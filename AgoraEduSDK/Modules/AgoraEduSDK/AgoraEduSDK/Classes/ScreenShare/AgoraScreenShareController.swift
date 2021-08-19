//
//  AgoraScreenShareController.swift
//  AgoraEduSDK
//
//  Created by SRS on 2021/5/7.
//  Copyright © 2021 Agora. All rights reserved.
//

import Foundation
import EduSDK
import AgoraUIBaseViews
import AgoraUIEduBaseViews
import AgoraEduContext

//@objc public protocol AgoraScreenShareControllerDelegate: NSObjectProtocol {
//    func screenShareController(_ controller: AgoraScreenShareController,
//                         didOccurError error: AgoraEduContextError)
//}

@objcMembers public class AgoraScreenShareController: NSObject, AgoraController {
    
    public var vm: AgoraScreenShareVM?

    private var eventDispatcher: AgoraUIEventDispatcher = AgoraUIEventDispatcher()

    public init(vmConfig: AgoraVMConfig) {
        self.vm = AgoraScreenShareVM(config: vmConfig)
        self.eventDispatcher = AgoraUIEventDispatcher()
        
        super.init()
    }
    
    //
    public func updateScenePath(_ path: String) {
//        self.vm?.updateScenePath(path, successBlock: { [weak self] (screenShareState, screenStreamUuid) in
//            self?.handleScreenShareState(screenShareState, screenStreamUuid)
//        }, failureBlock: nil)
    }
    
    //
    public func updateScreenSelectedProperties(_ cause: Any?) {
//        self.vm?.screenSelectChanged(cause: cause, successBlock: { [weak self] (screenShareState, screenStreamUuid) in
//            self?.handleScreenShareState(screenShareState, screenStreamUuid)
//        }, failureBlock: nil)
    }

    public func updateStreams(_ rteStreams: [AgoraRTEStream], changeType: AgoraInfoChangeType) {
        let screenStreamInfos = self.vm?.getUpdateScreenStreamInfos(rteStreams: rteStreams) ?? [String:String]()
        if screenStreamInfos.count > 0 {
            self.vm?.updateScreenShareState(successBlock: { [weak self] (screenShareState, screenStreamUuid) in
                self?.handleScreenShareState(screenShareState, screenStreamInfos.keys.first)
                
//                let parameters = "{\"che.video.render_background_color\":{\"uid\":\(screenStreamUuid), \"r\":\(1), \"g\":\(1), \"b\":\(1)}}"
//                AgoraRTCManager.share().setParameters(parameters)
            }, failureBlock: nil)
        }
    }

    public func updateStreamEvents(_ rteStreamEvents: [AgoraRTEStreamEvent], changeType: AgoraInfoChangeType) {
        let screenStreamInfos = self.vm?.getUpdateScreenStreamInfos(rteStreamEvents: rteStreamEvents) ?? [String:String]()
        if screenStreamInfos.count > 0 {
            let sharing = changeType == .remove ? false : true
            let userName = screenStreamInfos.values.first ?? ""
            
            if let msg = self.vm?.getScreenTipMessage(userName, sharing: sharing) {
                self.eventDispatcher.onShowScreenShareTips(msg)
            }
            
            self.vm?.updateScreenShareState(successBlock: { [weak self] (screenShareState, screenStreamUuid) in
                self?.handleScreenShareState(screenShareState, screenStreamInfos.keys.first)
            }, failureBlock: nil)
        }
    }
 
    public func rtcStreamChanged(_ streamUuid: String, rtcState: AgoraScreenShareRTCState) {
        
        self.vm?.rtcStreamChanged(streamUuid, rtcState: rtcState, successBlock: { [weak self] (shareState, screenStreamUuid) in
            self?.handleScreenShareState(shareState, streamUuid)
        }, failureBlock:nil)
    }
    
    private func handleScreenShareState(_ shareState: AgoraScreenShareState, _ screenStreamUuid: String? = nil) {
        
        if screenStreamUuid == nil && (shareState == .start || shareState == .stop || shareState == .pause) {
            return
        }
        
        switch shareState {
        case .start:
            self.eventDispatcher.onUpdateScreenShareState(AgoraEduContextScreenShareState.start,
                                                          streamUuid: screenStreamUuid!)
        case .stop:
            self.eventDispatcher.onUpdateScreenShareState(AgoraEduContextScreenShareState.stop,
                                                           streamUuid: screenStreamUuid!)
        case .pause:
            self.eventDispatcher.onUpdateScreenShareState(AgoraEduContextScreenShareState.pause,
                                                           streamUuid: screenStreamUuid!)
        case .selected:
            self.eventDispatcher.onSelectedScreenShareState(true)
        case .unSelected:
            self.eventDispatcher.onSelectedScreenShareState(false)
        }
    }
}

// MARK: - Life cycle
extension AgoraScreenShareController {
    public func viewWillAppear() {
    }
    
    public func viewDidLoad() {
    }
    
    public func viewDidAppear() {
    }
    
    public func viewWillDisappear() {
    }
    
    public func viewDidDisappear() {
    }
}

extension AgoraScreenShareController: AgoraEduScreenShareContext {
    // 事件监听
    public func registerEventHandler(_ handler: AgoraEduScreenShareHandler) {
        eventDispatcher.register(event: .shareScreen(object: handler))
    }
}
