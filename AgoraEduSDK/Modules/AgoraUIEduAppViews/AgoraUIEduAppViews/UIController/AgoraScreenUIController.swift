//
//  AgoraScreenUIController.swift
//  AgoraUIEduAppViews
//
//  Created by SRS on 2021/4/18.
//

import UIKit
import AgoraUIEduBaseViews
import AgoraUIBaseViews
import AgoraEduContext

protocol AgoraScreenUIControllerDelegate: NSObjectProtocol {
    func screenController(_ controller: AgoraScreenUIController,
                         didUpdateState state: AgoraEduContextScreenShareState)
    func screenController(_ controller: AgoraScreenUIController,
                         didSelectScreen selected: Bool)
}

class AgoraScreenUIController: NSObject, AgoraUIController {
    private var context: AgoraEduUserContext? {
        return contextProvider?.controllerNeedUserContext()
    }
    
    private let screenView = AgoraBaseUIView(frame: .zero)

    private(set) var viewType: AgoraEduContextAppType
    private weak var delegate: AgoraScreenUIControllerDelegate?
    private weak var contextProvider: AgoraControllerContextProvider?
    private weak var eventRegister: AgoraControllerEventRegister?
    
    var containerView = AgoraUIControllerContainer(frame: .zero)
    
    init(viewType: AgoraEduContextAppType,
         delegate: AgoraScreenUIControllerDelegate,
         contextProvider: AgoraControllerContextProvider,
         eventRegister: AgoraControllerEventRegister) {
        self.viewType = viewType
        self.delegate = delegate
        self.contextProvider = contextProvider
        self.eventRegister = eventRegister
        
        super.init()
        initViews()
        initLayout()
        observeEvent(register: eventRegister)
    }
    
    private func initViews() {
        containerView.backgroundColor = .clear
        containerView.addSubview(screenView)
        containerView.isHidden = true
    }

    private func initLayout() {
        screenView.agora_x = 0
        screenView.agora_y = 0
        screenView.agora_right = 0
        screenView.agora_bottom = 0
    }
    
    private func observeEvent(register: AgoraControllerEventRegister) {
        register.controllerRegisterScreenEvent(self)
    }
}

// MARK: - AgoraEduScreenShareHandler
extension AgoraScreenUIController: AgoraEduScreenShareHandler {
    // 开启或者关闭屏幕分享
    func onUpdateScreenShareState(_ state: AgoraEduContextScreenShareState, streamUuid: String) {
        
        self.delegate?.screenController(self, didUpdateState: state)
        
        if state != .stop {
            containerView.isHidden = false
            context?.renderView(screenView,
                                streamUuid: streamUuid)
        } else {
            containerView.isHidden = true
            context?.renderView(nil,
                                streamUuid: streamUuid)
        }
    }
    func onSelectScreenShare(_ selected: Bool) {
        containerView.isHidden = !selected

        self.delegate?.screenController(self, didSelectScreen: selected)
    }

    /* 屏幕分享相关消息
     * XXX开启了屏幕分享
     * XXX关闭了屏幕分享
     */
    func onShowScreenShareTips(_ message: String) {
        AgoraUtils.showToast(message: message)
    }
}
