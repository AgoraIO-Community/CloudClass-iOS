//
//  OSSModel.h
//  AgoraLog
//
//  Created by SRS on 2020/7/2.
//  Copyright © 2020 agora. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface OSSModel : NSObject

@property (nonatomic, strong) NSString *msg;
@property (nonatomic, assign) NSInteger code;
@property (nonatomic, strong) NSString *data;

+ (nullable OSSModel *)initWithJsonString:(NSString *)jsonString error:(NSError **)error;

@end

NS_ASSUME_NONNULL_END
