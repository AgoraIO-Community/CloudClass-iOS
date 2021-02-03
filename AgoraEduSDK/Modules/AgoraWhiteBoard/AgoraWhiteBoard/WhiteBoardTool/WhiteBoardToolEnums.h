//
//  WhiteBoardToolEnums.h
//  AgoraWhiteBoard
//
//  Created by Cavan on 2021/2/3.
//

#import <Foundation/Foundation.h>

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

NS_ASSUME_NONNULL_END
