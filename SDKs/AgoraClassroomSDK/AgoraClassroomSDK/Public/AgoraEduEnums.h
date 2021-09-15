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

NS_ASSUME_NONNULL_END
