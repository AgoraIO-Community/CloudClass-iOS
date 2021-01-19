//
//  EduTeacherService.h
//  Demo
//
//  Created by SRS on 2020/6/19.
//  Copyright © 2020 agora. All rights reserved.
//

#import "EduUserService.h"
#import "EduUserDelegate.h"
#import "EduEnumerates.h"

NS_ASSUME_NONNULL_BEGIN

@interface EduStreamsChangedModel : NSObject
@property (nonatomic, strong) NSString *streamUuid;
@property (nonatomic, assign) NSString *code;
@property (nonatomic, strong) NSString *msg;
@end

typedef void(^OnStreamsChangedSuccessBlock)(NSArray<EduStreamsChangedModel *> *model);

@interface EduTeacherService : EduUserService

@property (nonatomic, weak) id<EduTeacherDelegate> delegate;

- (void)updateCourseState:(EduCourseState)courseState success:(EduSuccessBlock)successBlock failure:(EduFailureBlock _Nullable)failureBlock;

- (void)allowAllStudentChat:(BOOL)enable success:(EduSuccessBlock)successBlock failure:(EduFailureBlock _Nullable)failureBlock;

- (void)allowStudentChat:(BOOL)enable remoteUser:(EduUser *)remoteUser success:(EduSuccessBlock)successBlock failure:(EduFailureBlock _Nullable)failureBlock;

- (void)upsetStudentStreams:(NSArray<EduStream *> *)streams success:(OnStreamsChangedSuccessBlock)successBlock failure:(EduFailureBlock _Nullable)failureBlock;
- (void)deleteStudentStreams:(NSArray<EduStream *> *)streams success:(OnStreamsChangedSuccessBlock)successBlock failure:(EduFailureBlock _Nullable)failureBlock;

@end

NS_ASSUME_NONNULL_END
