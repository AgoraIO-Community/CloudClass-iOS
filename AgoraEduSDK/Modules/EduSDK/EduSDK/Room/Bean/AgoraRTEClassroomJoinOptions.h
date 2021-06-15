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

NS_ASSUME_NONNULL_BEGIN

@interface AgoraRTEClassroomJoinOptions : NSObject

@property (nonatomic, copy) NSString *userName;
@property (nonatomic, assign) AgoraRTERoleType role;
@property (nonatomic, copy) NSString *urlRegion;
@property (nonatomic, copy) NSString *rtcRegion;

@property (nonatomic, strong) AgoraRTEClassroomMediaOptions *mediaOption;

- (instancetype)initWithUserName:(NSString *)userName
                       urlRegion:(NSString *)urlRegion
                       rtcRegion:(NSString *)rtcRegion
                            role:(AgoraRTERoleType)role;
- (instancetype)initWithRole:(AgoraRTERoleType)role;

@end

NS_ASSUME_NONNULL_END
