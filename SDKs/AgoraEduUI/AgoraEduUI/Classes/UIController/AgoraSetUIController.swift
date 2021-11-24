//
//  AgoraSetUIController.swift
//  AgoraEduUI
//
//  Created by SRS on 2021/5/17.
//

import AgoraUIEduBaseViews
import AgoraUIBaseViews
import AgoraEduContext

class AgoraSetUIController: NSObject, AgoraUIController {
    private var toastShowedStates: [String] = []
    // Contexts
    private weak var mediaContext: AgoraEduMediaContext? {
        return context?.media
    }
    
    private weak var userContext: AgoraEduUserContext? {
        return context?.user
    }
    
    private weak var roomContext: AgoraEduRoomContext? {
        return context?.room
    }
    
    private weak var streamContext: AgoraEduStreamContext? {
        return context?.stream
    }

    private weak var context: AgoraEduContextPool?
    
    private let setView = AgoraUISettingView(frame: .zero)
    
    var containerView = AgoraUIControllerContainer(frame: .zero)
    var localUser: AgoraEduContextUserDetailInfo?
    
    public init(context: AgoraEduContextPool) {
        self.context = context
        
        super.init()
        initViews()
        initLayout()
        observeEvent()
        observeUI()
    }
}

private extension AgoraSetUIController {
    func initViews() {
        containerView.backgroundColor = .clear
        containerView.addSubview(setView)
    }
    
    func initLayout() {
        setView.agora_x = 0
        setView.agora_y = 0
        setView.agora_right = 0
        setView.agora_bottom = 0
    }

    func observeEvent() {
        streamContext?.registerStreamEventHandler(self)
        roomContext?.registerEventHandler(self)
    }
    
    func observeUI() {
        setView.leaveClassBlock = { [unowned self] in
            self.exitClassAlert()
            self.containerView.removeFromSuperview()
        }
        
        setView.cameraStateBlock = { [unowned self] (open: Bool) in
            guard let local = self.localUser else {
                return
            }
            
           
        }
        
        setView.micStateBlock = { [unowned self] (open: Bool) in
            guard let local = self.localUser else {
                return
            }
            
            
        }
        
        setView.speakerStateBlock = { [unowned self] (open: Bool) in
            
        }
        
        setView.switchCameraBlock = { [unowned self] in
            
        }
    }
    
    func updateView(from stream: AgoraEduContextStream) {
        guard let context = userContext else {
            fatalError()
            return
        }
        
        guard stream.owner == context.getLocalUserInfo() else {
            return
        }
        
        setView.updateCameraState(stream.videoSourceType.isOpen)
        setView.updateMicroState(stream.audioSourceType.isOpen)
    }
}

extension AgoraSetUIController: AgoraEduStreamHandler {
    @objc func onStreamJoin(stream: AgoraEduContextStream,
                            operator: AgoraEduContextUserInfo?) {
        updateView(from: stream)
    }
    
    @objc func onStreamLeave(stream: AgoraEduContextStream,
                             operator: AgoraEduContextUserInfo?) {
        updateView(from: stream)
    }
    
    @objc func onStreamUpdate(stream: AgoraEduContextStream,
                              operator: AgoraEduContextUserInfo?) {
        updateView(from: stream)
    }
}

extension AgoraSetUIController: AgoraEduRoomHandler {
    @objc func onClassroomJoined() {
        guard let `userContext` = userContext,
              let `streamContext` = streamContext else {
            return
        }
        
        let localUser = userContext.getLocalUserInfo()
        
        guard let streams = streamContext.getStreamsInfo(userUuid: localUser.userUuid),
              let stream = streams.first else {
            return
        }
        
        updateView(from: stream)
    }
}

extension AgoraSetUIController: AgoraEduUserHandler {
    func onUpdateUserList(_ list: [AgoraEduContextUserDetailInfo]) {
        for user in list where user.isLocal == true {
            localUser = user
        }
    }
}

private extension AgoraSetUIController {
    func exitClassAlert() {
        let leftButtonLabel = AgoraAlertLabelModel()
        leftButtonLabel.text = AgoraKitLocalizedString("CancelText")
        
        let leftButton = AgoraAlertButtonModel()
        leftButton.titleLabel = leftButtonLabel
        
        let rightButtonLabel = AgoraAlertLabelModel()
        rightButtonLabel.text = AgoraKitLocalizedString("SureText")
        
        let rightButton = AgoraAlertButtonModel()
        rightButton.titleLabel = rightButtonLabel
        rightButton.tapActionBlock = { [unowned self] (index) -> Void in
            self.roomContext?.leaveRoom()
        }
        
        AgoraUtils.showAlert(imageModel: nil,
                             title: AgoraKitLocalizedString("LeaveClassTitleText"),
                             message: AgoraKitLocalizedString("LeaveClassText"),
                             btnModels: [leftButton, rightButton])
    }
}
