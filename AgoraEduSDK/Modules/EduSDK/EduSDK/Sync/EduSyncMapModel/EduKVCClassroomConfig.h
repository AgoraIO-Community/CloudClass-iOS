//
//  EduKVCClassroomConfig.h
//  EduSDK
//
//  Created by SRS on 2020/10/18.
//  Copyright © 2020 agora. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "EduEnumerates.h"

NS_ASSUME_NONNULL_BEGIN

@interface EduKVCClassroomConfig : NSObject

@property (nonatomic, copy) NSString *roomUuid;
@property (nonatomic, copy) NSString *dafaultUserName;
@property (nonatomic, assign) EduSceneType sceneType;

@end

NS_ASSUME_NONNULL_END
