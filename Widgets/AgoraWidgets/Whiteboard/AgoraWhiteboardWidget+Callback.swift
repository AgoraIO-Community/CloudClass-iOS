//
//  AgoraWhiteboardWidget+Callback.swift
//  AgoraWidgets
//
//  Created by LYY on 2021/12/7.
//

import Whiteboard
import AgoraUIEduBaseViews

extension AgoraWhiteboardWidget: WhiteRoomCallbackDelegate {
    public func fireRoomStateChanged(_ modifyState: WhiteRoomState!) {
        guard let `room` = room else {
            return
        }
        
        if let memberState = modifyState.memberState {
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
            dt.updateGlobalState(state: state)
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
        
        log(.info,
            log: "Whiteboard phase: \(phase.strValue)")
        if phase == .connected {
            AgoraLoading.hide()
        }
        if phase == .disconnected {
            self.joinWhiteboard()
        }
    }
}

extension AgoraWhiteboardWidget: WhiteCommonCallbackDelegate {
    public func throwError(_ error: Error) {
        log(.error,
            log: error.localizedDescription)
    }
    
    public func logger(_ dict: [AnyHashable : Any]) {
        // {funName: string, message: id} funName 为对应 API 的名称
        log(.info,
            log: dict.description)
    }
}

extension AgoraWhiteboardWidget: WhiteAudioMixerBridgeDelegate {
    public func startAudioMixing(_ filePath: String,
                                 loopback: Bool,
                                 replace: Bool,
                                 cycle: Int) {
        let request = AgoraBoardAudioMixingRequestData(requestType: .start,
                                                       filePath: filePath,
                                                       loopback: loopback,
                                                       replace: replace,
                                                       cycle: cycle)
        sendMessage(signal: .BoardAudioMixingRequest(request))
    }
    
    public func stopAudioMixing() {
        let request = AgoraBoardAudioMixingRequestData(requestType: .stop)
        sendMessage(signal: .BoardAudioMixingRequest(request))
    }
    
    public func setAudioMixingPosition(_ position: Int) {
        let request = AgoraBoardAudioMixingRequestData(requestType: .setPosition,
                                                       position: position)
        sendMessage(signal: .BoardAudioMixingRequest(request))
    }
}

extension AgoraWhiteboardWidget: AGBoardWidgetDTDelegate {
    func onConfigComplete() {
        initCondition.configComplete = true
    }
    
    func onGrantUsersChanged(grantUsers: [String]) {
        log(.info,
            log: "[Whiteboard widget] grant users changed: \(grantUsers)")
        sendMessage(signal: .BoardGrantDataChanged(grantUsers))
    }
    
    func onLocalGrantedChangedForBoardHandle(localGranted: Bool) {
        log(.info,
            log: "[Whiteboard widget] local granted: \(localGranted)")
        
        room?.setViewMode(localGranted ? .freedom : .follower)
        room?.disableDeviceInputs(!localGranted)
        
        if localGranted != dt.localGranted {
            room?.setWritable(localGranted,
                              completionHandler: {[weak self] isWritable, error in
                                guard let `self` = self else {
                                    return
                                }
                                self.dt.localGranted = isWritable
                                if let error = error {
                                    self.log(.error,
                                             log: "[Whiteboard widget] setWritable error: \(error.localizedDescription)")
                                } else {
                                    self.room?.disableCameraTransform(!isWritable)
                                    self.ifUseLocalCameraConfig()
                                    self.room?.setViewMode(isWritable ? .freedom : .follower)
                                }
                              })
        }
    }
    
    func onScenePathChanged(path: String) {
        ifUseLocalCameraConfig()
    }
}
