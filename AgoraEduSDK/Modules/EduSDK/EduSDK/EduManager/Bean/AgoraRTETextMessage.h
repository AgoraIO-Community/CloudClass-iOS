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
@property (nonatomic, assign) NSInteger type;
@property (nonatomic, strong) AgoraRTEUser *fromUser;
@property (nonatomic, strong) NSString *message;
@property (nonatomic, assign) NSInteger messageId;
@property (nonatomic, strong) NSString *peerMessageId;
@property (nonatomic, strong) NSArray<NSString *> *sensitiveWords;
@property (nonatomic, assign) NSInteger timestamp;
@end

NS_ASSUME_NONNULL_END
