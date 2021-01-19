//
//  EduUserService.m
//  Demo
//
//  Created by SRS on 2020/6/17.
//  Copyright © 2020 agora. All rights reserved.
//

#import "EduUserService.h"
#import "EduClassroomConfig.h"
#import "EduClassroomMediaOptions.h"
#import "HttpManager.h"
#import "RTCManager.h"
#import "EduStream.h"
#import "EduConstants.h"
#import "EduStream+ConvenientInit.h"
#import "PublishModel.h"
#import "CommonModel.h"
#import "AgoraLogService.h"
#import "SyncRoomSession.h"

#import "EduSyncRoomModel.h"
#import "EduSyncStreamModel.h"
#import "EduSyncUserModel.h"
#import "EduErrorManager.h"

#import "EduChannelMessageHandle.h"
#import "EduKVCUserConfig.h"

@implementation EduRenderConfig
@end

typedef NS_ENUM(NSUInteger, StreamState) {
    StreamStateCreate,
    StreamStateUpdate,
    StreamStateDelete,
};

@interface EduUserService()<RTCStreamStateDelegate>
@property (nonatomic, strong) NSMutableArray<AgoraRtcVideoCanvas*> *rtcVideoCanvasList;

@property (nonatomic, strong) NSString *channelId;
@property (nonatomic, strong) NSString *userToken;
@property (nonatomic, strong) EduClassroomMediaOptions *mediaOption;

@property (nonatomic, strong) EduChannelMessageHandle *messageHandle;

@end

@implementation EduUserService
- (instancetype)initWithConfig:(EduKVCUserConfig *)config {
    self = [super init];
    if (self) {
        self.channelId = config.roomUuid;
        self.messageHandle = config.messageHandle;
        self.mediaOption = config.mediaOption;
        self.userToken = config.userToken;
        
        RTCChannelDelegateConfig *config = [RTCChannelDelegateConfig new];
        config.streamStateDelegate = self;
        [RTCManager.shareManager setChannelDelegateWithConfig:config channelId:self.channelId];
        
        self.rtcVideoCanvasList = [NSMutableArray array];
        WEAK(self);
        self.messageHandle.checkAutoSubscribe = ^(NSArray<EduStream *> * _Nonnull streams, BOOL state) {
        
            if (weakself.mediaOption.autoSubscribe) {
                return;
            }

            for(EduStream *stream in streams) {
               if(state != 0) {
                   EduSubscribeOptions *options = [EduSubscribeOptions new];
                   options.subscribeAudio = YES;
                   options.subscribeVideo = YES;
                   options.videoStreamType = EduVideoStreamTypeLow;
                   [weakself subscribeStream:stream options:options success:^{
                       
                   } failure:^(NSError * _Nonnull error) {
                       
                   }];
               }
            }
        };
        
        self.messageHandle.checkStreamPublish = ^(EduStream * _Nonnull stream, StreamAction action) {
            
            if (action == StreamCreate || action == StreamUpdate) {
                [RTCManager.shareManager enableLocalVideo:stream.hasVideo];
                [RTCManager.shareManager enableLocalAudio:stream.hasAudio];
                [RTCManager.shareManager muteLocalVideoStream:!stream.hasVideo];
                [RTCManager.shareManager muteLocalAudioStream:!stream.hasAudio];
                [RTCManager.shareManager publishChannelId:weakself.channelId];
            } else {
                [RTCManager.shareManager enableLocalVideo:NO];
                [RTCManager.shareManager enableLocalAudio:NO];
                [RTCManager.shareManager muteLocalVideoStream:YES];
                [RTCManager.shareManager muteLocalAudioStream:YES];
                [RTCManager.shareManager unPublishChannelId:weakself.channelId];
            }
        };
    }
    return self;
}

- (NSError * _Nullable)setVideoConfig:(EduVideoConfig*)config {
    
    [AgoraLogService logMessageWithDescribe:@"user setVideoConfig:" message:@{@"roomUuid":NoNullString(self.channelId), @"config":NoNull(config)}];
    
    AgoraVideoEncoderConfiguration *configuration = [AgoraVideoEncoderConfiguration new];
    configuration.dimensions = CGSizeMake(config.videoDimensionWidth, config.videoDimensionHeight);
    configuration.frameRate = config.frameRate;
    configuration.bitrate = config.bitrate;
    configuration.orientationMode = AgoraVideoOutputOrientationModeAdaptative;
    
    switch (config.degradationPreference) {
        case EduDegradationMaintainQuality:
            configuration.degradationPreference = AgoraDegradationMaintainQuality;
            break;
        case EduDegradationMaintainFramerate:
            configuration.orientationMode = AgoraDegradationMaintainFramerate;
            break;
        case EduDegradationBalanced:
            configuration.orientationMode = AgoraDegradationBalanced;
            break;
        default:
            break;
    }
    
    NSInteger errCode = [RTCManager.shareManager setVideoEncoderConfiguration:configuration];
    if(errCode == 0) {
        return nil;
    }
    
    return [EduErrorManager mediaError:errCode codeMsg:[RTCManager getErrorDescription:errCode] code:201];
}

// media
- (void)startOrUpdateLocalStream:(EduStreamConfig*)config success:(OnUserMediaChangedSuccessBlock)successBlock failure:(EduFailureBlock)failureBlock {
    
    NSError *error;
    if(![config isKindOfClass:EduStreamConfig.class]) {
        error = [EduErrorManager paramterInvalid:@"config" code:1];
    } else {
        error = [EduErrorManager paramterEmptyError:@"streamUuid" value:config.streamUuid code:1];
    }
    if(error) {
        if(failureBlock) {
            failureBlock(error);
        }
        return;
    }
    
    [AgoraLogService logMessageWithDescribe:@"user startOrUpdateLocalStream:" message:@{@"roomUuid":NoNullString(self.channelId), @"config":NoNull(config)}];
    
    int code = [RTCManager.shareManager enableLocalVideo:config.enableCamera];
    if (code != 0) {
        NSError *error = [EduErrorManager mediaError:code codeMsg:[RTCManager getErrorDescription:code] code:201];
        if(failureBlock) {
            failureBlock(error);
        }
        return;
    }
    code = [RTCManager.shareManager enableLocalAudio:config.enableMicrophone];
    if (code != 0) {
        NSError *error = [EduErrorManager mediaError:code codeMsg:[RTCManager getErrorDescription:code] code:201];
        if(failureBlock) {
            failureBlock(error);
        }
        return;
    }
    
    if (config.enableCamera || config.enableMicrophone) {
        [RTCManager.shareManager setClientRole:AgoraClientRoleBroadcaster channelId:self.channelId];
    } else {
//        [RTCManager.shareManager setClientRole:AgoraClientRoleAudience channelId:self.channelId];
    }
    
    EduSyncUserModel *userModel = self.messageHandle.syncRoomSession.localUser;
    EduStream *stream = [[EduStream alloc] initWithStreamUuid:NoNullString(config.streamUuid) streamName:NoNullString(config.streamName) sourceType:EduVideoSourceTypeCamera hasVideo:config.enableCamera hasAudio:config.enableMicrophone user:[userModel mapEduBaseUser]];
    
    // 找到流 update
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"streamUuid in %@", config.streamUuid];
    NSArray<BaseSnapshotStreamModel*> *filteredArray = [self.messageHandle.syncRoomSession.localUser.streams filteredArrayUsingPredicate:predicate];
    if (filteredArray.count > 0) {
        
    } else {
        [RTCManager.shareManager startPreview];
    }
    
    if(successBlock) {
        successBlock(stream);
    }
}

- (NSError * _Nullable)switchCamera {
    
    int errCode = [RTCManager.shareManager switchCamera];
    if(errCode == 0) {
        return nil;
    } else {
        NSError *error = [EduErrorManager mediaError:errCode codeMsg:[RTCManager getErrorDescription:errCode] code:201];
        return error;
    }
}

// stream
- (void)subscribeStream:(EduStream*)stream options:(EduSubscribeOptions*)options success:(EduSuccessBlock)successBlock failure:(EduFailureBlock _Nullable)failureBlock {
    
    NSError *error;
    if (![stream isKindOfClass:EduStream.class]) {
        error = [EduErrorManager paramterInvalid:@"stream" code:1];
    } else {
        error = [EduErrorManager paramterEmptyError:@"streamUuid" value:stream.streamUuid code:1];
    }
    if(error) {
        if(failureBlock) {
            failureBlock(error);
        }
        return;
    }
    
    if(options.subscribeAudio){
        [RTCManager.shareManager muteRemoteAudioStream:stream.streamUuid mute:!options.subscribeAudio channelId:self.channelId];
    }
    if(options.subscribeVideo) {
        [RTCManager.shareManager muteRemoteVideoStream:stream.streamUuid mute:!options.subscribeVideo channelId:self.channelId];
        
        AgoraVideoStreamType type = AgoraVideoStreamTypeLow;
        if(options.videoStreamType == EduVideoStreamTypeHigh) {
            type = AgoraVideoStreamTypeHigh;
        }
        [RTCManager.shareManager setRemoteVideoStream:stream.streamUuid type:type];
    }
    
    if(successBlock) {
        successBlock();
    }
}

- (void)unsubscribeStream:(EduStream*)stream options:(EduSubscribeOptions*) options success:(EduSuccessBlock)successBlock failure:(EduFailureBlock _Nullable)failureBlock {
    
    NSError *error;
    if (![stream isKindOfClass:EduStream.class]) {
        error = [EduErrorManager paramterInvalid:@"stream" code:1];
    } else {
        error = [EduErrorManager paramterEmptyError:@"streamUuid" value:stream.streamUuid code:1];
    }
    if(error) {
        if(failureBlock) {
            failureBlock(error);
        }
        return;
    }
    
    if(!options.subscribeAudio){
        [RTCManager.shareManager muteRemoteAudioStream:stream.streamUuid mute:!options.subscribeAudio channelId:self.channelId];
    }
    if(!options.subscribeVideo){
        [RTCManager.shareManager muteRemoteVideoStream:stream.streamUuid mute:!options.subscribeVideo channelId:self.channelId];
    }
    
    if(successBlock) {
        successBlock();
    }
}

- (void)publishStream:(EduStream*)stream success:(EduSuccessBlock)successBlock failure:(EduFailureBlock _Nullable)failureBlock {
    
    NSError *error;
    if (![stream isKindOfClass:EduStream.class]) {
        error = [EduErrorManager paramterInvalid:@"stream" code:1];
    } else {
        error = [EduErrorManager paramterEmptyError:@"streamUuid" value:stream.streamUuid code:1];
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
         
            [RTCManager.shareManager muteLocalAudioStream:!stream.hasAudio];
            [RTCManager.shareManager muteLocalVideoStream:!stream.hasVideo];
            [RTCManager.shareManager publishChannelId:weakself.channelId];
        }
        
        if(successBlock) {
            successBlock();
        }
    } failure:failureBlock];
}

- (void)muteStream:(EduStream*)stream success:(EduSuccessBlock)successBlock failure:(EduFailureBlock _Nullable)failureBlock {
    
    NSError *error;
    if (![stream isKindOfClass:EduStream.class]) {
        error = [EduErrorManager paramterInvalid:@"stream" code:1];
    } else {
        error = [EduErrorManager paramterEmptyError:@"streamUuid" value:stream.streamUuid code:1];
    }
    if(error) {
        if(failureBlock) {
            failureBlock(error);
        }
        return;
    }

    if([stream.userInfo.userUuid isEqualToString:self.messageHandle.syncRoomSession.localUser.userUuid]) {
        [RTCManager.shareManager muteLocalAudioStream:!stream.hasAudio];
        [RTCManager.shareManager muteLocalVideoStream:!stream.hasVideo];
    }
    
    [self updateStreamWithState:StreamStateUpdate stream:stream success:^{
        if(successBlock) {
            successBlock();
        }
    } failure:failureBlock];
}
- (void)unpublishStream:(EduStream*)stream success:(EduSuccessBlock)successBlock failure:(EduFailureBlock _Nullable)failureBlock {
    
    NSError *error;
    if (![stream isKindOfClass:EduStream.class]) {
        error = [EduErrorManager paramterInvalid:@"stream" code:1];
    } else {
        error = [EduErrorManager paramterEmptyError:@"streamUuid" value:stream.streamUuid code:1];
    }
    if(error) {
        if(failureBlock) {
            failureBlock(error);
        }
        return;
    }

    if([stream.userInfo.userUuid isEqualToString:self.messageHandle.syncRoomSession.localUser.userUuid]) {
     
        [RTCManager.shareManager muteLocalAudioStream:YES];
        [RTCManager.shareManager muteLocalVideoStream:YES];
        [RTCManager.shareManager unPublishChannelId:self.channelId];
    }
    
    StreamState state = StreamStateDelete;
    [self updateStreamWithState:state stream:stream success:successBlock failure:failureBlock];
}

// message
- (void)sendRoomMessageWithText:(NSString*)text success:(EduSuccessBlock)successBlock failure:(EduFailureBlock)failureBlock {
    
    NSError *error = [EduErrorManager paramterEmptyError:@"text" value:text code:1];
    if(error) {
        if(failureBlock) {
            failureBlock(error);
        }
        return;
    }
    
    NSMutableDictionary *param = [NSMutableDictionary dictionary];
    param[@"message"] = text;
    [HttpManager roomMsgWithRoomUuid:self.channelId userToken:self.userToken param:param apiVersion:APIVersion1 analysisClass:CommonModel.class success:^(id<BaseModel>  _Nullable objModel) {
        if(successBlock){
            successBlock();
        }
        
    } failure:^(NSError * _Nullable error, NSInteger statusCode) {
        NSError *eduError = [EduErrorManager networkError:error.code codeMsg:error.localizedDescription code:301];
        if(failureBlock != nil) {
            failureBlock(eduError);
        }
    }];
}
- (void)sendUserMessageWithText:(NSString*)text remoteUser:(EduUser *)remoteUser success:(EduSuccessBlock)successBlock failure:(EduFailureBlock)failureBlock {
    
    NSError *error;
    if (![remoteUser isKindOfClass:EduUser.class]) {
        error = [EduErrorManager paramterInvalid:@"remoteUser" code:1];
    } else {
        error = [EduErrorManager paramterEmptyError:@"streamUuid" value:remoteUser.streamUuid code:1];
    }
    if(error == nil) {
        error = [EduErrorManager paramterEmptyError:@"userUuid" value:remoteUser.userUuid code:1];
    }
    if(error == nil) {
        error = [EduErrorManager paramterEmptyError:@"text" value:text code:1];
    }
    if(error == nil) {
        if([remoteUser.userUuid isEqualToString:self.messageHandle.syncRoomSession.localUser.userUuid]) {
            error = [EduErrorManager internalError:@"cannot send message to yourself" code:1];
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
    [HttpManager userMsgWithRoomUuid:self.channelId userToken:self.userToken userUuid:remoteUser.userUuid param:param apiVersion:APIVersion1 analysisClass:CommonModel.class success:^(id<BaseModel>  _Nullable objModel) {
        
        if(successBlock){
            successBlock();
        }
    } failure:^(NSError * _Nullable error, NSInteger statusCode) {
        NSError *eduError = [EduErrorManager networkError:error.code codeMsg:error.localizedDescription code:301];
        if(failureBlock != nil) {
            failureBlock(eduError);
        }
    }];
}

- (void)sendRoomChatMessageWithText:(NSString*)text success:(EduSuccessBlock)successBlock failure:(EduFailureBlock _Nullable)failureBlock {
    
    NSError *error = [EduErrorManager paramterEmptyError:@"text" value:text code:1];
    if(error) {
        if(failureBlock) {
            failureBlock(error);
        }
        return;
    }

    NSMutableDictionary *param = [NSMutableDictionary dictionary];
    param[@"message"] = text;
    param[@"type"] = @1;;
    [HttpManager roomChatWithRoomUuid:self.channelId userToken:self.userToken param:param apiVersion:APIVersion1 analysisClass:CommonModel.class success:^(id<BaseModel>  _Nullable objModel) {
        if(successBlock){
            successBlock();
        }
        
    } failure:^(NSError * _Nullable error, NSInteger statusCode) {
        NSError *eduError = [EduErrorManager networkError:error.code codeMsg:error.localizedDescription code:301];
        if(failureBlock != nil) {
            failureBlock(eduError);
        }
    }];
}

- (void)sendUserChatMessageWithText:(NSString*)text remoteUser:(EduUser *)remoteUser success:(EduSuccessBlock)successBlock failure:(EduFailureBlock _Nullable)failureBlock {
    
    NSError *error;
    if (![remoteUser isKindOfClass:EduUser.class]) {
        error = [EduErrorManager paramterInvalid:@"remoteUser" code:1];
    } else {
        error = [EduErrorManager paramterEmptyError:@"streamUuid" value:remoteUser.streamUuid code:1];
    }
    if(error == nil) {
        error = [EduErrorManager paramterEmptyError:@"userUuid" value:remoteUser.userUuid code:1];
    }
    if(error == nil) {
        error = [EduErrorManager paramterEmptyError:@"text" value:text code:1];
    }
    if(error == nil) {
        if([remoteUser.userUuid isEqualToString:self.messageHandle.syncRoomSession.localUser.userUuid]) {
            error = [EduErrorManager internalError:@"cannot chat with yourself" code:1];
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
    [HttpManager userChatWithRoomUuid:self.channelId userToken:self.userToken userUuid:remoteUser.userUuid param:param apiVersion:APIVersion1 analysisClass:CommonModel.class success:^(id<BaseModel>  _Nullable objModel) {
        
        if(successBlock){
            successBlock();
        }
    } failure:^(NSError * _Nullable error, NSInteger statusCode) {
        NSError *eduError = [EduErrorManager networkError:error.code codeMsg:error.localizedDescription code:301];
        if(failureBlock != nil) {
            failureBlock(eduError);
        }
    }];
}

// property
- (void)setRoomProperties:(NSDictionary *)properties cause:(EduObject * _Nullable)cause success:(EduSuccessBlock)successBlock failure:(EduFailureBlock _Nullable)failureBlock {
    
    if(![properties isKindOfClass:NSDictionary.class] || properties.allKeys.count == 0) {
        NSError *error = [EduErrorManager paramterInvalid:@"properties" code:1];
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
    [HttpManager setRoomPropertiesWithRoomUuid:self.channelId userToken:self.userToken param:param apiVersion:APIVersion1 analysisClass:CommonModel.class success:^(id<BaseModel>  _Nonnull objModel) {
            
        if(successBlock){
            successBlock();
        }
        
    } failure:^(NSError * _Nullable error, NSInteger statusCode) {
        NSError *eduError = [EduErrorManager networkError:error.code codeMsg:error.localizedDescription code:301];
        if(failureBlock != nil) {
            failureBlock(eduError);
        }
    }];
}
- (void)deleteRoomProperties:(NSArray<NSString *> *)keys cause:(EduObject * _Nullable)cause success:(EduSuccessBlock)successBlock failure:(EduFailureBlock _Nullable)failureBlock {
    
    if(![keys isKindOfClass:NSArray.class] || keys.count == 0) {
        NSError *error = [EduErrorManager paramterInvalid:@"keys" code:1];
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
    [HttpManager deleteRoomPropertiesWithRoomUuid:self.channelId userToken:self.userToken param:param apiVersion:APIVersion1 analysisClass:CommonModel.class success:^(id<BaseModel>  _Nonnull objModel) {
            
        if(successBlock){
            successBlock();
        }
        
    } failure:^(NSError * _Nullable error, NSInteger statusCode) {
        NSError *eduError = [EduErrorManager networkError:error.code codeMsg:error.localizedDescription code:301];
        if(failureBlock != nil) {
            failureBlock(eduError);
        }
    }];
}

// render
- (NSError * _Nullable)setStreamView:(UIView * _Nullable)view stream:(EduStream *)stream {
    
    EduRenderConfig *config = [EduRenderConfig new];
    config.renderMode = EduRenderModeHidden;
    return [self setStreamView:view stream:stream renderConfig:config];
}
- (NSError * _Nullable)setStreamView:(UIView * _Nullable)view stream:(EduStream *)stream renderConfig:(EduRenderConfig*)config {

    NSError *error;
    if (![stream isKindOfClass:EduStream.class]) {
        error = [EduErrorManager paramterInvalid:@"stream" code:1];
        
    } else if (![config isKindOfClass:EduRenderConfig.class]) {
        error = [EduErrorManager paramterInvalid:@"action" code:1];
        
    } else if(config.renderMode != EduRenderModeHidden && config.renderMode != EduRenderModeFit) {
        error = [EduErrorManager paramterInvalid:@"renderMode" code:1];
    } else {
        error = [EduErrorManager paramterEmptyError:@"" value:stream.streamUuid code:1];
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
    if (config.renderMode == EduRenderModeFit) {
        videoCanvas.renderMode = AgoraVideoRenderModeFit;
    } else if (config.renderMode == EduRenderModeHidden) {
        videoCanvas.renderMode = AgoraVideoRenderModeHidden;
    }
    
    [self.rtcVideoCanvasList addObject:videoCanvas];
        
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
    
        EduSyncUserModel *localUser = self.messageHandle.syncRoomSession.localUser;
        if([localUser.streamUuid isEqualToString:stream.streamUuid]) {
            [RTCManager.shareManager setupLocalVideo: videoCanvas];
        } else {
            [RTCManager.shareManager setupRemoteVideo: videoCanvas];
        }
    });
    
    return nil;
}

- (void)removeVideoCanvas:(AgoraRtcVideoCanvas *)videoCanvas {
    
    videoCanvas.view = nil;
    
    EduSyncUserModel *localUser = self.messageHandle.syncRoomSession.localUser;
    if([localUser.streamUuid isEqualToString:@(videoCanvas.uid).stringValue]) {
        [RTCManager.shareManager setupLocalVideo: videoCanvas];
    } else {
        [RTCManager.shareManager setupRemoteVideo: videoCanvas];
    }
    
    [AgoraLogService logMessageWithDescribe:@"user removeVideoCanvas:" message:@{@"roomUuid":NoNullString(self.channelId), @"streamUuid":@(videoCanvas.uid)}];
    
    [self.rtcVideoCanvasList removeObject:videoCanvas];
}

#pragma mark - RTCStreamStateDelegate
- (void)rtcLocalAudioStateChange:(AgoraAudioLocalState)state
                           error:(AgoraAudioLocalError)error {
    if ([self.mediaStreamDelegate respondsToSelector:@selector(didChangeOfLocalAudioStream:withState:)]) {
        EduStreamState eduState = [self getEduStreamStateWithLocalAudio:state];
        EduSyncUserModel *user = (EduSyncUserModel*)self.messageHandle.syncRoomSession.localUser;
        [self.mediaStreamDelegate didChangeOfLocalAudioStream:user.streamUuid
                                  withState:eduState];
    }
}
- (void)rtcLocalVideoStateChange:(AgoraLocalVideoStreamState)state
                           error:(AgoraLocalVideoStreamError)error {
    if ([self.mediaStreamDelegate respondsToSelector:@selector(didChangeOfLocalVideoStream:withState:)]) {
        EduStreamState eduState = [self getEduStreamStateWithLocalVideo:state];
        EduSyncUserModel *user = (EduSyncUserModel*)self.messageHandle.syncRoomSession.localUser;
        [self.mediaStreamDelegate didChangeOfLocalAudioStream:user.streamUuid
                                  withState:eduState];
    }
}

- (void)rtcRemoteAudioStateChangedOfUid:(NSUInteger)uid
                                  state:(AgoraAudioRemoteState)state
                                 reason:(AgoraAudioRemoteStateReason)reason
                                elapsed:(NSInteger)elapsed {
    if ([self.mediaStreamDelegate respondsToSelector:@selector(didChangeOfRemoteAudioStream:withState:)]) {
        EduStreamState eduState = [self getEduStreamStateWithRemoteAudio:state];
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
        EduStreamState eduState = [self getEduStreamStateWithRemoteVideo:state];
        NSString *streamId = [NSString stringWithFormat:@"%lu", (unsigned long)uid];
        [self.mediaStreamDelegate didChangeOfRemoteVideoStream:streamId
                                  withState:eduState];
    }
}

#pragma mark Private
- (EduStreamState)getEduStreamStateWithLocalVideo:(AgoraLocalVideoStreamState)rtc {
    switch (rtc) {
        case AgoraLocalVideoStreamStateStopped:
            return EduStreamStateStopped;
            break;
        case AgoraLocalVideoStreamStateCapturing:
            return EduStreamStateStarting;
            break;
        case AgoraLocalVideoStreamStateEncoding:
            return EduStreamStateRunning;
            break;
        case AgoraLocalVideoStreamStateFailed:
            return EduStreamStateFailed;
            break;
    }
}

- (EduStreamState)getEduStreamStateWithLocalAudio:(AgoraAudioLocalState)rtc {
    switch (rtc) {
        case AgoraAudioLocalStateStopped:
            return EduStreamStateStopped;
            break;
        case AgoraAudioLocalStateRecording:
            return EduStreamStateStarting;
            break;
        case AgoraAudioLocalStateEncoding:
            return EduStreamStateRunning;
            break;
        case AgoraAudioLocalStateFailed:
            return EduStreamStateFailed;
            break;
    }
}

- (EduStreamState)getEduStreamStateWithRemoteVideo:(AgoraVideoRemoteState)rtc {
    switch (rtc) {
        case AgoraVideoRemoteStateStopped:
            return EduStreamStateStopped;
            break;
        case AgoraVideoRemoteStateStarting:
            return EduStreamStateStarting;
            break;
        case AgoraVideoRemoteStateDecoding:
            return EduStreamStateRunning;
            break;
        case AgoraVideoRemoteStateFrozen:
            return EduStreamStateFrozen;
            break;
        case AgoraVideoRemoteStateFailed:
            return EduStreamStateFailed;
            break;
    }
}

- (EduStreamState)getEduStreamStateWithRemoteAudio:(AgoraAudioRemoteState)rtc {
    switch (rtc) {
        case AgoraAudioRemoteStateStopped:
            return EduStreamStateStopped;
            break;
        case AgoraAudioRemoteStateStarting:
            return EduStreamStateStarting;
            break;
        case AgoraAudioRemoteStateDecoding:
            return EduStreamStateRunning;
            break;
        case AgoraAudioRemoteStateFrozen:
            return EduStreamStateFrozen;
            break;
        case AgoraAudioRemoteStateFailed:
            return EduStreamStateFailed;
            break;
    }
}
- (void)updateStreamWithState:(StreamState)state stream:(EduStream*)stream success:(EduSuccessBlock)successBlock failure:(EduFailureBlock _Nullable)failureBlock {
    
    NSMutableDictionary *param = [NSMutableDictionary dictionary];
    param[@"streamName"] = stream.streamName;
    param[@"videoSourceType"] = @(stream.sourceType);
    param[@"audioSourceType"] = @(1);
    param[@"videoState"] = @(stream.hasVideo ? 1 : 0);
    param[@"audioState"] = @(stream.hasAudio ? 1 : 0);
    param[@"generateToken"] = @(0);
    if(state == StreamStateCreate || state == StreamStateUpdate) {
        [HttpManager upsetStreamWithRoomUuid:self.channelId userUuid:stream.userInfo.userUuid userToken:self.userToken streamUuid:stream.streamUuid param:param apiVersion:APIVersion1 analysisClass:PublishModel.class success:^(id<BaseModel>  _Nullable objModel) {

            if(successBlock){
                successBlock();
            }
        } failure:^(NSError * _Nullable error, NSInteger statusCode) {
            NSError *eduError = [EduErrorManager networkError:error.code codeMsg:error.localizedDescription code:301];
            if(failureBlock != nil) {
                failureBlock(eduError);
            }
        }];
    } else if(state == StreamStateDelete) {
        [HttpManager removeStreamWithRoomUuid:self.channelId userUuid:stream.userInfo.userUuid userToken:self.userToken streamUuid:stream.streamUuid param:param apiVersion:APIVersion1 analysisClass:CommonModel.class success:^(id<BaseModel>  _Nullable objModel) {

            if(successBlock){
                successBlock();
            }
        } failure:^(NSError * _Nullable error, NSInteger statusCode) {
            NSError *eduError = [EduErrorManager networkError:error.code codeMsg:error.localizedDescription code:301];
            if(failureBlock != nil) {
                failureBlock(eduError);
            }
        }];
    }
}

- (void)destory {
    for (AgoraRtcVideoCanvas *videoCanvas in self.rtcVideoCanvasList){
        videoCanvas.view = nil;
        
        EduSyncUserModel *localUser = self.messageHandle.syncRoomSession.localUser;
        if([localUser.streamUuid isEqualToString:@(videoCanvas.uid).stringValue]) {
            [RTCManager.shareManager setupLocalVideo: videoCanvas];
        } else {
            [RTCManager.shareManager setupRemoteVideo: videoCanvas];
        }
    }
    [self.rtcVideoCanvasList removeAllObjects];
    
    [AgoraLogService logMessageWithDescribe:@"EduUserService desotry:" message:@{@"roomUuid": NoNullString(self.channelId)}];
}

- (void)dealloc {
    [self destory];
}

@end
