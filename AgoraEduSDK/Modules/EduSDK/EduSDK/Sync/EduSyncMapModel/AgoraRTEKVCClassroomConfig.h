//
//  AgoraRTEKVCClassroomConfig.h
//  EduSDK
//
//  Created by SRS on 2020/10/18.
//  Copyright © 2020 agora. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "AgoraRTEEnumerates.h"

NS_ASSUME_NONNULL_BEGIN

@interface AgoraRTEKVCClassroomConfig : NSObject

@property (nonatomic, copy) NSString *roomUuid;
@property (nonatomic, copy) NSString *dafaultUserName;
@property (nonatomic, assign) AgoraRTESceneType sceneType;

@property (nonatomic, copy, nullable) NSString *encryptionKey;
@property (nonatomic, assign) NSInteger encryptionMode;

@end

NS_ASSUME_NONNULL_END
