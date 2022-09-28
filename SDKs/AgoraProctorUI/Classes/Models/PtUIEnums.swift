//
//  PtUIEnums.swift
//  AgoraProctorUI
//
//  Created by LYY on 2022/9/5.
//

import AgoraEduCore

@objc public enum PtUISceneExitReason: Int {
    case normal, kickOut
}

enum FcrProctorUIExamState {
    case before
    case during(countdown: Int,timeInfo: FcrProctorExamTimeInfo)
    case after(timeInfo: FcrProctorExamTimeInfo)
}

enum FcrProctorUIDeviceType: String {
    case main = "main"
    case sub = "sub"
}
