//
//  AgoraRenderUIController.swift
//  AgoraUIEduAppViews
//
//  Created by Cavan on 2021/4/22.
//

import AgoraUIEduBaseViews
import AgoraUIBaseViews
import AgoraEduContext

@objcMembers class AgoraRenderUIController: NSObject, AgoraUIController {
    private(set) var viewType: AgoraEduContextAppType
    
    var roomContext: AgoraEduRoomContext? {
        return contextProvider?.controllerNeedRoomContext()
    }
    
    var userContext: AgoraEduUserContext? {
        return contextProvider?.controllerNeedUserContext()
    }
    
    private weak var contextProvider: AgoraControllerContextProvider?
    private weak var eventRegister: AgoraControllerEventRegister?
    
    var containerView = AgoraUIControllerContainer(frame: .zero)
    
    init(viewType: AgoraEduContextAppType,
         contextProvider: AgoraControllerContextProvider,
         eventRegister: AgoraControllerEventRegister) {
        self.viewType = viewType
        self.contextProvider = contextProvider
        self.eventRegister = eventRegister
    }
    
    func updateUserView(_ view: AgoraUIUserView,
                        oldUserInfo: AgoraEduContextUserDetailInfo? = nil,
                        newUserInfo: AgoraEduContextUserDetailInfo? = nil) {
        view.update(with: newUserInfo)
        
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
