//
//  FcrTeacherWindowRenderUIController.swift
//  AgoraEduUI
//
//  Created by Cavan on 2022/6/9.
//

import AgoraUIBaseViews
import AgoraEduCore
import Foundation

class FcrTeacherTachedWindowUIComponent: FcrTachedStreamWindowUIComponent {
    private let roomController: AgoraEduRoomContext
    private let userController: AgoraEduUserContext
    private(set) var streamController: AgoraEduStreamContext
    private let mediaController: AgoraEduMediaContext
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
         subRoom: AgoraEduSubRoomContext? = nil,
         dataSource: [FcrTachedWindowRenderViewState]? = nil,
         reverseItem: Bool = true,
         delegate: FcrTachedStreamWindowUIComponentDelegate? = nil) {
        self.roomController = roomController
        self.userController = userController
        self.streamController = streamController
        self.mediaController = mediaController
        self.subRoom = subRoom
        
        super.init(dataSource: dataSource,
                   reverseItem: reverseItem,
                   delegate: delegate)
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
    
    override func onWillDisplayItem(_ item: FcrTachedWindowRenderViewState,
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
            break
//            stopRenderVideo(streamId: data.streamId,
//                            view: renderView)
        default:
            break
        }
    }
    
    override func onDidEndDisplayingItem(_ item: FcrTachedWindowRenderViewState,
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

extension FcrTeacherTachedWindowUIComponent: AgoraUIActivity {
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
private extension FcrTeacherTachedWindowUIComponent {
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
    internal func createItem(with stream: AgoraEduContextStreamInfo) -> FcrTachedWindowRenderViewState {
        let rewardCount = userController.getUserRewardCount(userUuid: stream.owner.userUuid)
        
        let data = FcrStreamWindowViewData.create(stream: stream,
                                                  rewardCount: rewardCount,
                                                  boardPrivilege: false)
        
        let hide = getItemIsHidden(streamId: stream.streamUuid)
        
        let item = FcrTachedWindowRenderViewState.create(isHide: hide,
                                                         data: data)
        
        return item
    }
    
    func getItemIsHidden(streamId: String) -> Bool {
        guard let `delegate` = delegate else {
            return false
        }
        
        return delegate.tachedStreamWindowUIComponent(self,
                                                      shouldItemIsHide: streamId)
    }
}

private extension FcrTeacherTachedWindowUIComponent {
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

extension FcrTeacherTachedWindowUIComponent: AgoraEduRoomHandler {
    func onJoinRoomSuccess(roomInfo: AgoraEduContextRoomInfo) {
        viewWillActive()
    }
}

extension FcrTeacherTachedWindowUIComponent: AgoraEduSubRoomHandler {
    func onJoinSubRoomSuccess(roomInfo: AgoraEduContextSubRoomInfo) {
        viewWillActive()
    }
}

extension FcrTeacherTachedWindowUIComponent: AgoraEduUserHandler {
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

extension FcrTeacherTachedWindowUIComponent: AgoraEduStreamHandler {
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

extension FcrTeacherTachedWindowUIComponent: AgoraEduMediaHandler {
    func onVolumeUpdated(volume: Int,
                         streamUuid: String) {
        updateVolume(streamId: streamUuid,
                     volume: volume)
    }
}
