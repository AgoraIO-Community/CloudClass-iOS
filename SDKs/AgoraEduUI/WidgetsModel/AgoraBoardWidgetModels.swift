//
//  AgoraBoardWidgetModel.swift
//  AFNetworking
//
//  Created by LYY on 2021/12/8.
//

import Foundation

enum AgoraBoardRoomPhase: Int,Convertable {
    case Connecting
    case Connected
    case Reconnecting
    case Disconnecting
    case Disconnected
};

enum AgoraBoardInteractionSignal: Convertable {
    case JoinBoard
    case BoardPhaseChanged(AgoraBoardRoomPhase)
    case MemberStateChanged(AgoraBoardMemberState)
    case AudioMixingStateChanged(AgoraBoardAudioMixingChangeData)
    case BoardGrantDataChanged(Array<String>)
    
    var rawValue: Int {
        switch self {
        case .JoinBoard:                          return 0
        case .BoardPhaseChanged(_):         return 1
        case .MemberStateChanged(_):        return 2
        case .AudioMixingStateChanged(_):   return 3
        case .BoardGrantDataChanged(_):     return 4
        }
    }
    
    static func getType(rawValue: Int) -> Convertable.Type? {
        switch rawValue {
        case 1: return AgoraBoardRoomPhase.self
        case 2: return AgoraBoardMemberState.self
        case 3: return AgoraBoardAudioMixingChangeData.self
        case 4: return Array<String>.self
            
        default:
            return nil
        }
    }
    
    static func makeSignal(rawValue: Int,
                           body: Convertable?) -> AgoraBoardInteractionSignal? {
        switch rawValue {
        case 0: return .JoinBoard
        case 1:
            if let x = body as? AgoraBoardRoomPhase {
                return .BoardPhaseChanged(x)
            }
        case 2:
            if let x = body as? AgoraBoardMemberState {
                return .MemberStateChanged(x)
            }
        case 3:
            if let x = body as? AgoraBoardAudioMixingChangeData {
                return .AudioMixingStateChanged(x)
            }
        case 4:
            if let x = body as? Array<String> {
                return .BoardGrantDataChanged(x)
            }
        default:
            break
        }
        return nil
    }
    
    init(from decoder: Decoder) throws {
        let container = try decoder.singleValueContainer()
        
        if let x = try? container.decode(AgoraBoardRoomPhase.self) {
            self = .BoardPhaseChanged(x)
            return
        }
        
        if let x = try? container.decode(AgoraBoardMemberState.self) {
            self = .MemberStateChanged(x)
            return
        }
        
        if let x = try? container.decode(AgoraBoardAudioMixingChangeData.self) {
            self = .AudioMixingStateChanged(x)
            return
        }
        
        if let x = try? container.decode(Array<String>.self) {
            self = .BoardGrantDataChanged(x)
            return
        }
        
        self = .JoinBoard
    }
    
    func encode(to encoder: Encoder) throws {
        var container = try encoder.singleValueContainer()
        switch self {
        case .JoinBoard:
            break
        case .BoardPhaseChanged(let AgoraBoardWidgetRoomPhase):
            try container.encode(AgoraBoardWidgetRoomPhase)
        case .MemberStateChanged(let AgoraBoardWidgetMemberState):
            try container.encode(AgoraBoardWidgetMemberState)
        case .AudioMixingStateChanged(let agoraBoardAudioMixingData):
            try container.encode(agoraBoardAudioMixingData)
        case .BoardGrantDataChanged(let agoraBoardGrantData):
            try container.encode(agoraBoardGrantData)
        }
    }
}

enum AgoraWihteBoardToolDirectionType {
   case Portrait
   case Landscape
};

enum AgoraWihteBoardToolStyle {
    case Dark
    case White
};

// TODO: for AgoraBoardWidgetManager
enum AgoraBoardWidgetToolType: Int,Convertable {
    case Selector
    case Text
    case Rectangle
    case Ellipse
    case Eraser
    case Pencil
    case Arrow
    case Straight
    case Pointer
    case Clicker
}

// MARK: - Message
// 当外部手动更新某一项数据的时候MemberState就只包含对应的某一项，然后通过sendMessageToWidget发送即可
// 若初始化时期，白板需要向外传
struct AgoraBoardMemberState: Convertable {
    // 被激活教具
    var activeApplianceType: AgoraBoardWidgetToolType?
    // 颜色
    var strokeColor: Array<Int>?
    // 线条宽度
    var strokeWidth: Int?
    // 文字大小
    var textSize: Int?
    
    init(activeApplianceType: AgoraBoardWidgetToolType?,
         strokeColor: Array<Int>?,
         strokeWidth: Int?,
         textSize: Int?) {
        self.activeApplianceType = activeApplianceType
        self.strokeColor = strokeColor
        self.strokeWidth = strokeWidth
        self.textSize = textSize
    }
}

struct AgoraBoardAudioMixingChangeData: Convertable {
    var statusCode: Int
    var errorCode: Int
}

struct AgoraBoardAudioMixingStartData: Convertable {
    var statusCode: Int
    var errorCode: Int
}
