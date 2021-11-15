//
//  AgoraUIRenderItem.swift
//  AgoraEduUI
//
//  Created by Cavan on 2021/10/15.
//

import UIKit

struct AgoraUIRenderItem {
    enum VideoSourceType {
        case invalid, none, camera, screen
    }
    
    enum AudioSourceType {
        case invalid, none, mic
    }
    
    var userName: String
    var userUuid: String
    var videoSourceType: VideoSourceType
    var audioSourceType: AudioSourceType
    var hasVideoStream: Bool
    var hasAudioStream: Bool
}
