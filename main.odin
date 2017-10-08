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

import "core:strings.odin"
import "core:math.odin"
import "core:fmt.odin"
import "core:os.odin"

import "shared:odin-glfw/glfw.odin"
import "shared:odin-gl/gl.odin"
import "shared:odin-fbx/fbx.odin"

import "rift.odin"
import "utils.odin"

vec2 :: struct {
    x, y: f32,
};

vec3 :: struct {
    x, y, z: f32,
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

Vec3 :: struct #ordered {
    x, y, z: f32,
};

Vertex :: struct #ordered {
    position, normal: Vec3,
};

Model :: struct {
    vertices: []Vertex,
    
    num_vertices: int,
    num_triangles: int,

    bbox: [6]f32 = [6]f32{1.0e9, -1.0e9, 1.0e9, -1.0e9, 1.09e9, -1.0e9},

    vao: u32,
    vbo: u32,
};

model_init_and_upload :: proc(using model: ^Model) {
    gl.CreateBuffers(1, &vbo);
    gl.NamedBufferData(vbo, size_of(Vertex)*num_vertices, &vertices[0], gl.STATIC_DRAW);
    
    gl.CreateVertexArrays(1, &vao);
    gl.VertexArrayVertexBuffer(vao, 0, vbo, 0, size_of(Vertex));

    gl.EnableVertexArrayAttrib(vao, 0);
    gl.EnableVertexArrayAttrib(vao, 1);
    
    gl.VertexArrayAttribFormat(vao, 0, 3, gl.FLOAT, gl.FALSE, 0);
    gl.VertexArrayAttribFormat(vao, 1, 3, gl.FLOAT, gl.FALSE, 12);

    gl.VertexArrayAttribBinding(vao, 0, 0);
    gl.VertexArrayAttribBinding(vao, 1, 0);
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

    //glfw.WindowHint(glfw.SAMPLES, 4);
    glfw.WindowHint(glfw.CONTEXT_VERSION_MAJOR, 4);
    glfw.WindowHint(glfw.CONTEXT_VERSION_MINOR, 5);
    glfw.WindowHint(glfw.OPENGL_PROFILE, glfw.OPENGL_CORE_PROFILE);

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
    gl.load_up_to(4, 5, set_proc_address);
    fmt.fprintln(os.stderr, "Loaded OpenGL function pointers");



    load_part :: proc(part: ^fbx.Geometry) -> Model {
        using model: Model;
        vertices = make([]Vertex, len(part.indices));
        for index, j in part.indices {
            i := int(index < 0 ? -1*index - 1 : index);
            x,  y,  z  := part.vertices[3*i+0], part.vertices[3*i+1], part.vertices[3*i+2];
            nx, ny, nz := part.normals[3*j+0],  part.normals[3*j+1],  part.normals[3*j+2];

            bbox[0] = min(bbox[0], f32(x));
            bbox[1] = max(bbox[1], f32(x));
            bbox[2] = min(bbox[2], f32(y));
            bbox[3] = max(bbox[3], f32(y));
            bbox[4] = min(bbox[4], f32(z));
            bbox[5] = max(bbox[5], f32(z));

            vertices[j] = Vertex{Vec3{f32(x),  f32(y),  f32(z)}, Vec3{f32(nx), f32(ny), f32(nz)}};
        }

        fmt.println(bbox);


        num_vertices = len(vertices);
        num_triangles = num_vertices/3;

        model_init_and_upload(&model);

        return model;
    }

    fbx_right := fbx.load_fbx("models/rightController.FBX");
    fbx_left := fbx.load_fbx("models/leftController.FBX");
    model := fbx.create_model_from_fbx(&fbx_right);
    model2 := fbx.create_model_from_fbx(&fbx_left);

    models := make([]Model, len(model.parts));
    models2 := make([]Model, len(model2.parts));



    /*
    rightController::Model
    menuButton::Model
    confimButton::Model
    cancelButton::Model
    stick::Model
    grip::Model
    trigger::Model
    */
    for _, i in model.parts {
        models[i] = load_part(&model.parts[i]);
        fmt.printf("%.6f %.6f %.6f\n", model.parts[i].local_translation[0], model.parts[i].local_translation[1],model.parts[i].local_translation[2]);
    }
    for _, i in model2.parts {
        models2[i] = load_part(&model2.parts[i]);
        fmt.printf("%.6f %.6f %.6f\n", model2.parts[i].local_translation[0], model2.parts[i].local_translation[1],model2.parts[i].local_translation[2]);
    }

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
    mirror_desc := ovrMirrorTextureDesc{ovrTextureFormat.OVR_FORMAT_R8G8B8A8_UNORM_SRGB, resx, resy, u32(ovrTextureMiscFlags.ovrTextureMisc_None), 0};

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
    eye_render_desc := [2]ovrEyeRenderDesc{
        ovr_GetRenderDesc(session, ovrEyeType.ovrEye_Left, hmd_desc.MaxEyeFov[0]), 
        ovr_GetRenderDesc(session, ovrEyeType.ovrEye_Right, hmd_desc.MaxEyeFov[1])
    };
    hmd_to_eye_pose := [2]ovrPosef{ eye_render_desc[0].HmdToEyePose, eye_render_desc[1].HmdToEyePose };
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



    vao_coordinates: u32;
    gl.GenVertexArrays(1, &vao_coordinates);
    gl.BindVertexArray(vao_coordinates);

    vertices_coordinates := [...]f32 {-1.0,  0.0,  0.0, 
                                       1.0,  0.0,  0.0,
                                       0.0, -1.0,  0.0,
                                       0.0,  1.0,  0.0,
                                       0.0,  0.0, -1.0,
                                       0.0,  0.0,  1.0
    };
    vbo_lines: u32;
    gl.GenBuffers(1, &vbo_lines);
    gl.BindBuffer(gl.ARRAY_BUFFER, vbo_lines);
    gl.BufferData(gl.ARRAY_BUFFER, size_of(vertices_coordinates), &vertices_coordinates[0], gl.STATIC_DRAW);

    gl.EnableVertexAttribArray(0);
    gl.VertexAttribPointer(0, 3, gl.FLOAT, gl.FALSE, 0, nil);


    //-------------------------------------------------------------------------------------------//    

    // Enable SRGB and depth test and set background color
    gl.Enable(gl.DEPTH_TEST);
    gl.Enable(gl.FRAMEBUFFER_SRGB);
    gl.ClearColor(0.2, 0.3, 0.4, 1.0); 

    fmt.println("num models:", len(models));

    uniforms := gl.get_uniforms_from_program(program);
    defer for uniform, name in uniforms do free(uniform.name);

    for uniform, name in uniforms {
        fmt.println(name, uniform);
    }
        
    hmd_to_eye_pose[0].Position.x = -0.001;
    hmd_to_eye_pose[1].Position.x = 0.001;

    frame_index: i64 = 0;
    for glfw.WindowShouldClose(window) == 0 {
        glfw.PollEvents();

        glfw.calculate_frame_timings(window);

        // See: https://developer.oculus.com/documentation/pcsdk/latest/concepts/dg-sensor/#dg-sensor-head-tracking

        // Get the predicted head pose for the current frame
        ovr_GetEyePoses(session, frame_index, ovrTrue, &hmd_to_eye_pose[0], &layer.RenderPose[0], &layer.SensorSampleTime);

        // Get controller tracking state (i.e. position and orientation)
        ts := ovr_GetTrackingState(session, 0, 1);

        // Get controller input state (i.e. buttons)
        is: ovrInputState;
        ovr_GetInputState(session, ovrControllerType.ovrControllerType_Touch, &is);
        p_left := ts.HandPoses[0].ThePose.Position;
        p_right := ts.HandPoses[1].ThePose.Position;

        
        // @NOTE: add pre-orientation to model quaternion, swaps y and z components of offsets and negates the new y component.
        q_reorient1 := ovrQuatf{0.0, math.sin(math.to_radians(180.0/2)), 0.0, math.cos(math.to_radians(180.0/2))};
        q_reorient2 := ovrQuatf{math.sin(math.to_radians(-90.0/2)), 0.0, 0.0, math.cos(math.to_radians(-90.0/2))};
        q_reorient := qmul(q_reorient1, q_reorient2);
        q_left := qmul(ts.HandPoses[0].ThePose.Orientation, q_reorient);
        q_right := qmul(ts.HandPoses[1].ThePose.Orientation, q_reorient);

        AA : i32 = 2;
        for key in glfw.KEY_1...glfw.KEY_9 {
            if glfw.GetKey(window, i32(key)) == glfw.PRESS {
                AA = i32(key) - glfw.KEY_1 + 1;
            }
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
            p_hmd := layer.RenderPose[1-eye].Position;
            q_hmd := layer.RenderPose[1-eye].Orientation;
            gl.Uniform3fv(get_uniform_location(program, "p_hmd\x00"), 1, &p_hmd.x);
            gl.Uniform4fv(get_uniform_location(program, "q_hmd\x00"), 1, &q_hmd.x);

            d := f32(40.0);
            light_positions := [...]f32 { -d,  d, d,   d,  d, d,   -d, -d, d,   d, -d, d };

            l := f32(300.0);
            light_colors := [...]f32 { l, l, l,  l, l, l,  l, l, l,  l, l, l };

            gl.Uniform3f(get_uniform_location(program, "albedo"), 0.0, 0.0, 0.0);
            gl.Uniform1f(get_uniform_location(program, "metallic"), 0.3);
            gl.Uniform1f(get_uniform_location(program, "roughness"), 0.5);
            gl.Uniform1f(get_uniform_location(program, "ao"), 1.0);
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

            // Left controller
            /*
            draw_model2(program, model_left.vao, 
                       1, cast(u32)len(model_left.indices), 
                       ovrVector3f{0, 0 ,0}, 
                       p_left, q_left);
            */

            draw_coordinates_at :: proc(vao_coordinates, program: u32, p, d: ovrVector3f, q: ovrQuatf, c: ovrVector3f, o, n: int) {
                gl.UseProgram(program);
                gl.BindVertexArray(vao_coordinates);
                
                gl.Uniform1i(get_uniform_location(program, "apply_texture\x00"), 2);
                
                gl.Uniform3f(get_uniform_location(program, "coordinate_color\x00"), c.x, c.y, c.z);
                gl.Uniform3f(get_uniform_location(program, "d_model\x00"), d.x, d.y, d.z);
                gl.Uniform3f(get_uniform_location(program, "p_model\x00"), p.x, p.y, p.z);
                gl.Uniform4f(get_uniform_location(program, "q_model\x00"), q.x, q.y, q.z, q.w);

                gl.DrawArraysInstanced(gl.TRIANGLE_STRIP, 0, 18, 3);

            }
            draw_coordinates_at :: proc(vao_coordinates, program: u32, p, d: ovrVector3f, q,q2: ovrQuatf, c: ovrVector3f, o, n: int) {
                gl.UseProgram(program);
                gl.BindVertexArray(vao_coordinates);
                
                gl.Uniform1i(get_uniform_location(program, "apply_texture\x00"), 2);
                
                gl.Uniform3f(get_uniform_location(program, "coordinate_color\x00"), c.x, c.y, c.z);
                gl.Uniform3f(get_uniform_location(program, "d_model\x00"), d.x, d.y, d.z);
                gl.Uniform3f(get_uniform_location(program, "p_model\x00"), p.x, p.y, p.z);
                gl.Uniform4f(get_uniform_location(program, "q_model\x00"), q.x, q.y, q.z, q.w);
                gl.Uniform4f(get_uniform_location(program, "q_pre\x00"), q2.x, q2.y, q2.z, q2.w);

                gl.DrawArraysInstanced(gl.TRIANGLE_STRIP, 0, 18, 3);

            }
            draw_coordinates_at(vao_coordinates, program, p_right, ovrVector3f{0.0, 0.0, 0.0}, q_right, ovrVector3f{0.0, 0.0, 0.0}, 0, 6);
            
            gl.UseProgram(program);
            gl.Uniform1i(get_uniform_location(program, "apply_texture\x00"), 1);

            draw_controller_part :: proc(program: u32, vao: u32, num_vertices: i32, d_pivot, d_model, p_model: ovrVector3f, q_pivot, q_model: ovrQuatf) {
                gl.Uniform3fv(get_uniform_location(program, "d_pivot\x00"), 1, &d_pivot.x);
                gl.Uniform4fv(get_uniform_location(program, "q_pivot\x00"), 1, &q_pivot.x);

                gl.Uniform3fv(get_uniform_location(program, "p_model\x00"), 1, &p_model.x);
                gl.Uniform4fv(get_uniform_location(program, "q_model\x00"), 1, &q_model.x);
                gl.Uniform3fv(get_uniform_location(program, "d_model\x00"), 1, &d_model.x);

                gl.BindVertexArray(vao);
                gl.DrawArrays(gl.TRIANGLES, 0, num_vertices);  
            }

            {
                // Menu
                draw_controller_part(program, models[1].vao, cast(i32)models[1].num_vertices, ovrVector3f{}, ovrVector3f{}, p_right, ovrQuatf{}, q_right);
                draw_controller_part(program, models2[2].vao, cast(i32)models2[2].num_vertices, ovrVector3f{}, ovrVector3f{}, p_left, ovrQuatf{}, q_left);
            }

            {
                // B
                dp := ovrVector3f{0.008937141 - (0.009135387), 0.005691095 - (0.005499177), -0.001804241 - (-0.000116555)};
                
                draw_controller_part(program, models[2].vao, cast(i32)models[2].num_vertices, ovrVector3f{}, is.Buttons&0x00000001 == 0 ? ovrVector3f{} : dp, p_right, ovrQuatf{}, q_right);
                draw_controller_part(program, models2[3].vao, cast(i32)models2[3].num_vertices, ovrVector3f{}, is.Buttons&0x00000100 == 0 ? ovrVector3f{} : dp, p_left, ovrQuatf{}, q_left);
            }

            {
                // A
                dp := ovrVector3f{0.001718102 - (0.00191709), -0.007191364 - (-0.007383698), -0.002603772 - (-0.0009119599)};

                draw_controller_part(program, models[3].vao, cast(i32)models[3].num_vertices, ovrVector3f{}, is.Buttons&0x00000002 == 0 ? ovrVector3f{} : dp, p_right, ovrQuatf{}, q_right);
                draw_controller_part(program, models2[4].vao, cast(i32)models2[4].num_vertices, ovrVector3f{}, is.Buttons&0x00000200 == 0 ? ovrVector3f{} : dp, p_left, ovrQuatf{}, q_left);
            }

            
            {
                // stick
                {
                    dx := is.Thumbstick[1].x;
                    dy := is.Thumbstick[1].y;
                    dr := math.sqrt(dx*dx + dy*dy + 1.0e-9);

                    a := 15.0*math.PI/180.0 * (dr/1.0);
                    q := ovrQuatf{dy/dr*math.sin(a/2), -dx/dr*math.sin(a/2), 0.0*math.sin(a/2), math.cos(a/2)};
                    d := ovrVector3f{-0.01063739, -0.004980708, -0.00941856};

                    draw_controller_part(program, models[4].vao, cast(i32)models[4].num_vertices, d, ovrVector3f{}, p_right, q, q_right);
                }
                {
                    dx := is.Thumbstick[0].x;
                    dy := is.Thumbstick[0].y;
                    dr := math.sqrt(dx*dx + dy*dy + 1.0e-9);

                    a := 15.0*math.PI/180.0 * (dr/1.0);
                    q := ovrQuatf{dy/dr*math.sin(a/2), -dx/dr*math.sin(a/2), 0.0*math.sin(a/2), math.cos(a/2)};
                    d := ovrVector3f{0.01063739, -0.004980708, -0.00941856};
                    draw_controller_part(program, models2[1].vao, cast(i32)models2[1].num_vertices, d, ovrVector3f{}, p_left, q, q_left);
                }
            }

            {
                // Grip

                {       
                    // Extract pivot axis from UP quaternion
                    x, y, z, w : f32= 0.04835906, 0.5594535, 0.8149385, 0.1433468; 
                    sinangle := math.sqrt(1.0 - w*w);
                    ax, ay, az := x/sinangle, y/sinangle, z/sinangle;

                    // interpolate angle between 0 and the difference in angle between the UP and DOWN quaternions
                    aa := is.HandTrigger[1]*0.0156846; // 2*0.0156846 == 2*arccos(0.1278072) - 2*arccos(0.1433468)
                    qq := ovrQuatf{ax*math.sin(aa), ay*math.sin(aa), az*math.sin(aa), math.cos(aa)}; // factor 1/2 cancels

                    // Interpolate position 
                    p1 := ovrVector3f{-0.01307428, 0.02563973, -0.02742721}; // Up position, y and z swapped due to 90 degree rotation, new y negated
                    p2 := ovrVector3f{-0.01826144, 0.02345688, -0.02513915}; // Down position, y and z swapped due to 90 degree rotation, new y negated
                    p := ovrVector3f{p1.x + (p2.x-p1.x)*is.HandTrigger[1], p1.y + (p2.y-p1.y)*is.HandTrigger[1],p1.z + (p2.z-p1.z)*is.HandTrigger[1]};

                    d := ovrVector3f{-0.0045*is.HandTrigger[1], -0.0005*is.HandTrigger[1], 0.0015*is.HandTrigger[1]}; 

                    draw_controller_part(program, models[5].vao, cast(i32)models[5].num_vertices, p, d, p_right, qq, q_right);
                }
                {       
                    // Extract pivot axis from UP quaternion
                    x, y, z, w : f32= 0.04835906, 0.5594535, 0.8149385, 0.1433468; 
                    sinangle := math.sqrt(1.0 - w*w);
                    ax, ay, az := x/sinangle, y/sinangle, z/sinangle;

                    // interpolate angle between 0 and the difference in angle between the UP and DOWN quaternions
                    aa := -is.HandTrigger[0]*0.0156846; // 2*0.0156846 == 2*arccos(0.1278072) - 2*arccos(0.1433468)
                    qq := ovrQuatf{ax*math.sin(aa), ay*math.sin(aa), az*math.sin(aa), math.cos(aa)}; // factor 1/2 cancels

                    // Interpolate position 
                    p1 := ovrVector3f{0.01307428, 0.02563973, -0.02742721}; // Up position, y and z swapped due to 90 degree rotation, new y negated
                    p2 := ovrVector3f{0.01826144, 0.02345688, -0.02513915}; // Down position, y and z swapped due to 90 degree rotation, new y negated
                    p := ovrVector3f{p1.x + (p2.x-p1.x)*is.HandTrigger[1], p1.y + (p2.y-p1.y)*is.HandTrigger[1],p1.z + (p2.z-p1.z)*is.HandTrigger[1]};

                    d := ovrVector3f{0.0045*is.HandTrigger[0], -0.0005*is.HandTrigger[0], 0.0015*is.HandTrigger[0]}; 

                    draw_controller_part(program, models2[5].vao, cast(i32)models2[5].num_vertices, p, d, p_left, qq, q_left);
                }
            }

            {
                {
                    // Trigger
                    x, y, z, w : f32= -0.6180527, 0.02941076, -0.05015482, 0.7839837;
            
                    cosangle := w;
                    sinangle := math.sqrt(1.0 - cosangle*cosangle);

                    aa := -is.IndexTrigger[1]*0.173899;
                    ax, ay, az := x/sinangle, y/sinangle, z/sinangle;

                    hmd_to_eye_pose[0].Position.x *= math.pow(0.9, aa);
                    hmd_to_eye_pose[1].Position.x *= math.pow(0.9, aa);

                    qq := ovrQuatf{ax*math.sin(aa), ay*math.sin(aa), az*math.sin(aa), math.cos(aa)};
                    p := ovrVector3f{0.001420307, -0.02186586, -0.005496453};

                    draw_controller_part(program, models[6].vao, cast(i32)models[6].num_vertices, p, ovrVector3f{}, p_right, qq, q_right);
                }
                {
                    // Trigger
                    x, y, z, w : f32= -0.6180527, 0.02941076, -0.05015482, 0.7839837;
            
                    cosangle := w; 
                    sinangle := math.sqrt(1.0 - cosangle*cosangle);

                    aa := -is.IndexTrigger[0]*0.173899;
                    ax, ay, az := x/sinangle, y/sinangle, z/sinangle;

                    hmd_to_eye_pose[0].Position.x *= math.pow(1.0/0.9, aa);
                    hmd_to_eye_pose[1].Position.x *= math.pow(1.0/0.9, aa);

                    qq := ovrQuatf{ax*math.sin(aa), ay*math.sin(aa), az*math.sin(aa), math.cos(aa)};
                    p := ovrVector3f{0.001420307, -0.02186586, -0.005496453};

                    draw_controller_part(program, models2[6].vao, cast(i32)models2[6].num_vertices, p, ovrVector3f{}, p_left, qq, q_left);
                }
            }
           
            draw_controller_part(program, models[0].vao, cast(i32)models[0].num_vertices, ovrVector3f{}, ovrVector3f{}, p_right, ovrQuatf{}, q_right);
            draw_controller_part(program, models2[0].vao, cast(i32)models2[0].num_vertices, ovrVector3f{}, ovrVector3f{}, p_left, ovrQuatf{}, q_left);
            
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
