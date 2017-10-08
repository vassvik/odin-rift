import "core:fmt.odin"; // println, printf
foreign_system_library ovr "libovr.lib";


// from OVR_Version.h

OVR_PRODUCT_VERSION :: 1;   // Product version doesn't participate in semantic versioning.
OVR_MAJOR_VERSION   :: 1;  // If you change these values then you need to also make sure to change LibOVR/Projects/Windows/LibOVR.props in parallel.
OVR_MINOR_VERSION   :: 18; // 
OVR_PATCH_VERSION   :: 0;
OVR_BUILD_NUMBER    :: 0;

OVR_DLL_COMPATIBLE_VERSION :: 101; // ((product * 100) + major)

OVR_MIN_REQUESTABLE_MINOR_VERSION :: 17;

OVR_FEATURE_VERSION :: 0;

OVR_VERSION_STRING :: "1.18.0";

OVR_DETAILED_VERSION_STRING :: "1.18.0.0";

_DEBUG :: true;

when _DEBUG do OVR_FILE_DESCRIPTION_STRING :: "dev build debug";
else        do OVR_FILE_DESCRIPTION_STRING :: "dev build";


// from OVR_CAPI_Keys.h

OVR_KEY_USER :: "User\x00";

OVR_KEY_NAME :: "Name\x00";

OVR_KEY_GENDER     :: "Gender\x00"; // string "Male", "Female", or "Unknown"
OVR_DEFAULT_GENDER :: "Unknown\x00";

OVR_KEY_PLAYER_HEIGHT     :: "PlayerHeight\x00"; // float meters
OVR_DEFAULT_PLAYER_HEIGHT :: f32(1.778);

OVR_KEY_EYE_HEIGHT     :: "EyeHeight\x00"; // float meters
OVR_DEFAULT_EYE_HEIGHT :: f32(1.675);

OVR_KEY_NECK_TO_EYE_DISTANCE       :: "NeckEyeDistance\x00"; // float[2] meters
OVR_DEFAULT_NECK_TO_EYE_HORIZONTAL :: f32(0.0805);
OVR_DEFAULT_NECK_TO_EYE_VERTICAL   :: f32(0.075);

OVR_KEY_EYE_TO_NOSE_DISTANCE :: "EyeToNoseDist\x00"; // float[2] meters


OVR_PERF_HUD_MODE :: "PerfHudMode\x00"; // int, allowed values are defined in enum ovrPerfHudMode

OVR_LAYER_HUD_MODE            :: "LayerHudMode\x00";                      // int, allowed values are defined in enum ovrLayerHudMode
OVR_LAYER_HUD_CURRENT_LAYER   :: "LayerHudCurrentLayer\x00";              // int, The layer to show 
OVR_LAYER_HUD_SHOW_ALL_LAYERS :: "LayerHudShowAll\x00";                   // bool, Hide other layers when the hud is enabled

OVR_DEBUG_HUD_STEREO_MODE               :: "DebugHudStereoMode\x00";                // int, allowed values are defined in enum ovrDebugHudStereoMode
OVR_DEBUG_HUD_STEREO_GUIDE_INFO_ENABLE  :: "DebugHudStereoGuideInfoEnable\x00";     // bool
OVR_DEBUG_HUD_STEREO_GUIDE_SIZE         :: "DebugHudStereoGuideSize2f\x00";         // float[2]
OVR_DEBUG_HUD_STEREO_GUIDE_POSITION     :: "DebugHudStereoGuidePosition3f\x00";     // float[3]
OVR_DEBUG_HUD_STEREO_GUIDE_YAWPITCHROLL :: "DebugHudStereoGuideYawPitchRoll3f\x00"; // float[3]
OVR_DEBUG_HUD_STEREO_GUIDE_COLOR        :: "DebugHudStereoGuideColor4f\x00";        // float[4]


// OVR_ErrorCode.h
ovrResult  :: #type i32;

ovrSuccessType :: enum i32 {
    ovrSuccess = 0,
};

ovrSuccessTypes :: enum i32 {
    ovrSuccess_NotVisible        = 1000,
    ovrSuccess_BoundaryInvalid   = 1001,  ///< Boundary is invalid due to sensor change or was not setup.
    ovrSuccess_DeviceUnavailable = 1002,
}

ovrErrorType :: enum i32 {
    /* General errors */
    ovrError_MemoryAllocationFailure       = -1000,   ///< Failure to allocate memory.
    ovrError_InvalidSession                = -1002,   ///< Invalid ovrSession parameter provided.
    ovrError_Timeout                       = -1003,   ///< The operation timed out.
    ovrError_NotInitialized                = -1004,   ///< The system or component has not been initialized.
    ovrError_InvalidParameter              = -1005,   ///< Invalid parameter provided. See error info or log for details.
    ovrError_ServiceError                  = -1006,   ///< Generic service error. See error info or log for details.
    ovrError_NoHmd                         = -1007,   ///< The given HMD doesn't exist.
    ovrError_Unsupported                   = -1009,   ///< Function call is not supported on this hardware/software
    ovrError_DeviceUnavailable             = -1010,   ///< Specified device type isn't available.
    ovrError_InvalidHeadsetOrientation     = -1011,   ///< The headset was in an invalid orientation for the requested operation (e.g. vertically oriented during ovr_RecenterPose).
    ovrError_ClientSkippedDestroy          = -1012,   ///< The client failed to call ovr_Destroy on an active session before calling ovr_Shutdown. Or the client crashed.
    ovrError_ClientSkippedShutdown         = -1013,   ///< The client failed to call ovr_Shutdown or the client crashed.
    ovrError_ServiceDeadlockDetected       = -1014,   ///< The service watchdog discovered a deadlock.
    ovrError_InvalidOperation              = -1015,   ///< Function call is invalid for object's current state
    ovrError_InsufficientArraySize         = -1016,   ///< Increase size of output array
    ovrError_NoExternalCameraInfo          = -1017,   /// There is not any external camera information stored by ovrServer.
    ovrError_LostTracking                  = -1018,   /// Tracking is lost when ovr_GetDevicePoses() is called.

    /* Audio error range, reserved for Audio errors. */
    ovrError_AudioDeviceNotFound           = -2001,   ///< Failure to find the specified audio device.
    ovrError_AudioComError                 = -2002,   ///< Generic COM error.

    /* Initialization errors. */
    ovrError_Initialize                    = -3000,   ///< Generic initialization error.
    ovrError_LibLoad                       = -3001,   ///< Couldn't load LibOVRRT.
    ovrError_LibVersion                    = -3002,   ///< LibOVRRT version incompatibility.
    ovrError_ServiceConnection             = -3003,   ///< Couldn't connect to the OVR Service.
    ovrError_ServiceVersion                = -3004,   ///< OVR Service version incompatibility.
    ovrError_IncompatibleOS                = -3005,   ///< The operating system version is incompatible.
    ovrError_DisplayInit                   = -3006,   ///< Unable to initialize the HMD display.
    ovrError_ServerStart                   = -3007,   ///< Unable to start the server. Is it already running?
    ovrError_Reinitialization              = -3008,   ///< Attempting to re-initialize with a different version.
    ovrError_MismatchedAdapters            = -3009,   ///< Chosen rendering adapters between client and service do not match
    ovrError_LeakingResources              = -3010,   ///< Calling application has leaked resources
    ovrError_ClientVersion                 = -3011,   ///< Client version too old to connect to service
    ovrError_OutOfDateOS                   = -3012,   ///< The operating system is out of date.
    ovrError_OutOfDateGfxDriver            = -3013,   ///< The graphics driver is out of date.
    ovrError_IncompatibleGPU               = -3014,   ///< The graphics hardware is not supported
    ovrError_NoValidVRDisplaySystem        = -3015,   ///< No valid VR display system found.
    ovrError_Obsolete                      = -3016,   ///< Feature or API is obsolete and no longer supported.
    ovrError_DisabledOrDefaultAdapter      = -3017,   ///< No supported VR display system found, but disabled or driverless adapter found.
    ovrError_HybridGraphicsNotSupported    = -3018,   ///< The system is using hybrid graphics (Optimus, etc...), which is not support.
    ovrError_DisplayManagerInit            = -3019,   ///< Initialization of the DisplayManager failed.
    ovrError_TrackerDriverInit             = -3020,   ///< Failed to get the interface for an attached tracker
    ovrError_LibSignCheck                  = -3021,   ///< LibOVRRT signature check failure.
    ovrError_LibPath                       = -3022,   ///< LibOVRRT path failure.
    ovrError_LibSymbols                    = -3023,   ///< LibOVRRT symbol resolution failure.
    ovrError_RemoteSession                 = -3024,   ///< Failed to connect to the service because remote connections to the service are not allowed.
    ovrError_InitializeVulkan              = -3025,   /// Vulkan initialization error.

    /* Rendering errors */
    ovrError_DisplayLost                   = -6000,   ///< In the event of a system-wide graphics reset or cable unplug this is returned to the app.
    ovrError_TextureSwapChainFull          = -6001,   ///< ovr_CommitTextureSwapChain was called too many times on a texture swapchain without calling submit to use the chain.
    ovrError_TextureSwapChainInvalid       = -6002,   ///< The ovrTextureSwapChain is in an incomplete or inconsistent state. Ensure ovr_CommitTextureSwapChain was called at least once first.
    ovrError_GraphicsDeviceReset           = -6003,   ///< Graphics device has been reset (TDR, etc...)
    ovrError_DisplayRemoved                = -6004,   ///< HMD removed from the display adapter
    ovrError_ContentProtectionNotAvailable = -6005,   ///<Content protection is not available for the display
    ovrError_ApplicationInvisible          = -6006,   ///< Application declared itself as an invisible type and is not allowed to submit frames.
    ovrError_Disallowed                    = -6007,   ///< The given request is disallowed under the current conditions.
    ovrError_DisplayPluggedIncorrectly     = -6008,   ///< Display portion of HMD is plugged into an incompatible port (ex: IGP)

    /* Fatal errors */
    ovrError_RuntimeException              = -7000,   ///< A runtime exception occurred. The application is required to shutdown LibOVR and re-initialize it before this error state will be cleared.

    /* Calibration errors */
    ovrError_NoCalibration                 = -9000,   ///< Result of a missing calibration block
    ovrError_OldVersion                    = -9001,   ///< Result of an old calibration block
    ovrError_MisformattedBlock             = -9002,   ///< Result of a bad calibration block due to lengths
}

ovrErrorInfo :: struct #ordered {
    Result: ovrResult,
    ErrorString: [512]u8,
};

// PORT NOTE: Changed from macros to inline procedures
OVR_SUCCESS :: proc(result: ovrResult) -> bool #inline { 
    return result >= ovrResult(ovrSuccessType.ovrSuccess); 
}

OVR_UNQUALIFIED_SUCCESS :: proc(result: ovrResult) -> bool #inline {
    return result == ovrResult(ovrSuccessType.ovrSuccess); 
} 

OVR_FAILURE :: proc(result: ovrResult) -> bool #inline { 
    return !OVR_SUCCESS(result); 
}


// from OVR_CAPI.h

OVR_OS :: ODIN_OS;


ovrBool    :: #type u8;   ///< Boolean type, char
ovrTrue    :: 1;          ///< ovrBool value of false.
ovrFalse   :: 0;          ///< ovrBool value of true.


// ***** Simple Math Structures

ovrColorf :: struct #ordered #align 4 {
    r, g, b, a: f32,
};

ovrVector2i :: struct #ordered #align 4 {
    x, y: i32,
};

ovrSizei :: struct #ordered #align 4 {
    w, h: i32,
};

ovrRecti :: struct #ordered #align 4 {
    Pos: ovrVector2i,
    Size: ovrSizei,
};

ovrQuatf :: struct #ordered #align 4 {
    x, y, z, w: f32, 
};

ovrVector2f :: struct #ordered #align 4 {
    x, y: f32,
};

ovrVector3f :: struct #ordered #align 4 {
    x, y, z: f32,
}

ovrMatrix4f :: struct #ordered #align 4 {
    M: [4][4]f32,
};

ovrPosef :: struct #ordered #align 4 {
    Orientation: ovrQuatf,
    Position:    ovrVector3f,
};

ovrPoseStatef :: struct #ordered #align 8 {
    ThePose:             ovrPosef,      ///< Position and orientation.
    AngularVelocity:     ovrVector3f,   ///< Angular velocity in radians per second.
    LinearVelocity:      ovrVector3f,   ///< Velocity in meters per second.
    AngularAcceleration: ovrVector3f,   ///< Angular acceleration in radians per second per second.
    LinearAcceleration:  ovrVector3f,   ///< Acceleration in meters per second per second.
    pad0:                [4]u8,         ///< \internal struct pad.
    TimeInSeconds:       f64,           ///< Absolute time that this pose refers to. \see ovr_GetTimeInSeconds
};

ovrFovPort :: struct #ordered #align 4 {
    UpTan:    f32, ///< The tangent of the angle between the viewing vector and the top edge of the field of view.
    DownTan:  f32, ///< The tangent of the angle between the viewing vector and the bottom edge of the field of view.
    LeftTan:  f32, ///< The tangent of the angle between the viewing vector and the left edge of the field of view.
    RightTan: f32, ///< The tangent of the angle between the viewing vector and the right edge of the field of view.    
};

ovrHmdType :: enum i32 {
    ovrHmd_None      = 0,
    ovrHmd_DK1       = 3,
    ovrHmd_DKHD      = 4,
    ovrHmd_DK2       = 6,
    ovrHmd_CB        = 8,
    ovrHmd_Other     = 9,
    ovrHmd_E3_2015   = 10,
    ovrHmd_ES06      = 11,
    ovrHmd_ES09      = 12,
    ovrHmd_ES11      = 13,
    ovrHmd_CV1       = 14,

    ovrHmd_EnumSize  = 0x7fffffff, ///< \internal Force type int32_t.
};

ovrHmdCaps :: enum i32 {
    ovrHmdCap_DebugDevice         = 0x0010,   ///< <B>(read only)</B> Specifies that the HMD is a virtual debug device.
    ovrHmdCap_EnumSize            = 0x7fffffff ///< \internal Force type int32_t.
}

ovrTrackingCaps :: enum i32 {
    ovrTrackingCap_Orientation      = 0x0010,    ///< Supports orientation tracking (IMU).
    ovrTrackingCap_MagYawCorrection = 0x0020,    ///< Supports yaw drift correction via a magnetometer or other means.
    ovrTrackingCap_Position         = 0x0040,    ///< Supports positional tracking.
    ovrTrackingCap_EnumSize         = 0x7fffffff ///< \internal Force type int32_t.
}

ovrEyeType :: enum i32 {
    ovrEye_Left     = 0,         ///< The left eye, from the viewer's perspective.
    ovrEye_Right    = 1,         ///< The right eye, from the viewer's perspective.
    ovrEye_Count    = 2,         ///< \internal Count of enumerated elements.
    ovrEye_EnumSize = 0x7fffffff ///< \internal Force type int32_t.
}

ovrTrackingOrigin :: enum i32 {
    ovrTrackingOrigin_EyeLevel = 0,
    ovrTrackingOrigin_FloorLevel = 1,
    ovrTrackingOrigin_Count = 2,            ///< \internal Count of enumerated elements.
    ovrTrackingOrigin_EnumSize = 0x7fffffff ///< \internal Force type int32_t.
};

ovrGraphicsLuid :: struct #ordered #align 8 {
    // Public definition reserves space for graphics API-specific implementation
    Reserved : [8]u8,
};

ovrHmdDesc :: struct #ordered #align 8 {
    Type:                  ovrHmdType,                           ///< The type of HMD.
    pad0:                  [4]u8,                                ///< \internal struct paddding.
    ProductName:           [64]u8,                               ///< UTF8-encoded product identification string (e.g. "Oculus Rift DK1").
    Manufacturer:          [64]u8,                               ///< UTF8-encoded HMD manufacturer identification string.
    VendorId:              i16,                                  ///< HID (USB) vendor identifier of the device.
    ProductId:             i16,                                  ///< HID (USB) product identifier of the device.
    SerialNumber:          [24]u8,                               ///< HMD serial number.
    FirmwareMajor:         i16,                                  ///< HMD firmware major version.
    FirmwareMinor:         i16,                                  ///< HMD firmware minor version.
    AvailableHmdCaps:      u32,                                  ///< Capability bits described by ovrHmdCaps which the HMD currently supports.
    DefaultHmdCaps:        u32,                                  ///< Capability bits described by ovrHmdCaps which are default for the current Hmd.
    AvailableTrackingCaps: u32,                                  ///< Capability bits described by ovrTrackingCaps which the system currently supports.
    DefaultTrackingCaps:   u32,                                  ///< Capability bits described by ovrTrackingCaps which are default for the current system.
    DefaultEyeFov:         [ovrEyeType.ovrEye_Count]ovrFovPort,  ///< Defines the recommended FOVs for the HMD.
    MaxEyeFov:             [ovrEyeType.ovrEye_Count]ovrFovPort,  ///< Defines the maximum FOVs for the HMD.
    Resolution:            ovrSizei,                             ///< Resolution of the full HMD screen (both eyes) in pixels.
    DisplayRefreshRate:    f32,                                  ///< Nominal refresh rate of the display in cycles per second at the time of HMD creation.
    pad1:                  [4]u8,                                ///< \internal struct paddding.
};


ovrSession :: #type ^struct {};
ovrProcessId :: u32;

VkInstance :: ^struct {};
VkPhysicalDevice :: ^struct {};
VkDevice :: ^struct {};
VkQueue :: ^struct {};
VkImage :: ^struct {};


ovrStatusBits :: enum i32 {
    ovrStatus_OrientationTracked    = 0x0001,    ///< Orientation is currently tracked (connected and in use).
    ovrStatus_PositionTracked       = 0x0002,    ///< Position is currently tracked (false if out of range).
    ovrStatus_EnumSize              = 0x7fffffff ///< \internal Force type int32_t.
};

ovrTrackerDesc :: struct #ordered #align 8 {
    FrustumHFovInRadians: f32,      ///< Sensor frustum horizontal field-of-view (if present).
    FrustumVFovInRadians: f32,      ///< Sensor frustum vertical field-of-view (if present).
    FrustumNearZInMeters: f32,      ///< Sensor frustum near Z (if present).
    FrustumFarZInMeters:  f32,      ///< Sensor frustum far Z (if present).
};

ovrTrackerFlags :: enum i32 {
    ovrTracker_Connected   = 0x0020,      ///< The sensor is present, else the sensor is absent or offline.
    ovrTracker_PoseTracked = 0x0004       ///< The sensor has a valid pose, else the pose is unavailable. This will only be set if ovrTracker_Connected is set.
};

ovrTrackerPose :: struct #ordered #align 8 {
    TrackerFlags: u32,      ///< ovrTrackerFlags.
    Pose: ovrPosef,         ///< The sensor's pose. This pose includes sensor tilt (roll and pitch). For a leveled coordinate system use LeveledPose.
    LeveledPose: ovrPosef,  ///< The sensor's leveled pose, aligned with gravity. This value includes position and yaw of the sensor, but not roll and pitch. It can be used as a reference point to render real-world objects in the correct location.
    pad0: [4]u8,            ///< \internal struct pad.
};

ovrTrackingState :: struct #ordered #align 8 {
    HeadPose:         ovrPoseStatef,
    StatusFlags:      u32,
    HandPoses:         [2]ovrPoseStatef,
    HandStatusFlags:  [2]u32,
    CalibratedOrigin: ovrPosef,
};

ovrEyeRenderDesc :: struct #ordered #align 4 {
    Eye: ovrEyeType,                         ///< The eye index to which this instance corresponds.
    Fov: ovrFovPort,                         ///< The field of view.
    DistortedViewport: ovrRecti,             ///< Distortion viewport.
    PixelsPerTanAngleAtCenter: ovrVector2f,  ///< How many display pixels will fit in tan(angle) = 1.
    HmdToEyePose: ovrPosef,             ///< Translation of each eye, in meters. @NOTE: CHANGED FROM VECTOR TO POSE IN 1.17
};

ovrTimewarpProjectionDesc :: struct #ordered #align 4 {
    Projection22: f32,     ///< Projection matrix element [2][2].
    Projection23: f32,     ///< Projection matrix element [2][3].
    Projection32: f32,     ///< Projection matrix element [3][2].
};

ovrViewScaleDesc :: struct #ordered #align 4 {
    HmdToEyeOffset:               [ovrEyeType.ovrEye_Count]ovrVector3f,   ///< Translation of each eye.
    HmdSpaceToWorldScaleInMeters: f32,                                    ///< Ratio of viewer units to meter units.
};


// ***** Platform-independent Rendering Configuration

ovrTextureType :: enum i32 {
    ovrTexture_2D,              ///< 2D textures.
    ovrTexture_2D_External,     ///< External 2D texture. Not used on PC
    ovrTexture_Cube,            ///< Cube maps. Not currently supported on PC.
    ovrTexture_Count,
    ovrTexture_EnumSize = 0x7fffffff  ///< \internal Force type int32_t.
};

ovrTextureBindFlags :: enum i32 {
    ovrTextureBind_None,
    ovrTextureBind_DX_RenderTarget = 0x0001,    ///< The application can write into the chain with pixel shader
    ovrTextureBind_DX_UnorderedAccess = 0x0002, ///< The application can write to the chain with compute shader
    ovrTextureBind_DX_DepthStencil = 0x0004,    ///< The chain buffers can be bound as depth and/or stencil buffers

    ovrTextureBind_EnumSize = 0x7fffffff  ///< \internal Force type int32_t.
};

ovrTextureFormat :: enum i32 {
    OVR_FORMAT_UNKNOWN              = 0,
    OVR_FORMAT_B5G6R5_UNORM         = 1,    ///< Not currently supported on PC. Would require a DirectX 11.1 device.
    OVR_FORMAT_B5G5R5A1_UNORM       = 2,    ///< Not currently supported on PC. Would require a DirectX 11.1 device.
    OVR_FORMAT_B4G4R4A4_UNORM       = 3,    ///< Not currently supported on PC. Would require a DirectX 11.1 device.
    OVR_FORMAT_R8G8B8A8_UNORM       = 4,
    OVR_FORMAT_R8G8B8A8_UNORM_SRGB  = 5,
    OVR_FORMAT_B8G8R8A8_UNORM       = 6,
    OVR_FORMAT_B8G8R8A8_UNORM_SRGB  = 7,    ///< Not supported for OpenGL applications
    OVR_FORMAT_B8G8R8X8_UNORM       = 8,    ///< Not supported for OpenGL applications
    OVR_FORMAT_B8G8R8X8_UNORM_SRGB  = 9,    ///< Not supported for OpenGL applications
    OVR_FORMAT_R16G16B16A16_FLOAT   = 10,
    OVR_FORMAT_R11G11B10_FLOAT      = 25,   ///< Introduced in v1.10

    OVR_FORMAT_D16_UNORM            = 11,
    OVR_FORMAT_D24_UNORM_S8_UINT    = 12,
    OVR_FORMAT_D32_FLOAT            = 13,
    OVR_FORMAT_D32_FLOAT_S8X24_UINT = 14,

    OVR_FORMAT_BC1_UNORM            = 15,
    OVR_FORMAT_BC1_UNORM_SRGB       = 16,
    OVR_FORMAT_BC2_UNORM            = 17,
    OVR_FORMAT_BC2_UNORM_SRGB       = 18,
    OVR_FORMAT_BC3_UNORM            = 19,
    OVR_FORMAT_BC3_UNORM_SRGB       = 20,
    OVR_FORMAT_BC6H_UF16            = 21,
    OVR_FORMAT_BC6H_SF16            = 22,
    OVR_FORMAT_BC7_UNORM            = 23,
    OVR_FORMAT_BC7_UNORM_SRGB       = 24,
    
    OVR_FORMAT_ENUMSIZE = 0x7fffffff  ///< \internal Force type int32_t.
};

ovrTextureMiscFlags :: enum i32 { // @WARNING: OVR_CAPI.h is inconsistent in typedefing the struct name
    ovrTextureMisc_None = 0x0000,
    ovrTextureMisc_DX_Typeless = 0x0001,
    ovrTextureMisc_AllowGenerateMips = 0x0002,
    ovrTextureMisc_ProtectedContent = 0x0004,
    ovrTextureMisc_EnumSize = 0x7fffffff  ///< \internal Force type int32_t.
};

ovrTextureSwapChainDesc :: struct #ordered {
    Type:        ovrTextureType,  // @WARNING: Unset in OVR_CAPI.h
    Format:      ovrTextureFormat,
    ArraySize:   i32,               ///< Only supported with ovrTexture_2D. Not supported on PC at this time.
    Width:       i32,
    Height:      i32,
    MipLevels:   i32,
    SampleCount: i32,               ///< Current only supported on depth textures
    StaticImage: ovrBool,           ///< Not buffered in a chain. For images that don't change
    MiscFlags:   u32,               ///< ovrTextureFlags
    BindFlags:   u32,               ///< ovrTextureBindFlags. Not used for GL.
};

ovrMirrorTextureDesc :: struct #ordered {
    Format:        ovrTextureFormat,
    Width:         i32,
    Height:        i32,
    MiscFlags:     u32,              ///< ovrTextureFlags
    MirrorOptions: u32, // @WARNING; ADDED SINCE 1.13
};

ovrTextureSwapChain :: #type ^struct {};
ovrMirrorTexture :: #type ^struct {};


//-----------------------------------------------------------------------------------

ovrButton :: enum i32 {
    ovrButton_A         = 0x00000001, /// A button on XBox controllers and right Touch controller. Select button on Oculus Remote.
    ovrButton_B         = 0x00000002, /// B button on XBox controllers and right Touch controller. Back button on Oculus Remote.
    ovrButton_RThumb    = 0x00000004, /// Right thumbstick on XBox controllers and Touch controllers. Not present on Oculus Remote.
    ovrButton_RShoulder = 0x00000008, /// Right shoulder button on XBox controllers. Not present on Touch controllers or Oculus Remote.

    ovrButton_X         = 0x00000100,  /// X button on XBox controllers and left Touch controller. Not present on Oculus Remote.
    ovrButton_Y         = 0x00000200,  /// Y button on XBox controllers and left Touch controller. Not present on Oculus Remote.
    ovrButton_LThumb    = 0x00000400,  /// Left thumbstick on XBox controllers and Touch controllers. Not present on Oculus Remote.
    ovrButton_LShoulder = 0x00000800,  /// Left shoulder button on XBox controllers. Not present on Touch controllers or Oculus Remote.

    ovrButton_Up        = 0x00010000,  /// Up button on XBox controllers and Oculus Remote. Not present on Touch controllers.
    ovrButton_Down      = 0x00020000,  /// Down button on XBox controllers and Oculus Remote. Not present on Touch controllers.
    ovrButton_Left      = 0x00040000,  /// Left button on XBox controllers and Oculus Remote. Not present on Touch controllers.
    ovrButton_Right     = 0x00080000,  /// Right button on XBox controllers and Oculus Remote. Not present on Touch controllers.
    ovrButton_Enter     = 0x00100000,  /// Start on XBox 360 controller. Menu on XBox One controller and Left Touch controller. Should be referred to as the Menu button in user-facing documentation.
    ovrButton_Back      = 0x00200000,  /// Back on Xbox 360 controller. View button on XBox One controller. Not present on Touch controllers or Oculus Remote.
    ovrButton_VolUp     = 0x00400000,  /// Volume button on Oculus Remote. Not present on XBox or Touch controllers.
    ovrButton_VolDown   = 0x00800000,  /// Volume button on Oculus Remote. Not present on XBox or Touch controllers.
    ovrButton_Home      = 0x01000000,  /// Home button on XBox controllers. Oculus button on Touch controllers and Oculus Remote.
    
    ovrButton_Private   = ovrButton_VolUp | ovrButton_VolDown | ovrButton_Home,

    ovrButton_RMask = ovrButton_A | ovrButton_B | ovrButton_RThumb | ovrButton_RShoulder,
    ovrButton_LMask = ovrButton_X | ovrButton_Y | ovrButton_LThumb | ovrButton_LShoulder | ovrButton_Enter,

    ovrButton_EnumSize  = 0x7fffffff ///< \internal Force type int32_t.
};

ovrTouch :: enum i32 {
    ovrTouch_A              = 0x00000001, // ovrButton_A,
    ovrTouch_B              = 0x00000002, // ovrButton_B,
    ovrTouch_RThumb         = 0x00000004, // ovrButton_RThumb,
    ovrTouch_RThumbRest     = 0x00000008,
    ovrTouch_RIndexTrigger  = 0x00000010,

    ovrTouch_RButtonMask    = ovrTouch_A | ovrTouch_B | ovrTouch_RThumb | ovrTouch_RThumbRest | ovrTouch_RIndexTrigger,

    ovrTouch_X              = 0x00000100, // ovrButton_X,
    ovrTouch_Y              = 0x00000200, // ovrButton_Y,
    ovrTouch_LThumb         = 0x00000400, // ovrButton_LThumb,
    ovrTouch_LThumbRest     = 0x00000800,
    ovrTouch_LIndexTrigger  = 0x00001000,

    ovrTouch_LButtonMask    = ovrTouch_X | ovrTouch_Y | ovrTouch_LThumb | ovrTouch_LThumbRest | ovrTouch_LIndexTrigger,

    ovrTouch_RIndexPointing = 0x00000020,
    ovrTouch_RThumbUp       = 0x00000040,
    ovrTouch_LIndexPointing = 0x00002000,
    ovrTouch_LThumbUp       = 0x00004000,

    ovrTouch_RPoseMask      = ovrTouch_RIndexPointing | ovrTouch_RThumbUp,
    ovrTouch_LPoseMask      = ovrTouch_LIndexPointing | ovrTouch_LThumbUp,

    ovrTouch_EnumSize       = 0x7fffffff ///< \internal Force type int32_t.
};

ovrTouchHapticsDesc :: struct #ordered #align 8 {
    SampleRateHz: i32,
    SampleSizeInBytes: i32,

    QueueMinSizeToAvoidStarvation: i32,

    SubmitMinSamples: i32,
    SubmitMaxSamples: i32,
    SubmitOptimalSamples: i32,
};

ovrControllerType :: enum i32 {
    ovrControllerType_None      = 0x0000,
    ovrControllerType_LTouch    = 0x0001,
    ovrControllerType_RTouch    = 0x0002,
    ovrControllerType_Touch     = (ovrControllerType_LTouch | ovrControllerType_RTouch),
    ovrControllerType_Remote    = 0x0004,

    ovrControllerType_XBox      = 0x0010,

    ovrControllerType_Object0   = 0x0100,
    ovrControllerType_Object1   = 0x0200,
    ovrControllerType_Object2   = 0x0400,
    ovrControllerType_Object3   = 0x0800,

    ovrControllerType_Active    = -1, ///< Operate on or query whichever controller is active. // @@@ WARNING!!: is 0xffffffff in the OVR_CAPI.h!

    ovrControllerType_EnumSize  = 0x7fffffff ///< \internal Force type int32_t.
};

ovrHapticsBufferSubmitMode :: enum i32 {
    ovrHapticsBufferSubmit_Enqueue = 0x0, // @WARNING: unset in OVR_CAPI.h
};

OVR_HAPTICS_BUFFER_SAMPLES_MAX :: 256;

ovrHapticsBuffer :: struct #ordered {
    Samples: rawptr, // @WARNING: const void* 
    SamplesCount: i32,
    SubmitMode: ovrHapticsBufferSubmitMode,
};

ovrHapticsPlaybackState :: struct #ordered {
    RemainingQueueSpace: i32,
    SamplesQueued: i32,
};

ovrTrackedDeviceType :: enum i32 {
    ovrTrackedDevice_None       = 0x0000,
    ovrTrackedDevice_HMD        = 0x0001,
    ovrTrackedDevice_LTouch     = 0x0002,
    ovrTrackedDevice_RTouch     = 0x0004,
    ovrTrackedDevice_Touch      = (ovrTrackedDevice_LTouch| ovrTrackedDevice_RTouch),
    
    ovrTrackedDevice_Object0    = 0x0010,
    ovrTrackedDevice_Object1    = 0x0020,
    ovrTrackedDevice_Object2    = 0x0040,
    ovrTrackedDevice_Object3    = 0x0080,

    ovrTrackedDevice_All        = 0xFFFF,
};

ovrBoundaryType :: enum i32 {
    ovrBoundary_Outer           = 0x0001,
    ovrBoundary_PlayArea        = 0x0100,
};

ovrBoundaryLookAndFeel :: struct #ordered {
    Color: ovrColorf,
};

ovrBoundaryTestResult :: struct #ordered {
    IsTriggering: ovrBool,
    ClosestDistance: f32,
    ClosestPoint: ovrVector3f,
    ClosestPointNormal: ovrVector3f,
};

ovrHandType :: enum i32 {
    ovrHand_Left  = 0,
    ovrHand_Right = 1,
    ovrHand_Count = 2,
    ovrHand_EnumSize = 0x7fffffff ///< \internal Force type int32_t.
};

ovrInputState :: struct #ordered {
    TimeInSeconds: f64,
    Buttons: u32,
    Touches: u32,
    IndexTrigger: [ovrHandType.ovrHand_Count]f32,
    HandTrigger: [ovrHandType.ovrHand_Count]f32,
    Thumbstick: [ovrHandType.ovrHand_Count]ovrVector2f,
    ControllerType: ovrControllerType,
    IndexTriggerNoDeadzone: [ovrHandType.ovrHand_Count]f32,
    HandTriggerNoDeadzone: [ovrHandType.ovrHand_Count]f32,
    ThumbstickNoDeadzone: [ovrHandType.ovrHand_Count]ovrVector2f,
    IndexTriggerRaw: [ovrHandType.ovrHand_Count]f32,
    HandTriggerRaw: [ovrHandType.ovrHand_Count]f32,
    ThumbstickRaw: [ovrHandType.ovrHand_Count]ovrVector2f,
};


ovrCameraIntrinsics :: struct #ordered  {
  LastChangedTime: f64,
  FOVPort: ovrFovPort,
  VirtualNearPlaneDistanceMeters: f32,
  VirtualFarPlaneDistanceMeters: f32,
  ImageSensorPixelResolution: ovrSizei,
  LensDistortionMatrix: ovrMatrix4f,
  ExposurePeriodSeconds: f64,
  ExposureDurationSeconds: f64,
};

ovrCameraStatusFlags :: enum i32 {
  ovrCameraStatus_None = 0x0,
  ovrCameraStatus_Connected = 0x1,
  ovrCameraStatus_Calibrating = 0x2,
  ovrCameraStatus_CalibrationFailed = 0x4,
  ovrCameraStatus_Calibrated = 0x8,
  ovrCameraStatus_EnumSize = 0x7fffffff ///< \internal Force type int32_t.
};

ovrCameraExtrinsics :: struct #ordered {
  LastChangedTimeSeconds:   f64,
  CameraStatusFlags:        u32,
  AttachedToDevice:         ovrTrackedDeviceType,
  RelativePose:             ovrPosef,
  LastExposureTimeSeconds:  f64,
  ExposureLatencySeconds:   f64,
  AdditionalLatencySeconds: f64,
};

OVR_EXTERNAL_CAMERA_NAME_SIZE :: 32;

ovrExternalCamera :: struct #ordered {
  Name: [OVR_EXTERNAL_CAMERA_NAME_SIZE]u8,
  Intrinsics: ovrCameraIntrinsics,
  Extrinsics: ovrCameraExtrinsics,
};


// ***** Initialize structures

ovrInitFlags :: enum i32 {
    ovrInit_Debug          = 0x00000001,
    ovrInit_RequestVersion = 0x00000004,
    ovrInit_Invisible      = 0x00000010,
    ovrInit_MixedRendering = 0x00000020,
    ovrinit_WritableBits   = 0x00ffffff,
    ovrInit_EnumSize       = 0x7fffffff ///< \internal Force type int32_t.
};

ovrLogLevel :: enum i32 {
    ovrLogLevel_Debug    = 0, ///< Debug-level log event.
    ovrLogLevel_Info     = 1, ///< Info-level log event.
    ovrLogLevel_Error    = 2, ///< Error-level log event.

    ovrLogLevel_EnumSize = 0x7fffffff ///< \internal Force type int32_t.
};

ovrLogCallback :: #type proc(userData: uint, level: i32, message: ^u8) #cc_c; // @WARNING: message was initially const char* in OVR_CAPI.h

ovrInitParams :: struct #ordered #align 8 {
    Flags:                 u32,
    RequestedMinorVersion: u32,
    LogCallback:           ovrLogCallback,
    UserData:              uint,
    ConnectionTimeoutMS:   u32,
    pad0:                  [4]u8, ///< \internal
};


// ***** API Interfaces

foreign ovr {   
    ovr_Initialize :: proc(params: ^ovrInitParams) -> ovrResult ---;

    ovr_Shutdown :: proc() ---;

    ovr_GetLastErrorInfo :: proc(errorInfo: ^ovrErrorInfo) ---;

    ovr_GetVersionString :: proc() -> ^u8 ---; // @WARNING: returns const char* in OVR_CAPI.h

    ovr_TraceMessage :: proc(level: i32, message: ^u8) -> i32 ---; // @WARNING: message originall const char* in OVR_CAPI.h

    ovr_IdentifyClient :: proc(identify: ^u8) -> ovrResult ---; // @WARNING: identity originally const char* in OVR_CAPI.h
}


/// @name HMD Management

foreign ovr {   
    ovr_GetHmdDesc :: proc(session: ovrSession) -> ovrHmdDesc ---;

    ovr_GetTrackerCount :: proc(session: ovrSession) -> u32 ---;

    ovr_GetTrackerDesc :: proc(session: ovrSession, trackerDescIndex: u32) -> ovrTrackerDesc ---;

    ovr_Create :: proc(pSession: ^ovrSession, pLuid: ^ovrGraphicsLuid) -> ovrResult ---;

    ovr_Destroy :: proc(ovrSession) ---;
}

ovrSessionStatus :: struct #ordered {
    IsVisible:      ovrBool,  ///< True if the process has VR focus and thus is visible in the HMD.
    HmdPresent:     ovrBool,  ///< True if an HMD is present.
    HmdMounted:     ovrBool,  ///< True if the HMD is on the user's head.
    DisplayLost:    ovrBool,  ///< True if the session is in a display-lost state. See ovr_SubmitFrame.
    ShouldQuit:     ovrBool,  ///< True if the application should initiate shutdown.
    ShouldRecenter: ovrBool,  ///< True if UX has requested re-centering. Must call ovr_ClearShouldRecenterFlag, ovr_RecenterTrackingOrigin or ovr_SpecifyTrackingOrigin
    Internal:       [2]ovrBool,
};

foreign ovr ovr_GetSessionStatus :: proc(session: ovrSession, sessionStatus: ^ovrSessionStatus) -> ovrResult ---;


/// @name Tracking

foreign ovr {
    ovr_SetTrackingOriginType :: proc(session: ovrSession, origin: ovrTrackingOrigin) -> ovrResult ---;

    ovr_GetTrackingOriginType :: proc(session: ovrSession) -> ovrTrackingOrigin ---;

    ovr_RecenterTrackingOrigin :: proc(session: ovrSession) -> ovrResult ---;

    ovr_SpecifyTrackingOrigin :: proc(session: ovrSession, originPose: ovrPosef) -> ovrResult ---;

    ovr_ClearShouldRecenterFlag :: proc(session: ovrSession) ---;

    ovr_GetTrackingState :: proc(session: ovrSession, absTime: f64, latencyMarker: ovrBool) -> ovrTrackingState ---;

    ovr_GetDevicePoses :: proc(session: ovrSession, deviceTypes: ^ovrTrackedDeviceType, deviceCount: i32, absTime: f64, outDevicePoses: ^ovrPoseStatef) -> ovrResult ---;

    ovr_GetTrackerPose :: proc(session: ovrSession, trackerPoseIndex: u32) -> ovrTrackerPose ---;

    ovr_GetInputState :: proc(session: ovrSession, controllerType: ovrControllerType, inputState: ^ovrInputState) -> ovrResult ---;

    ovr_GetConnectedControllerTypes :: proc(session: ovrSession) -> u32 ---;

    ovr_GetTouchHapticsDesc :: proc(session: ovrSession, controllerType: ovrControllerType) -> ovrTouchHapticsDesc ---;

    ovr_SetControllerVibration :: proc(session: ovrSession, controllerType: ovrControllerType, frequency, amplitude: f32) -> ovrResult ---;

    ovr_SubmitControllerVibration :: proc(session: ovrSession, controllerType: ovrControllerType, buffer: ^ovrHapticsBuffer) -> ovrResult ---; // @WARNING: const removed

    ovr_GetControllerVibrationState :: proc(session: ovrSession, controllerType: ovrControllerType, outState: ^ovrHapticsPlaybackState) -> ovrResult ---;

    ovr_TestBoundary :: proc(session: ovrSession, deviceBitmask: ovrTrackedDeviceType, boundaryType: ovrBoundaryType, outTestResult: ^ovrBoundaryTestResult) -> ovrResult ---;

    ovr_TestBoundaryPoint :: proc(session: ovrSession, point: ^ovrVector3f, singleBoundaryType: ovrBoundaryType, outTestResult: ^ovrBoundaryTestResult) -> ovrResult ---; // @WARNING: const removed

    ovr_SetBoundaryLookAndFeel :: proc(session: ovrSession, lookAndFeel: ^ovrBoundaryLookAndFeel) -> ovrResult ---; // @WARNING: const removed

    ovr_ResetBoundaryLookAndFeel :: proc(session: ovrSession) -> ovrResult ---;

    ovr_GetBoundaryGeometry :: proc(session: ovrSession, boundaryType: ovrBoundaryType, outFloorPoints: ^ovrVector3f, outFloorPointsCount: ^i32) -> ovrResult ---;

    ovr_GetBoundaryDimensions :: proc(session: ovrSession, boundaryType: ovrBoundaryType, outDimensions: ^ovrVector3f) -> ovrResult ---;

    ovr_GetBoundaryVisible :: proc(session: ovrSession, outIsVisible: ^ovrBool) -> ovrResult ---;

    ovr_RequestBoundaryVisible :: proc(session: ovrSession, visible: ovrBool) -> ovrResult ---;
}


// @name Layers

ovrMaxLayerCount :: 16;

ovrLayerType :: enum i32 {
    ovrLayerType_Disabled       = 0,      ///< Layer is disabled.
    ovrLayerType_EyeFov         = 1,      ///< Described by ovrLayerEyeFov.
    ovrLayerType_Quad           = 3,      ///< Described by ovrLayerQuad. Previously called ovrLayerType_QuadInWorld.
    /// enum 4 used to be ovrLayerType_QuadHeadLocked. Instead, use ovrLayerType_Quad with ovrLayerFlag_HeadLocked.
    ovrLayerType_EyeMatrix      = 5,      ///< Described by ovrLayerEyeMatrix.
    ovrLayerType_EnumSize       = 0x7fffffff ///< Force type int32_t.
};

ovrLayerFlags :: enum i32 {
    ovrLayerFlag_HighQuality               = 0x01,
    ovrLayerFlag_TextureOriginAtBottomLeft = 0x02,
    ovrLayerFlag_HeadLocked                = 0x04
};

ovrLayerHeader :: struct #ordered #align 8 { // @WARNING: aligned to pointer size. @TODO: warning on all other align as pointer size
    Type:  ovrLayerType,   ///< Described by ovrLayerType.
    Flags: u32,            ///< Described by ovrLayerFlags.
};

ovrLayerEyeFov :: struct #ordered #align 8 {  // @WARNING: aligned to pointer size.
    Header: ovrLayerHeader,
    ColorTexture: [ovrEyeType.ovrEye_Count]ovrTextureSwapChain,
    Viewport: [ovrEyeType.ovrEye_Count]ovrRecti,
    Fov: [ovrEyeType.ovrEye_Count]ovrFovPort,
    RenderPose: [ovrEyeType.ovrEye_Count]ovrPosef,
    SensorSampleTime: f64,
};

ovrLayerEyeMatrix :: struct #ordered #align 8 {  // @WARNING: aligned to pointer size.
    Header: ovrLayerHeader,
    ColorTexture: [ovrEyeType.ovrEye_Count]ovrTextureSwapChain,
    Viewport: [ovrEyeType.ovrEye_Count]ovrRecti,
    RenderPose: [ovrEyeType.ovrEye_Count]ovrPosef,
    Matrix: [ovrEyeType.ovrEye_Count]ovrMatrix4f,
    SensorSampleTime: f64,
};

ovrLayerQuad :: struct #ordered #align 8 {  // @WARNING: aligned to pointer size.
    Header: ovrLayerHeader,
    ColorTexture: ovrTextureSwapChain,
    Viewport: ovrRecti,
    QuadPoseCenter: ovrPosef,
    QuadSize: ovrVector2f,
};

ovrLayer_Union :: struct #raw_union {
    Header: ovrLayerHeader,
    EyeFov: ovrLayerEyeFov,
    Quad:   ovrLayerQuad,
};


/// SDK Distortion Rendering

foreign ovr {   
    ovr_GetTextureSwapChainLength :: proc(session: ovrSession, chain: ovrTextureSwapChain, out_Length: ^i32) -> ovrResult ---;

    ovr_GetTextureSwapChainCurrentIndex :: proc(session: ovrSession, chain: ovrTextureSwapChain, out_Index: ^i32) -> ovrResult ---;

    ovr_GetTextureSwapChainDesc :: proc(session: ovrSession, chain: ovrTextureSwapChain, out_Desc: ^ovrTextureSwapChainDesc) -> ovrResult ---;

    ovr_CommitTextureSwapChain :: proc(session: ovrSession, chain: ovrTextureSwapChain) -> ovrResult ---;

    ovr_DestroyTextureSwapChain :: proc(session: ovrSession, chain: ovrTextureSwapChain) ---;

    ovr_DestroyMirrorTexture :: proc(session: ovrSession, mirrorTexture: ovrMirrorTexture) ---;

    ovr_GetFovTextureSize :: proc(session: ovrSession, eye: ovrEyeType, fov: ovrFovPort, pixelsPerDisplayPixel: f32) -> ovrSizei ---;

    ovr_GetRenderDesc :: proc(session: ovrSession, eyeType: ovrEyeType, fov: ovrFovPort) -> ovrEyeRenderDesc ---;

    ovr_SubmitFrame :: proc(session: ovrSession, frameIndex: i64, viewScaleDesc: ^ovrViewScaleDesc, layerPtrList: ^^ovrLayerHeader, layerCount: u32) -> ovrResult ---; // @WARNING: const removed
}


/// Frame Timing

ovrPerfStatsPerCompositorFrame :: struct #ordered #align 4 {
    HmdVsyncIndex: i32,

    AppFrameIndex: i32,
    AppDroppedFrameCount: i32,
    AppMotionToPhotonLatency: f32,
    AppQueueAheadTime: f32,
    AppCpuElapsedTime: f32,
    AppGpuElapsedTime: f32,
    
    CompositorFrameIndex: i32,
    CompositorDroppedFrameCount: i32,
    CompositorLatency: f32,
    CompositorCpuElapsedTime: f32,
    CompositorGpuElapsedTime: f32,
    CompositorCpuStartToGpuEndElapsedTime: f32,
    CompositorGpuEndToVsyncElapsedTime: f32,
    
    AswIsActive: ovrBool,
    AswActivatedToggleCount: i32,
    AswPresentedFrameCount: i32,
    AswFailedFrameCount: i32,
};

ovrMaxProvidedFrameStats :: 5;

ovrPerfStats :: struct #ordered #align 4 {
    FrameStats: [ovrMaxProvidedFrameStats]ovrPerfStatsPerCompositorFrame,
    FrameStatsCount: i32,
    AnyFrameStatsDropped: ovrBool,
    AdaptiveGpuPerformanceScale: f32,
    AswIsAvailable: ovrBool,
    VisibleProcessId: ovrProcessId,
};

foreign ovr {   
    ovr_GetPerfStats :: proc(session: ovrSession, outStats: ^ovrPerfStats) -> ovrResult ---;

    ovr_ResetPerfStats :: proc(session: ovrSession) -> ovrResult ---;

    ovr_GetPredictedDisplayTime :: proc(session: ovrSession, frameIndex: i64) -> f64 ---;

    ovr_GetTimeInSeconds :: proc() -> f64 ---;
}

ovrPerfHudMode :: enum i32 {
    ovrPerfHud_Off                = 0,  ///< Turns off the performance HUD
    ovrPerfHud_PerfSummary        = 1,  ///< Shows performance summary and headroom
    ovrPerfHud_LatencyTiming      = 2,  ///< Shows latency related timing info
    ovrPerfHud_AppRenderTiming    = 3,  ///< Shows render timing info for application
    ovrPerfHud_CompRenderTiming   = 4,  ///< Shows render timing info for OVR compositor
    ovrPerfHud_AswStats           = 6,  ///< Shows Async Spacewarp-specific info
    ovrPerfHud_VersionInfo        = 5,  ///< Shows SDK & HMD version Info
    ovrPerfHud_Count              = 7,  ///< \internal Count of enumerated elements.
    ovrPerfHud_EnumSize = 0x7fffffff    ///< \internal Force type int32_t.
};

ovrLayerHudMode :: enum i32 {
    ovrLayerHud_Off = 0, ///< Turns off the layer HUD
    ovrLayerHud_Info = 1, ///< Shows info about a specific layer
    ovrLayerHud_EnumSize = 0x7fffffff
};

ovrDebugHudStereoMode :: enum i32 {
    ovrDebugHudStereo_Off                 = 0,  ///< Turns off the Stereo Debug HUD
    ovrDebugHudStereo_Quad                = 1,  ///< Renders Quad in world for Stereo Debugging
    ovrDebugHudStereo_QuadWithCrosshair   = 2,  ///< Renders Quad+crosshair in world for Stereo Debugging
    ovrDebugHudStereo_CrosshairAtInfinity = 3,  ///< Renders screen-space crosshair at infinity for Stereo Debugging
    ovrDebugHudStereo_Count,                    ///< \internal Count of enumerated elements

    ovrDebugHudStereo_EnumSize = 0x7fffffff     ///< \internal Force type int32_t
};

/// @name Mixed reality capture support

foreign ovr {
    ovr_GetExternalCameras :: proc(session: ovrSession, cameras: ^ovrExternalCamera, inoutCameraCount: ^u32) -> ovrResult ---;

    ovr_SetExternalCameraProperties :: proc(session: ovrSession, name: ^u8, intrinsics: ^ovrCameraIntrinsics, extrinsics: ^ovrCameraExtrinsics) -> ovrResult ---;
}


/// @name Property Access

foreign ovr {
    ovr_GetBool :: proc(session: ovrSession, propertyName: ^u8, defaultVal: ovrBool) -> ovrBool ---; // @WARNING: const char* to ^u8

    ovr_SetBool :: proc(session: ovrSession, propertyName: ^u8, value: ovrBool) -> ovrBool ---; // @WARNING: const char* to ^u8

    ovr_GetInt :: proc(session: ovrSession, propertyName: ^u8, defaultVal: i32) -> i32 ---;

    ovr_SetInt :: proc(session: ovrSession, propertyName: ^u8, value: i32) -> ovrBool ---;

    ovr_GetFloat :: proc(session: ovrSession, propertyName: ^u8, defaultVal: f32) -> f32 ---;

    ovr_SetFloat :: proc(session: ovrSession, propertyName: ^u8, value: f32) -> ovrBool ---;

    ovr_GetFloatArray :: proc(session: ovrSession, propertyName: ^u8, values: ^f32, valuesCapacity: u32) -> u32 ---; // @WARNING: float[] to ^f32

    ovr_SetFloatArray :: proc(session: ovrSession, propertyName: ^u8, values: ^f32, valuesSize: u32) -> ovrBool ---; // @WARNING: const float[] to ^f32

    ovr_GetString :: proc(session: ovrSession, propertyName: ^u8, defaultVal: ^u8) -> ^u8 ---;

    ovr_SetString :: proc(session: ovrSession, propertyName: ^u8, value: ^u8) -> ovrBool ---;
}


// ***** Backward compatibility #includes

// from OVR_CAPI_Util.h

ovrProjectionModifier :: enum i32 {
    ovrProjection_None = 0x00,
    ovrProjection_LeftHanded = 0x01,
    ovrProjection_FarLessThanNear = 0x02,
    ovrProjection_FarClipAtInfinity = 0x04,
    ovrProjection_ClipRangeOpenGL = 0x08,
};

ovrDetectResult :: struct #ordered #align 8 {
    IsOculusServiceRunning: ovrBool,
    IsOculusHMDConnected: ovrBool,

    pad0: [6]u8,
};

_ := compile_assert(size_of(ovrDetectResult) == 8);

ovrHapticsGenMode :: enum i32 {
    ovrHapticsGenMode_PointSample,
    ovrHapticsGenMode_Count
};

ovrAudioChannelData :: struct #ordered {
    Samples: ^f32,
    SamplesCount: i32,
    Frequency: i32,
};

ovrHapticsClip :: struct #ordered {
    Samples: rawptr,
    SamplesCount: i32,
};


when ODIN_OS == "windows" do OVR_HMD_CONNECTED_EVENT_NAME :: "OculusHMDConnected\x00";

foreign ovr {
    ovr_Detect :: proc(timeoutMilliseconds: i32) -> ovrDetectResult ---;

    ovrMatrix4f_Projection :: proc(fov: ovrFovPort, znear, zfar: f32, projectionModFlags: u32) -> ovrMatrix4f ---;

    ovrTimewarpProjectionDesc_FromProjection :: proc(projection: ovrMatrix4f, projectionModFlags: u32) -> ovrTimewarpProjectionDesc ---;

    ovrMatrix4f_OrthoSubProjection :: proc(projection: ovrMatrix4f, orthoScale: ovrVector2f, orthoDistance: f32, HmdToEyeOffsetX: f32) -> ovrMatrix4f ---;

    //ovr_CalcEyePoses_old :: proc(headPose: ovrPosef, hmdToEyeOffset: ^ovrVector3f, outEyePoses: ^ovrPosef) ---;  // THESE ARE DEPRECATED IN FAVOUR OF USING POSE INSTEAD OF VECTOR

    ovr_CalcEyePoses :: proc(headPose: ovrPosef,  HmdToEyePose: ^ovrPosef, outEyePoses: ^ovrPosef) #link_name "ovr_CalcEyePoses2" ---; // NOTE: ovr_CalcEyePoses still correspond to the old version

    //ovr_GetEyePoses_old :: proc(session: ovrSession, frameIndex: i64, latencyMarker: ovrBool, hmdToEyeOffset: ^ovrVector3f, outEyePoses: ^ovrPosef, outSensorSampleTime: ^f64) ---; // THESE ARE DEPRECATED IN FAVOUR OF USING POSE INSTEAD OF VECTOR
    
    ovr_GetEyePoses :: proc(session: ovrSession, frameIndex: i64, latencyMarker: ovrBool, hmdToEyeOffset: ^ovrPosef, outEyePoses: ^ovrPosef, outSensorSampleTime: ^f64) #link_name "ovr_GetEyePoses2" ---; // NOTE: ovr_CalcEyePoses still correspond to the old version

    ovrPosef_FlipHandedness :: proc(inPose: ^ovrPosef, outPose: ^ovrPosef) ---;

    ovr_ReadWavFromBuffer :: proc(outAudioChannel: ^ovrAudioChannelData, inputData: rawptr, dataSizeInBytes: i32, stereoChannelToUse: i32) -> ovrResult ---;

    ovr_GenHapticsFromAudioData :: proc(outHapticsClip: ^ovrHapticsClip, audioChannel: ^ovrAudioChannelData, genMode: ovrHapticsGenMode) -> ovrResult ---;

    ovr_ReleaseAudioChannelData :: proc(audioChannel: ^ovrAudioChannelData) ---;

    ovr_ReleaseHapticsClip :: proc(hapticsClip: ^ovrHapticsClip) ---;
}


// from OVR_CAPI_GL.h

foreign ovr {   
    ovr_CreateTextureSwapChainGL    :: proc(session: ovrSession, desc: ^ovrTextureSwapChainDesc, out_TextureSwapChain: ^ovrTextureSwapChain) -> ovrResult ---;

    ovr_GetTextureSwapChainBufferGL :: proc(session: ovrSession, chain: ovrTextureSwapChain, index: i32, out_TexId: ^u32) -> ovrResult ---;

    ovr_CreateMirrorTextureGL       :: proc(session: ovrSession, desc: ^ovrMirrorTextureDesc, out_MirrorTexture: ^ovrMirrorTexture) -> ovrResult ---;

    ovr_GetMirrorTextureBufferGL    :: proc(session: ovrSession, mirrorTexture: ovrMirrorTexture, out_TexId: ^u32) -> ovrResult ---;
}
