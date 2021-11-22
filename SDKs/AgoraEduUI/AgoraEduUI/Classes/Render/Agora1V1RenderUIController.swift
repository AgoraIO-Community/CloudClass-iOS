//
//  Agora1V1RenderUIController.swift
//  AgoraEduUI
//
//  Created by SRS on 2021/4/18.
//

import AgoraUIEduBaseViews
import AgoraUIBaseViews
import AgoraEduContext

class Agora1V1RenderUIController: AgoraRenderUIController {
    
    private var teacherInfo: AgoraEduContextUserDetailInfo? {
        didSet {
            updateUserView(teacherView,
                           oldUserInfo: oldValue,
                           newUserInfo: teacherInfo)
        }
    }
    
    private var studentInfo: AgoraEduContextUserDetailInfo? {
        didSet {
            updateUserView(studentView,
                           oldUserInfo: oldValue,
                           newUserInfo: studentInfo)
        }
    }
    
    private var teacherView = AgoraUIUserView(frame: .zero)
    private var studentView = AgoraUIUserView(frame: .zero)
    private let teacherIndex = 0
    private let studentIndex = 1
    private var lastLocalStream: AgoraEduContextStream?
    
    override init(viewType: AgoraEduContextRoomType,
                  contextPool: AgoraEduContextPool) {
        super.init(viewType: viewType,
                   contextPool: contextPool)
        containerView.delegate = self
        contextPool.stream.registerStreamEventHandler(self)
        initViews()
    }
    
    func updateRenderView(fullScreen: Bool) {
        // render video stream
        if fullScreen {
            if let info = teacherInfo {
                unrenderVideoStream(from: info,
                                    on: teacherView.videoCanvas)
            }
            
            if let info = studentInfo {
                unrenderVideoStream(from: info,
                                    on: studentView.videoCanvas)
            }
        } else  {
            if let info = teacherInfo {
                renderVideoStream(from: info,
                                  on: teacherView.videoCanvas)
            }
            
            if let info = studentInfo {
                renderVideoStream(from: info,
                                  on: studentView.videoCanvas)
            }
        }
        
        // view hide
        if fullScreen {
            self.studentView.alpha = 1
            self.teacherView.alpha = 1
            UIView.animate(withDuration: TimeInterval.agora_animation) {
                self.studentView.alpha = 0
                self.teacherView.alpha = 0
            }
        } else {
            self.studentView.alpha = 0
            self.teacherView.alpha = 0
            UIView.animate(withDuration: TimeInterval.agora_animation) {
                self.studentView.alpha = 1
                self.teacherView.alpha = 1
            }
        }
    }
}

// MARK: - Private
private extension Agora1V1RenderUIController {
    func initViews() {
        teacherView.index = teacherIndex
        studentView.index = studentIndex
        
        containerView.backgroundColor = .clear
        containerView.addSubview(teacherView)
        containerView.addSubview(studentView)
    }

    func initLayout() {
        let width = containerView.bounds.width
        let height = AgoraKitDeviceAssistant.OS.isPad ?  (containerView.bounds.height - 2)/2 : width
        
        containerView.layoutIfNeeded()
        
        teacherView.agora_y = 0
        teacherView.agora_right = 0
        teacherView.agora_width = width
        teacherView.agora_height = height
        
        let isPad = AgoraKitDeviceAssistant.OS.isPad
        let ViewTopGap: CGFloat = 2
        
        studentView.agora_bottom = 0
        studentView.agora_right = teacherView.agora_right
        studentView.agora_width = width
        studentView.agora_height = height
    }
    
    func updateRenderItemsFromUserList(_ list: [AgoraEduContextUserDetailInfo]) {
        var newTeacherInfo: AgoraEduContextUserDetailInfo? = nil
        var newStudentInfo: AgoraEduContextUserDetailInfo? = nil

        for info in list {
            switch info.role {
            case .teacher:
                newTeacherInfo = info
            case .student:
                newStudentInfo = info
            default:
                continue
            }

            teacherInfo = newTeacherInfo
            studentInfo = newStudentInfo
        }
    }
}

// MARK: - AgoraEduUserHandler
extension Agora1V1RenderUIController: AgoraEduUserHandler {
    // 更新人员信息列表，只显示在线人员信息
    public func onUpdateUserList(_ list: [AgoraEduContextUserDetailInfo]) {
        updateRenderItemsFromUserList(list)
    }
    
    // 自己被踢出
    public func onKickedOut() {
        let buttonLabel = AgoraAlertLabelModel()
        buttonLabel.text = AgoraKitLocalizedString("SureText")
        
        let buttonModel = AgoraAlertButtonModel()
        buttonModel.titleLabel = buttonLabel
        buttonModel.tapActionBlock = { [weak self] (index) -> Void in
            self?.roomContext?.leaveRoom()
        }
        
        AgoraUtils.showAlert(imageModel: nil,
                             title: AgoraKitLocalizedString("KickOutNoticeText"),
                             message: AgoraKitLocalizedString("KickOutText"),
                             btnModels: [buttonModel])
    }
    
    // 音量提示
    public func onUpdateAudioVolumeIndication(_ value: Int,
                                              streamUuid: String) {
        guard let `streamContext` = streamContext else {
            return
        }
        
        if let info = teacherInfo,
           let streams = streamContext.getStreamsInfo(userUuid: info.userUuid),
           let stream = streams.first,
           stream.streamUuid == streamUuid,
           stream.streamType.hasAudio {
            teacherView.updateAudio(effect: value)
        }

        if let info = studentInfo,
           let streams = streamContext.getStreamsInfo(userUuid: info.userUuid),
           let stream = streams.first,
           stream.streamUuid == streamUuid,
           stream.streamType.hasAudio {
            studentView.updateAudio(effect: value)
        }
    }
}

extension Agora1V1RenderUIController: AgoraEduStreamHandler {
    func onStreamJoin(stream: AgoraEduContextStream,
                      operator: AgoraEduContextUserInfo?) {
        guard let `userContext` = userContext else {
            return
        }
        
        let localUser = userContext.getLocalUserInfo()
        
        if localUser == stream.owner {
            lastLocalStream = stream
        }
        
        let list = userContext.getUserInfoList()
        updateRenderItemsFromUserList(list)
    }
    
    func onStreamLeave(stream: AgoraEduContextStream,
                       operator: AgoraEduContextUserInfo?) {
        guard let `userContext` = userContext else {
            return
        }
        
        let localUser = userContext.getLocalUserInfo()
        
        if localUser == stream.owner {
            lastLocalStream = stream
        }
        
        let list = userContext.getUserInfoList()
        updateRenderItemsFromUserList(list)
    }
    
    func onStreamUpdate(stream: AgoraEduContextStream,
                        operator: AgoraEduContextUserInfo?) {
        guard let `userContext` = userContext else {
            return
        }
        
        let list = userContext.getUserInfoList()
        updateRenderItemsFromUserList(list)
        
        defer {
            let localUser = userContext.getLocalUserInfo()
            
            if localUser == stream.owner {
                lastLocalStream = stream
            }
        }
        
        guard let `operator` = `operator` else {
            return
        }
        
        let localUser = userContext.getLocalUserInfo()
        
        guard localUser == stream.owner,
              localUser != `operator`,
              let lastStream = lastLocalStream else {
            return
        }
        
        if lastStream.streamType.hasVideo != stream.streamType.hasVideo {
            let text = AgoraUILocalizedString(stream.streamType.hasVideo ? "CameraUnMuteText" : "CameraMuteText",
                                              object: self)
            AgoraToast.toast(msg: text)
        }
        
        if lastStream.streamType.hasAudio != stream.streamType.hasAudio {
            let text = AgoraUILocalizedString(stream.streamType.hasVideo ? "MicrophoneUnMuteText" : "MicrophoneMuteText",
                                              object: self)
            AgoraToast.toast(msg: text)
        }
    }
}

extension Agora1V1RenderUIController: AgoraUIControllerContainerDelegate {
    func containerLayoutSubviews() {
        initLayout()
    }
}
