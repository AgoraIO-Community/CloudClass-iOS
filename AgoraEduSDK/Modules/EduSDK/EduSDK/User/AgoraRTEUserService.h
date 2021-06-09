//
//  AgoraRTEUserService.h
//  Demo
//
//  Created by SRS on 2020/6/17.
//  Copyright © 2020 agora. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import "AgoraRTEStreamConfig.h"
#import "AgoraRTEBaseTypes.h"
#import "AgoraRTEStream.h"
#import "AgoraRTEUser.h"
#import "AgoraRTEVideoConfig.h"
#import "AgoraRTEEnumerates.h"
#import "AgoraRTEUserDelegate.h"

@interface AgoraRTERenderConfig : NSObject
@property (nonatomic, assign) AgoraRTERenderMode renderMode;
@end

@interface AgoraRTEStreamStateInfo : NSObject
//AgoraRTEStreamState
@property (nonatomic, strong) NSNumber * _Nullable audioState;
@property (nonatomic, strong) NSNumber * _Nullable videoState;
@end

NS_ASSUME_NONNULL_BEGIN

typedef void(^OnUserMediaChangedSuccessBlock)(AgoraRTEStream *stream);

@interface AgoraRTEUserService : NSObject

@property (nonatomic, weak, nullable) id <AgoraRTEMediaStreamDelegate> mediaStreamDelegate;

// @{streamId:AgoraRTEStreamStateInfo}
@property (nonatomic, strong, readonly) NSDictionary<NSString *, AgoraRTEStreamStateInfo *> *streamStateModels;

// you must set Video Config before startOrUpdateLocalStream
- (NSError * _Nullable)setVideoConfig:(AgoraRTEVideoConfig*)config;

// media
- (void)startOrUpdateLocalStream:(AgoraRTEStreamConfig*)config success:(OnUserMediaChangedSuccessBlock)successBlock failure:(AgoraRTEFailureBlock _Nullable)failureBlock;

- (NSError * _Nullable)switchCamera;
- (int)setEnableSpeakerphone:(BOOL)enable;
- (BOOL)isSpeakerphoneEnabled;

// stream
- (void)subscribeStream:(AgoraRTEStream*)stream options:(AgoraRTESubscribeOptions*)options success:(AgoraRTESuccessBlock)successBlock failure:(AgoraRTEFailureBlock _Nullable)failureBlock;
- (void)unsubscribeStream:(AgoraRTEStream*)stream options:(AgoraRTESubscribeOptions*)options success:(AgoraRTESuccessBlock)successBlock failure:(AgoraRTEFailureBlock _Nullable)failureBlock;

- (void)publishStream:(AgoraRTEStream*)stream success:(AgoraRTESuccessBlock)successBlock failure:(AgoraRTEFailureBlock _Nullable)failureBlock;
- (void)muteStream:(AgoraRTEStream*)stream success:(AgoraRTESuccessBlock)successBlock failure:(AgoraRTEFailureBlock _Nullable)failureBlock;
- (void)unpublishStream:(AgoraRTEStream*)stream success:(AgoraRTESuccessBlock)successBlock failure:(AgoraRTEFailureBlock _Nullable)failureBlock;

// message
- (void)sendRoomMessageWithText:(NSString*)text success:(AgoraRTESuccessBlock)successBlock failure:(AgoraRTEFailureBlock _Nullable)failureBlock;
- (void)sendUserMessageWithText:(NSString*)text remoteUser:(AgoraRTEUser *)remoteUser success:(AgoraRTESuccessBlock)successBlock failure:(AgoraRTEFailureBlock _Nullable)failureBlock;
- (void)sendRoomChatMessageWithText:(NSString*)text success:(AgoraRTESuccessBlock)successBlock failure:(AgoraRTEFailureBlock _Nullable)failureBlock;
- (void)sendUserChatMessageWithText:(NSString*)text remoteUser:(AgoraRTEUser *)remoteUser success:(AgoraRTESuccessBlock)successBlock failure:(AgoraRTEFailureBlock _Nullable)failureBlock;

// property
- (void)setRoomProperties:(NSDictionary<NSString *, NSString *> *)properties cause:(AgoraRTEObject * _Nullable)cause success:(AgoraRTESuccessBlock)successBlock failure:(AgoraRTEFailureBlock _Nullable)failureBlock;
- (void)deleteRoomProperties:(NSArray<NSString *> *)keys cause:(AgoraRTEObject * _Nullable)cause success:(AgoraRTESuccessBlock)successBlock failure:(AgoraRTEFailureBlock _Nullable)failureBlock;

// render
- (NSError * _Nullable)setStreamView:(UIView * _Nullable)view stream:(AgoraRTEStream *)stream;
- (NSError * _Nullable)setStreamView:(UIView * _Nullable)view stream:(AgoraRTEStream *)stream renderConfig:(AgoraRTERenderConfig*)config;

- (void)destory;

#pragma mark Unavailable Initializers
+ (instancetype)new NS_UNAVAILABLE;
- (instancetype)init NS_UNAVAILABLE;

@end

NS_ASSUME_NONNULL_END
