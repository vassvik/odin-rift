#include <stdio.h>

#include <glad/glad.h>
#include <glad/glad.c>
#include <GLFW/glfw3.h>

#include <OVR_CAPI_GL.h>


void print_last_rift_error()
{
    ovrErrorInfo errorInfo;
    ovr_GetLastErrorInfo(&errorInfo);
    fprintf(stderr, "Error %d, %s\n", errorInfo.Result, errorInfo.ErrorString);
}

void error_callback(int error, const char *desc)
{
    fprintf(stderr, "Error %d, %s\n", error, desc);
}

int main() 
{
    //
    // Initialize OVR, GLFW and OpengL
    //
    if (!OVR_SUCCESS(ovr_Initialize(NULL))) {
        print_last_rift_error();
        goto Cleanup4;
    }
    fprintf(stderr, "Succeeded initializing OVR\n");

    ovrSession session;
    ovrGraphicsLuid luid;
    if (!OVR_SUCCESS(ovr_Create(&session, &luid))) {
        print_last_rift_error();
        goto Cleanup3;
    }
    fprintf(stderr, "Succeeded creating VR session\n");


    glfwSetErrorCallback(error_callback);

    if (!glfwInit()) {
        goto Cleanup2;
    }
    fprintf(stderr, "Succeeded initializing GLFW\n"); 

    double resx = 1600, resy = 900;
    GLFWwindow *window = glfwCreateWindow(resx, resy, "Rift simple example", NULL, NULL);
    if (!window) {
        goto Cleanup1;
    }
    fprintf(stderr, "Succeeded creating GLFW window\n"); 

    glfwMakeContextCurrent(window); 
    glfwSwapInterval(0);


    if(!gladLoadGL()) {
        fprintf(stderr, "Error, could not load OpenGL function pointers\n");
        goto Cleanup1;
    }
    fprintf(stderr, "Succeeded loading OpenGL function pointers\n"); 


    //
    // Get general headset description.
    // Used in particular for getting headset FOV parameters
    // 
    ovrHmdDesc hmd_desc = ovr_GetHmdDesc(session);

    //
    // Setup texture swap chains. One texture chain per eye, and each chain has 3 textures.
    // Each eye can in general have different FOV values, and different texture sizes.
    // These textures are handled internally by the Oculus SDK.
    //
    ovrSizei eye_texture_sizes[2];
    ovrTextureSwapChain texture_swap_chains[2];

    for (int eye = 0; eye < 2; eye++) {
        eye_texture_sizes[eye] = ovr_GetFovTextureSize(session, eye, hmd_desc.DefaultEyeFov[eye], 1.0f);

        ovrTextureSwapChainDesc desc = {ovrTexture_2D, OVR_FORMAT_R8G8B8A8_UNORM_SRGB, 1, eye_texture_sizes[eye].w, eye_texture_sizes[eye].h, 1, 1, ovrFalse, ovrTextureMisc_None, ovrTextureBind_None};
        if (!OVR_SUCCESS(ovr_CreateTextureSwapChainGL(session, &desc, &texture_swap_chains[eye]))) {
            print_last_rift_error();
            goto Cleanup1;
        }

        int length = 0;
        ovr_GetTextureSwapChainLength(session, texture_swap_chains[eye], &length);
        for (int i = 0; i < length; i++) {
            GLuint chain_tex_id;
            if (!OVR_SUCCESS(ovr_GetTextureSwapChainBufferGL(session, texture_swap_chains[eye], i, &chain_tex_id))) {
                print_last_rift_error();
                goto Cleanup1;
            }
            glBindTexture(GL_TEXTURE_2D, chain_tex_id);

            glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MIN_FILTER, GL_LINEAR);
            glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MAG_FILTER, GL_LINEAR);
            glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_WRAP_S, GL_CLAMP_TO_EDGE);
            glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_WRAP_T, GL_CLAMP_TO_EDGE);
        }
    }
    fprintf(stderr, "Created texture swap chains for both eyes\n");

    //
    // Set up a "mirror texture" that is used to mirror what's rendered in the headset to the default framebuffer
    // This is a done using a simple blit at the end of the rendering loop. 
    // This is a configured as a simple frame buffer with no depth info.
    // This texture is handled internally by the Oculus SDK.
    //
    // @Note: An alternative to this is to do a separate monoscopic rendering pass that is displayed in the main window
    //
    ovrMirrorTexture mirror_texture_ovr = NULL;
    ovrMirrorTextureDesc mirror_desc = {OVR_FORMAT_R8G8B8A8_UNORM_SRGB, resx, resy, ovrTextureMisc_None};

    if (!OVR_SUCCESS(ovr_CreateMirrorTextureGL(session, &mirror_desc, &mirror_texture_ovr))) { 
        print_last_rift_error();
        goto Cleanup1;
    }
    fprintf(stderr, "Created and configured mirror texture\n");


    GLuint mirror_texture_gl;
    if (!OVR_SUCCESS(ovr_GetMirrorTextureBufferGL(session, mirror_texture_ovr, &mirror_texture_gl))) {
        print_last_rift_error();
        goto Cleanup1;
    }

    GLuint mirror_fbo = 0;
    glGenFramebuffers(1, &mirror_fbo);
    glBindFramebuffer(GL_READ_FRAMEBUFFER, mirror_fbo);
    glFramebufferTexture2D(GL_READ_FRAMEBUFFER, GL_COLOR_ATTACHMENT0, GL_TEXTURE_2D, mirror_texture_gl, 0);
    glFramebufferRenderbuffer(GL_READ_FRAMEBUFFER, GL_DEPTH_ATTACHMENT, GL_RENDERBUFFER, 0);
    glBindFramebuffer(GL_READ_FRAMEBUFFER, 0);
    fprintf(stderr, "Configured mirror texture framebuffer\n");

    //
    // Each eye has its own framebuffer associated with it, which we bind a color texture to depending
    // on which buffer in the chain is used. 
    //
    // Depth buffers can be handled manually or as a separate texture chain.
    //
    GLuint per_eye_fbo[2];
    glGenFramebuffers(2, per_eye_fbo);
    // @TODO: Add depth render buffer or depth textures
    fprintf(stderr, "Configured per-eye framebuffers\n");


    //
    // Oculus' SDK support "layers", which are like individual windows in an operating system.
    // Usually there is one "3D" layer that is the usual render, then there can be additional 
    // layers on top of that to represent UI elements, floating text, etc.
    // Most of the information in the layer stay constant, so we keep it outside the render 
    // loop for now.
    //
    ovrLayerEyeFov layer = {
        {   // Header
            ovrLayerType_EyeFov, 
            ovrLayerFlag_TextureOriginAtBottomLeft
        }, 
        {   // ColorTexture[ovrEye_Count]
            texture_swap_chains[0], 
            texture_swap_chains[1]
        },
        {   // Viewport[ovrEye_Count]
            {0, 0, eye_texture_sizes[0].w, eye_texture_sizes[0].h}, 
            {0, 0, eye_texture_sizes[1].w, eye_texture_sizes[1].h}
        },
        {   // Fov[ovrEye_Count]
            hmd_desc.DefaultEyeFov[0], 
            hmd_desc.DefaultEyeFov[1]
        }
        // RenderPose and SensorSampleTime set in render loop
    };
        
    //
    // Used to get the current Eye poses in the render loop, as long as the Fov stays unchanged.
    // The eye offsets are used to construct view matrices for each eye.
    //
    ovrEyeRenderDesc eye_render_desc[2] = {
        ovr_GetRenderDesc(session, ovrEye_Left, hmd_desc.DefaultEyeFov[0]), 
        ovr_GetRenderDesc(session, ovrEye_Right, hmd_desc.DefaultEyeFov[1])
    };
    ovrVector3f hmd_to_eye_offset[2] = { eye_render_desc[0].HmdToEyeOffset, eye_render_desc[1].HmdToEyeOffset };
    fprintf(stderr, "Set up default layer, render descriptions and offsets to each eye. ");

    // We're gonna do SRGB, so just keep that enabled from the start
    glEnable(GL_FRAMEBUFFER_SRGB);


    long long frame_index = 0;
    while (!glfwWindowShouldClose(window)) {
        glfwPollEvents();

        // Get the predicted head pose for the current frame
        ovr_GetEyePoses(session, frame_index, ovrTrue, hmd_to_eye_offset, layer.RenderPose, &layer.SensorSampleTime);

        for (int eye = 0; eye < 2; eye++) {
            // Set up the framebuffer per eye
            int current_index;
            ovr_GetTextureSwapChainCurrentIndex(session, texture_swap_chains[eye], &current_index);

            GLuint current_texture_id;
            ovr_GetTextureSwapChainBufferGL(session, texture_swap_chains[eye], current_index, &current_texture_id);

            glBindFramebuffer(GL_FRAMEBUFFER, per_eye_fbo[eye]);
            glFramebufferTexture2D(GL_FRAMEBUFFER, GL_COLOR_ATTACHMENT0, GL_TEXTURE_2D, current_texture_id, 0);

            // Render
            glViewport(0, 0, eye_texture_sizes[eye].w, eye_texture_sizes[eye].h);
            glClearColor(eye, 0.0, 1.0 - eye, 1.0); // left = blue, right = red
            glClear(GL_COLOR_BUFFER_BIT);

            // Commit the render
            ovr_CommitTextureSwapChain(session, texture_swap_chains[eye]);
        }

        // Submit the layer(s), currently a single layer
        ovrLayerHeader* layer_header = &layer.Header;
        if (!OVR_SUCCESS(ovr_SubmitFrame(session, frame_index, NULL, &layer_header, 1))) {
            print_last_rift_error();
            goto Cleanup1;
        }

        // Blit mirror texture to back buffer
        // @NOTE: Alternatively do an additional monoscopic rendering to the main window
        glBindFramebuffer(GL_READ_FRAMEBUFFER, mirror_fbo);
        glBindFramebuffer(GL_DRAW_FRAMEBUFFER, 0);
        glBlitFramebuffer(0, resy, resx, 0,   0, 0, resx, resy,   GL_COLOR_BUFFER_BIT, GL_NEAREST);
        glBindFramebuffer(GL_FRAMEBUFFER, 0);

        // Done
        glfwSwapBuffers(window);

        frame_index++;
    }

Cleanup1:
    glfwTerminate();
Cleanup2:
    ovr_Destroy(session);
Cleanup3:
    ovr_Shutdown();
Cleanup4:

    return 0;
}