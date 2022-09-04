//
//  FcrTeacherWindowRenderUIController.swift
//  AgoraEduUI
//
//  Created by Cavan on 2022/6/9.
//

import AgoraUIBaseViews
import AgoraEduContext
import Foundation

class FcrTeacherWindowRenderUIComponent: FcrWindowRenderUIComponent {
    private let roomController: AgoraEduRoomContext
    private let userController: AgoraEduUserContext
    private(set) var streamController: AgoraEduStreamContext
    private let mediaController: AgoraEduMediaContext
    private let widgetController: AgoraEduWidgetContext
    private let subRoom: AgoraEduSubRoomContext?
    
    private var roomId: String {
        if let `subRoom` = subRoom {
            return subRoom.getSubRoomInfo().subRoomUuid
        } else {
            return roomController.getRoomInfo().roomUuid
        }
    }
    
    init(roomController: AgoraEduRoomContext,
         userController: AgoraEduUserContext,
         streamController: AgoraEduStreamContext,
         mediaController: AgoraEduMediaContext,
         widgetController: AgoraEduWidgetContext,
         subRoom: AgoraEduSubRoomContext? = nil,
         dataSource: [FcrWindowRenderViewState]? = nil,
         reverseItem: Bool = true,
         delegate: FcrWindowRenderUIComponentDelegate? = nil) {
        self.roomController = roomController
        self.userController = userController
        self.streamController = streamController
        self.mediaController = mediaController
        self.widgetController = widgetController
        self.subRoom = subRoom
        
        super.init(dataSource: dataSource,
                   reverseItem: reverseItem)
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
    }
    
    override func onDidAddItem(_ item: FcrWindowRenderViewState) {
        super.onDidAddItem(item)
        
        guard let data = item.data,
              data.audioState.isBoth else {
            return
        }
        
        startPlayAudio(streamId: data.streamId)
    }
    
    override func onDidUpdateItem(_ item: FcrWindowRenderViewState) {
        super.onDidUpdateItem(item)
        
        guard let data = item.data else {
            return
        }
        
        if data.audioState.isBoth {
            startPlayAudio(streamId: data.streamId)
        } else {
            stopPlayAudio(streamId: data.streamId)
        }
    }
    
    override func onDidDeleteItem(_ item: FcrWindowRenderViewState) {
        super.onDidDeleteItem(item)
        
        guard let data = item.data else {
            return
        }
        
        stopPlayAudio(streamId: data.streamId)
    }
    
    override func onWillDisplayItem(_ item: FcrWindowRenderViewState,
                                    renderView: FcrWindowRenderVideoView) {
        super.onWillDisplayItem(item,
                                renderView: renderView)
        
        switch item {
        case .show(let data):
            if data.videoState.isBoth {
                startRenderVideo(streamId: data.streamId,
                                 view: renderView)
            } else {
                stopRenderVideo(streamId: data.streamId,
                                view: renderView)
            }
        case .hide(let data):
            stopRenderVideo(streamId: data.streamId,
                            view: renderView)
        default:
            break
        }
    }
    
    override func onDidEndDisplayingItem(_ item: FcrWindowRenderViewState,
                                         renderView: FcrWindowRenderVideoView) {
        super.onDidEndDisplayingItem(item,
                                     renderView: renderView)
        
        switch item {
        case .show(let data):
            stopRenderVideo(streamId: data.streamId,
                            view: renderView)
        default:
            break
        }
    }
}

extension FcrTeacherWindowRenderUIComponent: AgoraUIActivity {
    func viewWillActive() {
        userController.registerUserEventHandler(self)
        streamController.registerStreamEventHandler(self)
        mediaController.registerMediaEventHandler(self)
        
        guard let teacher = userController.getUserList(role: .teacher)?.first else {
            return
        }
        
        addItemOfTeacher(teacher)
    }
    
    func viewWillInactive() {
        userController.unregisterUserEventHandler(self)
        streamController.unregisterStreamEventHandler(self)
        mediaController.unregisterMediaEventHandler(self)
        
        guard let teacher = userController.getUserList(role: .teacher)?.first else {
            return
        }
        
        deleteItemOfTeacher(teacher)
    }
}

// MARK: - Item
private extension FcrTeacherWindowRenderUIComponent {
    // For lecture override
    @objc internal func addItemOfTeacher(_ user: AgoraEduContextUserInfo) {
        guard let stream = streamController.firstCameraStream(of: user) else {
            return
        }
        
        let item = createItem(with: stream)
        addItem(item)
    }
    
    func updateItemOfTeacher(_ user: AgoraEduContextUserInfo) {
        guard let stream = streamController.firstCameraStream(of: user) else {
            return
        }
        
        let item = createItem(with: stream)
        updateItem(item)
    }
    
    // For lecture override
    @objc internal func deleteItemOfTeacher(_ user: AgoraEduContextUserInfo) {
        deleteItem(of: user.userUuid)
    }
    
    // For lecture call
    internal func createItem(with stream: AgoraEduContextStreamInfo) -> FcrWindowRenderViewState {
        let rewardCount = userController.getUserRewardCount(userUuid: stream.owner.userUuid)
        
        let data = FcrWindowRenderViewData.create(stream: stream,
                                                  rewardCount: rewardCount,
                                                  boardPrivilege: false)
        
        let isActive = widgetController.streamWindowWidgetIsActive(of: stream)
        
        let item = FcrWindowRenderViewState.create(isHide: isActive,
                                                   data: data)
        
        return item
    }
}

private extension FcrTeacherWindowRenderUIComponent {
    func startPlayAudio(streamId: String) {
        mediaController.startPlayAudio(roomUuid: roomId,
                                       streamUuid: streamId)
    }
    
    func stopPlayAudio(streamId: String) {
        mediaController.stopPlayAudio(roomUuid: roomId,
                                      streamUuid: streamId)
    }
    
    func startRenderVideo(streamId: String,
                          view: FcrWindowRenderVideoView) {
        let renderConfig = AgoraEduContextRenderConfig()
        renderConfig.mode = .hidden
        
        mediaController.startRenderVideo(roomUuid: roomId,
                                         view: view,
                                         renderConfig: renderConfig,
                                         streamUuid: streamId)
    }
    
    func stopRenderVideo(streamId: String,
                         view: FcrWindowRenderVideoView) {
        mediaController.stopRenderVideo(roomUuid: roomId,
                                        streamUuid: streamId)
    }
}

extension FcrTeacherWindowRenderUIComponent: AgoraEduRoomHandler {
    func onJoinRoomSuccess(roomInfo: AgoraEduContextRoomInfo) {
        viewWillActive()
    }
}

extension FcrTeacherWindowRenderUIComponent: AgoraEduSubRoomHandler {
    func onJoinSubRoomSuccess(roomInfo: AgoraEduContextSubRoomInfo) {
        viewWillActive()
    }
}

extension FcrTeacherWindowRenderUIComponent: AgoraEduUserHandler {
    func onRemoteUserJoined(user: AgoraEduContextUserInfo) {
        guard user.userRole == .teacher else {
            return
        }
        
        addItemOfTeacher(user)
    }
    
    func onRemoteUserLeft(user: AgoraEduContextUserInfo,
                          operatorUser: AgoraEduContextUserInfo?,
                          reason: AgoraEduContextUserLeaveReason) {
        guard user.userRole == .teacher else {
            return
        }
        
        deleteItemOfTeacher(user)
    }
}

extension FcrTeacherWindowRenderUIComponent: AgoraEduStreamHandler {
    func onStreamJoined(stream: AgoraEduContextStreamInfo,
                        operatorUser: AgoraEduContextUserInfo?) {
        guard stream.owner.userRole == .teacher else {
            return
        }
        
        addItemOfTeacher(stream.owner)
    }
    
    func onStreamUpdated(stream: AgoraEduContextStreamInfo,
                         operatorUser: AgoraEduContextUserInfo?) {
        guard stream.owner.userRole == .teacher else {
            return
        }
        
        updateItemOfTeacher(stream.owner)
    }
}

extension FcrTeacherWindowRenderUIComponent: AgoraEduMediaHandler {
    func onVolumeUpdated(volume: Int,
                         streamUuid: String) {
        updateVolume(streamId: streamUuid,
                     volume: volume)
    }
}
