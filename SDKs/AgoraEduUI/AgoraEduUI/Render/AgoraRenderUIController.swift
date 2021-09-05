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
    
    var roomContext: AgoraEduRoomContext? {
        return contextProvider?.controllerNeedRoomContext()
    }
    
    var mediaContext: AgoraEduMediaContext? {
        return contextProvider?.controllerNeedMediaContext()
    }
    
    var userContext: AgoraEduUserContext? {
        return contextProvider?.controllerNeedUserContext()
    }
    
    private weak var contextProvider: AgoraControllerContextProvider?
    
    var containerView = AgoraUIControllerContainer(frame: .zero)
    
    var isCoHost = false {
        didSet {
            guard oldValue != isCoHost,
                  !isCoHost else {
                return
            }
            
            let text = AgoraUILocalizedString("RemovedCoHostText",
                                              object: self)
            
            AgoraUtils.showToast(message: text)
        }
    }
    
    init(viewType: AgoraEduContextRoomType,
         contextProvider: AgoraControllerContextProvider) {
        self.viewType = viewType
        self.contextProvider = contextProvider
    }
    
    func updateUserView(_ view: AgoraUIUserView,
                        oldUserInfo: AgoraEduContextUserDetailInfo? = nil,
                        newUserInfo: AgoraEduContextUserDetailInfo? = nil) {
        
        if let userInfo = newUserInfo {
            if userInfo.onLine {
                view.updateCameraState(userInfo.cameraState.uiType,
                                       hasStream: userInfo.enableVideo)
                
                view.updateMicState(userInfo.microState.uiType,
                                    hasStream: userInfo.enableAudio,
                                    isLocal: userInfo.isSelf)
            } else {
                view.updateDefaultDeviceState()
            }
            
            
            
            view.whiteBoardImageView.isHidden = !userInfo.boardGranted
            view.updateUserReward(count: userInfo.rewardCount)
            view.updateUserName(name: userInfo.user.userName)
        } else {
            view.updateDefaultDeviceState()
            view.whiteBoardImageView.isHidden = true
            view.updateUserName(name: "")
        }
        
        if let info = newUserInfo,
           info.enableVideo {
            renderVideoStream(info.streamUuid,
                              on: view.videoCanvas)
        } else if let info = oldUserInfo {
            unrenderVideoStream(info.streamUuid,
                                on: view.videoCanvas)
        }
    }

    func renderVideoStream(_ streamUuid: String,
                           on view: AgoraUIVideoCanvas) {
        if let canvasStreamUuid = view.renderingStreamUuid,
           canvasStreamUuid == streamUuid {
            return
        }
        
        view.renderingStreamUuid = streamUuid
        userContext?.renderView(view,
                                streamUuid: streamUuid)
    }
    
    func unrenderVideoStream(_ streamUuid: String,
                             on view: AgoraUIVideoCanvas) {
        guard let _ = view.renderingStreamUuid else {
            return
        }
        
        view.renderingStreamUuid = nil
        userContext?.renderView(nil,
                                streamUuid: streamUuid)
    }
}

class AgoraRenderListItem: NSObject {
    var userInfo: AgoraEduContextUserDetailInfo
    var volume: Int = 0

    init(userInfo: AgoraEduContextUserDetailInfo,
         volume: Int) {
        self.userInfo = userInfo
        self.volume = volume
    }
}

extension AgoraEduContextDeviceState {
    var uiType: AgoraUIUserView.DeviceState {
        switch self {
        case .available:    return .available
        case .notAvailable: return .invalid
        case .close:        return .close
        }
    }
}
