//
//  AgoraUIController.swift
//  AgoraUIEduAppViews
//
//  Created by Cavan on 2021/4/17.
//

import UIKit
import AgoraUIBaseViews
import AgoraEduContext

protocol AgoraUIControllerContainerDelegate: NSObjectProtocol {
    func containerLayoutSubviews()
}

class AgoraUIControllerContainer: AgoraBaseUIView {
    weak var delegate: AgoraUIControllerContainerDelegate?
    
    override func layoutSubviews() {
        super.layoutSubviews()
        delegate?.containerLayoutSubviews()
    }
}

protocol AgoraController where Self: NSObject {
//    func observeEvent(register: AgoraControllerEventRegister)
}

protocol AgoraUIController: AgoraController {
    associatedtype T: AgoraUIControllerContainer
    var containerView: T {set get}
}

protocol AgoraControllerContextProvider: NSObjectProtocol {
    func controllerNeedWhiteBoardContext() -> AgoraEduWhiteBoardContext
    func controllerNeedWhiteBoardToolContext() -> AgoraEduWhiteBoardToolContext
    func controllerNeedWhiteBoardPageControlContext() -> AgoraEduWhiteBoardPageControlContext
    
    func controllerNeedRoomContext() -> AgoraEduRoomContext
    func controllerNeedDeviceContext() -> AgoraEduDeviceContext
    func controllerNeedChatContext() -> AgoraEduMessageContext
    func controllerNeedUserContext() -> AgoraEduUserContext
    func controllerNeedHandsUpContext() -> AgoraEduHandsUpContext
    func controllerNeedPrivateChatContext() -> AgoraEduPrivateChatContext
    func controllerNeedScreenContext() -> AgoraEduScreenShareContext
    func controllerNeedExtAppContext() -> AgoraEduExtAppContext
}

protocol AgoraControllerEventRegister: NSObjectProtocol {
    func controllerRegisterWhiteBoardEvent(_ handler: AgoraEduWhiteBoardHandler)
    func controllerRegisterWhiteBoardPageControlEvent(_ handler: AgoraEduWhiteBoardPageControlHandler)
    
    func controllerRegisterRoomEvent(_ handler: AgoraEduRoomHandler)
    func controllerRegisterDeviceEvent(_ handler: AgoraEduDeviceHandler)
    func controllerRegisterChatEvent(_ handler: AgoraEduMessageHandler)
    func controllerRegisterPrivateChatEvent(_ handler: AgoraEduPrivateChatHandler)
    func controllerRegisterUserEvent(_ handler: AgoraEduUserHandler)
    func controllerRegisterHandsUpEvent(_ handler: AgoraEduHandsUpHandler)
    func controllerRegisterScreenEvent(_ handler: AgoraEduScreenShareHandler)
}
