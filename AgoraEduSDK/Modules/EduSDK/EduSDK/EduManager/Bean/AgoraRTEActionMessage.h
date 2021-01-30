//
//  AgoraRTEActionMessage.h
//  EduSDK
//
//  Created by SRS on 2020/9/24.
//

#import <Foundation/Foundation.h>
#import "AgoraRTEEnumerates.h"
#import "AgoraRTEUser.h"

NS_ASSUME_NONNULL_BEGIN

@interface AgoraRTEActionMessage : NSObject
@property (nonatomic, strong, readonly) NSString *processUuid;
@property (nonatomic, assign, readonly) AgoraRTEActionType action;
@property (nonatomic, assign, readonly) NSInteger timeout;
@property (nonatomic, strong, readonly) AgoraRTEBaseUser *fromUser;
@property (nonatomic, strong, readonly) NSDictionary *payload;
@end

NS_ASSUME_NONNULL_END
