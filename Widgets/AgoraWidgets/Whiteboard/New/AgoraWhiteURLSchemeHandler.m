//
//  AgoraWhiteURLSchemeHandler.m
//  AgoraWhiteBoard
//
//  Created by SRS on 2021/2/10.
//  Copyright © 2021 agora. All rights reserved.
//

#import "AgoraWhiteURLSchemeHandler.h"
#import "AgoraWeakProxy.h"

@interface AgoraWhiteURLSchemeHandler ()
@property (nonatomic, copy) NSString *scheme;
@property (nonatomic, copy) NSString *directory;

@property (nonatomic, strong) NSURLSession *session;
@property (nonatomic, strong) NSHashTable *hashTable;
@end

@implementation AgoraWhiteURLSchemeHandler
- (instancetype)initWithScheme:(NSString *)scheme
                     directory:(NSString *)directory {
    self = [self init];
    _scheme = scheme;
    _directory = directory;
    AgoraWeakProxy *proxy = [[AgoraWeakProxy alloc] initWithTarget:self];
    _session = [NSURLSession sessionWithConfiguration:[NSURLSessionConfiguration defaultSessionConfiguration]
                                             delegate:proxy
                                        delegateQueue:nil];
    _hashTable = [NSHashTable hashTableWithOptions:NSPointerFunctionsWeakMemory];
    
    return self;
}

#pragma mark -
#pragma mark - Private
#pragma mark -
- (NSString *)filePath:(NSURLRequest *)request {
    NSString *urlString = request.URL.path;

    NSArray<NSString *>* prefixs = @[[self.scheme stringByAppendingString:@"://"],
                                     @"https://",
                                     @"http://"];
    
    for (NSString *prefix in prefixs) {
        if ([urlString hasPrefix:prefix]) {
            urlString = [urlString stringByReplacingOccurrencesOfString:prefix
                                                             withString:@""
                                                                options:NSCaseInsensitiveSearch
                                                                  range:NSMakeRange(0, prefix.length)];
        }
    }
    
    NSString *filePathString = [self.directory stringByAppendingPathComponent:urlString];
    
    return [NSURL fileURLWithPath:filePathString].path;
}

- (NSURLRequest *)httpRequest:(NSURLRequest *)originRequest {
    NSMutableURLRequest *request = [originRequest mutableCopy];

    NSString *urlString = request.URL.absoluteString;
    if ([urlString hasPrefix:self.scheme]) {
        NSRange range = NSMakeRange(0, self.scheme.length);
        urlString = [urlString stringByReplacingCharactersInRange:range
                                                       withString:@"https"];
    }
    request.URL = [NSURL URLWithString:urlString];
    
    return request;
}

- (BOOL)resourcesExist:(NSString *)filePath {
    return [[NSFileManager defaultManager] fileExistsAtPath:filePath];
}

#pragma mark - HTTP
+ (NSString *)mimeTypeForData:(NSData *)data {
    uint8_t c;
    [data getBytes:&c
            length:1];

    switch (c) {
        case 0xFF:
            return @"image/jpeg";
            break;
        case 0x89:
            return @"image/png";
            break;
        case 0x47:
            return @"image/gif";
            break;
        case 0x49:
        case 0x4D:
            return @"image/tiff";
            break;
        case 0x25:
            return @"application/pdf";
            break;
        case 0xD0:
            return @"application/vnd";
            break;
        case 0x46:
            return @"text/plain";
            break;
        default:
            return @"application/octet-stream";
    }
    return nil;
}

#pragma mark - WKURLSchemeHandler
- (void)webView:(WKWebView *)webView
startURLSchemeTask:(id <WKURLSchemeTask>)urlSchemeTask {
    NSURLRequest *request = urlSchemeTask.request;
    NSString *filePath = [self filePath:request];
    
    if ([self resourcesExist:filePath]) {
        NSData *data = [[NSFileManager defaultManager] contentsAtPath:filePath];

        NSURLResponse *response;
        
        BOOL condition1 = [[filePath pathExtension] isEqualToString:@"json"];
        BOOL condition2 = [[filePath pathExtension] isEqualToString:@"xml"];
        
        // js fetch need http status code
        if (condition1 || condition2) {
            response = [[NSHTTPURLResponse alloc] initWithURL:request.URL
                                                   statusCode:200
                                                  HTTPVersion:@"HTTP/1.1"
                                                 headerFields:nil];
        } else {
            NSString *mimeType = [[self class] mimeTypeForData:data];
            response = [[NSURLResponse alloc] initWithURL:request.URL
                                                 MIMEType:mimeType
                                    expectedContentLength:data.length
                                         textEncodingName:nil];
        }
        
        [urlSchemeTask didReceiveResponse:response];
        [urlSchemeTask didReceiveData:data];
        [urlSchemeTask didFinish];
    } else {
        NSURLRequest *httpRequest = [self httpRequest:request];
        [self.hashTable addObject:urlSchemeTask];
        
        NSURLSessionDataTask *task = [self.session dataTaskWithRequest:httpRequest
                                                     completionHandler:^(NSData * _Nullable data,
                                                                         NSURLResponse * _Nullable response,
                                                                         NSError * _Nullable error) {
            if (![self.hashTable containsObject:urlSchemeTask]) {
                return ;
            }
            if (response) {
                [urlSchemeTask didReceiveResponse:response];
            }
            if (data) {
                [urlSchemeTask didReceiveData:data];
            }
            if (error) {
                [urlSchemeTask didFailWithError:error];
            } else {
                [urlSchemeTask didFinish];
            }
            [self.hashTable removeObject:urlSchemeTask];
        }];
        [task resume];
    }
}

- (void)webView:(WKWebView *)webView
stopURLSchemeTask:(id <WKURLSchemeTask>)urlSchemeTask {
    [self.hashTable removeObject:urlSchemeTask];
}
@end
