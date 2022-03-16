//
//  PaintingRoomStateViewController.swift
//  AgoraEduUI
//
//  Created by Jonathan on 2021/10/12.
//

import AgoraUIBaseViews
import AgoraEduContext
import Masonry

struct AgoraClassTimeInfo {
    var state: AgoraEduContextClassState
    var startTime: Int64
    var duration: Int64
    var closeDelay: Int64
}

class AgoraRoomStateUIController: UIViewController {
    
    public weak var roomDelegate: AgoraClassRoomManagement?
    /** 状态栏*/
    private var stateView: AgoraRoomStateBar!
    
    public var themeColor: UIColor?
    /** SDK环境*/
    private var contextPool: AgoraEduContextPool!
    /** 房间计时器*/
    private var timer: Timer?
    /** 房间时间信息*/
    private var timeInfo: AgoraClassTimeInfo?
    
    private var localStream: AgoraEduContextStreamInfo?
    
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
        self.timer = Timer.scheduledTimer(withTimeInterval: 1.0,
                                          repeats: true,
                                          block: { [weak self] t in
            self?.updateTimeVisual()
        })
        contextPool.room.registerRoomEventHandler(self)
        contextPool.monitor.registerMonitorEventHandler(self)
        contextPool.user.registerUserEventHandler(self)
        contextPool.stream.registerStreamEventHandler(self)
    }
}

// MARK: - Private
private extension AgoraRoomStateUIController {
    func setup() {
        self.stateView.titleLabel.text = self.contextPool.room.getRoomInfo().roomName
        let info = self.contextPool.room.getClassInfo()
        self.timeInfo = AgoraClassTimeInfo(state: info.state,
                                           startTime: info.startTime,
                                           duration: info.duration * 1000,
                                           closeDelay: info.closeDelay * 1000)
    }
    
    @objc func updateTimeVisual() {
        guard let info = self.timeInfo else {
            return
        }
        
        let realTime = Int64(Date().timeIntervalSince1970 * 1000)
        switch info.state {
        case .before:
            if themeColor != nil {
                stateView.timeLabel.textColor = UIColor.white.withAlphaComponent(0.7)
            } else {
                stateView.timeLabel.textColor = UIColor(hex: 0x677386)
            }
            if info.startTime == 0 {
                stateView.timeLabel.text = "fcr_room_class_not_start".agedu_localized()
            } else {
                let time = info.startTime - realTime
                let text = "fcr_room_class_time_away".agedu_localized()
                stateView.timeLabel.text = text + timeString(from: time)
            }
        case .after:
            stateView.timeLabel.textColor = .red
            let time = realTime - info.startTime
            let text = "fcr_room_class_over".agedu_localized()
            stateView.timeLabel.text = text + timeString(from: time)
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
            if themeColor != nil {
                stateView.timeLabel.textColor = UIColor.white.withAlphaComponent(0.7)
            } else {
                stateView.timeLabel.textColor = UIColor(hex: 0x677386)
            }
            let time = realTime - info.startTime
            let text = "fcr_room_class_started".agedu_localized()
            stateView.timeLabel.text = text + timeString(from: time)
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
    
    func timeString(from interval: Int64) -> String {
        let time = interval > 0 ? (interval / 1000) : 0
        let minuteInt = time / 60
        let secondInt = time % 60
        
        let minuteString = NSString(format: "%02d", minuteInt) as String
        let secondString = NSString(format: "%02d", secondInt) as String
        
        return "\(minuteString):\(secondString)"
    }
    
    func getLocalStream() {
        let user = contextPool.user.getLocalUserInfo()
        guard let streams = contextPool.stream.getStreamList(userUuid: user.userUuid) else {
            return
        }
        
        for stream in streams where stream.videoSourceType == .camera {
            localStream = stream
        }
    }
}
// MARK: - AgoraEduUserHandler
extension AgoraRoomStateUIController: AgoraEduUserHandler {
    func onLocalUserKickedOut() {
        AgoraAlert()
            .setTitle("fcr_user_local_kick_out_notice".agedu_localized())
            .setMessage("fcr_user_local_kick_out".agedu_localized())
            .addAction(action: AgoraAlertAction(title: "fcr_room_class_leave_sure".agedu_localized(), action: {
                self.roomDelegate?.exitClassRoom(reason: .kickOut)
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

// MARK: - AgoraEduRoomHandler
extension AgoraRoomStateUIController: AgoraEduRoomHandler {
    func onJoinRoomSuccess(roomInfo: AgoraEduContextRoomInfo) {
        setup()
        getLocalStream()
    }
    
    func onClassStateUpdated(state: AgoraEduContextClassState) {
        let info = self.contextPool.room.getClassInfo()
        self.timeInfo = AgoraClassTimeInfo(state: info.state,
                                           startTime: info.startTime,
                                           duration: info.duration * 1000,
                                           closeDelay: info.closeDelay * 1000)
    }
    
    func onRoomClosed() {
        AgoraAlert()
            .setTitle("fcr_room_class_over_notice".agedu_localized())
            .setMessage("fcr_room_class_over".agedu_localized())
            .addAction(action: AgoraAlertAction(title: "fcr_room_class_leave_sure".agedu_localized(), action: {
                self.roomDelegate?.exitClassRoom(reason: .normal)
            }))
            .show(in: self)
    }
}
// MARK: - AgoraEduStreamContext
extension AgoraRoomStateUIController: AgoraEduStreamHandler {
    func onStreamJoined(stream: AgoraEduContextStreamInfo,
                        operatorUser: AgoraEduContextUserInfo?) {
        let localUUID = contextPool.user.getLocalUserInfo().userUuid
        guard stream.owner.userUuid == localUUID else {
            return
        }
        
        localStream = stream
    }
    
    func onStreamLeft(stream: AgoraEduContextStreamInfo,
                      operatorUser: AgoraEduContextUserInfo?) {
        let localUUID = contextPool.user.getLocalUserInfo().userUuid
        guard stream.owner.userUuid == localUUID else {
            return
        }
        
        localStream = nil
    }
    
    func onStreamUpdated(stream: AgoraEduContextStreamInfo,
                         operatorUser: AgoraEduContextUserInfo?) {
        let localUUID = contextPool.user.getLocalUserInfo().userUuid
        guard stream.owner.userUuid == localUUID,
              stream.owner.userRole == .student else {
            return
        }
        
        guard let `localStream` = localStream else {
            self.localStream = stream
            return
        }
        
        if localStream.streamType.hasAudio != stream.streamType.hasAudio {
            if stream.streamType.hasAudio {
                AgoraToast.toast(msg:"fcr_stream_start_audio".agedu_localized(),
                                 type: .notice)
            } else {
                AgoraToast.toast(msg:"fcr_stream_stop_audio".agedu_localized(),
                                 type: .error)
            }
        }
        
        if localStream.streamType.hasVideo != stream.streamType.hasVideo {
            if stream.streamType.hasVideo {
                AgoraToast.toast(msg:"fcr_stream_start_video".agedu_localized(),
                                 type: .error)
            } else {
                AgoraToast.toast(msg:"fcr_stream_stop_video".agedu_localized(),
                                 type: .error)
            }
        }
        
        self.localStream = stream
    }
}

// MARK: - AgoraEduMonitorHandler
extension AgoraRoomStateUIController: AgoraEduMonitorHandler {
    func onLocalNetworkQualityUpdated(quality: AgoraEduContextNetworkQuality) {
        switch quality {
        case .unknown:
            self.stateView.setNetworkState(.unknown)
        case .good:
            self.stateView.setNetworkState(.good)
        case .bad:
            self.stateView.setNetworkState(.bad)
        case .down:
            AgoraToast.toast(msg:"fcr_monitor_network_disconnected".agedu_localized(),
                             type: .error)
            self.stateView.setNetworkState(.down)
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
            self.roomDelegate?.exitClassRoom(reason: .kickOut)
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
// MARK: - Creations
private extension AgoraRoomStateUIController {
    func createViews() {
        view.backgroundColor = .white
        view.layer.borderWidth = 1
        view.layer.borderColor = UIColor(hex: 0xECECF1)?.cgColor
        view.layer.cornerRadius = 2
        view.clipsToBounds = true
        
        stateView = AgoraRoomStateBar(frame: .zero)
        stateView.themeColor = themeColor ?? .white
        view.addSubview(stateView)
    }
    
    func createConstraint() {
        stateView.mas_makeConstraints { make in
            make?.left.right().top().bottom().equalTo()(0)
        }
    }
}
