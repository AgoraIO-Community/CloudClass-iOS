//
//  PtExamUIComponent.swift
//  AgoraProctorUI
//
//  Created by LYY on 2022/9/1.
//

import AgoraUIBaseViews
import AgoraEduCore

@objc public protocol PtExamUIComponentDelegate: NSObjectProtocol {
    func onExamExit()
}

class PtExamUIComponent: PtUIComponent {
    /**view**/
    private lazy var contentView = PtExamView(frame: .zero)
    
    /**context**/
    private weak var delegate: PtExamUIComponentDelegate?
    private let contextPool: AgoraEduContextPool
    private var subRoom: AgoraEduSubRoomContext?
    
    /**data**/
    private var currentFront: Bool = true
    
    @objc public init(contextPool: AgoraEduContextPool,
                      delegate: PtExamUIComponentDelegate?) {
        self.contextPool = contextPool
        self.delegate = delegate
        
        super.init(nibName: nil,
                   bundle: nil)
    }
    
    public override func viewDidLoad() {
        super.viewDidLoad()
        
        initViews()
        initViewFrame()
        updateViewProperties()
        
        contextPool.room.registerRoomEventHandler(self)
        contextPool.group.registerGroupEventHandler(self)
        
        checkExamState(countdown: 0)
        setAvatarInfo()
        localSubRoomCheck()
    }
    
    public override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        contentView.animate()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

// MARK: - AgoraEduRoomHandler
extension PtExamUIComponent: AgoraEduRoomHandler {
    public func onClassStateUpdated(state: AgoraEduContextClassState) {
        checkExamState(countdown: 5)
    }
}

// MARK: - AgoraEduRoomHandler
extension PtExamUIComponent: AgoraEduUserHandler {
    public func onCoHostUserListAdded(userList: [AgoraEduContextUserInfo],
                                      operatorUser: AgoraEduContextUserInfo?) {
        // mostly happend when rtm reconnects successfully
        setupCohost()
    }
    
    public func onCoHostUserListRemoved(userList: [AgoraEduContextUserInfo],
                                        operatorUser: AgoraEduContextUserInfo?) {
        // mostly happend when rtm disconnects
        stopRenderLocalVideo()
    }
}

// MARK: - AgoraEduSubRoomHandler
extension PtExamUIComponent: AgoraEduSubRoomHandler {
    public func onJoinSubRoomSuccess(roomInfo: AgoraEduContextSubRoomInfo) {
        setupCohost()
    }
}

// MARK: - AgoraEduStreamHandler
extension PtExamUIComponent: AgoraEduStreamHandler {
    public func onStreamJoined(stream: AgoraEduContextStreamInfo,
                               operatorUser: AgoraEduContextUserInfo?) {
        startRenderLocalVideo()
    }
}

// MARK: - AgoraEduGroupHandler
extension PtExamUIComponent: AgoraEduGroupHandler {
    public func onSubRoomListAdded(subRoomList: [AgoraEduContextSubRoomInfo]) {
        guard let userIdPrefix = contextPool.user.getLocalUserInfo().userUuid.getUserIdPrefix(),
              let info = subRoomList.first(where: {$0.subRoomName == userIdPrefix}) else {
            return
        }
        
        joinSubRoom(info.subRoomUuid)
    }
}

// MARK: - AgoraUIContentContainer
extension PtExamUIComponent: AgoraUIContentContainer {
    public func initViews() {
        view.addSubview(contentView)
        
        contentView.exitButton.addTarget(self,
                                         action: #selector(onClickExitRoom),
                                         for: .touchUpInside)
        contentView.leaveButton.addTarget(self,
                                          action: #selector(onClickExitRoom),
                                          for: .touchUpInside)
        
        let userName = contextPool.user.getLocalUserInfo().userName
        contentView.nameLabel.text = userName
        let roomName = contextPool.room.getRoomInfo().roomName
        contentView.examNameLabel.text = roomName
        
        contentView.switchCameraButton.addTarget(self,
                                                 action: #selector(onClickSwitchCamera),
                                                 for: .touchUpInside)
    }
    
    public func initViewFrame() {
        contentView.mas_makeConstraints { make in
            make?.left.right().top().bottom().equalTo()(0)
        }
    }
    
    public func updateViewProperties() {
        let config = UIConfig.exam
        
        view.backgroundColor = config.backgroundColor
    }
}

// MARK: - private
private extension PtExamUIComponent {
    func checkExamState(countdown: Int = 0) {
        let classInfo = contextPool.room.getClassInfo()
        let state = classInfo.toExamState(countdown: countdown)
        contentView.updateViewWithState(state)
        
        guard classInfo.state == .after else {
            return
        }
        stopRenderLocalVideo()
    }
    
    @objc func onClickSwitchCamera() {
        let deviceType: AgoraEduContextSystemDevice = currentFront ? .backCamera : .frontCamera
        guard contextPool.media.openLocalDevice(systemDevice: deviceType) == nil else {
            return
        }
        currentFront = !currentFront
    }
    
    @objc func onClickExitRoom() {
        let roomState = contextPool.room.getClassInfo().state
        
        guard roomState != .after else {
            exit()
            return
        }
        
        let message = "pt_exam_prep_label_leave_exam".pt_localized()
        
        let config = UIConfig.alert.button
        
        let cancelTitle = "pt_sub_room_button_stay".pt_localized()
        let cancelAction = AgoraAlertAction(title: cancelTitle,
                                            titleColor: config.normalTitleColor,
                                            backgroundColor: config.normalBackgroundColor)
        
        let leaveTitle = "pt_sub_room_button_leave".pt_localized()
        let leaveAction = AgoraAlertAction(title: leaveTitle,
                                           titleColor: config.highlightTitleColor,
                                           backgroundColor: config.highlightBackgroundColor) { [weak self] _ in
            self?.exit()
        }
        
        showAlert(contentList: [message],
                  actions: [cancelAction, leaveAction])
    }
    
    func setAvatarInfo() {
        // avatar
        let userInfo = self.contextPool.user.getLocalUserInfo()
        guard let userIdPrefix = userInfo.userUuid.getUserIdPrefix() else {
            return
        }
        
        contentView.renderView.setUserName(userInfo.userName)
        let mainUserId = userIdPrefix.joinUserId(.main)
        if let props = contextPool.user.getUserProperties(userUuid: mainUserId),
           let avatarUrl = props["avatar"] as? String {
            contentView.renderView.setAvartarImage(avatarUrl)
        }
    }
    
    func localSubRoomCheck() {
        let localUserId = contextPool.user.getLocalUserInfo().userUuid
        guard let userIdPrefix = localUserId.getUserIdPrefix() else {
            return
        }
        
        let localSubRoomId = getUserSubroomId(userIdPrefix: userIdPrefix)
        
        if subRoomCheck(localSubRoomId) {
            joinSubRoom(localSubRoomId)
        } else {
            let config = AgoraEduContextSubRoomCreateConfig(subRoomName: userIdPrefix,
                                                            subRoomId: localSubRoomId,
                                                            userList: [localUserId],
                                                            subRoomProperties: nil)
            contextPool.group.addSubRoomList(configs: [config],
                                             isInvited: false,
                                             success: nil) { [weak self] error in
                self?.localSubRoomCheck()
            }
        }
    }
    
    func joinSubRoom(_ subRoomId: String) {
        guard subRoom == nil,
              let localSubRoom = contextPool.group.createSubRoomObject(subRoomUuid: subRoomId) else {
            return
        }
        
        subRoom = localSubRoom
        
        localSubRoom.registerSubRoomEventHandler(self)
        localSubRoom.stream.registerStreamEventHandler(self)
        localSubRoom.user.registerUserEventHandler(self)
        
        AgoraLoading.loading()
        localSubRoom.joinSubRoom(success: { [weak self] in
            AgoraLoading.hide()
        }, failure: { [weak self] error in
            AgoraLoading.hide()
            AgoraToast.toast(message: "pt_room_tips_join_failed".pt_localized())
        })
    }
    
    func setupCohost() {
        let localUserId = contextPool.user.getLocalUserInfo().userUuid
        guard let `subRoom` = subRoom,
              let list = subRoom.user.getCoHostList(),
              list.contains(where: {$0.userUuid == localUserId}) else {
            return
        }
        
        startRenderLocalVideo()
    }
    
    func exit() {
        if let subRoom = subRoom {
            subRoom.registerSubRoomEventHandler(self)
            subRoom.stream.registerStreamEventHandler(self)
            subRoom.user.unregisterUserEventHandler(self)
        }
        
        contextPool.room.unregisterRoomEventHandler(self)
        contextPool.group.unregisterGroupEventHandler(self)
        
        stopRenderLocalVideo()
        
        subRoom?.leaveSubRoom()
        delegate?.onExamExit()
    }
    
    func startRenderLocalVideo() {
        // 大房间不发流
        guard let `subRoom` = subRoom else {
            return
        }
        let userId = subRoom.user.getLocalUserInfo().userUuid
        let localStreamList = subRoom.stream.getStreamList(userUuid: userId)
        
        guard let streamId = localStreamList?.first(where: {$0.videoSourceType == .camera})?.streamUuid else {
            return
        }
        
        let renderConfig = AgoraEduContextRenderConfig()
        renderConfig.mode = .hidden
        
        contextPool.media.startRenderVideo(roomUuid: subRoom.getSubRoomInfo().subRoomUuid,
                                           view: contentView.renderView,
                                           renderConfig: renderConfig,
                                           streamUuid: streamId)
    }
    
    func stopRenderLocalVideo() {
        let userId = contextPool.user.getLocalUserInfo().userUuid
        let localStreamList = contextPool.stream.getStreamList(userUuid: userId)
        
        guard let streamId = localStreamList?.first(where: {$0.videoSourceType == .camera})?.streamUuid  else {
            return
        }
        
        contextPool.media.stopRenderVideo(streamUuid: streamId)
    }
    
    func getUserSubroomId(userIdPrefix: String) -> String {
        let roomId = contextPool.room.getRoomInfo().roomUuid
        let localSubRoomId = "\(roomId)-\(userIdPrefix)".md5()
        return localSubRoomId
    }
    
    func subRoomCheck(_ subRoomId: String) -> Bool {
        guard let list = contextPool.group.getSubRoomList() else {
            return false
        }
        
        return list.contains(where: {$0.subRoomUuid == subRoomId})
        
    }
}
