//
//  FcrUIEnums.swift
//  AgoraProctorUI
//
//  Created by LYY on 2022/9/5.
//

import AgoraEduContext

enum FcrProctorUIExamState {
    case before
    case during(countdown: Int,timeInfo: FcrProctorExamTimeInfo)
    case after(timeInfo: FcrProctorExamTimeInfo)
}

enum FcrProctorUIDeviceType: String {
    case main = "main"
    case sub = "sub"
}
