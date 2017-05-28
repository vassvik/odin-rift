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

#import "strings.odin";
#import "fmt.odin";
#import "os.odin";

#import "glfw.odin";
#import "gl.odin";

#import "rift.odin";




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

    glfw.SetErrorCallback(error_callback);

    if glfw.Init() == 0 {
        return;
    }
    defer glfw.Terminate();
    fmt.fprintln(os.stderr, "Succeeded initializing GLFW");


    title := "Rift minimal example (Odin)\x00";
    resx, resy : i32 = 1600, 900;
    window := glfw.CreateWindow(resx, resy, ^byte(&title[0]), nil, nil);
    if window == nil {
        return;
    }
    fmt.fprintln(os.stderr, "Succeeded creating GLFW window");

    glfw.MakeContextCurrent(window);
    glfw.SwapInterval(0);

    // Load OpenGL function pointers using glfw.GetProcAddress
    gl.init( proc(p: rawptr, name: string) { (^(proc() #cc_c))(p)^ = glfw.GetProcAddress(&name[0]); } );
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

    for eye in 0..1 {
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
        for i in 0..<length {
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

    for eye in 0..1 {
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


    // Setup "controller" vao, vbo and vertex attribs, and upload
    vao_controller: u32;
    gl.GenVertexArrays(1, &vao_controller);

    num_vertices_controller: i32 = 12;
    pos_data_controller := [..]f32{
       -1.0*0.1, -1.0*0.1, 0.0,
       -0.1*0.1, -1.0*0.1, 0.0,
       -1.0*0.1,  1.0*0.1, 0.0,

       -1.0*0.1,  1.0*0.1, 0.0,
       -0.1*0.1, -1.0*0.1, 0.0,
       -0.1*0.1,  1.0*0.1, 0.0,

        0.1*0.1, -1.0*0.1, 0.0,
        1.0*0.1, -1.0*0.1, 0.0,
        0.1*0.1,  1.0*0.1, 0.0,

        0.1*0.1,  1.0*0.1, 0.0,
        1.0*0.1, -1.0*0.1, 0.0,
        1.0*0.1,  1.0*0.1, 0.0,
    };

    uv_data_controller := [..]f32{
        0.0, 0.0, 
        0.5, 0.0, 
        0.0, 1.0, 
        
        0.0, 1.0,
        0.5, 0.0,
        0.5, 1.0,
        
        0.5, 0.0,
        1.0, 0.0,
        0.5, 1.0,
        
        0.5, 1.0,
        1.0, 0.0,
        1.0, 1.0,
    };

    gl.BindVertexArray(vao_controller);

    vbo_controller_pos: u32;
    gl.GenBuffers(1, &vbo_controller_pos);
    gl.BindBuffer(gl.ARRAY_BUFFER, vbo_controller_pos);
    gl.BufferData(gl.ARRAY_BUFFER, size_of_val(pos_data_controller), &pos_data_controller[0], gl.STATIC_DRAW);
    
    gl.EnableVertexAttribArray(0);
    gl.VertexAttribPointer(0, 3, gl.FLOAT, gl.FALSE, 0, nil);


    vbo_controller_uv: u32;
    gl.GenBuffers(1, &vbo_controller_uv);
    gl.BindBuffer(gl.ARRAY_BUFFER, vbo_controller_uv);
    gl.BufferData(gl.ARRAY_BUFFER, size_of_val(uv_data_controller), &uv_data_controller[0], gl.STATIC_DRAW);

    gl.EnableVertexAttribArray(1);
    gl.VertexAttribPointer(1, 2, gl.FLOAT, gl.FALSE, 0, nil);

    defer {
        gl.DeleteBuffers(1, &vbo_controller_uv);
        gl.DeleteBuffers(1, &vbo_controller_pos);
        gl.DeleteVertexArrays(1, &vao_controller);
    }


    // Setup "controller" texture and upload
    texture_width: i32 = 4;
    texture_height: i32 = 4;
    texture_data := [..]u8 {
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
    gl.Uniform1i(gl.get_uniform_location(program, "texture_sampler\x00"), 0);

    defer {
        gl.DeleteTextures(1, &texture_controller);
    }





    // Setup room vao, vbo and vertex attribs, and upload
    vao_room: u32;
    gl.GenVertexArrays(1, &vao_room);
    gl.BindVertexArray(vao_room);

    half_side: f32 = 10.0;
    floor_height: f32 = -2.0; // @TODO: use actual floor/sitting height instead of 2 meters..
    roof_height: f32 = 3.0;
    
    num_vertices_room: i32 = 12;
    pos_data_room := [..]f32 {
        -half_side, floor_height, -half_side,
         half_side, floor_height, -half_side,
        -half_side, floor_height,  half_side,
        -half_side, floor_height,  half_side,
         half_side, floor_height, -half_side,
         half_side, floor_height,  half_side,

        -half_side, roof_height, -half_side, 
         half_side, roof_height, -half_side, 
        -half_side, roof_height,  half_side, 
        -half_side, roof_height,  half_side, 
         half_side, roof_height, -half_side, 
         half_side, roof_height,  half_side, 
    };

    vbo_room: u32;
    gl.GenBuffers(1, &vbo_room);
    gl.BindBuffer(gl.ARRAY_BUFFER, vbo_room);
    gl.BufferData(gl.ARRAY_BUFFER, size_of_val(pos_data_room), &pos_data_room[0], gl.STATIC_DRAW);

    gl.EnableVertexAttribArray(0);
    gl.VertexAttribPointer(0, 3, gl.FLOAT, gl.FALSE, 0, nil);
    
    gl.EnableVertexAttribArray(1);
    gl.VertexAttribPointer(1, 2, gl.FLOAT, gl.FALSE, 0, nil);

    defer {
        gl.DeleteBuffers(1, &vbo_room);
        gl.DeleteVertexArrays(1, &vao_room);
    }

    //-------------------------------------------------------------------------------------------//    

    // Enable SRGB and depth test and set background color
    gl.Enable(gl.DEPTH_TEST);
    gl.Enable(gl.FRAMEBUFFER_SRGB);
    gl.ClearColor(0.2, 0.3, 0.4, 1.0); 

    frame_index: i64 = 0;
    for glfw.WindowShouldClose(window) == 0 {
        glfw.PollEvents();

        // Get the predicted head pose for the current frame
        ovr_GetEyePoses(session, frame_index, ovrTrue, &hmd_to_eye_offset[0], &layer.RenderPose[0], &layer.SensorSampleTime);

        // Get controller trackign state
        // See: https://developer.oculus.com/documentation/pcsdk/latest/concepts/dg-sensor/#dg-sensor-head-tracking
        ts := ovr_GetTrackingState(session, 0, 1);

        // Main rendering section. All draw calls currently use the same shaders. 
        gl.UseProgram(program);

        // Bind "controller" texture
        gl.ActiveTexture(gl.TEXTURE0);
        gl.BindTexture(gl.TEXTURE_2D, texture_controller);
        
        // Upload uniforms that are the same per-eye
        gl.Uniform1f(gl.get_uniform_location(program, "time\x00"), f32(glfw.GetTime()));
        
        // We need to render the scene twice, once for each eye.
        for eye in 0..1 {
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
            P := ovrMatrix4f_Projection(hmd_desc.MaxEyeFov[eye], f32(0.2), f32(1000.0), u32(ovrProjectionModifier.ovrProjection_None));
            gl.UniformMatrix4fv(gl.get_uniform_location(program, "P\x00"), 1, gl.TRUE, &P.M[0][0]);


            // Upload headset position and orientation as uniforms. 
            // The camera is rotated and translated according to these in the shader
            p_hmd := layer.RenderPose[eye].Position;
            q_hmd := layer.RenderPose[eye].Orientation;
            gl.Uniform3fv(gl.get_uniform_location(program, "p_hmd\x00"), 1, &p_hmd.x);
            gl.Uniform4fv(gl.get_uniform_location(program, "q_hmd\x00"), 1, &q_hmd.x);


            // @NOTE: The same shader is used to draw both the room (which is shaded based on position)
            // and the controllers (which are shaded based on uv's and a texture), 
            // by setting the "apply_texture" uniform to 0 (no texture) or 1 (using texture)

            // Draw the "room" first, which doesn't use any textures, but are shaded
            // based on the pixel's position/coverage relative to global gridlines
            gl.BindVertexArray(vao_room);
            gl.Uniform1i(gl.get_uniform_location(program, "apply_texture\x00"), 0);
            
            // The room is static
            gl.Uniform3f(gl.get_uniform_location(program, "p_model\x00"), 0.0, 0.0, 0.0);
            gl.Uniform4f(gl.get_uniform_location(program, "q_model\x00"), 0.0, 0.0, 0.0, 1.0);
            gl.DrawArrays(gl.TRIANGLES, 0, u32(num_vertices_room));

            
            // Next, draw the two controllers as oriented, textured quads
            gl.BindVertexArray(vao_controller);
            gl.Uniform1i(gl.get_uniform_location(program, "apply_texture\x00"), 1);
            
            // Left controller
            p_left := ts.HandPoses[0].ThePose.Position;
            q_left := ts.HandPoses[0].ThePose.Orientation;
            
            gl.Uniform3fv(gl.get_uniform_location(program, "p_model\x00"), 1, &p_left.x);
            gl.Uniform4fv(gl.get_uniform_location(program, "q_model\x00"), 1, &q_left.x);
            gl.DrawArrays(gl.TRIANGLES, 0, u32(num_vertices_controller));

            // Right controller
            p_right := ts.HandPoses[1].ThePose.Position;
            q_right := ts.HandPoses[1].ThePose.Orientation;

            gl.Uniform3fv(gl.get_uniform_location(program, "p_model\x00"), 1, &p_right.x);
            gl.Uniform4fv(gl.get_uniform_location(program, "q_model\x00"), 1, &q_right.x);
            gl.DrawArrays(gl.TRIANGLES, 0, u32(num_vertices_controller));


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

        frame_index++;
    }
}


// Error reporting helpers:
print_last_rift_error :: proc() {
    using rift;

    errorInfo: ovrErrorInfo;
    ovr_GetLastErrorInfo(&errorInfo);
    fmt.fprintf(os.stderr, "Error %d, %s\n", errorInfo.Result, errorInfo.ErrorString);
}

error_callback :: proc(error: i32, desc: ^byte) #cc_c {
    fmt.printf("Error code %d:\n    %s\n", error, strings.to_odin_string(desc));
}