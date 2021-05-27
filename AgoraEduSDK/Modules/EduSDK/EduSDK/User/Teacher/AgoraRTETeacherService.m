//
//  AgoraRTETeacherService.m
//  Demo
//
//  Created by SRS on 2020/6/19.
//  Copyright © 2020 agora. All rights reserved.
//

#import "AgoraRTETeacherService.h"
#import "AgoraRTEConstants.h"
#import "AgoraRTEMessageHandle.h"
#import "AgoraRTEChannelMessageHandle.h"
#import "AgoraRTEHttpManager.h"
#import "AgoraRTEErrorManager.h"
#import "AgoraRTECommonModel.h"

@implementation AgoraRTEStreamsChangedModel
@end


@interface AgoraRTETeacherService ()
@property (nonatomic, strong) NSString *channelId;
@property (nonatomic, strong) NSString *userToken;
@property (nonatomic, strong) AgoraRTEChannelMessageHandle *messageHandle;
@end

@implementation AgoraRTETeacherService

- (void)updateCourseState:(AgoraRTECourseState)courseState success:(AgoraRTESuccessBlock)successBlock failure:(AgoraRTEFailureBlock _Nullable)failureBlock {
    
    if (courseState != AgoraRTECourseStateStart && courseState != AgoraRTECourseStateStop) {
        
        NSError *error = [AgoraRTEErrorManager paramterInvalid:@"courseState" code:1];
        if(failureBlock) {
            failureBlock(error);
        }
        return;
    }
    
    [AgoraRTEHttpManager updateRoomStartOrStopWithRoomUuid:self.channelId state:courseState userToken:self.userToken param:@{} apiVersion:APIVersion1 analysisClass:AgoraRTECommonModel.class success:^(id<AgoraRTEBaseModel>  _Nonnull objModel) {
        
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

- (void)allowAllStudentChat:(BOOL)enable success:(AgoraRTESuccessBlock)successBlock failure:(AgoraRTEFailureBlock _Nullable)failureBlock {
    
    NSNumber *muteChat = enable ? @(0) : @(1);
    
    NSDictionary *param = @{
        @"muteChat": @{
            kAgoraRTEServiceRoleBroadcaster:muteChat,
            kAgoraRTEServiceRoleAudience:muteChat,
        }
    };

    [AgoraRTEHttpManager updateRoomMuteWithRoomUuid:self.channelId userToken:self.userToken param:param apiVersion:APIVersion1 analysisClass:AgoraRTECommonModel.class success:^(id<AgoraRTEBaseModel>  _Nonnull objModel) {
        
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

- (void)allowStudentChat:(BOOL)enable remoteUser:(AgoraRTEUser *)remoteUser success:(AgoraRTESuccessBlock)successBlock failure:(AgoraRTEFailureBlock _Nullable)failureBlock {
    
    NSError *error;
    if (![remoteUser isKindOfClass:AgoraRTEUser.class]) {
        error = [AgoraRTEErrorManager paramterInvalid:@"remoteUser" code:1];
    }
    if(error) {
        if(failureBlock) {
            failureBlock(error);
        }
        return;
    }
    
    NSNumber *muteChat = enable ? @(0) : @(1);
    
    NSDictionary *param = @{
        @"userName": AgoraRTENoNullString(remoteUser.userName),
        @"muteChat": muteChat
    };
    [AgoraRTEHttpManager updateUserStateWithRoomUuid:self.channelId userUuid:AgoraRTENoNullString(remoteUser.userUuid) userToken:self.userToken param:param apiVersion:APIVersion1 analysisClass:AgoraRTECommonModel.class success:^(id<AgoraRTEBaseModel>  _Nonnull objModel) {
        
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

- (void)upsetStudentStreams:(NSArray<AgoraRTEStream *> *)streams success:(OnStreamsChangedSuccessBlock)successBlock failure:(AgoraRTEFailureBlock _Nullable)failureBlock {
    
    if(![streams isKindOfClass:NSArray.class] || streams.count == 0) {
        NSError *error = [AgoraRTEErrorManager paramterInvalid:@"streams" code:1];
        if(error) {
            if(failureBlock) {
                failureBlock(error);
            }
            return;
        }
    }
    
    NSMutableArray *streamsParam = [NSMutableArray array];
    for (AgoraRTEStream *stream in streams) {
        NSDictionary *dic = @{@"userUuid":stream.userInfo.userUuid,
                              @"streamUuid":stream.streamUuid,
                              @"streamName":stream.streamName,
                              @"videoSourceType":@(stream.sourceType),
                              @"audioSourceType":@(1),
                              @"videoState":stream.hasAudio?@1:@0,
                              @"audioState":stream.hasVideo?@1:@0};
        [streamsParam addObject:dic];
    }

    [AgoraRTEHttpManager upsetStreamsWithRoomUuid:self.channelId userToken:self.userToken param:@{@"streams":streamsParam} apiVersion:APIVersion1 analysisClass:AgoraRTECommonModel.self success:^(id<AgoraRTEBaseModel>  _Nonnull objModel) {
        if(successBlock){
            AgoraRTECommonModel *cm = (AgoraRTECommonModel*)objModel;
            NSMutableArray<AgoraRTEStreamsChangedModel *> *models = [NSMutableArray array];
            if ([cm.data isKindOfClass:NSArray.class]) {
                for(id obj in cm.data) {
                    AgoraRTEStreamsChangedModel *model = [AgoraRTEStreamsChangedModel yy_modelWithDictionary:AgoraRTENoNullDictionary(obj)];
                    if (model != nil) {
                        [models addObject:model];
                    }
                }
            }
            successBlock(models);
        }
        
    } failure:^(NSError * _Nullable error, NSInteger statusCode) {
        NSError *eduError = [AgoraRTEErrorManager networkError:error.code codeMsg:error.localizedDescription code:301];
        if(failureBlock != nil) {
            failureBlock(eduError);
        }
    }];
}
- (void)deleteStudentStreams:(NSArray<AgoraRTEStream *> *)streams success:(OnStreamsChangedSuccessBlock)successBlock failure:(AgoraRTEFailureBlock _Nullable)failureBlock {
    
    if(![streams isKindOfClass:NSArray.class] || streams.count == 0) {
        NSError *error = [AgoraRTEErrorManager paramterInvalid:@"streams" code:1];
        if(error) {
            if(failureBlock) {
                failureBlock(error);
            }
            return;
        }
    }
    
    NSMutableArray *streamsParam = [NSMutableArray array];
    for (AgoraRTEStream *stream in streams) {
        NSDictionary *dic = @{@"userUuid":stream.userInfo.userUuid,
                              @"streamUuid":stream.streamUuid};
        [streamsParam addObject:dic];
    }

    [AgoraRTEHttpManager removeStreamsWithRoomUuid:self.channelId userToken:self.userToken param:@{@"streams":streamsParam} apiVersion:APIVersion1 analysisClass:AgoraRTECommonModel.self success:^(id<AgoraRTEBaseModel>  _Nonnull objModel) {
        if(successBlock){
            AgoraRTECommonModel *cm = (AgoraRTECommonModel*)objModel;
            NSMutableArray<AgoraRTEStreamsChangedModel *> *models = [NSMutableArray array];
            if ([cm.data isKindOfClass:NSArray.class]) {
                for(id obj in cm.data) {
                    AgoraRTEStreamsChangedModel *model = [AgoraRTEStreamsChangedModel yy_modelWithDictionary:AgoraRTENoNullDictionary(obj)];
                    if (model != nil) {
                        [models addObject:model];
                    }
                }
            }
            successBlock(models);
        }
        
    } failure:^(NSError * _Nullable error, NSInteger statusCode) {
        NSError *eduError = [AgoraRTEErrorManager networkError:error.code codeMsg:error.localizedDescription code:301];
        if(failureBlock != nil) {
            failureBlock(eduError);
        }
    }];
}
- (void)createOrUpdateStudentStream:(AgoraRTEStream *)stream success:(AgoraRTESuccessBlock)successBlock failure:(AgoraRTEFailureBlock _Nullable)failureBlock {
    
    [self publishStream:stream success:successBlock failure:failureBlock];
}

#pragma mark --Private
- (void)setDelegate:(id<AgoraRTETeacherDelegate>)delegate {
    _delegate = delegate;
    self.messageHandle.userDelegate = delegate;
}
@end
