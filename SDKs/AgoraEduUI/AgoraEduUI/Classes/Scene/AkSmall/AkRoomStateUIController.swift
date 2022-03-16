//
//  PaintingRoomStateViewController.swift
//  AgoraEduUI
//
//  Created by Jonathan on 2021/10/12.
//

import Masonry
import AgoraEduContext
import AgoraUIBaseViews

class AkRoomStateUIController: UIViewController {
    
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
private extension AkRoomStateUIController {
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
            if info.startTime == 0 {
                stateView.timeLabel.text = "title_before_class".agedu_localized()
            } else {
                let time = info.startTime - realTime
                let text = "ClassBeforeStartText".agedu_localized()
                stateView.timeLabel.text = text + timeString(from: time)
            }
        case .after:
            stateView.timeLabel.textColor = .red
            let time = realTime - info.startTime
            let text = "ClassAfterStopText".agedu_localized()
            stateView.timeLabel.text = text + timeString(from: time)
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
            let time = realTime - info.startTime
            let text = "ClassAfterStartText".agedu_localized()
            stateView.timeLabel.text = text + timeString(from: time)
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
extension AkRoomStateUIController: AgoraEduUserHandler {
    func onLocalUserKickedOut() {
        AgoraAlert()
            .setTitle("KickOutNoticeText".agedu_localized())
            .setMessage("local_user_kicked_out".agedu_localized())
            .addAction(action: AgoraAlertAction(title: "SureText".agedu_localized(), action: {
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

// MARK: - AgoraEduRoomHandler
extension AkRoomStateUIController: AgoraEduRoomHandler {
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
            .setTitle("ClassOverNoticeText".agedu_localized())
            .setMessage("ClassOverText".agedu_localized())
            .addAction(action: AgoraAlertAction(title: "SureText".agedu_localized(), action: {
                self.roomDelegate?.exitClassRoom(reason: .normal)
            }))
            .show(in: self)
    }
}
// MARK: - AgoraEduStreamContext
extension AkRoomStateUIController: AgoraEduStreamHandler {
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
                AgoraToast.toast(msg:"toast_student_audio_stream_on".agedu_localized(),
                                 type: .notice)
            } else {
                AgoraToast.toast(msg:"toast_student_audio_stream_off".agedu_localized(),
                                 type: .error)
            }
        }
        
        if localStream.streamType.hasVideo != stream.streamType.hasVideo {
            if stream.streamType.hasVideo {
                AgoraToast.toast(msg:"toast_student_video_stream_on".agedu_localized(),
                                 type: .error)
            } else {
                AgoraToast.toast(msg:"toast_student_video_stream_off".agedu_localized(),
                                 type: .error)
            }
        }
        
        self.localStream = stream
    }
}

// MARK: - AgoraEduMonitorHandler
extension AkRoomStateUIController: AgoraEduMonitorHandler {
    func onLocalNetworkQualityUpdated(quality: AgoraEduContextNetworkQuality) {
        switch quality {
        case .unknown:
            self.stateView.setNetworkState(.unknown)
        case .good:
            self.stateView.setNetworkState(.good)
        case .bad:
            self.stateView.setNetworkState(.bad)
        case .down:
            AgoraToast.toast(msg:"NetworkDisconnectedText".agedu_localized(),
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
            AgoraToast.toast(msg: "LoginOnAnotherDeviceText".agedu_localized(),
                             type: .error)
            self.roomDelegate?.exitClassRoom(reason: .kickOut)
        case .connecting:
            AgoraLoading.loading(msg: "LoaingText".agedu_localized())
        case .disconnected, .reconnecting:
            AgoraToast.toast(msg:"NetworkDisconnectedText".agedu_localized(),
                             type: .error)
            AgoraLoading.loading(msg: "ReconnectingText".agedu_localized())
        case .connected:
            AgoraLoading.hide()
        }
    }
}

// MARK: - Creations
private extension AkRoomStateUIController {
    func createViews() {
        view.backgroundColor = .white
        view.layer.borderWidth = 1
        view.layer.borderColor = UIColor(hex: 0xECECF1)?.cgColor
        view.layer.cornerRadius = 2
        view.clipsToBounds = true
        
        stateView = AgoraRoomStateBar(frame: .zero)
        stateView.backgroundColor = UIColor(hexString: "#1D35AD")
        stateView.titleLabel.textColor = UIColor(hexString: "#C2D5E5")
        stateView.timeLabel.textColor = UIColor(hexString: "#C2D5E5")
        
        view.addSubview(stateView)
    }
    
    func createConstraint() {
        stateView.mas_makeConstraints { make in
            make?.left.right().top().bottom().equalTo()(0)
        }
    }
}
