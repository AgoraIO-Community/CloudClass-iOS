//
//  AgoraBaseExtApp.m
//  AgoraExtApp
//
//  Created by Cavan on 2021/4/8.
//

#import "AgoraBaseExtApp.h"
#import <AgoraExtApp/AgoraExtApp-Swift.h>

@interface AgoraBaseExtApp ()<AgoraBaseExtAppUIViewDelegate>
@property (nonatomic, strong) AgoraBaseUIView *view;
@property (nonatomic, copy) NSString *appIdentifier;
@end

@implementation AgoraBaseExtApp
- (instancetype)initWithAppIdentifier:(NSString *)appIdentifier
                        localUserInfo:(AgoraExtAppUserInfo *)userInfo
                             roomInfo:(AgoraExtAppRoomInfo *)roomInfo
                           properties:(NSDictionary *)properties {
    self = [super init];
    
    if (self) {
        self.appIdentifier = appIdentifier;
        self.localUserInfo = userInfo;
        self.roomInfo = roomInfo;
        self.properties = properties;
        
        AgoraBaseUIView *extView = [AgoraBaseExtAppUIViewWrapper createExtAppUIView];
        [AgoraBaseExtAppUIViewWrapper extDelegate:extView
                                         delegate:self];
        self.view = extView;
    }
    
    return self;
}

- (void)localUserInfoDidUpdate:(AgoraExtAppUserInfo *)userInfo {
    self.localUserInfo = userInfo;
}

- (void)roomInfoDidUpdate:(AgoraExtAppRoomInfo *)roomInfo {
    self.roomInfo = roomInfo;
}

- (void)propertiesDidUpdate:(NSDictionary *)properties {
    self.properties = properties;
}

- (void)updateProperties:(NSDictionary *)properties
                 success:(AgoraExtAppCompletion)success
                    fail:(AgoraExtAppErrorCompletion)fail {
    SEL func = @selector(extApp:updateProperties:success:fail:);
    
    if ([self.delegate respondsToSelector:func]) {
        [self.delegate extApp:self
             updateProperties:properties
                      success:success
                         fail:fail];
    }
}

- (void)deleteProperties:(NSArray <NSString *> *)keys
                 success:(AgoraExtAppCompletion)success
                    fail:(AgoraExtAppErrorCompletion)fail {
    SEL func = @selector(extApp:deleteProperties:success:fail:);
    
    if ([self.delegate respondsToSelector:func]) {
        [self.delegate extApp:self
             deleteProperties:keys
                      success:success
                         fail:fail];
    }
}

- (void)unload {
    SEL func = @selector(extAppWillUnload:);
    
    if ([self.delegate respondsToSelector:func]) {
        [self.delegate extAppWillUnload:self];
    }
}

#pragma mark - Life cycle
- (void)extAppDidLoad:(AgoraExtAppContext *)context {
    
}

- (void)extAppWillUnload {
    
}

- (void)extAppUIViewPanTransformed:(AgoraBaseUIView *)extView {
    UIView *v = extView.superview;
    if (v == nil) {
        return;
    }
    
    // 计算xy
    CGSize medSize = [self calculateMED];
    
    CGFloat fx = [AgoraBaseExtAppUIViewWrapper x:extView];
    CGFloat fy = [AgoraBaseExtAppUIViewWrapper y:extView];
    CGFloat x = extView.transform.tx + fx;
    CGFloat y = extView.transform.ty + fy;
    CGPoint point = CGPointMake(x / medSize.width, y / medSize.height);
    
    // 抛上层
    SEL func = @selector(extApp:syncAppPosition:);
    if ([self.delegate respondsToSelector:func]) {
        [self.delegate extApp:self syncAppPosition:point];
    }
}

// 远端移动
- (void)onExtAppUIViewPositionSync:(AgoraBaseUIView *)extView
                             point:(CGPoint)point {
    UIView *v = extView.superview;
    if (v == nil) {
        return;
    }
    
    // 计算xy
    CGSize medSize = [self calculateMED];
    CGPoint targetPoint = CGPointMake(point.x * medSize.width, point.y * medSize.height);

    // 更新位置
    CGFloat fx = [AgoraBaseExtAppUIViewWrapper x:extView];
    CGFloat fy = [AgoraBaseExtAppUIViewWrapper y:extView];

    extView.transform = CGAffineTransformMakeTranslation(targetPoint.x - fx,
                                                      targetPoint.y - fy);
}

// 最大有效移动范围（Maximum Effective Distance, MED）
// Extension App 在不超出教室布局的前提下，分别能够在 X 轴、Y 轴方向移动的最大距离
- (CGSize)calculateMED {

    UIView *v = self.view.superview;
    if (v == nil) {
        return CGSizeZero;
    }

    CGSize superSize = v.frame.size;
    CGSize size = self.view.frame.size;
    
    // MEDx = parent.width - self.width
    CGFloat width = superSize.width - size.width;
    
    // MEDy = parent.height - self.height
    CGFloat height = superSize.height - size.height;
    
    return CGSizeMake(width, height);
}


@end
