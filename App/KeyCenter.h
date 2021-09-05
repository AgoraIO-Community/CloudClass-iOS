//
//  KeyCenter.h
//  AgoraEducation
//
//  Created by SRS on 2021/1/10.
//  Copyright © 2021 yangmoumou. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface KeyCenter : NSObject

// For Agora SDK APP id，you can refer to [https://docs.agora.io/en/Agora%20Platform/terms?platform=All%20Platforms#a-nameappidaapp-id]
+ (NSString *)appId;
+ (NSString *)appCertificate;
+ (NSString *)hostURL;
+ (NSString *)rtcVersion;
+ (NSString *)publishDate;
@end

NS_ASSUME_NONNULL_END
