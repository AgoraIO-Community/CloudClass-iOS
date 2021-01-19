//
//  EduEnumerates.h
//  EduSDK
//
//  Created by SRS on 2020/10/18.
//  Copyright © 2020 agora. All rights reserved.
//

typedef NS_ENUM(NSInteger, EduRoleType) {
    EduRoleTypeInvalid = 0,
    EduRoleTypeTeacher = 1,
    EduRoleTypeStudent = 2,
    EduRoleTypeAssistant = 3,
};

typedef NS_ENUM(NSInteger, EduSceneType) {
    EduSceneType1V1 = 0,
    EduSceneTypeSmall = 1,
    EduSceneTypeBig = 2,
    EduSceneTypeBreakout = 3,
    EduSceneTypeMedium = 4,
};

typedef NS_ENUM(NSInteger, EduVideoSourceType) {
    EduVideoSourceTypeNone = 0,
    EduVideoSourceTypeCamera = 1,
    EduVideoSourceTypeScreen = 2,
};

typedef NS_ENUM(NSInteger, EduUserLeftType) {
    EduUserLeftTypeNormal = 1,
    EduUserLeftTypeKickOff = 2,
};

typedef NS_ENUM(NSInteger, EduClassroomChangeType) {
    EduClassroomChangeTypeAllStudentsChat,
    EduClassroomChangeTypeCourseState,
};

typedef NS_ENUM(NSInteger, EduUserStateChangeType) {
    EduUserStateChangeTypeChat,
};

typedef NS_ENUM(NSInteger, EduStreamStateChangeType) {
    EduStreamStateChangeTypeVideo,
    EduStreamStateChangeTypeAudio,
    EduStreamStateChangeTypeVideo_Audio,
};

typedef NS_ENUM(NSInteger, NetworkQuality) {
    NetworkQualityUnknown = -1,
    NetworkQualityHigh = 1,
    NetworkQualityMiddle = 2,
    NetworkQualityLow = 3,
};

typedef NS_ENUM(NSInteger, ConnectionState) {
    ConnectionStateDisconnected             = 1,
    ConnectionStateConnecting               = 2,
    ConnectionStateConnected                = 3,
    ConnectionStateReconnecting             = 4,
    ConnectionStateAborted                  = 5,
};

typedef NS_ENUM(NSInteger, EduCourseState) {
    EduCourseStateStart = 1,
    EduCourseStateStop = 2,
};

typedef NS_ENUM(NSUInteger, EduActionType) {
    EduActionTypeApply = 1,
    EduActionTypeInvitation = 2,
    EduActionTypeAccept = 3,
    EduActionTypeReject = 4,
    EduActionTypeCancel = 5,
};

typedef NS_ENUM(NSUInteger, EduRenderMode) {
    
    /** Hidden(1): Uniformly scale the video until it fills the visible boundaries (cropped). One dimension of the video may have clipped contents. */
    EduRenderModeHidden = 1,
    /** Fit(2): Uniformly scale the video until one of its dimension fits the boundary (zoomed to fit). Areas that are not filled due to the disparity in the aspect ratio are filled with black. */
    EduRenderModeFit = 2,
};

typedef NS_ENUM(NSInteger, EduVideoStreamType) {
    EduVideoStreamTypeHigh = 0,
    EduVideoStreamTypeLow = 1,
};

typedef NS_ENUM(NSInteger, EduVideoOutputOrientationMode) {
    /** Adaptive mode.
     <p>The video encoder adapts to the orientation mode of the video input device. When you use a custom video source, the output video from the encoder inherits the orientation of the original video.
     <ul><li>If the width of the captured video from the SDK is greater than the height, the encoder sends the video in landscape mode. The encoder also sends the rotational information of the video, and the receiver uses the rotational information to rotate the received video.</li>
     <li>If the original video is in portrait mode, the output video from the encoder is also in portrait mode. The encoder also sends the rotational information of the video to the receiver.</li></ul></p>
     */
    EduVideoOutputOrientationModeAdaptative,
    /** Landscape mode.
     <p>The video encoder always sends the video in landscape mode. The video encoder rotates the original video before sending it and the rotational information is 0. This mode applies to scenarios involving CDN live streaming.</p>
     */
    EduVideoOutputOrientationModeFixedLandscape,
     /** Portrait mode.
      <p>The video encoder always sends the video in portrait mode. The video encoder rotates the original video before sending it and the rotational information is 0. This mode applies to scenarios involving CDN live streaming.</p>
      */
    EduVideoOutputOrientationModeFixedPortrait,
};

/** The video encoding degradation preference under limited bandwidth. */
typedef NS_ENUM(NSInteger, EduDegradationPreference) {
    /** Degrades the frame rate to guarantee the video quality. */
    EduDegradationMaintainQuality = 0,
    /** Degrades the video quality to guarantee the frame rate. */
    EduDegradationMaintainFramerate = 1,
    /** Reserved for future use. */
    EduDegradationBalanced = 2,
};

typedef NS_ENUM(NSUInteger, EduStreamState) {
    EduStreamStateStopped = 0,
    EduStreamStateStarting = 1,
    EduStreamStateRunning = 2,
    EduStreamStateFrozen = 3,
    EduStreamStateFailed = 4,
};
