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

typedef NS_ENUM(NSInteger, WhiteBoardToolType) {
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
};

NS_ASSUME_NONNULL_END
