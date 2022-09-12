//
//  FcrContextExtension.swift
//  AgoraProctorUI
//
//  Created by LYY on 2022/9/5.
//

import AgoraEduContext

extension AgoraEduContextClassInfo {
    var ui: FcrExamExamStateInfo {
        let info = FcrExamExamStateInfo(state: state,
                                        startTime: startTime,
                                        duration: duration)
        return info
    }
}
