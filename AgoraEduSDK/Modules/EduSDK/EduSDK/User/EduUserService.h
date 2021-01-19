//
//  EduUserService.h
//  Demo
//
//  Created by SRS on 2020/6/17.
//  Copyright © 2020 agora. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import "EduStreamConfig.h"
#import "EduBaseTypes.h"
#import "EduStream.h"
#import "EduUser.h"
#import "EduVideoConfig.h"
#import "EduEnumerates.h"
#import "EduUserDelegate.h"

@interface EduRenderConfig : NSObject
@property (nonatomic, assign) EduRenderMode renderMode;
@end

NS_ASSUME_NONNULL_BEGIN

typedef void(^OnUserMediaChangedSuccessBlock)(EduStream *stream);

@interface EduUserService : NSObject

@property (nonatomic, weak, nullable) id <EduMediaStreamDelegate> mediaStreamDelegate;

// you must set Video Config before startOrUpdateLocalStream
- (NSError * _Nullable)setVideoConfig:(EduVideoConfig*)config;

// media
- (void)startOrUpdateLocalStream:(EduStreamConfig*)config success:(OnUserMediaChangedSuccessBlock)successBlock failure:(EduFailureBlock _Nullable)failureBlock;

- (NSError * _Nullable)switchCamera;

// stream
- (void)subscribeStream:(EduStream*)stream options:(EduSubscribeOptions*)options success:(EduSuccessBlock)successBlock failure:(EduFailureBlock _Nullable)failureBlock;
- (void)unsubscribeStream:(EduStream*)stream options:(EduSubscribeOptions*)options success:(EduSuccessBlock)successBlock failure:(EduFailureBlock _Nullable)failureBlock;

- (void)publishStream:(EduStream*)stream success:(EduSuccessBlock)successBlock failure:(EduFailureBlock _Nullable)failureBlock;
- (void)muteStream:(EduStream*)stream success:(EduSuccessBlock)successBlock failure:(EduFailureBlock _Nullable)failureBlock;
- (void)unpublishStream:(EduStream*)stream success:(EduSuccessBlock)successBlock failure:(EduFailureBlock _Nullable)failureBlock;

// message
- (void)sendRoomMessageWithText:(NSString*)text success:(EduSuccessBlock)successBlock failure:(EduFailureBlock _Nullable)failureBlock;
- (void)sendUserMessageWithText:(NSString*)text remoteUser:(EduUser *)remoteUser success:(EduSuccessBlock)successBlock failure:(EduFailureBlock _Nullable)failureBlock;
- (void)sendRoomChatMessageWithText:(NSString*)text success:(EduSuccessBlock)successBlock failure:(EduFailureBlock _Nullable)failureBlock;
- (void)sendUserChatMessageWithText:(NSString*)text remoteUser:(EduUser *)remoteUser success:(EduSuccessBlock)successBlock failure:(EduFailureBlock _Nullable)failureBlock;

// property
- (void)setRoomProperties:(NSDictionary<NSString *, NSString *> *)properties cause:(EduObject * _Nullable)cause success:(EduSuccessBlock)successBlock failure:(EduFailureBlock _Nullable)failureBlock;
- (void)deleteRoomProperties:(NSArray<NSString *> *)keys cause:(EduObject * _Nullable)cause success:(EduSuccessBlock)successBlock failure:(EduFailureBlock _Nullable)failureBlock;

// render
- (NSError * _Nullable)setStreamView:(UIView * _Nullable)view stream:(EduStream *)stream;
- (NSError * _Nullable)setStreamView:(UIView * _Nullable)view stream:(EduStream *)stream renderConfig:(EduRenderConfig*)config;

- (void)destory;

#pragma mark Unavailable Initializers
+ (instancetype)new NS_UNAVAILABLE;
- (instancetype)init NS_UNAVAILABLE;

@end

NS_ASSUME_NONNULL_END
