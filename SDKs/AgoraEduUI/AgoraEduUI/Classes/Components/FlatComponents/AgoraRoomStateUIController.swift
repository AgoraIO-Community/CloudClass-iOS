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
    /** SDK环境*/
    private var contextPool: AgoraEduContextPool
    private var subRoom: AgoraEduSubRoomContext?
    
    /** 状态栏*/
    private var stateView = AgoraRoomStateBar(frame: .zero)
    
    /** 房间计时器*/
    private var timer: Timer?
    /** 房间时间信息*/
    private var timeInfo: AgoraClassTimeInfo?
    
    init(context: AgoraEduContextPool,
         subRoom: AgoraEduSubRoomContext? = nil) {
        self.contextPool = context
        self.subRoom = subRoom
        super.init(nibName: nil,
                   bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    deinit {
        viewWillInactive()
        print("\(#function): \(self.classForCoder)")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        initViews()
        initViewFrame()
        updateViewProperties()
        
        if let `subRoom` = subRoom {
            subRoom.registerSubRoomEventHandler(self)
            contextPool.group.registerGroupEventHandler(self)
        }
        
        contextPool.room.registerRoomEventHandler(self)
        contextPool.monitor.registerMonitorEventHandler(self)
    }
}

extension AgoraRoomStateUIController: AgoraUIContentContainer, AgoraUIActivity {
    func initViews() {
        view.addSubview(stateView)
    }
    
    func initViewFrame() {
        stateView.mas_remakeConstraints { make in
            make?.left.right().top().bottom().equalTo()(0)
        }
    }
    
    func updateViewProperties() {
        let ui = AgoraUIGroup()
        let color = ui.color
        let frame = ui.frame
        
        view.backgroundColor = .white
        view.layer.borderWidth = frame.room_state_border_width
        view.layer.borderColor = color.small_room_state_border_color
        view.layer.cornerRadius = frame.room_state_corner_radius
        view.clipsToBounds = true
        
        stateView.backgroundColor = color.room_state_bg_color
        
        var roomTitle: String
        switch contextPool.room.getRoomInfo().roomType {
        case .oneToOne:     roomTitle = "fcr_room_one_to_one_title".agedu_localized()
        case .small:        roomTitle = "fcr_room_small_title".agedu_localized()
        case .lecture:      roomTitle = "fcr_room_lecture_title".agedu_localized()
        @unknown default:   roomTitle = "fcr_room_small_title".agedu_localized()
        }
        stateView.titleLabel.text = roomTitle
        
        stateView.titleLabel.textColor = color.room_state_label_before_color
        stateView.timeLabel.textColor = color.room_state_label_before_color
        
        let recordingTitle = "fcr_record_recording".agedu_localized()
        stateView.recordingLabel.text = recordingTitle
        
        let isHidden: Bool = !((contextPool.room.getRecordingState() == .started))
        stateView.recordingStateView.isHidden = isHidden
        stateView.recordingLabel.isHidden = isHidden
        
        if let sub = subRoom {
            stateView.titleLabel.text = sub.getSubRoomInfo().subRoomName
        } else {
            stateView.titleLabel.text = contextPool.room.getRoomInfo().roomName
        }
    }
    
    func viewWillActive() {
        let info = self.contextPool.room.getClassInfo()
        self.timeInfo = AgoraClassTimeInfo(state: info.state,
                                           startTime: info.startTime,
                                           duration: info.duration * 1000,
                                           closeDelay: info.closeDelay * 1000)
        
        self.timer = Timer.scheduledTimer(withTimeInterval: 1.0,
                                          repeats: true,
                                          block: { [weak self] t in
            self?.updateTimeVisual()
        })
    }
    
    func viewWillInactive() {
        self.timer?.invalidate()
        self.timer = nil
    }
}

// MARK: - Private
private extension AgoraRoomStateUIController {
    @objc func updateTimeVisual() {
        guard let info = self.timeInfo else {
            return
        }
        
        let color = AgoraColorGroup()
        
        let realTime = Int64(Date().timeIntervalSince1970 * 1000)
        switch info.state {
        case .before:
            stateView.timeLabel.textColor = color.room_state_label_before_color
            if info.startTime == 0 {
                stateView.timeLabel.text = "fcr_room_class_not_start".agedu_localized()
            } else {
                let time = info.startTime - realTime
                let text = "fcr_room_class_time_away".agedu_localized()
                stateView.timeLabel.text = text + timeString(from: time)
            }
        case .after:
            stateView.timeLabel.textColor = color.room_state_label_after_color
            let time = realTime - info.startTime
            let text = "fcr_room_class_over".agedu_localized()
            stateView.timeLabel.text = text + timeString(from: time)
            // 事件
            let countDown = info.closeDelay + info.duration - time
            if countDown == info.closeDelay {
                let minNum = Int(info.closeDelay / 60)
                let strMid = "\(minNum)"
                
                let str = "fcr_room_close_warning".agedu_localized()
                let final = str.replacingOccurrences(of: String.agedu_localized_replacing_x(),
                                                     with: strMid)
                AgoraToast.toast(msg: final)
            } else if countDown == 60 {
                let str = "fcr_room_close_warning".agedu_localized()
                let final = str.replacingOccurrences(of: String.agedu_localized_replacing_x(),
                                                     with: "1")
                AgoraToast.toast(msg: final)
            }
        case .during:
            stateView.timeLabel.textColor = color.room_state_label_during_color
            let time = realTime - info.startTime
            let text = "fcr_room_class_started".agedu_localized()
            stateView.timeLabel.text = text + timeString(from: time)
            // 事件
            let countDown = info.closeDelay + info.duration - time
            if countDown == 5 * 60 + info.closeDelay {
                let str = "fcr_room_class_end_warning".agedu_localized()
                let final = str.replacingOccurrences(of: String.agedu_localized_replacing_x(),
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
}

// MARK: - AgoraEduRoomHandler
extension AgoraRoomStateUIController: AgoraEduRoomHandler {
    func onJoinRoomSuccess(roomInfo: AgoraEduContextRoomInfo) {
        viewWillActive()
    }
    
    func onClassStateUpdated(state: AgoraEduContextClassState) {
        let info = contextPool.room.getClassInfo()
        timeInfo = AgoraClassTimeInfo(state: info.state,
                                      startTime: info.startTime,
                                      duration: info.duration * 1000,
                                      closeDelay: info.closeDelay * 1000)
    }
    
    func onRecordingStateUpdated(state: FcrRecordingState) {
        let isHidden: Bool = !(state == .started)
        
        stateView.recordingLabel.isHidden = isHidden
        stateView.recordingStateView.isHidden = isHidden
    }
}

// MARK: - AgoraEduSubRoomHandler
extension AgoraRoomStateUIController: AgoraEduSubRoomHandler {
    func onJoinSubRoomSuccess(roomInfo: AgoraEduContextSubRoomInfo) {
        viewWillActive()
    }
}

extension AgoraRoomStateUIController: AgoraEduGroupHandler {
    func onSubRoomListUpdated(subRoomList: [AgoraEduContextSubRoomInfo]) {
        let localUserId = contextPool.user.getLocalUserInfo().userUuid
        
        for subRoom in subRoomList {
            guard let list = contextPool.group.getUserListFromSubRoom(subRoomUuid: subRoom.subRoomUuid),
               list.contains(localUserId) else {
               return
            }
        
            stateView.titleLabel.text = subRoom.subRoomName
            break
        }
    }
}

// MARK: - AgoraEduMonitorHandler
extension AgoraRoomStateUIController: AgoraEduMonitorHandler {
    func onLocalNetworkQualityUpdated(quality: AgoraEduContextNetworkQuality) {
        var image: UIImage?
        
        switch quality {
        case .unknown:
            image = UIImage.agedu_named("ic_network_unknow")
        case .good:
            image = UIImage.agedu_named("ic_network_good")
        case .bad:
            image = UIImage.agedu_named("ic_network_bad")
        case .down:
            image = UIImage.agedu_named("ic_network_down")
            
            let message = "fcr_monitor_network_disconnected".agedu_localized()
            AgoraToast.toast(msg: message,
                             type: .error)
        default:
            return
        }
        
        stateView.netStateView.image = image
    }
}
