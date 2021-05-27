//
//  WhiteBoardToolEnums.h
//  AgoraWhiteBoard
//
//  Created by Cavan on 2021/2/3.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

typedef NS_ENUM(NSInteger, AgoraWihteBoardToolDirectionType) {
    WihteBoardToolDirectionTypePortrait,
    WihteBoardToolDirectionTypeLandscape,
};

typedef NS_ENUM(NSInteger, AgoraWihteBoardToolStyle) {
    WihteBoardToolStyleDark,
    WihteBoardToolStyleWhite,
};

typedef NS_ENUM(NSInteger, AgoraWhiteBoardToolType) {
    WhiteBoardToolTypeSelector  = 0,
    WhiteBoardToolTypeText,
    WhiteBoardToolTypeRectangle,
    WhiteBoardToolTypeEllipse,
    WhiteBoardToolTypeEraser,
    WhiteBoardToolTypeColor,
    
    WhiteBoardToolTypePencil,
    WhiteBoardToolTypeArrow,
    WhiteBoardToolTypeStraight,
    WhiteBoardToolTypePointer,
    WhiteBoardToolTypeClicker
};

NS_ASSUME_NONNULL_END
