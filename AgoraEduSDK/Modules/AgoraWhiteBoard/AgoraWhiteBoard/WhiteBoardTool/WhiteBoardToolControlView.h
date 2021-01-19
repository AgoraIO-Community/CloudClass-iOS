//
//  WhiteBoardToolControlView.h
//  AgoraWhiteBoard
//
//  Created by SRS on 2020/7/14.
//  Copyright © 2020 agora. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

typedef NS_ENUM(NSInteger, WihteBoardToolDirectionType) {
    WihteBoardToolDirectionTypePortrait,
    WihteBoardToolDirectionTypeLandscape,
};

typedef NS_ENUM(NSInteger, WihteBoardToolStyle) {
    WihteBoardToolStyleDark,
    WihteBoardToolStyleWhite,
};

typedef NS_ENUM(NSInteger, WihteBoardToolType) {
    WihteBoardToolTypeSelector  = 0,
    WihteBoardToolTyperPencil,
    WihteBoardToolTyperText,
    WihteBoardToolTyperEraser,
    WihteBoardToolTyperColor,
};

@protocol WihteBoardToolControlDelegate <NSObject>
- (void)onSelectToolType:(WihteBoardToolType)type;
@end

@interface WhiteBoardToolControlView : UIView

@property (nonatomic, weak) id <WihteBoardToolControlDelegate> delegate;

// default Portrait
- (void)setToolDirection: (WihteBoardToolDirectionType)directionType;

// dfault WihteBoardToolStyleDark
- (void)setToolStyle: (WihteBoardToolStyle)style;

@end

NS_ASSUME_NONNULL_END
