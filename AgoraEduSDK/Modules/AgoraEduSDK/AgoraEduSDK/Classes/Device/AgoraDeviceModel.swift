//
//  AgoraDeviceModel.swift
//  AgoraEduSDK
//
//  Created by SRS on 2021/5/7.
//  Copyright © 2021 Agora. All rights reserved.
//

import Foundation

public enum AgoraDeviceType: String {
    case camera = "camera"
    case microphone = "mic"
    case speaker = "speaker"
    case facing = "facing"
}

@objc public enum AgoraDeviceStateType: Int {
    case camera, microphone
}
