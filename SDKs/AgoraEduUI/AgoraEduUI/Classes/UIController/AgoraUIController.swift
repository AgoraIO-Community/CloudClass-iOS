//
//  AgoraUIController.swift
//  AgoraEduUI
//
//  Created by Cavan on 2021/4/17.
//

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

protocol AgoraControllerContextProvider: NSObjectProtocol {
    func controllerNeedWhiteBoardContext() -> AgoraEduWhiteBoardContext
    func controllerNeedWhiteBoardToolContext() -> AgoraEduWhiteBoardToolContext
    func controllerNeedWhiteBoardPageControlContext() -> AgoraEduWhiteBoardPageControlContext
    
    func controllerNeedRoomContext() -> AgoraEduRoomContext
    
    func controllerNeedUserContext() -> AgoraEduUserContext
    
    func controllerNeedExtAppContext() -> AgoraEduExtAppContext
    func controllerNeedMediaContext() -> AgoraEduMediaContext
    func controllerNeedMonitorContext() -> AgoraEduMonitorContext
}

protocol AgoraControllerEventRegister: NSObjectProtocol {
    func controllerRegisterWhiteBoardEvent(_ handler: AgoraEduWhiteBoardHandler)
    func controllerRegisterWhiteBoardPageControlEvent(_ handler: AgoraEduWhiteBoardPageControlHandler)
    
    func controllerRegisterRoomEvent(_ handler: AgoraEduRoomHandler)
    func controllerRegisterUserEvent(_ handler: AgoraEduUserHandler)
}
