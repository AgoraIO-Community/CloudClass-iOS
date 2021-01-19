
//
//  EduConstants.h
//  EduSDK
//
//  Created by SRS on 2020/7/21.
//  Copyright © 2020 agora. All rights reserved.
//

#import <Foundation/Foundation.h>

#ifndef EduConstants_h
#define EduConstants_h

#define NoNullNumber(x) (([x isKindOfClass:NSNumber.class]) ? x : @(0))
#define NoNullString(x) ([x isKindOfClass:NSString.class] ? x : @"")
#define NoNullArray(x) ([x isKindOfClass:NSArray.class] ? x : @[])
#define NoNullDictionary(x) ([x isKindOfClass:NSDictionary.class] ? x : @{})
#define NoNull(x) ((x == nil) ? @"nil" : x)

#define LocalErrorDomain @"io.agora.AgoraEduSDK"
#define LocalError(errCode, reason) ([NSError errorWithDomain:LocalErrorDomain \
    code:(errCode) \
userInfo:@{NSLocalizedDescriptionKey:(reason)}])

#define WEAK(object) __weak typeof(object) weak##object = object

extern const NSString *kServiceRoleHost;
extern const NSString *kServiceRoleHost;
extern const NSString *kServiceRoleAssistant;
extern const NSString *kServiceRoleBroadcaster;
extern const NSString *kServiceRoleAudience;


#endif /* EduConstants_h */



