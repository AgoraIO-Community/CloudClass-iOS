//
//  FcrContextExtension.swift
//  AgoraProctorUI
//
//  Created by LYY on 2022/9/5.
//

import AgoraEduContext

extension AgoraEduContextClassState {
    var toUI: FcrUIRoomState {
        switch self {
        case .before: return .before
        case .during: return .during
        case .after:  return .after
        }
    }
}
