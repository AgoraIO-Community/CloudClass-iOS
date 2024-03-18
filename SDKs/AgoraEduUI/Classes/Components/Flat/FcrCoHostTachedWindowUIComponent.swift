//
//  FcrCoHostWindowRenderUIController.swift
//  AgoraEduUI
//
//  Created by Cavan on 2022/6/5.
//

import AgoraUIBaseViews
import AgoraEduCore
import Foundation

class FcrCoHostTachedWindowUIComponent: FcrTachedStreamWindowUIComponent {
    private let roomController: AgoraEduRoomContext
    private let userController: AgoraEduUserContext
    private let streamController: AgoraEduStreamContext
    private let mediaController: AgoraEduMediaContext
    private let subRoom: AgoraEduSubRoomContext?

    private var roomId: String {
        if let `subRoom` = subRoom {
            return subRoom.getSubRoomInfo().subRoomUuid
        } else {
            return roomController.getRoomInfo().roomUuid
        }
    }
    
    private weak var componentDataSource: FcrUIComponentDataSource?
    
    init(roomController: AgoraEduRoomContext,
         userController: AgoraEduUserContext,
         streamController: AgoraEduStreamContext,
         mediaController: AgoraEduMediaContext,
         subRoom: AgoraEduSubRoomContext? = nil,
         delegate: FcrTachedStreamWindowUIComponentDelegate? = nil,
         componentDataSource: FcrUIComponentDataSource? = nil) {
        self.roomController = roomController
        self.userController = userController
        self.streamController = streamController
        self.mediaController = mediaController
        self.subRoom = subRoom
        self.componentDataSource = componentDataSource
        
        super.init(maxShowItemCount: 6,
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

extension FcrCoHostTachedWindowUIComponent: AgoraUIActivity {
    func viewWillActive() {
        addItems()
        
        userController.registerUserEventHandler(self)
        streamController.registerStreamEventHandler(self)
        mediaController.registerMediaEventHandler(self)
    }
    
    func viewWillInactive() {
        deleteItems()
        
        userController.unregisterUserEventHandler(self)
        streamController.unregisterStreamEventHandler(self)
        mediaController.unregisterMediaEventHandler(self)
    }
}

// MARK: - Item
private extension FcrCoHostTachedWindowUIComponent {
    func addItemByStream(_ stream: AgoraEduContextStreamInfo) {
        guard stream.isCoHostCameraStream else {
            return
        }
        
        let item = createItem(with: stream)
        
        addItem(item)
    }
    
    func updateItemByStream(_ stream: AgoraEduContextStreamInfo) {
        guard stream.isCoHostCameraStream else {
            return
        }
        
        let item = createItem(with: stream)
        
        updateItem(item)
    }
    
    func deleteItemByStream(_ stream: AgoraEduContextStreamInfo) {
        guard stream.isCoHostCameraStream else {
            return
        }
        
        deleteItem(of: stream.owner.userUuid)
    }
    
    func addItems() {
        guard let list = streamController.getAllStreamList() else {
            return
        }
        
        for stream in list {
            addItemByStream(stream)
        }
    }
    
    func deleteItems() {
        for item in dataSource {
            guard let userId = item.data?.userId else {
                continue
            }
            
            deleteItem(of: userId)
        }
    }
    
    func createItem(with stream: AgoraEduContextStreamInfo) -> FcrTachedWindowRenderViewState {
        var boardPrivilege: Bool = false
        
        let userId = stream.owner.userUuid
        
        if let userList = componentDataSource?.componentNeedGrantedUserList(),
           userList.contains(userId) {
            boardPrivilege = true
        }
        
        let rewardCount = userController.getUserRewardCount(userUuid: userId)
        
        let data = FcrStreamWindowViewData.create(stream: stream,
                                                  rewardCount: rewardCount,
                                                  boardPrivilege: boardPrivilege)
        
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
    
    func coHostListContainer(user: AgoraEduContextUserInfo) -> Bool {
        guard let list = userController.getCoHostList() else {
            return false
        }
        
        return list.contains(where: {$0.userUuid == user.userUuid})
    }
}

private extension FcrCoHostTachedWindowUIComponent {    
    func startRenderVideo(streamId: String,
                          view: FcrWindowRenderVideoView) {
        streamController.setRemoteVideoStreamSubscribeLevel(streamUuid: streamId,
                                                            level: .low)
        
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

extension FcrCoHostTachedWindowUIComponent: AgoraEduRoomHandler {
    func onJoinRoomSuccess(roomInfo: AgoraEduContextRoomInfo) {
        viewWillActive()
    }
}

extension FcrCoHostTachedWindowUIComponent: AgoraEduSubRoomHandler {
    func onJoinSubRoomSuccess(roomInfo: AgoraEduContextSubRoomInfo) {
        viewWillActive()
    }
}

extension FcrCoHostTachedWindowUIComponent: AgoraEduUserHandler {
    func onUserHandsWave(userUuid: String,
                         duration: Int,
                         payload: [String: Any]?) {
        guard let renderView = getRenderView(userId: userUuid) else {
            return
        }
        
        renderView.startWaving()
    }
    
    func onUserHandsDown(userUuid: String,
                         payload: [String : Any]?) {
        guard let renderView = getRenderView(userId: userUuid) else {
            return
        }
        
        renderView.stopWaving()
    }
    
    func onUserRewarded(user: AgoraEduContextUserInfo,
                        rewardCount: Int,
                        operatorUser: AgoraEduContextUserInfo?) {
        guard let list = streamController.getStreamList(userUuid: user.userUuid) else {
            return
        }
        
        for stream in list {
            addItemByStream(stream)
        }
    }
}

extension FcrCoHostTachedWindowUIComponent: AgoraEduStreamHandler {
    func onStreamJoined(stream: AgoraEduContextStreamInfo,
                        operatorUser: AgoraEduContextUserInfo?) {
        addItemByStream(stream)
    }
    
    func onStreamUpdated(stream: AgoraEduContextStreamInfo,
                         operatorUser: AgoraEduContextUserInfo?) {
        updateItemByStream(stream)
    }
    
    func onStreamLeft(stream: AgoraEduContextStreamInfo,
                      operatorUser: AgoraEduContextUserInfo?) {
        deleteItemByStream(stream)
    }
}

extension FcrCoHostTachedWindowUIComponent: AgoraEduMediaHandler {
    func onVolumeUpdated(volume: Int,
                         streamUuid: String) {
        updateVolume(streamId: streamUuid,
                     volume: volume)
    }
}

fileprivate extension AgoraEduContextStreamInfo {
    var isCoHostCameraStream: Bool {
        if owner.userRole != .teacher && videoSourceType == .camera {
            return true
        } else {
            return false
        }
    }
}
