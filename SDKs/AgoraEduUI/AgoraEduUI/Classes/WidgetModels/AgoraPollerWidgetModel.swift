//
//  AgoraPollerWidgetModel.swift
//  AgoraEduUI
//
//  Created by LYY on 2022/3/2.
//

import Foundation

let kPollerWidgetId = "polling"
enum AgoraPollerWidgetSignal: Convertable {
    case frameChange(CGRect)
    
    private enum CodingKeys: CodingKey {
        case frameChange
    }
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        
        if let startInfo = try? container.decode(CGRect.self,
                                                 forKey: .frameChange) {
            self = .frameChange(startInfo)
        } else {
            self = .frameChange(.zero)
        }
    }
    
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        switch self {
        case .frameChange(let value):
            try container.encode(value,
                                 forKey: .frameChange)
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
    func toPollerSignal() -> AgoraPollerWidgetSignal? {
        guard let messageDic = self.json(),
              let signal = try AgoraPollerWidgetSignal.decode(messageDic) else {
                  return nil
              }
        return signal
    }
}
