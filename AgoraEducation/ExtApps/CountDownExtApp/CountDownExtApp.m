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

typedef enum : NSInteger {
    CountdownStateDefault = 0,
    CountdownStateStart,
    CountdownStatePause,
    CountdownStateStop,
} CountdownState;

@interface CountDownExtApp ()<CountDownDelegate>
@property (nonatomic, strong) id<CountDownProtocol> countDown;
@property (nonatomic, assign) CountdownState localState;

@property (nonatomic, assign) NSInteger startTime;
@property (nonatomic, assign) NSInteger pauseTime;
@property (nonatomic, assign) NSInteger duration;
@end

@implementation CountDownExtApp
#pragma mark - Data callback
- (void)propertiesDidUpdate:(NSDictionary *)properties {
    /*
     * startTime,duration,stop
     */
    if ([properties isEqualToDictionary:self.properties]) {
        [self.view setHidden:YES];
        return;
    }
    
    [super propertiesDidUpdate:properties];
    
    if (properties.allValues.count <= 0) {
        return;
    }
    
    [self handleTimer];
}

#pragma mark - Life cycle
- (void)extAppDidLoad:(AgoraExtAppContext *)context {
    [self initView];
    [self initData:context.properties];
}

- (void)extAppWillUnload {
    
}

#pragma mark - private
- (void)initView {
    [self.view setUserInteractionEnabled:YES];
    self.view.backgroundColor = UIColor.clearColor;

    AgoraBaseUIView *containerView = [CountDownWrapper getViewWithDelegate:self];
    self.countDown = [CountDownWrapper getCountDwon];
    
    [self.view addSubview:containerView];
    
    BOOL isPad = [UIDevice.currentDevice.model isEqualToString:@"iPad"] ? YES : NO;
    [self.view agora_clear_constraint];
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
    UIPanGestureRecognizer *pan = [[UIPanGestureRecognizer alloc] initWithTarget:self
                                                                          action:@selector(drag:)];
    [self.view addGestureRecognizer:pan];
}

- (void)drag:(UIPanGestureRecognizer *)recognizer {
    if (![recognizer.view isKindOfClass:AgoraBaseUIView.class]) {
        return;
    }
    AgoraBaseUIView *view = (AgoraBaseUIView *)recognizer.view;
    
    CGPoint trans = [recognizer translationInView:UIApplication.sharedApplication.keyWindow];
    
    CGFloat ori_x = view.center.x;
    CGFloat ori_y = view.center.y;
    
    BOOL needXConstraint = (view.frame.origin.x + view.frame.size.width + trans.x > view.superview.frame.size.width) || view.frame.origin.x + trans.x < 0;
    BOOL needYConstraint = (view.frame.origin.y + view.frame.size.height + trans.y > view.superview.frame.size.height) || view.frame.origin.y + trans.y < 0;
    
    CGFloat new_x = needXConstraint ? ori_x : (ori_x + trans.x);
    CGFloat new_y = needYConstraint ? ori_y : (ori_y + trans.y);
    
    if (recognizer.state == UIGestureRecognizerStateChanged) {
        [UIView animateWithDuration:0
                         animations:^{
            recognizer.view.center = CGPointMake(new_x,
                                                 new_y);
            [recognizer setTranslation:CGPointZero
                                inView:recognizer.view];
        }];
    }
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
    [self stopTimer];
    
    self.localState = CountdownStateStart;
    NSString *startTimeStr = (NSString *)self.properties[@"startTime"];
    NSString *durationStr = (NSString *)self.properties[@"duration"];
    
    NSDate *date = [NSDate date];
    NSInteger current = [date timeIntervalSince1970];
    
    NSInteger totalSeconds = (startTimeStr.integerValue + durationStr.integerValue) - current;
    
    if (totalSeconds <= 0) {
        return;
    }
    
    [self.countDown setCountDownWithTotalSeconds:totalSeconds];
    [self.countDown invokeCountDown];
}

- (void)stopTimer {
    self.localState = CountdownStateStop;
    [self.countDown cancelCountDown];
}

- (void)pauseTimer {
    
    NSString *startTimeStr = (NSString *)self.properties[@"startTime"];
    NSString *pauseTimeStr = (NSString *)self.properties[@"pauseTime"];
    
    if (pauseTimeStr.integerValue < startTimeStr.integerValue) {
        return;
    }
    
    switch (self.localState) {
        case CountdownStateDefault:
            [self.countDown setCountDownWithTotalSeconds:(pauseTimeStr.integerValue - startTimeStr.integerValue)];
            break;
        case CountdownStateStart: {
            self.localState = CountdownStatePause;
            [self.countDown pauseCountDown];
            break;
        }
        case CountdownStateStop:
            self.localState = CountdownStatePause;
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

