# odin-rift

## Dependencies: 

To run the example (`main.odin`) you will need [odin-glfw](https://github.com/vassvik/odin-glfw), [odin-gl](https://github.com/vassvik/odin-gl) and [odin-fbx](https://github.com/vassvik/odin-fbx). Clone them into your `shared` collection in the Odin repo folder.

miniz.lib is bundled, which is used to decompress the data in the fbx model files. 


## Description

This library provides bindings to interface with the Oculus Rift SDK for the programming language [Odin](https://github.com/gingerBill/Odin). Currently supports version 1.18.

Works for Odin commit "01d8aea4df45255c6187267a58b0f84dacadc768" as of 4th of October. Only works for Windows, as the SDK is Windows only at this moment. Windows 10 is recommended (and perhaps needed?).


Currently contains two examples: 
 - `main_minimal.odin` is the *bare minimum*, only drawing a different color for each eye, with no tracking at all. This one's about 250 lines of code. 
 - `main.odin` goes a bit further, drawing a 3D scene with full headset and Touch controller tracking using official model files (with animations). 
 
Other files are work-in-progress

The examples use `GLFW` to manage window creation, mouse and keyboard input and context creation, and `glfwGetProcAddress` is used to fetch the OpenGL function pointers using `odin-gl`. `glfw.odin` contains all GLFW bindings (see [https://github.com/vassvik/odin-glfw](https://github.com/vassvik/odin-glfw)), and `gl.odin` (see [https://github.com/vassvik/odin-gl](https://github.com/vassvik/odin-gl)) loads OpenGL function pointers.


Dependencies: 
 - GLFW. Bundled, both .dll and import .lib, version 3.2.1
 - Rift SDK. Bundled .lib file, version 1.18. Oculus Runtime (the .dll) needs to be in PATH. 
 - Miniz. 

 Recommended reading: https://developer.oculus.com/documentation/pcsdk/latest/concepts/book-dg/
