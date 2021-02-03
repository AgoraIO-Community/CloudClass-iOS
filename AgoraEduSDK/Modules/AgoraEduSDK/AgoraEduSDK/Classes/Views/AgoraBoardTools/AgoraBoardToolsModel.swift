//
//  AgoraBoardToolsModel.swift
//  AgoraEduSDK
//
//  Created by Cavan on 2021/2/3.
//

import UIKit

// MARK: - AgoraBoardToolsItem
@objc public enum AgoraBoardToolsItemType: Int {
    case move = 0, pencil, text, rectangle, circle, eraser
    
    var image: UIImage {
        switch self {
        case .move:      return AgoraImgae(name: "箭头")
        case .pencil:    return AgoraImgae(name: "笔")
        case .text:      return AgoraImgae(name: "文本")
        case .rectangle: return AgoraImgae(name: "矩形工具")
        case .circle:    return AgoraImgae(name: "圆形工具")
        case .eraser:    return AgoraImgae(name: "橡皮")
        }
    }
    
    var selectedImage: UIImage {
        switch self {
        case .move:      return AgoraImgae(name: "箭头-1")
        case .pencil:    return AgoraImgae(name: "笔-1")
        case .text:      return AgoraImgae(name: "文本-1")
        case .rectangle: return AgoraImgae(name: "矩形工具-1")
        case .circle:    return AgoraImgae(name: "圆形工具")
        case .eraser:    return AgoraImgae(name: "橡皮-1")
        }
    }
}

@objc enum AgoraBoardToolsColor: Int {
    case blue, yellow, red, green, black, white
    
    var value: UIColor {
        switch self {
        case .blue:   return .blue
        case .yellow: return .yellow
        case .red:    return .red
        case .green:  return .green
        case .black:  return .black
        case .white:  return .white
        }
    }
}

enum AgoraBoardToolsLineWidth {
    case width1, width2, width3, width4
    
    var value: Int {
        switch self {
        case .width1: return 1
        case .width2: return 2
        case .width3: return 3
        case .width4: return 4
        }
    }
}

enum AgoraBoardToolsPencilType {
    case pencil1, pencil2, pencil3, pencil4
    
    var value: Int {
        switch self {
        case .pencil1: return 1
        case .pencil2: return 2
        case .pencil3: return 3
        case .pencil4: return 4
        }
    }
}

enum AgoraBoardToolsFont {
    case font22, font24, font26, font30, font36, font42, font60, font72
    
    var value: Int {
        switch self {
        case .font22: return 22
        case .font24: return 24
        case .font26: return 26
        case .font30: return 30
        case .font36: return 36
        case .font42: return 42
        case .font60: return 60
        case .font72: return 72
        }
    }
}
