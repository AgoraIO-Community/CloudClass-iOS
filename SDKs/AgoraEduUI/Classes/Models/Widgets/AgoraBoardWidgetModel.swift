//
//  AgoraBoardWidgetModel.swift
//  AgoraEduUI
//
//  Created by DoubleCircle on 2021/12/9.
//

import Foundation

// MARK: - Config
enum AgoraBoardWidgetSignal: Convertable {
    case JoinBoard
    case ChangeAssistantType(FcrBoardWidgetAssistantType)
    case GetBoardGrantedUsers([String])
    case UpdateGrantedUsers(AgoraBoardWidgetGrantUsersChangeType)
    case AudioMixingStateChanged(AgoraBoardWidgetAudioMixingChangeData)
    case BoardAudioMixingRequest(AgoraBoardWidgetAudioMixingRequestData)
    case BoardPageChanged(AgoraBoardWidgetPageChangeType)
    case BoardStepChanged(AgoraBoardWidgetStepChangeType)
    case ClearBoard
    case OpenCourseware(AgoraBoardWidgetCoursewareInfo)
    case WindowStateChanged(AgoraBoardWidgetWindowState)
    case SaveBoard
    case ChangeRatio
    case OnBoardSaveResult(FcrBoardWidgetSnapshotResult)
    case CloseBoard
    
    private enum CodingKeys: CodingKey {
        case JoinBoard
        case ChangeAssistantType
        case GetBoardGrantedUsers
        case UpdateGrantedUsers
        case AudioMixingStateChanged
        case BoardAudioMixingRequest
        case BoardPageChanged
        case BoardStepChanged
        case ClearBoard
        case OpenCourseware
        case WindowStateChanged
        case SaveBoard
        case ChangeRatio
        case OnBoardSaveResult
        case CloseBoard
    }
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        
        if let _ = try? container.decodeNil(forKey: .JoinBoard) {
            self = .JoinBoard
        } else if let value = try? container.decode(FcrBoardWidgetAssistantType.self,
                                                    forKey: .ChangeAssistantType) {
            self = .ChangeAssistantType(value)
        } else if let value = try? container.decode(AgoraBoardWidgetAudioMixingChangeData.self,
                                                    forKey: .AudioMixingStateChanged) {
            self = .AudioMixingStateChanged(value)
        } else if let value = try? container.decode([String].self,
                                                    forKey: .GetBoardGrantedUsers) {
            self = .GetBoardGrantedUsers(value)
        } else if let value = try? container.decode(AgoraBoardWidgetGrantUsersChangeType.self,
                                                    forKey: .UpdateGrantedUsers) {
            self = .UpdateGrantedUsers(value)
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
        } else if let _ = try? container.decodeNil(forKey: .SaveBoard) {
            self = .SaveBoard
        } else if let _ = try? container.decodeNil(forKey: .ChangeRatio) {
            self = .ChangeRatio
        } else if let value = try? container.decode(FcrBoardWidgetSnapshotResult.self,
                                                    forKey: .OnBoardSaveResult) {
            self = .OnBoardSaveResult(value)
        } else if let _ = try? container.decodeNil(forKey: .CloseBoard) {
            self = .CloseBoard
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
        case .ChangeAssistantType(let x):
            try container.encode(x,
                                 forKey: .ChangeAssistantType)
        case .GetBoardGrantedUsers(let x):
            try container.encode(x,
                                 forKey: .GetBoardGrantedUsers)
        case .UpdateGrantedUsers(let x):
            try container.encode(x,
                                 forKey: .UpdateGrantedUsers)
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
        case .SaveBoard:
            try container.encodeNil(forKey: .SaveBoard)
        case .ChangeRatio:
            try container.encodeNil(forKey: .ChangeRatio)
        case .OnBoardSaveResult(let x):
            try container.encode(x,
                                 forKey: .OnBoardSaveResult)
        case .CloseBoard:
            try container.encodeNil(forKey: .CloseBoard)
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
// save snapshot
enum FcrBoardWidgetSnapshotResult: Int, Convertable {
    case savedToAlbum, noAlbumAuth, failureToSave
}

enum AgoraBoardWidgetWindowState: Int, Convertable {
    case min, max, normal
}
// MARK: - Message
// 当外部手动更新某一项数据的时候MemberState就只包含对应的某一项，然后通过sendMessageToWidget发送即可
// 若初始化时期，白板需要向外传
struct AgoraBoardWidgetAssistantType: Convertable {
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

enum FcrBoardWidgetToolType: Int, Convertable {
    case clicker, area, laserPointer, eraser
}

struct FcrBoardWidgetTextInfo: Convertable {
    var size: Int
    var color: Array<Int>
}

enum FcrBoardWidgetShapeType: Int, Convertable {
    case curve, straight, arrow, rectangle, triangle, rhombus, pentagram, ellipse
}

struct FcrBoardWidgetShapeInfo: Convertable {
    var type: FcrBoardWidgetShapeType
    var width: Int
    var color: Array<Int>
}
    
enum FcrBoardWidgetAssistantType: Convertable {
    case tool(FcrBoardWidgetToolType)
    case text(FcrBoardWidgetTextInfo)
    case shape(FcrBoardWidgetShapeInfo)

    private enum CodingKeys: CodingKey {
        case tool
        case text
        case shape
    }
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        
        if let value = try? container.decode(FcrBoardWidgetToolType.self,
                                                    forKey: .tool) {
            self = .tool(value)
        } else if let value = try? container.decode(FcrBoardWidgetTextInfo.self,
                                                    forKey: .text) {
            self = .text(value)
        } else if let value = try? container.decode(FcrBoardWidgetShapeInfo.self,
                                                    forKey: .shape) {
            self = .shape(value)
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
        case .tool(let x):
            try container.encode(x,
                                 forKey: .tool)
        case .text(let x):
            try container.encode(x,
                                 forKey: .text)
        case .shape(let x):
            try container.encode(x,
                                 forKey: .shape)
        }
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

extension Int {
    func toColorArr() -> [Int] {
        return UIColor(hex: self)!.getRGBAArr()
    }
}

enum AgoraBoardWidgetGrantUsersChangeType: Convertable {
    case add([String])
    case delete([String])
    
    private enum CodingKeys: CodingKey {
        case add
        case delete
    }
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        if let x = try? container.decode([String].self,
                                         forKey: .add) {
            self = .add(x)
        } else if let x = try? container.decode([String].self,
                                                forKey: .delete) {
            self = .delete(x)
        } else {
            throw DecodingError.typeMismatch(AgoraBoardWidgetGrantUsersChangeType.self,
                                             DecodingError.Context(codingPath: decoder.codingPath,
                                                                   debugDescription: "Wrong type for AgoraBoardGrantUsersChangeType"))
        }
    }
    
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        switch self {
        case .add(let x):
            try container.encode(x,
                                 forKey: .add)
        case .delete(let x):
            try container.encode(x,
                                 forKey: .delete)
        }
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
    case undoAble(Bool)
    case redoAble(Bool)
    
    private enum CodingKeys: CodingKey {
        case pre
        case next
        case undoAble
        case redoAble
    }
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        if let x = try? container.decode(Int.self,
                                         forKey: .pre) {
            self = .pre(x)
        } else if let x = try? container.decode(Int.self,
                                                forKey: .next) {
            self = .next(x)
        } else if let x = try? container.decode(Bool.self,
                                                forKey: .undoAble) {
            self = .undoAble(x)
        } else if let x = try? container.decode(Bool.self,
                                                forKey: .redoAble) {
            self = .redoAble(x)
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
        case .undoAble(let x):
            try container.encode(x,
                                 forKey: .undoAble)
        case .redoAble(let x):
            try container.encode(x,
                                 forKey: .redoAble)
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
