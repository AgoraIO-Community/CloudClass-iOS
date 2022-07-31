//
//  AgoraCountdownWidgetModel.swift
//  AgoraEduUI
//
//  Created by LYY on 2022/3/6.
//

enum AgoraCountdownWidgetSignal: Convertable {
    case getTimestamp
    case sendTimestamp(Int64)
    
    private enum CodingKeys: CodingKey {
        case getTimestamp
        case sendTimestamp
    }
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        
        if let ts = try? container.decode(Int64.self,
                                                 forKey: .sendTimestamp) {
            self = .sendTimestamp(ts)
        } else if let _ = try? container.decodeNil(forKey: .getTimestamp) {
            self = .getTimestamp
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
        case .getTimestamp:
            try container.encodeNil(forKey: .getTimestamp)
        case .sendTimestamp(let ts):
            try container.encode(ts,
                                 forKey: .sendTimestamp)
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
    func toCountdownSignal() -> AgoraCountdownWidgetSignal? {
        guard let dic = self.json(),
              let signal = try AgoraCountdownWidgetSignal.decode(dic) else {
                  return nil
              }
        
        return signal
    }
}
