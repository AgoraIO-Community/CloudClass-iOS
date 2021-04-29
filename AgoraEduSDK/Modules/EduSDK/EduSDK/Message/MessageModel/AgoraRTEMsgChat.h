//
//  AgoraRTEMsgChat.h
//  EduSDK
//
//  Created by SRS on 2020/7/22.
//  Copyright © 2020 agora. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "AgoraRTEUser.h"
#import "AgoraRTEClassroom.h"

NS_ASSUME_NONNULL_BEGIN

@interface AgoraRTEMsgChat : NSObject
@property (nonatomic, assign) NSInteger type;
@property (nonatomic, strong) NSString *message;
@property (nonatomic, assign) NSInteger messageId;
@property (nonatomic, assign) NSInteger sendTime;
@property (nonatomic, strong) AgoraRTEUser *fromUser;
@property (nonatomic, strong) NSArray<NSString *> *sensitiveWords;
@property (nonatomic, strong) AgoraRTEClassroomInfo *fromRoom;
@end

NS_ASSUME_NONNULL_END
