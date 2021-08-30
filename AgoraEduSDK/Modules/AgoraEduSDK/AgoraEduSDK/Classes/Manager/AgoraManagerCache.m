//
//  AgoraManagerCache.m
//  AgoraEduSDK
//
//  Created by SRS on 2021/2/8.
//

#import "AgoraManagerCache.h"

static AgoraManagerCache *manager = nil;

@implementation AgoraManagerCache
+ (instancetype)share {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        manager = [[AgoraManagerCache alloc] init];
        manager.sdkReady = NO;
        manager.differTime = 0;
        manager.lan = AgoraEduChatTranslationLanAUTO;
        manager.coursewares = @[];
        manager.cameraEncoderConfiguration = [AgoraEduVideoEncoderConfiguration new];
    });
    return manager;
}

+ (void)releaseResource {
    AgoraManagerCache.share.classroom = nil;
    AgoraManagerCache.share.classroomDelegate = nil;
    AgoraManagerCache.share.token = nil;
    AgoraManagerCache.share.sdkReady = NO;
    
    AgoraManagerCache.share.boardAppId = @"";
    AgoraManagerCache.share.coursewares = @[];
    AgoraManagerCache.share.extApps = nil;
    AgoraManagerCache.share.components = nil;
    
    AgoraManagerCache.share.collectionStyle = nil;
    AgoraManagerCache.share.boardStyles = nil;
    
    AgoraManagerCache.share.cameraEncoderConfiguration = [AgoraEduVideoEncoderConfiguration new];
}
@end
