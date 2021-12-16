//
//  ChatTopView.h
//  AgoraEducation
//
//  Created by lixiaoming on 2021/6/21.
//

#import <UIKit/UIKit.h>
#import "CustomBadgeView.h"

NS_ASSUME_NONNULL_BEGIN

@protocol ChatTopViewDelegate <NSObject>

- (void)chatTopViewDidSelectedChanged:(NSUInteger)nSelected;
- (void)chatTopViewDidClickHide;

@end


@interface ChatTopView : UIView
@property (nonatomic,weak) id<ChatTopViewDelegate> delegate;
@property (nonatomic) BOOL isShowRedNotice;
@property (nonatomic) BOOL isShowAnnouncementRedNotice;
@property (nonatomic) NSInteger currentTab;
@property (nonatomic,strong) CustomBadgeView* badgeView;
@property (nonatomic,strong) CustomBadgeView* announcementbadgeView;

@property (nonatomic,strong) UIButton* chatButton;
@property (nonatomic,strong) UIButton* hideButton;

@property (nonatomic,strong) UIView* selLine;
@property (nonatomic,strong) UIButton* announcementButton;

@end

NS_ASSUME_NONNULL_END
