//
//  PtUIModels.swift
//  AgoraProctorUI
//
//  Created by LYY on 2022/9/5.
//

import AgoraEduCore

struct FcrProctorExamTimeInfo {
    var startTime: Int64
    var duration: Int64
    
    var valid: Bool {
        return (startTime > 0) && (duration > 0)
    }
}
