//
//  AgoraBoardWidgetModel.swift
//  AgoraEduUI
//
//  Created by DoubleCircle on 2021/12/9.
//

import Foundation
// MARK: - Config
enum AgoraBoardWidgetRoomPhase: Int,Convertable {
    case Connecting
    case Connected
    case Reconnecting
    case Disconnecting
    case Disconnected
};

enum AgoraBoardWidgetSignal {
    case JoinBoard
    case BoardPhaseChanged(AgoraBoardWidgetRoomPhase)
    case MemberStateChanged(AgoraBoardWidgetMemberState)
    case BoardGrantDataChanged(Array<String>?)
    case AudioMixingStateChanged(AgoraBoardWidgetAudioMixingChangeData)
    case BoardAudioMixingRequest(AgoraBoardWidgetAudioMixingRequestData)
    case BoardInit
    
    var rawValue: Int {
        switch self {
        case .JoinBoard:                    return 0
        case .BoardPhaseChanged(_):         return 1
        case .MemberStateChanged(_):        return 2
        case .BoardGrantDataChanged(_):     return 3
        case .AudioMixingStateChanged(_):   return 4
        case .BoardAudioMixingRequest(_):   return 5
        case .BoardInit:                     return 6
        }
    }
    
    static func getType(rawValue: Int) -> Convertable.Type? {
        switch rawValue {
        case 1: return AgoraBoardWidgetRoomPhase.self
        case 2: return AgoraBoardWidgetMemberState.self
        case 3: return Array<String>.self
        case 4: return AgoraBoardWidgetAudioMixingChangeData.self
        case 5: return AgoraBoardWidgetAudioMixingRequestData.self
        default:
            return nil
        }
    }
    
    static func makeSignal(rawValue: Int,
                           body: Convertable?) -> AgoraBoardWidgetSignal? {
        switch rawValue {
        case 0:
            return .JoinBoard
        case 1:
            if let x = body as? AgoraBoardWidgetRoomPhase {
                return .BoardPhaseChanged(x)
            }
        case 2:
            if let x = body as? AgoraBoardWidgetMemberState {
                return .MemberStateChanged(x)
            }
        case 3:
            if let x = body as? Array<String> {
                return .BoardGrantDataChanged(x)
            }
        case 4:
            if let x = body as? AgoraBoardWidgetAudioMixingChangeData {
                return .AudioMixingStateChanged(x)
            }
        case 5:
            if let x = body as? AgoraBoardWidgetAudioMixingRequestData {
                return .BoardAudioMixingRequest(x)
            }
        case 6:
            return .BoardInit
        default:
            break
        }
        return nil
    }
}

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
struct AgoraBoardWidgetMemberState: Convertable {
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

struct AgoraBoardWidgetAudioMixingChangeData: Convertable {
    var statusCode: Int
    var errorCode: Int
}

enum AgoraBoardWidgetAudioMixingRequestType: Int,Convertable {
    case start,stop,setPosition
}

struct AgoraBoardWidgetAudioMixingRequestData: Convertable {
    var requestType: AgoraBoardWidgetAudioMixingRequestType
    var filePath: String
    var loopback: Bool
    var replace: Bool
    var cycle: Int
    var position: Int
    
    init(requestType: AgoraBoardWidgetAudioMixingRequestType,
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


// MARK: - extension
extension AgoraBoardWidgetSignal {
    func toMessageString() -> String? {
        var dic = [String: Any]()
        dic["signal"] = self.rawValue
        switch self {
        case .MemberStateChanged(let boardMemberState) :
            dic["body"] = boardMemberState.toDictionary()
        case .BoardGrantDataChanged(let list):
            dic["body"] = list
        case .AudioMixingStateChanged(let boardAudioMixingChangeData) :
            dic["body"] = boardAudioMixingChangeData
        case .BoardGrantDataChanged(let boardGrantData) :
            dic["body"] = boardGrantData
        default:
            break
        }
        return dic.jsonString()
    }
}

extension String {
    func toSignal() -> AgoraBoardWidgetSignal? {
        guard let dic = self.json(),
              let signalRaw = dic["signal"] as? Int else {
            return nil
        }
        if signalRaw == AgoraBoardWidgetSignal.JoinBoard.rawValue {
            return .JoinBoard
        }
        
        guard let bodyDic = dic["body"] as? [String:Any],
              let type = AgoraBoardWidgetSignal.getType(rawValue: signalRaw),
              let obj = try type.decode(bodyDic) else {
            return nil
        }
        return AgoraBoardWidgetSignal.makeSignal(rawValue: signalRaw,
                                                      body: obj)
    }
}
