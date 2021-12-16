//
//  AgoraScreenSharingUIController.swift
//  AgoraEduUI
//
//  Created by Cavan on 2021/12/9.
//

import AgoraEduContext
import UIKit

class AgoraScreenSharingUIController: UIViewController {
    private var isScreenSharing: Bool = false {
        didSet {
            view.isHidden = !isScreenSharing
        }
    }
    
    /** SDK环境*/
    var contextPool: AgoraEduContextPool!
    
    init(context: AgoraEduContextPool) {
        super.init(nibName: nil, bundle: nil)
        contextPool = context
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.isHidden = true
        
        contextPool.room.registerRoomEventHandler(self)
        contextPool.stream.registerStreamEventHandler(self)
        
        initScreenSharing()
    }
    
    private func startRender(stream: AgoraEduContextStreamInfo) {
        guard stream.videoSourceType == .screen,
              isScreenSharing == false else {
            return
        }
        
        let mediaContext = contextPool.media
        
        let renderConfig = AgoraEduContextRenderConfig()
        renderConfig.mode = .fit //1559292209
        
        mediaContext.startRenderVideo(view: view,
                                      renderConfig: renderConfig,
                                      streamUuid: stream.streamUuid)
        
        isScreenSharing = true
    }
    
    private func stopRender(stream: AgoraEduContextStreamInfo) {
        guard stream.videoSourceType == .screen else {
            return
        }
        
        let mediaContext = contextPool.media
        mediaContext.stopRenderVideo(streamUuid: stream.streamUuid)
        
        isScreenSharing = false
    }
    
    private func initScreenSharing() {
        let streamContext = contextPool.stream
        
        guard let list = streamContext.getAllStreamList() else {
            return
        }
        
        for stream in list where stream.videoSourceType == .screen {
            startRender(stream: stream)
        }
    }
}

extension AgoraScreenSharingUIController: AgoraEduRoomHandler {
    func onRoomJoinedSuccess(roomInfo: AgoraEduContextRoomInfo) {
        initScreenSharing()
    }
}

extension AgoraScreenSharingUIController: AgoraEduStreamHandler {
    func onStreamJoined(stream: AgoraEduContextStreamInfo,
                        operatorUser: AgoraEduContextUserInfo?) {
        startRender(stream: stream)
    }
    
    func onStreamLeft(stream: AgoraEduContextStreamInfo,
                      operatorUser: AgoraEduContextUserInfo?) {
       stopRender(stream: stream)
    }
    
    func onStreamUpdated(stream: AgoraEduContextStreamInfo,
                         operatorUser: AgoraEduContextUserInfo?) {
        startRender(stream: stream)
    }
}
