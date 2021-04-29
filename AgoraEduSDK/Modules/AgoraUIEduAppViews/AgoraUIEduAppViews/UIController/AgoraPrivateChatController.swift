//
//  AgoraPrivateChatController.swift
//  AgoraUIEduAppViews
//
//  Created by SRS on 2021/4/18.
//

import Foundation
import AgoraUIEduBaseViews
import AgoraUIBaseViews
import AgoraEduContext

class AgoraPrivateChatController: NSObject, AgoraController {

    private(set) var viewType: AgoraEduContextAppType
    private weak var contextProvider: AgoraControllerContextProvider?
    private weak var eventRegister: AgoraControllerEventRegister?
    
    init(viewType: AgoraEduContextAppType,
         contextProvider: AgoraControllerContextProvider,
         eventRegister: AgoraControllerEventRegister) {

        self.viewType = viewType
        self.contextProvider = contextProvider
        self.eventRegister = eventRegister
        
        super.init()
        initData()
    }
    
    private func initData() {
        self.eventRegister?.controllerRegisterPrivateChatEvent(self)
    }
}

// MARK: - AgoraEduPrivateChatHandler
extension AgoraPrivateChatController: AgoraEduPrivateChatHandler {
    // 收到开始私密语音通知
    func onStartPrivateChat(_ info: AgoraEduContextPrivateChatInfo) {
        AgoraUtils.showToast(message: "\(info.fromUser.userName) 和 \(info.toUser.userName) onStartPrivateChat")
    }
    // 收到结束私密语音通知
    func onEndPrivateChat() {
        AgoraUtils.showToast(message: "onEndPrivateChat")
    }
}
