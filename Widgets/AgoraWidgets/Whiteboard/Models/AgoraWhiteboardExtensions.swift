//
//  AgoraWhiteboardExtensions.swift
//  AgoraWidgets
//
//  Created by DoubleCircle on 2021/12/3.
//

import Foundation
import Whiteboard

// MARK: - from Whiteboard
extension WhiteApplianceNameKey {
    func toWidget() -> AgoraBoardToolType {
        switch self {
        case .ApplianceSelector: return .Selector
        case .ApplianceText: return .Text
        case .ApplianceRectangle: return .Rectangle
        case .ApplianceEllipse: return .Ellipse
        case .ApplianceEraser: return .Eraser
        case .AppliancePencil: return .Pencil
        case .ApplianceArrow: return .Arrow
        case .ApplianceStraight: return .Straight
        case .ApplianceLaserPointer: return .Pointer
        case .ApplianceClicker: return .Clicker
        default:
            return .Selector
        }
    }
}

extension WhiteRoomPhase {
    func toWidget() -> AgoraBoardRoomPhase {
        switch self {
        case .connecting:      return .Connecting
        case .connected:       return .Connected
        case .reconnecting:    return .Reconnecting
        case .disconnecting:   return .Disconnecting
        case .disconnected:    return .Disconnected
        default:
            return .Disconnected
        }
    }
    
    var strValue: String {
        switch self {
        case .connecting:      return "Connecting"
        case .connected:       return "Connected"
        case .reconnecting:    return "Reconnecting"
        case .disconnecting:   return "Disconnecting"
        case .disconnected:    return "Disconnected"
        default:
            return "Disconnected"
        }
    }
}

extension WhiteCameraState {
    func toWidget() -> AgoraWhiteBoardCameraConfig {
        var config = AgoraWhiteBoardCameraConfig()
        config.centerX = CGFloat(self.centerX)
        config.centerY = CGFloat(self.centerY)
        config.scale = CGFloat(self.scale)
        return config
    }
}

extension WhiteReadonlyMemberState {
    func toMemberState() -> WhiteMemberState {
        var state = WhiteMemberState()
        state.currentApplianceName = self.currentApplianceName
        state.strokeColor = self.strokeColor
        state.strokeWidth = self.strokeWidth
        state.textSize = self.textSize
        state.shapeType = self.shapeType
        return state
    }
}

// MARK: - from Widget
extension AgoraWhiteBoardCameraConfig {
    func toWhiteboard() -> WhiteCameraConfig {
        var cameraState  = WhiteCameraConfig()
        cameraState.centerX = NSNumber(nonretainedObject: self.centerX)
        cameraState.centerY = NSNumber(nonretainedObject:self.centerY)
        cameraState.scale = NSNumber(nonretainedObject:self.scale)
        return cameraState
    }
}

extension AgoraBoardToolType {
    func toWhiteboard() -> WhiteApplianceNameKey {
        switch self {
        case .Selector:     return .ApplianceSelector
        case .Text:         return .ApplianceText
        case .Rectangle:    return .ApplianceRectangle
        case .Ellipse:      return .ApplianceEllipse
        case .Eraser:       return .ApplianceEraser
        case .Pencil:       return .AppliancePencil
        case .Arrow:        return .ApplianceArrow
        case .Straight:     return .ApplianceStraight
        case .Pointer:      return .ApplianceLaserPointer
        case .Clicker:      return .ApplianceClicker
        default:
            return .ApplianceSelector
        }
    }
}

extension AgoraBoardMemberState {
    init(_ state: WhiteReadonlyMemberState) {
        var toolType = state.currentApplianceName.toWidget()
        var colorArr = Array<Int>()
        var strokeWidth: Int?
        var textSize: Int?

        state.strokeColor.forEach { number in
            colorArr.append(number.intValue)
        }
        
        if let width = state.strokeWidth {
            strokeWidth = width.intValue
        }
        
        if let stateTextSize = state.textSize {
            textSize = stateTextSize.intValue
        }

        let agState = AgoraBoardMemberState(activeApplianceType: toolType,
                                                strokeColor: colorArr,
                                                strokeWidth: strokeWidth,
                                                textSize: textSize)
        self.init(activeApplianceType: toolType,
                  strokeColor: colorArr,
                  strokeWidth: strokeWidth,
                  textSize: textSize)
    }
    
    func toWhiteboard(oriState: WhiteMemberState) -> WhiteMemberState {
        // TODO: 数据结构转换
        var memberState = WhiteMemberState()
        
        memberState.currentApplianceName = self.activeApplianceType?.toWhiteboard()
        memberState.strokeColor = self.strokeColor as [NSNumber]?
        memberState.strokeWidth = self.strokeWidth as NSNumber?
        memberState.textSize = self.textSize as NSNumber?
        
        return memberState
    }
}

extension AgoraBoardInteractionSignal {
    func toMessageString() -> String? {
        var dic = [String: Any]()
        dic["signal"] = self.rawValue
        switch self {
        case .JoinBoard: break
        case .BoardPhaseChanged(let boardRoomPhase) :
            dic["body"] = boardRoomPhase.rawValue
        case .MemberStateChanged(let boardMemberState) :
            dic["body"] = boardMemberState.toDictionary()
        case .AudioMixingStateChanged(let boardAudioMixingChangeData) :
            dic["body"] = boardAudioMixingChangeData.toDictionary()
        case .BoardGrantDataChanged(let boardGrantData) :
            dic["body"] = boardGrantData
        case .BoardAudioMixingRequest(let agoraBoardAudioMixingRequestData):
            dic["body"] = agoraBoardAudioMixingRequestData.toDictionary()
        default:
            break
        }
        return dic.jsonString()
    }
}

// MARK: - Base
extension Dictionary {
    func toObj<T>(_ type: T.Type) -> T? where T : Decodable {
        guard JSONSerialization.isValidJSONObject(self),
              let data = try? JSONSerialization.data(withJSONObject: self,
                                                     options: []),
              let model = try? JSONDecoder().decode(T.self,
                                                    from: data) else {
                  return nil
              }
        return model
    }

}

extension String {
    func translatePath() -> String {
        if self.count < 32 {
            return "/init"
        } else {
            return self
        }
    }
    
    func toSignal() -> AgoraBoardInteractionSignal? {
        guard let dic = self.json(),
              let signalRaw = dic["signal"] as? Int else {
            return nil
        }
        if signalRaw == AgoraBoardInteractionSignal.JoinBoard.rawValue {
            return .JoinBoard
        }
        
        if let bodyArr = dic["body"] as? [String] {
            return .BoardGrantDataChanged(bodyArr)
        }
        
        guard let bodyDic = dic["body"] as? [String:Any],
              let type = AgoraBoardInteractionSignal.getType(rawValue: signalRaw),
              let obj = try type.decode(bodyDic) else {
            return nil
        }
        return AgoraBoardInteractionSignal.makeSignal(rawValue: signalRaw,
                                                      body: obj)
    }
}

extension Array : Convertable where Element == String {
    
}

extension UIColor {
    func getRGBAArr() -> Array<NSNumber> {
        var red: CGFloat = 0
        var green: CGFloat = 0
        var blue: CGFloat = 0
        var alpha: CGFloat = 0
        self.getRed(&red,
                    green: &green,
                    blue: &blue,
                    alpha: &alpha)
        return [NSNumber(value: Int(red)),
                NSNumber(value: Int(green)),
                NSNumber(value: Int(blue))]
    }
}
