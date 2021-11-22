//
//  AgoraPrivateChatController.swift
//  AgoraEduUI
//
//  Created by SRS on 2021/4/18.
//

import AgoraUIEduBaseViews
import AgoraUIBaseViews
import AgoraEduContext

class AgoraPrivateChatController: NSObject, AgoraController {
    private(set) var viewType: AgoraEduContextRoomType
    private weak var contextProvider: AgoraControllerContextProvider?
    
    init(viewType: AgoraEduContextRoomType,
         contextProvider: AgoraControllerContextProvider) {

        self.viewType = viewType
        self.contextProvider = contextProvider
        super.init()
    }
}

// MARK: - AgoraEduPrivateChatHandler
extension AgoraPrivateChatController: AgoraEduPrivateChatHandler {
    // 收到开始私密语音通知
    func onStartPrivateChat(_ info: AgoraEduContextPrivateChatInfo) {
        AgoraToast.toast(msg: "\(info.fromUser.userName) 和 \(info.toUser.userName) onStartPrivateChat")
    }
    // 收到结束私密语音通知
    func onEndPrivateChat() {
        AgoraToast.toast(msg: "onEndPrivateChat")
    }
}
