//
//  AgoraOneToOneStateUIController.swift
//  AgoraEduUI
//
//  Created by Jonathan on 2021/11/15.
//

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
        createConstraint()
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
        let color = AgoraColorGroup()
        if sender.isSelected {
            settingButton.imageView?.tintColor = color.one_room_setting_selected_tint_color
            settingButton.backgroundColor = color.one_room_setting_selected_bg_color
        } else {
            settingButton.imageView?.tintColor = color.one_room_setting_unselected_tint_color
            settingButton.backgroundColor = color.one_room_setting_unselected_bg_color
        }
    }
    
    func updateTimeVisual() {
        guard let info = self.timeInfo else {
            return
        }
        
        let group = AgoraColorGroup()
        
        let realTime = Int64(Date().timeIntervalSince1970 * 1000)
        switch info.state {
        case .before:
            timeLabel.textColor = group.room_state_label_before_color
            if info.startTime == 0 {
                timeLabel.text = "fcr_room_class_not_start".agedu_localized()
            } else {
                let time = info.startTime - realTime
                let text = "fcr_room_class_time_away".agedu_localized()
                timeLabel.text = text + timeString(from: time)
            }
        case .after:
            timeLabel.textColor = group.room_state_label_after_color
            let time = realTime - info.startTime
            let text = "fcr_room_class_over".agedu_localized()
            timeLabel.text = text + timeString(from: time)
            // 事件
            let countDown = info.closeDelay + info.duration - time
            if countDown == info.closeDelay {
                let minNum = Int(info.closeDelay / 60)
                let strMid = "\(minNum)"
                
                let str = "fcr_room_close_warning".agedu_localized()
                let final = str.replacingOccurrences(of: String.agedu_localized_replacing(),
                                                     with: strMid)
                AgoraToast.toast(msg: final)
            } else if countDown == 60 {
                let str = "fcr_room_close_warning".agedu_localized()
                let final = str.replacingOccurrences(of: String.agedu_localized_replacing(),
                                                     with: "1")
                AgoraToast.toast(msg: final)
            }
        case .during:
            timeLabel.textColor = group.room_state_label_during_color
            let time = realTime - info.startTime
            let text = "fcr_room_class_started".agedu_localized()
            timeLabel.text = text + timeString(from: time)
            // 事件
            let countDown = info.closeDelay + info.duration - time
            if countDown == 5 * 60 + info.closeDelay {
                let str = "fcr_room_class_end_warning".agedu_localized()
                let final = str.replacingOccurrences(of: String.agedu_localized_replacing(),
                                                     with: "5")
                AgoraToast.toast(msg: final)
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
        AgoraAlertModel()
            .setTitle("fcr_room_class_over_notice".agedu_localized())
            .setMessage("fcr_room_class_over".agedu_localized())
            .addAction(action: AgoraAlertAction(title: "fcr_room_class_leave_sure".agedu_localized(), action: {
                self.roomDelegate?.exitClassRoom(reason: .normal,
                                                 roomType: .main)
            }))
            .show(in: self)
    }
}

// MARK: - AgoraEduUserHandler
extension AgoraOneToOneStateUIController: AgoraEduUserHandler {
    func onLocalUserKickedOut() {
        AgoraAlertModel()
            .setTitle("fcr_user_local_kick_out_notice".agedu_localized())
            .setMessage("fcr_user_local_kick_out".agedu_localized())
            .addAction(action: AgoraAlertAction(title: "fcr_room_class_leave_sure".agedu_localized(), action: {
                self.roomDelegate?.exitClassRoom(reason: .kickOut,
                                                 roomType: .main)
            }))
            .show(in: self)
    }
    
    func onCoHostUserListAdded(userList: [AgoraEduContextUserInfo],
                               operatorUser: AgoraEduContextUserInfo?) {
        let localUUID = contextPool.user.getLocalUserInfo().userUuid
        if let _ = userList.first(where: {$0.userUuid == localUUID}) {
            // 老师邀请你上台了，与大家积极互动吧
            AgoraToast.toast(msg: "fcr_user_local_start_co_hosting".agedu_localized(),
                             type: .notice)
        }
    }
    
    func onCoHostUserListRemoved(userList: [AgoraEduContextUserInfo],
                                 operatorUser: AgoraEduContextUserInfo?) {
        let localUUID = contextPool.user.getLocalUserInfo().userUuid
        if let _ = userList.first(where: {$0.userUuid == localUUID}) {
            // 你离开讲台了，暂时无法与大家互动
            AgoraToast.toast(msg: "fcr_user_local_stop_co_hosting".agedu_localized(),
                             type: .error)
        }
    }
    
    func onUserRewarded(user: AgoraEduContextUserInfo,
                        rewardCount: Int,
                        operatorUser: AgoraEduContextUserInfo?) {
        // 祝贺**获得奖励
        let str = "fcr_user_congratulation".agedu_localized()
        let final = str.replacingOccurrences(of: String.agedu_localized_replacing(),
                                             with: user.userName)
        AgoraToast.toast(msg: final,
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
        case .bad:
            netStateView.image = UIImage.agedu_named("ic_network_bad")
        case .down:
            AgoraToast.toast(msg:"fcr_monitor_network_disconnected".agedu_localized(),
                             type: .error)
            netStateView.image = UIImage.agedu_named("ic_network_down")
        default: break
        }
    }
    
    func onLocalConnectionUpdated(state: AgoraEduContextConnectionState) {
        switch state {
        case .aborted:
            // 踢出
            AgoraLoading.hide()
            AgoraToast.toast(msg: "fcr_monitor_login_remote_device".agedu_localized(),
                             type: .error)
            self.roomDelegate?.exitClassRoom(reason: .kickOut,
                                             roomType: .main)
        case .connecting:
            AgoraLoading.loading(msg: "fcr_room_loading".agedu_localized())
        case .disconnected, .reconnecting:
            AgoraToast.toast(msg:"fcr_monitor_network_disconnected".agedu_localized(),
                             type: .error)
            AgoraLoading.loading(msg: "fcr_monitor_network_reconnecting".agedu_localized())
        case .connected:
            AgoraLoading.hide()
        }
    }
}

// MARK: - Creaions
private extension AgoraOneToOneStateUIController {
    func createViews() {
        let ui = AgoraUIGroup()
        
        view.backgroundColor = ui.color.room_state_bg_color
        view.layer.borderWidth = ui.frame.room_state_border_width
        view.layer.borderColor = ui.color.room_state_border_color
        view.layer.cornerRadius = ui.frame.room_state_corner_radius
        view.clipsToBounds = true
        
        // default network quality is good
        netStateView = UIImageView(image: UIImage.agedu_named("ic_network_good"))
        view.addSubview(netStateView)
        
        lineView = UIView(frame: .zero)
        lineView.backgroundColor = ui.color.room_state_line_color
        view.addSubview(lineView)
        
        titleLabel = UILabel()
        titleLabel.font = UIFont.systemFont(ofSize: 9)
        titleLabel.textColor = ui.color.one_room_state_title_color
        view.addSubview(titleLabel)
        
        timeLabel = UILabel()
        timeLabel.font = UIFont.systemFont(ofSize: 9)
        timeLabel.textColor = ui.color.one_room_state_time_color
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
    
    func createConstraint() {
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
