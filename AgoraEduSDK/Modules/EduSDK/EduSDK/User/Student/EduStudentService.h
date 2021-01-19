//
//  EduStudentService.h
//  Demo
//
//  Created by SRS on 2020/6/19.
//  Copyright © 2020 agora. All rights reserved.
//

#import "EduUserService.h"
#import "EduUserDelegate.h"

NS_ASSUME_NONNULL_BEGIN

@interface EduStudentService : EduUserService

@property (nonatomic, weak) id<EduStudentDelegate> delegate;

@end

NS_ASSUME_NONNULL_END
