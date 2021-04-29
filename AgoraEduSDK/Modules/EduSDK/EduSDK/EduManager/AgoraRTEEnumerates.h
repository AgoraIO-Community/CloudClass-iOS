//
//  AgoraRTEEnumerates.h
//  EduSDK
//
//  Created by SRS on 2020/10/18.
//  Copyright © 2020 agora. All rights reserved.
//

typedef NS_ENUM(NSInteger, AgoraRTERoleType) {
    AgoraRTERoleTypeInvalid = 0,
    AgoraRTERoleTypeTeacher = 1,
    AgoraRTERoleTypeStudent = 2,
    AgoraRTERoleTypeAssistant = 3,
};

typedef NS_ENUM(NSInteger, AgoraRTESceneType) {
    AgoraRTESceneType1V1 = 0,
    AgoraRTESceneTypeSmall = 1,
    AgoraRTESceneTypeBig = 2,
    AgoraRTESceneTypeBreakout = 3,
    AgoraRTESceneTypeMedium = 4,
};

typedef NS_ENUM(NSInteger, AgoraRTEVideoSourceType) {
    AgoraRTEVideoSourceTypeNone = 0,
    AgoraRTEVideoSourceTypeCamera = 1,
    AgoraRTEVideoSourceTypeScreen = 2,
};

typedef NS_ENUM(NSInteger, AgoraRTEUserLeftType) {
    AgoraRTEUserLeftTypeNormal = 1,
    AgoraRTEUserLeftTypeKickOff = 2,
};

typedef NS_ENUM(NSInteger, AgoraRTEClassroomChangeType) {
    AgoraRTEClassroomChangeTypeAllStudentsChat,
    AgoraRTEClassroomChangeTypeCourseState,
};

typedef NS_ENUM(NSInteger, AgoraRTEUserStateChangeType) {
    AgoraRTEUserStateChangeTypeChat,
};

typedef NS_ENUM(NSInteger, AgoraRTEStreamStateChangeType) {
    AgoraRTEStreamStateChangeTypeVideo,
    AgoraRTEStreamStateChangeTypeAudio,
    AgoraRTEStreamStateChangeTypeVideo_Audio,
};

typedef NS_ENUM(NSInteger, AgoraRTENetworkQuality) {
    AgoraRTENetworkQualityUnknown = -1,
    AgoraRTENetworkQualityHigh = 1,
    AgoraRTENetworkQualityMiddle = 2,
    AgoraRTENetworkQualityLow = 3,
};

typedef NS_ENUM(NSInteger, AgoraRTEConnectionState) {
    AgoraRTEConnectionStateDisconnected             = 1,
    AgoraRTEConnectionStateConnecting               = 2,
    AgoraRTEConnectionStateConnected                = 3,
    AgoraRTEConnectionStateReconnecting             = 4,
    AgoraRTEConnectionStateAborted                  = 5,
};

typedef NS_ENUM(NSInteger, AgoraRTECourseState) {
    AgoraRTECourseStateDefault = 0,
    AgoraRTECourseStateStart = 1,
    AgoraRTECourseStateStop = 2,
};

typedef NS_ENUM(NSUInteger, AgoraRTEActionType) {
    AgoraRTEActionTypeApply = 1,
    AgoraRTEActionTypeInvitation = 2,
    AgoraRTEActionTypeAccept = 3,
    AgoraRTEActionTypeReject = 4,
    AgoraRTEActionTypeCancel = 5,
};

typedef NS_ENUM(NSUInteger, AgoraRTERenderMode) {
    
    /** Hidden(1): Uniformly scale the video until it fills the visible boundaries (cropped). One dimension of the video may have clipped contents. */
    AgoraRTERenderModeHidden = 1,
    /** Fit(2): Uniformly scale the video until one of its dimension fits the boundary (zoomed to fit). Areas that are not filled due to the disparity in the aspect ratio are filled with black. */
    AgoraRTERenderModeFit = 2,
};

typedef NS_ENUM(NSInteger, AgoraRTEVideoStreamType) {
    AgoraRTEVideoStreamTypeHigh = 0,
    AgoraRTEVideoStreamTypeLow = 1,
};

typedef NS_ENUM(NSInteger, AgoraRTEVideoOutputOrientationMode) {
    /** Adaptive mode.
     <p>The video encoder adapts to the orientation mode of the video input device. When you use a custom video source, the output video from the encoder inherits the orientation of the original video.
     <ul><li>If the width of the captured video from the SDK is greater than the height, the encoder sends the video in landscape mode. The encoder also sends the rotational information of the video, and the receiver uses the rotational information to rotate the received video.</li>
     <li>If the original video is in portrait mode, the output video from the encoder is also in portrait mode. The encoder also sends the rotational information of the video to the receiver.</li></ul></p>
     */
    AgoraRTEVideoOutputOrientationModeAdaptative,
    /** Landscape mode.
     <p>The video encoder always sends the video in landscape mode. The video encoder rotates the original video before sending it and the rotational information is 0. This mode applies to scenarios involving CDN live streaming.</p>
     */
    AgoraRTEVideoOutputOrientationModeFixedLandscape,
     /** Portrait mode.
      <p>The video encoder always sends the video in portrait mode. The video encoder rotates the original video before sending it and the rotational information is 0. This mode applies to scenarios involving CDN live streaming.</p>
      */
    AgoraRTEVideoOutputOrientationModeFixedPortrait,
};

/** The video encoding degradation preference under limited bandwidth. */
typedef NS_ENUM(NSInteger, AgoraRTEDegradationPreference) {
    /** Degrades the frame rate to guarantee the video quality. */
    AgoraRTEDegradationMaintainQuality = 0,
    /** Degrades the video quality to guarantee the frame rate. */
    AgoraRTEDegradationMaintainFramerate = 1,
    /** Reserved for future use. */
    AgoraRTEDegradationBalanced = 2,
};

typedef NS_ENUM(NSUInteger, AgoraRTEStreamState) {
    AgoraRTEStreamStateStopped = 0,
    AgoraRTEStreamStateStarting = 1,
    AgoraRTEStreamStateRunning = 2,
    AgoraRTEStreamStateFrozen = 3,
    AgoraRTEStreamStateFailed = 4,
};
