//
//  AgoraSmallRenderUIController+EventHandler.swift
//  AgoraEduUI
//
//  Created by Cavan on 2021/4/22.
//

import AgoraEduContext
import AgoraUIBaseViews
import AgoraUIEduBaseViews

// MARK: - AgoraEduUserHandler
extension AgoraSmallRenderUIController: AgoraEduUserHandler {
    func onRemoteUserJoined(user: AgoraEduContextUserInfo) {
        if user.role == .teacher {
            teacherInfo = user
        }
        delegate?.renderSmallController(self,
                                        didUpdateTeacherIn: teacherInfo != nil)
        updateLayout()
        
        if user.isCoHost {
            updateCoHosts()
            updateLayout()
        }
    }
    
    func onRemoteUserLeft(user: AgoraEduContextUserInfo,
                          operator: AgoraEduContextUserInfo?,
                          reason: AgoraEduContextUserLeaveReason) {
        if user.role == .teacher {
            teacherInfo = nil
        }
        if user.isCoHost {
            updateCoHosts()
            updateLayout()
        }
    }
    
    func onUserHandsWave(fromUser: AgoraEduContextUserInfo,
                         duration: Int) {
        // TODO: waving handle
    }
    
    func onUserUpdated(user: AgoraEduContextUserInfo,
                       operator: AgoraEduContextUserInfo?) {
        if user.role == .teacher {
            teacherInfo = user
        }
        if user.isCoHost {
            updateCoHosts()
            updateLayout()
        }
    }
    
    // 自己被踢出
    public func onLocalUserKickedOut() {
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
    
    func onUserRewarded(user: AgoraEduContextUserInfo,
                        rewardCount: Int,
                        operator: AgoraEduContextUserInfo) {
        rewardAnimation()
    }
}

extension AgoraSmallRenderUIController: AgoraEduMediaHandler {
    func onVolumeUpdated(volume: Int,
                         streamUuid: String) {
        //        if let info = teacherInfo,
        //           info.streamUuid == streamUuid {
        //            teacherView.updateAudio(effect: value)
        //        } else {
        //            updateCoHostVolumeIndication(value,
        //                                         streamUuid: streamUuid)
        //        }
    }
    
    func onLocalDeviceStateUpdated(device: AgoraEduContextDeviceInfo,
                                   state: AgoraEduContextDeviceState) {
        
    }
}
