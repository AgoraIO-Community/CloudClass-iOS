//
//  AgoraRTEBaseTypes.h
//  EduSDK
//
//  Created by SRS on 2020/7/8.
//  Copyright © 2020 agora. All rights reserved.
//

NS_ASSUME_NONNULL_BEGIN

typedef void(^AgoraRTESuccessBlock)(void);
typedef void(^AgoraRTEFailureBlock)(NSError *error);

typedef NSDictionary<NSString *, NSString *> AgoraRTEObject;

typedef NS_ENUM(NSInteger, AgoraRTEDebugItem) {
    AgoraRTEDebugItemLog
};

NS_ASSUME_NONNULL_END
