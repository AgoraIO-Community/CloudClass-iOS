//
//  AgoraRTETextMessage.h
//  Demo
//
//  Created by SRS on 2020/6/19.
//  Copyright © 2020 agora. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "AgoraRTEUser.h"

NS_ASSUME_NONNULL_BEGIN

@interface AgoraRTETextMessage : NSObject
@property (nonatomic, strong, readonly) AgoraRTEUser *fromUser;
@property (nonatomic, strong, readonly) NSString *message;
@property (nonatomic, assign, readonly) NSInteger timestamp;
@end

NS_ASSUME_NONNULL_END
