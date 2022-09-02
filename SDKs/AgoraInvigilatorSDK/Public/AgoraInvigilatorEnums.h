//
//  AgoraInvigilatorEnums.h
//  AgoraClassroomSDK
//
//  Created by SRS on 2021/1/7.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN
// 上台后音视频是否自动发流权限
typedef NS_ENUM(NSInteger, AgoraInvigilatorMediaAuthOption) {
    // 无权限
    AgoraInvigilatorMediaAuthOptionNone = 0,
    // 仅音频权限
    AgoraInvigilatorMediaAuthOptionAudio = 1,
    // 仅视频权限
    AgoraInvigilatorMediaAuthOptionVideo = 2,
    // 音频+视频权限
    AgoraInvigilatorMediaAuthOptionBoth = 3,
};

typedef NS_ENUM(NSInteger, AgoraInvigilatorRegion) {
    // 中国大陆
    AgoraInvigilatorRegionCN = 0,
    // 北美
    AgoraInvigilatorRegionNA = 1,
    // 欧洲
    AgoraInvigilatorRegionEU = 2,
    // 东南亚
    AgoraInvigilatorRegionAP = 3
};

typedef NS_ENUM(NSInteger, AgoraInvigilatorExitReason) {
    // 正常退出
    AgoraInvigilatorExitReasonNormal = 0,
    // 被踢出
    AgoraInvigilatorExitReasonKickOut = 1
};

/**加密方式*/
typedef NS_ENUM(NSInteger, AgoraInvigilatorMediaEncryptionMode) {
    AgoraInvigilatorMediaEncryptionModeNone       = 0,
    /** 1: 128-bit AES encryption, XTS mode. */
    AgoraInvigilatorMediaEncryptionModeAES128XTS  = 1,
    /** 2: 128-bit AES encryption, ECB mode. */
    AgoraInvigilatorMediaEncryptionModeAES128ECB  = 2,
    /** 3: 256-bit AES encryption, XTS mode. */
    AgoraInvigilatorMediaEncryptionModeAES256XTS  = 3,
    /** 4: 128-bit SM4 encryption, ECB mode. */
    AgoraInvigilatorMediaEncryptionModeSM4128ECB  = 4,
    /** 5: 128-bit AES encryption, GCM mode.*/
    AgoraInvigilatorMediaEncryptionModeAES128GCM  = 5,
    /** 6: 256-bit AES encryption, GCM mode.*/
    AgoraInvigilatorMediaEncryptionModeAES256GCM  = 6,
    AgoraInvigilatorMediaEncryptionModeAES128GCM2 = 7,
    AgoraInvigilatorMediaEncryptionModeAES256GCM2 = 8
};

typedef NS_ENUM(NSInteger, AgoraInvigilatorMirrorMode) {
    AgoraInvigilatorMirrorModeDisabled = 0,
    AgoraInvigilatorMirrorModeEnabled  = 1
};

// RTC 观众延时级别
typedef NS_ENUM(NSInteger, AgoraInvigilatorLatencyLevel) {
    AgoraInvigilatorLatencyLevelLow      = 1,
    AgoraInvigilatorLatencyLevelUltraLow = 2
};

typedef NS_ENUM(NSInteger, AgoraInvigilatorUserRole) {
    AgoraInvigilatorUserRoleTeacher  = 1,
    AgoraInvigilatorUserRoleStudent  = 2,
    AgoraInvigilatorUserRoleObserver = 4
};

typedef NS_ENUM(NSInteger, AgoraInvigilatorServiceType) {
    AgoraInvigilatorServiceTypeLivePremium,
    AgoraInvigilatorServiceTypeLiveStandard,
    AgoraInvigilatorServiceTypeCDN,
    AgoraInvigilatorServiceTypeFusion,
    AgoraInvigilatorServiceTypeMixStreamCDN,
    AgoraInvigilatorServiceTypeHostingScene
};

typedef NS_ENUM(NSInteger, AgoraInvigilatorStreamState) {
    AgoraInvigilatorStreamStateOff     = 0,
    AgoraInvigilatorStreamStateOn      = 1
};

typedef NS_ENUM(NSInteger, AgoraInvigilatorRoomType) {
  FcrUISceneTypeOneToOne = 0,
  FcrUISceneTypeSmall = 1,
  FcrUISceneTypeLecture = 2,
  FcrUISceneTypeVocation = 3,
};

NS_ASSUME_NONNULL_END
