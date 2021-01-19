//
//  EduBaseTypes.h
//  EduSDK
//
//  Created by SRS on 2020/7/8.
//  Copyright © 2020 agora. All rights reserved.
//

NS_ASSUME_NONNULL_BEGIN

typedef void(^EduSuccessBlock)(void);
typedef void(^EduFailureBlock)(NSError *error);

typedef NSDictionary<NSString *, NSString *> EduObject;

typedef NS_ENUM(NSInteger, EduDebugItem) {
    EduDebugItemLog
};

NS_ASSUME_NONNULL_END
