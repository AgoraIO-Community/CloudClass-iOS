//
//  EduClassroomJoinConfig.h
//  EduSDK
//
//  Created by SRS on 2020/7/3.
//  Copyright © 2020 agora. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "EduClassroomMediaOptions.h"
#import "EduUser.h"

NS_ASSUME_NONNULL_BEGIN

@interface EduClassroomJoinOptions : NSObject

@property (nonatomic, copy) NSString *userName;
@property (nonatomic, assign) EduRoleType role;

@property (nonatomic, strong) EduClassroomMediaOptions *mediaOption;

- (instancetype)initWithUserName:(NSString *)userName role:(EduRoleType)role;
- (instancetype)initWithRole:(EduRoleType)role;

@end

NS_ASSUME_NONNULL_END
