//
//  AgoraBoardWidgetModel.swift
//  AgoraWidgets
//
//  Created by LYY on 2021/12/6.
//

import Foundation

enum AgoraBoardWidgetToolType: Int, Codable {
    case Selector
    case Text
    case Rectangle
    case Ellipse
    case Eraser
    case Color
    case Pencil
    case Arrow
    case Straight
    case Pointer
    case Clicker
}

enum AgoraBoardWidgetRoomPhase: Int, Codable {
    case Connecting
    case Connected
    case Reconnecting
    case Disconnecting
    case Disconnected
};


struct AgoraBoardWidgetMemberState: Codable {
    // 被激活教具
    var activeApplianceType: AgoraBoardWidgetToolType? = nil
    // 颜色
    var strokeColor: Int? = nil
    // 线条宽度
    var strokeWidth: Int? = nil
    // 文字大小
    var textSize: Int? = nil
}

struct AgoraBoardWidgetGrantData: Codable {
    // 是否授权
    var granted: Bool
    // 被改变权限的学生uuid集合
    var userUuids: [String]
}

struct AgoraBoardWidgetAudioMixingData: Codable {
    var statusCode: Int
    var errorCode: Int
}


enum AgoraBoardWidgetMessage: Codable {
    case PreJoin
    case BoardPhaseChanged(AgoraBoardWidgetRoomPhase)
    case MemberStateChanged(AgoraBoardWidgetMemberState)
    case AudioMixingStateChanged(AgoraBoardWidgetAudioMixingData)
    case BoardGrantDataChanged(AgoraBoardWidgetGrantData)
    
    var rawValue: Int {
        switch self {
        case .PreJoin:                          return 0
        case .BoardPhaseChanged(let _):         return 1
        case .MemberStateChanged(let _):        return 2
        case .AudioMixingStateChanged(let _):   return 3
        case .BoardGrantDataChanged(let _):     return 4
        }
    }
    
    init(from decoder: Decoder) throws {
        let container = try decoder.singleValueContainer()
        
        if let x = try? container.decode(AgoraBoardWidgetRoomPhase.self) {
            self = .BoardPhaseChanged(x)
            return
        }
        
        if let x = try? container.decode(AgoraBoardWidgetMemberState.self) {
            self = .MemberStateChanged(x)
            return
        }
        
        if let x = try? container.decode(AgoraBoardWidgetAudioMixingData.self) {
            self = .AudioMixingStateChanged(x)
            return
        }
        
        if let x = try? container.decode(AgoraBoardWidgetGrantData.self) {
            self = .BoardGrantDataChanged(x)
            return
        }
        
        self = .PreJoin
    }
    
    func encode(to encoder: Encoder) throws {
        var container = try encoder.singleValueContainer()
        switch self {
        case .PreJoin:
            break
        case .BoardPhaseChanged(let agoraWhiteboardRoomPhase):
            try container.encode(agoraWhiteboardRoomPhase)
        case .MemberStateChanged(let agoraWhiteboardMemberState):
            try container.encode(agoraWhiteboardMemberState)
        case .AudioMixingStateChanged(let agoraBoardAudioMixingData):
            try container.encode(agoraBoardAudioMixingData)
        case .BoardGrantDataChanged(let agoraBoardGrantData):
            try container.encode(agoraBoardGrantData)
        }
    }
}
