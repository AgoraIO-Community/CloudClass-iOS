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
#import <EduSDK/EduSDK-Swift.h>

@implementation AgoraRTEStreamStateInfo
@end

typedef NS_ENUM(NSUInteger, AgoraRTESyncStreamState) {
    AgoraRTESyncStreamStateCreate,
    AgoraRTESyncStreamStateUpdate,
    AgoraRTESyncStreamStateDelete,
};

@interface AgoraRTEUserService()<AgoraRTCStreamStateDelegate, AgoraRTCSpeakerReportDelegate, AgoraRTCErrorDelegate>

@property (nonatomic, strong) NSMutableArray<AgoraRtcVideoCanvas*> *rtcVideoCanvasList;
@property (nonatomic, strong) NSMutableDictionary<NSString *, AgoraRTEStreamStateInfo *> *streamStateModels;

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
        
        self.streamStateModels = [NSMutableDictionary dictionary];
        self.rtcVideoCanvasList = [NSMutableArray array];
        AgoraRTEWEAK(self);
        self.messageHandle.checkAutoSubscribe = ^(NSArray<AgoraRTEStream *> * _Nonnull streams, BOOL state) {
        
            if (weakself.mediaOption.autoSubscribe) {
                return;
            }

            for(AgoraRTEStream *stream in streams) {
               if(state != 0) {
                   AgoraRTESubscribeOptions *options = [AgoraRTESubscribeOptions new];
                   options.subscribeAudio = YES;
                   options.subscribeVideo = YES;
                   options.videoStreamType = AgoraRTEVideoStreamTypeLow;
                   if (stream.sourceType == AgoraRTEVideoSourceTypeScreen) {
                       options.videoStreamType = AgoraRTEVideoStreamTypeHigh;
                   }
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
    
    [AgoraRTELogService logMessageWithDescribe:@"user setVideoConfig:" message:@{@"roomUuid":AgoraRTENoNullString(self.channelId), @"config":AgoraRTENoNull(config)}];
    
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
    
    [AgoraRTELogService logMessageWithDescribe:@"user startOrUpdateLocalStream:" message:@{@"roomUuid":AgoraRTENoNullString(self.channelId), @"config":AgoraRTENoNull(config)}];
    
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
    AgoraRTEStream *stream = [[AgoraRTEStream alloc] initWithStreamUuid:AgoraRTENoNullString(config.streamUuid) streamName:AgoraRTENoNullString(config.streamName) sourceType:AgoraRTEVideoSourceTypeCamera hasVideo:config.enableCamera hasAudio:config.enableMicrophone user:[userModel mapAgoraRTEBaseUser]];
    
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
- (int)setEnableSpeakerphone:(BOOL)enable {
    return [AgoraRTCManager.shareManager setEnableSpeakerphone:enable];
}
- (BOOL)isSpeakerphoneEnabled {
    return [AgoraRTCManager.shareManager isSpeakerphoneEnabled];
}

// stream
- (void)subscribeStream:(AgoraRTEStream*)stream options:(AgoraRTESubscribeOptions*)options success:(AgoraRTESuccessBlock)successBlock failure:(AgoraRTEFailureBlock _Nullable)failureBlock {
    
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

- (void)unsubscribeStream:(AgoraRTEStream*)stream options:(AgoraRTESubscribeOptions*) options success:(AgoraRTESuccessBlock)successBlock failure:(AgoraRTEFailureBlock _Nullable)failureBlock {
    
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

    AgoraRTEWEAK(self);
    AgoraRTESyncStreamState state = AgoraRTESyncStreamStateCreate;
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
    
    [self updateStreamWithState:AgoraRTESyncStreamStateUpdate stream:stream success:^{
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
    
    AgoraRTESyncStreamState state = AgoraRTESyncStreamStateDelete;
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
    param[@"type"] = @1;
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
    
    NSNumber *number = [NSNumber numberWithLongLong:stream.streamUuid.longLongValue];
    NSUInteger streamUuid = number.unsignedIntegerValue;

    // 去重复
    for (AgoraRtcVideoCanvas *videoCanvas in self.rtcVideoCanvasList) {

        if(!view) {
            if(videoCanvas.uid == streamUuid) {
                [removeArray addObject:videoCanvas];
                return nil;
            }
        } else if(videoCanvas.view == view) {
            if(videoCanvas.uid == streamUuid) {
                return nil;
            }
            [removeArray addObject:videoCanvas];
            
        } else if(videoCanvas.uid == streamUuid) {
            [removeArray addObject:videoCanvas];
        }
    }
    
    for (AgoraRtcVideoCanvas *videoCanvas in removeArray) {
        [self removeVideoCanvas:videoCanvas];
    }
    [removeArray removeAllObjects];
    
    if (view == nil) {
        return nil;
    }
    
    AgoraRtcVideoCanvas *videoCanvas = [[AgoraRtcVideoCanvas alloc] init];
    videoCanvas.uid = streamUuid;
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
    
    [AgoraRTELogService logMessageWithDescribe:@"user removeVideoCanvas:" message:@{@"roomUuid":AgoraRTENoNullString(self.channelId), @"streamUuid":@(videoCanvas.uid)}];
    
    [self.rtcVideoCanvasList removeObject:videoCanvas];
}

#pragma mark - AgoraRTCStreamStateDelegate
- (void)rtcLocalVideoStats:(AgoraRtcLocalVideoStats *)state {
    if ([self.mediaStreamDelegate respondsToSelector:@selector(localVideoStream:rendererOutputFrameRate:)]) {
        [self.mediaStreamDelegate localVideoStream:self.messageHandle.syncRoomSession.streams.firstObject
                                      rendererOutputFrameRate:state.rendererOutputFrameRate];
    }
}
- (void)rtcRemoteVideoStats:(AgoraRtcRemoteVideoStats *)state {
    if ([self.mediaStreamDelegate respondsToSelector:@selector(remoteVideoStream:rendererOutputFrameRate:)]) {
        [self.mediaStreamDelegate remoteVideoStream:@(state.uid).stringValue
                                      rendererOutputFrameRate:state.rendererOutputFrameRate];
    }
}
- (void)rtcLocalAudioStateChange:(AgoraAudioLocalState)state
                           error:(AgoraAudioLocalError)error {
    
    AgoraRTEStreamState eduState = [self getAgoraRTEStreamStateWithLocalAudio:state];
    NSString *streamUuid = self.messageHandle.syncRoomSession.localUser.streamUuid;
    
    AgoraRTEStreamStateInfo *info = self.streamStateModels[streamUuid];
    if (info == nil) {
        info = [AgoraRTEStreamStateInfo new];
    }
    info.audioState = @(eduState);
    [self.streamStateModels setValue:info forKey:streamUuid];
    
    if ([self.mediaStreamDelegate respondsToSelector:@selector(didChangeOfLocalAudioStream:withState:)]) {
        [self.mediaStreamDelegate didChangeOfLocalAudioStream:streamUuid
                                  withState:eduState];
    }
}
- (void)rtcLocalVideoStateChange:(AgoraLocalVideoStreamState)state
                           error:(AgoraLocalVideoStreamError)error {
    
    AgoraRTEStreamState eduState = [self getAgoraRTEStreamStateWithLocalVideo:state];
    NSString *streamUuid = self.messageHandle.syncRoomSession.localUser.streamUuid;

    AgoraRTEStreamStateInfo *info = self.streamStateModels[streamUuid];
    if (info == nil) {
        info = [AgoraRTEStreamStateInfo new];
    }
    info.videoState = @(eduState);
    [self.streamStateModels setValue:info forKey:streamUuid];

    if ([self.mediaStreamDelegate respondsToSelector:@selector(didChangeOfLocalVideoStream:withState:)]) {

        [self.mediaStreamDelegate didChangeOfLocalVideoStream:streamUuid
                                  withState:eduState];
    }
}
- (void)rtcReportAudioVolumeIndicationOfLocalSpeaker:(AgoraRtcAudioVolumeInfo *)speaker {
    
    if ([self.mediaStreamDelegate respondsToSelector:@selector(audioVolumeIndicationOfLocalStream:withVolume:)]) {
        
        NSString *streamUuid = self.messageHandle.syncRoomSession.localUser.streamUuid;
        
        [self.mediaStreamDelegate audioVolumeIndicationOfLocalStream:streamUuid withVolume:speaker.volume];
    }
}

- (void)rtcRemoteAudioStateChangedOfUid:(NSUInteger)uid
                                  state:(AgoraAudioRemoteState)state
                                 reason:(AgoraAudioRemoteStateReason)reason
                                elapsed:(NSInteger)elapsed {
    
    AgoraRTEStreamState eduState = [self getAgoraRTEStreamStateWithRemoteAudio:state];
    NSString *streamUuid = [NSString stringWithFormat:@"%lu", (unsigned long)uid];
    
    AgoraRTEStreamStateInfo *info = self.streamStateModels[streamUuid];
    if (info == nil) {
        info = [AgoraRTEStreamStateInfo new];
    }
    info.audioState = @(eduState);
    [self.streamStateModels setValue:info forKey:streamUuid];
    
    if ([self.mediaStreamDelegate respondsToSelector:@selector(didChangeOfRemoteAudioStream:withState:)]) {
        [self.mediaStreamDelegate didChangeOfRemoteAudioStream:streamUuid
                                  withState:eduState];
    }
}

- (void)rtcRemoteVideoStateChangedOfUid:(NSUInteger)uid
                                  state:(AgoraVideoRemoteState)state
                                 reason:(AgoraVideoRemoteStateReason)reason
                                elapsed:(NSInteger)elapsed {
    
    AgoraRTEStreamState eduState = [self getAgoraRTEStreamStateWithRemoteVideo:state];
    NSString *streamUuid = [NSString stringWithFormat:@"%lu", (unsigned long)uid];
    
    AgoraRTEStreamStateInfo *info = self.streamStateModels[streamUuid];
    if (info == nil) {
        info = [AgoraRTEStreamStateInfo new];
    }
    info.videoState = @(eduState);
    [self.streamStateModels setValue:info forKey:streamUuid];
    
    if ([self.mediaStreamDelegate respondsToSelector:@selector(didChangeOfRemoteVideoStream:withState:)]) {
        [self.mediaStreamDelegate didChangeOfRemoteVideoStream:streamUuid
                                  withState:eduState];
    }
}

- (void)rtcReportAudioVolumeIndicationOfRemoteSpeaker:(AgoraRtcAudioVolumeInfo *)speaker {
    
    if ([self.mediaStreamDelegate respondsToSelector:@selector(audioVolumeIndicationOfRemoteStream:withVolume:)]) {
        
        NSString *streamUuid = [NSString stringWithFormat:@"%lu", (unsigned long)speaker.uid];
        
        [self.mediaStreamDelegate audioVolumeIndicationOfRemoteStream:streamUuid withVolume:speaker.volume];
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
- (void)updateStreamWithState:(AgoraRTESyncStreamState)state stream:(AgoraRTEStream*)stream success:(AgoraRTESuccessBlock)successBlock failure:(AgoraRTEFailureBlock _Nullable)failureBlock {
    
    NSMutableDictionary *param = [NSMutableDictionary dictionary];
    param[@"streamName"] = stream.streamName;
    param[@"videoSourceType"] = @(stream.sourceType);
    param[@"audioSourceType"] = @(1);
    param[@"videoState"] = @(stream.hasVideo ? 1 : 0);
    param[@"audioState"] = @(stream.hasAudio ? 1 : 0);
    param[@"generateToken"] = @(0);
    if(state == AgoraRTESyncStreamStateCreate || state == AgoraRTESyncStreamStateUpdate) {
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
    } else if(state == AgoraRTESyncStreamStateDelete) {
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
    self.streamStateModels = [NSMutableDictionary dictionary];

    [AgoraRTELogService logMessageWithDescribe:@"AgoraRTEUserService desotry:" message:@{@"roomUuid": AgoraRTENoNullString(self.channelId)}];
}

- (void)dealloc {
    [self destory];
}

@end
