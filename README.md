# odin-rift

## NOTE: Initialize submodules:

```
git submodule update --init --recursive --remote
```
## Description

This library provides bindings to interface with the Oculus Rift SDK for the programming language [Odin](https://github.com/gingerBill/Odin). Currently supports version 1.13, but will be upgraded to 1.17 momentarily. 

Works for Odin commit "1161aa829d0823cfa3e2f4c93160b7b94b4b0a5c" as of 13th of August. Only works for Windows, as the SDK is Windows only at this moment. Windows 10 is recommended (and perhaps needed?).


Currently contains two examples: 
 - `main_minimal.odin` is the *bare minimum*, only drawing a different color for each eye, with no tracking at all. This one's about 250 lines of code. **This example is OUTDATED**. 
 - `main.odin` goes a bit further, drawing a 3D scene with full headset and Touch controller tracking. 
 
 Other files are work-in-progress

The examples use `GLFW` to manage window creation, mouse and keyboard input and context creation, and `glfwGetProcAddress` is used to fetch the OpenGL function pointers. `glfw.odin` contains all GLFW bindings (see [https://github.com/vassvik/odin-glfw](https://github.com/vassvik/odin-glfw)), and `gl.odin` (see [https://github.com/vassvik/odin-gl](https://github.com/vassvik/odin-gl)) loads OpenGL function pointers.


Dependencies: 
 - GLFW. Bundled, both .dll and import .lib, version 3.2.1
 - Rift SDK. Bundled .lib file, version 1.13. Oculus Runtime (the .dll) needs to be in PATH. 


 Recommended reading: https://developer.oculus.com/documentation/pcsdk/latest/concepts/book-dg/

