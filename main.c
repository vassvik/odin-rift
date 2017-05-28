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
//   Note: Uses GLFW for window and OpenGL context creation, and GLAD to load
//         the OpenGL function pointers. 
//  
//  
//   Source statistics: (approximitely 600 or so lines total)
//         Documentation and declarations:         43 LOC
//         Initialization:                         44 LOC
//         Texture chains and mirror texture:      71 LOC
//         Framebuffer and depth textures:         25 LOC
//         Layer and render description:           38 LOC
//         Preparing OpenGL data and shaders:     144 LOC
//         Main render loop:                      118 LOC
//         Cleanup:                                34 LOC
//         Helper functions:                      102 LOC
//  
///////////////////////////////////////////////////////////////////////////////////////////////////

#include <stdio.h>

#include <glad/glad.h>
#include <glad/glad.c>
#include <GLFW/glfw3.h>

#include <OVR_CAPI_GL.h>

char *read_entire_file(const char *filename);
int compile_shader(const char *file_path, GLuint shader_ID);
GLuint load_shaders(const char *vertex_file_path, const char *fragment_file_path);

void print_last_rift_error();
void error_callback(int error, const char *desc);

int main() 
{
    //-------------------------------------------------------------------------------------------//
    // See https://developer.oculus.com/documentation/pcsdk/latest/concepts/dg-sensor/#dg_sensor
    

    // Initialize OVR, GLFW and OpengL
    if (!OVR_SUCCESS(ovr_Initialize(NULL))) {
        print_last_rift_error();
        goto Cleanup6;
    }
    fprintf(stderr, "Succeeded initializing OVR\n");

    ovrSession session;
    ovrGraphicsLuid luid;
    if (!OVR_SUCCESS(ovr_Create(&session, &luid))) {
        print_last_rift_error();
        goto Cleanup5;
    }
    fprintf(stderr, "Succeeded creating VR session\n");

    //-------------------------------------------------------------------------------------------//

    glfwSetErrorCallback(error_callback);

    if (!glfwInit()) {
        goto Cleanup4;
    }
    fprintf(stderr, "Succeeded initializing GLFW\n"); 

    double resx = 1600, resy = 900;
    GLFWwindow *window = glfwCreateWindow(resx, resy, "Rift simple example", NULL, NULL);
    if (!window) {
        goto Cleanup3;
    }
    fprintf(stderr, "Succeeded creating GLFW window\n"); 

    glfwMakeContextCurrent(window); 
    glfwSwapInterval(0);


    if(!gladLoadGL()) {
        fprintf(stderr, "Error, could not load OpenGL function pointers\n");
        goto Cleanup3;
    }
    fprintf(stderr, "Succeeded loading OpenGL function pointers\n"); 

    //-------------------------------------------------------------------------------------------//
    // https://developer.oculus.com/documentation/pcsdk/latest/concepts/dg-render/#dg-render-initialize

    // Get general headset description.
    // Used in particular for getting headset FOV parameters
    ovrHmdDesc hmd_desc = ovr_GetHmdDesc(session);

    // Setup texture swap chains. One texture chain per eye, and each chain has 3 textures.
    // Each eye can in general have different FOV values, and different texture sizes.
    // These textures are handled internally by the Oculus SDK.
    ovrSizei eye_texture_sizes[2];
    ovrTextureSwapChain texture_swap_chains[2];

    for (int eye = 0; eye < 2; eye++) {
        eye_texture_sizes[eye] = ovr_GetFovTextureSize(session, eye, hmd_desc.MaxEyeFov[eye], 1.0f);

        ovrTextureSwapChainDesc desc = {ovrTexture_2D, OVR_FORMAT_R8G8B8A8_UNORM_SRGB, 1, eye_texture_sizes[eye].w, eye_texture_sizes[eye].h, 1, 1, ovrFalse, ovrTextureMisc_None, ovrTextureBind_None};
        if (!OVR_SUCCESS(ovr_CreateTextureSwapChainGL(session, &desc, &texture_swap_chains[eye]))) {
            print_last_rift_error();
            goto Cleanup3; // @NOTE: What if only one fails
        }

        int length = 0;
        ovr_GetTextureSwapChainLength(session, texture_swap_chains[eye], &length);
        for (int i = 0; i < length; i++) {
            GLuint chain_tex_id;
            if (!OVR_SUCCESS(ovr_GetTextureSwapChainBufferGL(session, texture_swap_chains[eye], i, &chain_tex_id))) {
                print_last_rift_error();
                goto Cleanup2; // @NOTE: What if only one fails, but it has created the texture swap chain?
            }
            glBindTexture(GL_TEXTURE_2D, chain_tex_id);

            glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MIN_FILTER, GL_LINEAR);
            glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MAG_FILTER, GL_LINEAR);
            glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_WRAP_S, GL_CLAMP_TO_EDGE);
            glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_WRAP_T, GL_CLAMP_TO_EDGE);
        }
    }
    fprintf(stderr, "Created texture swap chains for both eyes\n");

    //-------------------------------------------------------------------------------------------//

    // Set up a "mirror texture" that is used to mirror what's rendered in the headset to the default framebuffer
    // This is a done using a simple blit at the end of the rendering loop. 
    // This is a configured as a simple frame buffer with no depth info.
    // This texture is handled internally by the Oculus SDK.
    //
    // @Note: An alternative to this is to do a separate monoscopic rendering pass that is displayed in the main window
    ovrMirrorTexture mirror_texture_ovr = NULL;
    ovrMirrorTextureDesc mirror_desc = {OVR_FORMAT_R8G8B8A8_UNORM_SRGB, resx, resy, ovrTextureMisc_None};

    if (!OVR_SUCCESS(ovr_CreateMirrorTextureGL(session, &mirror_desc, &mirror_texture_ovr))) { 
        print_last_rift_error();
        goto Cleanup2; // @NOTE: What if creating the texture swap chain succesds, but not this one?
    }
    fprintf(stderr, "Created and configured mirror texture\n");


    GLuint mirror_texture_gl;
    if (!OVR_SUCCESS(ovr_GetMirrorTextureBufferGL(session, mirror_texture_ovr, &mirror_texture_gl))) {
        print_last_rift_error();
        goto Cleanup1; // @NOTE: What if creating the texture swap chain succesds, but not this one?
    }

    GLuint mirror_fbo = 0;
    glGenFramebuffers(1, &mirror_fbo);
    glBindFramebuffer(GL_READ_FRAMEBUFFER, mirror_fbo);
    glFramebufferTexture2D(GL_READ_FRAMEBUFFER, GL_COLOR_ATTACHMENT0, GL_TEXTURE_2D, mirror_texture_gl, 0);
    glFramebufferRenderbuffer(GL_READ_FRAMEBUFFER, GL_DEPTH_ATTACHMENT, GL_RENDERBUFFER, 0);
    glBindFramebuffer(GL_READ_FRAMEBUFFER, 0);
    fprintf(stderr, "Configured mirror texture framebuffer\n");

    //-------------------------------------------------------------------------------------------//    

    // We use a single framebuffer to render to for both eyes, 
    // but we bind different eye texture to it depending on which
    // buffer in the chain is used and which eye we are current rendering
    GLuint eye_fbo;
    glGenFramebuffers(1, &eye_fbo);
    fprintf(stderr, "Configured eye framebuffers\n");


    // Depth buffers can be handled manually or as a separate texture chain (?)
    GLuint depth_textures[2];
    glGenTextures(2, &depth_textures[0]);

    for (int eye = 0; eye < 2; eye++) {
        glBindTexture(GL_TEXTURE_2D, depth_textures[eye]);

        glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MIN_FILTER, GL_LINEAR);
        glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MAG_FILTER, GL_LINEAR);
        glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_WRAP_S, GL_CLAMP_TO_EDGE);
        glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_WRAP_T, GL_CLAMP_TO_EDGE);

        glTexImage2D(GL_TEXTURE_2D, 0, GL_DEPTH_COMPONENT24, eye_texture_sizes[eye].w, eye_texture_sizes[eye].h, 0, GL_DEPTH_COMPONENT, GL_UNSIGNED_INT, NULL);
    }
    fprintf(stderr, "Created per-eye depth buffers\n");

    //-------------------------------------------------------------------------------------------//
    // See: https://developer.oculus.com/documentation/pcsdk/latest/concepts/dg-render/#dg-render-layers

    // Oculus' SDK support "layers", which are like individual windows in an operating system.
    // Usually there is one "3D" layer that is the usual render, then there can be additional 
    // layers on top of that to represent UI elements, floating text, etc.
    // Most of the information in the layer stay constant, so we keep it outside the render 
    // loop for now.
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
            hmd_desc.MaxEyeFov[0], 
            hmd_desc.MaxEyeFov[1]
        }
        // RenderPose and SensorSampleTime set in render loop
    };
        

    // Used to get the current Eye poses in the render loop, as long as the Fov stays unchanged.
    // The eye offsets are used to construct view matrices for each eye.
    // See: https://developer.oculus.com/documentation/pcsdk/latest/concepts/dg-render/#dg-render-frame
    ovrEyeRenderDesc eye_render_desc[2] = {
        ovr_GetRenderDesc(session, ovrEye_Left, hmd_desc.MaxEyeFov[0]), 
        ovr_GetRenderDesc(session, ovrEye_Right, hmd_desc.MaxEyeFov[1])
    };
    ovrVector3f hmd_to_eye_offset[2] = { eye_render_desc[0].HmdToEyeOffset, eye_render_desc[1].HmdToEyeOffset };
    fprintf(stderr, "Set up default layer, render descriptions and offsets to each eye.\n");

    //-------------------------------------------------------------------------------------------//    

    // Load shaders from files
    GLuint program = load_shaders("shaders/vertex_shader.vs", "shaders/fragment_shader.fs");
    if (program == 0) {
        fprintf(stderr, "Could not load shaders. Exiting\n");
        goto Cleanup1;
    }

    // Setup "controller" vao, vbo and vertex attribs, and upload
    GLuint vao_controller;
    glGenVertexArrays(1, &vao_controller);
    glBindVertexArray(vao_controller);

    int num_vertices_controller = 12;
    GLfloat pos_data_controller[] = {
       -1.0f*0.1, -1.0f*0.1, 0.0f,
       -0.1f*0.1, -1.0f*0.1, 0.0f,
       -1.0f*0.1,  1.0f*0.1, 0.0f,

       -1.0f*0.1,  1.0f*0.1, 0.0f,
       -0.1f*0.1, -1.0f*0.1, 0.0f,
       -0.1f*0.1,  1.0f*0.1, 0.0f,

        0.1f*0.1, -1.0f*0.1, 0.0f,
        1.0f*0.1, -1.0f*0.1, 0.0f,
        0.1f*0.1,  1.0f*0.1, 0.0f,

        0.1f*0.1,  1.0f*0.1, 0.0f,
        1.0f*0.1, -1.0f*0.1, 0.0f,
        1.0f*0.1,  1.0f*0.1, 0.0f,
    };

    GLfloat uv_data_controller[] = {
        0.0f, 0.0f, 
        0.5f, 0.0f, 
        0.0f, 1.0f, 
        
        0.0f, 1.0f,
        0.5f, 0.0f,
        0.5f, 1.0f,
        
        0.5f, 0.0f,
        1.0f, 0.0f,
        0.5f, 1.0f,
        
        0.5f, 1.0f,
        1.0f, 0.0f,
        1.0f, 1.0f,
    };


    GLuint vbo_controller_pos;
    glGenBuffers(1, &vbo_controller_pos);
    glBindBuffer(GL_ARRAY_BUFFER, vbo_controller_pos);
    glBufferData(GL_ARRAY_BUFFER, sizeof(pos_data_controller), pos_data_controller, GL_STATIC_DRAW);
    
    glEnableVertexAttribArray(0);
    glVertexAttribPointer(0, 3, GL_FLOAT, GL_FALSE, 0, (void*)0);


    GLuint vbo_controller_uv;
    glGenBuffers(1, &vbo_controller_uv);
    glBindBuffer(GL_ARRAY_BUFFER, vbo_controller_uv);
    glBufferData(GL_ARRAY_BUFFER, sizeof(uv_data_controller), uv_data_controller, GL_STATIC_DRAW);

    glEnableVertexAttribArray(1);
    glVertexAttribPointer(1, 2, GL_FLOAT, GL_FALSE, 0, (void*)0);


    // Setup "controller" texture and upload
    int texture_width = 4;
    int texture_height = 4;
    unsigned char texture_data[] = {
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

    GLuint texture_controller;
    glGenTextures(1, &texture_controller);
    glActiveTexture(GL_TEXTURE0);
    glBindTexture(GL_TEXTURE_2D, texture_controller);

    glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MIN_FILTER, GL_NEAREST);
    glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MAG_FILTER, GL_NEAREST);
    glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_WRAP_S, GL_REPEAT);
    glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_WRAP_T, GL_REPEAT);
    glTexImage2D(GL_TEXTURE_2D, 0, GL_SRGB, texture_width, texture_height, 0, GL_RGB, GL_UNSIGNED_BYTE, texture_data);

    glUseProgram(program);
    glUniform1i(glGetUniformLocation(program, "texture_sampler"), 0);


    // Setup room vao, vbo and vertex attribs, and upload
    GLuint vao_room;
    glGenVertexArrays(1, &vao_room);
    glBindVertexArray(vao_room);

    float half_side = 10.0;
    float floor_height = -2.0; // use actual floor/sitting height
    float roof_height = 3.0;
    
    int num_vertices_room = 12;
    GLfloat pos_data_roomn[] = {
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

    GLuint vbo_room;
    glGenBuffers(1, &vbo_room);
    glBindBuffer(GL_ARRAY_BUFFER, vbo_room);
    glBufferData(GL_ARRAY_BUFFER, sizeof(pos_data_roomn), pos_data_roomn, GL_STATIC_DRAW);

    glEnableVertexAttribArray(0);
    glVertexAttribPointer(0, 3, GL_FLOAT, GL_FALSE, 0, (void*)0);
    
    glEnableVertexAttribArray(1);
    glVertexAttribPointer(1, 2, GL_FLOAT, GL_FALSE, 0, (void*)0);

    //-------------------------------------------------------------------------------------------//    

    // Enable SRGB and depth test and set background color
    glEnable(GL_DEPTH_TEST);
    glEnable(GL_FRAMEBUFFER_SRGB);
    glClearColor(0.2, 0.3, 0.4, 1.0); 

    // Main render loop
    long long frame_index = 0;
    while (!glfwWindowShouldClose(window)) {
        glfwPollEvents();

        // Get the predicted head pose for next frame
        ovr_GetEyePoses(session, frame_index, ovrTrue, hmd_to_eye_offset, layer.RenderPose, &layer.SensorSampleTime);
        
        // Get controller trackign state
        // See: https://developer.oculus.com/documentation/pcsdk/latest/concepts/dg-sensor/#dg-sensor-head-tracking
        ovrTrackingState ts = ovr_GetTrackingState(session, 0, 1);

        // Main rendering section. All draw calls currently use the same shaders. 
        glUseProgram(program);

        // Bind "controller" texture
        glActiveTexture(GL_TEXTURE0);
        glBindTexture(GL_TEXTURE_2D, texture_controller);
        
        // Upload uniforms that are the same per-eye
        glUniform1f(glGetUniformLocation(program, "time"), glfwGetTime());
        
        // We need to render the scene twice, once for each eye.
        for (int eye = 0; eye < 2; eye++) {
            // Grab the current available color buffer texture from the texture swap chain.
            int current_index;
            ovr_GetTextureSwapChainCurrentIndex(session, texture_swap_chains[eye], &current_index);

            GLuint current_texture_id;
            ovr_GetTextureSwapChainBufferGL(session, texture_swap_chains[eye], current_index, &current_texture_id);

            // Set up the framebuffer, using the current eye texture and depth texture for this eye.
            glBindFramebuffer(GL_FRAMEBUFFER, eye_fbo);
            glFramebufferTexture2D(GL_FRAMEBUFFER, GL_COLOR_ATTACHMENT0, GL_TEXTURE_2D, current_texture_id, 0);
            glFramebufferTexture2D(GL_FRAMEBUFFER, GL_DEPTH_ATTACHMENT, GL_TEXTURE_2D, depth_textures[eye], 0);

            // Setup render
            glViewport(0, 0, eye_texture_sizes[eye].w, eye_texture_sizes[eye].h);
            glClear(GL_COLOR_BUFFER_BIT | GL_DEPTH_BUFFER_BIT);

            // Upload this eye's perspective projection matrix
            ovrMatrix4f P = ovrMatrix4f_Projection(hmd_desc.MaxEyeFov[eye], 0.2f, 1000.0f, ovrProjection_None);
            glUniformMatrix4fv(glGetUniformLocation(program, "P"), 1, GL_TRUE, &P.M[0][0]);


            // Upload headset position and orientation as uniforms. 
            // The camera is rotated and translated according to these in the shader
            ovrVector3f p_hmd = layer.RenderPose[eye].Position;
            ovrQuatf q_hmd = layer.RenderPose[eye].Orientation;
            glUniform3fv(glGetUniformLocation(program, "p_hmd"), 1, &p_hmd.x);
            glUniform4fv(glGetUniformLocation(program, "q_hmd"), 1, &q_hmd.x);


            // @NOTE: The same shader is used to draw both the room (which is shaded based on position)
            // and the controllers (which are shaded based on uv's and a texture), 
            // by setting the "apply_texture" uniform to 0 (no texture) or 1 (using texture)

            // Draw the "room" first, which doesn't use any textures, but are shaded
            // based on the pixel's position/coverage relative to global gridlines
            glBindVertexArray(vao_room);
            glUniform1i(glGetUniformLocation(program, "apply_texture"), 0);
            
            // The room is static
            glUniform3f(glGetUniformLocation(program, "p_model"), 0.0, 0.0, 0.0);
            glUniform4f(glGetUniformLocation(program, "q_model"), 0.0, 0.0, 0.0, 1.0);
            glDrawArrays(GL_TRIANGLES, 0, num_vertices_room);

            
            // Next, draw the two controllers as oriented, textured quads
            glBindVertexArray(vao_controller);
            glUniform1i(glGetUniformLocation(program, "apply_texture"), 1);
            
            // Left controller
            ovrVector3f p_left = ts.HandPoses[0].ThePose.Position;
            ovrQuatf    q_left = ts.HandPoses[0].ThePose.Orientation;
            
            glUniform3fv(glGetUniformLocation(program, "p_model"), 1, &p_left.x);
            glUniform4fv(glGetUniformLocation(program, "q_model"), 1, &q_left.x);
            glDrawArrays(GL_TRIANGLES, 0, num_vertices_controller);

            // Right controller
            ovrVector3f p_right = ts.HandPoses[1].ThePose.Position;
            ovrQuatf    q_right = ts.HandPoses[1].ThePose.Orientation;

            glUniform3fv(glGetUniformLocation(program, "p_model"), 1, &p_right.x);
            glUniform4fv(glGetUniformLocation(program, "q_model"), 1, &q_right.x);
            glDrawArrays(GL_TRIANGLES, 0, num_vertices_controller);

            // Commit the render
            ovr_CommitTextureSwapChain(session, texture_swap_chains[eye]);
        }

        // Submit the layer(s), currently a single layer
        ovrLayerHeader* layer_header = &layer.Header;
        if (!OVR_SUCCESS(ovr_SubmitFrame(session, frame_index, NULL, &layer_header, 1))) {
            print_last_rift_error();
            goto Cleanup0;
        }

        // Blit mirror texture to back buffer
        // @NOTE: Alternatively do an additional monoscopic rendering to the main window
        glBindFramebuffer(GL_READ_FRAMEBUFFER, mirror_fbo);
        glBindFramebuffer(GL_DRAW_FRAMEBUFFER, 0);
        glBlitFramebuffer(0, resy, resx, 0,   0, 0, resx, resy,   GL_COLOR_BUFFER_BIT, GL_LINEAR);
        glBindFramebuffer(GL_FRAMEBUFFER, 0);

        // Done, show on screen
        glfwSwapBuffers(window);

        frame_index++;
    }

    //-------------------------------------------------------------------------------------------//    

    // Cleanup stage. 
    // I chose to use labels and gotos here, 
    // since different points of failure
    // require different levels of cleanup. 
Cleanup0:
    glDeleteProgram(program);

    glDeleteBuffers(1, &vbo_controller_pos);
    glDeleteBuffers(1, &vbo_controller_uv);
    glDeleteBuffers(1, &vbo_room);
    
    glDeleteVertexArrays(1, &vao_controller);
    glDeleteVertexArrays(1, &vao_room);
    
    glDeleteFramebuffers(1, &mirror_fbo);
    glDeleteFramebuffers(1, &eye_fbo);

    glDeleteTextures(1, &texture_controller);
    glDeleteTextures(2, &depth_textures[0]);
Cleanup1:
    ovr_DestroyMirrorTexture(session, mirror_texture_ovr);
Cleanup2:    
    ovr_DestroyTextureSwapChain(session, texture_swap_chains[0]);
    ovr_DestroyTextureSwapChain(session, texture_swap_chains[1]);
Cleanup3:
    glfwTerminate();
Cleanup4:
    ovr_Destroy(session);
Cleanup5:
    ovr_Shutdown();
Cleanup6:
    ;

    return 0;
}

//-------------------------------------------------------------------------------------------//    

// Error reporting helper functions
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

// Shader loading helper functions
char *read_entire_file(const char *filename) {
    FILE *f = fopen(filename, "rb");

    if (f == NULL) {
        return NULL;
    }

    fseek(f, 0, SEEK_END);
    long fsize = ftell(f);
    fseek(f, 0, SEEK_SET);

    char *string = (char*)malloc(fsize + 1);
    fread(string, fsize, 1, f);
    string[fsize] = '\0';
    fclose(f);

    return string;
}

int compile_shader(const char *file_path, GLuint shader_ID) {
    char *shader_code = read_entire_file(file_path);
    if (shader_code == NULL) {
        fprintf(stderr, "Error: Could not read shader file: \"%s\"\n", file_path);
        return -1;
    }
    printf("Compiling shader : %s\n", file_path);
    glShaderSource(shader_ID, 1, (const char**)&shader_code , NULL);
    glCompileShader(shader_ID);

    GLint result;
    glGetShaderiv(shader_ID, GL_COMPILE_STATUS, &result);

    if ( result == GL_FALSE ){
        GLint info_log_length;
        glGetShaderiv(shader_ID, GL_INFO_LOG_LENGTH, &info_log_length);

        char shader_error_message[99999];
        glGetShaderInfoLog(shader_ID, info_log_length, NULL, shader_error_message);
        fprintf(stderr, "Error while compiling shader \"%s\":\n%s", file_path, shader_error_message);

        free(shader_code);
        return -2;
    }

    free(shader_code);

    return 0;
}

GLuint load_shaders(const char *vertex_file_path,const char *fragment_file_path){
    GLuint vertex_shader_ID   = glCreateShader(GL_VERTEX_SHADER);
    GLuint fragment_shader_ID = glCreateShader(GL_FRAGMENT_SHADER);

    int err1 = compile_shader(vertex_file_path, vertex_shader_ID);
    int err2 = compile_shader(fragment_file_path, fragment_shader_ID);

    if (err1 || err2) {
        glDeleteShader(vertex_shader_ID);
        glDeleteShader(fragment_shader_ID);
        return 0;
    }

    GLuint program_ID = glCreateProgram();
    glAttachShader(program_ID, vertex_shader_ID);
    glAttachShader(program_ID, fragment_shader_ID);
    glLinkProgram(program_ID);

    GLint result;
    glGetProgramiv(program_ID, GL_LINK_STATUS, &result);

    if ( result == GL_FALSE ){
        GLint info_log_length;
        glGetProgramiv(program_ID, GL_INFO_LOG_LENGTH, &info_log_length);

        GLchar program_error_message[99999];
        glGetProgramInfoLog(program_ID, info_log_length, NULL, program_error_message);
        printf("Error while linking program:\n%s\n", program_error_message);
        
        glDeleteShader(vertex_shader_ID);
        glDeleteShader(fragment_shader_ID);
        return 0;
    }

    glDeleteShader(vertex_shader_ID);
    glDeleteShader(fragment_shader_ID);

    return program_ID;
}