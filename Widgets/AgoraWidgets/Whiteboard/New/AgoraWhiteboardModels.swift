//
//  AgoraBoardModels.swift
//  AgoraWidgets
//
//  Created by DoubleCircle on 2021/12/3.
//

import Foundation

/// 对应AgoraBoardWidgetModel
// MARK: - Config
enum AgoraBoardRoomPhase: Int,Convertable {
    case Connecting
    case Connected
    case Reconnecting
    case Disconnecting
    case Disconnected
};

enum AgoraBoardInteractionSignal {
    case JoinBoard
    case BoardPhaseChanged(AgoraBoardRoomPhase)
    case MemberStateChanged(AgoraBoardMemberState)
    case BoardGrantDataChanged(Array<String>?)
    case AudioMixingStateChanged(AgoraBoardAudioMixingData)
    case BoardAudioMixingRequest(AgoraBoardAudioMixingRequestData)
    
    var rawValue: Int {
        switch self {
        case .JoinBoard:                             return 0
        case .BoardPhaseChanged(_):                  return 1
        case .MemberStateChanged(_):                 return 2
        case .BoardGrantDataChanged(_):              return 3
        case .AudioMixingStateChanged(_):            return 4
        case .BoardAudioMixingRequest(_):            return 5
        default:
            return -1
        }
    }
    
    static func getType(rawValue: Int) -> Convertable.Type? {
        switch rawValue {
        case 1: return AgoraBoardRoomPhase.self
        case 2: return AgoraBoardMemberState.self
        case 3: return Array<String>.self
        case 4: return AgoraBoardAudioMixingData.self
        case 5: return AgoraBoardAudioMixingRequestData.self
            
        default:
            return nil
        }
    }
    
    static func makeSignal(rawValue: Int,
                           body: Convertable?) -> AgoraBoardInteractionSignal? {
        switch rawValue {
        case 0:
            return .JoinBoard
        case 1:
            if let x = body as? AgoraBoardRoomPhase {
                return .BoardPhaseChanged(x)
            }
        case 2:
            if let x = body as? AgoraBoardMemberState {
                return .MemberStateChanged(x)
            }
        case 3:
            if let x = body as? Array<String> {
                return .BoardGrantDataChanged(x)
            }
        case 4:
            if let x = body as? AgoraBoardAudioMixingData {
                return .AudioMixingStateChanged(x)
            }
        case 5:
            if let x = body as? AgoraBoardAudioMixingRequestData {
                return .BoardAudioMixingRequest(x)
            }
        default:
            break
        }
        return nil
    }
}

enum AgoraBoardToolType: Int,Convertable {
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
    var activeApplianceType: AgoraBoardToolType?
    // 颜色
    var strokeColor: Array<Int>?
    // 线条宽度
    var strokeWidth: Int?
    // 文字大小
    var textSize: Int?
    
    init(activeApplianceType: AgoraBoardToolType?,
         strokeColor: Array<Int>?,
         strokeWidth: Int?,
         textSize: Int?) {
        self.activeApplianceType = activeApplianceType
        self.strokeColor = strokeColor
        self.strokeWidth = strokeWidth
        self.textSize = textSize
    }
}

struct AgoraBoardAudioMixingData: Convertable {
    var statusCode: Int
    var errorCode: Int
}

enum AgoraBoardAudioMixingRequestType: Int,Convertable {
    case start,stop,setPosition
}

struct AgoraBoardAudioMixingRequestData: Convertable {
    var requestType: AgoraBoardAudioMixingRequestType
    var filePath: String
    var loopback: Bool
    var replace: Bool
    var cycle: Int
    var position: Int
    
    init(requestType: AgoraBoardAudioMixingRequestType,
         filePath: String = "",
         loopback: Bool = true,
         replace: Bool = true,
         cycle: Int = 0,
         position: Int = 0) {
        self.requestType = requestType
        self.filePath = filePath
        self.loopback = loopback
        self.replace = replace
        self.cycle = cycle
        self.position = position
    }
}
