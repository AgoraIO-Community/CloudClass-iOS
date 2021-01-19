//
//  EduKVCUserConfig.h
//  EduSDK
//
//  Created by SRS on 2020/10/18.
//  Copyright © 2020 agora. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "EduChannelMessageHandle.h"
#import "EduClassroomMediaOptions.h"

NS_ASSUME_NONNULL_BEGIN

@interface EduKVCUserConfig : NSObject

@property (nonatomic, strong) NSString *roomUuid;
@property (nonatomic, weak) EduChannelMessageHandle *messageHandle;
@property (nonatomic, strong) NSString *userToken;
@property (nonatomic, strong) EduClassroomMediaOptions *mediaOption;

@end

NS_ASSUME_NONNULL_END
