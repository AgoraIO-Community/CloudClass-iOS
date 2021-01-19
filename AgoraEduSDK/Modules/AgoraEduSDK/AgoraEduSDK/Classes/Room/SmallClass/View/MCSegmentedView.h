//
//  MCSegmentedView.h
//  AgoraEducation
//
//  Created by yangmoumou on 2019/11/15.
//  Copyright © 2019 Agora. All rights reserved.
//

#import <UIKit/UIKit.h>
typedef NS_ENUM(NSInteger, SegmentType) {
    SegmentTypeMessage,
    SegmentTypeList,
};

typedef void(^SelectSegmentViewIndex)(NSInteger index);

NS_ASSUME_NONNULL_BEGIN

@interface MCSegmentedView : UIView
@property (nonatomic, assign) SegmentType segmentType;
@property (nonatomic, copy) SelectSegmentViewIndex selectIndex;
- (void)showBadgeWithCount:(NSInteger)count;
- (void)hiddeBadge;
@end

NS_ASSUME_NONNULL_END
