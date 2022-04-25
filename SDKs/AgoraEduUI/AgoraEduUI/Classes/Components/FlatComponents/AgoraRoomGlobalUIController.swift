//
//  AgoraRoomGlobalUIController.swift
//  AgoraEduUI
//
//  Created by DoubleCircle on 2022/4/25.
//

import AgoraUIBaseViews
import AgoraEduContext
import FLAnimatedImage
import AudioToolbox

protocol AgoraRoomGlobalUIControllerDelegate: NSObjectProtocol {
    func onLocalUserAddedToSubRoom(subRoomId: String)
    func onLocalUserRemovedFromSubRoom(subRoomId: String)
    func onGroupStateChanged(_ state: Bool)
}

// 作为全局状态监听，展示toast，动图等，自身不包含UI
class AgoraRoomGlobalUIController: UIViewController {
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
    // data
    public weak var roomDelegate: AgoraClassRoomManagement?
    
    private weak var delegate: AgoraRoomGlobalUIControllerDelegate?
    
    private var localStream: AgoraEduContextStreamInfo?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if let `subRoom` = subRoom {
            subRoom.registerSubRoomEventHandler(self)
        } else {
            contextPool.group.registerGroupEventHandler(self)
        }
        
        contextPool.room.registerRoomEventHandler(self)
        userController.registerUserEventHandler(self)
        streamController.registerStreamEventHandler(self)
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
    
    func showRewardAnimation() {
        showReward()
    }
    
    init(context: AgoraEduContextPool,
         delegate: AgoraRoomGlobalUIControllerDelegate?,
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
}

// MARK: - AgoraEduRoomHandler
extension AgoraRoomGlobalUIController: AgoraEduRoomHandler {
    func onJoinRoomSuccess(roomInfo: AgoraEduContextRoomInfo) {
        setUp()
        checkNeedJoinSubRoom()
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
extension AgoraRoomGlobalUIController: AgoraEduSubRoomHandler {
    func onJoinSubRoomSuccess(roomInfo: AgoraEduContextRoomInfo) {
        setUp()
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

// MARK: - AgoraEduUserHandler
extension AgoraRoomGlobalUIController: AgoraEduUserHandler {
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
        if let _ = userList.first(where: {$0.userUuid == localUUID}),
           let op = operatorUser,
           op.userRole == .teacher {
            // 老师邀请你上台了，与大家积极互动吧
            AgoraToast.toast(msg: "fcr_user_local_start_co_hosting".agedu_localized(),
                             type: .notice)
        }
    }
    
    func onCoHostUserListRemoved(userList: [AgoraEduContextUserInfo],
                                 operatorUser: AgoraEduContextUserInfo?) {
        let localUUID = contextPool.user.getLocalUserInfo().userUuid
        if let _ = userList.first(where: {$0.userUuid == localUUID}),
           toastFlag(uid: localUUID) {
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

// MARK: - AgoraEduMonitorHandler
extension AgoraRoomGlobalUIController: AgoraEduMonitorHandler {
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
extension AgoraRoomGlobalUIController: AgoraEduGroupHandler {
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

// MARK: - AgoraEduStreamContext
extension AgoraRoomGlobalUIController: AgoraEduStreamHandler {
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

private extension AgoraRoomGlobalUIController {
    func setUp() {
        let user = contextPool.user.getLocalUserInfo()
        guard let streams = contextPool.stream.getStreamList(userUuid: user.userUuid) else {
            return
        }
        
        for stream in streams where stream.videoSourceType == .camera {
            localStream = stream
        }
    }
    
    func showReward() {
        guard let url = Bundle.agoraEduUI().url(forResource: "img_reward", withExtension: "gif"),
              let data = try? Data(contentsOf: url) else {
            return
        }
        let animatedImage = FLAnimatedImage(animatedGIFData: data)
        let imageView = FLAnimatedImageView()
        imageView.animatedImage = animatedImage
        imageView.loopCompletionBlock = {[weak imageView] (loopCountRemaining) -> Void in
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
        guard let rewardUrl = Bundle.agoraEduUI().url(forResource: "sound_reward",
                                                      withExtension: "mp3") else {
            return
        }
        
        var soundId: SystemSoundID = 0;
        AudioServicesCreateSystemSoundID(rewardUrl as CFURL,
                                         &soundId);
        AudioServicesAddSystemSoundCompletion(soundId, nil, nil, {
            (soundId, clientData) -> Void in
            AudioServicesDisposeSystemSoundID(soundId)
        }, nil)
        AudioServicesPlaySystemSound(soundId)
    }
    
    func toastFlag(uid: String) -> Bool {
        var flag = true
        let groupState = contextPool.group.getGroupInfo().state
        if groupState,
           subRoom == nil,
           let subRoomList = contextPool.group.getSubRoomList() {
            for item in subRoomList {
                if let userList = contextPool.group.getUserListFromSubRoom(subRoomUuid: item.subRoomUuid),
                   userList.contains(uid) {
                    flag = false
                    break
                }
            }
        }

        return flag
    }
}
