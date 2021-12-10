//
//  AgoraWhiteboardWidget+Callback.swift
//  AgoraWidgets
//
//  Created by LYY on 2021/12/7.
//

import Whiteboard

extension AgoraWhiteboardWidget: WhiteRoomCallbackDelegate {
    public func fireRoomStateChanged(_ modifyState: WhiteRoomState!) {
        guard let `room` = room else {
            return
        }
        
        if let memberState = modifyState.memberState {
            let agMember = AgoraBoardMemberState(memberState)
            sendMessage(signal: .MemberStateChanged(agMember))
            return
        }
        
        // 老师离开
        if let broadcastState = modifyState.broadcastState {
            if broadcastState.broadcasterId == nil {
                room.scalePpt(toFit: .continuous)
                room.scaleIframeToFit()
            }
            return
        }
        
        if let zoomScale = modifyState.zoomScale {
            return
        }

        if let state = modifyState.globalState as? AgoraWhiteboardGlobalState {
            dt.globalState = state
            return
        }
        
        if let sceneState = modifyState.sceneState {
            // 1. 取真实regionDomain
            if sceneState.scenes.count > 0,
               let ppt = sceneState.scenes[0].ppt,
               ppt.src.hasPrefix("pptx://") {
                let src = ppt.src
                let index = src.index(src.startIndex, offsetBy:7)
                let arr = String(src[index...]).split(separator: ".")
                dt.regionDomain = (dt.regionDomain == String(arr[0])) ? dt.regionDomain : String(arr[0])
            }
            
            // 2. scenePath 判断
            let newScenePath = sceneState.scenePath.split(separator: "/")[1]
            if "/\(newScenePath)" != dt.scenePath {
                dt.scenePath = "/\(newScenePath)"
            }
            
            // 3. ppt 获取总页数，当前第几页
            room.scaleIframeToFit()
            if sceneState.scenes[sceneState.index] != nil {
                room.scalePpt(toFit: .continuous)
            }
            // page改变
//            let pageCount = sceneState.scenes.count
//            let pageIndex = sceneState.index
            ifUseLocalCameraConfig()
            return
        }
        
        if let cameraState = modifyState.cameraState,
           dt.localGranted {
            // 如果本地被授权，则是本地自己设置的摄像机视角
            dt.localCameraConfigs[room.sceneState.scenePath] = cameraState.toWidget()
            return
        }
    }
    
    public func firePhaseChanged(_ phase: WhiteRoomPhase) {
        sendMessage(signal: .BoardPhaseChanged(phase.toWidget()))
        
        if phase == .disconnected,
           let `room` = room,
           !room.disconnectedBySelf {
            // 断线重连
            joinWhiteboard()
        }
    }
}

extension AgoraWhiteboardWidget: WhiteCommonCallbackDelegate {
    public func throwError(_ error: Error) {
        log(.error,
            content: error.localizedDescription)
    }
    
    public func logger(_ dict: [AnyHashable : Any]) {
        log(.info,
            content: dict.description)
    }
}

extension AgoraWhiteboardWidget: WhiteAudioMixerBridgeDelegate {
    public func startAudioMixing(_ filePath: String,
                                 loopback: Bool,
                                 replace: Bool,
                                 cycle: Int) {
//        // 调用RTC
//        let contextError = context.media.startAudioMixing(filePath: filePath,
//                                                   loopback: loopback,
//                                                   replace: replace,
//                                                   cycle: cycle)
//        if let error = contextError {
            // 714对应RTC中的AgoraAudioMixingStateFailed
//            whiteSDK.audioMixer?.setMediaState(714,
//                                               errorCode: error.code)
//        }
    }
    
    public func stopAudioMixing() {
//        let contextError = context.media.stopAudioMixing()
//        if let error = contextError {
//            whiteSDK.audioMixer?.setMediaState(0,
//                                               errorCode: error.code)
//        }
    }
    
    public func setAudioMixingPosition(_ position: Int) {
//        let contextError = context.media.setAudioMixingPosition(position: position)
//        if let error = contextError {
//            whiteSDK.audioMixer?.setMediaState(0,
//                                               errorCode: error.code)
//        }
    }
}

extension AgoraWhiteboardWidget: AGBoardWidgetDTDelegate {
    func onFollowChanged(follow: Bool) {
        if follow {
            room?.setViewMode(.follower)
        } else {
            room?.setViewMode(.freedom)
        }
    }
    
    func onGrantUsersChanged(grantUsers: [String]?) {
        sendMessage(signal: .BoardGrantDataChanged(grantUsers))
    }
    
    func onLocalGrantedChanged(localGranted: Bool) {
        room?.disableCameraTransform(!localGranted)
        ifUseLocalCameraConfig()
        if localGranted {
            room?.setViewMode(.freedom)
        } else {
            room?.setViewMode(.follower)
        }
    }
    
    func onScenePathChanged(path: String) {
        ifUseLocalCameraConfig()
    }
}
