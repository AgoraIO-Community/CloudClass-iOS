//  代码地址: https://github.com/CoderMJLee/AgoraRefresh
#import <UIKit/UIKit.h>
#import <objc/message.h>

// 弱引用
#define MJWeakSelf __weak typeof(self) weakSelf = self;

// 日志输出
#ifdef DEBUG
#define AgoraRefreshLog(...) NSLog(__VA_ARGS__)
#else
#define AgoraRefreshLog(...)
#endif

// 过期提醒
#define AgoraRefreshDeprecated(DESCRIPTION) __attribute__((deprecated(DESCRIPTION)))

// 运行时objc_msgSend
#define AgoraRefreshMsgSend(...) ((void (*)(void *, SEL, UIView *))objc_msgSend)(__VA_ARGS__)
#define AgoraRefreshMsgTarget(target) (__bridge void *)(target)

// RGB颜色
#define AgoraRefreshColor(r, g, b) [UIColor colorWithRed:(r)/255.0 green:(g)/255.0 blue:(b)/255.0 alpha:1.0]

// 文字颜色
#define AgoraRefreshLabelTextColor AgoraRefreshColor(90, 90, 90)

// 字体大小
#define AgoraRefreshLabelFont [UIFont boldSystemFontOfSize:14]

// 常量
UIKIT_EXTERN const CGFloat AgoraRefreshLabelLeftInset;
UIKIT_EXTERN const CGFloat AgoraRefreshHeaderHeight;
UIKIT_EXTERN const CGFloat AgoraRefreshFooterHeight;
UIKIT_EXTERN const CGFloat AgoraRefreshTrailWidth;
UIKIT_EXTERN const CGFloat AgoraRefreshFastAnimationDuration;
UIKIT_EXTERN const CGFloat AgoraRefreshSlowAnimationDuration;

UIKIT_EXTERN NSString *const AgoraRefreshKeyPathContentOffset;
UIKIT_EXTERN NSString *const AgoraRefreshKeyPathContentSize;
UIKIT_EXTERN NSString *const AgoraRefreshKeyPathContentInset;
UIKIT_EXTERN NSString *const AgoraRefreshKeyPathPanState;

UIKIT_EXTERN NSString *const AgoraRefreshHeaderLastUpdatedTimeKey;

UIKIT_EXTERN NSString *const AgoraRefreshHeaderIdleText;
UIKIT_EXTERN NSString *const AgoraRefreshHeaderPullingText;
UIKIT_EXTERN NSString *const AgoraRefreshHeaderRefreshingText;

UIKIT_EXTERN NSString *const AgoraRefreshTrailerIdleText;
UIKIT_EXTERN NSString *const AgoraRefreshTrailerPullingText;

UIKIT_EXTERN NSString *const AgoraRefreshAutoFooterIdleText;
UIKIT_EXTERN NSString *const AgoraRefreshAutoFooterRefreshingText;
UIKIT_EXTERN NSString *const AgoraRefreshAutoFooterNoMoreDataText;

UIKIT_EXTERN NSString *const AgoraRefreshBackFooterIdleText;
UIKIT_EXTERN NSString *const AgoraRefreshBackFooterPullingText;
UIKIT_EXTERN NSString *const AgoraRefreshBackFooterRefreshingText;
UIKIT_EXTERN NSString *const AgoraRefreshBackFooterNoMoreDataText;

UIKIT_EXTERN NSString *const AgoraRefreshHeaderLastTimeText;
UIKIT_EXTERN NSString *const AgoraRefreshHeaderDateTodayText;
UIKIT_EXTERN NSString *const AgoraRefreshHeaderNoneLastDateText;

// 状态检查
#define AgoraRefreshCheckState \
AgoraRefreshState oldState = self.state; \
if (state == oldState) return; \
[super setState:state];

// 异步主线程执行，不强持有Self
#define AgoraRefreshDispatchAsyncOnMainQueue(x) \
__weak typeof(self) weakSelf = self; \
dispatch_async(dispatch_get_main_queue(), ^{ \
typeof(weakSelf) self = weakSelf; \
{x} \
});
