//
//  PaintingRoomStateViewController.swift
//  AgoraEduUI
//
//  Created by Jonathan on 2021/10/12.
//

import AgoraUIBaseViews
import AgoraEduContext
import Masonry

class VocationalRoomStateUIComponent: UIViewController {
    /** SDK环境*/
    private var contextPool: AgoraEduContextPool
    private var subRoom: AgoraEduSubRoomContext?
    
    public weak var roomDelegate: FcrUISceneExit?
    /** 状态栏*/
    private var stateView = VocationalRoomStateBar(frame: .zero)
    /** 退出房间按钮*/
    private var leaveButton = UIButton(type: .custom)
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

extension VocationalRoomStateUIComponent: AgoraUIContentContainer, AgoraUIActivity {
    func initViews() {
        view.addSubview(stateView)
        
        leaveButton.setImage(UIImage.agedu_named("ic_func_leave_room"),
                             for: .normal)
        leaveButton.addTarget(self,
                              action: #selector(onClickExit(_:)),
                              for: .touchUpInside)
        view.addSubview(leaveButton)
    }
    
    func initViewFrame() {
        stateView.mas_remakeConstraints { make in
            make?.left.right().top().bottom().equalTo()(0)
        }
        leaveButton.mas_makeConstraints { make in
            make?.top.bottom().equalTo()(0)
            make?.width.equalTo()(44)
            make?.centerY.right().equalTo()(0)
        }
    }
    
    func updateViewProperties() {
        view.backgroundColor = FcrUIColorGroup.systemForegroundColor
        view.layer.borderWidth = FcrUIFrameGroup.borderWidth
        view.layer.borderColor = FcrUIColorGroup.systemDividerColor.cgColor
        
        stateView.backgroundColor = FcrUIColorGroup.systemForegroundColor
        
        var roomTitle: String
        switch contextPool.room.getRoomInfo().roomType {
        case .oneToOne:     roomTitle = "fcr_room_one_to_one_title".agedu_localized()
        case .small:        roomTitle = "fcr_room_small_title".agedu_localized()
        case .lecture:      roomTitle = "fcr_room_lecture_title".agedu_localized()
        @unknown default:   roomTitle = "fcr_room_small_title".agedu_localized()
        }
        stateView.titleLabel.text = roomTitle
        
        stateView.titleLabel.textColor = FcrUIColorGroup.textLevel3Color
        stateView.timeLabel.textColor = FcrUIColorGroup.textLevel3Color
        
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
private extension VocationalRoomStateUIComponent {
    
    @objc func onClickExit(_ sender: UIButton) {
        AgoraAlertModel()
            .setTitle("fcr_room_class_leave_class_title".agedu_localized())
            .setMessage("fcr_room_exit_warning".agedu_localized())
            .addAction(action: AgoraAlertAction(title: "fcr_room_class_leave_cancel".agedu_localized(), action:nil))
            .addAction(action: AgoraAlertAction(title: "fcr_room_class_leave_sure".agedu_localized(), action: {
                self.roomDelegate?.exitScene(reason: .normal,
                                                 type: .main)
            }))
            .show(in: self)
    }
    
    @objc func updateTimeVisual() {
        guard let info = self.timeInfo else {
            return
        }
        
        let realTime = Int64(Date().timeIntervalSince1970 * 1000)
        switch info.state {
        case .before:
            stateView.timeLabel.textColor = FcrUIColorGroup.textLevel3Color
            if info.startTime == 0 {
                stateView.timeLabel.text = "fcr_room_class_not_start".agedu_localized()
            } else {
                let time = info.startTime - realTime
                let text = "fcr_room_class_time_away".agedu_localized()
                stateView.timeLabel.text = text + timeString(from: time)
            }
        case .after:
            stateView.timeLabel.textColor = FcrUIColorGroup.systemErrorColor
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
                AgoraToast.toast(message: final)
            } else if countDown == 60 {
                let str = "fcr_room_close_warning".agedu_localized()
                let final = str.replacingOccurrences(of: String.agedu_localized_replacing_x(),
                                                     with: "1")
                AgoraToast.toast(message: final)
            }
        case .during:
            stateView.timeLabel.textColor = FcrUIColorGroup.textLevel3Color
            let time = realTime - info.startTime
            let text = "fcr_room_class_started".agedu_localized()
            stateView.timeLabel.text = text + timeString(from: time)
            // 事件
            let countDown = info.closeDelay + info.duration - time
            if countDown == 5 * 60 + info.closeDelay {
                let str = "fcr_room_class_end_warning".agedu_localized()
                let final = str.replacingOccurrences(of: String.agedu_localized_replacing_x(),
                                                     with: "5")
                AgoraToast.toast(message: final)
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
extension VocationalRoomStateUIComponent: AgoraEduRoomHandler {
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
}

// MARK: - AgoraEduSubRoomHandler
extension VocationalRoomStateUIComponent: AgoraEduSubRoomHandler {
    func onJoinSubRoomSuccess(roomInfo: AgoraEduContextSubRoomInfo) {
        viewWillActive()
    }
}

extension VocationalRoomStateUIComponent: AgoraEduGroupHandler {
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
extension VocationalRoomStateUIComponent: AgoraEduMonitorHandler {
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
            AgoraToast.toast(message: message,
                             type: .error)
        default:
            return
        }
        
        stateView.netStateView.image = image
    }
}

class VocationalRoomStateBar: UIView, AgoraUIContentContainer {
    
    private var sepLine = UIView()
    
    let netStateView = UIImageView()
    
    let timeLabel = UILabel()
    let titleLabel = UILabel()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        initViews()
        initViewFrame()
        updateViewProperties()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func initViews() {
        addSubview(netStateView)
        addSubview(timeLabel)
        addSubview(sepLine)
        addSubview(titleLabel)
    }
    
    func initViewFrame() {
        netStateView.mas_makeConstraints { make in
            if #available(iOS 11.0, *) {
                make?.left.equalTo()(self.mas_safeAreaLayoutGuideLeft)?.offset()(10)
            } else {
                make?.left.equalTo()(self)?.offset()(10)
            }
            make?.width.height().equalTo()(20)
            make?.centerY.equalTo()(netStateView.superview)
        }
        sepLine.mas_makeConstraints { make in
            make?.width.equalTo()(1)
            make?.height.equalTo()(AgoraFit.scale(16))
            make?.center.equalTo()(0)
        }
        timeLabel.mas_makeConstraints { make in
            make?.left.equalTo()(sepLine.mas_right)?.offset()(8)
            make?.top.bottom().equalTo()(0)
            make?.width.greaterThanOrEqualTo()(60)
        }
        titleLabel.mas_makeConstraints { make in
            make?.right.equalTo()(sepLine.mas_left)?.offset()(-8)
            make?.top.bottom().equalTo()(0)
        }
    }
    
    func updateViewProperties() {
        let font = FcrUIFontGroup.font9
        
        timeLabel.font = font
        timeLabel.textColor = FcrUIColorGroup.textLevel3Color
        
        sepLine.backgroundColor = FcrUIColorGroup.systemDividerColor
        
        titleLabel.font = font
        titleLabel.textColor = FcrUIColorGroup.textLevel1Color
    }
}

