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
    
    override init(viewType: AgoraEduContextRoomType,
         contextProvider: AgoraControllerContextProvider) {
        super.init(viewType: viewType,
                   contextProvider: contextProvider)
        
        containerView.delegate = self
        
        initViews()
    }
    
    func updateRenderView(fullScreen: Bool) {
        // render video stream
        if fullScreen {
            if let info = teacherInfo {
                unrenderVideoStream(info.streamUuid,
                                    on: teacherView.videoCanvas)
            }
            
            if let info = studentInfo {
                unrenderVideoStream(info.streamUuid,
                                    on: studentView.videoCanvas)
            }
        } else  {
            if let info = teacherInfo {
                renderVideoStream(info.streamUuid,
                                  on: teacherView.videoCanvas)
            }
            
            if let info = studentInfo {
                renderVideoStream(info.streamUuid,
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
}

// MARK: - AgoraEduUserHandler
extension Agora1V1RenderUIController: AgoraEduUserHandler {
    // 更新人员信息列表，只显示在线人员信息
    public func onUpdateUserList(_ list: [AgoraEduContextUserDetailInfo]) {
        var newTeacherInfo: AgoraEduContextUserDetailInfo? = nil
        var newStudentInfo: AgoraEduContextUserDetailInfo? = nil
        
        for info in list {
            switch info.user.role {
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
        if let info = teacherInfo,
           info.streamUuid == streamUuid,
           info.enableAudio {
            teacherView.updateAudio(effect: value)
        }
        
        if let info = studentInfo,
           info.streamUuid == streamUuid,
           info.enableAudio {
            studentView.updateAudio(effect: value)
        }
    }
    /* 显示提示信息
     * 你的摄像头被关闭了
     * 你的麦克风被关闭了
     * 你的摄像头被打开了
     * 你的麦克风被打开了
     */
    public func onShowUserTips(_ message: String) {
        AgoraUtils.showToast(message: message)
    }
    
    func onStreamUpdated(_ streamType: EduContextMediaStreamType,
                         fromUser: AgoraEduContextUserDetailInfo,
                         operator: AgoraEduContextUserInfo?) {
        guard fromUser.isSelf else {
            return
        }
        
        switch streamType {
        case .video:
            let text = AgoraUILocalizedString(fromUser.enableVideo ? "CameraUnMuteText" : "CameraMuteText",
                                              object: self)
            AgoraUtils.showToast(message: text)
        case .audio:
            let text = AgoraUILocalizedString(fromUser.enableAudio ? "MicrophoneUnMuteText" : "MicrophoneMuteText",
                                              object: self)
            AgoraUtils.showToast(message: text)
        default:
            break
        }
    }
}

extension Agora1V1RenderUIController: AgoraUIControllerContainerDelegate {
    func containerLayoutSubviews() {
        initLayout()
    }
}
