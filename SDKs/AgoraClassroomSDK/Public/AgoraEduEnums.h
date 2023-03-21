//
//  AgoraEduEnums.h
//  AgoraClassroomSDK
//
//  Created by SRS on 2021/1/7.
//

#import <AgoraEduCore/AgoraEduCore-Swift.h>
#import <AgoraEduUI/AgoraEduUI-Swift.h>
#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

typedef FcrUISceneExitReason AgoraEduExitReason;

typedef FcrUISceneType AgoraEduRoomType;

typedef AgoraEduCoreUserRole AgoraEduUserRole;

typedef AgoraEduCoreLatencyLevel AgoraEduLatencyLevel;

typedef AgoraEduCoreStreamState AgoraEduStreamState;

typedef AgoraEduCoreMirrorMode AgoraEduMirrorMode;

typedef AgoraEduCoreRegion AgoraEduRegion;

typedef AgoraEduCoreMediaEncryptionMode AgoraEduMediaEncryptionMode;

typedef AgoraEduCoreVideoOutputOrientationMode AgoraEduVideoOutputOrientationMode;

typedef NS_ENUM(NSInteger, AgoraEduServiceType) {
    AgoraEduServiceTypeLivePremium,
    AgoraEduServiceTypeLiveStandard,
    AgoraEduServiceTypeCDN,
    AgoraEduServiceTypeFusion,
    AgoraEduServiceTypeMixStreamCDN,
    AgoraEduServiceTypeHostingScene
};

NS_ASSUME_NONNULL_END
