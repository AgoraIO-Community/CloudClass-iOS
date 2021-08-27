//
//  CountDownExtApp.m
//  AgoraEducation
//
//  Created by Cavan on 2021/4/13.
//  Copyright © 2021 Agora. All rights reserved.
//

#import "CountDownExtApp.h"
#import "AgoraCloudClass-Swift.h"
@import AgoraUIBaseViews;
@import AgoraEduExtApp;
@import AgoraEduContext;

typedef enum : NSInteger {
    CountdownStateDefault = 0,
    CountdownStateStart,
    CountdownStatePause,
    CountdownStateStop,
} CountdownState;

@interface CountDownExtApp ()<CountDownDelegate, AgoraEduWhiteBoardHandler>
@property (nonatomic, strong) id<CountDownProtocol> countDown;
@property (nonatomic, assign) CountdownState localState;

@property (nonatomic, assign) NSInteger startTime;
@property (nonatomic, assign) NSInteger pauseTime;
@property (nonatomic, assign) NSInteger duration;
@end

@implementation CountDownExtApp
#pragma mark - Data callback
- (void)propertiesDidUpdate:(NSDictionary *)properties {

    [super propertiesDidUpdate:properties];
    
    if (properties.allValues.count <= 0) {
        return;
    }
    
    [self handleTimer];
}

#pragma mark - Life cycle
- (void)extAppDidLoad:(AgoraEduExtAppContext *)context {
    [self initView];
    [self initData:context.properties];
    
    [context.contextPool.whiteBoard registerBoardEventHandler:self];
}

- (void)extAppWillUnload {
    [self.countDown cancelCountDown];
}

#pragma mark - AgoraEduWhiteBoardHandler
// 有权限就可以移动白板，否则不可以
- (void)onSetDrawingEnabled:(BOOL)enabled {
    self.view.agora_is_draggable = enabled;
}

#pragma mark - private
- (void)initView {
    [self.view setUserInteractionEnabled:YES];
    self.view.backgroundColor = UIColor.clearColor;

    CountDownWrapper *wrapper = [[CountDownWrapper alloc] init];
    AgoraBaseUIView *containerView = [wrapper getViewWithDelegate:self];
    self.countDown = [wrapper getCountDwon];
    
    [self.view addSubview:containerView];
    
    BOOL isPad = [UIDevice.currentDevice.model isEqualToString:@"iPad"] ? YES : NO;
    [self.view agora_clear_constraint];
    [containerView agora_clear_constraint];
    self.view.agora_center_x = 0;
    self.view.agora_center_y = 0;
    self.view.agora_width = isPad ? 260 : 184;
    self.view.agora_height = isPad ? 140 : 102;
    
    containerView.agora_x = 0;
    containerView.agora_y = 0;
    containerView.agora_right = 0;
    containerView.agora_bottom = 0;
}

- (void)initData:(NSDictionary *)properties {
    [self propertiesDidUpdate:properties];
}

- (NSInteger)getCurrentTime {
    NSDate *date = [NSDate date];
    return [date timeIntervalSince1970];
}

- (void)setProperties:(NSDictionary *)properties {
    if ([properties isEqualToDictionary:self.properties]) {
        [self.view setHidden:YES];
        return;
    }
    [super setProperties:properties];
}

- (void)setLocalState:(CountdownState)localState {
    if (localState == _localState) {
        return;
    }
    _localState = localState;
}

#pragma mark - Timer
- (void)handleTimer {
    [self.view setHidden:NO];
    
    NSString *remoteStateStr = (NSString *)self.properties[@"state"];
    NSInteger remoteState = remoteStateStr.integerValue;
    if (remoteState == 0) {
        return;
    }
    
    switch (remoteState) {
        case CountdownStateStart:
            [self startTimer];
            break;
        case CountdownStatePause:
            [self pauseTimer];
            break;
        default:
            break;
    }
}

- (void)startTimer {
    self.localState = CountdownStateStart;
    NSString *startTimeStr = (NSString *)self.properties[@"startTime"];
    NSString *durationStr = (NSString *)self.properties[@"duration"];
    
    if (!startTimeStr ||
        !durationStr ||
        startTimeStr.integerValue == 0 ||
        durationStr.integerValue == 0) {
        return;
    }
    
    NSInteger totalSeconds = (startTimeStr.integerValue + durationStr.integerValue) - [self getCurrentTime];
    
    if (totalSeconds <= 0) {
        totalSeconds = 0;
        self.localState = CountdownStateStop;
    }
    
    [self.countDown invokeCountDownWithTotalSeconds:totalSeconds ifExecute:YES];
}

- (void)stopTimer {
    self.localState = CountdownStateStop;
    [self.countDown cancelCountDown];
}

- (void)pauseTimer {
    
    NSString *startTimeStr = (NSString *)self.properties[@"startTime"];
    NSString *pauseTimeStr = (NSString *)self.properties[@"pauseTime"];
    NSString *durationStr = (NSString *)self.properties[@"duration"];
    
    if (!startTimeStr ||
        !pauseTimeStr ||
        startTimeStr.integerValue == 0 ||
        pauseTimeStr.integerValue == 0 ||
        (pauseTimeStr.integerValue < startTimeStr.integerValue)) {
        return;
    }
    
    NSInteger time = 0;
    
    if (startTimeStr.integerValue + durationStr.integerValue >= [self getCurrentTime]) {
        time = pauseTimeStr.integerValue - startTimeStr.integerValue;
    }
    switch (self.localState) {
        case CountdownStateDefault:
            [self.countDown invokeCountDownWithTotalSeconds:time ifExecute:NO];
            self.localState = CountdownStatePause;
            break;
        case CountdownStateStart: {
            self.localState = CountdownStatePause;
            [self.countDown pauseCountDown];
            break;
        }
        case CountdownStateStop:
            self.localState = CountdownStatePause;
            break;
        case CountdownStatePause:
            [self.countDown invokeCountDownWithTotalSeconds:time ifExecute:NO];
            break;
        default:
            break;
    }
}

# pragma mark - CountDownDelegate
- (void)countDownDidStop {
    self.localState = CountdownStateStop;
}

- (void)countDownUpTo:(NSInteger)currrentSeconds {
    
}
@end

