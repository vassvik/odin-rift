///////////////////////////////////////////////////////////////////////////////////////////////////
//  
//   Simple Oculus Rift SDK example using OpenGL and GLFW. 
//  
//   Features full HMD head tracking and Touch controller tracking. 
//  
//   Parts should be familiar to you if you have read the PC SDK Developer Guide
//   at https://developer.oculus.com/documentation/pcsdk/latest/concepts/book-dg/
//  
//   Based in parts on OculusTinyRooms(GL).
//  
//   Note: Written in a sequential manner to make it easy to follow along,
//         which means, for the most part, that everything is contained in
//         a sequential order in main(). Related sections are separated by
//         a //---------------------------------------------------------//
//  
//   Note: Uses GLFW for window and OpenGL context creation
//         
//  
//  
//   Source statistics: 
//         
//  
///////////////////////////////////////////////////////////////////////////////////////////////////

import (
   "strings.odin";
   "math.odin";
   "fmt.odin";
   "os.odin";

   "glfw.odin";
   "gl.odin";

   "rift.odin";
   "utils.odin";
)

vec2 :: struct {
    x, y: f32;
};

vec3 :: struct {
    x, y, z: f32;
};

qmul :: proc(q1, q2: rift.ovrQuatf) -> rift.ovrQuatf {
    q: rift.ovrQuatf;
    q.x = (q1.w * q2.x) + (q1.x * q2.w) + (q1.y * q2.z) - (q1.z * q2.y);
    q.y = (q1.w * q2.y) - (q1.x * q2.z) + (q1.y * q2.w) + (q1.z * q2.x);
    q.z = (q1.w * q2.z) + (q1.x * q2.y) - (q1.y * q2.x) + (q1.z * q2.w);
    q.w = (q1.w * q2.w) - (q1.x * q2.x) - (q1.y * q2.y) - (q1.z * q2.z);
    return q;
}

get_uniform_location :: proc(program: u32, name: string) -> i32 {
    return gl.GetUniformLocation(program, &name[0]);
}

draw_model :: proc(program: u32, vao: u32, texture: u32, num_vertices: u32, d, p: rift.ovrVector3f, q: rift.ovrQuatf) {
    gl.UseProgram(program);
    gl.BindVertexArray(vao);

    gl.BindTexture(gl.TEXTURE_2D, texture);
    gl.Uniform1i(get_uniform_location(program, "apply_texture\x00"), texture != 0 ? 1 : 0);
    
    gl.Uniform3f(get_uniform_location(program, "d_model\x00"), d.x, d.y, d.z);
    gl.Uniform3f(get_uniform_location(program, "p_model\x00"), p.x, p.y, p.z);
    gl.Uniform4f(get_uniform_location(program, "q_model\x00"), q.x, q.y, q.z, q.w);

    gl.DrawArrays(gl.TRIANGLES, 0, i32(num_vertices));
}

draw_model2 :: proc(program: u32, vao: u32, texture: u32, num_elements: u32, d, p: rift.ovrVector3f, q: rift.ovrQuatf) {
    gl.UseProgram(program);
    gl.BindVertexArray(vao);
    
    gl.BindTexture(gl.TEXTURE_2D, texture);
    gl.Uniform1i(get_uniform_location(program, "apply_texture\x00"), texture != 0 ? 1 : 0);
    
    gl.Uniform3f(get_uniform_location(program, "d_model\x00"), d.x, d.y, d.z);
    gl.Uniform3f(get_uniform_location(program, "p_model\x00"), p.x, p.y, p.z);
    gl.Uniform4f(get_uniform_location(program, "q_model\x00"), q.x, q.y, q.z, q.w);

    gl.DrawElements(gl.TRIANGLES, i32(num_elements), gl.UNSIGNED_INT, nil);
}

main :: proc() {
    using rift;

    //-------------------------------------------------------------------------------------------//
    // See https://developer.oculus.com/documentation/pcsdk/latest/concepts/dg-sensor/#dg_sensor
    
    // Initialize OVR, GLFW and OpengL
    if !OVR_SUCCESS(ovr_Initialize(nil)) {
        print_last_rift_error();
        return;
    }
    defer ovr_Shutdown();
    fmt.fprintln(os.stderr, "Succeeded initializing OVR");

    session : ovrSession;
    luid : ovrGraphicsLuid;
    if !OVR_SUCCESS(ovr_Create(&session, &luid)) {
        print_last_rift_error();
        return;
    }
    defer ovr_Destroy(session);
    fmt.fprintln(os.stderr, "Succeeded creating VR session");

    //-------------------------------------------------------------------------------------------//
    error_callback :: proc(error: i32, desc: ^u8) #cc_c {
        fmt.printf("Error code %d:\n    %s\n", error, strings.to_odin_string(desc));
    }
    glfw.SetErrorCallback(error_callback);

    if glfw.Init() == 0 {
        return;
    }
    defer glfw.Terminate();
    fmt.fprintln(os.stderr, "Succeeded initializing GLFW");

    glfw.WindowHint(glfw.SAMPLES, 4);    // samples, for antialiasing

    title := "Rift minimal example (Odin)\x00";
    resx, resy : i32 = 1600, 900;
    window := glfw.CreateWindow(resx, resy, &title[0], nil, nil);
    if window == nil {
        return;
    }
    fmt.fprintln(os.stderr, "Succeeded creating GLFW window");

    glfw.MakeContextCurrent(window);
    glfw.SwapInterval(0);

    // Load OpenGL function pointers using glfw.GetProcAddress
    set_proc_address :: proc(p: rawptr, name: string) { 
        (cast(^rawptr)p)^ = rawptr(glfw.GetProcAddress(&name[0]));
    }
    gl.load_up_to(3, 3, set_proc_address);
    fmt.fprintln(os.stderr, "Loaded OpenGL function pointers");

    //-------------------------------------------------------------------------------------------//
    // https://developer.oculus.com/documentation/pcsdk/latest/concepts/dg-render/#dg-render-initialize

    // Get general headset description.
    // Used in particular for getting headset FOV parameters
    hmd_desc := ovr_GetHmdDesc(session);

    // Setup texture swap chains. One texture chain per eye, and each chain has 3 textures.
    // Each eye can in general have different FOV values, and different texture sizes.
    // These textures are handled internally by the Oculus SDK.
    eye_texture_sizes: [2]ovrSizei;
    texture_swap_chains: [2]ovrTextureSwapChain;

    for eye in 0...1 {
        eye_texture_sizes[eye] = ovr_GetFovTextureSize(session, ovrEyeType(eye), hmd_desc.MaxEyeFov[eye], 1.0);

        desc := ovrTextureSwapChainDesc{
            ovrTextureType.ovrTexture_2D, 
            ovrTextureFormat.OVR_FORMAT_R8G8B8A8_UNORM_SRGB, 
            1, 
            eye_texture_sizes[eye].w, 
            eye_texture_sizes[eye].h, 
            1, 
            1, 
            ovrFalse, 
            u32(ovrTextureMiscFlags.ovrTextureMisc_None), 
            u32(ovrTextureBindFlags.ovrTextureBind_None)
        };
        if (!OVR_SUCCESS(ovr_CreateTextureSwapChainGL(session, &desc, &texture_swap_chains[eye]))) {
            print_last_rift_error();
            return;
        }

        length: i32;
        ovr_GetTextureSwapChainLength(session, texture_swap_chains[eye], &length);
        for i in 0..length {
            chain_tex_id: u32;
            if (!OVR_SUCCESS(ovr_GetTextureSwapChainBufferGL(session, texture_swap_chains[eye], i, &chain_tex_id))) {
                print_last_rift_error();
                return;
            }
            gl.BindTexture(gl.TEXTURE_2D, chain_tex_id);

            gl.TexParameteri(gl.TEXTURE_2D, gl.TEXTURE_MIN_FILTER, gl.LINEAR);
            gl.TexParameteri(gl.TEXTURE_2D, gl.TEXTURE_MAG_FILTER, gl.LINEAR);
            gl.TexParameteri(gl.TEXTURE_2D, gl.TEXTURE_WRAP_S, gl.CLAMP_TO_EDGE);
            gl.TexParameteri(gl.TEXTURE_2D, gl.TEXTURE_WRAP_T, gl.CLAMP_TO_EDGE);
        }
    }
    defer ovr_DestroyTextureSwapChain(session, texture_swap_chains[0]);
    defer ovr_DestroyTextureSwapChain(session, texture_swap_chains[1]);
    fmt.fprintln(os.stderr, "Created texture swap chains for both eyes");

    //-------------------------------------------------------------------------------------------//

    // Set up a "mirror texture" that is used to mirror what's rendered in the headset to the default framebuffer
    // This is a done using a simple blit at the end of the rendering loop. 
    // This is a configured as a simple frame buffer with no depth info.
    // This texture is handled internally by the Oculus SDK.
    //
    // @Note: An alternative to this is to do a separate monoscopic rendering pass that is displayed in the main window
    mirror_texture_ovr: ovrMirrorTexture;
    mirror_desc := ovrMirrorTextureDesc{ovrTextureFormat.OVR_FORMAT_R8G8B8A8_UNORM_SRGB, resx, resy, u32(ovrTextureMiscFlags.ovrTextureMisc_None)};

    if (!OVR_SUCCESS(ovr_CreateMirrorTextureGL(session, &mirror_desc, &mirror_texture_ovr))) { 
        print_last_rift_error();
        return;
    }
    defer ovr_DestroyMirrorTexture(session, mirror_texture_ovr);
    fmt.fprintln(os.stderr, "Created and configured mirror texture");


    mirror_texture_gl: u32;
    if (!OVR_SUCCESS(ovr_GetMirrorTextureBufferGL(session, mirror_texture_ovr, &mirror_texture_gl))) {
        print_last_rift_error();
        return;
    }

    mirror_fbo: u32;
    gl.GenFramebuffers(1, &mirror_fbo);
    gl.BindFramebuffer(gl.READ_FRAMEBUFFER, mirror_fbo);
    gl.FramebufferTexture2D(gl.READ_FRAMEBUFFER, gl.COLOR_ATTACHMENT0, gl.TEXTURE_2D, mirror_texture_gl, 0);
    gl.FramebufferRenderbuffer(gl.READ_FRAMEBUFFER, gl.DEPTH_ATTACHMENT, gl.RENDERBUFFER, 0);
    gl.BindFramebuffer(gl.READ_FRAMEBUFFER, 0);
    defer gl.DeleteFramebuffers(1, &mirror_fbo);
    fmt.fprintln(os.stderr, "Configured mirror texture framebuffer");

    //-------------------------------------------------------------------------------------------//    

    // We use a single framebuffer to render to for both eyes, 
    // but we bind different eye texture to it depending on which
    // buffer in the chain is used and which eye we are current rendering
    eye_fbo: u32;
    gl.GenFramebuffers(1, &eye_fbo);
    defer gl.DeleteFramebuffers(1, &eye_fbo);
    fmt.fprintln(os.stderr, "Configured per-eye framebuffers");


    // We use one texture per eye as a depth buffer.
    // Depth buffers can be handled manually or as a separate texture chain (?)
    depth_textures: [2]u32;
    gl.GenTextures(2, &depth_textures[0]);
    defer gl.DeleteTextures(2, &depth_textures[0]);

    for eye in 0...1 {
        gl.BindTexture(gl.TEXTURE_2D, depth_textures[eye]);

        gl.TexParameteri(gl.TEXTURE_2D, gl.TEXTURE_MIN_FILTER, gl.LINEAR);
        gl.TexParameteri(gl.TEXTURE_2D, gl.TEXTURE_MAG_FILTER, gl.LINEAR);
        gl.TexParameteri(gl.TEXTURE_2D, gl.TEXTURE_WRAP_S, gl.CLAMP_TO_EDGE);
        gl.TexParameteri(gl.TEXTURE_2D, gl.TEXTURE_WRAP_T, gl.CLAMP_TO_EDGE);

        gl.TexImage2D(gl.TEXTURE_2D, 0, gl.DEPTH_COMPONENT24, eye_texture_sizes[eye].w, eye_texture_sizes[eye].h, 0, gl.DEPTH_COMPONENT, gl.UNSIGNED_INT, nil);
    }
    fmt.fprintln(os.stderr, "Created per-eye depth buffers");

    //-------------------------------------------------------------------------------------------//
    // See: https://developer.oculus.com/documentation/pcsdk/latest/concepts/dg-render/#dg-render-layers

    // Oculus' SDK support "layers", which are like individual windows in an operating system.
    // Usually there is one "3D" layer that is the usual render, then there can be additional 
    // layers on top of that to represent UI elements, floating text, etc.
    // Most of the information in the layer stay constant, so we keep it outside the render 
    // loop for now.
    layer := ovrLayerEyeFov {
        Header = ovrLayerHeader {
            Type = ovrLayerType.ovrLayerType_EyeFov, 
            Flags = u32(ovrLayerFlags.ovrLayerFlag_TextureOriginAtBottomLeft)
        }, 
        ColorTexture = [2]ovrTextureSwapChain {
            texture_swap_chains[0], 
            texture_swap_chains[1]
        },
        Viewport = [2]ovrRecti{
            ovrRecti{
                Pos = ovrVector2i{0, 0}, 
                Size = ovrSizei{eye_texture_sizes[0].w, eye_texture_sizes[0].h}
            }, 
            ovrRecti{
                Pos = ovrVector2i{0, 0}, 
                Size = ovrSizei{eye_texture_sizes[1].w, eye_texture_sizes[1].h}
            }, 
        },
        Fov = [2]ovrFovPort{
            hmd_desc.MaxEyeFov[0], 
            hmd_desc.MaxEyeFov[1]
        },

        // RenderPose and SensorSampleTime set in render loop, so set to default values
        RenderPose = [2]ovrPosef{
            ovrPosef{
                ovrQuatf{0.0, 0.0, 0.0, 1.0},
                ovrVector3f{0.0, 0.0, 0.0},
            },
            ovrPosef{
                ovrQuatf{0.0, 0.0, 0.0, 1.0},
                ovrVector3f{0.0, 0.0, 0.0},
            },
        },
        SensorSampleTime = f64(0.0),
    };
    
    // Used to get the current Eye poses in the render loop, as long as the Fov stays unchanged.
    // The eye offsets are used to construct view matrices for each eye.
    // See: https://developer.oculus.com/documentation/pcsdk/latest/concepts/dg-render/#dg-render-frame
    eye_render_desc: [2]ovrEyeRenderDesc = [2]ovrEyeRenderDesc{
        ovr_GetRenderDesc(session, ovrEyeType.ovrEye_Left, hmd_desc.MaxEyeFov[0]), 
        ovr_GetRenderDesc(session, ovrEyeType.ovrEye_Right, hmd_desc.MaxEyeFov[1])
    };
    hmd_to_eye_offset: [2]ovrVector3f = [2]ovrVector3f{ eye_render_desc[0].HmdToEyeOffset, eye_render_desc[1].HmdToEyeOffset };
    fmt.fprintln(os.stderr, "Set up default layer, render descriptions and offsets to each eye.");


    // Load shaders from files
    program, success := gl.load_shaders("shaders/vertex_shader.vs", "shaders/fragment_shader.fs");
    if !success {
        fmt.fprintln(os.stderr, "Could not load shaders. Exiting.");
        return;
    }
    defer gl.DeleteProgram(program);


    model_left, status_left := utils.read_obj("models/Oculus_Left.obj");
    model_right, status_right := utils.read_obj("models/Oculus_Right.obj");
    //if true do return;
    
    //num_vertices_controllers: [2]u32 = [2]u32{u32(len(v1)), u32(len(v2))};

    load_model :: proc(using model: ^utils.Model) {
        gl.GenVertexArrays(1, &vao);
        gl.BindVertexArray(vao);

        gl.GenBuffers(3, &vbos[0]);
        gl.GenBuffers(1, &ebo);

        gl.BindBuffer(gl.ARRAY_BUFFER, vbos[0]);
        gl.BufferData(gl.ARRAY_BUFFER, size_of(positions[0])*len(positions), &positions[0], gl.STATIC_DRAW);   
        gl.VertexAttribPointer(0, 3, gl.FLOAT, gl.FALSE, 0, nil);
        gl.EnableVertexAttribArray(0);

        gl.BindBuffer(gl.ARRAY_BUFFER, vbos[1]);
        gl.BufferData(gl.ARRAY_BUFFER, size_of(normals[0])*len(normals), &normals[0], gl.STATIC_DRAW);   
        gl.VertexAttribPointer(1, 3, gl.FLOAT, gl.FALSE, 0, nil);
        gl.EnableVertexAttribArray(1);

        gl.BindBuffer(gl.ARRAY_BUFFER, vbos[2]);
        gl.BufferData(gl.ARRAY_BUFFER, size_of(uvs[0])*len(uvs), &uvs[0], gl.STATIC_DRAW);   
        gl.VertexAttribPointer(2, 2, gl.FLOAT, gl.FALSE, 0, nil);
        gl.EnableVertexAttribArray(2);

        gl.BindBuffer(gl.ELEMENT_ARRAY_BUFFER, ebo);
        gl.BufferData(gl.ELEMENT_ARRAY_BUFFER, size_of(indices[0])*len(indices), &indices[0], gl.STATIC_DRAW);
        
        fmt.println(size_of(positions[0])*len(positions), size_of(normals[0])*len(normals), size_of(uvs[0])*len(uvs), size_of(indices[0])*len(indices));
    }

    unload_model :: proc(using model: ^utils.Model) {
        gl.DeleteVertexArrays(1, &vao);
        gl.DeleteBuffers(3, &vbos[0]);
        gl.DeleteBuffers(1, &ebo);
    }

    load_model(&model_left);
    load_model(&model_right);

    defer {
        unload_model(&model_left);
        unload_model(&model_right);
    }


    // Setup "controller" texture and upload
    texture_width: i32 = 4;
    texture_height: i32 = 4;
    texture_data := [...]u8 {
        255, 152,   0, // orange
        156,  39, 176, // purple
          3, 169, 244, // light blue
        139, 195,  74, // light green

        255,  87,  34, // deep orange
        103,  58, 183, // deep purple
          0, 188, 212, // cyan
        205, 220,  57, // lime

        244,  67,  54, // red
         63,  81, 181, // indigo
          0, 150, 137, // teal
        255, 235,  59, // yellow
        
        233,  30,  99, // pink
         33, 150, 243, // blue
         76, 175,  80, // green
        255, 193,   7, // amber
    };

    texture_controller: u32;
    gl.GenTextures(1, &texture_controller);
    gl.ActiveTexture(gl.TEXTURE0);
    gl.BindTexture(gl.TEXTURE_2D, texture_controller);

    gl.TexParameteri(gl.TEXTURE_2D, gl.TEXTURE_MIN_FILTER, gl.NEAREST);
    gl.TexParameteri(gl.TEXTURE_2D, gl.TEXTURE_MAG_FILTER, gl.NEAREST);
    gl.TexParameteri(gl.TEXTURE_2D, gl.TEXTURE_WRAP_S, gl.REPEAT);
    gl.TexParameteri(gl.TEXTURE_2D, gl.TEXTURE_WRAP_T, gl.REPEAT);
    gl.TexImage2D(gl.TEXTURE_2D, 0, gl.SRGB, texture_width, texture_height, 0, gl.RGB, gl.UNSIGNED_BYTE, &texture_data[0]);

    gl.UseProgram(program);
    gl.Uniform1i(get_uniform_location(program, "texture_sampler\x00"), 0);

    defer {
        gl.DeleteTextures(1, &texture_controller);
    }





    // Setup room vao, vbo and vertex attribs, and upload
    vao_room: u32;
    gl.GenVertexArrays(1, &vao_room);
    gl.BindVertexArray(vao_room);

    half_side: f32 = 30.0;
    floor_height: f32 = -2.0; // @TODO: use actual floor/sitting height instead of 2 meters..
    roof_height: f32 = 3.0;
    


    cubeVertices:= [8*3]vec3 {
        vec3{-half_side,  roof_height,  -half_side},
        vec3{ half_side,  roof_height,  -half_side},
        vec3{-half_side,  roof_height,   half_side},
        vec3{ half_side,  roof_height,   half_side},
        vec3{-half_side,  floor_height, -half_side},
        vec3{ half_side,  floor_height, -half_side},
        vec3{-half_side,  floor_height,  half_side},
        vec3{ half_side,  floor_height,  half_side},
    };

    cubeIndices := [14]i32 {
        0, 1, 2, 3, 7, 1, 5, 4, 7, 6, 2, 4, 0, 1
    };



    dot :: proc(a, b: vec3) -> f32 { return a.x*b.x + a.y*b.y + a.z*b.z; };

    norm :: proc(v: vec3) -> vec3 {
        mag := math.sqrt(dot(v,v));
        return vec3{v.x/mag, v.y/mag, v.z/mag};
    }

    cross :: proc(a, b: vec3) -> vec3 { 
        return vec3{a.y*b.z - a.z*b.y, 
                    a.z*b.x - a.x*b.z, 
                    a.x*b.y - a.y*b.x};
    };

    normal_triangle :: proc(a, b, c: vec3) -> vec3 {
        v1 := vec3{b.x - a.x, b.y - a.y, b.z - a.z};
        v2 := vec3{c.x - a.x, c.y - a.y, c.z - a.z};
        return norm(cross(v1, v2));
    }

    num_indices_room :: 14;
    num_triangles_room :: num_indices_room - 2; // since it is a triangle strip of N indices, there are N-2 triangles
    num_vertices_room :: 3*num_triangles_room; // needed by glDrawArrays

    pos_data_room:    [num_vertices_room]vec3;
    normal_data_room: [num_vertices_room]vec3;
    uv_data_room:     [num_vertices_room]vec2;

    for i in 0..num_triangles_room {

        pos_data_room[3*i+0] = cubeVertices[cubeIndices[i + 0 + (i % 2)]];;
        pos_data_room[3*i+1] = cubeVertices[cubeIndices[i + 1 - (i % 2)]];;
        pos_data_room[3*i+2] = cubeVertices[cubeIndices[i + 2]];;

        // vertices are in clockwise winding order, so the (outward) normal is just the normalized cross product
        normal := normal_triangle(pos_data_room[3*i+0], pos_data_room[3*i+1], pos_data_room[3*i+2]);
        normal_data_room[3*i+0] = normal;
        normal_data_room[3*i+1] = normal;
        normal_data_room[3*i+2] = normal; 

        if abs(normal.x) > 0.5 {
            uv_data_room[3*i+0] = vec2{pos_data_room[3*i+0].y, pos_data_room[3*i+0].z};
            uv_data_room[3*i+1] = vec2{pos_data_room[3*i+1].y, pos_data_room[3*i+1].z};
            uv_data_room[3*i+2] = vec2{pos_data_room[3*i+2].y, pos_data_room[3*i+2].z};
        } else if abs(normal.y) > 0.5 {
            uv_data_room[3*i+0] = vec2{pos_data_room[3*i+0].x, pos_data_room[3*i+0].z};
            uv_data_room[3*i+1] = vec2{pos_data_room[3*i+1].x, pos_data_room[3*i+1].z};
            uv_data_room[3*i+2] = vec2{pos_data_room[3*i+2].x, pos_data_room[3*i+2].z};
        } else if abs(normal.z) > 0.5 {
            uv_data_room[3*i+0] = vec2{pos_data_room[3*i+0].x, pos_data_room[3*i+0].y};
            uv_data_room[3*i+1] = vec2{pos_data_room[3*i+1].x, pos_data_room[3*i+1].y};
            uv_data_room[3*i+2] = vec2{pos_data_room[3*i+2].x, pos_data_room[3*i+2].y};
        }
    }



    vbo_pos_room: u32;
    gl.GenBuffers(1, &vbo_pos_room);
    gl.BindBuffer(gl.ARRAY_BUFFER, vbo_pos_room);
    gl.BufferData(gl.ARRAY_BUFFER, size_of(pos_data_room), &pos_data_room[0], gl.STATIC_DRAW);
   
    gl.EnableVertexAttribArray(0);
    gl.VertexAttribPointer(0, 3, gl.FLOAT, gl.FALSE, 0, nil);
    
    vbo_normal_room: u32;
    gl.GenBuffers(1, &vbo_normal_room);
    gl.BindBuffer(gl.ARRAY_BUFFER, vbo_normal_room);
    gl.BufferData(gl.ARRAY_BUFFER, size_of(normal_data_room), &normal_data_room[0], gl.STATIC_DRAW);

    gl.EnableVertexAttribArray(1);
    gl.VertexAttribPointer(1, 3, gl.FLOAT, gl.FALSE, 0, nil);

    vbo_uv_room: u32;
    gl.GenBuffers(1, &vbo_uv_room);
    gl.BindBuffer(gl.ARRAY_BUFFER, vbo_uv_room);
    gl.BufferData(gl.ARRAY_BUFFER, size_of(uv_data_room), &uv_data_room[0], gl.STATIC_DRAW);

    gl.EnableVertexAttribArray(2);
    gl.VertexAttribPointer(2, 2, gl.FLOAT, gl.FALSE, 0, nil);


    defer {
        gl.DeleteBuffers(1, &vbo_pos_room);
        gl.DeleteBuffers(1, &vbo_normal_room);
        gl.DeleteBuffers(1, &vbo_uv_room);
        gl.DeleteVertexArrays(1, &vao_room);
    }

    //-------------------------------------------------------------------------------------------//    



    // Enable SRGB and depth test and set background color
    gl.Enable(gl.DEPTH_TEST);
    gl.Enable(gl.FRAMEBUFFER_SRGB);
    gl.ClearColor(0.2, 0.3, 0.4, 1.0); 

    //controller_offset_x, controller_offset_y, controller_offset_z : f32 = -0.0067174, 0.0017909, -0.0525607;
    controller_offset_x, controller_offset_y, controller_offset_z : f32 = 0.0, 0.0, 0.0;

    frame_index: i64 = 0;
    for glfw.WindowShouldClose(window) == 0 {
        glfw.PollEvents();

        glfw.calculate_frame_timings(window);

        // See: https://developer.oculus.com/documentation/pcsdk/latest/concepts/dg-sensor/#dg-sensor-head-tracking

        // Get the predicted head pose for the current frame
        ovr_GetEyePoses(session, frame_index, ovrTrue, &hmd_to_eye_offset[0], &layer.RenderPose[0], &layer.SensorSampleTime);

        // Get controller tracking state (i.e. position and orientation)
        ts := ovr_GetTrackingState(session, 0, 1);

        // Get controller input state (i.e. buttons)
        is: ovrInputState;
        ovr_GetInputState(session, ovrControllerType.ovrControllerType_Touch, &is);

        p_left := ts.HandPoses[0].ThePose.Position;
        p_right := ts.HandPoses[1].ThePose.Position;

        q_reorient := ovrQuatf{0.0, math.sin(math.to_radians(180.0/2)), 0.0, math.cos(math.to_radians(180.0/2))};
        q_left := qmul(ts.HandPoses[0].ThePose.Orientation, q_reorient);
        q_right := qmul(ts.HandPoses[1].ThePose.Orientation, q_reorient);

        AA : i32 = 2;
        for key in glfw.KEY_1...glfw.KEY_9 {
            if glfw.GetKey(window, i32(key)) == glfw.PRESS {
                AA = i32(key) - glfw.KEY_1 + 1;
            }
        }

        if glfw.GetKey(window, glfw.KEY_LEFT_CONTROL) == glfw.PRESS {
            controller_offset_x += f32(glfw.GetKey(window, glfw.KEY_D) - glfw.GetKey(window, glfw.KEY_A))*0.0001;
            controller_offset_y += f32(glfw.GetKey(window, glfw.KEY_E) - glfw.GetKey(window, glfw.KEY_Q))*0.0001;
            controller_offset_z += f32(glfw.GetKey(window, glfw.KEY_W) - glfw.GetKey(window, glfw.KEY_S))*0.0001;
        }

        // Upload uniforms that are the same per-eye
        gl.Uniform1f(get_uniform_location(program, "time\x00"), f32(glfw.GetTime()));
        gl.Uniform1i(get_uniform_location(program, "AA\x00"), AA);

        // Main rendering section. 

        // We need to render the scene twice, once for each eye.
        for eye in 0...1 {
            // Grab the current available color buffer texture from the texture swap chain.
            current_index: i32;
            ovr_GetTextureSwapChainCurrentIndex(session, texture_swap_chains[eye], &current_index);

            current_texture_id: u32;
            ovr_GetTextureSwapChainBufferGL(session, texture_swap_chains[eye], current_index, &current_texture_id);

            // Set up the framebuffer, using the current eye texture and depth texture for this eye.
            gl.BindFramebuffer(gl.FRAMEBUFFER, eye_fbo);
            gl.FramebufferTexture2D(gl.FRAMEBUFFER, gl.COLOR_ATTACHMENT0, gl.TEXTURE_2D, current_texture_id, 0);
            gl.FramebufferTexture2D(gl.FRAMEBUFFER, gl.DEPTH_ATTACHMENT, gl.TEXTURE_2D, depth_textures[eye], 0);

            // Setup render
            gl.Viewport(0, 0, eye_texture_sizes[eye].w, eye_texture_sizes[eye].h);
            gl.Clear(gl.COLOR_BUFFER_BIT | gl.DEPTH_BUFFER_BIT);

            // Upload this eye's perspective projection matrix
            P := ovrMatrix4f_Projection(hmd_desc.MaxEyeFov[eye], 0.2, 1000.0, u32(ovrProjectionModifier.ovrProjection_None));
            gl.UniformMatrix4fv(get_uniform_location(program, "P\x00"), 1, gl.TRUE, &P.M[0][0]);

            // Upload headset position and orientation as uniforms. 
            // The camera is rotated and translated according to these in the shader
            p_hmd := layer.RenderPose[eye].Position;
            q_hmd := layer.RenderPose[eye].Orientation;
            gl.Uniform3fv(get_uniform_location(program, "p_hmd\x00"), 1, &p_hmd.x);
            gl.Uniform4fv(get_uniform_location(program, "q_hmd\x00"), 1, &q_hmd.x);

            gl.Uniform3f(get_uniform_location(program, "albedo"), 0.0, 0.0, 0.0);
            gl.Uniform1f(get_uniform_location(program, "metallic"), 0.3);
            gl.Uniform1f(get_uniform_location(program, "roughness"), 0.5);
            gl.Uniform1f(get_uniform_location(program, "ao"), 1.0);

            d :f32 = 40.0;
            light_positions := [...]f32 {
                -d,  d, d,
                 d,  d, d,
                -d, -d, d,
                 d, -d, d,
            };

            l :f32= 300.0;
            light_colors := [...]f32 {
                l, l, l,
                l, l, l,
                l, l, l,
                l, l, l
            };
            gl.Uniform3fv(get_uniform_location(program, "lightPositions\x00"), 4, &light_positions[0]);
            gl.Uniform3fv(get_uniform_location(program, "lightColors\x00"), 4, &light_colors[0]);

            gl.Uniform3f(get_uniform_location(program, "camPos"), p_hmd.x, p_hmd.y, p_hmd.z);

            // @NOTE: The same shader is used to draw both the room (which is shaded based on position)
            // and the controllers (which are shaded based on uv's and a texture), 
            // by setting the "apply_texture" uniform to 0 (no texture) or 1 (using texture)

            // Draw the "room" first, which doesn't use any textures, but are shaded
            // based on the pixel's position/coverage relative to global gridlines

            // Room
            draw_model(program, vao_room, 
                       0, num_vertices_room, 
                       ovrVector3f{0.0, 0.0, 0.0}, 
                       ovrVector3f{0.0, 0.0, 0.0}, ovrQuatf{0.0, 0.0, 0.0, 1.0});
            /*
            // Left controller
            draw_model(program, vao_controllers[0], 
                       texture_controller, num_vertices_controllers[0], 
                       ovrVector3f{controller_offset_x, controller_offset_y, controller_offset_z}, 
                       p_left, q_left);

            // Right controller
            draw_model(program, vao_controllers[1], 
                       texture_controller, num_vertices_controllers[1], 
                       ovrVector3f{-controller_offset_x, controller_offset_y, controller_offset_z}, 
                       p_right, q_right);
        */
            // Left controller
            draw_model2(program, model_left.vao, 
                       texture_controller, cast(u32)len(model_left.indices), 
                       ovrVector3f{controller_offset_x, controller_offset_y, controller_offset_z}, 
                       p_left, q_left);

            // Right controller
            draw_model2(program, model_right.vao, 
                       texture_controller, cast(u32)len(model_right.indices), 
                       ovrVector3f{-controller_offset_x, controller_offset_y, controller_offset_z}, 
                       p_right, q_right);

            // Commit the render
            ovr_CommitTextureSwapChain(session, texture_swap_chains[eye]);
        }

        // Submit the layer(s), currently a single layer
        layer_header: ^ovrLayerHeader = &layer.Header;
        if (!OVR_SUCCESS(ovr_SubmitFrame(session, frame_index, nil, &layer_header, 1))) {
            print_last_rift_error();
            return;
        }

        // Blit mirror texture to back buffer
        // @NOTE: Alternatively do an additional monoscopic rendering to the main window
        gl.BindFramebuffer(gl.READ_FRAMEBUFFER, mirror_fbo);
        gl.BindFramebuffer(gl.DRAW_FRAMEBUFFER, 0);
        gl.BlitFramebuffer(0, resy, resx, 0,   0, 0, resx, resy,   gl.COLOR_BUFFER_BIT, gl.NEAREST);
        gl.BindFramebuffer(gl.FRAMEBUFFER, 0);

        // Done
        glfw.SwapBuffers(window);

        frame_index += 1;
    }
}


// Error reporting helpers:
print_last_rift_error :: proc() {
    using rift;

    errorInfo: ovrErrorInfo;
    ovr_GetLastErrorInfo(&errorInfo);
    fmt.fprintf(os.stderr, "Error %d, %s\n", errorInfo.Result, strings.to_odin_string(cast(^u8)&errorInfo.ErrorString[0]));
}


