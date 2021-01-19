//
//  EduTextMessage.h
//  Demo
//
//  Created by SRS on 2020/6/19.
//  Copyright © 2020 agora. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "EduUser.h"

NS_ASSUME_NONNULL_BEGIN

@interface EduTextMessage : NSObject
@property (nonatomic, strong, readonly) EduUser *fromUser;
@property (nonatomic, strong, readonly) NSString *message;
@property (nonatomic, assign, readonly) NSInteger timestamp;
@end

NS_ASSUME_NONNULL_END
