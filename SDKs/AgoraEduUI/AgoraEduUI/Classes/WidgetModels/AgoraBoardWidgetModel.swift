//
//  AgoraBoardWidgetModel.swift
//  AgoraEduUI
//
//  Created by DoubleCircle on 2021/12/9.
//

import Foundation

let kBoardWidgetId = "netlessBoard"
// MARK: - Config
enum AgoraBoardWidgetSignal {
    case JoinBoard
    case BoardPhaseChanged(AgoraBoardWidgetRoomPhase)
    case MemberStateChanged(AgoraBoardWidgetMemberState)
    case BoardGrantDataChanged(Array<String>?)
    case AudioMixingStateChanged(AgoraBoardWidgetAudioMixingChangeData)
    case BoardAudioMixingRequest(AgoraBoardWidgetAudioMixingRequestData)
    case BoardPageChanged(AgoraBoardWidgetPageChangeType)
    case BoardStepChanged(AgoraBoardWidgetStepChangeType)
    case ClearBoard
    case OpenCourseware(AgoraBoardWidgetCoursewareInfo)
    case WindowStateChanged(AgoraBoardWidgetWindowState)
    
    var rawValue: Int {
        switch self {
        case .JoinBoard:                    return 0
        case .BoardPhaseChanged(_):         return 1
        case .MemberStateChanged(_):        return 2
        case .BoardGrantDataChanged(_):     return 3
        case .AudioMixingStateChanged(_):   return 4
        case .BoardAudioMixingRequest(_):   return 5
        case .BoardPageChanged:             return 6
        case .BoardStepChanged:             return 7
        case .ClearBoard:                   return 8
        case .OpenCourseware:               return 9
        case .WindowStateChanged(_):                 return 10
        }
    }
    
    static func getType(rawValue: Int) -> Convertable.Type? {
        switch rawValue {
        case 1:  return AgoraBoardWidgetRoomPhase.self
        case 2:  return AgoraBoardWidgetMemberState.self
        case 3:  return Array<String>.self
        case 4:  return AgoraBoardWidgetAudioMixingChangeData.self
        case 5:  return AgoraBoardWidgetAudioMixingRequestData.self
        case 6:  return AgoraBoardWidgetPageChangeType.self
        case 7:  return AgoraBoardWidgetStepChangeType.self
        case 9:  return AgoraBoardWidgetCoursewareInfo.self
        case 10: return AgoraBoardWidgetWindowState.self
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
            if let x = body as? AgoraBoardWidgetPageChangeType {
                return .BoardPageChanged(x)
            }
        case 7:
            if let x = body as? AgoraBoardWidgetStepChangeType {
                return .BoardStepChanged(x)
            }
        case 8:
            return .ClearBoard
        case 9:
            if let x = body as? AgoraBoardWidgetCoursewareInfo {
                return .OpenCourseware(x)
            }
        case 10:
            if let x = body as? AgoraBoardWidgetWindowState {
                return .WindowStateChanged(x)
            }
        default:
            break
        }
        return nil
    }
}

enum AgoraBoardWidgetRoomPhase: Int,Convertable {
    case Connecting
    case Connected
    case Reconnecting
    case Disconnecting
    case Disconnected
};

enum AgoraBoardWidgetToolType: Int,Convertable {
    case Selector, Text, Rectangle, Ellipse, Eraser, Pencil, Arrow, Straight, Pointer, Clicker, Shape
    
    func toMainType() -> AgoraBoardToolMainType? {
        switch self {
        case .Clicker:      return .clicker
        case .Text:         return .text
        case .Eraser:       return .rubber
        case .Rectangle:    fallthrough
        case .Ellipse:      fallthrough
        case .Pencil:       fallthrough
        case .Arrow:        fallthrough
        case .Straight:     fallthrough
        case .Shape:        return .paint
        default:            return nil
        }
    }
    
    func toPaintType() -> AgoraBoardToolPaintType? {
        switch self {
        case .Pencil:   return .pencil
        case .Arrow:    return .arrow
        case .Straight: return .line
        default:        return nil
        }
    }
}

enum AgoraBoardWidgetShapeType: Int,Convertable {
    case Triangle, Rhombus, Pentagram, Ballon
    
    func toPaintType() -> AgoraBoardToolPaintType? {
        switch self {
        case .Triangle:     return .triangle
        case .Rhombus:      return .rhombus
        case .Pentagram:    return .pentagram
        default:            return nil
        }
    }
}

enum AgoraBoardWidgetWindowState: Int, Convertable {
    case min, max, normal
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
    // 图形
    var shapeType: AgoraBoardWidgetShapeType?
    
    init(activeApplianceType: AgoraBoardWidgetToolType? = nil,
         strokeColor: Array<Int>? = nil,
         strokeWidth: Int? = nil,
         textSize: Int? = nil,
         shapeType: AgoraBoardWidgetShapeType? = nil) {
        self.activeApplianceType = activeApplianceType
        self.strokeColor = strokeColor
        self.strokeWidth = strokeWidth
        self.textSize = textSize
        self.shapeType = shapeType
    }
}

struct AgoraBoardWidgetAudioMixingChangeData: Convertable {
    var stateCode: Int
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
            dic["body"] = boardAudioMixingChangeData.toDictionary()
        case .BoardPageChanged(let page):
            dic["body"] = page.toDictionary()
        case .BoardStepChanged(let changeType):
            dic["body"] = changeType.toDictionary()
        case .OpenCourseware(let coursewareInfo):
            dic["body"] = coursewareInfo.toDictionary()
        case .WindowStateChanged(let state):
            dic["body"] = state.rawValue
        default:
            break
        }
    return dic.jsonString()
    }
}

extension String {
    func toBoardSignal() -> AgoraBoardWidgetSignal? {
        guard let dic = self.json(),
              let signalRaw = dic["signal"] as? Int else {
            return nil
        }
        if signalRaw == AgoraBoardWidgetSignal.JoinBoard.rawValue {
            return .JoinBoard
        }
        
        if signalRaw == AgoraBoardWidgetSignal.ClearBoard.rawValue {
            return .ClearBoard
        }
        
        if let bodyArr = dic["body"] as? [String] {
            return .BoardGrantDataChanged(bodyArr)
        }
        
        if let bodyInt = dic["body"] as? Int,
           let type = AgoraBoardWidgetSignal.getType(rawValue: signalRaw) {

            if type == AgoraBoardWidgetWindowState.self,
            let changeType = AgoraBoardWidgetWindowState(rawValue: bodyInt) {
                return .WindowStateChanged(changeType)
            }
        }
        
        if let bodyDic = dic["body"] as? [String:Any],
              let type = AgoraBoardWidgetSignal.getType(rawValue: signalRaw),
              let obj = try type.decode(bodyDic) {
            return AgoraBoardWidgetSignal.makeSignal(rawValue: signalRaw,
                                                          body: obj)
        }
        
        return nil
    }
}

// page handle
struct AgoraBoardWidgetPageInfo: Convertable {
    var index: Int
    var count: Int
}

enum AgoraBoardWidgetPageChangeType: Convertable {
    case index(Int)
    case count(Int)
    
    private enum CodingKeys: CodingKey {
        case index
        case count
    }
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        
        if let type1Value = try? container.decode(Int.self, forKey: .index) {
            self = .index(type1Value)
        }
        else{
            let type2Value = try container.decode(Int.self, forKey: .count)
            self = .count(type2Value)
        }
        
    }
    
    func encode(to encoder: Encoder) throws {
        
        var container = encoder.container(keyedBy: CodingKeys.self)
        switch self {
        case .index(let value):
            try container.encode(value, forKey: .index)
        case .count(let value):
            try container.encode(value, forKey: .count)
        }
    }
}

// step
enum AgoraBoardWidgetStepChangeType: Convertable {
    case pre(Int)
    case next(Int)
    case undoCount(Int)
    case redoCount(Int)
    
    var rawValue: Int {
        get {
            switch self {
            case .pre(let _):         return 0
            case .next(let _):        return 1
            case .undoCount(let _):   return 2
            case .redoCount(let _):   return 3
            }
        }
    }
    
    private enum CodingKeys: CodingKey {
        case pre
        case next
        case undoCount
        case redoCount
    }
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        if let x = try? container.decodeIfPresent(Int.self,
                                                  forKey: .pre) {
            self = .pre(x)
        }
        if let x = try? container.decodeIfPresent(Int.self,
                                                  forKey: .next) {
            self = .next(x)
        }
        if let x = try? container.decodeIfPresent(Int.self,
                                                  forKey: .undoCount) {
            self = .undoCount(x)
        }
        if let x = try? container.decodeIfPresent(Int.self,
                                                  forKey: .redoCount) {
            self = .redoCount(x)
        }
        throw DecodingError.typeMismatch(AgoraBoardWidgetStepChangeType.self,
                                         DecodingError.Context(codingPath: decoder.codingPath,
                                                               debugDescription: "Wrong type for AgoraBoardWidgetStepChangeType"))
    }
    
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        switch self {
        case .pre(let x):
            try container.encode(x,
                                 forKey: .pre)
        case .next(let x):
            try container.encode(x,
                                 forKey: .next)
        case .undoCount(let x):
            try container.encode(x,
                                 forKey: .undoCount)
        case .redoCount(let x):
            try container.encode(x,
                                 forKey: .redoCount)
        }
    }
}
// courseware
// 待定
struct AgoraBoardWidgetCoursewareInfo: Convertable {
    var resourceUuid: String
    var resourceName: String
    var scenes: [AgoraBoardWidgetWhiteScene]
    var convert: Bool?
}

struct AgoraBoardWidgetWhiteScene: Convertable {
    var name: String
    var ppt: AgoraBoardWidgetWhitePptPage
}

struct AgoraBoardWidgetWhitePptPage: Convertable {
    /// 图片的 URL 地址。
    var src: String
    /// 图片的 URL 宽度。单位为像素。
    var width: Float
    /// 图片的 URL 高度。单位为像素。
    var height: Float
    /// 预览图片的 URL 地址
    var previewURL: String?
}
