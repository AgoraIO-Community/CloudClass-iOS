//
//  EduTeacherService.m
//  Demo
//
//  Created by SRS on 2020/6/19.
//  Copyright © 2020 agora. All rights reserved.
//

#import "EduTeacherService.h"
#import "EduConstants.h"
#import "EduMessageHandle.h"
#import "EduChannelMessageHandle.h"
#import "HttpManager.h"
#import "EduErrorManager.h"
#import "CommonModel.h"

@implementation EduStreamsChangedModel
@end


@interface EduTeacherService ()
@property (nonatomic, strong) NSString *channelId;
@property (nonatomic, strong) NSString *userToken;
@property (nonatomic, strong) EduChannelMessageHandle *messageHandle;
@end

@implementation EduTeacherService

- (void)updateCourseState:(EduCourseState)courseState success:(EduSuccessBlock)successBlock failure:(EduFailureBlock _Nullable)failureBlock {
    
    if (courseState != EduCourseStateStart && courseState != EduCourseStateStop) {
        
        NSError *error = [EduErrorManager paramterInvalid:@"courseState" code:1];
        if(failureBlock) {
            failureBlock(error);
        }
        return;
    }
    
    [HttpManager updateRoomStartOrStopWithRoomUuid:self.channelId state:courseState userToken:self.userToken param:@{} apiVersion:APIVersion1 analysisClass:CommonModel.class success:^(id<BaseModel>  _Nonnull objModel) {
        
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

- (void)allowAllStudentChat:(BOOL)enable success:(EduSuccessBlock)successBlock failure:(EduFailureBlock _Nullable)failureBlock {
    
    NSNumber *muteChat = enable ? @(0) : @(1);
    
    NSDictionary *param = @{
        @"muteChat": @{
            kServiceRoleBroadcaster:muteChat,
            kServiceRoleAudience:muteChat,
        }
    };

    [HttpManager updateRoomMuteWithRoomUuid:self.channelId userToken:self.userToken param:param apiVersion:APIVersion1 analysisClass:CommonModel.class success:^(id<BaseModel>  _Nonnull objModel) {
        
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

- (void)allowStudentChat:(BOOL)enable remoteUser:(EduUser *)remoteUser success:(EduSuccessBlock)successBlock failure:(EduFailureBlock _Nullable)failureBlock {
    
    NSError *error;
    if (![remoteUser isKindOfClass:EduUser.class]) {
        error = [EduErrorManager paramterInvalid:@"remoteUser" code:1];
    }
    if(error) {
        if(failureBlock) {
            failureBlock(error);
        }
        return;
    }
    
    NSNumber *muteChat = enable ? @(0) : @(1);
    
    NSDictionary *param = @{
        @"userName": NoNullString(remoteUser.userName),
        @"muteChat": muteChat
    };
    [HttpManager updateUserStateWithRoomUuid:self.channelId userUuid:NoNullString(remoteUser.userUuid) userToken:self.userToken param:param apiVersion:APIVersion1 analysisClass:CommonModel.class success:^(id<BaseModel>  _Nonnull objModel) {
        
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

- (void)upsetStudentStreams:(NSArray<EduStream *> *)streams success:(OnStreamsChangedSuccessBlock)successBlock failure:(EduFailureBlock _Nullable)failureBlock {
    
    if(![streams isKindOfClass:NSArray.class] || streams.count == 0) {
        NSError *error = [EduErrorManager paramterInvalid:@"streams" code:1];
        if(error) {
            if(failureBlock) {
                failureBlock(error);
            }
            return;
        }
    }
    
    NSMutableArray *streamsParam = [NSMutableArray array];
    for (EduStream *stream in streams) {
        NSDictionary *dic = @{@"userUuid":stream.userInfo.userUuid,
                              @"streamUuid":stream.streamUuid,
                              @"streamName":stream.streamName,
                              @"videoSourceType":@(stream.sourceType),
                              @"audioSourceType":@(1),
                              @"videoState":stream.hasAudio?@1:@0,
                              @"audioState":stream.hasVideo?@1:@0};
        [streamsParam addObject:dic];
    }

    [HttpManager upsetStreamsWithRoomUuid:self.channelId userToken:self.userToken param:@{@"streams":streamsParam} apiVersion:APIVersion1 analysisClass:CommonModel.self success:^(id<BaseModel>  _Nonnull objModel) {
        if(successBlock){
            CommonModel *cm = (CommonModel*)objModel;
            NSMutableArray<EduStreamsChangedModel *> *models = [NSMutableArray array];
            if ([cm.data isKindOfClass:NSArray.class]) {
                for(id obj in cm.data) {
                    EduStreamsChangedModel *model = [EduStreamsChangedModel yy_modelWithDictionary:NoNullDictionary(obj)];
                    if (model != nil) {
                        [models addObject:model];
                    }
                }
            }
            successBlock(models);
        }
        
    } failure:^(NSError * _Nullable error, NSInteger statusCode) {
        NSError *eduError = [EduErrorManager networkError:error.code codeMsg:error.localizedDescription code:301];
        if(failureBlock != nil) {
            failureBlock(eduError);
        }
    }];
}
- (void)deleteStudentStreams:(NSArray<EduStream *> *)streams success:(OnStreamsChangedSuccessBlock)successBlock failure:(EduFailureBlock _Nullable)failureBlock {
    
    if(![streams isKindOfClass:NSArray.class] || streams.count == 0) {
        NSError *error = [EduErrorManager paramterInvalid:@"streams" code:1];
        if(error) {
            if(failureBlock) {
                failureBlock(error);
            }
            return;
        }
    }
    
    NSMutableArray *streamsParam = [NSMutableArray array];
    for (EduStream *stream in streams) {
        NSDictionary *dic = @{@"userUuid":stream.userInfo.userUuid,
                              @"streamUuid":stream.streamUuid};
        [streamsParam addObject:dic];
    }

    [HttpManager removeStreamsWithRoomUuid:self.channelId userToken:self.userToken param:@{@"streams":streamsParam} apiVersion:APIVersion1 analysisClass:CommonModel.self success:^(id<BaseModel>  _Nonnull objModel) {
        if(successBlock){
            CommonModel *cm = (CommonModel*)objModel;
            NSMutableArray<EduStreamsChangedModel *> *models = [NSMutableArray array];
            if ([cm.data isKindOfClass:NSArray.class]) {
                for(id obj in cm.data) {
                    EduStreamsChangedModel *model = [EduStreamsChangedModel yy_modelWithDictionary:NoNullDictionary(obj)];
                    if (model != nil) {
                        [models addObject:model];
                    }
                }
            }
            successBlock(models);
        }
        
    } failure:^(NSError * _Nullable error, NSInteger statusCode) {
        NSError *eduError = [EduErrorManager networkError:error.code codeMsg:error.localizedDescription code:301];
        if(failureBlock != nil) {
            failureBlock(eduError);
        }
    }];
}
- (void)createOrUpdateStudentStream:(EduStream *)stream success:(EduSuccessBlock)successBlock failure:(EduFailureBlock _Nullable)failureBlock {
    
    [self publishStream:stream success:successBlock failure:failureBlock];
}

#pragma mark --Private
- (void)setDelegate:(id<EduTeacherDelegate>)delegate {
    _delegate = delegate;
    self.messageHandle.userDelegate = delegate;
}
@end
