//
//  AgoraBaseViewController.h
//  AgoraEducation
//
//  Created by SRS on 2020/8/3.
//  Copyright © 2020 Agora. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <AgoraEduSDK/AgoraClassroomSDK.h>
#import <AgoraEduSDK/AgoraEduSDK-Swift.h>
#import <AgoraEduContext/AgoraEduContext-Swift.h>
#import <AgoraUIBaseViews/AgoraUIBaseViews-Swift.h>
#import <AgoraUIEduBaseViews/AgoraUIEduBaseViews-Swift.h>
#import <AgoraUIEduAppViews/AgoraUIEduAppViews-Swift.h>
#import "AgoraEduManager.h"
#import "AgoraManagerCache.h"

NS_ASSUME_NONNULL_BEGIN

@protocol VCProcessDelegate <NSObject>
@optional

- (void)onJoinClassroomSuccess;

// room
- (void)onSetClassroomName:(NSString *)roomName;
- (void)onSetClassState:(AgoraEduContextClassState)state;
- (void)onSetClassTime:(NSString *)time;
- (void)onShowClassTips:(NSString *)message;
- (void)onSetNetworkQuality:(AgoraEduContextNetworkQuality)quality;
- (void)onSetConnectionState:(AgoraEduContextConnectionState)state;
- (void)onShowErrorInfo:(AgoraEduContextError *)error;
- (void)onFlexRoomPropertiesInitialize:(NSDictionary *) properties;
- (void)onFlexRoomPropertiesChanged:(NSDictionary *)changedProperties
                         properties:(NSDictionary *)properties
                              cause:(NSDictionary *)cause
                       operatorUser:(AgoraEduContextUserInfo *)operatorUser;

// user
- (void)onUpdateUserList:(NSArray<AgoraEduContextUserDetailInfo*> *)list;
- (void)onUpdateCoHostList:(NSArray<AgoraEduContextUserDetailInfo*> *)list;
- (void)onKickedOut;
- (void)onUpdateAudioVolumeIndication:(NSInteger)value
                           streamUuid:(NSString *)streamUuid;
- (void)onShowUserTips:(NSString *)message;
- (void)onFlexUserPropertiesChanged:(NSDictionary *)changedProperties
                         properties:(NSDictionary *)properties
                              cause:(NSDictionary *)cause
                           fromUser:(AgoraEduContextUserDetailInfo *)fromUser
                       operatorUser:(AgoraEduContextUserInfo *)operatorUser;

// chat
- (void)onAddRoomMessage:(AgoraEduContextChatInfo *)chatInfo;
- (void)onAddConversationMessage:(AgoraEduContextChatInfo *)chatInfo;
- (void)updateRoomChatState:(BOOL)muteChat;
- (void)onLocalChatState:(BOOL)muteChat
                          to:(AgoraEduContextUserInfo *)userInfo
                          by:(AgoraEduContextUserInfo *)operator;
- (void)updateLocalChatState:(BOOL)muteChat
                          to:(AgoraEduContextUserInfo *)userInfo
                          by:(AgoraEduContextUserInfo *)operator;
- (void)updateRemoteChatState:(BOOL)muteChat
                           to:(AgoraEduContextUserInfo *)userInfo
                           by:(AgoraEduContextUserInfo *)operator;
- (void)onShowChatTips:(NSString *)message;

// handsup
- (void)onSetHandsUpEnable:(BOOL)enable;
- (void)onSetHandsUpState:(AgoraEduContextHandsUpState)state;
- (void)onShowHandsUpTips:(NSString *)message;

@end

@interface AgoraBaseViewController : UIViewController<VCProcessDelegate>

// data
@property (nonatomic, strong) AgoraVMConfig *vmConfig;

// VM
@property (nonatomic, strong) AgoraRoomVM * _Nullable roomVM;
@property (nonatomic, strong) AgoraUserVM * _Nullable userVM;
@property (nonatomic, strong) AgoraChatVM * _Nullable chatVM;
@property (nonatomic, strong) AgoraHandsUpVM * _Nullable handsUpVM;
@property (nonatomic, strong) AgoraScreenVM * _Nullable screenVM;

// Protocol
@property (nonatomic, strong) AgoraUIEventDispatcher *eventDispatcher;

//// ContextPool
@property (nonatomic, strong) AgoraEduContextPoolIMP *contextPool;

// View
@property (nonatomic, weak) AgoraBaseUIView *appView;

// host
@property (nonatomic, copy) NSString *host;

// imp in AgoraBaseViewController+Room
- (void)onShowErrorInfo:(AgoraEduContextError *)error;

// imp in ChildViewController
- (void)updateAllList;

- (void)registerExtApps:(NSArray<AgoraExtAppConfiguration *> *)apps;

- (void)registerWidgets:(NSArray<AgoraWidgetConfiguration *> *)widgets;

- (void)classroomPropertyUpdated:(NSDictionary *)changedProperties
                       classroom:(AgoraRTEClassroom *)classroom
                           cause:(NSDictionary * _Nullable)cause
                    operatorUser:(AgoraRTEBaseUser *)operatorUser;

// init controllers
- (void)initChildren;
- (void)initContextPool;

// rte delegate
// TODO: move to category
- (void)classroom:(AgoraRTEClassroom * _Nonnull)classroom
remoteStreamsInit:(NSArray<AgoraRTEStream*> *)streams;
- (void)classroom:(AgoraRTEClassroom * _Nonnull)classroom
remoteStreamsAdded:(NSArray<AgoraRTEStreamEvent*> *)events;
@end

NS_ASSUME_NONNULL_END
