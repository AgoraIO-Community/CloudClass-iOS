//
//  WhiteBoardToolControlView.h
//  AgoraWhiteBoard
//
//  Created by SRS on 2020/7/14.
//  Copyright © 2020 agora. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "WhiteBoardToolEnums.h"

NS_ASSUME_NONNULL_BEGIN

@protocol WihteBoardToolControlDelegate <NSObject>
- (void)onSelectToolType:(WhiteBoardToolType)type;
@end

@interface WhiteBoardToolControlView : UIView

@property (nonatomic, weak) id <WihteBoardToolControlDelegate> delegate;

// default Portrait
- (void)setToolDirection: (WihteBoardToolDirectionType)directionType;

// dfault WihteBoardToolStyleDark
- (void)setToolStyle: (WihteBoardToolStyle)style;

@end

NS_ASSUME_NONNULL_END
