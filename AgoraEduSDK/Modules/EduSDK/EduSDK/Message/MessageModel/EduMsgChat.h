//
//  EduMsgChat.h
//  EduSDK
//
//  Created by SRS on 2020/7/22.
//  Copyright © 2020 agora. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "EduUser.h"
#import "EduClassroom.h"

NS_ASSUME_NONNULL_BEGIN

@interface EduMsgChat : NSObject
@property (nonatomic, assign) NSInteger type;
@property (nonatomic, strong) NSString *message;
@property (nonatomic, strong) EduUser *fromUser;
@property (nonatomic, strong) EduClassroomInfo *fromRoom;
@end

NS_ASSUME_NONNULL_END
