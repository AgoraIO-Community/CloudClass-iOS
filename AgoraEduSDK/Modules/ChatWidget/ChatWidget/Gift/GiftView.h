//
//  GiftView.h
//  AgoraEducation
//
//  Created by lixiaoming on 2021/5/18.
//  Copyright © 2021 Agora. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "GiftCellView.h"

NS_ASSUME_NONNULL_BEGIN

@protocol GiftViewDelegate <NSObject>

- (void)sendGift:(GiftCellView*)giftView;

@end

@interface GiftView : UIView
@property (nonatomic,weak) id<GiftViewDelegate> delegate;
@end

NS_ASSUME_NONNULL_END
