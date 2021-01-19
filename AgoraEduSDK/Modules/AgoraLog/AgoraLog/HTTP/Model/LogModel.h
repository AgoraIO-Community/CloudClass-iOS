//
//  LogParamModel.h
//  AgoraEducation
//
//  Created by SRS on 2020/1/8.
//  Copyright © 2019 Agora. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface LogInfoModel : NSObject
@property (nonatomic, strong) NSString *bucketName;
@property (nonatomic, strong) NSString *callbackBody;
@property (nonatomic, strong) NSString *callbackContentType;
@property (nonatomic, strong) NSString *ossKey;
@property (nonatomic, strong) NSString *ossEndpoint;
@property (nonatomic, strong) NSString *accessKeyId;
@property (nonatomic, strong) NSString *accessKeySecret;
@property (nonatomic, strong) NSString *securityToken;
@end

@interface LogModel : NSObject
@property (nonatomic, strong) NSString *msg;
@property (nonatomic, assign) NSInteger code;
@property (nonatomic, strong) LogInfoModel *data;

+ (LogModel *)initWithObject:(id)dictionary;

@end

NS_ASSUME_NONNULL_END
