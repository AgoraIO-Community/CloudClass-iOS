//
//  AgoraBoardToolsModel.swift
//  AgoraEduSDK
//
//  Created by Cavan on 2021/2/3.
//

import UIKit

// MARK: - AgoraBoardToolsItem
@objc public enum AgoraBoardToolsItemType: Int {
    case clicker = 0, select, pencil, text, eraser, color
}

@objc public enum AgoraBoardToolsColor: Int, CaseIterable {
    case white, lightGray, darkGray, black
    case red, orange, yellow, green
    case purple, cyan, blue, pink
    
    public var intValue: Int {
        switch self {
        case .white:     return 0xFFFFFF
        case .lightGray: return 0x9B9B9B
        case .darkGray:  return 0x4A4A4A
        case .black:     return 0x000000
            
        case .red:       return 0xD0021B
        case .orange:    return 0xF5A623
        case .yellow:    return 0xF8E71C
        case .green:     return 0x7ED321
        
        case .purple:    return 0x9013FE
        case .cyan:      return 0x50E3C2
        case .blue:      return 0x0073FF
        case .pink:      return 0xFFC8E2
        }
    }
    
    public var intString: String {
        let string = NSString(format: "%06x", intValue) as String
        return string
    }
    
    public var value: UIColor? {
        return UIColor(hex: intValue)
    }
}

@objc public enum AgoraBoardToolsLineWidth: Int, CaseIterable {
    case width1 = 1, width2, width3, width4, width5
    
    public var value: Int {
        switch self {
        case .width1: return 4
        case .width2: return 8
        case .width3: return 12
        case .width4: return 18
        case .width5: return 22
        }
    }
    
    public static func fromValue(_ value: Int?) -> AgoraBoardToolsLineWidth {
        guard let v = value else {
            return .width1
        }
        switch v {
        case 4: return .width1
        case 8: return .width2
        case 12: return .width3
        case 18: return .width4
        case 22: return .width5
        default:
            return .width1
        }
    }
}

@objc public enum AgoraBoardToolsPencilType: Int {
    case pencil, rectangle, circle, line
}

@objc public enum AgoraBoardToolsFont: Int, CaseIterable {
    case font22, font24, font26, font30, font36, font42
    
    public var value: Int {
        switch self {
        case .font22: return 22
        case .font24: return 24
        case .font26: return 26
        case .font30: return 30
        case .font36: return 36
        case .font42: return 42
        }
    }
    
    public static func fromValue(_ value: Int?) -> AgoraBoardToolsFont {
        guard let v = value else {
            return .font22
        }
        switch v {
        case 22: return .font22
        case 24: return .font24
        case 26: return .font26
        case 30: return .font30
        case 36: return .font36
        case 42: return .font42
        default:
            return .font22
        }
    }
}
