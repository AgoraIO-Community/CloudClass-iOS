//
//  AgoraManagerCache.h
//  AgoraEduSDK
//
//  Created by SRS on 2021/2/8.
//

#import <Foundation/Foundation.h>
#import "AgoraEduClassroom.h"
#import "AgoraEduObjects.h"
#import <AgoraWidget/AgoraWidget.h>

NS_ASSUME_NONNULL_BEGIN

@interface AgoraManagerCache : NSObject

+ (instancetype)share;

@property (nonatomic, strong, nullable) AgoraEduClassroom *classroom;
@property (nonatomic, assign) float differTime;
@property (nonatomic, weak, nullable) id<AgoraEduClassroomDelegate> classroomDelegate;

@property (nonatomic, assign) BOOL sdkReady;
@property (nonatomic, copy) NSString *token;
@property (nonatomic, copy) AgoraEduChatTranslationLan lan;

@property (nonatomic, copy) NSString *appId;
@property (nonatomic, copy) NSString *boardAppId;
@property (nonatomic, copy) NSString *userUuid;
@property (nonatomic, copy) NSString *roomUuid;
@property (nonatomic, strong) id roomStateInfoModel;
@property (nonatomic, strong) NSArray<AgoraEduCourseware*> *coursewares;
@property (nonatomic, strong) NSArray<AgoraExtAppConfiguration *> *extApps;
@property (nonatomic, strong) NSArray<AgoraWidgetConfiguration *> *components;

@property (nonatomic, strong, nullable) NSDictionary *collectionStyle;
@property (nonatomic, strong, nullable) NSArray<NSString *> *boardStyles;

@property (nonatomic, strong) AgoraEduVideoEncoderConfiguration *cameraEncoderConfiguration;
+ (void)releaseResource;

@end

NS_ASSUME_NONNULL_END
