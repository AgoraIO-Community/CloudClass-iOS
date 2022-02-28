//
//  AgoraSpreadWidgetModel.swift
//  AgoraEduUI
//
//  Created by LYY on 2022/1/18.
//

import Foundation

let kSpreadWidgetId = "streamWindow"
struct AgoraSpreadWidgetUser: Convertable {
    var userId: String
    var streamId: String
}

struct AgoraSpreadWidgetInfo: Convertable {
    var frame: CGRect
    var user: AgoraSpreadWidgetUser
}

enum AgoraSpreadWidgetSignal {
    case start(AgoraSpreadWidgetInfo)
    case changeFrame(AgoraSpreadWidgetInfo)
    case stop
    
    var rawValue: Int {
        switch self {
        case .start(_):         return 0
        case .changeFrame(_):   return 1
        case .stop:             return 2
        default:                return -1
        }
    }
    
    static func getType(rawValue: Int) -> Convertable.Type? {
        switch rawValue {
        case 0,1: return AgoraSpreadWidgetInfo.self
        default:
            return nil
        }
    }
    
    static func makeSignal(rawValue: Int,
                           body: Convertable?) -> AgoraSpreadWidgetSignal? {
        switch rawValue {
        case 0:
            if let x = body as? AgoraSpreadWidgetInfo {
                return .start(x)
            }
        case 1:
            if let x = body as? AgoraSpreadWidgetInfo {
                return .changeFrame(x)
            }
        default:
            break
        }
        return nil
    }
}


extension String {
    func toSpreadSignal() -> AgoraSpreadWidgetSignal? {
        guard let dic = self.json(),
              let signalRaw = dic["signal"] as? Int else {
                  return nil
              }
        if signalRaw == AgoraSpreadWidgetSignal.stop.rawValue {
            return .stop
        }
        
        if let bodyDic = dic["body"] as? [String:Any],
           let type = AgoraSpreadWidgetSignal.getType(rawValue: signalRaw),
           let obj = try type.decode(bodyDic) {
            return AgoraSpreadWidgetSignal.makeSignal(rawValue: signalRaw,
                                                      body: obj)
        }
        
        return nil
    }
}
