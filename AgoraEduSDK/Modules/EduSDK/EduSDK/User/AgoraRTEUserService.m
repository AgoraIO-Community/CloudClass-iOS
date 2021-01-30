//
//  AgoraRTEUserService.m
//  Demo
//
//  Created by SRS on 2020/6/17.
//  Copyright © 2020 agora. All rights reserved.
//

#import "AgoraRTEUserService.h"
#import "AgoraRTEClassroomConfig.h"
#import "AgoraRTEClassroomMediaOptions.h"
#import "AgoraRTEHttpManager.h"
#import "AgoraRTCManager.h"
#import "AgoraRTEStream.h"
#import "AgoraRTEConstants.h"
#import "AgoraRTEStream+ConvenientInit.h"
#import "AgoraRTEPublishModel.h"
#import "AgoraRTECommonModel.h"
#import "AgoraRTELogService.h"
#import "AgoraRTESyncRoomSession.h"

#import "AgoraRTESyncRoomModel.h"
#import "AgoraRTESyncStreamModel.h"
#import "AgoraRTESyncUserModel.h"
#import "AgoraRTEErrorManager.h"

#import "AgoraRTEChannelMessageHandle.h"
#import "AgoraRTEKVCUserConfig.h"

@implementation AgoraRTERenderConfig
@end

typedef NS_ENUM(NSUInteger, StreamState) {
    StreamStateCreate,
    StreamStateUpdate,
    StreamStateDelete,
};

@interface AgoraRTEUserService()<AgoraRTCStreamStateDelegate, AgoraRTCSpeakerReportDelegate>
@property (nonatomic, strong) NSMutableArray<AgoraRtcVideoCanvas*> *rtcVideoCanvasList;

@property (nonatomic, strong) NSString *channelId;
@property (nonatomic, strong) NSString *userToken;
@property (nonatomic, strong) AgoraRTEClassroomMediaOptions *mediaOption;

@property (nonatomic, strong) AgoraRTEChannelMessageHandle *messageHandle;

@end

@implementation AgoraRTEUserService
- (instancetype)initWithConfig:(AgoraRTEKVCUserConfig *)config {
    self = [super init];
    if (self) {
        self.channelId = config.roomUuid;
        self.messageHandle = config.messageHandle;
        self.mediaOption = config.mediaOption;
        self.userToken = config.userToken;
        
        AgoraRTCChannelDelegateConfig *config = [AgoraRTCChannelDelegateConfig new];
        config.streamStateDelegate = self;
        AgoraRTCManager.shareManager.speakerReportDelegate = self;

        [AgoraRTCManager.shareManager setChannelDelegateWithConfig:config channelId:self.channelId];
        
        self.rtcVideoCanvasList = [NSMutableArray array];
        WEAK(self);
        self.messageHandle.checkAutoSubscribe = ^(NSArray<AgoraRTEStream *> * _Nonnull streams, BOOL state) {
        
            if (weakself.mediaOption.autoSubscribe) {
                return;
            }

            for(AgoraRTEStream *stream in streams) {
               if(state != 0) {
                   EduSubscribeOptions *options = [EduSubscribeOptions new];
                   options.subscribeAudio = YES;
                   options.subscribeVideo = YES;
                   options.videoStreamType = AgoraRTEVideoStreamTypeLow;
                   [weakself subscribeStream:stream options:options success:^{
                       
                   } failure:^(NSError * _Nonnull error) {
                       
                   }];
               }
            }
        };
        
        self.messageHandle.checkStreamPublish = ^(AgoraRTEStream * _Nonnull stream, AgoraRTEStreamAction action) {
            
            if (action == AgoraRTEStreamCreate || action == AgoraRTEStreamUpdate) {
                [AgoraRTCManager.shareManager enableLocalVideo:stream.hasVideo];
                [AgoraRTCManager.shareManager enableLocalAudio:stream.hasAudio];
                [AgoraRTCManager.shareManager muteLocalVideoStream:!stream.hasVideo];
                [AgoraRTCManager.shareManager muteLocalAudioStream:!stream.hasAudio];
                [AgoraRTCManager.shareManager publishChannelId:weakself.channelId];
            } else {
                [AgoraRTCManager.shareManager enableLocalVideo:NO];
                [AgoraRTCManager.shareManager enableLocalAudio:NO];
                [AgoraRTCManager.shareManager muteLocalVideoStream:YES];
                [AgoraRTCManager.shareManager muteLocalAudioStream:YES];
                [AgoraRTCManager.shareManager unPublishChannelId:weakself.channelId];
            }
        };
    }
    return self;
}

- (NSError * _Nullable)setVideoConfig:(AgoraRTEVideoConfig*)config {
    
    [AgoraRTELogService logMessageWithDescribe:@"user setVideoConfig:" message:@{@"roomUuid":NoNullString(self.channelId), @"config":NoNull(config)}];
    
    AgoraVideoEncoderConfiguration *configuration = [AgoraVideoEncoderConfiguration new];
    configuration.dimensions = CGSizeMake(config.videoDimensionWidth, config.videoDimensionHeight);
    configuration.frameRate = config.frameRate;
    configuration.bitrate = config.bitrate;
    configuration.orientationMode = AgoraVideoOutputOrientationModeAdaptative;
    
    switch (config.degradationPreference) {
        case AgoraRTEDegradationMaintainQuality:
            configuration.degradationPreference = AgoraDegradationMaintainQuality;
            break;
        case AgoraRTEDegradationMaintainFramerate:
            configuration.orientationMode = AgoraDegradationMaintainFramerate;
            break;
        case AgoraRTEDegradationBalanced:
            configuration.orientationMode = AgoraDegradationBalanced;
            break;
        default:
            break;
    }
    
    NSInteger errCode = [AgoraRTCManager.shareManager setVideoEncoderConfiguration:configuration];
    if(errCode == 0) {
        return nil;
    }
    
    return [AgoraRTEErrorManager mediaError:errCode codeMsg:[AgoraRTCManager getErrorDescription:errCode] code:201];
}

// media
- (void)startOrUpdateLocalStream:(AgoraRTEStreamConfig*)config success:(OnUserMediaChangedSuccessBlock)successBlock failure:(AgoraRTEFailureBlock)failureBlock {
    
    NSError *error;
    if(![config isKindOfClass:AgoraRTEStreamConfig.class]) {
        error = [AgoraRTEErrorManager paramterInvalid:@"config" code:1];
    } else {
        error = [AgoraRTEErrorManager paramterEmptyError:@"streamUuid" value:config.streamUuid code:1];
    }
    if(error) {
        if(failureBlock) {
            failureBlock(error);
        }
        return;
    }
    
    [AgoraRTELogService logMessageWithDescribe:@"user startOrUpdateLocalStream:" message:@{@"roomUuid":NoNullString(self.channelId), @"config":NoNull(config)}];
    
    int code = [AgoraRTCManager.shareManager enableLocalVideo:config.enableCamera];
    if (code != 0) {
        NSError *error = [AgoraRTEErrorManager mediaError:code codeMsg:[AgoraRTCManager getErrorDescription:code] code:201];
        if(failureBlock) {
            failureBlock(error);
        }
        return;
    }
    code = [AgoraRTCManager.shareManager enableLocalAudio:config.enableMicrophone];
    if (code != 0) {
        NSError *error = [AgoraRTEErrorManager mediaError:code codeMsg:[AgoraRTCManager getErrorDescription:code] code:201];
        if(failureBlock) {
            failureBlock(error);
        }
        return;
    }
    
    if (config.enableCamera || config.enableMicrophone) {
        [AgoraRTCManager.shareManager setClientRole:AgoraClientRoleBroadcaster channelId:self.channelId];
    } else {
//        [AgoraRTCManager.shareManager setClientRole:AgoraClientRoleAudience channelId:self.channelId];
    }
    
    AgoraRTESyncUserModel *userModel = self.messageHandle.syncRoomSession.localUser;
    AgoraRTEStream *stream = [[AgoraRTEStream alloc] initWithStreamUuid:NoNullString(config.streamUuid) streamName:NoNullString(config.streamName) sourceType:AgoraRTEVideoSourceTypeCamera hasVideo:config.enableCamera hasAudio:config.enableMicrophone user:[userModel mapAgoraRTEBaseUser]];
    
    // 找到流 update
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"streamUuid in %@", config.streamUuid];
    NSArray<AgoraRTEBaseSnapshotStreamModel*> *filteredArray = [self.messageHandle.syncRoomSession.localUser.streams filteredArrayUsingPredicate:predicate];
    if (filteredArray.count > 0) {
        
    } else {
        [AgoraRTCManager.shareManager startPreview];
    }
    
    if(successBlock) {
        successBlock(stream);
    }
}

- (NSError * _Nullable)switchCamera {
    
    int errCode = [AgoraRTCManager.shareManager switchCamera];
    if(errCode == 0) {
        return nil;
    } else {
        NSError *error = [AgoraRTEErrorManager mediaError:errCode codeMsg:[AgoraRTCManager getErrorDescription:errCode] code:201];
        return error;
    }
}

// stream
- (void)subscribeStream:(AgoraRTEStream*)stream options:(EduSubscribeOptions*)options success:(AgoraRTESuccessBlock)successBlock failure:(AgoraRTEFailureBlock _Nullable)failureBlock {
    
    NSError *error;
    if (![stream isKindOfClass:AgoraRTEStream.class]) {
        error = [AgoraRTEErrorManager paramterInvalid:@"stream" code:1];
    } else {
        error = [AgoraRTEErrorManager paramterEmptyError:@"streamUuid" value:stream.streamUuid code:1];
    }
    if(error) {
        if(failureBlock) {
            failureBlock(error);
        }
        return;
    }
    
    if(options.subscribeAudio){
        [AgoraRTCManager.shareManager muteRemoteAudioStream:stream.streamUuid mute:!options.subscribeAudio channelId:self.channelId];
    }
    if(options.subscribeVideo) {
        [AgoraRTCManager.shareManager muteRemoteVideoStream:stream.streamUuid mute:!options.subscribeVideo channelId:self.channelId];
        
        AgoraVideoStreamType type = AgoraVideoStreamTypeLow;
        if(options.videoStreamType == AgoraRTEVideoStreamTypeHigh) {
            type = AgoraVideoStreamTypeHigh;
        }
        [AgoraRTCManager.shareManager setRemoteVideoStream:stream.streamUuid type:type];
    }
    
    if(successBlock) {
        successBlock();
    }
}

- (void)unsubscribeStream:(AgoraRTEStream*)stream options:(EduSubscribeOptions*) options success:(AgoraRTESuccessBlock)successBlock failure:(AgoraRTEFailureBlock _Nullable)failureBlock {
    
    NSError *error;
    if (![stream isKindOfClass:AgoraRTEStream.class]) {
        error = [AgoraRTEErrorManager paramterInvalid:@"stream" code:1];
    } else {
        error = [AgoraRTEErrorManager paramterEmptyError:@"streamUuid" value:stream.streamUuid code:1];
    }
    if(error) {
        if(failureBlock) {
            failureBlock(error);
        }
        return;
    }
    
    if(!options.subscribeAudio){
        [AgoraRTCManager.shareManager muteRemoteAudioStream:stream.streamUuid mute:!options.subscribeAudio channelId:self.channelId];
    }
    if(!options.subscribeVideo){
        [AgoraRTCManager.shareManager muteRemoteVideoStream:stream.streamUuid mute:!options.subscribeVideo channelId:self.channelId];
    }
    
    if(successBlock) {
        successBlock();
    }
}

- (void)publishStream:(AgoraRTEStream*)stream success:(AgoraRTESuccessBlock)successBlock failure:(AgoraRTEFailureBlock _Nullable)failureBlock {
    
    NSError *error;
    if (![stream isKindOfClass:AgoraRTEStream.class]) {
        error = [AgoraRTEErrorManager paramterInvalid:@"stream" code:1];
    } else {
        error = [AgoraRTEErrorManager paramterEmptyError:@"streamUuid" value:stream.streamUuid code:1];
    }
    if(error) {
        if(failureBlock) {
            failureBlock(error);
        }
        return;
    }

    WEAK(self);
    StreamState state = StreamStateCreate;
    [self updateStreamWithState:state stream:stream success:^{
        
        if([stream.userInfo.userUuid isEqualToString:weakself.messageHandle.syncRoomSession.localUser.userUuid]) {
         
            [AgoraRTCManager.shareManager muteLocalAudioStream:!stream.hasAudio];
            [AgoraRTCManager.shareManager muteLocalVideoStream:!stream.hasVideo];
            [AgoraRTCManager.shareManager publishChannelId:weakself.channelId];
        }
        
        if(successBlock) {
            successBlock();
        }
    } failure:failureBlock];
}

- (void)muteStream:(AgoraRTEStream*)stream success:(AgoraRTESuccessBlock)successBlock failure:(AgoraRTEFailureBlock _Nullable)failureBlock {
    
    NSError *error;
    if (![stream isKindOfClass:AgoraRTEStream.class]) {
        error = [AgoraRTEErrorManager paramterInvalid:@"stream" code:1];
    } else {
        error = [AgoraRTEErrorManager paramterEmptyError:@"streamUuid" value:stream.streamUuid code:1];
    }
    if(error) {
        if(failureBlock) {
            failureBlock(error);
        }
        return;
    }

    if([stream.userInfo.userUuid isEqualToString:self.messageHandle.syncRoomSession.localUser.userUuid]) {
        [AgoraRTCManager.shareManager muteLocalAudioStream:!stream.hasAudio];
        [AgoraRTCManager.shareManager muteLocalVideoStream:!stream.hasVideo];
    }
    
    [self updateStreamWithState:StreamStateUpdate stream:stream success:^{
        if(successBlock) {
            successBlock();
        }
    } failure:failureBlock];
}
- (void)unpublishStream:(AgoraRTEStream*)stream success:(AgoraRTESuccessBlock)successBlock failure:(AgoraRTEFailureBlock _Nullable)failureBlock {
    
    NSError *error;
    if (![stream isKindOfClass:AgoraRTEStream.class]) {
        error = [AgoraRTEErrorManager paramterInvalid:@"stream" code:1];
    } else {
        error = [AgoraRTEErrorManager paramterEmptyError:@"streamUuid" value:stream.streamUuid code:1];
    }
    if(error) {
        if(failureBlock) {
            failureBlock(error);
        }
        return;
    }

    if([stream.userInfo.userUuid isEqualToString:self.messageHandle.syncRoomSession.localUser.userUuid]) {
     
        [AgoraRTCManager.shareManager muteLocalAudioStream:YES];
        [AgoraRTCManager.shareManager muteLocalVideoStream:YES];
        [AgoraRTCManager.shareManager unPublishChannelId:self.channelId];
    }
    
    StreamState state = StreamStateDelete;
    [self updateStreamWithState:state stream:stream success:successBlock failure:failureBlock];
}

// message
- (void)sendRoomMessageWithText:(NSString*)text success:(AgoraRTESuccessBlock)successBlock failure:(AgoraRTEFailureBlock)failureBlock {
    
    NSError *error = [AgoraRTEErrorManager paramterEmptyError:@"text" value:text code:1];
    if(error) {
        if(failureBlock) {
            failureBlock(error);
        }
        return;
    }
    
    NSMutableDictionary *param = [NSMutableDictionary dictionary];
    param[@"message"] = text;
    [AgoraRTEHttpManager roomMsgWithRoomUuid:self.channelId userToken:self.userToken param:param apiVersion:APIVersion1 analysisClass:AgoraRTECommonModel.class success:^(id<AgoraRTEBaseModel>  _Nullable objModel) {
        if(successBlock){
            successBlock();
        }
        
    } failure:^(NSError * _Nullable error, NSInteger statusCode) {
        NSError *eduError = [AgoraRTEErrorManager networkError:error.code codeMsg:error.localizedDescription code:301];
        if(failureBlock != nil) {
            failureBlock(eduError);
        }
    }];
}
- (void)sendUserMessageWithText:(NSString*)text remoteUser:(AgoraRTEUser *)remoteUser success:(AgoraRTESuccessBlock)successBlock failure:(AgoraRTEFailureBlock)failureBlock {
    
    NSError *error;
    if (![remoteUser isKindOfClass:AgoraRTEUser.class]) {
        error = [AgoraRTEErrorManager paramterInvalid:@"remoteUser" code:1];
    } else {
        error = [AgoraRTEErrorManager paramterEmptyError:@"streamUuid" value:remoteUser.streamUuid code:1];
    }
    if(error == nil) {
        error = [AgoraRTEErrorManager paramterEmptyError:@"userUuid" value:remoteUser.userUuid code:1];
    }
    if(error == nil) {
        error = [AgoraRTEErrorManager paramterEmptyError:@"text" value:text code:1];
    }
    if(error == nil) {
        if([remoteUser.userUuid isEqualToString:self.messageHandle.syncRoomSession.localUser.userUuid]) {
            error = [AgoraRTEErrorManager internalError:@"cannot send message to yourself" code:1];
        }
    }
    if(error) {
        if(failureBlock) {
            failureBlock(error);
        }
        return;
    }
    
    NSMutableDictionary *param = [NSMutableDictionary dictionary];
    param[@"message"] = text;
    [AgoraRTEHttpManager userMsgWithRoomUuid:self.channelId userToken:self.userToken userUuid:remoteUser.userUuid param:param apiVersion:APIVersion1 analysisClass:AgoraRTECommonModel.class success:^(id<AgoraRTEBaseModel>  _Nullable objModel) {
        
        if(successBlock){
            successBlock();
        }
    } failure:^(NSError * _Nullable error, NSInteger statusCode) {
        NSError *eduError = [AgoraRTEErrorManager networkError:error.code codeMsg:error.localizedDescription code:301];
        if(failureBlock != nil) {
            failureBlock(eduError);
        }
    }];
}

- (void)sendRoomChatMessageWithText:(NSString*)text success:(AgoraRTESuccessBlock)successBlock failure:(AgoraRTEFailureBlock _Nullable)failureBlock {
    
    NSError *error = [AgoraRTEErrorManager paramterEmptyError:@"text" value:text code:1];
    if(error) {
        if(failureBlock) {
            failureBlock(error);
        }
        return;
    }

    NSMutableDictionary *param = [NSMutableDictionary dictionary];
    param[@"message"] = text;
    param[@"type"] = @1;;
    [AgoraRTEHttpManager roomChatWithRoomUuid:self.channelId userToken:self.userToken param:param apiVersion:APIVersion1 analysisClass:AgoraRTECommonModel.class success:^(id<AgoraRTEBaseModel>  _Nullable objModel) {
        if(successBlock){
            successBlock();
        }
        
    } failure:^(NSError * _Nullable error, NSInteger statusCode) {
        NSError *eduError = [AgoraRTEErrorManager networkError:error.code codeMsg:error.localizedDescription code:301];
        if(failureBlock != nil) {
            failureBlock(eduError);
        }
    }];
}

- (void)sendUserChatMessageWithText:(NSString*)text remoteUser:(AgoraRTEUser *)remoteUser success:(AgoraRTESuccessBlock)successBlock failure:(AgoraRTEFailureBlock _Nullable)failureBlock {
    
    NSError *error;
    if (![remoteUser isKindOfClass:AgoraRTEUser.class]) {
        error = [AgoraRTEErrorManager paramterInvalid:@"remoteUser" code:1];
    } else {
        error = [AgoraRTEErrorManager paramterEmptyError:@"streamUuid" value:remoteUser.streamUuid code:1];
    }
    if(error == nil) {
        error = [AgoraRTEErrorManager paramterEmptyError:@"userUuid" value:remoteUser.userUuid code:1];
    }
    if(error == nil) {
        error = [AgoraRTEErrorManager paramterEmptyError:@"text" value:text code:1];
    }
    if(error == nil) {
        if([remoteUser.userUuid isEqualToString:self.messageHandle.syncRoomSession.localUser.userUuid]) {
            error = [AgoraRTEErrorManager internalError:@"cannot chat with yourself" code:1];
        }
    }
    if(error) {
        if(failureBlock) {
            failureBlock(error);
        }
        return;
    }
    
    NSMutableDictionary *param = [NSMutableDictionary dictionary];
    param[@"message"] = text;
    param[@"type"] = @1;
    [AgoraRTEHttpManager userChatWithRoomUuid:self.channelId userToken:self.userToken userUuid:remoteUser.userUuid param:param apiVersion:APIVersion1 analysisClass:AgoraRTECommonModel.class success:^(id<AgoraRTEBaseModel>  _Nullable objModel) {
        
        if(successBlock){
            successBlock();
        }
    } failure:^(NSError * _Nullable error, NSInteger statusCode) {
        NSError *eduError = [AgoraRTEErrorManager networkError:error.code codeMsg:error.localizedDescription code:301];
        if(failureBlock != nil) {
            failureBlock(eduError);
        }
    }];
}

// property
- (void)setRoomProperties:(NSDictionary *)properties cause:(AgoraRTEObject * _Nullable)cause success:(AgoraRTESuccessBlock)successBlock failure:(AgoraRTEFailureBlock _Nullable)failureBlock {
    
    if(![properties isKindOfClass:NSDictionary.class] || properties.allKeys.count == 0) {
        NSError *error = [AgoraRTEErrorManager paramterInvalid:@"properties" code:1];
        if(error) {
            if(failureBlock) {
                failureBlock(error);
            }
            return;
        }
    }
    
    NSMutableDictionary *param = [NSMutableDictionary dictionary];
    if (properties != nil) {
        param[@"properties"] = properties;
    }
    if (cause != nil) {
        param[@"cause"] = cause;
    }
    [AgoraRTEHttpManager setRoomPropertiesWithRoomUuid:self.channelId userToken:self.userToken param:param apiVersion:APIVersion1 analysisClass:AgoraRTECommonModel.class success:^(id<AgoraRTEBaseModel>  _Nonnull objModel) {
            
        if(successBlock){
            successBlock();
        }
        
    } failure:^(NSError * _Nullable error, NSInteger statusCode) {
        NSError *eduError = [AgoraRTEErrorManager networkError:error.code codeMsg:error.localizedDescription code:301];
        if(failureBlock != nil) {
            failureBlock(eduError);
        }
    }];
}
- (void)deleteRoomProperties:(NSArray<NSString *> *)keys cause:(AgoraRTEObject * _Nullable)cause success:(AgoraRTESuccessBlock)successBlock failure:(AgoraRTEFailureBlock _Nullable)failureBlock {
    
    if(![keys isKindOfClass:NSArray.class] || keys.count == 0) {
        NSError *error = [AgoraRTEErrorManager paramterInvalid:@"keys" code:1];
        if(error) {
            if(failureBlock) {
                failureBlock(error);
            }
            return;
        }
    }
    
    NSMutableDictionary *param = [NSMutableDictionary dictionary];
    if (keys != nil) {
        param[@"properties"] = keys;
    }
    if (cause != nil) {
        param[@"cause"] = cause;
    }
    [AgoraRTEHttpManager deleteRoomPropertiesWithRoomUuid:self.channelId userToken:self.userToken param:param apiVersion:APIVersion1 analysisClass:AgoraRTECommonModel.class success:^(id<AgoraRTEBaseModel>  _Nonnull objModel) {
            
        if(successBlock){
            successBlock();
        }
        
    } failure:^(NSError * _Nullable error, NSInteger statusCode) {
        NSError *eduError = [AgoraRTEErrorManager networkError:error.code codeMsg:error.localizedDescription code:301];
        if(failureBlock != nil) {
            failureBlock(eduError);
        }
    }];
}

// render
- (NSError * _Nullable)setStreamView:(UIView * _Nullable)view stream:(AgoraRTEStream *)stream {
    
    AgoraRTERenderConfig *config = [AgoraRTERenderConfig new];
    config.renderMode = AgoraRTERenderModeHidden;
    return [self setStreamView:view stream:stream renderConfig:config];
}
- (NSError * _Nullable)setStreamView:(UIView * _Nullable)view stream:(AgoraRTEStream *)stream renderConfig:(AgoraRTERenderConfig*)config {

    NSError *error;
    if (![stream isKindOfClass:AgoraRTEStream.class]) {
        error = [AgoraRTEErrorManager paramterInvalid:@"stream" code:1];
        
    } else if (![config isKindOfClass:AgoraRTERenderConfig.class]) {
        error = [AgoraRTEErrorManager paramterInvalid:@"action" code:1];
        
    } else if(config.renderMode != AgoraRTERenderModeHidden && config.renderMode != AgoraRTERenderModeFit) {
        error = [AgoraRTEErrorManager paramterInvalid:@"renderMode" code:1];
    } else {
        error = [AgoraRTEErrorManager paramterEmptyError:@"" value:stream.streamUuid code:1];
    }
    if(error) {
        return error;
    }
    
    NSMutableArray<AgoraRtcVideoCanvas *> *removeArray = [NSMutableArray array];
    
    // 去重复
    for (AgoraRtcVideoCanvas *videoCanvas in self.rtcVideoCanvasList) {
        if(!view) {
            if(videoCanvas.uid == stream.streamUuid.integerValue) {
                [removeArray addObject:videoCanvas];
                return nil;
            }
        } else if(videoCanvas.view == view) {
            if(videoCanvas.uid == stream.streamUuid.integerValue) {
                return nil;
            }
            [removeArray addObject:videoCanvas];
            
        } else if(videoCanvas.uid == stream.streamUuid.integerValue) {
            [removeArray addObject:videoCanvas];
        }
    }
    
    for (AgoraRtcVideoCanvas *videoCanvas in removeArray) {
        [self removeVideoCanvas:videoCanvas];
    }
    [removeArray removeAllObjects];
    
    AgoraRtcVideoCanvas *videoCanvas = [[AgoraRtcVideoCanvas alloc] init];
    videoCanvas.uid = [stream.streamUuid integerValue];;
    videoCanvas.view = view;
    videoCanvas.channel = self.channelId;
    if (config.renderMode == AgoraRTERenderModeFit) {
        videoCanvas.renderMode = AgoraVideoRenderModeFit;
    } else if (config.renderMode == AgoraRTERenderModeHidden) {
        videoCanvas.renderMode = AgoraVideoRenderModeHidden;
    }
    
    [self.rtcVideoCanvasList addObject:videoCanvas];
        
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
    
        AgoraRTESyncUserModel *localUser = self.messageHandle.syncRoomSession.localUser;
        if([localUser.streamUuid isEqualToString:stream.streamUuid]) {
            [AgoraRTCManager.shareManager setupLocalVideo: videoCanvas];
        } else {
            [AgoraRTCManager.shareManager setupRemoteVideo: videoCanvas];
        }
    });
    
    return nil;
}

- (void)removeVideoCanvas:(AgoraRtcVideoCanvas *)videoCanvas {
    
    videoCanvas.view = nil;
    
    AgoraRTESyncUserModel *localUser = self.messageHandle.syncRoomSession.localUser;
    if([localUser.streamUuid isEqualToString:@(videoCanvas.uid).stringValue]) {
        [AgoraRTCManager.shareManager setupLocalVideo: videoCanvas];
    } else {
        [AgoraRTCManager.shareManager setupRemoteVideo: videoCanvas];
    }
    
    [AgoraRTELogService logMessageWithDescribe:@"user removeVideoCanvas:" message:@{@"roomUuid":NoNullString(self.channelId), @"streamUuid":@(videoCanvas.uid)}];
    
    [self.rtcVideoCanvasList removeObject:videoCanvas];
}

#pragma mark - AgoraRTCStreamStateDelegate
- (void)rtcLocalAudioStateChange:(AgoraAudioLocalState)state
                           error:(AgoraAudioLocalError)error {
    if ([self.mediaStreamDelegate respondsToSelector:@selector(didChangeOfLocalAudioStream:withState:)]) {
        AgoraRTEStreamState eduState = [self getAgoraRTEStreamStateWithLocalAudio:state];
        AgoraRTESyncUserModel *user = (AgoraRTESyncUserModel*)self.messageHandle.syncRoomSession.localUser;
        [self.mediaStreamDelegate didChangeOfLocalAudioStream:user.streamUuid
                                  withState:eduState];
    }
}
- (void)rtcLocalVideoStateChange:(AgoraLocalVideoStreamState)state
                           error:(AgoraLocalVideoStreamError)error {
    if ([self.mediaStreamDelegate respondsToSelector:@selector(didChangeOfLocalVideoStream:withState:)]) {
        AgoraRTEStreamState eduState = [self getAgoraRTEStreamStateWithLocalVideo:state];
        AgoraRTESyncUserModel *user = (AgoraRTESyncUserModel*)self.messageHandle.syncRoomSession.localUser;
        [self.mediaStreamDelegate didChangeOfLocalVideoStream:user.streamUuid
                                  withState:eduState];
    }
}
- (void)rtcReportAudioVolumeIndicationOfLocalSpeaker:(AgoraRtcAudioVolumeInfo *)speaker {
    
    if ([self.mediaStreamDelegate respondsToSelector:@selector(audioVolumeIndicationOfLocalStream:withVolume:)]) {
        
        NSString *streamId = [NSString stringWithFormat:@"%lu", (unsigned long)speaker.uid];
        
        [self.mediaStreamDelegate audioVolumeIndicationOfLocalStream:streamId withVolume:speaker.volume];
    }
}

- (void)rtcRemoteAudioStateChangedOfUid:(NSUInteger)uid
                                  state:(AgoraAudioRemoteState)state
                                 reason:(AgoraAudioRemoteStateReason)reason
                                elapsed:(NSInteger)elapsed {
    if ([self.mediaStreamDelegate respondsToSelector:@selector(didChangeOfRemoteAudioStream:withState:)]) {
        AgoraRTEStreamState eduState = [self getAgoraRTEStreamStateWithRemoteAudio:state];
        NSString *streamId = [NSString stringWithFormat:@"%lu", (unsigned long)uid];
        [self.mediaStreamDelegate didChangeOfRemoteAudioStream:streamId
                                  withState:eduState];
    }
}

- (void)rtcRemoteVideoStateChangedOfUid:(NSUInteger)uid
                                  state:(AgoraVideoRemoteState)state
                                 reason:(AgoraVideoRemoteStateReason)reason
                                elapsed:(NSInteger)elapsed {
    if ([self.mediaStreamDelegate respondsToSelector:@selector(didChangeOfRemoteVideoStream:withState:)]) {
        AgoraRTEStreamState eduState = [self getAgoraRTEStreamStateWithRemoteVideo:state];
        NSString *streamId = [NSString stringWithFormat:@"%lu", (unsigned long)uid];
        [self.mediaStreamDelegate didChangeOfRemoteVideoStream:streamId
                                  withState:eduState];
    }
}

- (void)rtcReportAudioVolumeIndicationOfRemoteSpeaker:(AgoraRtcAudioVolumeInfo *)speaker {
    
    if ([self.mediaStreamDelegate respondsToSelector:@selector(audioVolumeIndicationOfRemoteStream:withVolume:)]) {
        
        NSString *streamId = [NSString stringWithFormat:@"%lu", (unsigned long)speaker.uid];
        
        [self.mediaStreamDelegate audioVolumeIndicationOfRemoteStream:streamId withVolume:speaker.volume];
    }
}
#pragma mark Private
- (void)setMediaStreamDelegate:(id<AgoraRTEMediaStreamDelegate>)mediaStreamDelegate {
    _mediaStreamDelegate = mediaStreamDelegate;
    
    if ([_mediaStreamDelegate respondsToSelector:@selector(audioVolumeIndicationOfLocalStream:withVolume:)]) {
        [AgoraRTCManager.shareManager enableAudioVolumeIndication:300 smooth:3 report_vad:YES];
        
    } else if ([_mediaStreamDelegate respondsToSelector:@selector(audioVolumeIndicationOfRemoteStream:withVolume:)]) {
        [AgoraRTCManager.shareManager enableAudioVolumeIndication:300 smooth:3 report_vad:NO];
    }
}

- (AgoraRTEStreamState)getAgoraRTEStreamStateWithLocalVideo:(AgoraLocalVideoStreamState)rtc {
    switch (rtc) {
        case AgoraLocalVideoStreamStateStopped:
            return AgoraRTEStreamStateStopped;
            break;
        case AgoraLocalVideoStreamStateCapturing:
            return AgoraRTEStreamStateStarting;
            break;
        case AgoraLocalVideoStreamStateEncoding:
            return AgoraRTEStreamStateRunning;
            break;
        case AgoraLocalVideoStreamStateFailed:
            return AgoraRTEStreamStateFailed;
            break;
    }
}

- (AgoraRTEStreamState)getAgoraRTEStreamStateWithLocalAudio:(AgoraAudioLocalState)rtc {
    switch (rtc) {
        case AgoraAudioLocalStateStopped:
            return AgoraRTEStreamStateStopped;
            break;
        case AgoraAudioLocalStateRecording:
            return AgoraRTEStreamStateStarting;
            break;
        case AgoraAudioLocalStateEncoding:
            return AgoraRTEStreamStateRunning;
            break;
        case AgoraAudioLocalStateFailed:
            return AgoraRTEStreamStateFailed;
            break;
    }
}

- (AgoraRTEStreamState)getAgoraRTEStreamStateWithRemoteVideo:(AgoraVideoRemoteState)rtc {
    switch (rtc) {
        case AgoraVideoRemoteStateStopped:
            return AgoraRTEStreamStateStopped;
            break;
        case AgoraVideoRemoteStateStarting:
            return AgoraRTEStreamStateStarting;
            break;
        case AgoraVideoRemoteStateDecoding:
            return AgoraRTEStreamStateRunning;
            break;
        case AgoraVideoRemoteStateFrozen:
            return AgoraRTEStreamStateFrozen;
            break;
        case AgoraVideoRemoteStateFailed:
            return AgoraRTEStreamStateFailed;
            break;
    }
}

- (AgoraRTEStreamState)getAgoraRTEStreamStateWithRemoteAudio:(AgoraAudioRemoteState)rtc {
    switch (rtc) {
        case AgoraAudioRemoteStateStopped:
            return AgoraRTEStreamStateStopped;
            break;
        case AgoraAudioRemoteStateStarting:
            return AgoraRTEStreamStateStarting;
            break;
        case AgoraAudioRemoteStateDecoding:
            return AgoraRTEStreamStateRunning;
            break;
        case AgoraAudioRemoteStateFrozen:
            return AgoraRTEStreamStateFrozen;
            break;
        case AgoraAudioRemoteStateFailed:
            return AgoraRTEStreamStateFailed;
            break;
    }
}
- (void)updateStreamWithState:(StreamState)state stream:(AgoraRTEStream*)stream success:(AgoraRTESuccessBlock)successBlock failure:(AgoraRTEFailureBlock _Nullable)failureBlock {
    
    NSMutableDictionary *param = [NSMutableDictionary dictionary];
    param[@"streamName"] = stream.streamName;
    param[@"videoSourceType"] = @(stream.sourceType);
    param[@"audioSourceType"] = @(1);
    param[@"videoState"] = @(stream.hasVideo ? 1 : 0);
    param[@"audioState"] = @(stream.hasAudio ? 1 : 0);
    param[@"generateToken"] = @(0);
    if(state == StreamStateCreate || state == StreamStateUpdate) {
        [AgoraRTEHttpManager upsetStreamWithRoomUuid:self.channelId userUuid:stream.userInfo.userUuid userToken:self.userToken streamUuid:stream.streamUuid param:param apiVersion:APIVersion1 analysisClass:AgoraRTEPublishModel.class success:^(id<AgoraRTEBaseModel>  _Nullable objModel) {

            if(successBlock){
                successBlock();
            }
        } failure:^(NSError * _Nullable error, NSInteger statusCode) {
            NSError *eduError = [AgoraRTEErrorManager networkError:error.code codeMsg:error.localizedDescription code:301];
            if(failureBlock != nil) {
                failureBlock(eduError);
            }
        }];
    } else if(state == StreamStateDelete) {
        [AgoraRTEHttpManager removeStreamWithRoomUuid:self.channelId userUuid:stream.userInfo.userUuid userToken:self.userToken streamUuid:stream.streamUuid param:param apiVersion:APIVersion1 analysisClass:AgoraRTECommonModel.class success:^(id<AgoraRTEBaseModel>  _Nullable objModel) {

            if(successBlock){
                successBlock();
            }
        } failure:^(NSError * _Nullable error, NSInteger statusCode) {
            NSError *eduError = [AgoraRTEErrorManager networkError:error.code codeMsg:error.localizedDescription code:301];
            if(failureBlock != nil) {
                failureBlock(eduError);
            }
        }];
    }
}

- (void)destory {
    for (AgoraRtcVideoCanvas *videoCanvas in self.rtcVideoCanvasList){
        videoCanvas.view = nil;
        
        AgoraRTESyncUserModel *localUser = self.messageHandle.syncRoomSession.localUser;
        if([localUser.streamUuid isEqualToString:@(videoCanvas.uid).stringValue]) {
            [AgoraRTCManager.shareManager setupLocalVideo: videoCanvas];
        } else {
            [AgoraRTCManager.shareManager setupRemoteVideo: videoCanvas];
        }
    }
    [self.rtcVideoCanvasList removeAllObjects];
    
    [AgoraRTELogService logMessageWithDescribe:@"AgoraRTEUserService desotry:" message:@{@"roomUuid": NoNullString(self.channelId)}];
}

- (void)dealloc {
    [self destory];
}

@end
