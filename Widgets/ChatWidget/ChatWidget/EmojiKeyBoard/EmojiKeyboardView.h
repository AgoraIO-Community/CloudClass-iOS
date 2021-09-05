//
//  EmojiKeyboardView.h
//  AgoraEducation
//
//  Created by lixiaoming on 2021/5/12.
//  Copyright © 2021 Agora. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef NS_ENUM(NSUInteger, EMEmotionType) {
    EMEmotionTypeEmoji = 0,
    EMEmotionTypePng,
    EMEmotionTypeGif,
    EMEmotionTypeDel,
};

@interface EMEmoticonModel : NSObject

@property (nonatomic, strong) NSString *eId;

@property (nonatomic, strong) NSString *name;

@property (nonatomic, strong) NSString *imgName;

//local name or remote url
@property (nonatomic, strong) NSString *original;

@property (nonatomic, readonly) EMEmotionType type;

- (instancetype)initWithType:(EMEmotionType)aType;

@end


@interface EMEmoticonCell : UICollectionViewCell

@property (nonatomic, strong) UIImageView *imgView;

@property (nonatomic, strong) UILabel *label;

@property (nonatomic, strong) EMEmoticonModel *model;

@end


@protocol EmojiKeyboardDelegate

- (void)emojiItemDidClicked:(NSString *) item;

- (void)emojiDidDelete;

@end


@interface EmojiKeyboardView : UIView

@property(nonatomic, weak) id<EmojiKeyboardDelegate> delegate;

@end
