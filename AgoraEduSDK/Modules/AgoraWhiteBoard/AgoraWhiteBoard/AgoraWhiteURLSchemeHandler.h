//
//  AgoraWhiteURLSchemeHandler.h
//  AgoraWhiteBoard
//
//  Created by SRS on 2021/2/10.
//  Copyright © 2021 agora. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <WebKit/WebKit.h>

#define AgoraWhiteCoursewareDirectory [NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES).firstObject stringByAppendingString:@"/AgoraDownload/"]

#define AgoraWhiteCoursewareScheme @"agoranetless"

NS_ASSUME_NONNULL_BEGIN

API_AVAILABLE(macos(10.13), ios(11.0))
@interface AgoraWhiteURLSchemeHandler : NSObject<WKURLSchemeHandler>
@property (nonatomic, readonly, copy) NSString *scheme;
@property (nonatomic, readonly, copy) NSString *directory;

- (instancetype)initWithScheme:(NSString *)scheme
                     directory:(NSString *)dir;

- (NSString *)filePath:(NSURLRequest *)request;
- (NSURLRequest *)httpRequest:(NSURLRequest *)originRequest;
@end

NS_ASSUME_NONNULL_END
