//
//  AgoraWebViewWidgetModel.swift
//  AgoraEduUI
//
//  Created by DoubleCircle on 2022/5/25.
//

enum AgoraWebViewWidgetSignal: Convertable {
    case boardAuth(Bool)
    case viewZIndexChanged(Int)
    case updateViewZIndex(Int)
    case scale
    case close
    
    private enum CodingKeys: CodingKey {
        case boardAuth
        case viewZIndexChanged
        case updateViewZIndex
        case scale
        case close
    }
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        
        if let value = try? container.decode(Bool.self,
                                             forKey: .boardAuth) {
            self = .boardAuth(value)
        } else if let value = try? container.decode(Int.self,
                                                    forKey: .viewZIndexChanged) {
            self = .viewZIndexChanged(value)
        } else if let value = try? container.decode(Int.self,
                                                     forKey: .updateViewZIndex) {
            self = .updateViewZIndex(value)
        } else if let value = try? container.decodeNil(forKey: .scale) {
            self = .scale
        } else if let value = try? container.decodeNil(forKey: .close) {
            self = .close
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
        case .boardAuth(let x):
            try container.encode(x,
                                 forKey: .boardAuth)
        case .viewZIndexChanged(let x):
            try container.encode(x,
                                 forKey: .viewZIndexChanged)
        case .updateViewZIndex(let x):
            try container.encode(x,
                                 forKey: .updateViewZIndex)
        case .scale:
            try container.encodeNil(forKey: .scale)
        case .close:
            try container.encodeNil(forKey: .close)
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
    func toWebViewSignal() -> AgoraWebViewWidgetSignal? {
        guard let dic = self.json(),
              let signal = try AgoraWebViewWidgetSignal.decode(dic) else {
            return nil
        }
        
        return signal
    }
}

