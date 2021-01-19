//
//  AgoraEduBaseViewController.h
//  AgoraEducation
//
//  Created by SRS on 2020/8/3.
//  Copyright © 2020 yangmoumou. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "EETextMessage.h"
#import "EENavigationView.h"
#import "EEChatTextFiled.h"
#import "AppHTTPManager.h"

typedef NS_ENUM(NSInteger, LocalStreamState) {
    // enable capture
    LocalStreamStateIdle,
    // enable capture & publish
    LocalStreamStateCreate,
    // enable capture & (mute | unmute)
    LocalStreamStateUpdate,
    // stop capture & unpublish
    LocalStreamStateRemove
};

NS_ASSUME_NONNULL_BEGIN

@interface AgoraEduBaseViewController : UIViewController

@property (nonatomic, assign) EduSceneType sceneType;
@property (nonatomic, strong) NSString *userUuid;
@property (nonatomic, strong) NSString *userName;
@property (nonatomic, strong) NSString *className;
@property (nonatomic, strong) NSString *roomUuid;

@property (nonatomic, strong) NSString *boardId;
@property (nonatomic, strong) NSString *boardToken;

@property (nonatomic, strong) WhiteBoardStateModel *boardState;
@property (nonatomic, strong) EduLocalUser *localUser;

#pragma mark --
@property (nonatomic, weak) UIView *boardView;
@property (nonatomic, assign) BOOL isChatTextFieldKeyboard;
+ (void)showToast:(NSString *)title;
- (void)setupWhiteBoard:(void (^) (void))success;
- (void)updateTimeState:(EENavigationView *)navigationView;
- (void)updateChatViews:(EEChatTextFiled *)chatTextFiled;

- (void)setLocalStreamVideo:(BOOL)hasVideo audio:(BOOL)hasAudio streamState:(LocalStreamState)state;
@end

NS_ASSUME_NONNULL_END
