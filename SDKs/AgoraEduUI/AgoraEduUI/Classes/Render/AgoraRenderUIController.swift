//
//  AgoraRenderUIController.swift
//  AgoraEduUI
//
//  Created by Cavan on 2021/4/22.
//

import AgoraUIEduBaseViews
import AgoraUIBaseViews
import AgoraEduContext

@objcMembers class AgoraRenderUIController: NSObject, AgoraUIController {
    private(set) var viewType: AgoraEduContextRoomType
    private weak var contextPool: AgoraEduContextPool?
    
    var roomContext: AgoraEduRoomContext? {
        return contextPool?.room
    }
    
    var mediaContext: AgoraEduMediaContext? {
        return contextPool?.media
    }
    
    var userContext: AgoraEduUserContext? {
        return contextPool?.user
    }
    
    var streamContext: AgoraEduStreamContext? {
        return contextPool?.stream
    }
    
    var containerView = AgoraUIControllerContainer(frame: .zero)
    
    var isCoHost = false {
        didSet {
            guard oldValue != isCoHost,
                  !isCoHost else {
                return
            }
            
            let text = AgoraUILocalizedString("RemovedCoHostText",
                                              object: self)
            
            AgoraToast.toast(msg: text)
        }
    }
    
    init(viewType: AgoraEduContextRoomType,
         contextPool: AgoraEduContextPool) {
        self.viewType = viewType
        self.contextPool = contextPool
    }
    
    func updateUserView(_ view: AgoraUIUserView,
                        oldUserInfo: AgoraEduContextUserDetailInfo? = nil,
                        newUserInfo: AgoraEduContextUserDetailInfo? = nil) {
        guard let `streamContext` = streamContext else {
            return
        }
        
        if let userInfo = newUserInfo,
           let streams = streamContext.getStreamsInfo(userUuid: userInfo.userUuid),
           let stream = streams.first {
            view.updateCameraState(stream.videoSourceType.uiType,
                                   hasStream: stream.streamType.hasAudio)
            
            view.updateMicState(stream.audioSourceType.uiType,
                                hasStream: stream.streamType.hasAudio)
            
            if stream.streamType.hasVideo {
                renderVideoStream(from: userInfo,
                                  on: view.videoCanvas)
            }
            
            view.whiteBoardImageView.isHidden = !userInfo.boardGranted
            view.updateUserReward(count: userInfo.rewardCount)
            view.updateUserName(name: userInfo.userName)
        } else {
            view.updateDefaultDeviceState()
            view.whiteBoardImageView.isHidden = true
            view.updateUserName(name: "")
        }
    }

    func renderVideoStream(from user: AgoraEduContextUserDetailInfo,
                           on view: AgoraUIVideoCanvas) {
        guard let `streamContext` = streamContext,
              let streams = streamContext.getStreamsInfo(userUuid: user.userUuid),
              let stream = streams.first else {
            return
        }
        
        let streamUuid = stream.streamUuid
        let isLocal = user.isLocal
        
        if let canvasStreamUuid = view.renderingStreamUuid,
           canvasStreamUuid == streamUuid {
            return
        }
        
        view.renderingStreamUuid = streamUuid

        let renderConfig = AgoraEduContextRenderConfig()
        renderConfig.mode = .hidden
        renderConfig.mirror = false
        
        streamContext.subscribeVideoStreamLevel(streamUuid: streamUuid,
                                                level: .low)

        if isLocal {
            mediaContext?.startRenderLocalVideo(view: view,
                                                renderConfig: renderConfig,
                                                streamUuid: streamUuid)
        } else {
            mediaContext?.startRenderRemoteVideo(view: view,
                                                 renderConfig: renderConfig,
                                                 streamUuid: streamUuid)
        }
    }
    
    func unrenderVideoStream(from user: AgoraEduContextUserDetailInfo,
                             on view: AgoraUIVideoCanvas) {
        guard let `streamContext` = streamContext,
              let streams = streamContext.getStreamsInfo(userUuid: user.userUuid),
              let stream = streams.first else {
            return
        }
        
        let streamUuid = stream.streamUuid
        let isLocal = user.isLocal
        
        guard let _ = view.renderingStreamUuid else {
            return
        }
        
        view.renderingStreamUuid = nil
        
        if isLocal {
            mediaContext?.stopRenderLocalVideo(streamUuid: streamUuid)
        } else {
            mediaContext?.stopRenderRemoteVideo(streamUuid: streamUuid)
        }
    }
}

class AgoraRenderListItem: NSObject {
    var userInfo: AgoraEduContextUserDetailInfo
    
    var volume: Int = 0 {
        didSet {
            if volume != oldValue {
                self.onUpdateVolume?(volume)
            }
        }
    }
    
    var streamUuid: String = ""
    
    var onUpdateVolume: ((Int) -> Void)?

    init(userInfo: AgoraEduContextUserDetailInfo,
         volume: Int) {
        self.userInfo = userInfo
        self.volume = volume
    }
}
