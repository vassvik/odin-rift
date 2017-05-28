#import "fmt.odin"; // println, printf
#foreign_system_library ovr "libovr.lib";



/********************************************************************************//**
\file      OVR_CAPI.h
\brief     Keys for CAPI proprty function calls
\copyright Copyright 2015 Oculus VR, LLC All Rights reserved.
************************************************************************************/

OVR_KEY_USER                 :: "User\x00";                // string
OVR_KEY_NAME                 :: "Name\x00";                // string
OVR_KEY_GENDER               :: "Gender\x00";              // string "Male", "Female", or "Unknown"
OVR_KEY_PLAYER_HEIGHT        :: "PlayerHeight\x00";        // float meters
OVR_KEY_EYE_HEIGHT           :: "EyeHeight\x00";           // float meters
OVR_KEY_NECK_TO_EYE_DISTANCE :: "NeckEyeDistance\x00";     // float[2] meters
OVR_KEY_EYE_TO_NOSE_DISTANCE :: "EyeToNoseDist\x00";       // float[2] meters

OVR_DEFAULT_GENDER :: "Unknown\x00";

OVR_DEFAULT_PLAYER_HEIGHT          : f32 : 1.778;
OVR_DEFAULT_EYE_HEIGHT             : f32 : 1.675;
OVR_DEFAULT_NECK_TO_EYE_HORIZONTAL : f32 : 0.0805;
OVR_DEFAULT_NECK_TO_EYE_VERTICAL   : f32 : 0.075;

OVR_PERF_HUD_MODE                       :: "PerfHudMode\x00";                       // int, allowed values are defined in enum ovrPerfHudMode

OVR_LAYER_HUD_MODE                      :: "LayerHudMode\x00";                      // int, allowed values are defined in enum ovrLayerHudMode
OVR_LAYER_HUD_CURRENT_LAYER             :: "LayerHudCurrentLayer\x00";              // int, The layer to show 
OVR_LAYER_HUD_SHOW_ALL_LAYERS           :: "LayerHudShowAll\x00";                   // bool, Hide other layers when the hud is enabled

OVR_DEBUG_HUD_STEREO_MODE               :: "DebugHudStereoMode\x00";                // int, allowed values are defined in enum ovrDebugHudStereoMode
OVR_DEBUG_HUD_STEREO_GUIDE_INFO_ENABLE  :: "DebugHudStereoGuideInfoEnable\x00";     // bool
OVR_DEBUG_HUD_STEREO_GUIDE_SIZE         :: "DebugHudStereoGuideSize2f\x00";         // float[2]
OVR_DEBUG_HUD_STEREO_GUIDE_POSITION     :: "DebugHudStereoGuidePosition3f\x00";     // float[3]
OVR_DEBUG_HUD_STEREO_GUIDE_YAWPITCHROLL :: "DebugHudStereoGuideYawPitchRoll3f\x00"; // float[3]
OVR_DEBUG_HUD_STEREO_GUIDE_COLOR        :: "DebugHudStereoGuideColor4f\x00";        // float[4]






/********************************************************************************//**
\file      OVR_Version.h
\brief     This header provides LibOVR version identification.
\copyright Copyright 2014-2016 Oculus VR, LLC All Rights reserved.
*************************************************************************************/

// Master version numbers
OVR_PRODUCT_VERSION :: 1;   // Product version doesn't participate in semantic versioning.
OVR_MAJOR_VERSION   :: 1;  // If you change these values then you need to also make sure to change LibOVR/Projects/Windows/LibOVR.props in parallel.
OVR_MINOR_VERSION   :: 13; // 
OVR_PATCH_VERSION   :: 0;
OVR_BUILD_NUMBER    :: 0;

// This is the ((product * 100) + major) version of the service that the DLL is compatible with.
// When we backport changes to old versions of the DLL we update the old DLLs
// to move this version number up to the latest version.
// The DLL is responsible for checking that the service is the version it supports
// and returning an appropriate error message if it has not been made compatible.
OVR_DLL_COMPATIBLE_VERSION :: 101;

OVR_FEATURE_VERSION :: 0;

/// "Major.Minor.Patch"
OVR_VERSION_STRING :: "1.13.0";

/// "Major.Minor.Patch.Build"
OVR_DETAILED_VERSION_STRING :: "1.13.0.0";

// \brief file description for version info
/// This appears in the user-visible file properties. It is intended to convey publicly
/// available additional information such as feature builds.
OVR_FILE_DESCRIPTION_STRING :: "dev build debug"; // PORT NOTE: original header has debug and release strings depending on if _DEBUG is defined





/********************************************************************************//**
\file  OVR_ErrorCode.h
\brief     This header provides LibOVR error code declarations.
\copyright Copyright 2015-2016 Oculus VR, LLC All Rights reserved.
*************************************************************************************/

/// API call results are represented at the highest level by a single ovrResult.
ovrResult  :: #type i32;


/// \brief Indicates if an ovrResult indicates success.
///
/// Some functions return additional successful values other than ovrSucces and
/// require usage of this macro to indicate successs.
///
OVR_SUCCESS :: proc(result: ovrResult) -> bool { return result >= ovrResult(ovrSuccessType.ovrSuccess); } // PORT NOTE: Changed from macro to procedure

/// \brief Indicates if an ovrResult indicates an unqualified success.
///
/// This is useful for indicating that the code intentionally wants to
/// check for result == ovrSuccess as opposed to OVR_SUCCESS(), which
/// checks for result >= ovrSuccess.
///
OVR_UNQUALIFIED_SUCCESS :: proc(result: ovrResult) -> bool { return result == ovrResult(ovrSuccessType.ovrSuccess); } // PORT NOTE: Changed from macro to procedure

/// \brief Indicates if an ovrResult indicates failure.
///
OVR_FAILURE :: proc(result: ovrResult) -> bool { return !OVR_SUCCESS(result); }

/// This is a general success result. Use OVR_SUCCESS to test for success.
ovrSuccessType :: enum i32 {
    ovrSuccess = 0,
};

// Public success types
// Success is a value greater or equal to 0, while all error types are negative values.
ovrSuccessTypes :: enum i32 {
    ovrSuccess_NotVisible        = 1000,
    ovrSuccess_BoundaryInvalid   = 1001,  ///< Boundary is invalid due to sensor change or was not setup.
    ovrSuccess_DeviceUnavailable = 1002,
}

// Public error types
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

    /* Other errors */
}


ovrErrorInfo :: struct #ordered {
    Result: ovrResult,
    ErrorString: [512]i8,
};





/********************************************************************************//**
\file      OVR_CAPI.h
\brief     C Interface to the Oculus PC SDK tracking and rendering library.
\copyright Copyright 2014 Oculus VR, LLC All Rights reserved.
************************************************************************************/

// PORT NOTE: Initial batch of defines are ignored


//-----------------------------------------------------------------------------------
// ***** ovrBool

ovrBool    :: #type i8;   ///< Boolean type
ovrTrue    :: 1;          ///< ovrBool value of false.
ovrFalse   :: 0;          ///< ovrBool value of true.


//-----------------------------------------------------------------------------------
// ***** Simple Math Structures

/// A RGBA color with normalized float components.
ovrColorf :: struct #ordered #align 4 {
    r, g, b, a: f32,
};

/// A 2D vector with integer components.
ovrVector2i :: struct #ordered #align 4 {
    x, y: i32,
};

/// A 2D size with integer components.
ovrSizei :: struct #ordered #align 4 {
    w, h: i32,
};

/// A 2D rectangle with a position and size.
/// All components are integers.
ovrRecti :: struct #ordered #align 4 {
    Pos: ovrVector2i,
    Size: ovrSizei,
};

/// A quaternion rotation.
ovrQuatf :: struct #ordered #align 4 {
    x, y, z, w: f32,
};

/// A 2D vector with float components.
ovrVector2f :: struct #ordered #align 4 {
    x, y: f32,
};

/// A 3D vector with float components.
ovrVector3f :: struct #ordered #align 4 {
    x, y, z: f32,
};

/// A 4x4 matrix with float elements.
ovrMatrix4f :: struct #ordered #align 4 {
    M: [4][4]f32,
};

/// Position and orientation together.
/// The coordinate system used is right-handed Cartesian.
ovrPosef :: struct #ordered #align 4 {
    Orientation: ovrQuatf,
    Position:    ovrVector3f,
};

/// A full pose (rigid body) configuration with first and second derivatives.
///
/// Body refers to any object for which ovrPoseStatef is providing data.
/// It can be the HMD, Touch controller, sensor or something else. The context
/// depends on the usage of the struct.
ovrPoseStatef :: struct #ordered #align 8 {
    ThePose:             ovrPosef,      ///< Position and orientation.
    AngularVelocity:     ovrVector3f,   ///< Angular velocity in radians per second.
    LinearVelocity:      ovrVector3f,   ///< Velocity in meters per second.
    AngularAcceleration: ovrVector3f,   ///< Angular acceleration in radians per second per second.
    LinearAcceleration:  ovrVector3f,   ///< Acceleration in meters per second per second.
    pad0:                [4]i8,         ///< \internal struct pad.
    TimeInSeconds:       f64,           ///< Absolute time that this pose refers to. \see ovr_GetTimeInSeconds
};

/// Describes the up, down, left, and right angles of the field of view.
///
/// Field Of View (FOV) tangent of the angle units.
/// \note For a standard 90 degree vertical FOV, we would
/// have: { UpTan = tan(90 degrees / 2), DownTan = tan(90 degrees / 2) }.
ovrFovPort :: struct #ordered #align 4 {
    UpTan:    f32, ///< The tangent of the angle between the viewing vector and the top edge of the field of view.
    DownTan:  f32, ///< The tangent of the angle between the viewing vector and the bottom edge of the field of view.
    LeftTan:  f32, ///< The tangent of the angle between the viewing vector and the left edge of the field of view.
    RightTan: f32, ///< The tangent of the angle between the viewing vector and the right edge of the field of view.    
};


//-----------------------------------------------------------------------------------
// ***** HMD Types

/// Enumerates all HMD types that we support.
///
/// The currently released developer kits are ovrHmd_DK1 and ovrHmd_DK2. The other enumerations are for internal use only.
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


/// HMD capability bits reported by device.
///
ovrHmdCaps :: enum i32 {
    // Read-only flags
    ovrHmdCap_DebugDevice             = 0x0010,   ///< <B>(read only)</B> Specifies that the HMD is a virtual debug device.


    ovrHmdCap_EnumSize            = 0x7fffffff ///< \internal Force type int32_t.
};


/// Tracking capability bits reported by the device.
/// Used with ovr_GetTrackingCaps.
ovrTrackingCaps :: enum i32 {
    ovrTrackingCap_Orientation      = 0x0010,    ///< Supports orientation tracking (IMU).
    ovrTrackingCap_MagYawCorrection = 0x0020,    ///< Supports yaw drift correction via a magnetometer or other means.
    ovrTrackingCap_Position         = 0x0040,    ///< Supports positional tracking.
    ovrTrackingCap_EnumSize         = 0x7fffffff ///< \internal Force type int32_t.
};


/// Specifies which eye is being used for rendering.
/// This type explicitly does not include a third "NoStereo" monoscopic option, as such is
/// not required for an HMD-centered API.
ovrEyeType :: enum i32 {
    ovrEye_Left     = 0,         ///< The left eye, from the viewer's perspective.
    ovrEye_Right    = 1,         ///< The right eye, from the viewer's perspective.
    ovrEye_Count    = 2,         ///< \internal Count of enumerated elements.
    ovrEye_EnumSize = 0x7fffffff ///< \internal Force type int32_t.
};

/// Specifies the coordinate system ovrTrackingState returns tracking poses in.
/// Used with ovr_SetTrackingOriginType()
ovrTrackingOrigin :: enum i32 {
    /// \brief Tracking system origin reported at eye (HMD) height
    /// \details Prefer using this origin when your application requires
    /// matching user's current physical head pose to a virtual head pose
    /// without any regards to a the height of the floor. Cockpit-based,
    /// or 3rd-person experiences are ideal candidates.
    /// When used, all poses in ovrTrackingState are reported as an offset
    /// transform from the profile calibrated or recentered HMD pose.
    /// It is recommended that apps using this origin type call ovr_RecenterTrackingOrigin
    /// prior to starting the VR experience, but notify the user before doing so
    /// to make sure the user is in a comfortable pose, facing a comfortable
    /// direction.
    ovrTrackingOrigin_EyeLevel = 0,
    
    /// \brief Tracking system origin reported at floor height
    /// \details Prefer using this origin when your application requires the
    /// physical floor height to match the virtual floor height, such as
    /// standing experiences.
    /// When used, all poses in ovrTrackingState are reported as an offset
    /// transform from the profile calibrated floor pose. Calling ovr_RecenterTrackingOrigin
    /// will recenter the X & Z axes as well as yaw, but the Y-axis (i.e. height) will continue
    /// to be reported using the floor height as the origin for all poses.
    ovrTrackingOrigin_FloorLevel = 1,
    
    ovrTrackingOrigin_Count = 2,            ///< \internal Count of enumerated elements.
    ovrTrackingOrigin_EnumSize = 0x7fffffff ///< \internal Force type int32_t.
};

/// Identifies a graphics device in a platform-specific way.
/// For Windows this is a LUID type.
ovrGraphicsLuid :: struct #ordered #align 8 {
    // Public definition reserves space for graphics API-specific implementation
    Reserved : [8]i8
};

/// This is a complete descriptor of the HMD.
ovrHmdDesc :: struct #ordered #align 8 {
    Type:                  ovrHmdType                            ///< The type of HMD.
    pad0:                  [4]i8,                                ///< \internal struct paddding.
    ProductName:           [64]i8,                               ///< UTF8-encoded product identification string (e.g. "Oculus Rift DK1").
    Manufacturer:          [64]i8,                               ///< UTF8-encoded HMD manufacturer identification string.
    VendorId:              i16,                                  ///< HID (USB) vendor identifier of the device.
    ProductId:             i16,                                  ///< HID (USB) product identifier of the device.
    SerialNumber:          [24]i8,                               ///< HMD serial number.
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
    pad1:                  [4]i8,                                ///< \internal struct paddding.
};


ovrSession :: #type ^struct {};



/// Bit flags describing the current status of sensor tracking.
///  The values must be the same as in enum StatusBits
///
/// \see ovrTrackingState
///
ovrStatusBits :: enum i32 {
    ovrStatus_OrientationTracked    = 0x0001,    ///< Orientation is currently tracked (connected and in use).
    ovrStatus_PositionTracked       = 0x0002,    ///< Position is currently tracked (false if out of range).
    ovrStatus_EnumSize              = 0x7fffffff ///< \internal Force type int32_t.
};


///  Specifies the description of a single sensor.
///
/// \see ovr_GetTrackerDesc
///
ovrTrackerDesc :: struct #ordered #align 8 {
    FrustumHFovInRadians: f32,      ///< Sensor frustum horizontal field-of-view (if present).
    FrustumVFovInRadians: f32,      ///< Sensor frustum vertical field-of-view (if present).
    FrustumNearZInMeters: f32,      ///< Sensor frustum near Z (if present).
    FrustumFarZInMeters: f32,       ///< Sensor frustum far Z (if present).
};


///  Specifies sensor flags.
///
///  /see ovrTrackerPose
///
ovrTrackerFlags :: enum i32 {
    ovrTracker_Connected   = 0x0020,      ///< The sensor is present, else the sensor is absent or offline.
    ovrTracker_PoseTracked = 0x0004       ///< The sensor has a valid pose, else the pose is unavailable. This will only be set if ovrTracker_Connected is set.
};


///  Specifies the pose for a single sensor.
///
ovrTrackerPose :: struct #ordered #align 8 {
    TrackerFlags: u32,      ///< ovrTrackerFlags.
    Pose: ovrPosef,         ///< The sensor's pose. This pose includes sensor tilt (roll and pitch). For a leveled coordinate system use LeveledPose.
    LeveledPose: ovrPosef,  ///< The sensor's leveled pose, aligned with gravity. This value includes position and yaw of the sensor, but not roll and pitch. It can be used as a reference point to render real-world objects in the correct location.
    pad0: [4]i8,            ///< \internal struct pad.
};


/// Tracking state at a given absolute time (describes predicted HMD pose, etc.).
/// Returned by ovr_GetTrackingState.
///
/// \see ovr_GetTrackingState
///
ovrTrackingState :: struct #ordered #align 8 {
    /// Predicted head pose (and derivatives) at the requested absolute time.
    HeadPose:         ovrPoseStatef,

    /// HeadPose tracking status described by ovrStatusBits.
    StatusFlags:      u32,

    /// The most recent calculated pose for each hand when hand controller tracking is present.
    /// HandPoses[ovrHand_Left] refers to the left hand and HandPoses[ovrHand_Right] to the right hand.
    /// These values can be combined with ovrInputState for complete hand controller information.
    HandPoses:         [2]ovrPoseStatef,

    /// HandPoses status flags described by ovrStatusBits.
    /// Only ovrStatus_OrientationTracked and ovrStatus_PositionTracked are reported.
    HandStatusFlags:  [2]u32,

    /// The pose of the origin captured during calibration.
    /// Like all other poses here, this is expressed in the space set by ovr_RecenterTrackingOrigin,
    /// or ovr_SpecifyTrackingOrigin and so will change every time either of those functions are called.
    /// This pose can be used to calculate where the calibrated origin lands in the new recentered space.
    /// If an application never calls ovr_RecenterTrackingOrigin or ovr_SpecifyTrackingOrigin, expect
    /// this value to be the identity pose and as such will point respective origin based on
    /// ovrTrackingOrigin requested when calling ovr_GetTrackingState.
    CalibratedOrigin: ovrPosef,
};



/// Rendering information for each eye. Computed by ovr_GetRenderDesc() based on the
/// specified FOV. Note that the rendering viewport is not included
/// here as it can be specified separately and modified per frame by
/// passing different Viewport values in the layer structure.
///
/// \see ovr_GetRenderDesc
///
ovrEyeRenderDesc :: struct #ordered #align 4 {
    Eye: ovrEyeType,                         ///< The eye index to which this instance corresponds.
    Fov: ovrFovPort,                         ///< The field of view.
    DistortedViewport: ovrRecti,             ///< Distortion viewport.
    PixelsPerTanAngleAtCenter: ovrVector2f,  ///< How many display pixels will fit in tan(angle) = 1.
    HmdToEyeOffset: ovrVector3f,             ///< Translation of each eye, in meters.
};


/// Projection information for ovrLayerEyeFovDepth.
///
/// Use the utility function ovrTimewarpProjectionDesc_FromProjection to
/// generate this structure from the application's projection matrix.
///
/// \see ovrLayerEyeFovDepth, ovrTimewarpProjectionDesc_FromProjection
///
ovrTimewarpProjectionDesc :: struct #ordered #align 4 {
    Projection22: f32,     ///< Projection matrix element [2][2].
    Projection23: f32,     ///< Projection matrix element [2][3].
    Projection32: f32,     ///< Projection matrix element [3][2].
};


/// Contains the data necessary to properly calculate position info for various layer types.
/// - HmdToEyeOffset is the same value pair provided in ovrEyeRenderDesc.
/// - HmdSpaceToWorldScaleInMeters is used to scale player motion into in-application units.
///   In other words, it is how big an in-application unit is in the player's physical meters.
///   For example, if the application uses inches as its units then HmdSpaceToWorldScaleInMeters would be 0.0254.
///   Note that if you are scaling the player in size, this must also scale. So if your application
///   units are inches, but you're shrinking the player to half their normal size, then
///   HmdSpaceToWorldScaleInMeters would be 0.0254*2.0.
///
/// \see ovrEyeRenderDesc, ovr_SubmitFrame
///
ovrViewScaleDesc :: struct #ordered #align 4 {
    HmdToEyeOffset:               [ovrEyeType.ovrEye_Count]ovrVector3f,   ///< Translation of each eye.
    HmdSpaceToWorldScaleInMeters: f32,                                    ///< Ratio of viewer units to meter units.
};


//-----------------------------------------------------------------------------------
// ***** Platform-independent Rendering Configuration

/// The type of texture resource.
///
/// \see ovrTextureSwapChainDesc
///
ovrTextureType :: enum i32 {
    ovrTexture_2D,              ///< 2D textures.
    ovrTexture_2D_External,     ///< External 2D texture. Not used on PC
    ovrTexture_Cube,            ///< Cube maps. Not currently supported on PC.
    ovrTexture_Count,
    ovrTexture_EnumSize = 0x7fffffff  ///< \internal Force type int32_t.
};

/// The bindings required for texture swap chain.
///
/// All texture swap chains are automatically bindable as shader
/// input resources since the Oculus runtime needs this to read them.
///
/// \see ovrTextureSwapChainDesc
///
ovrTextureBindFlags :: enum i32 {
    ovrTextureBind_None,
    ovrTextureBind_DX_RenderTarget = 0x0001,    ///< The application can write into the chain with pixel shader
    ovrTextureBind_DX_UnorderedAccess = 0x0002, ///< The application can write to the chain with compute shader
    ovrTextureBind_DX_DepthStencil = 0x0004,    ///< The chain buffers can be bound as depth and/or stencil buffers

    ovrTextureBind_EnumSize = 0x7fffffff  ///< \internal Force type int32_t.
};

/// The format of a texture.
///
/// \see ovrTextureSwapChainDesc
///
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

    // Depth formats
    OVR_FORMAT_D16_UNORM            = 11,
    OVR_FORMAT_D24_UNORM_S8_UINT    = 12,
    OVR_FORMAT_D32_FLOAT            = 13,
    OVR_FORMAT_D32_FLOAT_S8X24_UINT = 14,

    // Added in 1.5 compressed formats can be used for static layers
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

/// Misc flags overriding particular
///   behaviors of a texture swap chain
///
/// \see ovrTextureSwapChainDesc
///
ovrTextureMiscFlags :: enum i32 { // @WARNING: OVR_CAPI.h is inconsistent in typedefing the struct name
    ovrTextureMisc_None = 0x0000,

    /// DX only: The underlying texture is created with a TYPELESS equivalent of the
    /// format specified in the texture desc. The SDK will still access the
    /// texture using the format specified in the texture desc, but the app can
    /// create views with different formats if this is specified.
    ovrTextureMisc_DX_Typeless = 0x0001,

    /// DX only: Allow generation of the mip chain on the GPU via the GenerateMips
    /// call. This flag requires that RenderTarget binding also be specified.
    ovrTextureMisc_AllowGenerateMips = 0x0002,

    /// Texture swap chain contains protected content, and requires
    /// HDCP connection in order to display to HMD. Also prevents
    /// mirroring or other redirection of any frame containing this contents
    ovrTextureMisc_ProtectedContent = 0x0004,

    ovrTextureMisc_EnumSize = 0x7fffffff  ///< \internal Force type int32_t.
};

/// Description used to create a texture swap chain.
///
/// \see ovr_CreateTextureSwapChainDX
/// \see ovr_CreateTextureSwapChainGL
///
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

/// Description used to create a mirror texture.
///
/// \see ovr_CreateMirrorTextureDX
/// \see ovr_CreateMirrorTextureGL
///
ovrMirrorTextureDesc :: struct #ordered {
    Format:    ovrTextureFormat,
    Width:     i32,
    Height:    i32,
    MiscFlags: u32,              ///< ovrTextureFlags
};

ovrTextureSwapChain :: #type ^struct {};
ovrMirrorTexture :: #type ^struct {};

//-----------------------------------------------------------------------------------

/// Describes button input types.
/// Button inputs are combined; that is they will be reported as pressed if they are
/// pressed on either one of the two devices.
/// The ovrButton_Up/Down/Left/Right map to both XBox D-Pad and directional buttons.
/// The ovrButton_Enter and ovrButton_Return map to Start and Back controller buttons, respectively.
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
    
    // Bit mask of all buttons that are for private usage by Oculus
    ovrButton_Private   = ovrButton_VolUp | ovrButton_VolDown | ovrButton_Home,

    // Bit mask of all buttons on the right Touch controller
    ovrButton_RMask = ovrButton_A | ovrButton_B | ovrButton_RThumb | ovrButton_RShoulder,

    // Bit mask of all buttons on the left Touch controller
    ovrButton_LMask = ovrButton_X | ovrButton_Y | ovrButton_LThumb | ovrButton_LShoulder |
                      ovrButton_Enter,

    ovrButton_EnumSize  = 0x7fffffff ///< \internal Force type int32_t.
};

/// Describes touch input types.
/// These values map to capacitive touch values reported ovrInputState::Touch.
/// Some of these values are mapped to button bits for consistency.
ovrTouch :: enum i32 {
    ovrTouch_A              = 0x00000001, // ovrButton_A,
    ovrTouch_B              = 0x00000002, // ovrButton_B,
    ovrTouch_RThumb         = 0x00000004, // ovrButton_RThumb,
    ovrTouch_RThumbRest     = 0x00000008,
    ovrTouch_RIndexTrigger  = 0x00000010,

    // Bit mask of all the button touches on the right controller
    ovrTouch_RButtonMask    = ovrTouch_A | ovrTouch_B | ovrTouch_RThumb | ovrTouch_RThumbRest | ovrTouch_RIndexTrigger,

    ovrTouch_X              = 0x00000100, // ovrButton_X,
    ovrTouch_Y              = 0x00000200, // ovrButton_Y,
    ovrTouch_LThumb         = 0x00000400, // ovrButton_LThumb,
    ovrTouch_LThumbRest     = 0x00000800,
    ovrTouch_LIndexTrigger  = 0x00001000,

    // Bit mask of all the button touches on the left controller
    ovrTouch_LButtonMask    = ovrTouch_X | ovrTouch_Y | ovrTouch_LThumb | ovrTouch_LThumbRest | ovrTouch_LIndexTrigger,

    // Finger pose state
    // Derived internally based on distance, proximity to sensors and filtering.
    ovrTouch_RIndexPointing = 0x00000020,
    ovrTouch_RThumbUp       = 0x00000040,
    ovrTouch_LIndexPointing = 0x00002000,
    ovrTouch_LThumbUp       = 0x00004000,

    // Bit mask of all right controller poses
    ovrTouch_RPoseMask      = ovrTouch_RIndexPointing | ovrTouch_RThumbUp,

    // Bit mask of all left controller poses
    ovrTouch_LPoseMask      = ovrTouch_LIndexPointing | ovrTouch_LThumbUp,

    ovrTouch_EnumSize       = 0x7fffffff ///< \internal Force type int32_t.
};

/// Describes the Touch Haptics engine.
/// Currently, those values will NOT change during a session.
ovrTouchHapticsDesc :: struct #ordered #align 8 {
    // Haptics engine frequency/sample-rate, sample time in seconds equals 1.0/sampleRateHz
    SampleRateHz: i32,
    // Size of each Haptics sample, sample value range is [0, 2^(Bytes*8)-1]
    SampleSizeInBytes: i32,

    // Queue size that would guarantee Haptics engine would not starve for data
    // Make sure size doesn't drop below it for best results
    QueueMinSizeToAvoidStarvation: i32,

    // Minimum, Maximum and Optimal number of samples that can be sent to Haptics through ovr_SubmitControllerVibration
    SubmitMinSamples: i32,
    SubmitMaxSamples: i32,
    SubmitOptimalSamples: i32,
};

/// Specifies which controller is connected; multiple can be connected at once.
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

/// Haptics buffer submit mode
ovrHapticsBufferSubmitMode :: enum i32 {
    // Enqueue buffer for later playback
    ovrHapticsBufferSubmit_Enqueue = 0x0, // @WARNING: unset in OVR_CAPI.h
};

/// Haptics buffer descriptor, contains amplitude samples used for Touch vibration
ovrHapticsBuffer :: struct #ordered {
    /// Samples stored in opaque format
    Samples: rawptr, // @WARNING: const void* 
    /// Number of samples
    SamplesCount: i32,
    /// How samples are submitted to the hardware
    SubmitMode: ovrHapticsBufferSubmitMode,
};

/// State of the Haptics playback for Touch vibration
ovrHapticsPlaybackState :: struct #ordered {
    // Remaining space available to queue more samples
    RemainingQueueSpace: i32,

    // Number of samples currently queued
    SamplesQueued: i32,
};

/// Position tracked devices
ovrTrackedDeviceType :: enum i32 {
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

/// Boundary types that specified while using the boundary system
ovrBoundaryType :: enum i32 {
    // Outer boundary - closely represents user setup walls
    ovrBoundary_Outer           = 0x0001,

    // Play area - safe rectangular area inside outer boundary which can optionally be used to restrict user interactions and motion.
    ovrBoundary_PlayArea        = 0x0100,
};

/// Boundary system look and feel
ovrBoundaryLookAndFeel :: struct #ordered {
    // Boundary color (alpha channel is ignored)
    Color: ovrColorf,
};

/// Provides boundary test information
ovrBoundaryTestResult :: struct #ordered {
    // True if the boundary system is being triggered. Note that due to fade in/out effects this may not exactly match visibility.
    IsTriggering: ovrBool,
    
    // Distance to the closest play area or outer boundary surface.
    ClosestDistance: f32,
    
    // Closest point on the boundary surface.
    ClosestPoint: ovrVector3f,
    
    // Unit surface normal of the closest boundary surface.
    ClosestPointNormal: ovrVector3f,
};

/// Provides names for the left and right hand array indexes.
///
/// \see ovrInputState, ovrTrackingState
///
ovrHandType :: enum i32 {
    ovrHand_Left  = 0,
    ovrHand_Right = 1,
    ovrHand_Count = 2,
    ovrHand_EnumSize = 0x7fffffff ///< \internal Force type int32_t.
};



/// ovrInputState describes the complete controller input state, including Oculus Touch,
/// and XBox gamepad. If multiple inputs are connected and used at the same time,
/// their inputs are combined.
ovrInputState :: struct #ordered {
    /// System type when the controller state was last updated.
    TimeInSeconds: f64,

    /// Values for buttons described by ovrButton.
    Buttons: u32,

    /// Touch values for buttons and sensors as described by ovrTouch.
    Touches: u32,

    /// Left and right finger trigger values (ovrHand_Left and ovrHand_Right), in the range 0.0 to 1.0f.
    /// Returns 0 if the value would otherwise be less than 0.1176, for ovrControllerType_XBox.
    /// This has been formally named simply "Trigger". We retain the name IndexTrigger for backwards code compatibility.
    /// User-facing documentation should refer to it as the Trigger.
    IndexTrigger: [ovrHandType.ovrHand_Count]f32,

    /// Left and right hand trigger values (ovrHand_Left and ovrHand_Right), in the range 0.0 to 1.0f.
    /// This has been formally named "Grip Button". We retain the name HandTrigger for backwards code compatibility.
    /// User-facing documentation should refer to it as the Grip Button or simply Grip.
    HandTrigger: [ovrHandType.ovrHand_Count]f32,

    /// Horizontal and vertical thumbstick axis values (ovrHand_Left and ovrHand_Right), in the range -1.0f to 1.0f.
    /// Returns a deadzone (value 0) per each axis if the value on that axis would otherwise have been between -.2746 to +.2746, for ovrControllerType_XBox
    Thumbstick: [ovrHandType.ovrHand_Count]ovrVector2f,

    /// The type of the controller this state is for.
    ControllerType: ovrControllerType,

    /// Left and right finger trigger values (ovrHand_Left and ovrHand_Right), in the range 0.0 to 1.0f.
    /// Does not apply a deadzone.  Only touch applies a filter.
    /// This has been formally named simply "Trigger". We retain the name IndexTrigger for backwards code compatibility.
    /// User-facing documentation should refer to it as the Trigger.
    /// Added in 1.7
    IndexTriggerNoDeadzone: [ovrHandType.ovrHand_Count]f32,

    /// Left and right hand trigger values (ovrHand_Left and ovrHand_Right), in the range 0.0 to 1.0f.
    /// Does not apply a deadzone. Only touch applies a filter.
    /// This has been formally named "Grip Button". We retain the name HandTrigger for backwards code compatibility.
    /// User-facing documentation should refer to it as the Grip Button or simply Grip.
    /// Added in 1.7
    HandTriggerNoDeadzone: [ovrHandType.ovrHand_Count]f32,

    /// Horizontal and vertical thumbstick axis values (ovrHand_Left and ovrHand_Right), in the range -1.0f to 1.0f
    /// Does not apply a deadzone or filter.
    /// Added in 1.7
    ThumbstickNoDeadzone: [ovrHandType.ovrHand_Count]ovrVector2f,

    /// Left and right finger trigger values (ovrHand_Left and ovrHand_Right), in the range 0.0 to 1.0f.
    /// No deadzone or filter
    /// This has been formally named "Grip Button". We retain the name HandTrigger for backwards code compatibility.
    /// User-facing documentation should refer to it as the Grip Button or simply Grip.
    /// Added in 1.11
    IndexTriggerRaw: [ovrHandType.ovrHand_Count]f32,

    /// Left and right hand trigger values (ovrHand_Left and ovrHand_Right), in the range 0.0 to 1.0f.
    /// No deadzone or filter
    /// This has been formally named "Grip Button". We retain the name HandTrigger for backwards code compatibility.
    /// User-facing documentation should refer to it as the Grip Button or simply Grip.
    /// Added in 1.11
    HandTriggerRaw: [ovrHandType.ovrHand_Count]f32,

    /// Horizontal and vertical thumbstick axis values (ovrHand_Left and ovrHand_Right), in the range -1.0f to 1.0f
    /// No deadzone or filter
    /// Added in 1.11
    ThumbstickRaw: [ovrHandType.ovrHand_Count]ovrVector2f,
};



//-----------------------------------------------------------------------------------
// ***** Initialize structures

/// Initialization flags.
///
/// \see ovrInitParams, ovr_Initialize
///
ovrInitFlags :: enum i32 {
    /// When a debug library is requested, a slower debugging version of the library will
    /// run which can be used to help solve problems in the library and debug application code.
    ovrInit_Debug          = 0x00000001,


    /// When a version is requested, the LibOVR runtime respects the RequestedMinorVersion
    /// field and verifies that the RequestedMinorVersion is supported. Normally when you 
    /// specify this flag you simply use OVR_MINOR_VERSION for ovrInitParams::RequestedMinorVersion,
    /// though you could use a lower version than OVR_MINOR_VERSION to specify previous 
    /// version behavior.
    ovrInit_RequestVersion = 0x00000004,


    /// This client will not be visible in the HMD.
    /// Typically set by diagnostic or debugging utilities.
    ovrInit_Invisible      = 0x00000010,

    /// This client will alternate between VR and 2D rendering.
    /// Typically set by game engine editors and VR-enabled web browsers.
    ovrInit_MixedRendering = 0x00000020,

    



    /// These bits are writable by user code.
    ovrinit_WritableBits   = 0x00ffffff,

    ovrInit_EnumSize       = 0x7fffffff ///< \internal Force type int32_t.
};


/// Logging levels
///
/// \see ovrInitParams, ovrLogCallback
///
ovrLogLevel :: enum i32 {
    ovrLogLevel_Debug    = 0, ///< Debug-level log event.
    ovrLogLevel_Info     = 1, ///< Info-level log event.
    ovrLogLevel_Error    = 2, ///< Error-level log event.

    ovrLogLevel_EnumSize = 0x7fffffff ///< \internal Force type int32_t.
};


/// Signature of the logging callback function pointer type.
///
/// \param[in] userData is an arbitrary value specified by the user of ovrInitParams.
/// \param[in] level is one of the ovrLogLevel constants.
/// \param[in] message is a UTF8-encoded null-terminated string.
/// \see ovrInitParams, ovrLogLevel, ovr_Initialize
///
ovrLogCallback :: #type proc(userData: uint, level: i32, message: ^byte) #cc_c; // @WARNING: message was initially const char* in OVR_CAPI.h


/// Parameters for ovr_Initialize.
///
/// \see ovr_Initialize
///
ovrInitParams :: struct #ordered #align 8 {
    /// Flags from ovrInitFlags to override default behavior.
    /// Use 0 for the defaults.
    Flags:                 u32,

    /// Requests a specific minor version of the LibOVR runtime.
    /// Flags must include ovrInit_RequestVersion or this will be ignored and OVR_MINOR_VERSION 
    /// will be used. If you are directly calling the LibOVRRT version of ovr_Initialize
    /// in the LibOVRRT DLL then this must be valid and include ovrInit_RequestVersion.
    RequestedMinorVersion: u32,

    /// User-supplied log callback function, which may be called at any time
    /// asynchronously from multiple threads until ovr_Shutdown completes.
    /// Use NULL to specify no log callback.
    LogCallback:           ovrLogCallback,

    /// User-supplied data which is passed as-is to LogCallback. Typically this
    /// is used to store an application-specific pointer which is read in the
    /// callback function.
    UserData:              uint,

    /// Relative number of milliseconds to wait for a connection to the server
    /// before failing. Use 0 for the default timeout.
    ConnectionTimeoutMS:   u32,

    pad0:                  [4]i8, ///< \internal

};




// -----------------------------------------------------------------------------------
// ***** API Interfaces

/// Initializes LibOVR
///
/// Initialize LibOVR for application usage. This includes finding and loading the LibOVRRT
/// shared library. No LibOVR API functions, other than ovr_GetLastErrorInfo and ovr_Detect, can
/// be called unless ovr_Initialize succeeds. A successful call to ovr_Initialize must be eventually
/// followed by a call to ovr_Shutdown. ovr_Initialize calls are idempotent.
/// Calling ovr_Initialize twice does not require two matching calls to ovr_Shutdown.
/// If already initialized, the return value is ovr_Success.
///
/// LibOVRRT shared library search order:
///      -# Current working directory (often the same as the application directory).
///      -# Module directory (usually the same as the application directory,
///         but not if the module is a separate shared library).
///      -# Application directory
///      -# Development directory (only if OVR_ENABLE_DEVELOPER_SEARCH is enabled,
///         which is off by default).
///      -# Standard OS shared library search location(s) (OS-specific).
///
/// \param params Specifies custom initialization options. May be NULL to indicate default options when
///        using the CAPI shim. If you are directly calling the LibOVRRT version of ovr_Initialize
//         in the LibOVRRT DLL then this must be valid and include ovrInit_RequestVersion.
/// \return Returns an ovrResult indicating success or failure. In the case of failure, use
///         ovr_GetLastErrorInfo to get more information. Example failed results include:
///     - ovrError_Initialize: Generic initialization error.
///     - ovrError_LibLoad: Couldn't load LibOVRRT.
///     - ovrError_LibVersion: LibOVRRT version incompatibility.
///     - ovrError_ServiceConnection: Couldn't connect to the OVR Service.
///     - ovrError_ServiceVersion: OVR Service version incompatibility.
///     - ovrError_IncompatibleOS: The operating system version is incompatible.
///     - ovrError_DisplayInit: Unable to initialize the HMD display.
///     - ovrError_ServerStart:  Unable to start the server. Is it already running?
///     - ovrError_Reinitialization: Attempted to re-initialize with a different version.
///
/// <b>Example code</b>
///     \code{.cpp}
///         ovrInitParams initParams = { ovrInit_RequestVersion, OVR_MINOR_VERSION, NULL, 0, 0 };
///         ovrResult result = ovr_Initialize(&initParams);
///         if(OVR_FAILURE(result)) {
///             ovrErrorInfo errorInfo;
///             ovr_GetLastErrorInfo(&errorInfo);
///             DebugLog("ovr_Initialize failed: %s", errorInfo.ErrorString);
///             return false;
///         }
///         [...]
///     \endcode
///
/// \see ovr_Shutdown
///
// @ORIGINAL: OVR_PUBLIC_FUNCTION(ovrResult) ovr_Initialize(const ovrInitParams* params);
ovr_Initialize :: proc(params: ^ovrInitParams) -> ovrResult #foreign ovr "ovr_Initialize";


/// Shuts down LibOVR
///
/// A successful call to ovr_Initialize must be eventually matched by a call to ovr_Shutdown.
/// After calling ovr_Shutdown, no LibOVR functions can be called except ovr_GetLastErrorInfo
/// or another ovr_Initialize. ovr_Shutdown invalidates all pointers, references, and created objects
/// previously returned by LibOVR functions. The LibOVRRT shared library can be unloaded by
/// ovr_Shutdown.
///
/// \see ovr_Initialize
///
// @ORIGINAL: OVR_PUBLIC_FUNCTION(void) ovr_Shutdown();
ovr_Shutdown :: proc() #foreign ovr "ovr_Shutdown";

/// Returns information about the most recent failed return value by the
/// current thread for this library.
///
/// This function itself can never generate an error.
/// The last error is never cleared by LibOVR, but will be overwritten by new errors.
/// Do not use this call to determine if there was an error in the last API
/// call as successful API calls don't clear the last ovrErrorInfo.
/// To avoid any inconsistency, ovr_GetLastErrorInfo should be called immediately
/// after an API function that returned a failed ovrResult, with no other API
/// functions called in the interim.
///
/// \param[out] errorInfo The last ovrErrorInfo for the current thread.
///
/// \see ovrErrorInfo
///
// @ORIGINAL: OVR_PUBLIC_FUNCTION(void) ovr_GetLastErrorInfo(ovrErrorInfo* errorInfo);
ovr_GetLastErrorInfo :: proc(errorInfo: ^ovrErrorInfo) #foreign ovr "ovr_GetLastErrorInfo";


/// Returns the version string representing the LibOVRRT version.
///
/// The returned string pointer is valid until the next call to ovr_Shutdown.
///
/// Note that the returned version string doesn't necessarily match the current
/// OVR_MAJOR_VERSION, etc., as the returned string refers to the LibOVRRT shared
/// library version and not the locally compiled interface version.
///
/// The format of this string is subject to change in future versions and its contents
/// should not be interpreted.
///
/// \return Returns a UTF8-encoded null-terminated version string.
///
// @ORIGINAL: OVR_PUBLIC_FUNCTION(const char*) ovr_GetVersionString();
ovr_GetVersionString :: proc() -> ^byte #foreign ovr "ovr_GetVersionString"; // @WARNING: returns const char* in OVR_CAPI.h


/// Writes a message string to the LibOVR tracing mechanism (if enabled).
///
/// This message will be passed back to the application via the ovrLogCallback if
/// it was registered.
///
/// \param[in] level One of the ovrLogLevel constants.
/// \param[in] message A UTF8-encoded null-terminated string.
/// \return returns the strlen of the message or a negative value if the message is too large.
///
/// \see ovrLogLevel, ovrLogCallback
///
// @ORIGINAL: OVR_PUBLIC_FUNCTION(int) ovr_TraceMessage(int level, const char* message);
ovr_TraceMessage :: proc(level: i32, message: ^byte) -> i32 #foreign ovr "ovr_TraceMessage"; // @WARNING: message originall const char* in OVR_CAPI.h


/// Identify client application info.
///
/// The string is one or more newline-delimited lines of optional info
/// indicating engine name, engine version, engine plugin name, engine plugin
/// version, engine editor. The order of the lines is not relevant. Individual
/// lines are optional. A newline is not necessary at the end of the last line.
/// Call after ovr_Initialize and before the first call to ovr_Create.
/// Each value is limited to 20 characters. Key names such as 'EngineName:'
/// 'EngineVersion:' do not count towards this limit.
///
/// \param[in] identity Specifies one or more newline-delimited lines of optional info:
///             EngineName: %s\n
///             EngineVersion: %s\n
///             EnginePluginName: %s\n
///             EnginePluginVersion: %s\n
///             EngineEditor: <boolean> ('true' or 'false')\n
///
/// <b>Example code</b>
///     \code{.cpp}
///     ovr_IdentifyClient("EngineName: Unity\n"
///                        "EngineVersion: 5.3.3\n"
///                        "EnginePluginName: OVRPlugin\n"
///                        "EnginePluginVersion: 1.2.0\n"
///                        "EngineEditor: true");
///     \endcode
///
// @ORIGINAL: OVR_PUBLIC_FUNCTION(ovrResult) ovr_IdentifyClient(const char* identity);
ovr_IdentifyClient :: proc(identify: ^byte) -> ovrResult #foreign ovr "ovr_IdentifyClient"; // @WARNING: identity originally const char* in OVR_CAPI.h


//-------------------------------------------------------------------------------------
/// @name HMD Management
///
/// Handles the enumeration, creation, destruction, and properties of an HMD (head-mounted display).
///@{


/// Returns information about the current HMD.
///
/// ovr_Initialize must have first been called in order for this to succeed, otherwise ovrHmdDesc::Type
/// will be reported as ovrHmd_None.
///
/// \param[in] session Specifies an ovrSession previously returned by ovr_Create, else NULL in which
///                case this function detects whether an HMD is present and returns its info if so.
///
/// \return Returns an ovrHmdDesc. If the hmd is NULL and ovrHmdDesc::Type is ovrHmd_None then
///         no HMD is present.
///
// @ORIGINAL: OVR_PUBLIC_FUNCTION(ovrHmdDesc) ovr_GetHmdDesc(ovrSession session);
ovr_GetHmdDesc :: proc(session: ovrSession) -> ovrHmdDesc #foreign ovr "ovr_GetHmdDesc";


/// Returns the number of attached trackers.
///
/// The number of trackers may change at any time, so this function should be called before use
/// as opposed to once on startup.
///
/// \param[in] session Specifies an ovrSession previously returned by ovr_Create.
///
/// \return Returns unsigned int count.
///
// @ORIGINAL: OVR_PUBLIC_FUNCTION(unsigned int) ovr_GetTrackerCount(ovrSession session);
ovr_GetTrackerCount :: proc(session: ovrSession) -> u32 #foreign ovr "ovr_GetTrackerCount";


/// Returns a given attached tracker description.
///
/// ovr_Initialize must have first been called in order for this to succeed, otherwise the returned
/// trackerDescArray will be zero-initialized. The data returned by this function can change at runtime.
///
/// \param[in] session Specifies an ovrSession previously returned by ovr_Create.
///
/// \param[in] trackerDescIndex Specifies a tracker index. The valid indexes are in the range of 0 to
///            the tracker count returned by ovr_GetTrackerCount.
///
/// \return Returns ovrTrackerDesc. An empty ovrTrackerDesc will be returned if trackerDescIndex is out of range.
///
/// \see ovrTrackerDesc, ovr_GetTrackerCount
///
// @ORIGINAL: OVR_PUBLIC_FUNCTION(ovrTrackerDesc) ovr_GetTrackerDesc(ovrSession session, unsigned int trackerDescIndex);
//#TrackerDeckBlob :: struct #ordered {[4]f32};
//GetTrackerDesc :: proc(...) -> TrackerBlob #foreign ...;

ovr_GetTrackerDesc :: proc(session: ovrSession, trackerDescIndex: u32) -> ovrTrackerDesc #foreign ovr "ovr_GetTrackerDesc";
//ovr_GetTrackerDesc :: proc(session: ovrSession, trackerDescIndex: u32) -> TrackerDeckBlob #foreign ovr "ovr_GetTrackerDesc";


/// Creates a handle to a VR session.
///
/// Upon success the returned ovrSession must be eventually freed with ovr_Destroy when it is no longer needed.
/// A second call to ovr_Create will result in an error return value if the previous session has not been destroyed.
///
/// \param[out] pSession Provides a pointer to an ovrSession which will be written to upon success.
/// \param[out] pLuid Provides a system specific graphics adapter identifier that locates which
/// graphics adapter has the HMD attached. This must match the adapter used by the application
/// or no rendering output will be possible. This is important for stability on multi-adapter systems. An
/// application that simply chooses the default adapter will not run reliably on multi-adapter systems.
/// \return Returns an ovrResult indicating success or failure. Upon failure
///         the returned ovrSession will be NULL.
///
/// <b>Example code</b>
///     \code{.cpp}
///         ovrSession session;
///         ovrGraphicsLuid luid;
///         ovrResult result = ovr_Create(&session, &luid);
///         if(OVR_FAILURE(result))
///            ...
///     \endcode
///
/// \see ovr_Destroy
///
// @ORIGINAL: OVR_PUBLIC_FUNCTION(ovrResult) ovr_Create(ovrSession* pSession, ovrGraphicsLuid* pLuid);
ovr_Create :: proc(pSession: ^ovrSession, pLuid: ^ovrGraphicsLuid) -> ovrResult #foreign ovr "ovr_Create";


/// Destroys the session.
///
/// \param[in] session Specifies an ovrSession previously returned by ovr_Create.
/// \see ovr_Create
///
// @ORIGINAL: OVR_PUBLIC_FUNCTION(void) ovr_Destroy(ovrSession session);
ovr_Destroy :: proc(ovrSession) #foreign ovr "ovr_Destroy";


/// Specifies status information for the current session.
///
/// \see ovr_GetSessionStatus
///
ovrSessionStatus :: struct #ordered {
    IsVisible:      ovrBool,  ///< True if the process has VR focus and thus is visible in the HMD.
    HmdPresent:     ovrBool,  ///< True if an HMD is present.
    HmdMounted:     ovrBool,  ///< True if the HMD is on the user's head.
    DisplayLost:    ovrBool,  ///< True if the session is in a display-lost state. See ovr_SubmitFrame.
    ShouldQuit:     ovrBool,  ///< True if the application should initiate shutdown.
    ShouldRecenter: ovrBool,  ///< True if UX has requested re-centering. Must call ovr_ClearShouldRecenterFlag, ovr_RecenterTrackingOrigin or ovr_SpecifyTrackingOrigin
};


/// Returns status information for the application.
///
/// \param[in] session Specifies an ovrSession previously returned by ovr_Create.
/// \param[out] sessionStatus Provides an ovrSessionStatus that is filled in.
///
/// \return Returns an ovrResult indicating success or failure. In the case of
///         failure, use ovr_GetLastErrorInfo to get more information.
//          Return values include but aren't limited to:
///     - ovrSuccess: Completed successfully.
///     - ovrError_ServiceConnection: The service connection was lost and the application
//        must destroy the session.
///
// @ORIGINAL: OVR_PUBLIC_FUNCTION(ovrResult) ovr_GetSessionStatus(ovrSession session, ovrSessionStatus* sessionStatus);
ovr_GetSessionStatus :: proc(session: ovrSession, sessionStatus: ^ovrSessionStatus) -> ovrResult #foreign ovr "ovr_GetSessionStatus";

//@}



//-------------------------------------------------------------------------------------
/// @name Tracking
///
/// Tracking functions handle the position, orientation, and movement of the HMD in space.
///
/// All tracking interface functions are thread-safe, allowing tracking state to be sampled
/// from different threads.
///
///@{



/// Sets the tracking origin type
///
/// When the tracking origin is changed, all of the calls that either provide
/// or accept ovrPosef will use the new tracking origin provided.
///
/// \param[in] session Specifies an ovrSession previously returned by ovr_Create.
/// \param[in] origin Specifies an ovrTrackingOrigin to be used for all ovrPosef
///
/// \return Returns an ovrResult indicating success or failure. In the case of failure, use
///         ovr_GetLastErrorInfo to get more information.
///
/// \see ovrTrackingOrigin, ovr_GetTrackingOriginType
// @ORIGINAL: OVR_PUBLIC_FUNCTION(ovrResult) ovr_SetTrackingOriginType(ovrSession session, ovrTrackingOrigin origin);
ovr_SetTrackingOriginType :: proc(session: ovrSession, origin: ovrTrackingOrigin) -> ovrResult #foreign ovr "ovr_SetTrackingOriginType";


/// Gets the tracking origin state
///
/// \param[in] session Specifies an ovrSession previously returned by ovr_Create.
///
/// \return Returns the ovrTrackingOrigin that was either set by default, or previous set by the application.
///
/// \see ovrTrackingOrigin, ovr_SetTrackingOriginType
// @ORIGINAL: OVR_PUBLIC_FUNCTION(ovrTrackingOrigin) ovr_GetTrackingOriginType(ovrSession session);
ovr_GetTrackingOriginType :: proc(session: ovrSession) -> ovrTrackingOrigin #foreign ovr "ovr_GetTrackingOriginType";


/// Re-centers the sensor position and orientation.
///
/// This resets the (x,y,z) positional components and the yaw orientation component of the
/// tracking space for the HMD and controllers using the HMD's current tracking pose.
/// If the caller requires some tweaks on top of the HMD's current tracking pose, consider using
/// ovr_SpecifyTrackingOrigin instead.
///
/// The roll and pitch orientation components are always determined by gravity and cannot
/// be redefined. All future tracking will report values relative to this new reference position.
/// If you are using ovrTrackerPoses then you will need to call ovr_GetTrackerPose after
/// this, because the sensor position(s) will change as a result of this.
///
/// The headset cannot be facing vertically upward or downward but rather must be roughly
/// level otherwise this function will fail with ovrError_InvalidHeadsetOrientation.
///
/// For more info, see the notes on each ovrTrackingOrigin enumeration to understand how
/// recenter will vary slightly in its behavior based on the current ovrTrackingOrigin setting.
///
/// \param[in] session Specifies an ovrSession previously returned by ovr_Create.
///
/// \return Returns an ovrResult indicating success or failure. In the case of failure, use
///         ovr_GetLastErrorInfo to get more information. Return values include but aren't limited to:
///     - ovrSuccess: Completed successfully.
///     - ovrError_InvalidHeadsetOrientation: The headset was facing an invalid direction when
///       attempting recentering, such as facing vertically.
///
/// \see ovrTrackingOrigin, ovr_GetTrackerPose, ovr_SpecifyTrackingOrigin
///
// @ORIGINAL: OVR_PUBLIC_FUNCTION(ovrResult) ovr_RecenterTrackingOrigin(ovrSession session);
ovr_RecenterTrackingOrigin :: proc(session: ovrSession) -> ovrResult #foreign ovr "ovr_RecenterTrackingOrigin";

/// Allows manually tweaking the sensor position and orientation.
///
/// This function is similar to ovr_RecenterTrackingOrigin in that it modifies the
/// (x,y,z) positional components and the yaw orientation component of the tracking space for
/// the HMD and controllers.
/// 
/// While ovr_RecenterTrackingOrigin resets the tracking origin in reference to the HMD's
/// current pose, ovr_SpecifyTrackingOrigin allows the caller to explicitly specify a transform
/// for the tracking origin. This transform is expected to be an offset to the most recent
/// recentered origin, so calling this function repeatedly with the same originPose will keep
/// nudging the recentered origin in that direction.
///
/// There are several use cases for this function. For example, if the application decides to
/// limit the yaw, or translation of the recentered pose instead of directly using the HMD pose
/// the application can query the current tracking state via ovr_GetTrackingState, and apply
/// some limitations to the HMD pose because feeding this pose back into this function.
/// Similarly, this can be used to "adjust the seating position" incrementally in apps that
/// feature seated experiences such as cockpit-based games.
///
/// This function can emulate ovr_RecenterTrackingOrigin as such:
///     ovrTrackingState ts = ovr_GetTrackingState(session, 0.0, ovrFalse);
///     ovr_SpecifyTrackingOrigin(session, ts.HeadPose.ThePose);
///
/// The roll and pitch orientation components are determined by gravity and cannot be redefined.
/// If you are using ovrTrackerPoses then you will need to call ovr_GetTrackerPose after
/// this, because the sensor position(s) will change as a result of this.
///
/// For more info, see the notes on each ovrTrackingOrigin enumeration to understand how
/// recenter will vary slightly in its behavior based on the current ovrTrackingOrigin setting.
///
/// \param[in] session Specifies an ovrSession previously returned by ovr_Create.
/// \param[in] originPose Specifies a pose that will be used to transform the current tracking origin.
///
/// \return Returns an ovrResult indicating success or failure. In the case of failure, use
///         ovr_GetLastErrorInfo to get more information. Return values include but aren't limited to:
///     - ovrSuccess: Completed successfully.
///     - ovrError_InvalidParameter: The heading direction in originPose was invalid,
///         such as facing vertically. This can happen if the caller is directly feeding the pose
///         of a position-tracked device such as an HMD or controller into this function.
///
/// \see ovrTrackingOrigin, ovr_GetTrackerPose, ovr_RecenterTrackingOrigin
///
// @ORIGINAL: OVR_PUBLIC_FUNCTION(ovrResult) ovr_SpecifyTrackingOrigin(ovrSession session, ovrPosef originPose);
ovr_SpecifyTrackingOrigin :: proc(session: ovrSession, originPose: ovrPosef) -> ovrResult #foreign ovr "ovr_SpecifyTrackingOrigin";


/// Clears the ShouldRecenter status bit in ovrSessionStatus.
///
/// Clears the ShouldRecenter status bit in ovrSessionStatus, allowing further recenter requests to be
/// detected. Since this is automatically done by ovr_RecenterTrackingOrigin and ovr_SpecifyTrackingOrigin,
/// this function only needs to be called when application is doing its own re-centering logic.
// @ORIGINAL: OVR_PUBLIC_FUNCTION(void) ovr_ClearShouldRecenterFlag(ovrSession session);
ovr_ClearShouldRecenterFlag :: proc(session: ovrSession) #foreign ovr "ovr_ClearShouldRecenterFlag";


/// Returns tracking state reading based on the specified absolute system time.
///
/// Pass an absTime value of 0.0 to request the most recent sensor reading. In this case
/// both PredictedPose and SamplePose will have the same value.
///
/// This may also be used for more refined timing of front buffer rendering logic, and so on.
/// This may be called by multiple threads.
///
/// \param[in] session Specifies an ovrSession previously returned by ovr_Create.
/// \param[in] absTime Specifies the absolute future time to predict the return
///            ovrTrackingState value. Use 0 to request the most recent tracking state.
/// \param[in] latencyMarker Specifies that this call is the point in time where
///            the "App-to-Mid-Photon" latency timer starts from. If a given ovrLayer
///            provides "SensorSampleTime", that will override the value stored here.
/// \return Returns the ovrTrackingState that is predicted for the given absTime.
///
/// \see ovrTrackingState, ovr_GetEyePoses, ovr_GetTimeInSeconds
///
// @ORIGINAL: OVR_PUBLIC_FUNCTION(ovrTrackingState) ovr_GetTrackingState(ovrSession session, double absTime, ovrBool latencyMarker);
ovr_GetTrackingState :: proc(session: ovrSession, absTime: f64, latencyMarker: ovrBool) -> ovrTrackingState #foreign ovr "ovr_GetTrackingState";




/// Returns the ovrTrackerPose for the given attached tracker.
///
/// \param[in] session Specifies an ovrSession previously returned by ovr_Create.
/// \param[in] trackerPoseIndex Index of the tracker being requested.
///
/// \return Returns the requested ovrTrackerPose. An empty ovrTrackerPose will be returned if trackerPoseIndex is out of range.
///
/// \see ovr_GetTrackerCount
///
// @ORIGINAL: OVR_PUBLIC_FUNCTION(ovrTrackerPose) ovr_GetTrackerPose(ovrSession session, unsigned int trackerPoseIndex);
ovr_GetTrackerPose :: proc(session: ovrSession, trackerPoseIndex: u32) -> ovrTrackerPose #foreign ovr "ovr_GetTrackerPose";



/// Returns the most recent input state for controllers, without positional tracking info.
///
/// \param[out] inputState Input state that will be filled in.
/// \param[in] ovrControllerType Specifies which controller the input will be returned for.
/// \return Returns ovrSuccess if the new state was successfully obtained.
///
/// \see ovrControllerType
///
// @ORIGINAL: OVR_PUBLIC_FUNCTION(ovrResult) ovr_GetInputState(ovrSession session, ovrControllerType controllerType, ovrInputState* inputState);
ovr_GetInputState :: proc(session: ovrSession, controllerType: ovrControllerType, inputState: ^ovrInputState) -> ovrResult #foreign ovr "ovr_GetInputState";


/// Returns controller types connected to the system OR'ed together.
///
/// \return A bitmask of ovrControllerTypes connected to the system.
///
/// \see ovrControllerType
///
// @ORIGINAL: OVR_PUBLIC_FUNCTION(unsigned int) ovr_GetConnectedControllerTypes(ovrSession session);
ovr_GetConnectedControllerTypes :: proc(session: ovrSession) -> u32 #foreign ovr "ovr_GetConnectedControllerTypes";

/// Gets information about Haptics engine for the specified Touch controller.
///
/// \param[in] session Specifies an ovrSession previously returned by ovr_Create.
/// \param[in] controllerType The controller to retrieve the information from.
///
/// \return Returns an ovrTouchHapticsDesc.
///
// @ORIGINAL: OVR_PUBLIC_FUNCTION(ovrTouchHapticsDesc) ovr_GetTouchHapticsDesc(ovrSession session, ovrControllerType controllerType);
ovr_GetTouchHapticsDesc :: proc(session: ovrSession, controllerType: ovrControllerType) -> ovrTouchHapticsDesc #foreign ovr "ovr_GetTouchHapticsDesc";

/// Sets constant vibration (with specified frequency and amplitude) to a controller.
/// Note: ovr_SetControllerVibration cannot be used interchangeably with ovr_SubmitControllerVibration.
///
/// This method should be called periodically, vibration lasts for a maximum of 2.5 seconds.
///
/// \param[in] session Specifies an ovrSession previously returned by ovr_Create.
/// \param[in] controllerType The controller to set the vibration to.
/// \param[in] frequency Vibration frequency. Supported values are: 0.0 (disabled), 0.5 and 1.0. Non valid values will be clamped.
/// \param[in] amplitude Vibration amplitude in the [0.0, 1.0] range.
/// \return Returns an ovrResult for which OVR_SUCCESS(result) is false upon error and true
///         upon success. Return values include but aren't limited to:
///     - ovrSuccess: The call succeeded and a result was returned.
///     - ovrSuccess_DeviceUnavailable: The call succeeded but the device referred to by controllerType is not available.
///
// @ORIGINAL: OVR_PUBLIC_FUNCTION(ovrResult) ovr_SetControllerVibration(ovrSession session, ovrControllerType controllerType, float frequency, float amplitude);
ovr_SetControllerVibration :: proc(session: ovrSession, controllerType: ovrControllerType, frequency, amplitude: f32) -> ovrResult #foreign ovr "ovr_SetControllerVibration";

/// Submits a Haptics buffer (used for vibration) to Touch (only) controllers.
/// Note: ovr_SubmitControllerVibration cannot be used interchangeably with ovr_SetControllerVibration.
///
/// \param[in] session Specifies an ovrSession previously returned by ovr_Create.
/// \param[in] controllerType Controller where the Haptics buffer will be played.
/// \param[in] buffer Haptics buffer containing amplitude samples to be played.
/// \return Returns an ovrResult for which OVR_SUCCESS(result) is false upon error and true
///         upon success. Return values include but aren't limited to:
///     - ovrSuccess: The call succeeded and a result was returned.
///     - ovrSuccess_DeviceUnavailable: The call succeeded but the device referred to by controllerType is not available.
///
/// \see ovrHapticsBuffer
///
// @ORIGINAL: OVR_PUBLIC_FUNCTION(ovrResult) ovr_SubmitControllerVibration(ovrSession session, ovrControllerType controllerType, const ovrHapticsBuffer* buffer);
ovr_SubmitControllerVibration :: proc(session: ovrSession, controllerType: ovrControllerType, buffer: ^ovrHapticsBuffer) -> ovrResult #foreign ovr "ovr_SubmitControllerVibration"; // @WARNING: const removed

/// Gets the Haptics engine playback state of a specific Touch controller.
///
/// \param[in] session Specifies an ovrSession previously returned by ovr_Create.
/// \param[in] controllerType Controller where the Haptics buffer wil be played.
/// \param[in] outState State of the haptics engine.
/// \return Returns an ovrResult for which OVR_SUCCESS(result) is false upon error and true
///         upon success. Return values include but aren't limited to:
///     - ovrSuccess: The call succeeded and a result was returned.
///     - ovrSuccess_DeviceUnavailable: The call succeeded but the device referred to by controllerType is not available.
///
/// \see ovrHapticsPlaybackState
///
// @ORIGINAL: OVR_PUBLIC_FUNCTION(ovrResult) ovr_GetControllerVibrationState(ovrSession session, ovrControllerType controllerType, ovrHapticsPlaybackState* outState);
ovr_GetControllerVibrationState :: proc(session: ovrSession, controllerType: ovrControllerType, outState: ^ovrHapticsPlaybackState) -> ovrResult #foreign ovr "ovr_GetControllerVibrationState";


/// Tests collision/proximity of position tracked devices (e.g. HMD and/or Touch) against the Boundary System.
/// Note: this method is similar to ovr_BoundaryTestPoint but can be more precise as it may take into account device acceleration/momentum.
///
/// \param[in] session Specifies an ovrSession previously returned by ovr_Create.
/// \param[in] deviceBitmask Bitmask of one or more tracked devices to test.
/// \param[in] boundaryType Must be either ovrBoundary_Outer or ovrBoundary_PlayArea.
/// \param[out] outTestResult Result of collision/proximity test, contains information such as distance and closest point.
/// \return Returns an ovrResult for which OVR_SUCCESS(result) is false upon error and true
///         upon success. Return values include but aren't limited to:
///     - ovrSuccess: The call succeeded and a result was returned.
///     - ovrSuccess_BoundaryInvalid: The call succeeded but the result is not a valid boundary due to not being set up.
///     - ovrSuccess_DeviceUnavailable: The call succeeded but the device referred to by deviceBitmask is not available.
///
/// \see ovrBoundaryTestResult
///
// @ORIGINAL: OVR_PUBLIC_FUNCTION(ovrResult) ovr_TestBoundary(ovrSession session, ovrTrackedDeviceType deviceBitmask, 
//                                                            ovrBoundaryType boundaryType, ovrBoundaryTestResult* outTestResult);
ovr_TestBoundary :: proc(session: ovrSession, deviceBitmask: ovrTrackedDeviceType, 
                         boundaryType: ovrBoundaryType, outTestResult: ^ovrBoundaryTestResult) -> ovrResult #foreign ovr "ovr_TestBoundary";

/// Tests collision/proximity of a 3D point against the Boundary System.
///
/// \param[in] session Specifies an ovrSession previously returned by ovr_Create.
/// \param[in] point 3D point to test.
/// \param[in] singleBoundaryType Must be either ovrBoundary_Outer or ovrBoundary_PlayArea to test against
/// \param[out] outTestResult Result of collision/proximity test, contains information such as distance and closest point.
/// \return Returns an ovrResult for which OVR_SUCCESS(result) is false upon error and true
///         upon success. Return values include but aren't limited to:
///     - ovrSuccess: The call succeeded and a result was returned.
///     - ovrSuccess_BoundaryInvalid: The call succeeded but the result is not a valid boundary due to not being set up.
///
/// \see ovrBoundaryTestResult
///
// @ORIGINAL: OVR_PUBLIC_FUNCTION(ovrResult) ovr_TestBoundaryPoint(ovrSession session, const ovrVector3f* point, 
//                                                                 ovrBoundaryType singleBoundaryType, ovrBoundaryTestResult* outTestResult);
ovr_TestBoundaryPoint :: proc(session: ovrSession, point: ^ovrVector3f, 
                              singleBoundaryType: ovrBoundaryType, outTestResult: ^ovrBoundaryTestResult) -> ovrResult #foreign ovr "ovr_TestBoundaryPoint"; // @WARNING: const removed

/// Sets the look and feel of the Boundary System.
///
/// \param[in] session Specifies an ovrSession previously returned by ovr_Create.
/// \param[in] lookAndFeel Look and feel parameters.
/// \return Returns ovrSuccess upon success.
/// \see ovrBoundaryLookAndFeel
///
// @ORIGINAL: OVR_PUBLIC_FUNCTION(ovrResult) ovr_SetBoundaryLookAndFeel(ovrSession session, const ovrBoundaryLookAndFeel* lookAndFeel);
ovr_SetBoundaryLookAndFeel :: proc(session: ovrSession, lookAndFeel: ^ovrBoundaryLookAndFeel) -> ovrResult #foreign ovr "ovr_SetBoundaryLookAndFeel"; // @WARNING: const removed

/// Resets the look and feel of the Boundary System to its default state.
///
/// \param[in] session Specifies an ovrSession previously returned by ovr_Create.
/// \return Returns ovrSuccess upon success.
/// \see ovrBoundaryLookAndFeel
///
// @ORIGINAL: OVR_PUBLIC_FUNCTION(ovrResult) ovr_ResetBoundaryLookAndFeel(ovrSession session);
ovr_ResetBoundaryLookAndFeel :: proc(session: ovrSession) -> ovrResult #foreign ovr "ovr_ResetBoundaryLookAndFeel";

/// Gets the geometry of the Boundary System's "play area" or "outer boundary" as 3D floor points.
///
/// \param[in] session Specifies an ovrSession previously returned by ovr_Create.
/// \param[in] boundaryType Must be either ovrBoundary_Outer or ovrBoundary_PlayArea.
/// \param[out] outFloorPoints Array of 3D points (in clockwise order) defining the boundary at floor height (can be NULL to retrieve only the number of points).
/// \param[out] outFloorPointsCount Number of 3D points returned in the array.
/// \return Returns an ovrResult for which OVR_SUCCESS(result) is false upon error and true
///         upon success. Return values include but aren't limited to:
///     - ovrSuccess: The call succeeded and a result was returned.
///     - ovrSuccess_BoundaryInvalid: The call succeeded but the result is not a valid boundary due to not being set up.
///
// @ORIGINAL: OVR_PUBLIC_FUNCTION(ovrResult) ovr_GetBoundaryGeometry(ovrSession session, ovrBoundaryType boundaryType, ovrVector3f* outFloorPoints, int* outFloorPointsCount);
ovr_GetBoundaryGeometry :: proc(session: ovrSession, boundaryType: ovrBoundaryType, outFloorPoints: ^ovrVector3f, outFloorPointsCount: ^i32) -> ovrResult #foreign ovr "ovr_GetBoundaryGeometry";

/// Gets the dimension of the Boundary System's "play area" or "outer boundary".
///
/// \param[in] session Specifies an ovrSession previously returned by ovr_Create.
/// \param[in] boundaryType Must be either ovrBoundary_Outer or ovrBoundary_PlayArea.
/// \param[out] outDimensions Dimensions of the axis aligned bounding box that encloses the area in meters (width, height and length).
/// \return Returns an ovrResult for which OVR_SUCCESS(result) is false upon error and true
///         upon success. Return values include but aren't limited to:
///     - ovrSuccess: The call succeeded and a result was returned.
///     - ovrSuccess_BoundaryInvalid: The call succeeded but the result is not a valid boundary due to not being set up.
///
// @ORIGINAL: OVR_PUBLIC_FUNCTION(ovrResult) ovr_GetBoundaryDimensions(ovrSession session, ovrBoundaryType boundaryType, ovrVector3f* outDimensions);
ovr_GetBoundaryDimensions :: proc(session: ovrSession, boundaryType: ovrBoundaryType, outDimensions: ^ovrVector3f) -> ovrResult #foreign ovr "ovr_GetBoundaryDimensions";

/// Returns if the boundary is currently visible.
/// Note: visibility is false if the user has turned off boundaries, otherwise, it's true if the app has requested 
/// boundaries to be visible or if any tracked device is currently triggering it. This may not exactly match rendering 
/// due to fade-in and fade-out effects.
///
/// \param[in] session Specifies an ovrSession previously returned by ovr_Create.
/// \param[out] outIsVisible ovrTrue, if the boundary is visible.
/// \return Returns an ovrResult for which OVR_SUCCESS(result) is false upon error and true
///         upon success. Return values include but aren't limited to:
///     - ovrSuccess: Result was successful and a result was returned.
///     - ovrSuccess_BoundaryInvalid: The call succeeded but the result is not a valid boundary due to not being set up.
///
// @ORIGINAL: OVR_PUBLIC_FUNCTION(ovrResult) ovr_GetBoundaryVisible(ovrSession session, ovrBool* outIsVisible); 
ovr_GetBoundaryVisible :: proc(session: ovrSession, outIsVisible: ^ovrBool) -> ovrResult #foreign ovr "ovr_GetBoundaryVisible";

/// Requests boundary to be visible.
///
/// \param[in] session Specifies an ovrSession previously returned by ovr_Create.
/// \param[in] visible forces the outer boundary to be visible. An application can't force it to be invisible, but can cancel its request by passing false.

/// \return Returns ovrSuccess upon success.
///
// @ORIGINAL: OVR_PUBLIC_FUNCTION(ovrResult) ovr_RequestBoundaryVisible(ovrSession session, ovrBool visible);
ovr_RequestBoundaryVisible :: proc(session: ovrSession, visible: ovrBool) -> ovrResult #foreign ovr "ovr_RequestBoundaryVisible";

///@}


//-------------------------------------------------------------------------------------
// @name Layers
//
///@{


///  Specifies the maximum number of layers supported by ovr_SubmitFrame.
///
///  /see ovr_SubmitFrame
///
// @ORIGINAL:
// enum {
//     ovrMaxLayerCount = 16
// };
ovrMaxLayerCount :: 16;

/// Describes layer types that can be passed to ovr_SubmitFrame.
/// Each layer type has an associated struct, such as ovrLayerEyeFov.
///
/// \see ovrLayerHeader
///
ovrLayerType :: enum i32 {
    ovrLayerType_Disabled       = 0,      ///< Layer is disabled.
    ovrLayerType_EyeFov         = 1,      ///< Described by ovrLayerEyeFov.
    ovrLayerType_Quad           = 3,      ///< Described by ovrLayerQuad. Previously called ovrLayerType_QuadInWorld.
    /// enum 4 used to be ovrLayerType_QuadHeadLocked. Instead, use ovrLayerType_Quad with ovrLayerFlag_HeadLocked.
    ovrLayerType_EyeMatrix      = 5,      ///< Described by ovrLayerEyeMatrix.
    ovrLayerType_EnumSize       = 0x7fffffff ///< Force type int32_t.
};


/// Identifies flags used by ovrLayerHeader and which are passed to ovr_SubmitFrame.
///
/// \see ovrLayerHeader
///
ovrLayerFlags :: enum i32 {
    /// ovrLayerFlag_HighQuality enables 4x anisotropic sampling during the composition of the layer.
    /// The benefits are mostly visible at the periphery for high-frequency & high-contrast visuals.
    /// For best results consider combining this flag with an ovrTextureSwapChain that has mipmaps and
    /// instead of using arbitrary sized textures, prefer texture sizes that are powers-of-two.
    /// Actual rendered viewport and doesn't necessarily have to fill the whole texture.
    ovrLayerFlag_HighQuality               = 0x01,

    /// ovrLayerFlag_TextureOriginAtBottomLeft: the opposite is TopLeft.
    /// Generally this is false for D3D, true for OpenGL.
    ovrLayerFlag_TextureOriginAtBottomLeft = 0x02,

    /// Mark this surface as "headlocked", which means it is specified
    /// relative to the HMD and moves with it, rather than being specified
    /// relative to sensor/torso space and remaining still while the head moves.
    /// What used to be ovrLayerType_QuadHeadLocked is now ovrLayerType_Quad plus this flag.
    /// However the flag can be applied to any layer type to achieve a similar effect.
    ovrLayerFlag_HeadLocked                = 0x04

};


/// Defines properties shared by all ovrLayer structs, such as ovrLayerEyeFov.
///
/// ovrLayerHeader is used as a base member in these larger structs.
/// This struct cannot be used by itself except for the case that Type is ovrLayerType_Disabled.
///
/// \see ovrLayerType, ovrLayerFlags
///
ovrLayerHeader :: struct #ordered #align 8 { // @WARNING: aligned to pointer size. @TODO: warning on all other align as pointer size
    Type:  ovrLayerType,   ///< Described by ovrLayerType.
    Flags: u32            ///< Described by ovrLayerFlags.
};


/// Describes a layer that specifies a monoscopic or stereoscopic view.
/// This is the kind of layer that's typically used as layer 0 to ovr_SubmitFrame,
/// as it is the kind of layer used to render a 3D stereoscopic view.
///
/// Three options exist with respect to mono/stereo texture usage:
///    - ColorTexture[0] and ColorTexture[1] contain the left and right stereo renderings, respectively.
///      Viewport[0] and Viewport[1] refer to ColorTexture[0] and ColorTexture[1], respectively.
///    - ColorTexture[0] contains both the left and right renderings, ColorTexture[1] is NULL,
///      and Viewport[0] and Viewport[1] refer to sub-rects with ColorTexture[0].
///    - ColorTexture[0] contains a single monoscopic rendering, and Viewport[0] and
///      Viewport[1] both refer to that rendering.
///
/// \see ovrTextureSwapChain, ovr_SubmitFrame
///
ovrLayerEyeFov :: struct #ordered #align 8 {  // @WARNING: aligned to pointer size.
    /// Header.Type must be ovrLayerType_EyeFov.
    Header: ovrLayerHeader,

    /// ovrTextureSwapChains for the left and right eye respectively.
    /// The second one of which can be NULL for cases described above.
    ColorTexture: [ovrEyeType.ovrEye_Count]ovrTextureSwapChain,

    /// Specifies the ColorTexture sub-rect UV coordinates.
    /// Both Viewport[0] and Viewport[1] must be valid.
    Viewport: [ovrEyeType.ovrEye_Count]ovrRecti,

    /// The viewport field of view.
    Fov: [ovrEyeType.ovrEye_Count]ovrFovPort,

    /// Specifies the position and orientation of each eye view, with the position specified in meters.
    /// RenderPose will typically be the value returned from ovr_CalcEyePoses,
    /// but can be different in special cases if a different head pose is used for rendering.
    RenderPose: [ovrEyeType.ovrEye_Count]ovrPosef,

    /// Specifies the timestamp when the source ovrPosef (used in calculating RenderPose)
    /// was sampled from the SDK. Typically retrieved by calling ovr_GetTimeInSeconds
    /// around the instant the application calls ovr_GetTrackingState
    /// The main purpose for this is to accurately track app tracking latency.
    SensorSampleTime: f64,

};




/// Describes a layer that specifies a monoscopic or stereoscopic view.
/// This uses a direct 3x4 matrix to map from view space to the UV coordinates.
/// It is essentially the same thing as ovrLayerEyeFov but using a much
/// lower level. This is mainly to provide compatibility with specific apps.
/// Unless the application really requires this flexibility, it is usually better
/// to use ovrLayerEyeFov.
///
/// Three options exist with respect to mono/stereo texture usage:
///    - ColorTexture[0] and ColorTexture[1] contain the left and right stereo renderings, respectively.
///      Viewport[0] and Viewport[1] refer to ColorTexture[0] and ColorTexture[1], respectively.
///    - ColorTexture[0] contains both the left and right renderings, ColorTexture[1] is NULL,
///      and Viewport[0] and Viewport[1] refer to sub-rects with ColorTexture[0].
///    - ColorTexture[0] contains a single monoscopic rendering, and Viewport[0] and
///      Viewport[1] both refer to that rendering.
///
/// \see ovrTextureSwapChain, ovr_SubmitFrame
///
ovrLayerEyeMatrix :: struct #ordered #align 8 {  // @WARNING: aligned to pointer size.
    /// Header.Type must be ovrLayerType_EyeMatrix.
    Header: ovrLayerHeader,

    /// ovrTextureSwapChains for the left and right eye respectively.
    /// The second one of which can be NULL for cases described above.
    ColorTexture: [ovrEyeType.ovrEye_Count]ovrTextureSwapChain,

    /// Specifies the ColorTexture sub-rect UV coordinates.
    /// Both Viewport[0] and Viewport[1] must be valid.
    Viewport: [ovrEyeType.ovrEye_Count]ovrRecti,

    /// Specifies the position and orientation of each eye view, with the position specified in meters.
    /// RenderPose will typically be the value returned from ovr_CalcEyePoses,
    /// but can be different in special cases if a different head pose is used for rendering.
    RenderPose: [ovrEyeType.ovrEye_Count]ovrPosef,

    /// Specifies the mapping from a view-space vector
    /// to a UV coordinate on the textures given above.
    /// P = (x,y,z,1)*Matrix
    /// TexU  = P.x/P.z
    /// TexV  = P.y/P.z
    Matrix: [ovrEyeType.ovrEye_Count]ovrMatrix4f,

    /// Specifies the timestamp when the source ovrPosef (used in calculating RenderPose)
    /// was sampled from the SDK. Typically retrieved by calling ovr_GetTimeInSeconds
    /// around the instant the application calls ovr_GetTrackingState
    /// The main purpose for this is to accurately track app tracking latency.
    SensorSampleTime: f64,

};





/// Describes a layer of Quad type, which is a single quad in world or viewer space.
/// It is used for ovrLayerType_Quad. This type of layer represents a single
/// object placed in the world and not a stereo view of the world itself.
///
/// A typical use of ovrLayerType_Quad is to draw a television screen in a room
/// that for some reason is more convenient to draw as a layer than as part of the main
/// view in layer 0. For example, it could implement a 3D popup GUI that is drawn at a
/// higher resolution than layer 0 to improve fidelity of the GUI.
///
/// Quad layers are visible from both sides; they are not back-face culled.
///
/// \see ovrTextureSwapChain, ovr_SubmitFrame
///
ovrLayerQuad :: struct #ordered #align 8 {  // @WARNING: aligned to pointer size.
    /// Header.Type must be ovrLayerType_Quad.
    Header: ovrLayerHeader,

    /// Contains a single image, never with any stereo view.
    ColorTexture: ovrTextureSwapChain,

    /// Specifies the ColorTexture sub-rect UV coordinates.
    Viewport: ovrRecti,

    /// Specifies the orientation and position of the center point of a Quad layer type.
    /// The supplied direction is the vector perpendicular to the quad.
    /// The position is in real-world meters (not the application's virtual world,
    /// the physical world the user is in) and is relative to the "zero" position
    /// set by ovr_RecenterTrackingOrigin unless the ovrLayerFlag_HeadLocked flag is used.
    QuadPoseCenter: ovrPosef,

    /// Width and height (respectively) of the quad in meters.
    QuadSize: ovrVector2f,

};




/// Union that combines ovrLayer types in a way that allows them
/// to be used in a polymorphic way.
ovrLayer_Union :: raw_union {
    Header: ovrLayerHeader,
    EyeFov: ovrLayerEyeFov,
    Quad:   ovrLayerQuad,
};

//@}


/// @name SDK Distortion Rendering
///
/// All of rendering functions including the configure and frame functions
/// are not thread safe. It is OK to use ConfigureRendering on one thread and handle
/// frames on another thread, but explicit synchronization must be done since
/// functions that depend on configured state are not reentrant.
///
/// These functions support rendering of distortion by the SDK.
///
//@{

/// TextureSwapChain creation is rendering API-specific.
/// ovr_CreateTextureSwapChainDX and ovr_CreateTextureSwapChainGL can be found in the
/// rendering API-specific headers, such as OVR_CAPI_D3D.h and OVR_CAPI_GL.h

/// Gets the number of buffers in an ovrTextureSwapChain.
///
/// \param[in]  session Specifies an ovrSession previously returned by ovr_Create.
/// \param[in]  chain Specifies the ovrTextureSwapChain for which the length should be retrieved.
/// \param[out] out_Length Returns the number of buffers in the specified chain.
///
/// \return Returns an ovrResult for which OVR_SUCCESS(result) is false upon error.
///
/// \see ovr_CreateTextureSwapChainDX, ovr_CreateTextureSwapChainGL
///
// @ORIGINAL: OVR_PUBLIC_FUNCTION(ovrResult) ovr_GetTextureSwapChainLength(ovrSession session, ovrTextureSwapChain chain, int* out_Length);
ovr_GetTextureSwapChainLength :: proc(session: ovrSession, chain: ovrTextureSwapChain, out_Length: ^i32) -> ovrResult #foreign ovr "ovr_GetTextureSwapChainLength";

/// Gets the current index in an ovrTextureSwapChain.
///
/// \param[in]  session Specifies an ovrSession previously returned by ovr_Create.
/// \param[in]  chain Specifies the ovrTextureSwapChain for which the index should be retrieved.
/// \param[out] out_Index Returns the current (free) index in specified chain.
///
/// \return Returns an ovrResult for which OVR_SUCCESS(result) is false upon error.
///
/// \see ovr_CreateTextureSwapChainDX, ovr_CreateTextureSwapChainGL
///
// @ORIGINAL: OVR_PUBLIC_FUNCTION(ovrResult) ovr_GetTextureSwapChainCurrentIndex(ovrSession session, ovrTextureSwapChain chain, int* out_Index);
ovr_GetTextureSwapChainCurrentIndex :: proc(session: ovrSession, chain: ovrTextureSwapChain, out_Index: ^i32) -> ovrResult #foreign ovr "ovr_GetTextureSwapChainCurrentIndex";

/// Gets the description of the buffers in an ovrTextureSwapChain
///
/// \param[in]  session Specifies an ovrSession previously returned by ovr_Create.
/// \param[in]  chain Specifies the ovrTextureSwapChain for which the description should be retrieved.
/// \param[out] out_Desc Returns the description of the specified chain.
///
/// \return Returns an ovrResult for which OVR_SUCCESS(result) is false upon error.
///
/// \see ovr_CreateTextureSwapChainDX, ovr_CreateTextureSwapChainGL
///
// @ORIGINAL: OVR_PUBLIC_FUNCTION(ovrResult) ovr_GetTextureSwapChainDesc(ovrSession session, ovrTextureSwapChain chain, ovrTextureSwapChainDesc* out_Desc);
ovr_GetTextureSwapChainDesc :: proc(session: ovrSession, chain: ovrTextureSwapChain, out_Desc: ^ovrTextureSwapChainDesc) -> ovrResult #foreign ovr "ovr_GetTextureSwapChainDesc";

/// Commits any pending changes to an ovrTextureSwapChain, and advances its current index
///
/// \param[in]  session Specifies an ovrSession previously returned by ovr_Create.
/// \param[in]  chain Specifies the ovrTextureSwapChain to commit.
///
/// \note When Commit is called, the texture at the current index is considered ready for use by the
/// runtime, and further writes to it should be avoided. The swap chain's current index is advanced,
/// providing there's room in the chain. The next time the SDK dereferences this texture swap chain,
/// it will synchronize with the app's graphics context and pick up the submitted index, opening up
/// room in the swap chain for further commits.
///
/// \return Returns an ovrResult for which OVR_SUCCESS(result) is false upon error.
///         Failures include but aren't limited to:
///     - ovrError_TextureSwapChainFull: ovr_CommitTextureSwapChain was called too many times on a texture swapchain without calling submit to use the chain.
///
/// \see ovr_CreateTextureSwapChainDX, ovr_CreateTextureSwapChainGL
///
// @ORIGINAL: OVR_PUBLIC_FUNCTION(ovrResult) ovr_CommitTextureSwapChain(ovrSession session, ovrTextureSwapChain chain);
ovr_CommitTextureSwapChain :: proc(session: ovrSession, chain: ovrTextureSwapChain) -> ovrResult #foreign ovr "ovr_CommitTextureSwapChain";

/// Destroys an ovrTextureSwapChain and frees all the resources associated with it.
///
/// \param[in] session Specifies an ovrSession previously returned by ovr_Create.
/// \param[in] chain Specifies the ovrTextureSwapChain to destroy. If it is NULL then this function has no effect.
///
/// \see ovr_CreateTextureSwapChainDX, ovr_CreateTextureSwapChainGL
///
// @ORIGINAL: OVR_PUBLIC_FUNCTION(void) ovr_DestroyTextureSwapChain(ovrSession session, ovrTextureSwapChain chain);
ovr_DestroyTextureSwapChain :: proc(session: ovrSession, chain: ovrTextureSwapChain) #foreign ovr "ovr_DestroyTextureSwapChain";


/// MirrorTexture creation is rendering API-specific.
/// ovr_CreateMirrorTextureDX and ovr_CreateMirrorTextureGL can be found in the
/// rendering API-specific headers, such as OVR_CAPI_D3D.h and OVR_CAPI_GL.h

/// Destroys a mirror texture previously created by one of the mirror texture creation functions.
///
/// \param[in] session Specifies an ovrSession previously returned by ovr_Create.
/// \param[in] mirrorTexture Specifies the ovrTexture to destroy. If it is NULL then this function has no effect.
///
/// \see ovr_CreateMirrorTextureDX, ovr_CreateMirrorTextureGL
///
// @ORIGINAL: OVR_PUBLIC_FUNCTION(void) ovr_DestroyMirrorTexture(ovrSession session, ovrMirrorTexture mirrorTexture);
ovr_DestroyMirrorTexture :: proc(session: ovrSession, mirrorTexture: ovrMirrorTexture) #foreign ovr "ovr_DestroyMirrorTexture";

/// Calculates the recommended viewport size for rendering a given eye within the HMD
/// with a given FOV cone.
///
/// Higher FOV will generally require larger textures to maintain quality.
/// Apps packing multiple eye views together on the same texture should ensure there are
/// at least 8 pixels of padding between them to prevent texture filtering and chromatic
/// aberration causing images to leak between the two eye views.
///
/// \param[in] session Specifies an ovrSession previously returned by ovr_Create.
/// \param[in] eye Specifies which eye (left or right) to calculate for.
/// \param[in] fov Specifies the ovrFovPort to use.
/// \param[in] pixelsPerDisplayPixel Specifies the ratio of the number of render target pixels
///            to display pixels at the center of distortion. 1.0 is the default value. Lower
///            values can improve performance, higher values give improved quality.
///
/// <b>Example code</b>
///     \code{.cpp}
///         ovrHmdDesc hmdDesc = ovr_GetHmdDesc(session);
///         ovrSizei eyeSizeLeft  = ovr_GetFovTextureSize(session, ovrEye_Left,  hmdDesc.DefaultEyeFov[ovrEye_Left],  1.0f);
///         ovrSizei eyeSizeRight = ovr_GetFovTextureSize(session, ovrEye_Right, hmdDesc.DefaultEyeFov[ovrEye_Right], 1.0f);
///     \endcode
///
/// \return Returns the texture width and height size.
///
// @ORIGINAL: OVR_PUBLIC_FUNCTION(ovrSizei) ovr_GetFovTextureSize(ovrSession session, ovrEyeType eye, ovrFovPort fov,
//                                                                float pixelsPerDisplayPixel);

ovr_GetFovTextureSize :: proc(session: ovrSession, eye: ovrEyeType, fov: ovrFovPort, pixelsPerDisplayPixel: f32) -> ovrSizei #foreign ovr "ovr_GetFovTextureSize";

/// Computes the distortion viewport, view adjust, and other rendering parameters for
/// the specified eye.
///
/// \param[in] session Specifies an ovrSession previously returned by ovr_Create.
/// \param[in] eyeType Specifies which eye (left or right) for which to perform calculations.
/// \param[in] fov Specifies the ovrFovPort to use.
///
/// \return Returns the computed ovrEyeRenderDesc for the given eyeType and field of view.
///
/// \see ovrEyeRenderDesc
///
// @ORIGINAL: OVR_PUBLIC_FUNCTION(ovrEyeRenderDesc) ovr_GetRenderDesc(ovrSession session,
//                                                                    ovrEyeType eyeType, ovrFovPort fov);
ovr_GetRenderDesc :: proc(session: ovrSession, eyeType: ovrEyeType, fov: ovrFovPort) -> ovrEyeRenderDesc #foreign ovr "ovr_GetRenderDesc";

/// Submits layers for distortion and display.
///
/// ovr_SubmitFrame triggers distortion and processing which might happen asynchronously.
/// The function will return when there is room in the submission queue and surfaces
/// are available. Distortion might or might not have completed.
///
/// \param[in] session Specifies an ovrSession previously returned by ovr_Create.
///
/// \param[in] frameIndex Specifies the targeted application frame index, or 0 to refer to one frame
///        after the last time ovr_SubmitFrame was called.
///
/// \param[in] viewScaleDesc Provides additional information needed only if layerPtrList contains
///        an ovrLayerType_Quad. If NULL, a default version is used based on the current configuration and a 1.0 world scale.
///
/// \param[in] layerPtrList Specifies a list of ovrLayer pointers, which can include NULL entries to
///        indicate that any previously shown layer at that index is to not be displayed.
///        Each layer header must be a part of a layer structure such as ovrLayerEyeFov or ovrLayerQuad,
///        with Header.Type identifying its type. A NULL layerPtrList entry in the array indicates the
//         absence of the given layer.
///
/// \param[in] layerCount Indicates the number of valid elements in layerPtrList. The maximum
///        supported layerCount is not currently specified, but may be specified in a future version.
///
/// - Layers are drawn in the order they are specified in the array, regardless of the layer type.
///
/// - Layers are not remembered between successive calls to ovr_SubmitFrame. A layer must be
///   specified in every call to ovr_SubmitFrame or it won't be displayed.
///
/// - If a layerPtrList entry that was specified in a previous call to ovr_SubmitFrame is
///   passed as NULL or is of type ovrLayerType_Disabled, that layer is no longer displayed.
///
/// - A layerPtrList entry can be of any layer type and multiple entries of the same layer type
///   are allowed. No layerPtrList entry may be duplicated (i.e. the same pointer as an earlier entry).
///
/// <b>Example code</b>
///     \code{.cpp}
///         ovrLayerEyeFov  layer0;
///         ovrLayerQuad    layer1;
///           ...
///         ovrLayerHeader* layers[2] = { &layer0.Header, &layer1.Header };
///         ovrResult result = ovr_SubmitFrame(session, frameIndex, nullptr, layers, 2);
///     \endcode
///
/// \return Returns an ovrResult for which OVR_SUCCESS(result) is false upon error and true
///         upon success. Return values include but aren't limited to:
///     - ovrSuccess: rendering completed successfully.
///     - ovrSuccess_NotVisible: rendering completed successfully but was not displayed on the HMD,
///       usually because another application currently has ownership of the HMD. Applications receiving
///       this result should stop rendering new content, but continue to call ovr_SubmitFrame periodically
///       until it returns a value other than ovrSuccess_NotVisible. Applications should not loop on
///       calls to ovr_SubmitFrame in order to detect visibility; instead ovr_GetSessionStatus should be used.
///       Similarly, appliations should not call ovr_SubmitFrame with zero layers to detect visibility.
///     - ovrError_DisplayLost: The session has become invalid (such as due to a device removal)
///       and the shared resources need to be released (ovr_DestroyTextureSwapChain), the session needs to
///       destroyed (ovr_Destroy) and recreated (ovr_Create), and new resources need to be created
///       (ovr_CreateTextureSwapChainXXX). The application's existing private graphics resources do not
///       need to be recreated unless the new ovr_Create call returns a different GraphicsLuid.
///     - ovrError_TextureSwapChainInvalid: The ovrTextureSwapChain is in an incomplete or inconsistent state.
///       Ensure ovr_CommitTextureSwapChain was called at least once first.
///
/// \see ovr_GetPredictedDisplayTime, ovrViewScaleDesc, ovrLayerHeader, ovr_GetSessionStatus
///
// @ORIGINAL: OVR_PUBLIC_FUNCTION(ovrResult) ovr_SubmitFrame(ovrSession session, long long frameIndex,
//                                                           const ovrViewScaleDesc* viewScaleDesc,
//                                                           ovrLayerHeader const * const * layerPtrList, unsigned int layerCount); 
ovr_SubmitFrame :: proc(session: ovrSession, frameIndex: i64, viewScaleDesc: ^ovrViewScaleDesc, layerPtrList: ^^ovrLayerHeader, layerCount: u32) -> ovrResult #foreign ovr "ovr_SubmitFrame"; // @WARNING: const removed
///@}


//-------------------------------------------------------------------------------------
/// @name Frame Timing
///
//@{

///
/// Contains the performance stats for a given SDK compositor frame
///
/// All of the int fields can be reset via the ovr_ResetPerfStats call.
///
ovrPerfStatsPerCompositorFrame :: struct #ordered #align 4 {
    ///
    /// Vsync Frame Index - increments with each HMD vertical synchronization signal (i.e. vsync or refresh rate)
    /// If the compositor drops a frame, expect this value to increment more than 1 at a time.
    ///
    HmdVsyncIndex: i32,

    ///
    /// Application stats
    ///

    /// Index that increments with each successive ovr_SubmitFrame call
    AppFrameIndex: i32,
    
    /// If the app fails to call ovr_SubmitFrame on time, then expect this value to increment with each missed frame
    AppDroppedFrameCount: i32,
    
    /// Motion-to-photon latency for the application
    /// This value is calculated by either using the SensorSampleTime provided for the ovrLayerEyeFov or if that
    /// is not available, then the call to ovr_GetTrackingState which has latencyMarker set to ovrTrue
    AppMotionToPhotonLatency: f32,
    
    /// Amount of queue-ahead in seconds provided to the app based on performance and overlap of CPU & GPU utilization
    /// A value of 0.0 would mean the CPU & GPU workload is being completed in 1 frame's worth of time, while
    /// 11 ms (on the CV1) of queue ahead would indicate that the app's CPU workload for the next frame is
    /// overlapping the app's GPU workload for the current frame.
    AppQueueAheadTime: f32,
    
    /// Amount of time in seconds spent on the CPU by the app's render-thread that calls ovr_SubmitFrame
    /// Measured as elapsed time between from when app regains control from ovr_SubmitFrame to the next time the app
    /// calls ovr_SubmitFrame.
    AppCpuElapsedTime: f32,
    
    /// Amount of time in seconds spent on the GPU by the app
    /// Measured as elapsed time between each ovr_SubmitFrame call using GPU timing queries.
    AppGpuElapsedTime: f32,

    ///
    /// SDK Compositor stats
    ///

    /// Index that increments each time the SDK compositor completes a distortion and timewarp pass
    /// Since the compositor operates asynchronously, even if the app calls ovr_SubmitFrame too late,
    /// the compositor will kick off for each vsync.
    CompositorFrameIndex: i32,
    
    /// Increments each time the SDK compositor fails to complete in time
    /// This is not tied to the app's performance, but failure to complete can be tied to other factors
    /// such as OS capabilities, overall available hardware cycles to execute the compositor in time
    /// and other factors outside of the app's control.
    CompositorDroppedFrameCount: i32,
    
    /// Motion-to-photon latency of the SDK compositor in seconds
    /// This is the latency of timewarp which corrects the higher app latency as well as dropped app frames.
    CompositorLatency: f32,
    
    /// The amount of time in seconds spent on the CPU by the SDK compositor. Unless the VR app is utilizing
    /// all of the CPU cores at their peak performance, there is a good chance the compositor CPU times
    /// will not affect the app's CPU performance in a major way.
    CompositorCpuElapsedTime: f32,
    
    /// The amount of time in seconds spent on the GPU by the SDK compositor. Any time spent on the compositor
    /// will eat away from the available GPU time for the app.
    CompositorGpuElapsedTime: f32,
    
    /// The amount of time in seconds spent from the point the CPU kicks off the compositor to the point in time
    /// the compositor completes the distortion & timewarp on the GPU. In the event the GPU time is not
    /// available, expect this value to be -1.0f
    CompositorCpuStartToGpuEndElapsedTime: f32,
    
    /// The amount of time in seconds left after the compositor is done on the GPU to the associated V-Sync time.
    /// In the event the GPU time is not available, expect this value to be -1.0f
    CompositorGpuEndToVsyncElapsedTime: f32,

    ///
    /// Async Spacewarp stats (ASW)
    ///

    /// Will be true is ASW is active for the given frame such that the application is being forced into
    /// half the frame-rate while the compositor continues to run at full frame-rate
    AswIsActive: ovrBool,

    /// Accumulates each time ASW it activated where the app was forced in and out of half-rate rendering
    AswActivatedToggleCount: i32,

    /// Accumulates the number of frames presented by the compositor which had extrapolated ASW frames presented
    AswPresentedFrameCount: i32,

    /// Accumulates the number of frames that the compositor tried to present when ASW is active but failed
    AswFailedFrameCount: i32,

};

///
/// Maximum number of frames of performance stats provided back to the caller of ovr_GetPerfStats
///
// @ORIGINAL: enum { ovrMaxProvidedFrameStats = 5 };
ovrMaxProvidedFrameStats :: 5;

///
/// This is a complete descriptor of the performance stats provided by the SDK
///
///
/// 
/// \see ovr_GetPerfStats, ovrPerfStatsPerCompositorFrame
ovrPerfStats :: struct #ordered #align 4 {
    /// FrameStatsCount will have a maximum value set by ovrMaxProvidedFrameStats
    /// If the application calls ovr_GetPerfStats at the native refresh rate of the HMD
    /// then FrameStatsCount will be 1. If the app's workload happens to force
    /// ovr_GetPerfStats to be called at a lower rate, then FrameStatsCount will be 2 or more.
    /// If the app does not want to miss any performance data for any frame, it needs to
    /// ensure that it is calling ovr_SubmitFrame and ovr_GetPerfStats at a rate that is at least:
    /// "HMD_refresh_rate / ovrMaxProvidedFrameStats". On the Oculus Rift CV1 HMD, this will
    /// be equal to 18 times per second.
    ///
    /// The performance entries will be ordered in reverse chronological order such that the
    /// first entry will be the most recent one.
    FrameStats: [ovrMaxProvidedFrameStats]ovrPerfStatsPerCompositorFrame,
    FrameStatsCount: i32,

    /// If the app calls ovr_SubmitFrame at a rate less than 18 fps, then when calling
    /// ovr_GetPerfStats, expect AnyFrameStatsDropped to become ovrTrue while FrameStatsCount
    /// is equal to ovrMaxProvidedFrameStats.
    AnyFrameStatsDropped: ovrBool,

    /// AdaptiveGpuPerformanceScale is an edge-filtered value that a caller can use to adjust
    /// the graphics quality of the application to keep the GPU utilization in check. The value
    /// is calculated as: (desired_GPU_utilization / current_GPU_utilization)
    /// As such, when this value is 1.0, the GPU is doing the right amount of work for the app.
    /// Lower values mean the app needs to pull back on the GPU utilization.
    /// If the app is going to directly drive render-target resolution using this value, then
    /// be sure to take the square-root of the value before scaling the resolution with it.
    /// Changing render target resolutions however is one of the many things an app can do
    /// increase or decrease the amount of GPU utilization.
    /// Since AdaptiveGpuPerformanceScale is edge-filtered and does not change rapidly
    /// (i.e. reports non-1.0 values once every couple of seconds) the app can make the
    /// necessary adjustments and then keep watching the value to see if it has been satisfied.
    AdaptiveGpuPerformanceScale: f32,

    /// Will be true if Async Spacewarp (ASW) is available for this system which is dependent on
    /// several factors such as choice of GPU, OS and debug overrides
    AswIsAvailable: ovrBool,
};

/// Retrieves performance stats for the VR app as well as the SDK compositor.
///
/// If the app calling this function is not the one in focus (i.e. not visible in the HMD), then
/// outStats will be zero'd out.
/// New stats are populated after each successive call to ovr_SubmitFrame. So the app should call
/// this function on the same thread it calls ovr_SubmitFrame, preferably immediately
/// afterwards.
///
/// \param[in] session Specifies an ovrSession previously returned by ovr_Create.
/// \param[out] outStats Contains the performance stats for the application and SDK compositor
/// \return Returns an ovrResult for which OVR_SUCCESS(result) is false upon error and true
///         upon success.
///
/// \see ovrPerfStats, ovrPerfStatsPerCompositorFrame, ovr_ResetPerfStats
///
// @ORIGINAL: OVR_PUBLIC_FUNCTION(ovrResult) ovr_GetPerfStats(ovrSession session, ovrPerfStats* outStats);
ovr_GetPerfStats :: proc(session: ovrSession, outStats: ^ovrPerfStats) -> ovrResult #foreign ovr "ovr_GetPerfStats";

/// Resets the accumulated stats reported in each ovrPerfStatsPerCompositorFrame back to zero.
///
/// Only the integer values such as HmdVsyncIndex, AppDroppedFrameCount etc. will be reset
/// as the other fields such as AppMotionToPhotonLatency are independent timing values updated
/// per-frame.
///
/// \param[in] session Specifies an ovrSession previously returned by ovr_Create.
/// \return Returns an ovrResult for which OVR_SUCCESS(result) is false upon error and true
///         upon success.
///
/// \see ovrPerfStats, ovrPerfStatsPerCompositorFrame, ovr_GetPerfStats
///
// @ORIGINAL: OVR_PUBLIC_FUNCTION(ovrResult) ovr_ResetPerfStats(ovrSession session);
ovr_ResetPerfStats :: proc(session: ovrSession) -> ovrResult #foreign ovr "ovr_ResetPerfStats";

/// Gets the time of the specified frame midpoint.
///
/// Predicts the time at which the given frame will be displayed. The predicted time
/// is the middle of the time period during which the corresponding eye images will
/// be displayed.
///
/// The application should increment frameIndex for each successively targeted frame,
/// and pass that index to any relevant OVR functions that need to apply to the frame
/// identified by that index.
///
/// This function is thread-safe and allows for multiple application threads to target
/// their processing to the same displayed frame.
///
/// In the even that prediction fails due to various reasons (e.g. the display being off
/// or app has yet to present any frames), the return value will be current CPU time.
///
/// \param[in] session Specifies an ovrSession previously returned by ovr_Create.
/// \param[in] frameIndex Identifies the frame the caller wishes to target.
///            A value of zero returns the next frame index.
/// \return Returns the absolute frame midpoint time for the given frameIndex.
/// \see ovr_GetTimeInSeconds
///
// @ORIGINAL: OVR_PUBLIC_FUNCTION(double) ovr_GetPredictedDisplayTime(ovrSession session, long long frameIndex);
ovr_GetPredictedDisplayTime :: proc(session: ovrSession, frameIndex: i64) -> f64 #foreign ovr "ovr_GetPredictedDisplayTime";

/// Returns global, absolute high-resolution time in seconds.
///
/// The time frame of reference for this function is not specified and should not be
/// depended upon.
///
/// \return Returns seconds as a floating point value.
/// \see ovrPoseStatef, ovrFrameTiming
///
// @ORIGINAL: OVR_PUBLIC_FUNCTION(double) ovr_GetTimeInSeconds();
ovr_GetTimeInSeconds :: proc() -> f64 #foreign ovr "ovr_GetTimeInSeconds";


/// Performance HUD enables the HMD user to see information critical to
/// the real-time operation of the VR application such as latency timing,
/// and CPU & GPU performance metrics
///
///     App can toggle performance HUD modes as such:
///     \code{.cpp}
///         ovrPerfHudMode PerfHudMode = ovrPerfHud_LatencyTiming;
///         ovr_SetInt(session, OVR_PERF_HUD_MODE, (int)PerfHudMode);
///     \endcode
///
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

/// Layer HUD enables the HMD user to see information about a layer
///
///     App can toggle layer HUD modes as such:
///     \code{.cpp}
///         ovrLayerHudMode LayerHudMode = ovrLayerHud_Info;
///         ovr_SetInt(session, OVR_LAYER_HUD_MODE, (int)LayerHudMode);
///     \endcode
///
ovrLayerHudMode :: enum i32 {
    ovrLayerHud_Off = 0, ///< Turns off the layer HUD
    ovrLayerHud_Info = 1, ///< Shows info about a specific layer
    ovrLayerHud_EnumSize = 0x7fffffff
};

///@}

/// Debug HUD is provided to help developers gauge and debug the fidelity of their app's
/// stereo rendering characteristics. Using the provided quad and crosshair guides,
/// the developer can verify various aspects such as VR tracking units (e.g. meters),
/// stereo camera-parallax properties (e.g. making sure objects at infinity are rendered
/// with the proper separation), measuring VR geometry sizes and distances and more.
///
///     App can toggle the debug HUD modes as such:
///     \code{.cpp}
///         ovrDebugHudStereoMode DebugHudMode = ovrDebugHudStereo_QuadWithCrosshair;
///         ovr_SetInt(session, OVR_DEBUG_HUD_STEREO_MODE, (int)DebugHudMode);
///     \endcode
///
/// The app can modify the visual properties of the stereo guide (i.e. quad, crosshair)
/// using the ovr_SetFloatArray function. For a list of tweakable properties,
/// see the OVR_DEBUG_HUD_STEREO_GUIDE_* keys in the OVR_CAPI_Keys.h header file.
ovrDebugHudStereoMode :: enum i32 {
    ovrDebugHudStereo_Off                 = 0,  ///< Turns off the Stereo Debug HUD
    ovrDebugHudStereo_Quad                = 1,  ///< Renders Quad in world for Stereo Debugging
    ovrDebugHudStereo_QuadWithCrosshair   = 2,  ///< Renders Quad+crosshair in world for Stereo Debugging
    ovrDebugHudStereo_CrosshairAtInfinity = 3,  ///< Renders screen-space crosshair at infinity for Stereo Debugging
    ovrDebugHudStereo_Count,                    ///< \internal Count of enumerated elements

    ovrDebugHudStereo_EnumSize = 0x7fffffff     ///< \internal Force type int32_t
};


// -----------------------------------------------------------------------------------
/// @name Property Access
///
/// These functions read and write OVR properties. Supported properties
/// are defined in OVR_CAPI_Keys.h
///
//@{

/// Reads a boolean property.
///
/// \param[in] session Specifies an ovrSession previously returned by ovr_Create.
/// \param[in] propertyName The name of the property, which needs to be valid for only the call.
/// \param[in] defaultVal specifes the value to return if the property couldn't be read.
/// \return Returns the property interpreted as a boolean value. Returns defaultVal if
///         the property doesn't exist.
// @ORIGINAL: OVR_PUBLIC_FUNCTION(ovrBool) ovr_GetBool(ovrSession session, const char* propertyName, ovrBool defaultVal);
ovr_GetBool :: proc(session: ovrSession, propertyName: ^byte, defaultVal: ovrBool) -> ovrBool #foreign ovr "ovr_GetBool"; // @WARNING: const char* to ^byte

/// Writes or creates a boolean property.
/// If the property wasn't previously a boolean property, it is changed to a boolean property.
///
/// \param[in] session Specifies an ovrSession previously returned by ovr_Create.
/// \param[in] propertyName The name of the property, which needs to be valid only for the call.
/// \param[in] value The value to write.
/// \return Returns true if successful, otherwise false. A false result should only occur if the property
///         name is empty or if the property is read-only.
// @ORIGINAL: OVR_PUBLIC_FUNCTION(ovrBool) ovr_SetBool(ovrSession session, const char* propertyName, ovrBool value);
ovr_SetBool :: proc(session: ovrSession, propertyName: ^byte, value: ovrBool) -> ovrBool #foreign ovr "ovr_SetBool"; // @WARNING: const char* to ^byte


/// Reads an integer property.
///
/// \param[in] session Specifies an ovrSession previously returned by ovr_Create.
/// \param[in] propertyName The name of the property, which needs to be valid only for the call.
/// \param[in] defaultVal Specifes the value to return if the property couldn't be read.
/// \return Returns the property interpreted as an integer value. Returns defaultVal if
///         the property doesn't exist.
// @ORIGINAL: OVR_PUBLIC_FUNCTION(int) ovr_GetInt(ovrSession session, const char* propertyName, int defaultVal);
ovr_GetInt :: proc(session: ovrSession, propertyName: ^byte, defaultVal: i32) -> i32 #foreign ovr "ovr_GetInt";

/// Writes or creates an integer property.
///
/// If the property wasn't previously a boolean property, it is changed to an integer property.
///
/// \param[in] session Specifies an ovrSession previously returned by ovr_Create.
/// \param[in] propertyName The name of the property, which needs to be valid only for the call.
/// \param[in] value The value to write.
/// \return Returns true if successful, otherwise false. A false result should only occur if the property
///         name is empty or if the property is read-only.
// @ORIGINAL: OVR_PUBLIC_FUNCTION(ovrBool) ovr_SetInt(ovrSession session, const char* propertyName, int value);
ovr_SetInt :: proc(session: ovrSession, propertyName: ^byte, value: i32) -> ovrBool #foreign ovr "ovr_SetInt";


/// Reads a float property.
///
/// \param[in] session Specifies an ovrSession previously returned by ovr_Create.
/// \param[in] propertyName The name of the property, which needs to be valid only for the call.
/// \param[in] defaultVal specifes the value to return if the property couldn't be read.
/// \return Returns the property interpreted as an float value. Returns defaultVal if
///         the property doesn't exist.
// @ORIGINAL: OVR_PUBLIC_FUNCTION(float) ovr_GetFloat(ovrSession session, const char* propertyName, float defaultVal);
ovr_GetFloat :: proc(session: ovrSession, propertyName: ^byte, defaultVal: f32) -> f32 #foreign ovr "ovr_GetFloat";

/// Writes or creates a float property.
/// If the property wasn't previously a float property, it's changed to a float property.
///
/// \param[in] session Specifies an ovrSession previously returned by ovr_Create.
/// \param[in] propertyName The name of the property, which needs to be valid only for the call.
/// \param[in] value The value to write.
/// \return Returns true if successful, otherwise false. A false result should only occur if the property
///         name is empty or if the property is read-only.
// @ORIGINAL: OVR_PUBLIC_FUNCTION(ovrBool) ovr_SetFloat(ovrSession session, const char* propertyName, float value);
ovr_SetFloat :: proc(session: ovrSession, propertyName: ^byte, value: f32) -> ovrBool #foreign ovr "ovr_SetFloat";


/// Reads a float array property.
///
/// \param[in] session Specifies an ovrSession previously returned by ovr_Create.
/// \param[in] propertyName The name of the property, which needs to be valid only for the call.
/// \param[in] values An array of float to write to.
/// \param[in] valuesCapacity Specifies the maximum number of elements to write to the values array.
/// \return Returns the number of elements read, or 0 if property doesn't exist or is empty.
// @ORIGINAL: OVR_PUBLIC_FUNCTION(unsigned int) ovr_GetFloatArray(ovrSession session, const char* propertyName,
//                                                                float values[], unsigned int valuesCapacity);
ovr_GetFloatArray :: proc(session: ovrSession, propertyName: ^byte, values: ^f32, valuesCapacity: u32) -> u32 #foreign ovr "ovr_GetFloatArray"; // @WARNING: float[] to ^f32

/// Writes or creates a float array property.
///
/// \param[in] session Specifies an ovrSession previously returned by ovr_Create.
/// \param[in] propertyName The name of the property, which needs to be valid only for the call.
/// \param[in] values An array of float to write from.
/// \param[in] valuesSize Specifies the number of elements to write.
/// \return Returns true if successful, otherwise false. A false result should only occur if the property
///         name is empty or if the property is read-only.
// @ORIGINAL: OVR_PUBLIC_FUNCTION(ovrBool) ovr_SetFloatArray(ovrSession session, const char* propertyName,
//                                                           const float values[], unsigned int valuesSize);
ovr_SetFloatArray :: proc(session: ovrSession, propertyName: ^byte, values: ^f32, valuesSize: u32) -> ovrBool #foreign ovr "ovr_SetFloatArray"; // @WARNING: const float[] to ^f32


/// Reads a string property.
/// Strings are UTF8-encoded and null-terminated.
///
/// \param[in] session Specifies an ovrSession previously returned by ovr_Create.
/// \param[in] propertyName The name of the property, which needs to be valid only for the call.
/// \param[in] defaultVal Specifes the value to return if the property couldn't be read.
/// \return Returns the string property if it exists. Otherwise returns defaultVal, which can be specified as NULL.
///         The return memory is guaranteed to be valid until next call to ovr_GetString or
///         until the session is destroyed, whichever occurs first.
// @ORIGINAL: OVR_PUBLIC_FUNCTION(const char*) ovr_GetString(ovrSession session, const char* propertyName,
//                                                           const char* defaultVal);
ovr_GetString :: proc(session: ovrSession, propertyName: ^byte, defaultVal: ^byte) -> ^byte #foreign ovr "ovr_GetString"; // @WARNING: const char to ^byte

/// Writes or creates a string property.
/// Strings are UTF8-encoded and null-terminated.
///
/// \param[in] session Specifies an ovrSession previously returned by ovr_Create.
/// \param[in] propertyName The name of the property, which needs to be valid only for the call.
/// \param[in] value The string property, which only needs to be valid for the duration of the call.
/// \return Returns true if successful, otherwise false. A false result should only occur if the property
///         name is empty or if the property is read-only.
// @ORIGINAL: OVR_PUBLIC_FUNCTION(ovrBool) ovr_SetString(ovrSession session, const char* propertyName,
//                                                       const char* value);
ovr_SetString :: proc(session: ovrSession, propertyName: ^byte, value: ^byte) -> ovrBool #foreign ovr "ovr_SetString"; // @WARNING: const char to ^byte

///@}


/// @cond DoxygenIgnore
//-----------------------------------------------------------------------------
// ***** Compiler packing validation
//
// These checks ensure that the compiler settings being used will be compatible
// with with pre-built dynamic library provided with the runtime.

// @TODO: ADD ASSERTIONS SIMILAR TO OVR_CAPI.h





// -----------------------------------------------------------------------------------
// ***** Backward compatibility #includes
//
// This is at the bottom of this file because the following is dependent on the
// declarations above.

/********************************************************************************//**
\file      OVR_CAPI_Util.h
\brief     This header provides LibOVR utility function declarations
\copyright Copyright 2015-2016 Oculus VR, LLC All Rights reserved.
*************************************************************************************/


/// Enumerates modifications to the projection matrix based on the application's needs.
///
/// \see ovrMatrix4f_Projection
///
ovrProjectionModifier :: enum i32 {
    /// Use for generating a default projection matrix that is:
    /// * Right-handed.
    /// * Near depth values stored in the depth buffer are smaller than far depth values.
    /// * Both near and far are explicitly defined.
    /// * With a clipping range that is (0 to w).
    ovrProjection_None = 0x00,

    /// Enable if using left-handed transformations in your application.
    ovrProjection_LeftHanded = 0x01,

    /// After the projection transform is applied, far values stored in the depth buffer will be less than closer depth values.
    /// NOTE: Enable only if the application is using a floating-point depth buffer for proper precision.
    ovrProjection_FarLessThanNear = 0x02,

    /// When this flag is used, the zfar value pushed into ovrMatrix4f_Projection() will be ignored
    /// NOTE: Enable only if ovrProjection_FarLessThanNear is also enabled where the far clipping plane will be pushed to infinity.
    ovrProjection_FarClipAtInfinity = 0x04,

    /// Enable if the application is rendering with OpenGL and expects a projection matrix with a clipping range of (-w to w).
    /// Ignore this flag if your application already handles the conversion from D3D range (0 to w) to OpenGL.
    ovrProjection_ClipRangeOpenGL = 0x08,
};


/// Return values for ovr_Detect.
///
/// \see ovr_Detect
///
ovrDetectResult :: struct #ordered #align 8 {
    /// Is ovrFalse when the Oculus Service is not running.
    ///   This means that the Oculus Service is either uninstalled or stopped.
    ///   IsOculusHMDConnected will be ovrFalse in this case.
    /// Is ovrTrue when the Oculus Service is running.
    ///   This means that the Oculus Service is installed and running.
    ///   IsOculusHMDConnected will reflect the state of the HMD.
    IsOculusServiceRunning: ovrBool,

    /// Is ovrFalse when an Oculus HMD is not detected.
    ///   If the Oculus Service is not running, this will be ovrFalse.
    /// Is ovrTrue when an Oculus HMD is detected.
    ///   This implies that the Oculus Service is also installed and running.
    IsOculusHMDConnected: ovrBool,

    pad0: [6]i8,  ///< \internal struct padding

};

// OVR_STATIC_ASSERT(sizeof(ovrDetectResult) == 8, "ovrDetectResult size mismatch"); // @TODO: Implement assert


/// Modes used to generate Touch Haptics from audio PCM buffer.
///
ovrHapticsGenMode :: enum i32 {
    /// Point sample original signal at Haptics frequency
    ovrHapticsGenMode_PointSample,
    ovrHapticsGenMode_Count
}; // @WARNING: unset

/// Store audio PCM data (as 32b float samples) for an audio channel.
/// Note: needs to be released with ovr_ReleaseAudioChannelData to avoid memory leak.
///
ovrAudioChannelData :: struct #ordered {
    /// Samples stored as floats [-1.0f, 1.0f].
    Samples: ^f32, // const float*
    /// Number of samples
    SamplesCount: i32,
    /// Frequency (e.g. 44100)
    Frequency: i32,
};

/// Store a full Haptics clip, which can be used as data source for multiple ovrHapticsBuffers.
///
ovrHapticsClip :: struct #ordered {
    /// Samples stored in opaque format
    Samples: rawptr, // @WARNING: const void*
    /// Number of samples
    SamplesCount: i32,
};


/// Detects Oculus Runtime and Device Status
///
/// Checks for Oculus Runtime and Oculus HMD device status without loading the LibOVRRT
/// shared library.  This may be called before ovr_Initialize() to help decide whether or
/// not to initialize LibOVR.
///
/// \param[in] timeoutMilliseconds Specifies a timeout to wait for HMD to be attached or 0 to poll.
///
/// \return Returns an ovrDetectResult object indicating the result of detection.
///
/// \see ovrDetectResult
///
// @ORIGINAL: OVR_PUBLIC_FUNCTION(ovrDetectResult) ovr_Detect(int timeoutMilliseconds);
ovr_Detect :: proc(timeoutMilliseconds: i32) -> ovrDetectResult #foreign ovr "ovr_Detect";

// On the Windows platform,
//#ifdef _WIN32
//    /// This is the Windows Named Event name that is used to check for HMD connected state.
//    #define OVR_HMD_CONNECTED_EVENT_NAME L"OculusHMDConnected"
//#endif // _WIN32
OVR_HMD_CONNECTED_EVENT_NAME :: "OculusHMDConnected\x00";


/// Used to generate projection from ovrEyeDesc::Fov.
///
/// \param[in] fov Specifies the ovrFovPort to use.
/// \param[in] znear Distance to near Z limit.
/// \param[in] zfar Distance to far Z limit.
/// \param[in] projectionModFlags A combination of the ovrProjectionModifier flags.
///
/// \return Returns the calculated projection matrix.
/// 
/// \see ovrProjectionModifier
///
// @ORIGINAL: OVR_PUBLIC_FUNCTION(ovrMatrix4f) ovrMatrix4f_Projection(ovrFovPort fov, float znear, float zfar, unsigned int projectionModFlags);
ovrMatrix4f_Projection :: proc(fov: ovrFovPort, znear, zfar: f32, projectionModFlags: u32) -> ovrMatrix4f #foreign ovr "ovrMatrix4f_Projection";

/// Extracts the required data from the result of ovrMatrix4f_Projection.
///
/// \param[in] projection Specifies the project matrix from which to extract ovrTimewarpProjectionDesc.
/// \param[in] projectionModFlags A combination of the ovrProjectionModifier flags.
/// \return Returns the extracted ovrTimewarpProjectionDesc.
/// \see ovrTimewarpProjectionDesc
///
// @ORIGINAL: OVR_PUBLIC_FUNCTION(ovrTimewarpProjectionDesc) ovrTimewarpProjectionDesc_FromProjection(ovrMatrix4f projection, unsigned int projectionModFlags);
ovrTimewarpProjectionDesc_FromProjection :: proc(projection: ovrMatrix4f, projectionModFlags: u32) -> ovrTimewarpProjectionDesc #foreign ovr "ovrTimewarpProjectionDesc_FromProjection";

/// Generates an orthographic sub-projection.
///
/// Used for 2D rendering, Y is down.
///
/// \param[in] projection The perspective matrix that the orthographic matrix is derived from.
/// \param[in] orthoScale Equal to 1.0f / pixelsPerTanAngleAtCenter.
/// \param[in] orthoDistance Equal to the distance from the camera in meters, such as 0.8m.
/// \param[in] HmdToEyeOffsetX Specifies the offset of the eye from the center.
///
/// \return Returns the calculated projection matrix.
///
// @ORIGINAL: OVR_PUBLIC_FUNCTION(ovrMatrix4f) ovrMatrix4f_OrthoSubProjection(ovrMatrix4f projection, ovrVector2f orthoScale,
//                                                                            float orthoDistance, float HmdToEyeOffsetX);
ovrMatrix4f_OrthoSubProjection :: proc(projection: ovrMatrix4f, orthoScale: ovrVector2f, orthoDistance: f32, HmdToEyeOffsetX: f32) -> ovrMatrix4f #foreign ovr "ovrMatrix4f_OrthoSubProjection";


/// Computes offset eye poses based on headPose returned by ovrTrackingState.
///
/// \param[in] headPose Indicates the HMD position and orientation to use for the calculation.
/// \param[in] hmdToEyeOffset Can be ovrEyeRenderDesc.HmdToEyeOffset returned from
///            ovr_GetRenderDesc. For monoscopic rendering, use a vector that is the average 
///            of the two vectors for both eyes.
/// \param[out] outEyePoses If outEyePoses are used for rendering, they should be passed to 
///             ovr_SubmitFrame in ovrLayerEyeFov::RenderPose or ovrLayerEyeFovDepth::RenderPose.
///
// @ORIGINAL: OVR_PUBLIC_FUNCTION(void) ovr_CalcEyePoses(ovrPosef headPose,
//                                                       const ovrVector3f hmdToEyeOffset[2], // @WARNING: const
//                                                       ovrPosef outEyePoses[2]);
// ovr_CalcEyePoses :: proc(headPose: ovrPosef, hmdToEyeOffset: [2]ovrVector3f, outEyePoses: [2]ovrPosef) #foreign ovr "ovr_CalcEyePoses"; // @WARNING: need to send pointers
ovr_CalcEyePoses :: proc(headPose: ovrPosef, hmdToEyeOffset: ^ovrVector3f, outEyePoses: ^ovrPosef) #foreign ovr "ovr_CalcEyePoses";

/// Returns the predicted head pose in outHmdTrackingState and offset eye poses in outEyePoses.
///
/// This is a thread-safe function where caller should increment frameIndex with every frame
/// and pass that index where applicable to functions called on the rendering thread.
/// Assuming outEyePoses are used for rendering, it should be passed as a part of ovrLayerEyeFov.
/// The caller does not need to worry about applying HmdToEyeOffset to the returned outEyePoses variables.
///
/// \param[in]  hmd Specifies an ovrSession previously returned by ovr_Create.
/// \param[in]  frameIndex Specifies the targeted frame index, or 0 to refer to one frame after 
///             the last time ovr_SubmitFrame was called.
/// \param[in]  latencyMarker Specifies that this call is the point in time where
///             the "App-to-Mid-Photon" latency timer starts from. If a given ovrLayer
///             provides "SensorSampleTimestamp", that will override the value stored here.
/// \param[in]  hmdToEyeOffset Can be ovrEyeRenderDesc.HmdToEyeOffset returned from
///             ovr_GetRenderDesc. For monoscopic rendering, use a vector that is the average
///             of the two vectors for both eyes.
/// \param[out] outEyePoses The predicted eye poses.
/// \param[out] outSensorSampleTime The time when this function was called. May be NULL, in which case it is ignored.
///
// @ORIGINAL: OVR_PUBLIC_FUNCTION(void) ovr_GetEyePoses(ovrSession session, long long frameIndex, ovrBool latencyMarker,
//                                                      const ovrVector3f hmdToEyeOffset[2],
//                                                      ovrPosef outEyePoses[2],
//                                                      double* outSensorSampleTime);
//ovr_GetEyePoses :: proc(session: ovrSession, frameIndex: i64, latencyMarker: ovrBool, hmdToEyeOffset: [2]ovrVector3f, outEyePoses: [2]ovrPosef, outSensorSampleTime: ^f64) #foreign ovr "ovr_GetEyePoses";
ovr_GetEyePoses :: proc(session: ovrSession, frameIndex: i64, 
                        latencyMarker: ovrBool, 
                        hmdToEyeOffset: ^ovrVector3f, 
                        outEyePoses: ^ovrPosef,  // @WARNING!
                        outSensorSampleTime: ^f64) #foreign ovr "ovr_GetEyePoses";


/// Tracking poses provided by the SDK come in a right-handed coordinate system. If an application
/// is passing in ovrProjection_LeftHanded into ovrMatrix4f_Projection, then it should also use
/// this function to flip the HMD tracking poses to be left-handed.
///
/// While this utility function is intended to convert a left-handed ovrPosef into a right-handed
/// coordinate system, it will also work for converting right-handed to left-handed since the
/// flip operation is the same for both cases.
/// 
/// \param[in]  inPose that is right-handed
/// \param[out] outPose that is requested to be left-handed (can be the same pointer to inPose)
///
// @ORIGINAL: OVR_PUBLIC_FUNCTION(void) ovrPosef_FlipHandedness(const ovrPosef* inPose, ovrPosef* outPose);
ovrPosef_FlipHandedness :: proc(inPose: ^ovrPosef, outPose: ^ovrPosef) #foreign ovr "ovrPosef_FlipHandedness";

/// Reads an audio channel from Wav (Waveform Audio File) data.
/// Input must be a byte buffer representing a valid Wav file. Audio samples from the specified channel are read,
/// converted to float [-1.0f, 1.0f] and returned through ovrAudioChannelData.
///
/// Supported formats: PCM 8b, 16b, 32b and IEEE float (little-endian only).
///
/// \param[out] outAudioChannel output audio channel data.
/// \param[in] inputData a binary buffer representing a valid Wav file data.
/// \param[in] dataSizeInBytes size of the buffer in bytes.
/// \param[in] stereoChannelToUse audio channel index to extract (0 for mono).
///
// @ORIGINAL: OVR_PUBLIC_FUNCTION(ovrResult) ovr_ReadWavFromBuffer(ovrAudioChannelData* outAudioChannel, const void* inputData, int dataSizeInBytes, int stereoChannelToUse);
ovr_ReadWavFromBuffer :: proc(outAudioChannel: ^ovrAudioChannelData, inputData: rawptr, dataSizeInBytes: i32, stereoChannelToUse: i32) -> ovrResult #foreign ovr "ovr_ReadWavFromBuffer";

/// Generates playable Touch Haptics data from an audio channel.
///
/// \param[out] outHapticsClip generated Haptics clip.
/// \param[in] audioChannel input audio channel data. 
/// \param[in] genMode mode used to convert and audio channel data to Haptics data.
///
// @ORIGINAL: OVR_PUBLIC_FUNCTION(ovrResult) ovr_GenHapticsFromAudioData(ovrHapticsClip* outHapticsClip, const ovrAudioChannelData* audioChannel, ovrHapticsGenMode genMode);
ovr_GenHapticsFromAudioData :: proc(outHapticsClip: ^ovrHapticsClip, audioChannel: ^ovrAudioChannelData, genMode: ovrHapticsGenMode) -> ovrResult #foreign ovr "ovr_GenHapticsFromAudioData";

/// Releases memory allocated for ovrAudioChannelData. Must be called to avoid memory leak.
/// \param[in] audioChannel pointer to an audio channel
///
// @ORIGINAL: OVR_PUBLIC_FUNCTION(void) ovr_ReleaseAudioChannelData(ovrAudioChannelData* audioChannel);
ovr_ReleaseAudioChannelData :: proc(audioChannel: ^ovrAudioChannelData) #foreign ovr "ovr_ReleaseAudioChannelData";

/// Releases memory allocated for ovrHapticsClip. Must be called to avoid memory leak.
/// \param[in] hapticsClip pointer to a haptics clip
///
// @ORIGINAL: OVR_PUBLIC_FUNCTION(void) ovr_ReleaseHapticsClip(ovrHapticsClip* hapticsClip);
ovr_ReleaseHapticsClip :: proc(hapticsClip: ^ovrHapticsClip) #foreign ovr "ovr_ReleaseHapticsClip";








/********************************************************************************//**
\file      OVR_CAPI_GL.h
\brief     OpenGL-specific structures used by the CAPI interface.
\copyright Copyright 2015 Oculus VR, LLC. All Rights reserved.
************************************************************************************/



/// Creates a TextureSwapChain suitable for use with OpenGL.
///
/// \param[in]  session Specifies an ovrSession previously returned by ovr_Create.
/// \param[in]  desc Specifies the requested texture properties. See notes for more info about texture format.
/// \param[out] out_TextureSwapChain Returns the created ovrTextureSwapChain, which will be valid upon
///             a successful return value, else it will be NULL. This texture swap chain must be eventually
///             destroyed via ovr_DestroyTextureSwapChain before destroying the session with ovr_Destroy.
///
/// \return Returns an ovrResult indicating success or failure. In the case of failure, use 
///         ovr_GetLastErrorInfo to get more information.
///
/// \note The \a format provided should be thought of as the format the distortion compositor will use when reading
/// the contents of the texture. To that end, it is highly recommended that the application requests texture swap chain
/// formats that are in sRGB-space (e.g. OVR_FORMAT_R8G8B8A8_UNORM_SRGB) as the distortion compositor does sRGB-correct
/// rendering. Furthermore, the app should then make sure "glEnable(GL_FRAMEBUFFER_SRGB);" is called before rendering
/// into these textures. Even though it is not recommended, if the application would like to treat the texture as a linear
/// format and do linear-to-gamma conversion in GLSL, then the application can avoid calling "glEnable(GL_FRAMEBUFFER_SRGB);",
/// but should still pass in an sRGB variant for the \a format. Failure to do so will cause the distortion compositor
/// to apply incorrect gamma conversions leading to gamma-curve artifacts.
///
/// \see ovr_GetTextureSwapChainLength
/// \see ovr_GetTextureSwapChainCurrentIndex
/// \see ovr_GetTextureSwapChainDesc
/// \see ovr_GetTextureSwapChainBufferGL
/// \see ovr_DestroyTextureSwapChain
///
// @ORIGINAL: OVR_PUBLIC_FUNCTION(ovrResult) ovr_CreateTextureSwapChainGL(ovrSession session,
//                                                                        const ovrTextureSwapChainDesc* desc,
//                                                                        ovrTextureSwapChain* out_TextureSwapChain);
ovr_CreateTextureSwapChainGL :: proc(session: ovrSession, desc: ^ovrTextureSwapChainDesc, out_TextureSwapChain: ^ovrTextureSwapChain) -> ovrResult #foreign ovr "ovr_CreateTextureSwapChainGL";


/// Get a specific buffer within the chain as a GL texture name
///
/// \param[in]  session Specifies an ovrSession previously returned by ovr_Create.
/// \param[in]  chain Specifies an ovrTextureSwapChain previously returned by ovr_CreateTextureSwapChainGL
/// \param[in]  index Specifies the index within the chain to retrieve. Must be between 0 and length (see ovr_GetTextureSwapChainLength)
///             or may pass -1 to get the buffer at the CurrentIndex location. (Saving a call to GetTextureSwapChainCurrentIndex)
/// \param[out] out_TexId Returns the GL texture object name associated with the specific index requested
///
/// \return Returns an ovrResult indicating success or failure. In the case of failure, use 
///         ovr_GetLastErrorInfo to get more information.
///
// @ORIGINAL: OVR_PUBLIC_FUNCTION(ovrResult) ovr_GetTextureSwapChainBufferGL(ovrSession session,
//                                                                           ovrTextureSwapChain chain,
//                                                                           int index,
//                                                                           unsigned int* out_TexId);
ovr_GetTextureSwapChainBufferGL :: proc(session: ovrSession, chain: ovrTextureSwapChain, index: i32, out_TexId: ^u32) -> ovrResult #foreign ovr "ovr_GetTextureSwapChainBufferGL";

/// Creates a Mirror Texture which is auto-refreshed to mirror Rift contents produced by this application.
///
/// A second call to ovr_CreateMirrorTextureGL for a given ovrSession before destroying the first one
/// is not supported and will result in an error return.
///
/// \param[in]  session Specifies an ovrSession previously returned by ovr_Create.
/// \param[in]  desc Specifies the requested mirror texture description.
/// \param[out] out_MirrorTexture Specifies the created ovrMirrorTexture, which will be valid upon a successful return value, else it will be NULL.
///             This texture must be eventually destroyed via ovr_DestroyMirrorTexture before destroying the session with ovr_Destroy.
///
/// \return Returns an ovrResult indicating success or failure. In the case of failure, use 
///         ovr_GetLastErrorInfo to get more information.
///
/// \note The \a format provided should be thought of as the format the distortion compositor will use when writing into the mirror
/// texture. It is highly recommended that mirror textures are requested as sRGB formats because the distortion compositor
/// does sRGB-correct rendering. If the application requests a non-sRGB format (e.g. R8G8B8A8_UNORM) as the mirror texture,
/// then the application might have to apply a manual linear-to-gamma conversion when reading from the mirror texture.
/// Failure to do so can result in incorrect gamma conversions leading to gamma-curve artifacts and color banding.
///
/// \see ovr_GetMirrorTextureBufferGL
/// \see ovr_DestroyMirrorTexture
///
// @ORIGINAL: OVR_PUBLIC_FUNCTION(ovrResult) ovr_CreateMirrorTextureGL(ovrSession session,
//                                                                     const ovrMirrorTextureDesc* desc,
//                                                                     ovrMirrorTexture* out_MirrorTexture);
ovr_CreateMirrorTextureGL :: proc(session: ovrSession, desc: ^ovrMirrorTextureDesc, out_MirrorTexture: ^ovrMirrorTexture) -> ovrResult #foreign ovr "ovr_CreateMirrorTextureGL";

/// Get a the underlying buffer as a GL texture name
///
/// \param[in]  session Specifies an ovrSession previously returned by ovr_Create.
/// \param[in]  mirrorTexture Specifies an ovrMirrorTexture previously returned by ovr_CreateMirrorTextureGL
/// \param[out] out_TexId Specifies the GL texture object name associated with the mirror texture
///
/// \return Returns an ovrResult indicating success or failure. In the case of failure, use 
///         ovr_GetLastErrorInfo to get more information.
///
// @ORIGINAL: OVR_PUBLIC_FUNCTION(ovrResult) ovr_GetMirrorTextureBufferGL(ovrSession session,
//                                                                        ovrMirrorTexture mirrorTexture,
//                                                                        unsigned int* out_TexId);
ovr_GetMirrorTextureBufferGL :: proc(session: ovrSession, mirrorTexture: ovrMirrorTexture, out_TexId: ^u32) -> ovrResult #foreign ovr "ovr_GetMirrorTextureBufferGL";

