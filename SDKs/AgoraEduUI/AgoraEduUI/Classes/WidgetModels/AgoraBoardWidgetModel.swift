//
//  AgoraBoardWidgetModel.swift
//  AgoraEduUI
//
//  Created by DoubleCircle on 2021/12/9.
//

import Foundation

let kBoardWidgetId = "netlessBoard"
// MARK: - Config
enum AgoraBoardWidgetSignal: Convertable {
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
    
    private enum CodingKeys: CodingKey {
        case JoinBoard
        case BoardPhaseChanged
        case MemberStateChanged
        case BoardGrantDataChanged
        case AudioMixingStateChanged
        case BoardAudioMixingRequest
        case BoardPageChanged
        case BoardStepChanged
        case ClearBoard
        case OpenCourseware
        case WindowStateChanged
    }
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        
        if let _ = try? container.decodeNil(forKey: .JoinBoard) {
            self = .JoinBoard
        } else if let value = try? container.decode(AgoraBoardWidgetRoomPhase.self,
                                                    forKey: .BoardPhaseChanged) {
            self = .BoardPhaseChanged(value)
        } else if let value = try? container.decode(AgoraBoardWidgetMemberState.self,
                                                    forKey: .MemberStateChanged) {
            self = .MemberStateChanged(value)
        } else if let value = try? container.decode(AgoraBoardWidgetAudioMixingChangeData.self,
                                                    forKey: .AudioMixingStateChanged) {
            self = .AudioMixingStateChanged(value)
        } else if let value = try? container.decode(Array<String>?.self,
                                                    forKey: .BoardGrantDataChanged) {
            self = .BoardGrantDataChanged(value)
        } else if let value = try? container.decode(AgoraBoardWidgetPageChangeType.self,
                                                    forKey: .BoardPageChanged) {
            self = .BoardPageChanged(value)
        } else if let value = try? container.decode(AgoraBoardWidgetStepChangeType.self,
                                                    forKey: .BoardStepChanged) {
            self = .BoardStepChanged(value)
        } else if let value = try? container.decodeNil(forKey: .ClearBoard) {
            self = .ClearBoard
        } else if let value = try? container.decode(AgoraBoardWidgetCoursewareInfo.self,
                                                    forKey: .OpenCourseware) {
            self = .OpenCourseware(value)
        } else if let value = try? container.decode(AgoraBoardWidgetWindowState.self,
                                                    forKey: .WindowStateChanged) {
            self = .WindowStateChanged(value)
        } else {
            throw DecodingError.dataCorrupted(
                .init(
                    codingPath: container.codingPath,
                    debugDescription: "invalid data"
                )
            )
        }
    }
    
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        
        switch self {
        case .JoinBoard:
            try container.encodeNil(forKey: .JoinBoard)
        case .BoardPhaseChanged(let x):
            try container.encode(x,
                                 forKey: .BoardPhaseChanged)
        case .MemberStateChanged(let x):
            try container.encode(x,
                                 forKey: .MemberStateChanged)
        case .BoardGrantDataChanged(let x):
            try container.encode(x,
                                 forKey: .BoardGrantDataChanged)
        case .AudioMixingStateChanged(let x):
            try container.encode(x,
                                 forKey: .AudioMixingStateChanged)
        case .BoardAudioMixingRequest(let x):
            try container.encode(x,
                                 forKey: .BoardAudioMixingRequest)
        case .BoardPageChanged(let x):
            try container.encode(x,
                                 forKey: .BoardPageChanged)
        case .BoardStepChanged(let x):
            try container.encode(x,
                                 forKey: .BoardStepChanged)
        case .ClearBoard:
            try container.encodeNil(forKey: .ClearBoard)
        case .OpenCourseware(let x):
            try container.encode(x,
                                 forKey: .OpenCourseware)
        case .WindowStateChanged(let x):
            try container.encode(x,
                                 forKey: .WindowStateChanged)
    }
    }
    
    func toMessageString() -> String? {
        guard let dic = self.toDictionary(),
           let str = dic.jsonString() else {
            return nil
        }
        return str
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
extension String {
    func toBoardSignal() -> AgoraBoardWidgetSignal? {
        guard let dic = self.json(),
              let signal = try AgoraBoardWidgetSignal.decode(dic) else {
                  return nil
              }
        
        return signal
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
    
    private enum CodingKeys: CodingKey {
        case pre
        case next
        case undoCount
        case redoCount
    }
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        if let x = try? container.decode(Int.self,
                                         forKey: .pre) {
            self = .pre(x)
        } else if let x = try? container.decode(Int.self,
                                         forKey: .next) {
            self = .next(x)
        } else if let x = try? container.decode(Int.self,
                                         forKey: .undoCount) {
            self = .undoCount(x)
        } else if let x = try? container.decode(Int.self,
                                                forKey: .redoCount) {
            self = .redoCount(x)
        } else {
            throw DecodingError.typeMismatch(AgoraBoardWidgetStepChangeType.self,
                                             DecodingError.Context(codingPath: decoder.codingPath,
                                                                   debugDescription: "Wrong type for AgoraBoardWidgetStepChangeType"))
        }
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
    var resourceUrl: String
    var scenes: [AgoraBoardWidgetWhiteScene]?
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
