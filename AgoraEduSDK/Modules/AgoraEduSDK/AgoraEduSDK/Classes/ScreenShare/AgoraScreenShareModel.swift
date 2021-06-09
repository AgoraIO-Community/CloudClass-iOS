//
//  AgoraScreenShareModel.swift
//  AgoraEduSDK
//
//  Created by SRS on 2021/5/7.
//  Copyright © 2021 Agora. All rights reserved.
//

import Foundation

@objc public enum AgoraScreenShareState: Int {
    // pause是分享中断
    // selected和unSelected是切到其他tab，需要隐藏
    case start, pause, stop, selected, unSelected
}

@objc public enum AgoraScreenShareRTCState: Int {
    case onLine, offLine
}
