//
//  CountDownExtApp.m
//  AgoraEducation
//
//  Created by Cavan on 2021/4/13.
//  Copyright © 2021 Agora. All rights reserved.
//

#import "CountDownExtApp.h"

@interface CountDownExtApp ()
@property (nonatomic, strong) UIButton *closeButton;
@property (nonatomic, strong) UIButton *startButton;
@property (nonatomic, strong) UIButton *stopButton;
@property (nonatomic, strong) UILabel *countDownLabel;
@property (nonatomic, strong) NSTimer *timer;
@property (nonatomic, assign) NSInteger countDown; // second
@end

@implementation CountDownExtApp
#pragma mark - Data callback
- (void)propertiesDidUpdate:(NSDictionary *)properties {
    [super propertiesDidUpdate:properties];
    
    if (properties.allValues.count <= 0) {
        return;
    }
    
    NSString *startTime = properties[@"startTime"];
    
    if (startTime == nil) {
        [self stopTimer];
        return;
    }
    
    NSString *duration = properties[@"duration"];
    NSDate *date = [NSDate date];
    NSInteger start = [startTime integerValue];
    NSInteger durationTime = [duration integerValue];
    NSInteger current = [date timeIntervalSince1970];
    self.countDown = (start + durationTime) - current;
    
    if (self.countDown > 0) {
        [self startTimer];
    }
}

#pragma mark - Life cycle
- (void)extAppDidLoad:(AgoraExtAppContext *)context {
    [self initViews];
    [self initData:context.properties];
    [self layoutViews];
}

- (void)extAppWillUnload {
    
}

#pragma mark - CountDownExtApp
- (void)initViews {
    self.view.backgroundColor = [UIColor colorWithRed:248.0 / 255.0
                                                green:248.0 / 255.0
                                                 blue:252.0 / 255.0
                                                alpha:1];
    self.view.layer.borderWidth = 1;
    self.view.layer.borderColor = UIColor.blackColor.CGColor;
    
    self.closeButton = [[UIButton alloc] initWithFrame:CGRectZero];
    [self.closeButton setTitle:@"Close"
                      forState:UIControlStateNormal];
    [self.closeButton setTitleColor:UIColor.blackColor
                           forState:UIControlStateNormal];
    [self.closeButton addTarget:self
                         action:@selector(doCloseButtonPressed)
               forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:self.closeButton];
    
    self.startButton = [[UIButton alloc] initWithFrame:CGRectZero];
    [self.startButton setTitle:@"Start"
                      forState:UIControlStateNormal];
    [self.startButton setTitleColor:UIColor.blackColor
                           forState:UIControlStateNormal];
    [self.startButton addTarget:self
                         action:@selector(doStartButtonPressed)
               forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:self.startButton];
    
    self.stopButton = [[UIButton alloc] initWithFrame:CGRectZero];
    [self.stopButton setTitle:@"Stop"
                      forState:UIControlStateNormal];
    [self.stopButton setTitleColor:UIColor.blackColor
                           forState:UIControlStateNormal];
    [self.stopButton addTarget:self
                         action:@selector(doStopButtonPressed)
               forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:self.stopButton];
    
    self.countDownLabel = [[UILabel alloc] initWithFrame:CGRectZero];
    self.countDownLabel.textColor = UIColor.blackColor;
    self.countDownLabel.font = [UIFont systemFontOfSize:22];
    self.countDownLabel.text = @"0";
    self.countDownLabel.textAlignment = NSTextAlignmentCenter;
    [self.view addSubview:self.countDownLabel];
}

- (void)initData:(NSDictionary *)properties {
    [self propertiesDidUpdate:properties];
}

- (void)layoutViews {
    CGFloat buttonWidth = 100;
    CGFloat buttonHeight = 40;
    CGFloat distance = 10;
    CGFloat buttonX = self.view.frame.size.width - buttonWidth - distance;
    CGFloat buttonY = distance;
    
    self.closeButton.frame = CGRectMake(buttonX,
                                        buttonY,
                                        buttonWidth,
                                        buttonHeight);
    
    buttonX = buttonX - buttonWidth - 50;
    
    self.startButton.frame = CGRectMake(buttonX,
                                        buttonY,
                                        buttonWidth,
                                        buttonHeight);
    
    buttonX = buttonX - buttonWidth - 50;
    
    self.stopButton.frame = CGRectMake(buttonX,
                                       buttonY,
                                       buttonWidth,
                                       buttonHeight);
    
    CGFloat labelY = buttonY + buttonHeight + distance;
    
    self.countDownLabel.frame = CGRectMake(0,
                                           labelY,
                                           self.view.bounds.size.width,
                                           100);
}

#pragma mark - Button event
- (void)doStartButtonPressed {
    NSDate *date = [NSDate date];
    NSTimeInterval timestamp = date.timeIntervalSince1970;
    NSString *startTimestamp = [NSString stringWithFormat:@"%ld", (long)timestamp];
    NSString *duration = @"100";
    NSDictionary *properties = @{@"startTime": startTimestamp,
                                 @"duration": duration};
    
    [self updateProperties:properties success:^{
        NSLog(@"update successs");
    } fail:^(AgoraExtAppError * _Nonnull error) {
        NSLog(@"update fail");
    }];
}

- (void)doStopButtonPressed {
    [self deleteProperties:@[@"startTime"]
                   success:^{
        NSLog(@"delete successs");
    } fail:^(AgoraExtAppError * _Nonnull error) {
        NSLog(@"delete fail");
    }];
}

- (void)doCloseButtonPressed {
    [self unload];
}

#pragma mark - Timer
- (void)startTimer {
    [self stopTimer];
    
    self.countDownLabel.text = [NSString stringWithFormat:@"%ld", (long)self.countDown];
    
    __weak CountDownExtApp *weakSelf = self;
    
    self.timer = [NSTimer timerWithTimeInterval:1.0
                                        repeats:YES
                                          block:^(NSTimer * _Nonnull timer) {
        weakSelf.countDown -= 1;
        
        weakSelf.countDownLabel.text = [NSString stringWithFormat:@"%ld", (long)weakSelf.countDown];
        
        if (weakSelf.countDown <= 0) {
            [weakSelf stopTimer];
        }
    }];
    
    [[NSRunLoop mainRunLoop] addTimer:self.timer forMode:NSRunLoopCommonModes];
    
    [self.timer fire];
}

- (void)stopTimer {
    [self.timer invalidate];
    self.timer = nil;
}

- (void)dealloc {
    [self.timer invalidate];
    self.timer = nil;
}
@end
