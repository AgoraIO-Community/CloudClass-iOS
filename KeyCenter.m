//
//  KeyCenter.m
//  AgoraEducation
//
//  Created by SRS on 2021/1/10.
//  Copyright © 2021 yangmoumou. All rights reserved.
//

#import "KeyCenter.h"

@implementation KeyCenter
+ (NSString *)rtcVersion {
    return @"2.9.107.136";
}

+ (NSString *)publishDate {
    return @"2021.05.28";
}

+ (NSString *)appId {
    return <#Your Agora AppID#>;
}

+ (NSString *)appCertificate {
    return <#Your Agora Certificate#>;
}

+ (NSString *)hostURL {
    return @"https://api-test.agora.io/preview";
}

// PreProduct
//+ (NSString *)hostURL {
//    return @"https://api-test.agora.io/preview";
//}

// Product
//+ (NSString *)hostURL {
//    return @"https://api.agora.io";
//}
@end
