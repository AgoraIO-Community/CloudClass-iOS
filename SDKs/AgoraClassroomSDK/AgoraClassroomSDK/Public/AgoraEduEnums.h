//
//  AgoraEduEnums.h
//  AgoraClassroomSDK
//
//  Created by SRS on 2021/1/7.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

typedef NS_ENUM(NSInteger, AgoraEduRegion) {
    // 中国大陆
    AgoraEduRegionCN = 0,
    // 北美
    AgoraEduRegionNA = 1,
    // 欧洲
    AgoraEduRegionEU = 2,
    // 东南亚
    AgoraEduRegionAP = 3,
};

typedef NS_ENUM(NSInteger, AgoraEduExitReason) {
    // 失败
    AgoraEduExitReasonNormal = 0,
    // 准备完成
    AgoraEduExitReasonKickOut = 1
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
    /** 5: 128-bit AES encryption, GCM mode.*/
    AgoraEduMediaEncryptionModeAES128GCM = 5,
    /** 6: 256-bit AES encryption, GCM mode.*/
    AgoraEduMediaEncryptionModeAES256GCM = 6,
    AgoraEduMediaEncryptionModeAES128GCM2 = 7,
    AgoraEduMediaEncryptionModeAES256GCM2 = 8,
};

typedef NS_ENUM(NSInteger, AgoraEduMirrorMode) {
    AgoraEduMirrorModeEnabled  = 1,
    AgoraEduMirrorModeDisabled = 2,
};

// RTC 观众延时级别
typedef NS_ENUM(NSInteger, AgoraEduLatencyLevel) {
    AgoraEduLatencyLevelLow      = 1,
    AgoraEduLatencyLevelUltraLow = 2,
};

typedef NS_ENUM(NSInteger, AgoraEduRoleType) {
    AgoraEduRoleTypeTeacher = 1,
    AgoraEduRoleTypeStudent = 2,
};

typedef NS_ENUM(NSInteger, AgoraEduRoomType) {
    AgoraEduRoomTypeOneToOne   = 0,
    AgoraEduRoomTypeLecture    = 2,
    AgoraEduRoomTypeSmall      = 4,
    AgoraEduRoomTypePaintingSmall = 5,
};

typedef NS_ENUM(NSInteger, AgoraEduStreamState) {
    AgoraEduStreamStateOff     = 0,
    AgoraEduStreamStateOn      = 1,
    AgoraEduStreamStateDefault = 3,
};

NS_ASSUME_NONNULL_END
