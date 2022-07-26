//
//  AgoraChatWidgetModel.swift
//  AgoraEduUI
//
//  Created by LYY on 2022/7/20.
//

import Foundation

enum AgoraChatWidgetSignal: Convertable {
    case messageReceived
    case error(String)
    
    private enum CodingKeys: CodingKey {
        case messageReceived
        case error
    }
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        if let value = try? container.decode(String.self,
                                                    forKey: .error) {
            self = .error(value)
        } else if let value = try? container.decodeNil(forKey: .messageReceived) {
            self = .messageReceived
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
        case .error(let x):
            try container.encode(x,
                                 forKey: .error)
        case .messageReceived:
            try container.encodeNil(forKey: .messageReceived)
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
    func toChatSignal() -> AgoraChatWidgetSignal? {
        guard let dic = self.json(),
              let signal = try AgoraChatWidgetSignal.decode(dic) else {
                  return nil
              }
        
        return signal
    }
}
