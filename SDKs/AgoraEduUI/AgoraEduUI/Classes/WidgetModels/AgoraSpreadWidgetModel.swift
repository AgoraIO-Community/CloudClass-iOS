//
//  AgoraSpreadWidgetModel.swift
//  AgoraEduUI
//
//  Created by LYY on 2022/1/18.
//

import UIKit

let kSpreadWidgetId = "streamWindow"
struct AgoraSpreadWidgetUser: Convertable {
    var userId: String
    var streamId: String
}

struct AgoraSpreadWidgetInfo: Convertable {
    var frame: CGRect
    var user: AgoraSpreadWidgetUser
}

enum AgoraSpreadWidgetSignal: Convertable {
    case start(AgoraSpreadWidgetInfo)
    case changeFrame(AgoraSpreadWidgetInfo)
    case stop
    
    
    private enum CodingKeys: CodingKey {
        case start
        case changeFrame
        case stop
    }
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        
        if let _ = try? container.decodeNil(forKey: .stop) {
            self = .stop
        } else if let value = try? container.decode(AgoraSpreadWidgetInfo.self,
                                                    forKey: .start) {
            self = .start(value)
        } else if let value = try? container.decode(AgoraSpreadWidgetInfo.self,
                                                    forKey: .changeFrame) {
            self = .changeFrame(value)
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
        case .stop:
            try container.encodeNil(forKey: .stop)
        case .start(let x):
            try container.encode(x,
                                 forKey: .start)
        case .changeFrame(let x):
            try container.encode(x,
                                 forKey: .changeFrame)
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

extension String {
    func toSpreadSignal() -> AgoraSpreadWidgetSignal? {
        guard let dic = self.json(),
              let signal = try AgoraSpreadWidgetSignal.decode(dic) else {
                  return nil
              }
        
        return signal
    }
}
