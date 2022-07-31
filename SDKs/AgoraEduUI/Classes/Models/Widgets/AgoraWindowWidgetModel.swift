//
//  AgoraSpreadWidgetModel.swift
//  AgoraEduUI
//
//  Created by LYY on 2022/1/18.
//

struct AgoraStreamWindowWidgetRenderInfo: Convertable {
    var userUuid: String
    var streamId: String
    var zIndex: Int?
}

enum AgoraStreamWindowWidgetSignal: Convertable {
    case RenderInfo(AgoraStreamWindowWidgetRenderInfo)
    case ViewZIndex(Int)
    
    private enum CodingKeys: CodingKey {
        case RenderInfo
        case ViewZIndex
    }
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        
        if let value = try? container.decode(AgoraStreamWindowWidgetRenderInfo.self,
                                             forKey: .RenderInfo) {
            self = .RenderInfo(value)
        } else if let value = try? container.decode(Int.self,
                                                   forKey: .ViewZIndex) {
            self = .ViewZIndex(value)
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
        case .RenderInfo(let x):
            try container.encode(x,
                                 forKey: .RenderInfo)
        case .ViewZIndex(let x):
            try container.encode(x,
                                 forKey: .ViewZIndex)
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
    func toWindowSignal() -> AgoraStreamWindowWidgetSignal? {
        guard let dic = self.json(),
              let signal = try AgoraStreamWindowWidgetSignal.decode(dic) else {
                  return nil
              }
        
        return signal
    }
}
