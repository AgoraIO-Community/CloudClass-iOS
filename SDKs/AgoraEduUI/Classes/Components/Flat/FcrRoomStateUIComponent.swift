//
//  PaintingRoomStateViewController.swift
//  AgoraEduUI
//
//  Created by Jonathan on 2021/10/12.
//

import AgoraUIBaseViews
import AgoraEduCore
import Masonry

protocol FcrRoomStateUIComponentDelegate: NSObjectProtocol {
    func onPressedNetworkState()
}

struct AgoraClassTimeInfo {
    var state: AgoraEduContextClassState
    var startTime: Int64
    var duration: Int64
    var closeDelay: Int64
}

class FcrRoomStateUIComponent: FcrUIComponent {
    /** SDK环境*/
    private let roomController: AgoraEduRoomContext
    private let userController: AgoraEduUserContext
    private let monitorController: AgoraEduMonitorContext
    private let groupController: AgoraEduGroupContext
    private let subRoom: AgoraEduSubRoomContext?
    
    /** 状态栏*/
    let stateView = FcrRoomStateBar(frame: .zero)
    
    /** 房间计时器*/
    private var timer: Timer?
    /** 房间时间信息*/
    private var timeInfo: AgoraClassTimeInfo?
    
    weak var delegate: FcrRoomStateUIComponentDelegate?
    
    init(roomController: AgoraEduRoomContext,
         userController: AgoraEduUserContext,
         monitorController: AgoraEduMonitorContext,
         groupController: AgoraEduGroupContext,
         subRoom: AgoraEduSubRoomContext? = nil,
         delegate: FcrRoomStateUIComponentDelegate? = nil) {
        self.roomController = roomController
        self.userController = userController
        self.monitorController = monitorController
        self.groupController = groupController
        self.subRoom = subRoom
        self.delegate = delegate
        
        super.init(nibName: nil,
                   bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    deinit {
        viewWillInactive()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        initViews()
        initViewFrame()
        updateViewProperties()
        
        if let `subRoom` = subRoom {
            subRoom.registerSubRoomEventHandler(self)
            groupController.registerGroupEventHandler(self)
        }
        
        roomController.registerRoomEventHandler(self)
        monitorController.registerMonitorEventHandler(self)
    }
}

extension FcrRoomStateUIComponent: AgoraUIContentContainer, AgoraUIActivity {
    func initViews() {
        view.addSubview(stateView)
        
        let recordingTitle = "fcr_record_recording".edu_ui_localized()
        stateView.recordingLabel.text = recordingTitle
        
        var roomTitle: String
        
        switch roomController.getRoomInfo().roomType {
        case .oneToOne:     roomTitle = "fcr_room_one_to_one_title".edu_ui_localized()
        case .small:        roomTitle = "fcr_room_small_title".edu_ui_localized()
        case .lecture:      roomTitle = "fcr_room_lecture_title".edu_ui_localized()
        @unknown default:   roomTitle = "fcr_room_small_title".edu_ui_localized()
        }
        
        stateView.titleLabel.text = roomTitle
        
        if let sub = subRoom {
            stateView.titleLabel.text = sub.getSubRoomInfo().subRoomName
        } else {
            stateView.titleLabel.text = roomController.getRoomInfo().roomName
        }
        
        stateView.netStateView.addTarget(self,
                                         action: #selector(onPressedNetworkStateView),
                                         for: .touchUpInside)
    }
    
    func initViewFrame() {
        stateView.mas_remakeConstraints { make in
            make?.left.right().top().bottom().equalTo()(0)
        }
    }
    
    func updateViewProperties() {
        let config = UIConfig.stateBar
        
        view.agora_enable = config.enable
        view.agora_visible = config.visible
        
        stateView.netStateView.agora_enable = config.networkState.enable
        
        stateView.netStateView.titleLabel?.font = config.networkState.textFont
        
        stateView.timeLabel.agora_enable = config.scheduleTime.enable
        
        stateView.titleLabel.agora_enable = config.roomName.enable
        
        updateStateView(with: .good)
        
        let recodingIsVisible: Bool = (roomController.getRecordingState() == .started)
        
        let recordConfig = UIConfig.record
        stateView.recordingStateView.agora_enable = recordConfig.recordingState.enable
        stateView.recordingStateView.agora_visible = recodingIsVisible
        
        stateView.recordingLabel.agora_enable = recordConfig.recordingState.enable
        stateView.recordingLabel.agora_visible = recodingIsVisible
    }
    
    func viewWillActive() {
        let info = roomController.getClassInfo()
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
private extension FcrRoomStateUIComponent {
    @objc func updateTimeVisual() {
        guard let info = self.timeInfo else {
            return
        }
        
        let realTime = Int64(Date().timeIntervalSince1970 * 1000)
        switch info.state {
        case .before:
            stateView.timeLabel.textColor = FcrUIColorGroup.textLevel2Color
            if info.startTime == 0 {
                stateView.timeLabel.text = "fcr_room_class_not_start".edu_ui_localized()
            } else {
                let time = info.startTime - realTime
                let text = "fcr_room_class_time_away".edu_ui_localized()
                stateView.timeLabel.text = text + timeString(from: time)
            }
        case .after:
            stateView.timeLabel.textColor = FcrUIColorGroup.systemErrorColor
            let time = realTime - info.startTime
            let text = "fcr_room_class_over".edu_ui_localized()
            stateView.timeLabel.text = text + timeString(from: time)
            // 事件
            let countDown = info.closeDelay + info.duration - time
            if countDown == info.closeDelay {
                let minNum = Int(info.closeDelay / 60)
                let strMid = "\(minNum)"
                
                let str = "fcr_room_close_warning".edu_ui_localized()
                let final = str.replacingOccurrences(of: String.edu_ui_localized_replacing_x(),
                                                     with: strMid)
                AgoraToast.toast(message: final)
            } else if countDown == 60 {
                let str = "fcr_room_close_warning".edu_ui_localized()
                let final = str.replacingOccurrences(of: String.edu_ui_localized_replacing_x(),
                                                     with: "1")
                AgoraToast.toast(message: final)
            }
        case .during:
            stateView.timeLabel.textColor = FcrUIColorGroup.textLevel2Color
            let time = realTime - info.startTime
            let text = "fcr_room_class_started".edu_ui_localized()
            stateView.timeLabel.text = text + timeString(from: time)
            // 事件
            let countDown = info.closeDelay + info.duration - time
            if countDown == 5 * 60 + info.closeDelay {
                let str = "fcr_room_class_end_warning".edu_ui_localized()
                let final = str.replacingOccurrences(of: String.edu_ui_localized_replacing_x(),
                                                     with: "5")
                AgoraToast.toast(message: final)
            }
        }
    }
    
    func timeString(from interval: Int64) -> String {
        let time = interval > 0 ? (interval / 1000) : 0
        let hourInt = time / 3600
        let minuteInt = time % 3600 / 60
        let secondInt = time % 3600 % 60
        
        let hourString = NSString(format: "%02d", hourInt) as String
        let minuteString = NSString(format: "%02d", minuteInt) as String
        let secondString = NSString(format: "%02d", secondInt) as String
        if hourInt == 0 {
            return "\(minuteString):\(secondString)"
        } else {
            let hourString = NSString(format: "%02d", hourInt) as String
            return "\(hourString):\(minuteString):\(secondString)"
        }
    }
    
    @objc func onPressedNetworkStateView() {
        delegate?.onPressedNetworkState()
    }
    
    func updateStateView(with quality: AgoraEduContextNetworkQuality) {
        let config = UIConfig.stateBar.networkState
        
        var image: UIImage?
        var text: String
        var color: UIColor
        
        switch quality {
        case .good:
            image = config.goodImage
            text = "fcr_network_label_network_quality_excellent".edu_ui_localized()
            color = config.goodColor
        case .bad:
            image = config.badImage
            text = "fcr_network_label_network_quality_bad".edu_ui_localized()
            color = config.badColor
        case .down:
            image = config.downImage
            text = "fcr_network_label_network_quality_down".edu_ui_localized()
            color = config.downColor
        default:
            return
        }
        
        stateView.netStateView.setImage(image,
                                        for: .normal)
        
        stateView.netStateView.setTitle(text,
                                        for: .normal)
        
        stateView.netStateView.setTitleColor(color,
                                             for: .normal)
    }
}

// MARK: - AgoraEduRoomHandler
extension FcrRoomStateUIComponent: AgoraEduRoomHandler {
    func onJoinRoomSuccess(roomInfo: AgoraEduContextRoomInfo) {
        viewWillActive()
    }
    
    func onClassStateUpdated(state: AgoraEduContextClassState) {
        let info = roomController.getClassInfo()
        timeInfo = AgoraClassTimeInfo(state: info.state,
                                      startTime: info.startTime,
                                      duration: info.duration * 1000,
                                      closeDelay: info.closeDelay * 1000)
    }
    
    func onRecordingStateUpdated(state: FcrRecordingState) {
        let isVisible: Bool = (state == .started)
        
        stateView.recordingLabel.agora_visible = isVisible
        stateView.recordingStateView.agora_visible = isVisible
    }
}

// MARK: - AgoraEduSubRoomHandler
extension FcrRoomStateUIComponent: AgoraEduSubRoomHandler {
    func onJoinSubRoomSuccess(roomInfo: AgoraEduContextSubRoomInfo) {
        viewWillActive()
    }
}

extension FcrRoomStateUIComponent: AgoraEduGroupHandler {
    func onSubRoomListUpdated(subRoomList: [AgoraEduContextSubRoomInfo]) {
        let localUserId = userController.getLocalUserInfo().userUuid
        
        for subRoom in subRoomList {
            guard let list = groupController.getUserListFromSubRoom(subRoomUuid: subRoom.subRoomUuid),
               list.contains(localUserId) else {
               return
            }
        
            stateView.titleLabel.text = subRoom.subRoomName
            break
        }
    }
}

// MARK: - AgoraEduMonitorHandler
extension FcrRoomStateUIComponent: AgoraEduMonitorHandler {
    func onLocalConnectionUpdated(state: AgoraEduContextConnectionState) {
        switch state {
        case .reconnecting, .disconnected:
            updateStateView(with: .down)
        case .connected:
            updateStateView(with: .good)
        default:
            break
        }
    }
    
    func onLocalNetworkQualityUpdated(quality: AgoraEduContextNetworkQuality) {
        updateStateView(with: quality)
    }
}
