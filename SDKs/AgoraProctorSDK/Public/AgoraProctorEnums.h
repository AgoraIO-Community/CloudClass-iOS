//
//  AgoraProctorEnums.h
//  AgoraClassroomSDK
//
//  Created by SRS on 2021/1/7.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN
// 上台后音视频是否自动发流权限
typedef NS_ENUM(NSInteger, AgoraProctorMediaAuthOption) {
    // 无权限
    AgoraProctorMediaAuthOptionNone = 0,
    // 仅音频权限
    AgoraProctorMediaAuthOptionAudio = 1,
    // 仅视频权限
    AgoraProctorMediaAuthOptionVideo = 2,
    // 音频+视频权限
    AgoraProctorMediaAuthOptionBoth = 3,
};

typedef NS_ENUM(NSInteger, AgoraProctorRegion) {
    // 中国大陆
    AgoraProctorRegionCN = 0,
    // 北美
    AgoraProctorRegionNA = 1,
    // 欧洲
    AgoraProctorRegionEU = 2,
    // 东南亚
    AgoraProctorRegionAP = 3
};

typedef NS_ENUM(NSInteger, AgoraProctorExitReason) {
    // 正常退出
    AgoraProctorExitReasonNormal = 0,
    // 被踢出
    AgoraProctorExitReasonKickOut = 1
};

/**加密方式*/
typedef NS_ENUM(NSInteger, AgoraProctorMediaEncryptionMode) {
    AgoraProctorMediaEncryptionModeNone       = 0,
    /** 1: 128-bit AES encryption, XTS mode. */
    AgoraProctorMediaEncryptionModeAES128XTS  = 1,
    /** 2: 128-bit AES encryption, ECB mode. */
    AgoraProctorMediaEncryptionModeAES128ECB  = 2,
    /** 3: 256-bit AES encryption, XTS mode. */
    AgoraProctorMediaEncryptionModeAES256XTS  = 3,
    /** 4: 128-bit SM4 encryption, ECB mode. */
    AgoraProctorMediaEncryptionModeSM4128ECB  = 4,
    /** 5: 128-bit AES encryption, GCM mode.*/
    AgoraProctorMediaEncryptionModeAES128GCM  = 5,
    /** 6: 256-bit AES encryption, GCM mode.*/
    AgoraProctorMediaEncryptionModeAES256GCM  = 6,
    AgoraProctorMediaEncryptionModeAES128GCM2 = 7,
    AgoraProctorMediaEncryptionModeAES256GCM2 = 8
};

typedef NS_ENUM(NSInteger, AgoraProctorMirrorMode) {
    AgoraProctorMirrorModeDisabled = 0,
    AgoraProctorMirrorModeEnabled  = 1
};

// RTC 观众延时级别
typedef NS_ENUM(NSInteger, AgoraProctorLatencyLevel) {
    AgoraProctorLatencyLevelLow      = 1,
    AgoraProctorLatencyLevelUltraLow = 2
};

typedef NS_ENUM(NSInteger, AgoraProctorUserRole) {
    AgoraProctorUserRoleStudent  = 2
};

typedef NS_ENUM(NSInteger, AgoraProctorServiceType) {
    AgoraProctorServiceTypeLivePremium,
    AgoraProctorServiceTypeLiveStandard,
    AgoraProctorServiceTypeCDN,
    AgoraProctorServiceTypeFusion,
    AgoraProctorServiceTypeMixStreamCDN,
    AgoraProctorServiceTypeHostingScene
};

typedef NS_ENUM(NSInteger, AgoraProctorStreamState) {
    AgoraProctorStreamStateOff     = 0,
    AgoraProctorStreamStateOn      = 1
};

typedef NS_ENUM(NSInteger, AgoraProctorRoomType) {
    AgoraProctorRoomTypeProctor = 6
};

NS_ASSUME_NONNULL_END
