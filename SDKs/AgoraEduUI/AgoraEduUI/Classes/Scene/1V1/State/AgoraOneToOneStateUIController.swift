//
//  AgoraOneToOneStateUIController.swift
//  AgoraEduUI
//
//  Created by Jonathan on 2021/11/15.
//

import AgoraUIEduBaseViews
import AgoraUIBaseViews
import AgoraEduContext
import Masonry
import UIKit

protocol AgoraOneToOneStateUIControllerDelegate: NSObjectProtocol {
    func onSettingSelected(isSelected: Bool)
}

class AgoraOneToOneStateUIController: UIViewController {
    
    public weak var roomDelegate: AgoraClassRoomManagement?
    
    public weak var delegate: AgoraOneToOneStateUIControllerDelegate?
    
    private var netStateView: UIImageView!
    
    private var titleLabel: UILabel!
    
    private var lineView: UIView!
    
    private var timeLabel: UILabel!
    
    public var settingButton: UIButton!
    /** SDK环境*/
    private var contextPool: AgoraEduContextPool!
    /** 房间计时器*/
    private var timer: Timer?
    /** 房间时间信息*/
    private var timeInfo: AgoraClassTimeInfo?
    
    deinit {
        self.timer?.invalidate()
        self.timer = nil
        print("\(#function): \(self.classForCoder)")
    }
    
    init(context: AgoraEduContextPool) {
        super.init(nibName: nil, bundle: nil)
        contextPool = context
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        createViews()
        createConstrains()
        setup()
        self.timer = Timer.scheduledTimer(withTimeInterval: 1.0,
                                          repeats: true,
                                          block: { [weak self] _ in
            self?.updateTimeVisual()
        })
        contextPool.room.registerRoomEventHandler(self)
        contextPool.monitor.registerMonitorEventHandler(self)
        contextPool.user.registerUserEventHandler(self)
    }
    
    public func deSelect() {
        settingButton.isSelected = false
        settingButton.imageView?.tintColor = UIColor(hex: 0x7B88A0)
        settingButton.backgroundColor = .white
    }
}
// MARK: - Private
extension AgoraOneToOneStateUIController {
    func setup() {
        self.titleLabel.text = self.contextPool.room.getRoomInfo().roomName
        let info = self.contextPool.room.getClassInfo()
        self.timeInfo = AgoraClassTimeInfo(state: info.state,
                                           startTime: info.startTime,
                                           duration: info.duration * 1000,
                                           closeDelay: info.closeDelay * 1000)
    }
    
    func timeString(from interval: Int64) -> String {
        let time = interval > 0 ? (interval / 1000) : 0
        let minuteInt = time / 60
        let secondInt = time % 60
        
        let minuteString = NSString(format: "%02d", minuteInt) as String
        let secondString = NSString(format: "%02d", secondInt) as String

        return "\(minuteString):\(secondString)"
    }
}

// MARK: - Actions
extension AgoraOneToOneStateUIController {
    @objc func onClickSetting(_ sender: UIButton) {
        sender.isSelected = !sender.isSelected
        delegate?.onSettingSelected(isSelected: sender.isSelected)
        if sender.isSelected {
            settingButton.imageView?.tintColor = .white
            settingButton.backgroundColor = UIColor(hex: 0x357BF6)
        } else {
            settingButton.imageView?.tintColor = UIColor(hex: 0x7B88A0)
            settingButton.backgroundColor = .white
        }
    }
    
    func updateTimeVisual() {
        guard let info = self.timeInfo else {
            return
        }
        let realTime = Int64(Date().timeIntervalSince1970 * 1000)
        switch info.state {
        case .before:
            timeLabel.textColor = UIColor(hex: 0x677386)
            if info.startTime == 0 {
                timeLabel.text = "title_before_class".agedu_localized()
            } else {
                let time = info.startTime - realTime
                let text = "ClassBeforeStartText".agedu_localized()
                timeLabel.text = text + timeString(from: time)
            }
        case .after:
            timeLabel.textColor = .red
            let time = realTime - info.startTime
            let text = "ClassAfterStopText".agedu_localized()
            timeLabel.text = text + timeString(from: time)
            // 事件
            let countDown = info.closeDelay + info.duration - time
            if countDown == info.closeDelay {
                let strStart = "ClassCloseWarningStartText".agedu_localized()
                let minNum = Int(info.closeDelay / 60)
                let strMid = "\(minNum)"
                let strMin = "ClassCloseWarningEnd2Text".agedu_localized()
                let strEnd = "ClassCloseWarningEndText".agedu_localized()
                AgoraToast.toast(msg: strStart + strMid + strMin + strEnd)
            } else if countDown == 60 {
                let strStart = "ClassCloseWarningStart2Text".agedu_localized()
                let strMid = "1"
                let strEnd = "ClassCloseWarningEnd2Text".agedu_localized()
                AgoraToast.toast(msg: strStart + strMid + strEnd)
            }
        case .during:
            timeLabel.textColor = UIColor(hex: 0x677386)
            let time = realTime - info.startTime
            let text = "ClassAfterStartText".agedu_localized()
            timeLabel.text = text + timeString(from: time)
            // 事件
            let countDown = info.closeDelay + info.duration - time
            if countDown == 5 * 60 + info.closeDelay {
                let strStart = "ClassEndWarningStartText".agedu_localized()
                let strMid = "5"
                let strEnd = "ClassEndWarningEndText".agedu_localized()
                AgoraToast.toast(msg: strStart + strMid + strEnd)
            }
        }
    }
}

extension AgoraOneToOneStateUIController: AgoraEduRoomHandler {
    
    func onClassStateUpdated(state: AgoraEduContextClassState) {
        let info = self.contextPool.room.getClassInfo()
        self.timeInfo = AgoraClassTimeInfo(state: info.state,
                                           startTime: info.startTime,
                                           duration: info.duration * 1000,
                                           closeDelay: info.closeDelay * 1000)
    }
    
    func onRoomClosed() {
        AgoraAlert()
            .setTitle(AgoraKitLocalizedString("ClassOverNoticeText"))
            .setMessage(AgoraKitLocalizedString("ClassOverText"))
            .addAction(action: AgoraAlertAction(title: AgoraKitLocalizedString("SureText"), action: {
                self.roomDelegate?.exitClassRoom(reason: .normal)
            }))
            .show(in: self)
    }
}

// MARK: - AgoraEduUserHandler
extension AgoraOneToOneStateUIController: AgoraEduUserHandler {
    func onLocalUserKickedOut() {
        AgoraAlert()
            .setTitle(AgoraKitLocalizedString("KickOutNoticeText"))
            .setMessage("local_user_kicked_out".agedu_localized())
            .addAction(action: AgoraAlertAction(title: AgoraKitLocalizedString("SureText"), action: {
                self.roomDelegate?.exitClassRoom(reason: .kickOut)
            }))
            .show(in: self)
    }
    
    func onCoHostUserListAdded(userList: [AgoraEduContextUserInfo],
                               operatorUser: AgoraEduContextUserInfo?) {
        let localUUID = contextPool.user.getLocalUserInfo().userUuid
        if let _ = userList.first(where: {$0.userUuid == localUUID}) {
            // 老师邀请你上台了，与大家积极互动吧
            AgoraToast.toast(msg: "toast_student_stage_on".agedu_localized(),
                             type: .notice)
        }
    }
    
    func onCoHostUserListRemoved(userList: [AgoraEduContextUserInfo],
                                 operatorUser: AgoraEduContextUserInfo?) {
        let localUUID = contextPool.user.getLocalUserInfo().userUuid
        if let _ = userList.first(where: {$0.userUuid == localUUID}) {
            // 你离开讲台了，暂时无法与大家互动
            AgoraToast.toast(msg: "toast_student_stage_off".agedu_localized(),
                             type: .error)
        }
    }
    
    func onUserRewarded(user: AgoraEduContextUserInfo,
                        rewardCount: Int,
                        operatorUser: AgoraEduContextUserInfo?) {
        // 祝贺**获得奖励
        let str = String.init(format: "toast_reward_student_xx".agedu_localized(),
                              user.userName)
        AgoraToast.toast(msg: str,
                         type: .notice)
    }
}

extension AgoraOneToOneStateUIController: AgoraEduMonitorHandler {
    func onLocalNetworkQualityUpdated(quality: AgoraEduContextNetworkQuality) {
        switch quality {
        case .unknown:
            netStateView.image = UIImage.agedu_named("ic_network_unknow")
        case .good:
            netStateView.image = UIImage.agedu_named("ic_network_good")
        case .medium:
            netStateView.image = UIImage.agedu_named("ic_network_medium")
        case .bad:
            netStateView.image = UIImage.agedu_named("ic_network_bad")
        default: break
        }
    }
    
    func onLocalConnectionUpdated(state: AgoraEduContextConnectionState) {
        switch state {
        case .aborted:
            // 踢出
            AgoraLoading.hide()
            AgoraToast.toast(msg: AgoraKitLocalizedString("LoginOnAnotherDeviceText"),
                             type: .error)
            self.roomDelegate?.exitClassRoom(reason: .kickOut)
        case .connecting:
            AgoraLoading.loading(msg: AgoraKitLocalizedString("LoaingText"))
        case .disconnected, .reconnecting:
            AgoraLoading.loading(msg: AgoraKitLocalizedString("ReconnectingText"))
        case .connected:
            AgoraLoading.hide()
        }
    }
}

// MARK: - Creaions
private extension AgoraOneToOneStateUIController {
    func createViews() {
        view.backgroundColor = .white
        view.layer.borderWidth = 1
        view.layer.borderColor = UIColor(hex: 0xECECF1)?.cgColor
        view.layer.cornerRadius = 2
        view.clipsToBounds = true
        
        netStateView = UIImageView(image: UIImage.agedu_named("ic_network_unknow"))
        view.addSubview(netStateView)
        
        lineView = UIView(frame: .zero)
        lineView.backgroundColor = UIColor(hex: 0xECECF1)
        view.addSubview(lineView)
        
        titleLabel = UILabel()
        titleLabel.font = UIFont.systemFont(ofSize: 9)
        titleLabel.textColor = UIColor(hex: 0x191919)
        view.addSubview(titleLabel)
        
        timeLabel = UILabel()
        timeLabel.font = UIFont.systemFont(ofSize: 9)
        timeLabel.textColor = UIColor(hex: 0x677386)
        view.addSubview(timeLabel)
        
        settingButton = UIButton(type: .custom)
        if let settingIMG = UIImage.agedu_named("ic_func_setting")?
            .withRenderingMode(.alwaysTemplate) {
            settingButton.setImageForAllStates(settingIMG)
        }
        settingButton.imageView?.tintColor = UIColor(hex: 0x7B88A0)
        settingButton.addTarget(self, action: #selector(onClickSetting(_:)),
                                for: .touchUpInside)
        settingButton.layer.cornerRadius = 20 * 0.5
        settingButton.clipsToBounds = true
        view.addSubview(settingButton)
    }
    
    func createConstrains() {
        netStateView.mas_makeConstraints { make in
            make?.left.equalTo()(self.view)?.offset()(AgoraFit.scale(10))
            make?.width.height().equalTo()(20)
            make?.centerY.equalTo()(0)
        }
        lineView.mas_makeConstraints { make in
            make?.centerX.centerY().equalTo()(0)
            make?.width.equalTo()(1)
            make?.height.equalTo()(16)
        }
        titleLabel.mas_makeConstraints { make in
            make?.centerY.equalTo()(0)
            make?.right.equalTo()(lineView.mas_left)?.offset()(-8)
        }
        timeLabel.mas_makeConstraints { make in
            make?.centerY.equalTo()(0)
            make?.left.equalTo()(lineView.mas_right)?.offset()(8)
        }
        settingButton.mas_makeConstraints { make in
            make?.right.equalTo()(AgoraFit.scale(-10))
            make?.centerY.equalTo()(0)
            make?.width.height().equalTo()(20)
        }
    }
}
