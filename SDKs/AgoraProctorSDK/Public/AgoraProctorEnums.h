//
//  AgoraProctorEnums.h
//  AgoraClassroomSDK
//
//  Created by SRS on 2021/1/7.
//

#import <AgoraProctorUI/AgoraProctorUI-Swift.h>
#import <AgoraEduCore/AgoraEduCore-Swift.h>
#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

typedef AgoraEduCoreUserRole AgoraProctorUserRole;

typedef AgoraEduCoreLatencyLevel AgoraProctorLatencyLevel;

typedef AgoraEduCoreStreamState AgoraProctorStreamState;

typedef AgoraEduCoreMirrorMode AgoraProctorMirrorMode;

typedef AgoraEduCoreRegion AgoraProctorRegion;

typedef AgoraEduCoreMediaEncryptionMode AgoraProctorMediaEncryptionMode;


typedef NS_ENUM(NSInteger, AgoraProctorExitReason) {
    // 正常退出
    AgoraProctorExitReasonNormal = 0,
    // 被踢出
    AgoraProctorExitReasonKickOut = 1
};

NS_ASSUME_NONNULL_END
