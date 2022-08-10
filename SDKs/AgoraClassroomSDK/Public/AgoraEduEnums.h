//
//  AgoraEduEnums.h
//  AgoraClassroomSDK
//
//  Created by SRS on 2021/1/7.
//

#import <AgoraEduUI/AgoraEduUI-Swift.h>
#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN
// 上台后音视频是否自动发流权限
typedef NS_ENUM(NSInteger, AgoraEduMediaAuthOption) {
    // 无权限
    AgoraEduMediaAuthOptionNone = 0,
    // 仅音频权限
    AgoraEduMediaAuthOptionAudio = 1,
    // 仅视频权限
    AgoraEduMediaAuthOptionVideo = 2,
    // 音频+视频权限
    AgoraEduMediaAuthOptionBoth = 3,
};

typedef NS_ENUM(NSInteger, AgoraEduRegion) {
    // 中国大陆
    AgoraEduRegionCN = 0,
    // 北美
    AgoraEduRegionNA = 1,
    // 欧洲
    AgoraEduRegionEU = 2,
    // 东南亚
    AgoraEduRegionAP = 3
};

typedef NS_ENUM(NSInteger, AgoraEduExitReason) {
    // 正常退出
    AgoraEduExitReasonNormal = 0,
    // 被踢出
    AgoraEduExitReasonKickOut = 1
};

/**加密方式*/
typedef NS_ENUM(NSInteger, AgoraEduMediaEncryptionMode) {
    AgoraEduMediaEncryptionModeNone       = 0,
    /** 1: 128-bit AES encryption, XTS mode. */
    AgoraEduMediaEncryptionModeAES128XTS  = 1,
    /** 2: 128-bit AES encryption, ECB mode. */
    AgoraEduMediaEncryptionModeAES128ECB  = 2,
    /** 3: 256-bit AES encryption, XTS mode. */
    AgoraEduMediaEncryptionModeAES256XTS  = 3,
    /** 4: 128-bit SM4 encryption, ECB mode. */
    AgoraEduMediaEncryptionModeSM4128ECB  = 4,
    /** 5: 128-bit AES encryption, GCM mode.*/
    AgoraEduMediaEncryptionModeAES128GCM  = 5,
    /** 6: 256-bit AES encryption, GCM mode.*/
    AgoraEduMediaEncryptionModeAES256GCM  = 6,
    AgoraEduMediaEncryptionModeAES128GCM2 = 7,
    AgoraEduMediaEncryptionModeAES256GCM2 = 8
};

typedef NS_ENUM(NSInteger, AgoraEduMirrorMode) {
    AgoraEduMirrorModeDisabled = 0,
    AgoraEduMirrorModeEnabled  = 1
};

// RTC 观众延时级别
typedef NS_ENUM(NSInteger, AgoraEduLatencyLevel) {
    AgoraEduLatencyLevelLow      = 1,
    AgoraEduLatencyLevelUltraLow = 2
};

typedef NS_ENUM(NSInteger, AgoraEduUserRole) {
    AgoraEduUserRoleTeacher  = 1,
    AgoraEduUserRoleStudent  = 2,
    AgoraEduUserRoleObserver = 4
};

typedef FcrUISceneType AgoraEduRoomType;

typedef NS_ENUM(NSInteger, AgoraEduServiceType) {
    AgoraEduServiceTypeLivePremium,
    AgoraEduServiceTypeLiveStandard,
    AgoraEduServiceTypeCDN,
    AgoraEduServiceTypeFusion,
    AgoraEduServiceTypeMixStreamCDN,
    AgoraEduServiceTypeHostingScene
};

typedef NS_ENUM(NSInteger, AgoraEduStreamState) {
    AgoraEduStreamStateOff     = 0,
    AgoraEduStreamStateOn      = 1
};

NS_ASSUME_NONNULL_END
