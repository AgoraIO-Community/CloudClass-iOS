//
//  AgoraRTEClassroomJoinConfig.h
//  EduSDK
//
//  Created by SRS on 2020/7/3.
//  Copyright © 2020 agora. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "AgoraRTEClassroomMediaOptions.h"
#import "AgoraRTEUser.h"
#import "AgoraRTEObjects.h"

NS_ASSUME_NONNULL_BEGIN

@interface AgoraRTEClassroomJoinOptions : NSObject

@property (nonatomic, copy) NSString *userName;
@property (nonatomic, assign) AgoraRTERoleType role;

@property (nonatomic, strong) AgoraRTEClassroomMediaOptions *mediaOption;
@property (nonatomic, strong, nullable) AgoraRTEVideoConfig *videoConfig;

- (instancetype)initWithUserName:(NSString *)userName role:(AgoraRTERoleType)role;
- (instancetype)initWithRole:(AgoraRTERoleType)role;

@end

NS_ASSUME_NONNULL_END
