//
//  AgoraRTEKVCUserConfig.h
//  EduSDK
//
//  Created by SRS on 2020/10/18.
//  Copyright © 2020 agora. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "AgoraRTEChannelMessageHandle.h"
#import "AgoraRTEClassroomMediaOptions.h"

NS_ASSUME_NONNULL_BEGIN

@interface AgoraRTEKVCUserConfig : NSObject

@property (nonatomic, strong) NSString *roomUuid;
@property (nonatomic, weak) AgoraRTEChannelMessageHandle *messageHandle;
@property (nonatomic, strong) NSString *userToken;
@property (nonatomic, strong) AgoraRTEClassroomMediaOptions *mediaOption;

@end

NS_ASSUME_NONNULL_END
