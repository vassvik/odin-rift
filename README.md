# odin-rift

# README OUT OF DATE

A library for the programming language [Odin](https://github.com/gingerBill/Odin) for interfacing with the Oculus Rift SDK (version 1.13 currently).

Works for Odin commit "f4924e39d487f95bbfbfbc83dd0ae237923505ae" as of 28th of May, and at least Oculus SDK version 1.13 and onwards. Only works for Windows, as the SDK is Windows only at this moment. Windows 10 is recommended (and perhaps needed?).


Currently contains two examples: 
 - `main_minimal.odin` is the *bare minimum*, only drawing a different color for each eye, with no tracking at all. This one's about 250 lines of code.
 - `main.odin` goes a bit further, drawing a 3D scene with full headset and Touch controller tracking. This one's about 600 lines of code, and fairly well commented. 

Both examples use `GLFW` to manage window creation, mouse and keyboard input and context creation, and `glfwGetProcAddress` is used to fetch the OpenGL function pointers. `glfw.odin` contains all GLFW bindings (see [https://github.com/vassvik/odin-glfw](https://github.com/vassvik/odin-glfw)), and `gl.odin` contains, for the most part, only the functions that is needed in main.odin. 

Equivalent C programs are also bundled (main.c and main_minimal.c) that are functionality identical to their Odin counterparts. Compile using
```
cl /nologo main.c -Iinclude -IC:\OculusSDK\LibOVR\Include LibOVR.lib glfw3dll.lib
cl /nologo main_minimal.c -Iinclude -IC:\OculusSDK\LibOVR\Include LibOVR.lib glfw3dll.lib
```

Note: Requires the Rift SDK header files. 


Dependencies: 
 - GLFW. Bundled, both .dll and import .lib, and header files (for C code), version 3.2.1
 - Rift SDK. Bundled .lib file, version 1.13. Oculus Runtime needs to be in PATH. 


 Recommended reading: https://developer.oculus.com/documentation/pcsdk/latest/concepts/book-dg/

