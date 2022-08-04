//
//  FcrCoHostWindowRenderUIController.swift
//  AgoraEduUI
//
//  Created by Cavan on 2022/6/5.
//

import AgoraUIBaseViews
import AgoraEduContext
import Foundation

class FcrCoHostWindowRenderUIComponent: FcrWindowRenderUIComponent {
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
    
    private var widgetController: AgoraEduWidgetContext {
        if let `subRoom` = subRoom {
            return subRoom.widget
        } else {
            return contextPool.widget
        }
    }
    
    private var roomId: String {
        if let `subRoom` = subRoom {
            return subRoom.getSubRoomInfo().subRoomUuid
        } else {
            return contextPool.room.getRoomInfo().roomUuid
        }
    }
    
    private let contextPool: AgoraEduContextPool
    private var subRoom: AgoraEduSubRoomContext?
    
    private weak var componentDataSource: FcrUIComponentDataSource?
    
    init(context: AgoraEduContextPool,
         subRoom: AgoraEduSubRoomContext? = nil,
         delegate: FcrWindowRenderUIComponentDelegate? = nil,
         componentDataSource: FcrUIComponentDataSource? = nil) {
        self.contextPool = context
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
            contextPool.room.registerRoomEventHandler(self)
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

extension FcrCoHostWindowRenderUIComponent: AgoraUIActivity {
    func viewWillActive() {
        addItemsOfCoHost()
        
        userController.registerUserEventHandler(self)
        streamController.registerStreamEventHandler(self)
        contextPool.media.registerMediaEventHandler(self)
    }
    
    func viewWillInactive() {
        deleteItemsOfCoHost()
        
        userController.unregisterUserEventHandler(self)
        streamController.unregisterStreamEventHandler(self)
        contextPool.media.unregisterMediaEventHandler(self)
    }
}

// MARK: - Item
private extension FcrCoHostWindowRenderUIComponent {
    func addItemsOfCoHost() {
        guard let list = userController.getCoHostList() else {
            return
        }
        
        for user in list {
            addItemOfCoHost(by: user)
        }
    }
    
    func addItemOfCoHost(by user: AgoraEduContextUserInfo) {
        guard let stream = firstCameraStream(of: user) else {
            return
        }
        
        let item = createItem(with: stream)
        
        addItem(item)
    }
    
    func updateItemOfCoHost(by user: AgoraEduContextUserInfo) {
        guard let stream = firstCameraStream(of: user) else {
            return
        }
        
        let item = createItem(with: stream)
        
        updateItem(item)
    }
    
    func deleteItemsOfCoHost() {
        guard let list = userController.getCoHostList() else {
            return
        }
        
        for user in list {
            deleteItemOfCoHost(by: user)
        }
    }
    
    func deleteItemOfCoHost(by user: AgoraEduContextUserInfo) {
        deleteItem(of: user.userUuid)
    }
    
    func createItem(with stream: AgoraEduContextStreamInfo) -> FcrWindowRenderViewState {
        var boardPrivilege: Bool = false
        
        let userId = stream.owner.userUuid
        
        if let userList = componentDataSource?.componentNeedGrantedUserList(),
           userList.contains(userId) {
            boardPrivilege = true
        }
        
        let rewardCount = userController.getUserRewardCount(userUuid: userId)
        
        let data = FcrWindowRenderViewData.create(stream: stream,
                                                  rewardCount: rewardCount,
                                                  boardPrivilege: boardPrivilege)
        
        let isActive = widgetController.streamWindowWidgetIsActive(of: stream)
        
        let item = FcrWindowRenderViewState.create(isHide: isActive,
                                                   data: data)
        
        return item
    }
    
    func firstCameraStream(of user: AgoraEduContextUserInfo) -> AgoraEduContextStreamInfo? {
        guard let streamList = streamController.getStreamList(userUuid: user.userUuid) else {
            return nil
        }
        
        return streamList.first(where: {$0.videoSourceType == .camera})
    }
}

private extension FcrCoHostWindowRenderUIComponent {
    func startPlayAudio(streamId: String) {
        contextPool.media.startPlayAudio(roomUuid: roomId,
                                         streamUuid: streamId)
    }
    
    func stopPlayAudio(streamId: String) {
        contextPool.media.stopPlayAudio(roomUuid: roomId,
                                        streamUuid: streamId)
    }
    
    func startRenderVideo(streamId: String,
                          view: FcrWindowRenderVideoView) {
//        if let renderingStream = view.renderingStream,
//           renderingStream == streamId {
//            return
//        }
        
        view.renderingStream = streamId
        
        let renderConfig = AgoraEduContextRenderConfig()
        renderConfig.mode = .hidden
        
        contextPool.media.startRenderVideo(roomUuid: roomId,
                                           view: view,
                                           renderConfig: renderConfig,
                                           streamUuid: streamId)
    }
    
    func stopRenderVideo(streamId: String,
                         view: FcrWindowRenderVideoView) {
//        view.renderingStream = nil
        contextPool.media.stopRenderVideo(roomUuid: roomId,
                                          streamUuid: streamId)
    }
}

extension FcrCoHostWindowRenderUIComponent: AgoraEduRoomHandler {
    func onJoinRoomSuccess(roomInfo: AgoraEduContextRoomInfo) {
        viewWillActive()
    }
}

extension FcrCoHostWindowRenderUIComponent: AgoraEduSubRoomHandler {
    func onJoinSubRoomSuccess(roomInfo: AgoraEduContextSubRoomInfo) {
        viewWillActive()
    }
}

extension FcrCoHostWindowRenderUIComponent: AgoraEduUserHandler {
    func onCoHostUserListAdded(userList: [AgoraEduContextUserInfo],
                               operatorUser: AgoraEduContextUserInfo?) {
        for user in userList {
            addItemOfCoHost(by: user)
        }
    }
    
    func onCoHostUserListRemoved(userList: [AgoraEduContextUserInfo],
                                 operatorUser: AgoraEduContextUserInfo?) {
        for user in userList {
            deleteItemOfCoHost(by: user)
        }
    }
    
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
        updateItemOfCoHost(by: user)
    }
}

extension FcrCoHostWindowRenderUIComponent: AgoraEduStreamHandler {
    func onStreamJoined(stream: AgoraEduContextStreamInfo,
                        operatorUser: AgoraEduContextUserInfo?) {
        guard stream.owner.userRole == .student else {
            return
        }
        
        addItemOfCoHost(by: stream.owner)
    }
    
    func onStreamUpdated(stream: AgoraEduContextStreamInfo,
                         operatorUser: AgoraEduContextUserInfo?) {
        guard stream.owner.userRole == .student else {
            return
        }
        
        updateItemOfCoHost(by: stream.owner)
    }
}

extension FcrCoHostWindowRenderUIComponent: AgoraEduMediaHandler {
    func onVolumeUpdated(volume: Int,
                         streamUuid: String) {
        updateVolume(streamId: streamUuid,
                     volume: volume)
    }
}
