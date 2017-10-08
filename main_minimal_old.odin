import "core:fmt.odin";
import "core:os.odin";
import "core:strings.odin";
import "rift.odin";
import "shared:odin-glfw/glfw.odin";
import "shared:odin-gl/gl.odin";

print_last_rift_error :: proc() {
    using rift;

    errorInfo: ovrErrorInfo;
    ovr_GetLastErrorInfo(&errorInfo);
    fmt.fprintf(os.stderr, "Error %d, %s\n", errorInfo.Result, errorInfo.ErrorString);
}

main :: proc() {
    using rift;

    //
    if !OVR_SUCCESS(ovr_Initialize(nil)) {
        print_last_rift_error();
        return;
    }
    defer ovr_Shutdown();
    fmt.fprintln(os.stderr, "Succeeded initializing OVR");

    //
    session : ovrSession;
    luid : ovrGraphicsLuid;
    if !OVR_SUCCESS(ovr_Create(&session, &luid)) {
        print_last_rift_error();
        return;
    }
    defer ovr_Destroy(session);
    fmt.fprintln(os.stderr, "Succeeded creating VR session");

    //
    error_callback :: proc(error: i32, desc: ^u8) #cc_c {
        fmt.printf("Error code %d:\n    %s\n", error, strings.to_odin_string(desc));
    }
    glfw.SetErrorCallback(error_callback);

    if glfw.Init() == 0 {
        return;
    }
    defer glfw.Terminate();
    fmt.fprintln(os.stderr, "Succeeded initializing GLFW");

    //
    title := "Rift minimal example\x00";
    resx, resy : i32 = 1280, 720;
    glfw.WindowHint(glfw.CONTEXT_VERSION_MAJOR, 4);
    glfw.WindowHint(glfw.CONTEXT_VERSION_MINOR, 5);
    glfw.WindowHint(glfw.OPENGL_PROFILE, glfw.OPENGL_CORE_PROFILE);
    window := glfw.CreateWindow(resx, resy, &title[0], nil, nil);
    if window == nil {
        return;
    }
    fmt.fprintln(os.stderr, "Succeeded creating GLFW window");

    //
    glfw.MakeContextCurrent(window);
    glfw.SwapInterval(0);

    //
    set_proc_address :: proc(p: rawptr, name: string) { 
        (cast(^rawptr)p)^ = rawptr(glfw.GetProcAddress(&name[0]));
    }
    gl.load_up_to(4, 5, set_proc_address);
    fmt.fprintln(os.stderr, "Loaded OpenGL function pointers");

    //
    hmd_desc := ovr_GetHmdDesc(session);

    //
    eye_texture_sizes: [2]ovrSizei;
    texture_swap_chains: [2]ovrTextureSwapChain;

    for eye in 0...1 {
        eye_texture_sizes[eye] = ovr_GetFovTextureSize(session, ovrEyeType(eye), hmd_desc.DefaultEyeFov[eye], 1.0);

        desc := ovrTextureSwapChainDesc{
            Type = ovrTextureType.ovrTexture_2D, 
            Format = ovrTextureFormat.OVR_FORMAT_R8G8B8A8_UNORM_SRGB, 
            ArraySize = 1, 
            Width = eye_texture_sizes[eye].w, 
            Height = eye_texture_sizes[eye].h, 
            MipLevels = 1, 
            SampleCount = 1, 
            StaticImage = ovrFalse, 
            MiscFlags = u32(ovrTextureMiscFlags.ovrTextureMisc_None), 
            BindFlags = u32(ovrTextureBindFlags.ovrTextureBind_None)
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
    
    //
    mirror_texture_ovr: ovrMirrorTexture;
    mirror_desc := ovrMirrorTextureDesc{ovrTextureFormat.OVR_FORMAT_R8G8B8A8_UNORM_SRGB, resx, resy, u32(ovrTextureMiscFlags.ovrTextureMisc_None), 0};

    if (!OVR_SUCCESS(ovr_CreateMirrorTextureGL(session, &mirror_desc, &mirror_texture_ovr))) { 
        print_last_rift_error();
        return;
    }
    defer ovr_DestroyMirrorTexture(session, mirror_texture_ovr);

    //
    mirror_texture_gl: u32;
    if (!OVR_SUCCESS(ovr_GetMirrorTextureBufferGL(session, mirror_texture_ovr, &mirror_texture_gl))) {
        print_last_rift_error();
        return;
    }
    fmt.fprintln(os.stderr, "Created and configured mirror texture");

    //
    mirror_fbo: u32;
    gl.GenFramebuffers(1, &mirror_fbo);
    gl.BindFramebuffer(gl.READ_FRAMEBUFFER, mirror_fbo);
    gl.FramebufferTexture2D(gl.READ_FRAMEBUFFER, gl.COLOR_ATTACHMENT0, gl.TEXTURE_2D, mirror_texture_gl, 0);
    gl.FramebufferRenderbuffer(gl.READ_FRAMEBUFFER, gl.DEPTH_ATTACHMENT, gl.RENDERBUFFER, 0);
    gl.BindFramebuffer(gl.READ_FRAMEBUFFER, 0);
    fmt.fprintln(os.stderr, "Created mirror texture framebuffer");

    // 
    per_eye_fbo: [2]u32;
    gl.GenFramebuffers(2, &per_eye_fbo[0]);
    fmt.fprintln(os.stderr, "Created per-eye framebuffers");

    //
    layer := ovrLayerEyeFov {
        ovrLayerHeader {
            ovrLayerType.ovrLayerType_EyeFov, 
            u32(ovrLayerFlags.ovrLayerFlag_TextureOriginAtBottomLeft)
        }, 
        [2]ovrTextureSwapChain {
            texture_swap_chains[0], 
            texture_swap_chains[1]
        },
        [2]ovrRecti{
            ovrRecti{
                ovrVector2i{0, 0}, 
                ovrSizei{eye_texture_sizes[0].w, eye_texture_sizes[0].h}
            }, 
            ovrRecti{
                ovrVector2i{0, 0}, 
                ovrSizei{eye_texture_sizes[1].w, eye_texture_sizes[1].h}
            }, 
        },
        [2]ovrFovPort{
            hmd_desc.DefaultEyeFov[0], 
            hmd_desc.DefaultEyeFov[1]
        },

        // RenderPose and SensorSampleTime set in render loop
        [2]ovrPosef{
            ovrPosef{
                ovrQuatf{0.0, 0.0, 0.0, 1.0},
                ovrVector3f{0.0, 0.0, 0.0},
            },
            ovrPosef{
                ovrQuatf{0.0, 0.0, 0.0, 1.0},
                ovrVector3f{0.0, 0.0, 0.0},
            },
        },
        f64(0.0),
    };
    

    eye_render_desc := [2]ovrEyeRenderDesc{
        ovr_GetRenderDesc(session, ovrEyeType.ovrEye_Left, hmd_desc.DefaultEyeFov[0]), 
        ovr_GetRenderDesc(session, ovrEyeType.ovrEye_Right, hmd_desc.DefaultEyeFov[1])
    };
    hmd_to_eye_pose := [2]ovrPosef{ eye_render_desc[0].HmdToEyePose, eye_render_desc[1].HmdToEyePose };
    fmt.fprintln(os.stderr, "Set up default layer, and got render descriptions and relative pose of each eye.");

    // 
    gl.Enable(gl.FRAMEBUFFER_SRGB);

    frame_index: i64 = 0;
    for glfw.WindowShouldClose(window) == 0 {
        glfw.PollEvents();

        // 
        ovr_GetEyePoses(session, frame_index, ovrTrue, &hmd_to_eye_pose[0], &layer.RenderPose[0], &layer.SensorSampleTime);

        for eye in 0...1 {
            // 
            current_index: i32;
            ovr_GetTextureSwapChainCurrentIndex(session, texture_swap_chains[eye], &current_index);

            current_texture_id: u32;
            ovr_GetTextureSwapChainBufferGL(session, texture_swap_chains[eye], current_index, &current_texture_id);

            gl.BindFramebuffer(gl.FRAMEBUFFER, per_eye_fbo[eye]);
            gl.FramebufferTexture2D(gl.FRAMEBUFFER, gl.COLOR_ATTACHMENT0, gl.TEXTURE_2D, current_texture_id, 0);
            
            //
            gl.Viewport(0, 0, eye_texture_sizes[eye].w, eye_texture_sizes[eye].h);
            gl.ClearColor(f32(eye), 0.0, 1.0 - f32(eye), 1.0); // left = blue, right = red
            gl.Clear(gl.COLOR_BUFFER_BIT);

            // 
            ovr_CommitTextureSwapChain(session, texture_swap_chains[eye]);
        }

        // 
        layer_header: ^ovrLayerHeader = &layer.Header;
        if (!OVR_SUCCESS(ovr_SubmitFrame(session, frame_index, nil, &layer_header, 1))) {
            print_last_rift_error();
            return;
        }

        // 
        gl.BindFramebuffer(gl.READ_FRAMEBUFFER, mirror_fbo);
        gl.BindFramebuffer(gl.DRAW_FRAMEBUFFER, 0);
        gl.BlitFramebuffer(0, resy, resx, 0,   0, 0, resx, resy,   gl.COLOR_BUFFER_BIT, gl.NEAREST);
        gl.BindFramebuffer(gl.FRAMEBUFFER, 0);

        //
        glfw.SwapBuffers(window);

        frame_index += 1;
    }
}