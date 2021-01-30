//
//  AgoraRTEStudentService.h
//  Demo
//
//  Created by SRS on 2020/6/19.
//  Copyright © 2020 agora. All rights reserved.
//

#import "AgoraRTEUserService.h"
#import "AgoraRTEUserDelegate.h"

NS_ASSUME_NONNULL_BEGIN

@interface AgoraRTEStudentService : AgoraRTEUserService

@property (nonatomic, weak) id<AgoraRTEStudentDelegate> delegate;

@end

NS_ASSUME_NONNULL_END
