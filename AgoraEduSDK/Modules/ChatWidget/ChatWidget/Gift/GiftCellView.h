//
//  GiftCellView.h
//  AgoraEducation
//
//  Created by lixiaoming on 2021/5/18.
//  Copyright © 2021 Agora. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN
@class GiftCellView;

typedef NS_ENUM(NSUInteger, GiftType) {
    GiftTypeFlower = 0,
    GiftTypeHeart,
    GiftTypeDrumsticks,
    GifttypeCola,
    GiftTypeSuger,
    GiftTypeBackBlood,
    GiftTypeRocket,
};

@protocol GiftCellViewDelegate <NSObject>

- (void)giftDidSelected:(GiftCellView*)giftView;
- (void)sendGift:(GiftCellView*)giftView;

@end

@interface GiftCellView : UIView

+ (NSArray<NSString*>*)giftDescriptions;
+ (NSArray<NSNumber*>*)giftCredits;
+ (NSArray<NSString*>*)giftNames;
+ (NSArray<NSString*>*)giftUrls;

- (instancetype)initWithFrame:(CGRect)frame type:(GiftType)giftType;
- (void)setGiftSelected:(BOOL)aIsSelected;
// 礼物类型
@property (nonatomic) GiftType giftType;
// 学分
@property (nonatomic) NSUInteger credit;
@property (nonatomic,weak) id<GiftCellViewDelegate> delegate;
@end

NS_ASSUME_NONNULL_END
