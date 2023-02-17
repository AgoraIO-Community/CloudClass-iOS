//
//  AgoraRoomGlobalUIController.swift
//  AgoraEduUI
//
//  Created by DoubleCircle on 2022/4/25.
//

import AgoraUIBaseViews
import AgoraEduCore
import AudioToolbox

protocol FcrRoomGlobalUIComponentDelegate: NSObjectProtocol {
    func onAreaUpdated(type: FcrAreaViewType)
    
    func onLocalUserAddedToSubRoom(subRoomId: String)
    
    func onLocalUserRemovedFromSubRoom(subRoomId: String,
                                       isKickOut: Bool)
}

extension FcrRoomGlobalUIComponentDelegate {
    func onAreaUpdated(type: FcrAreaViewType) {
        
    }
    
    func onLocalUserAddedToSubRoom(subRoomId: String) {
        
    }
    
    func onLocalUserRemovedFromSubRoom(subRoomId: String,
                                       isKickOut: Bool) {
        
    }
}

// 作为全局状态监听，展示toast，动图等，自身不包含UI
class FcrRoomGlobalUIComponent: FcrUIComponent {
    /** SDK环境*/
    private let roomController: AgoraEduRoomContext
    private let monitorController: AgoraEduMonitorContext
    private let userController: AgoraEduUserContext
    private let groupController: AgoraEduGroupContext
    private let streamController: AgoraEduStreamContext
    private var subRoom: AgoraEduSubRoomContext?
    
    // data
    public weak var exitDelegate: FcrUISceneExit?
    private weak var delegate: FcrRoomGlobalUIComponentDelegate?
    
    private(set) var area = FcrAreaViewType.none
    
    private let areaKey = "area"
    
    private var localStream: AgoraEduContextStreamInfo?
    private var hasJoinedSubRoomId: String?
    
    var isRequestingHelp: Bool = false
    
    init(roomController: AgoraEduRoomContext,
         userController: AgoraEduUserContext,
         monitorController: AgoraEduMonitorContext,
         streamController: AgoraEduStreamContext,
         groupController: AgoraEduGroupContext,
         subRoom: AgoraEduSubRoomContext? = nil,
         delegate: FcrRoomGlobalUIComponentDelegate? = nil,
         exitDelegate: FcrUISceneExit?) {
        self.roomController = roomController
        self.userController = userController
        self.monitorController = monitorController
        self.streamController = streamController
        self.groupController = groupController
        self.subRoom = subRoom
        
        self.delegate = delegate
        self.exitDelegate = exitDelegate
        
        super.init(nibName: nil,
                   bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if let `subRoom` = subRoom {
            subRoom.registerSubRoomEventHandler(self)
        } else {
            roomController.registerRoomEventHandler(self)
        }
        
        monitorController.registerMonitorEventHandler(self)
        groupController.registerGroupEventHandler(self)
    }
}

// MARK: - AgoraUIActivity
extension FcrRoomGlobalUIComponent: AgoraUIActivity {
    func viewWillActive() {
        userController.registerUserEventHandler(self)
        streamController.registerStreamEventHandler(self)
        
        initData()
    }
    
    func viewWillInactive() {
        userController.unregisterUserEventHandler(self)
        streamController.unregisterStreamEventHandler(self)
    }
}

// MARK: - AgoraEduRoomHandler
extension FcrRoomGlobalUIComponent: AgoraEduRoomHandler {
    func onJoinRoomSuccess(roomInfo: AgoraEduContextRoomInfo) {
        viewWillActive()
        checkNeedJoinSubRoom()
        ifAreaChanged()
    }
    
    func onRoomClosed() {
        let title = "fcr_room_class_over_notice".edu_ui_localized()
        let content = "fcr_room_class_over".edu_ui_localized()
        let actionTitle = "fcr_room_class_leave_sure".edu_ui_localized()
        
        let action = AgoraAlertAction(title: actionTitle) { [weak self] _ in
            self?.exitDelegate?.exitScene(reason: .normal,
                                          type: .main)
        }
        
        showAlert(title: title,
                  contentList: [content],
                  actions: [action])
    }
    
    func onRoomPropertiesUpdated(changedProperties: [String : Any],
                                 cause: [String : Any]?,
                                 operatorUser: AgoraEduContextUserInfo?) {
        let keys = changedProperties.keys
        
        guard keys.contains(areaKey) else {
            return
        }
        
        ifAreaChanged()
    }
}

extension FcrRoomGlobalUIComponent: AgoraEduSubRoomHandler {
    func onJoinSubRoomSuccess(roomInfo: AgoraEduContextSubRoomInfo) {
        viewWillActive()
    }
}

// MARK: - AgoraEduUserHandler
extension FcrRoomGlobalUIComponent: AgoraEduUserHandler {
    func onLocalUserKickedOut() {
        let title = "fcr_user_local_kick_out_notice".edu_ui_localized()
        let content = "fcr_user_local_kick_out".edu_ui_localized()
        let actionTitle = "fcr_room_class_leave_sure".edu_ui_localized()
        
        let action = AgoraAlertAction(title: actionTitle) { [weak self] _ in
            self?.exitDelegate?.exitScene(reason: .kickOut,
                                          type: .main)
        }
        
        showAlert(title: title,
                  contentList: [content],
                  actions: [action])
    }
    
    func onCoHostUserListAdded(userList: [AgoraEduContextUserInfo],
                               operatorUser: AgoraEduContextUserInfo?) {
        let userId = userController.getLocalUserInfo().userUuid
        let list = userList.map( {$0.userUuid } )
        
        guard list.contains(userId),
              let `operatorUser` = operatorUser,
              operatorUser.userRole == .teacher else {
            return
        }
        
        let message = "fcr_user_local_start_co_hosting".edu_ui_localized()
        
        AgoraToast.toast(message: message,
                         type: .notice)
    }
    
    func onCoHostUserListRemoved(userList: [AgoraEduContextUserInfo],
                                 operatorUser: AgoraEduContextUserInfo?) {
        let userId = userController.getLocalUserInfo().userUuid
        let list = userList.map( {$0.userUuid} )
        
        guard list.contains(userId) else {
            return
        }
        
        // 你离开讲台了，暂时无法与大家互动
        let message = "fcr_user_local_stop_co_hosting".edu_ui_localized()
        
        AgoraToast.toast(message: message,
                         type: .error)
    }
    
    func onUserRewarded(user: AgoraEduContextUserInfo,
                        rewardCount: Int,
                        operatorUser: AgoraEduContextUserInfo?) {
        // 祝贺**获得奖励
        let message = "fcr_user_congratulation".edu_ui_localized()
        let final = message.replacingOccurrences(of: String.edu_ui_localized_replacing_x(),
                                                 with: user.userName)
        AgoraToast.toast(message: final,
                         type: .notice)
        
        showReward()
    }
}

// MARK: - AgoraEduMonitorHandler
extension FcrRoomGlobalUIComponent: AgoraEduMonitorHandler {
    func onLocalConnectionUpdated(state: AgoraEduContextConnectionState) {
        switch state {
        case .aborted:
            // 踢出
            AgoraLoading.hide()
            
            let message = "fcr_monitor_login_remote_device".edu_ui_localized()
            
            AgoraToast.toast(message: message,
                             type: .error)
            
            self.exitDelegate?.exitScene(reason: .kickOut,
                                         type: .main)
        case .connecting:
            let message = "fcr_room_loading".edu_ui_localized()
            AgoraLoading.loading(message: message)
        case .disconnected, .reconnecting:
            let toastMessage = "fcr_monitor_network_disconnected".edu_ui_localized()
            AgoraToast.toast(message: toastMessage,
                             type: .error)
            
            let loadingMessage = "fcr_monitor_network_reconnecting".edu_ui_localized()
            AgoraLoading.loading(message: loadingMessage)
        case .connected:
            AgoraLoading.hide()
        }
    }
    
    func onLocalNetworkQualityUpdated(quality: AgoraEduContextNetworkQuality) {
        switch quality {
        case .bad:
            let toastMessage = "fcr_monitor_network_poor".edu_ui_localized()
            AgoraToast.toast(message: toastMessage,
                             type: .error)
        default:
            break
        }
    }
}

// MARK: - AgoraEduGroupHandler
extension FcrRoomGlobalUIComponent: AgoraEduGroupHandler {
    func onGroupInfoUpdated(groupInfo: AgoraEduContextGroupInfo) {
        guard !groupInfo.state,
              subRoom == nil else {
            return
        }
        AgoraToast.toast(message: "fcr_group_close_group".edu_ui_localized(),
                         type: .warning)
    }
    
    func onUserListInvitedToSubRoom(userList: [String],
                                    subRoomUuid: String,
                                    operatorUser: AgoraEduContextUserInfo?) {
        let localUserId = userController.getLocalUserInfo().userUuid
        
        guard userList.contains(localUserId),
              let subRoomList = groupController.getSubRoomList(),
              let subRoomInfo = subRoomList.first(where: {$0.subRoomUuid == subRoomUuid}) else {
            return
        }
        
        var message = "fcr_group_invitation".edu_ui_localized()
        let final = message.replacingOccurrences(of: String.edu_ui_localized_replacing_x(),
                                                 with: subRoomInfo.subRoomName)
        let title = "fcr_group_join".edu_ui_localized()
        
        let laterActionTitle = "fcr_group_button_later".edu_ui_localized()
        let laterAction = AgoraAlertAction(title: laterActionTitle)
        
        let joinActionTitle = "fcr_group_button_join".edu_ui_localized()
        
        let joinAction = AgoraAlertAction(title: joinActionTitle) { [weak self] _ in
            self?.groupController.userListAcceptInvitationToSubRoom(userList: [localUserId],
                                                                     subRoomUuid: subRoomUuid,
                                                                     success: nil,
                                                                     failure: nil)
        }
        
        showAlert(title: title,
                  contentList: [final],
                  actions: [laterAction, joinAction])
    }
    
    func onUserListAddedToSubRoom(userList: [String],
                                  subRoomUuid: String,
                                  operatorUser: AgoraEduContextUserInfo?) {
        let localUserId = userController.getLocalUserInfo().userUuid
        
        if userList.contains(localUserId) {
            hasJoinedSubRoomId = subRoomUuid
            
            delegate?.onLocalUserAddedToSubRoom(subRoomId: subRoomUuid)
            return
        }
        
        guard hasJoinedSubRoomId == subRoomUuid else {
            return
        }
        
        for userId in userList {
            guard let userInfo = userController.getUserInfo(userUuid: userId),
                  let roleString = userInfo.userRole.stringValue
            else {
                return
            }
            
            let message = "fcr_group_enter_group".edu_ui_localized()
            
            var temp = message.replacingOccurrences(of: String.edu_ui_localized_replacing_x(),
                                                     with: roleString)
            
            var final = temp.replacingOccurrences(of: String.edu_ui_localized_replacing_y(),
                                                  with: userInfo.userName)
            
            AgoraToast.toast(message: final,
                             type: .notice)
        }
    }
    
    func onUserListRemovedFromSubRoom(userList: [AgoraEduContextSubRoomRemovedUserEvent],
                                      subRoomUuid: String) {
        let localUserId = userController.getLocalUserInfo().userUuid
        
        for event in userList where event.userUuid == localUserId {
            hasJoinedSubRoomId = nil
            
            let isKickOut = (event.reason == .kickOut)
            delegate?.onLocalUserRemovedFromSubRoom(subRoomId: subRoomUuid,
                                                    isKickOut: isKickOut)
        }
        
        guard hasJoinedSubRoomId == subRoomUuid,
              let _ = subRoom
        else {
            return
        }
        
        let userIdList = userList.map({return $0.userUuid})
        
        for userId in userIdList {
            guard let userInfo = userController.getUserInfo(userUuid: userId),
                  let roleString = userInfo.userRole.stringValue
            else {
                return
            }
            
            let message = "fcr_group_exit_group".edu_ui_localized()
            
            var temp = message.replacingOccurrences(of: String.edu_ui_localized_replacing_x(),
                                                     with: roleString)
            
            var final = temp.replacingOccurrences(of: String.edu_ui_localized_replacing_y(),
                                                  with: userInfo.userName)
            
            AgoraToast.toast(message: final,
                             type: .warning)
        }
    }
    
    func onSubRoomListAdded(subRoomList: [AgoraEduContextSubRoomInfo]) {
        let localUserId = userController.getLocalUserInfo().userUuid
        
        for subRoom in subRoomList {
            guard let list = groupController.getUserListFromSubRoom(subRoomUuid: subRoom.subRoomUuid),
                  list.contains(localUserId)
            else {
                continue
            }
        
            hasJoinedSubRoomId = subRoom.subRoomUuid
            
            delegate?.onLocalUserAddedToSubRoom(subRoomId: subRoom.subRoomUuid)
            break
        }
    }
    
    func onSubRoomListRemoved(subRoomList: [AgoraEduContextSubRoomInfo]) {
        let list = subRoomList.map( {$0.subRoomUuid} )
        
        guard let hasJoined = hasJoinedSubRoomId,
              list.contains(hasJoined)
        else {
            return
        }
        
        hasJoinedSubRoomId = nil
        
        delegate?.onLocalUserRemovedFromSubRoom(subRoomId: hasJoined,
                                                isKickOut: false)
    }
    
    func onUserListRejectedToSubRoom(userList: [String],
                                     subRoomUuid: String,
                                     operatorUser: AgoraEduContextUserInfo?) {
        guard isRequestingHelp,
              let teacherUserId = userController.getUserList(role: .teacher)?.first?.userUuid,
              userList.contains(teacherUserId)
        else {
            return
        }
        
        isRequestingHelp = false
        
        let confirmAction = AgoraAlertAction(title: "fcr_group_sure".edu_ui_localized())
        
        let title = "fcr_group_help_title".edu_ui_localized()
        let content = "fcr_group_help_teacher_busy_msg".edu_ui_localized()
        
        showAlert(title: title,
                  contentList: [content],
                  actions: [confirmAction])
    }
}

// MARK: - AgoraEduStreamContext
extension FcrRoomGlobalUIComponent: AgoraEduStreamHandler {
    func onStreamJoined(stream: AgoraEduContextStreamInfo,
                        operatorUser: AgoraEduContextUserInfo?) {
        let userId = userController.getLocalUserInfo().userUuid
        
        guard stream.owner.userUuid == userId else {
            return
        }
        
        localStream = stream
    }
    
    func onStreamLeft(stream: AgoraEduContextStreamInfo,
                      operatorUser: AgoraEduContextUserInfo?) {
        let userId = userController.getLocalUserInfo().userUuid
        
        guard stream.owner.userUuid == userId else {
            return
        }
        
        localStream = nil
    }
    
    func onStreamUpdated(stream: AgoraEduContextStreamInfo,
                         operatorUser: AgoraEduContextUserInfo?) {
        let userId = userController.getLocalUserInfo().userUuid
        
        guard stream.owner.userUuid == userId else {
            return
        }
        
        guard let `localStream` = localStream else {
            self.localStream = stream
            return
        }
        
        if localStream.streamType.hasAudio != stream.streamType.hasAudio {
            if stream.streamType.hasAudio {
                let message = "fcr_stream_start_audio".edu_ui_localized()
                
                AgoraToast.toast(message: message,
                                 type: .notice)
            } else {
                let message = "fcr_stream_stop_audio".edu_ui_localized()
                
                AgoraToast.toast(message: message,
                                 type: .error)
            }
        }
        
        if localStream.streamType.hasVideo != stream.streamType.hasVideo {
            if stream.streamType.hasVideo {
                let message = "fcr_stream_start_video".edu_ui_localized()
                
                AgoraToast.toast(message: message,
                                 type: .notice)
            } else {
                let message = "fcr_stream_stop_video".edu_ui_localized()
                
                AgoraToast.toast(message: message,
                                 type: .error)
            }
        }
        
        self.localStream = stream
    }
}

private extension FcrRoomGlobalUIComponent {
    func initData() {
        let user = userController.getLocalUserInfo()
        
        guard let streams = streamController.getStreamList(userUuid: user.userUuid) else {
            return
        }
        
        for stream in streams where stream.videoSourceType == .camera {
            localStream = stream
            break
        }
    }
    
    func showReward() {
        guard let url = Bundle.edu_ui_bundle().url(forResource: "img_reward",
                                                withExtension: "gif"),
              let data = try? Data(contentsOf: url) else {
            return
        }
        
        let animatedImage = AGAnimatedImage(animatedGIFData: data)
        let imageView = AGAnimatedImageView()
        imageView.animatedImage = animatedImage
        imageView.loopCompletionBlock = { [weak imageView] (loopCountRemaining) -> Void in
            imageView?.removeFromSuperview()
        }
        
        if let window = UIApplication.shared.keyWindow {
            window.addSubview(imageView)
            imageView.mas_makeConstraints { make in
                make?.center.equalTo()(0)
                make?.width.equalTo()(AgoraFit.scale(238))
                make?.height.equalTo()(AgoraFit.scale(238))
            }
        }
        
        // sounds
        guard let rewardUrl = Bundle.edu_ui_bundle().url(forResource: "sound_reward",
                                                      withExtension: "mp3") else {
            return
        }
        
        var soundId: SystemSoundID = 0;
        AudioServicesCreateSystemSoundID(rewardUrl as CFURL,
                                         &soundId)
        
        AudioServicesAddSystemSoundCompletion(soundId,
                                              nil,
                                              nil, { (soundId, clientData) -> Void in
                                                AudioServicesDisposeSystemSoundID(soundId)
                                              }, nil)
        AudioServicesPlaySystemSound(soundId)
    }
    
    func checkNeedJoinSubRoom() {
        guard let subRoomList = groupController.getSubRoomList() else {
            return
        }
        
        let localUserId = userController.getLocalUserInfo().userUuid
        
        for subRoom in subRoomList {
            let list = groupController.getUserListFromSubRoom(subRoomUuid: subRoom.subRoomUuid)
            
            guard let `list` = list,
                  list.contains(localUserId) else {
                continue
            }
        
            hasJoinedSubRoomId = subRoom.subRoomUuid
            
            delegate?.onLocalUserAddedToSubRoom(subRoomId: subRoom.subRoomUuid)
            break
        }
    }
    
    // MARK: - Area
    func areaChanged(with roomProperties: [String: Any]) {
        guard let areaInt = ValueTransform(value: roomProperties[areaKey],
                                           result: Int.self)
        else {
            return
        }
        
        let area = FcrAreaViewType(rawValue: areaInt)
        
        self.area = area
        
        delegate?.onAreaUpdated(type: area)
    }
    
    func ifAreaChanged() {
        var roomProperties: [String: Any]?
        
        if let `subRoom` = subRoom {
            roomProperties = subRoom.getSubRoomProperties()
        } else {
            roomProperties = roomController.getRoomProperties()
        }
        
        guard let properties = roomProperties else {
            return
        }
        
        areaChanged(with: properties)
    }
}
