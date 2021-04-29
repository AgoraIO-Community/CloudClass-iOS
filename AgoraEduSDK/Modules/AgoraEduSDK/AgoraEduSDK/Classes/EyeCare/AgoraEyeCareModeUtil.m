//
//  AgoraEyeCareModeUtil.m
//  AgoraEducation
//
//  Created by yangmoumou on 2019/9/23.
//  Copyright © 2019 Agora. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "AgoraEyeCareModeUtil.h"

static AgoraEyeCareModeUtil *eyeCareUtil = nil;
/// NSUserDefaults存的key
static NSString * const kAgoraEduEyeCareModeStatus = @"kAgoraEduEyeCareModeStatus";

@interface AgoraEyeCareModeUtil ()
@property (nonatomic, strong) UIView *maskView;
@end

@implementation AgoraEyeCareModeUtil
+ (instancetype)sharedUtil {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        eyeCareUtil = [[self alloc] init];
    });
    return eyeCareUtil;
}

+ (id)allocWithZone:(struct _NSZone *)zone {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        eyeCareUtil = [super allocWithZone:zone];
    });
    return eyeCareUtil;
}

- (nonnull id)copyWithZone:(nullable NSZone *)zone {
    return eyeCareUtil;
}

- (nonnull id)mutableCopyWithZone:(nullable NSZone *)zone {
    return eyeCareUtil;
}

- (BOOL)queryEyeCareModeStatus {
    return [[NSUserDefaults standardUserDefaults] boolForKey:kAgoraEduEyeCareModeStatus];
}

- (void)switchEyeCareMode:(BOOL)on {
    if (on) {
        self.maskView.hidden = NO;
    } else {
        self.maskView.hidden = YES;
    }
    
    [[NSUserDefaults standardUserDefaults] setBool:on
                                            forKey:kAgoraEduEyeCareModeStatus];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

- (UIView *)maskView {
    if (!_maskView) {
        UIWindow *window = [UIApplication sharedApplication].windows.firstObject;
        CGSize size = UIScreen.mainScreen.bounds.size;
        _maskView = [[UIView alloc] initWithFrame:CGRectMake(0,
                                                             0,
                                                             MAX(size.width, size.height),
                                                             MAX(size.width, size.height))];
        _maskView.backgroundColor = [UIColor colorWithRed:255 / 255.0
                                                    green:153 / 255.0
                                                     blue:0
                                                    alpha:0.1];
        _maskView.hidden = NO;
        _maskView.userInteractionEnabled = NO;
        [window addSubview:_maskView];
    }
    return _maskView;
}
@end
