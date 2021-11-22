//
//  AgoraLectureRenderUIController+EventHandler.swift
//  AgoraUIEduAppViews
//
//  Created by Cavan on 2021/4/22.
//

import AgoraEduContext
import AgoraUIBaseViews
import AgoraUIEduBaseViews

// MARK: - AgoraEduUserHandler
extension AgoraLectureRenderUIController: AgoraEduUserHandler {
    // 更新人员信息列表，只显示在线人员信息
    public func onUpdateUserList(_ list: [AgoraEduContextUserDetailInfo]) {
        if let kitUserInfo = list.first(where: { $0.role == .teacher }) {
            teacherInfo = kitUserInfo
        } else {
            teacherInfo = nil
        }
    }
    
    // 更新人员信息列表，只显示台上人员信息。（台上会包含不在线的）
    public func onUpdateCoHostList(_ list: [AgoraEduContextUserDetailInfo]) {
        updateCoHosts(with: list)
    }
    
    // 自己被踢出
    public func onKickedOut() {
        let btnLabel = AgoraAlertLabelModel()
        btnLabel.text = AgoraKitLocalizedString("SureText")
        let btnModel = AgoraAlertButtonModel()
        
        btnModel.titleLabel = btnLabel
        btnModel.tapActionBlock = { [weak self] (index) -> Void in
            self?.roomContext?.leaveRoom()
        }
        
        AgoraUtils.showAlert(imageModel: nil,
                             title: AgoraKitLocalizedString("KickOutNoticeText"),
                             message: AgoraKitLocalizedString("KickOutText"),
                             btnModels: [btnModel])
    }
    
    // 音量提示
    public func onUpdateAudioVolumeIndication(_ value: Int,
                                              streamUuid: String) {
//        if let info = teacherInfo,
//           info.streamUuid == streamUuid {
//            teacherView.updateAudio(effect: value)
//        } else {
//            updateCoHostVolumeIndication(value,
//                                         streamUuid: streamUuid)
//        }
    }
    
    /* 显示提示信息
     * 你的摄像头被关闭了
     * 你的麦克风被关闭了
     * 你的摄像头被打开了
     * 你的麦克风被打开了
     */
    public func onShowUserTips(_ message: String) {
        AgoraToast.toast(msg: message)
    }
    
    public func onStreamUpdated(_ streamType: EduContextMediaStreamType,
                                fromUser: AgoraEduContextUserDetailInfo,
                                operator: AgoraEduContextUserInfo?) {
        guard fromUser.isLocal else {
            return
        }
//
//        switch streamType {
//        case .video:
//            let text = AgoraUILocalizedString(fromUser.enableVideo ? "CameraUnMuteText" : "CameraMuteText",
//                                              object: self)
//            AgoraToast.toast(msg: text)
//        case .audio:
//            let text = AgoraUILocalizedString(fromUser.enableAudio ? "MicrophoneUnMuteText" : "MicrophoneMuteText",
//                                              object: self)
//            AgoraToast.toast(msg: text)
//        default:
//            break
//        }
    }
    
    // 收到奖励（自己或者其他学生）
    public func onShowUserReward(_ user: AgoraEduContextUserInfo) {
        rewardAnimation()
    }
}
