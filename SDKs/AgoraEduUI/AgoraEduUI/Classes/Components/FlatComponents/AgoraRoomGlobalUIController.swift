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
    func onLocalUserRemovedFromSubRoom(subRoomId: String,
                                       isKickOut: Bool)
}

// 作为全局状态监听，展示toast，动图等，自身不包含UI
class AgoraRoomGlobalUIController: UIViewController, AgoraUIActivity {
    /** SDK环境*/
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
    
    private var contextPool: AgoraEduContextPool
    private var subRoom: AgoraEduSubRoomContext?
    
    // data
    public weak var roomDelegate: AgoraClassRoomManagement?
    private weak var delegate: AgoraRoomGlobalUIControllerDelegate?
    
    private var localStream: AgoraEduContextStreamInfo?
    private var hasJoinedSubRoomId: String?
    
    init(context: AgoraEduContextPool,
         delegate: AgoraRoomGlobalUIControllerDelegate?,
         subRoom: AgoraEduSubRoomContext? = nil) {
        self.contextPool = context
        self.delegate = delegate
        self.subRoom = subRoom
        
        super.init(nibName: nil,
                   bundle: nil)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if let `subRoom` = subRoom {
            subRoom.registerSubRoomEventHandler(self)
        }
        
        contextPool.room.registerRoomEventHandler(self)
        contextPool.group.registerGroupEventHandler(self)
    }
    
    func viewWillActive() {
        userController.registerUserEventHandler(self)
        streamController.registerStreamEventHandler(self)
        
        setup()
        checkNeedJoinSubRoom()
    }
    
    func viewWillInactive() {
        userController.unregisterUserEventHandler(self)
        streamController.unregisterStreamEventHandler(self)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    public override var shouldAutorotate: Bool {
        return true
    }
    
    public override var preferredInterfaceOrientationForPresentation: UIInterfaceOrientation {
        return .landscapeRight
    }
    
    public override var supportedInterfaceOrientations: UIInterfaceOrientationMask {
        return .landscapeRight
    }
}

// MARK: - AgoraEduRoomHandler
extension AgoraRoomGlobalUIController: AgoraEduRoomHandler {
    func onJoinRoomSuccess(roomInfo: AgoraEduContextRoomInfo) {
        viewWillActive()
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

extension AgoraRoomGlobalUIController: AgoraEduSubRoomHandler {
    func onJoinSubRoomSuccess(roomInfo: AgoraEduContextRoomInfo) {
        viewWillActive()
    }
}

// MARK: - AgoraEduUserHandler
extension AgoraRoomGlobalUIController: AgoraEduUserHandler {
    func onLocalUserKickedOut() {
        let action = AgoraAlertAction(title: "fcr_room_class_leave_sure".agedu_localized(), action: {
            self.roomDelegate?.exitClassRoom(reason: .kickOut,
                                             roomType: .main)
        })
        
        let title = "fcr_user_local_kick_out_notice".agedu_localized()
        let message = "fcr_user_local_kick_out".agedu_localized()
        
        AgoraAlertModel()
            .setTitle(title)
            .setMessage(message)
            .addAction(action: action)
            .show(in: self)
    }
    
    func onCoHostUserListAdded(userList: [AgoraEduContextUserInfo],
                               operatorUser: AgoraEduContextUserInfo?) {
        let userId = contextPool.user.getLocalUserInfo().userUuid
        let list = userList.map( {$0.userUuid } )
        
        guard list.contains(userId),
              let `operatorUser` = operatorUser,
              operatorUser.userRole == .teacher else {
            return
        }
        
        // 老师邀请你上台了，与大家积极互动吧
        let message = "fcr_user_local_start_co_hosting".agedu_localized()
        
        AgoraToast.toast(msg: message,
                         type: .notice)
    }
    
    func onCoHostUserListRemoved(userList: [AgoraEduContextUserInfo],
                                 operatorUser: AgoraEduContextUserInfo?) {
        let userId = contextPool.user.getLocalUserInfo().userUuid
        let list = userList.map( {$0.userUuid} )
        
        guard list.contains(userId) else {
            return
        }
        
        // 你离开讲台了，暂时无法与大家互动
        let message = "fcr_user_local_stop_co_hosting".agedu_localized()
        
        AgoraToast.toast(msg: message,
                         type: .error)
    }
    
    func onUserRewarded(user: AgoraEduContextUserInfo,
                        rewardCount: Int,
                        operatorUser: AgoraEduContextUserInfo?) {
        // 祝贺**获得奖励
        let message = "fcr_user_congratulation".agedu_localized()
        let final = message.replacingOccurrences(of: String.agedu_localized_replacing(),
                                                 with: user.userName)
        AgoraToast.toast(msg: final,
                         type: .notice)
        
        showReward()
    }
}

// MARK: - AgoraEduMonitorHandler
extension AgoraRoomGlobalUIController: AgoraEduMonitorHandler {
    func onLocalConnectionUpdated(state: AgoraEduContextConnectionState) {
        switch state {
        case .aborted:
            // 踢出
            AgoraLoading.hide()
            
            let message = "fcr_monitor_login_remote_device".agedu_localized()
            
            AgoraToast.toast(msg: message,
                             type: .error)
            
            self.roomDelegate?.exitClassRoom(reason: .kickOut,
                                             roomType: .main)
        case .connecting:
            let message = "fcr_room_loading".agedu_localized()
            AgoraLoading.loading(msg: message)
        case .disconnected, .reconnecting:
            let toastMessage = "fcr_monitor_network_disconnected".agedu_localized()
            AgoraToast.toast(msg: toastMessage,
                             type: .error)
            
            let loadingMessage = "fcr_monitor_network_reconnecting".agedu_localized()
            AgoraLoading.loading(msg: loadingMessage)
        case .connected:
            AgoraLoading.hide()
        }
    }
}

// MARK: - AgoraEduGroupHandler
extension AgoraRoomGlobalUIController: AgoraEduGroupHandler {
    func onUserListInvitedToSubRoom(userList: Array<String>,
                                    subRoomUuid: String,
                                    operatorUser: AgoraEduContextUserInfo?) {
        let localUserId = contextPool.user.getLocalUserInfo().userUuid
        
        guard userList.contains(localUserId),
              let subRoomList = contextPool.group.getSubRoomList(),
              let subRoomInfo = subRoomList.first(where: {$0.subRoomUuid == subRoomUuid}) else {
            return
        }
        
        var message = "fcr_group_invitation".agedu_localized()
        let final = message.replacingOccurrences(of: String.agedu_localized_replacing(),
                                                 with: subRoomInfo.subRoomName)
        let title = "fcr_group_join".agedu_localized()
        
        let laterActionTitle = "fcr_group_button_later".agedu_localized()
        let laterAction = AgoraAlertAction(title: laterActionTitle)
        
        let joinActionTitle = "fcr_group_button_join".agedu_localized()
        let joinAction = AgoraAlertAction(title: joinActionTitle,
                                          action: { [weak self] in
                                            let group = self?.contextPool.group
                                            
                                            group?.userListAcceptInvitationToSubRoom(userList: [localUserId],
                                                                                     subRoomUuid: subRoomUuid,
                                                                                     success: nil,
                                                                                     failure: nil)
                                          })
        
        AgoraAlertModel()
            .setTitle(title)
            .setMessage(final)
            .addAction(action: laterAction)
            .addAction(action: joinAction)
            .show(in: self)
    }
    
    func onUserListAddedToSubRoom(userList: [String],
                                  subRoomUuid: String,
                                  operatorUser: AgoraEduContextUserInfo?) {
        let localUserId = contextPool.user.getLocalUserInfo().userUuid
        
        guard userList.contains(localUserId) else {
            return
        }
        
        hasJoinedSubRoomId = subRoomUuid
        
        delegate?.onLocalUserAddedToSubRoom(subRoomId: subRoomUuid)
    }
    
    func onUserListRemovedFromSubRoom(userList: [AgoraEduContextSubRoomRemovedUserEvent],
                                      subRoomUuid: String) {
        let localUserId = contextPool.user.getLocalUserInfo().userUuid
        
        for event in userList where event.userUuid == localUserId {
            hasJoinedSubRoomId = nil
            
            let isKickOut = (event.reason == .kickOut)
            delegate?.onLocalUserRemovedFromSubRoom(subRoomId: subRoomUuid,
                                                    isKickOut: isKickOut)
        }
    }
    
    func onSubRoomListAdded(subRoomList: [AgoraEduContextSubRoomInfo]) {
        let localUserId = contextPool.user.getLocalUserInfo().userUuid
        
        for subRoom in subRoomList {
            guard let list = contextPool.group.getUserListFromSubRoom(subRoomUuid: subRoom.subRoomUuid),
               list.contains(localUserId) else {
               return
            }
        
            hasJoinedSubRoomId = subRoom.subRoomUuid
            
            delegate?.onLocalUserAddedToSubRoom(subRoomId: subRoom.subRoomUuid)
            break
        }
    }
    
    func onSubRoomListRemoved(subRoomList: [AgoraEduContextSubRoomInfo]) {
        let list = subRoomList.map( {$0.subRoomUuid} )
        
        guard let hasJoined = hasJoinedSubRoomId,
              list.contains(hasJoined) else {
            return
        }
        
        hasJoinedSubRoomId = nil
        
        delegate?.onLocalUserRemovedFromSubRoom(subRoomId: hasJoined,
                                                isKickOut: false)
    }
}

// MARK: - AgoraEduStreamContext
extension AgoraRoomGlobalUIController: AgoraEduStreamHandler {
    func onStreamJoined(stream: AgoraEduContextStreamInfo,
                        operatorUser: AgoraEduContextUserInfo?) {
        let userId = contextPool.user.getLocalUserInfo().userUuid
        
        guard stream.owner.userUuid == userId else {
            return
        }
        
        localStream = stream
    }
    
    func onStreamLeft(stream: AgoraEduContextStreamInfo,
                      operatorUser: AgoraEduContextUserInfo?) {
        let userId = contextPool.user.getLocalUserInfo().userUuid
        
        guard stream.owner.userUuid == userId else {
            return
        }
        
        localStream = nil
    }
    
    func onStreamUpdated(stream: AgoraEduContextStreamInfo,
                         operatorUser: AgoraEduContextUserInfo?) {
        let userId = contextPool.user.getLocalUserInfo().userUuid
        
        guard stream.owner.userUuid == userId,
              stream.owner.userRole == .student else {
            return
        }
        
        guard let `localStream` = localStream else {
            self.localStream = stream
            return
        }
        
        if localStream.streamType.hasAudio != stream.streamType.hasAudio {
            if stream.streamType.hasAudio {
                let message = "fcr_stream_start_audio".agedu_localized()
                
                AgoraToast.toast(msg: message,
                                 type: .notice)
            } else {
                let message = "fcr_stream_stop_audio".agedu_localized()
                
                AgoraToast.toast(msg: message,
                                 type: .error)
            }
        }
        
        if localStream.streamType.hasVideo != stream.streamType.hasVideo {
            if stream.streamType.hasVideo {
                let message = "fcr_stream_start_video".agedu_localized()
                
                AgoraToast.toast(msg: message,
                                 type: .error)
            } else {
                let message = "fcr_stream_stop_video".agedu_localized()
                
                AgoraToast.toast(msg: message,
                                 type: .error)
            }
        }
        
        self.localStream = stream
    }
}

private extension AgoraRoomGlobalUIController {
    func setup() {
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
        guard let url = Bundle.agoraEduUI().url(forResource: "img_reward",
                                                withExtension: "gif"),
              let data = try? Data(contentsOf: url) else {
            return
        }
        
        let animatedImage = FLAnimatedImage(animatedGIFData: data)
        let imageView = FLAnimatedImageView()
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
        guard let rewardUrl = Bundle.agoraEduUI().url(forResource: "sound_reward",
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
        let group = contextPool.group
        
        guard let subRoomList = group.getSubRoomList() else {
            return
        }
        
        let localUserId = userController.getLocalUserInfo().userUuid
        
        for subRoom in subRoomList {
            guard let list = group.getUserListFromSubRoom(subRoomUuid: subRoom.subRoomUuid),
               list.contains(localUserId) else {
               continue
            }
        
            delegate?.onLocalUserAddedToSubRoom(subRoomId: subRoom.subRoomUuid)
            break
        }
    }
    
    func showRewardAnimation() {
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
}
