#import "fmt.odin"; // println, printf
#import win32 "sys/windows.odin"; // Sleep
#foreign_system_library ovr "libovr.lib";

ovrSuccess :: 0; // from OVR_ErrorCode.h
ovrTrue    :: 1;
ovrFalse   :: 0;

ovrResult  :: #type i32;
ovrBool    :: #type i8;
ovrSession :: #type ^struct {};

ovrGraphicsLuid :: struct #ordered #align 8 {
    Reserved : [8]i8
};

ovrQuatf :: struct #ordered #align 4 {
    x, y, z, w: f32,
};

ovrVector3f :: struct #ordered #align 4 {
    x, y, z: f32,
};

ovrPosef :: struct #ordered #align 4 {
    Orientation: ovrQuatf,
    Position:    ovrVector3f,
};

ovrPoseStatef :: struct #ordered #align 8 {
    ThePose:             ovrPosef,
    AngularVelocity:     ovrVector3f,
    LinearVelocity:      ovrVector3f,
    AngularAcceleration: ovrVector3f,
    LinearAcceleration:  ovrVector3f,
    pad0:                [4]i8,
    TimeInSeconds:       f64,
};

ovrTrackingState :: struct #ordered #align 8 {
    HeadPose:         ovrPoseStatef,
    StatusFlags:      u32,
    HandPose:         [2]ovrPoseStatef,
    HandStatusFlags:  [2]u32,
    CalibratedOrigin: ovrPosef,
};

ovrLogCallback :: #type proc(userData: uint, level: i32, message: ^byte) #cc_c;

ovrInitParams :: struct #ordered #align 8 {
    Flags:                 u32,
    RequestedMinorVersion: u32,
    LogCallback:           ovrLogCallback,
    UserData:              uint,
    ConnectionTimeoutMS:   u32,
    pad0:                  [4]i8,
};

// OVR_PUBLIC_FUNCTION(ovrResult) ovr_Initialize(const ovrInitParams* params);
// OVR_PUBLIC_FUNCTION(ovrResult) ovr_Create(ovrSession* pSession, ovrGraphicsLuid* pLuid);
// OVR_PUBLIC_FUNCTION(ovrTrackingState) ovr_GetTrackingState(ovrSession session, double absTime, ovrBool latencyMarker);
// OVR_PUBLIC_FUNCTION(void) ovr_Destroy(ovrSession session);

ovr_Initialize       :: proc(^ovrInitParams)                -> ovrResult        #foreign ovr "ovr_Initialize";       
ovr_Create           :: proc(^ovrSession, ^ovrGraphicsLuid) -> ovrResult        #foreign ovr "ovr_Create";
ovr_GetTrackingState :: proc(ovrSession, f64, ovrBool)      -> ovrTrackingState #foreign ovr "ovr_GetTrackingState";
ovr_Destroy          :: proc(ovrSession)                                        #foreign ovr "ovr_Destroy";

main :: proc() {
    if result_init := ovr_Initialize(nil); result_init == ovrSuccess {
        session : ovrSession;
        luid : ovrGraphicsLuid;

        if result_create := ovr_Create(^session, ^luid); result_create == ovrSuccess {
            for {
                ts := ovr_GetTrackingState(session, 0, 1);
                pos := ts.HeadPose.ThePose.Position;
                orient := ts.HeadPose.ThePose.Orientation;

                fmt.printf("Pos = (%f, %f, %f), Orient = (%f, %f, %f, %f)\n", pos.x, pos.y, pos.z, orient.x, orient.y, orient.z, orient.w);
                
                win32.Sleep(100);
            }

            ovr_Destroy(session);
        } else {
            fmt.println("Error, could not create. Error code:", result_create);
        }
    } else {
        fmt.println("Error, could not initialize. Error code:", result_init);
    }
}