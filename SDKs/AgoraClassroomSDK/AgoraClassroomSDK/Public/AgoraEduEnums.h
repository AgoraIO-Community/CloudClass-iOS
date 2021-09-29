//
//  AgoraEduEnums.h
//  AgoraClassroomSDK
//
//  Created by SRS on 2021/1/7.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

// 事件类型
typedef NS_ENUM(NSInteger, AgoraEduEvent) {
    // 失败
    AgoraEduEventFailed = 0,
    // 准备完成
    AgoraEduEventReady,
    // 已经销毁
    AgoraEduEventDestroyed,
    // Forbidden
    AgoraEduEventForbidden,
};

/**加密方式*/
typedef NS_ENUM(NSInteger, AgoraEduMediaEncryptionMode) {
    AgoraEduMediaEncryptionModeNone = 0,
    /** 1: 128-bit AES encryption, XTS mode. */
    AgoraEduMediaEncryptionModeAES128XTS = 1,
    /** 2: 128-bit AES encryption, ECB mode. */
    AgoraEduMediaEncryptionModeAES128ECB = 2,
    /** 3: 256-bit AES encryption, XTS mode. */
    AgoraEduMediaEncryptionModeAES256XTS = 3,
    /** 4: 128-bit SM4 encryption, ECB mode. */
    AgoraEduMediaEncryptionModeSM4128ECB = 4,
    /** 5: 128-bit AES encryption, GCM mode.

     @since v3.3.1
     */
    AgoraEduMediaEncryptionModeAES128GCM = 5,
    /** 6: 256-bit AES encryption, GCM mode.

     @since v3.3.1
     */
    AgoraEduMediaEncryptionModeAES256GCM = 6,
};

typedef NS_ENUM(NSInteger, AgoraEduMirrorMode) {
    AgoraEduMirrorModeAuto     = 0,
    AgoraEduMirrorModeEnabled  = 1,
    AgoraEduMirrorModeDisabled = 2,
};

// RTC 观众延时级别
typedef NS_ENUM(NSInteger, AgoraEduLatencyLevel) {
    AgoraEduLatencyLevelLow      = 1,
    AgoraEduLatencyLevelUltraLow = 2,
};

typedef NS_ENUM(NSInteger, AgoraEduBoardFitMode) {
    AgoraEduBoardFitModeAuto   = 1,
    AgoraEduBoardFitModeRetain = 2,
};

typedef NS_ENUM(NSInteger, AgoraEduRoleType) {
    AgoraEduRoleTypeStudent = 2,
};

typedef NS_ENUM(NSInteger, AgoraEduRoomType) {
    AgoraEduRoomTypeOneToOne   = 0,
    AgoraEduRoomTypeLecture    = 2,
    AgoraEduRoomTypeSmall      = 4,
};

typedef NS_ENUM(NSInteger, AgoraEduStreamState) {
    AgoraEduStreamStateOff     = 0,
    AgoraEduStreamStateOn      = 1,
    AgoraEduStreamStateDefault = 3,
};

NS_ASSUME_NONNULL_END
