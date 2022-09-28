//
//  PtContextExtension.swift
//  AgoraProctorUI
//
//  Created by LYY on 2022/9/5.
//

import AgoraEduCore

extension AgoraEduContextClassInfo {
    func toExamState(countdown: Int = 0) -> FcrProctorUIExamState {
        switch state {
        case .before:
            return .before
        case .during:
            let timeInfo = FcrProctorExamTimeInfo(startTime: startTime,
                                                  duration: duration)
            return .during(countdown: countdown,
                           timeInfo: timeInfo)
        case .after:
            let timeInfo = FcrProctorExamTimeInfo(startTime: startTime,
                                                  duration: duration)
            return .after(timeInfo: timeInfo)
        }
    }
}
