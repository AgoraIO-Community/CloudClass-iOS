//
//  AgoraManagerCache.h
//  AgoraEduSDK
//
//  Created by SRS on 2021/2/8.
//

#import <Foundation/Foundation.h>
#import "AgoraEduManager.h"
#import "AgoraHttpModel.h"

NS_ASSUME_NONNULL_BEGIN

@interface AgoraManagerCache : NSObject

+ (instancetype)share;

@property (nonatomic, strong, nullable) AgoraEduClassroom *classroom;
//@property (nonatomic, strong, nullable) AgoraEduReplay *replay;
@property (nonatomic, assign) float differTime;
@property (nonatomic, weak, nullable) id<AgoraEduClassroomDelegate> classroomDelegate;
//@property (nonatomic, weak, nullable) id<AgoraEduReplayDelegate> replayDelegate;

@property (nonatomic, assign) BOOL sdkReady;
@property (nonatomic, copy) NSString *token;
@property (nonatomic, copy) AgoraEduChatTranslationLan lan;

@property (nonatomic, copy) NSString *appId;
@property (nonatomic, copy) NSString *boardAppId;
@property (nonatomic, copy) NSString *userUuid;
@property (nonatomic, copy) NSString *roomUuid;
@property (nonatomic, copy) NSString *urlRegion;
@property (nonatomic, strong) AgoraRoomStateInfoModel *roomStateInfoModel;
@property (nonatomic, strong) NSArray<AgoraEduCourseware*> *coursewares;
@property (nonatomic, strong) NSArray<AgoraExtAppConfiguration *> *extApps;

@property (nonatomic, strong) AgoraEduMediaOptions * _Nullable mediaOptions;

+ (void)releaseResource;

@end

NS_ASSUME_NONNULL_END
