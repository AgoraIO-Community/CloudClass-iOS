//
//  AgoraRTETeacherService.h
//  Demo
//
//  Created by SRS on 2020/6/19.
//  Copyright © 2020 agora. All rights reserved.
//

#import "AgoraRTEUserService.h"
#import "AgoraRTEUserDelegate.h"
#import "AgoraRTEEnumerates.h"

NS_ASSUME_NONNULL_BEGIN

@interface AgoraRTEStreamsChangedModel : NSObject
@property (nonatomic, strong) NSString *streamUuid;
@property (nonatomic, assign) NSString *code;
@property (nonatomic, strong) NSString *msg;
@end

typedef void(^OnStreamsChangedSuccessBlock)(NSArray<AgoraRTEStreamsChangedModel *> *model);

@interface AgoraRTETeacherService : AgoraRTEUserService

@property (nonatomic, weak) id<AgoraRTETeacherDelegate> delegate;

- (void)updateCourseState:(AgoraRTECourseState)courseState success:(AgoraRTESuccessBlock)successBlock failure:(AgoraRTEFailureBlock _Nullable)failureBlock;

- (void)allowAllStudentChat:(BOOL)enable success:(AgoraRTESuccessBlock)successBlock failure:(AgoraRTEFailureBlock _Nullable)failureBlock;

- (void)allowStudentChat:(BOOL)enable remoteUser:(AgoraRTEUser *)remoteUser success:(AgoraRTESuccessBlock)successBlock failure:(AgoraRTEFailureBlock _Nullable)failureBlock;

- (void)upsetStudentStreams:(NSArray<AgoraRTEStream *> *)streams success:(OnStreamsChangedSuccessBlock)successBlock failure:(AgoraRTEFailureBlock _Nullable)failureBlock;
- (void)deleteStudentStreams:(NSArray<AgoraRTEStream *> *)streams success:(OnStreamsChangedSuccessBlock)successBlock failure:(AgoraRTEFailureBlock _Nullable)failureBlock;

@end

NS_ASSUME_NONNULL_END
