//
//  DeviceManager.h
//  AgoraLog
//
//  Created by SRS on 2020/7/2.
//  Copyright © 2020 agora. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface DeviceManager : NSObject
+ (NSString *)getDeviceIdentifier;
@end

NS_ASSUME_NONNULL_END
