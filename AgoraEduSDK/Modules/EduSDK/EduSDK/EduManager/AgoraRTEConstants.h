
//
//  AgoraRTEConstants.h
//  EduSDK
//
//  Created by SRS on 2020/7/21.
//  Copyright © 2020 agora. All rights reserved.
//

#import <Foundation/Foundation.h>

#ifndef AgoraRTEConstants_h
#define AgoraRTEConstants_h

#define AgoraRTENoNullString(x) ([x isKindOfClass:NSString.class] ? x : @"")
#define AgoraRTENoNullArray(x) ([x isKindOfClass:NSArray.class] ? x : @[])
#define AgoraRTENoNullDictionary(x) ([x isKindOfClass:NSDictionary.class] ? x : @{})
#define AgoraRTENoNull(x) ((x == nil) ? @"nil" : x)

#define AgoraRTELocalErrorDomain @"io.agora.AgoraEduSDK"
#define AgoraRTELocalError(errCode, reason) ([NSError errorWithDomain:AgoraRTELocalErrorDomain \
    code:(errCode) \
userInfo:@{NSLocalizedDescriptionKey:(reason)}])

#define AgoraRTEWEAK(object) __weak typeof(object) weak##object = object

extern const NSString *kAgoraRTEServiceRoleHost;
extern const NSString *kAgoraRTEServiceRoleAssistant;
extern const NSString *kAgoraRTEServiceRoleBroadcaster;
extern const NSString *kAgoraRTEServiceRoleAudience;


#endif /* EduConstants_h */



