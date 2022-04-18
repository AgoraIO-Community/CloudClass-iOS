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

protocol AgoraRoomStateUIControllerDelegate: NSObjectProtocol {
    func onLocalUserAddedToSubRoom(subRoomId: String)
    func onLocalUserRemovedFromSubRoom(subRoomId: String)
    func onGroupStateChanged(_ state: Bool)
}

class AgoraRoomStateUIController: UIViewController {
    /** SDK环境*/
    private var contextPool: AgoraEduContextPool!
    private var subRoom: AgoraEduSubRoomContext?
    
    private var userController: AgoraEduUserContext {
        if let `subRoom` = subRoom {
            return subRoom.user
        } else {
            return contextPool.user
        }
    }
    
    private var streamController: AgoraEduStreamContext {
        if let `subRoom` = subRoom {
            return subRoom.stream
        } else {
            return contextPool.stream
        }
    }
    
    public weak var roomDelegate: AgoraClassRoomManagement?
    
    private weak var delegate: AgoraRoomStateUIControllerDelegate?
    /** 状态栏*/
    private var stateView: AgoraRoomStateBar!
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
    
    init(context: AgoraEduContextPool,
         delegate: AgoraRoomStateUIControllerDelegate?,
         subRoom: AgoraEduSubRoomContext? = nil) {
        super.init(nibName: nil,
                   bundle: nil)
        self.contextPool = context
        self.subRoom = subRoom
        self.delegate = delegate
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
        
        if let `subRoom` = subRoom {
            subRoom.registerSubRoomEventHandler(self)
        } else {
            contextPool.group.registerGroupEventHandler(self)
        }
        
        userController.registerUserEventHandler(self)
        streamController.registerStreamEventHandler(self)
        
        contextPool.room.registerRoomEventHandler(self)
        contextPool.monitor.registerMonitorEventHandler(self)
    }
}

// MARK: - Private
private extension AgoraRoomStateUIController {
    func setup() {
        let info = self.contextPool.room.getClassInfo()
        self.timeInfo = AgoraClassTimeInfo(state: info.state,
                                           startTime: info.startTime,
                                           duration: info.duration * 1000,
                                           closeDelay: info.closeDelay * 1000)
        if let sub = subRoom {
            stateView.titleLabel.text = sub.getSubRoomInfo().subRoomName
        } else {
            stateView.titleLabel.text = contextPool.room.getRoomInfo().roomName
        }
        
        getLocalStream()
    }
    
    func checkNeedJoinSubRoom() {
        // Group
        guard contextPool.group.getGroupInfo().state,
              let subRoomList = contextPool.group.getSubRoomList() else {
            return
        }
        
        let localUserId = contextPool.user.getLocalUserInfo().userUuid
        
        for info in subRoomList {
            if let list = contextPool.group.getUserListFromSubRoom(subRoomUuid: info.subRoomUuid),
               list.contains(localUserId) {
                delegate?.onLocalUserAddedToSubRoom(subRoomId: info.subRoomUuid)
            }
        }
    }
    
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
            stateView.timeLabel.textColor = color.room_state_label_during_color
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
    
    // 小房间内，老师加入/离开的 toast
    func onRemoteUserJoined(user: AgoraEduContextUserInfo) {
        guard let _ = subRoom,
              user.userRole == .teacher else {
            return
        }
        
        let text = "fcr_group_enter_group".agedu_localized()
        
        AgoraToast.toast(msg: text,
                         type: .notice)
    }
    
    func onRemoteUserLeft(user: AgoraEduContextUserInfo,
                          operatorUser: AgoraEduContextUserInfo?,
                          reason: AgoraEduContextUserLeaveReason) {
        guard let _ = subRoom,
              user.userRole == .teacher else {
            return
        }
        
        let text = "fcr_group_exit_group".agedu_localized()
        
        AgoraToast.toast(msg: text,
                         type: .notice)
    }
}

// MARK: - AgoraEduRoomHandler
extension AgoraRoomStateUIController: AgoraEduRoomHandler {
    func onJoinRoomSuccess(roomInfo: AgoraEduContextRoomInfo) {
        setup()
        checkNeedJoinSubRoom()
    }
    
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

// MARK: - AgoraEduSubRoomHandler
extension AgoraRoomStateUIController: AgoraEduSubRoomHandler {
    func onJoinSubRoomSuccess(roomInfo: AgoraEduContextRoomInfo) {
        setup()
    }
    
    func onSubRoomClosed() {
        AgoraAlertModel()
            .setTitle("fcr_room_class_over_notice".agedu_localized())
            .setMessage("fcr_room_class_over".agedu_localized())
            .addAction(action: AgoraAlertAction(title: "fcr_room_class_leave_sure".agedu_localized(), action: {
                self.roomDelegate?.exitClassRoom(reason: .normal,
                                                 roomType: .sub)
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

// MARK: - AgoraEduGroupHandler
extension AgoraRoomStateUIController: AgoraEduGroupHandler {
    func onGroupInfoUpdated(groupInfo: AgoraEduContextGroupInfo) {
        delegate?.onGroupStateChanged(groupInfo.state)
    }
    
    func onUserListInvitedToSubRoom(userList: Array<String>,
                                    subRoomUuid: String,
                                    operatorUser: AgoraEduContextUserInfo?) {
        let localUserId = contextPool.user.getLocalUserInfo().userUuid
        guard userList.contains(localUserId),
              let subRoomList = contextPool.group.getSubRoomList(),
              let subRoomInfo = subRoomList.first(where: {$0.subRoomUuid == subRoomUuid}) else {
            return
        }
        var str = "fcr_group_invitation".agedu_localized()
        let final = str.replacingOccurrences(of: String.agedu_localized_replacing(),
                                             with: subRoomInfo.subRoomName)
        AgoraAlertModel()
            .setTitle("fcr_group_join".agedu_localized())
            .setMessage(final)
            .addAction(action: AgoraAlertAction(title: "fcr_group_button_later".agedu_localized(), action:nil))
            .addAction(action: AgoraAlertAction(title: "fcr_group_button_join".agedu_localized(), action: { [weak self] in
                self?.contextPool.group.userListAcceptInvitationToSubRoom(userList: [localUserId],
                                                                          subRoomUuid: subRoomUuid,
                                                                          success: nil,
                                                                          failure: nil)
            }))
            .show(in: self)
    }
    
    func onUserListRejectedToSubRoom(userList: [String],
                                      subRoomUuid: String,
                                      operatorUser: AgoraEduContextUserInfo?) {
        guard let teacher = contextPool.user.getUserList(role: .teacher)?.first else {
            return
        }
        
        let teacherId = teacher.userUuid
        
        guard userList.contains(teacherId) else {
            return
        }
        
        AgoraToast.toast(msg: "fcr_group_help_teacher_busy_msg".agedu_localized(),
                         type: .warning)
    }
    
    func onUserListAddedToSubRoom(userList: Array<String>,
                                  subRoomUuid: String,
                                  operatorUser: AgoraEduContextUserInfo?) {
        let localUserId = contextPool.user.getLocalUserInfo().userUuid
        guard userList.contains(localUserId) else {
            return
        }
        delegate?.onLocalUserAddedToSubRoom(subRoomId: subRoomUuid)
    }
    
    func onUserMovedToSubRoom(userUuid: String,
                              fromSubRoomUuid: String,
                              toSubRoomUuid: String,
                              operatorUser: AgoraEduContextUserInfo?) {
        // 主房间消息
        let localUserId = contextPool.user.getLocalUserInfo().userUuid
        guard userUuid == localUserId else {
            return
        }
        delegate?.onLocalUserRemovedFromSubRoom(subRoomId: fromSubRoomUuid)
        delegate?.onLocalUserAddedToSubRoom(subRoomId: toSubRoomUuid)
    }
    
    func onUserListRemovedFromSubRoom(userList: Array<AgoraEduContextSubRoomRemovedUserEvent>,
                                      subRoomUuid: String) {
        let localUserId = contextPool.user.getLocalUserInfo().userUuid
        let list = userList.map({ return $0.userUuid })
        
        guard list.contains(localUserId) else {
            return
        }
        
        delegate?.onLocalUserRemovedFromSubRoom(subRoomId: subRoomUuid)
    }
    
    func onSubRoomListRemoved(subRoomList: Array<AgoraEduContextSubRoomInfo>) {
        let localUserId = contextPool.user.getLocalUserInfo().userUuid
        
        for room in subRoomList {
            let roomId = room.subRoomUuid
            
            guard let userList = contextPool.group.getUserListFromSubRoom(subRoomUuid: roomId) else {
                return
            }
            
            if userList.contains(localUserId) {
                delegate?.onLocalUserRemovedFromSubRoom(subRoomId: roomId)
            }
        }
    }
}

// MARK: - Creations
private extension AgoraRoomStateUIController {
    func createViews() {
        let ui = AgoraUIGroup()
        view.backgroundColor = .white
        view.layer.borderWidth = ui.frame.room_state_border_width
        view.layer.borderColor = ui.color.small_room_state_border_color
        view.layer.cornerRadius = ui.frame.room_state_corner_radius
        view.clipsToBounds = true
        
        stateView = AgoraRoomStateBar(frame: .zero)
        stateView.backgroundColor = ui.color.room_state_bg_color
        
        var roomTitle = ""
        switch contextPool.room.getRoomInfo().roomType {
        case .oneToOne: roomTitle = "fcr_room_one_to_one_title".agedu_localized()
        case .small:    roomTitle = "fcr_room_small_title".agedu_localized()
        case .lecture:  roomTitle = "fcr_room_lecture_title".agedu_localized()
        }
        self.stateView.titleLabel.text = roomTitle
        
        stateView.titleLabel.textColor = ui.color.room_state_label_before_color
        stateView.timeLabel.textColor = ui.color.room_state_label_before_color
        
        view.addSubview(stateView)
    }
    
    func createConstraint() {
        stateView.mas_makeConstraints { make in
            make?.left.right().top().bottom().equalTo()(0)
        }
    }
}
