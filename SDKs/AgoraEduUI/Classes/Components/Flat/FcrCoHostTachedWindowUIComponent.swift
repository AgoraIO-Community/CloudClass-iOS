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
        addItemsOfCoHost()
        
        userController.registerUserEventHandler(self)
        streamController.registerStreamEventHandler(self)
        mediaController.registerMediaEventHandler(self)
    }
    
    func viewWillInactive() {
        deleteItemsOfCoHost()
        
        userController.unregisterUserEventHandler(self)
        streamController.unregisterStreamEventHandler(self)
        mediaController.unregisterMediaEventHandler(self)
    }
}

// MARK: - Item
private extension FcrCoHostTachedWindowUIComponent {
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
    
    func firstCameraStream(of user: AgoraEduContextUserInfo) -> AgoraEduContextStreamInfo? {
        guard let streamList = streamController.getStreamList(userUuid: user.userUuid) else {
            return nil
        }
        
        return streamList.first(where: {$0.videoSourceType == .camera})
    }
    
    func getItemIsHidden(streamId: String) -> Bool {
        guard let `delegate` = delegate else {
            return false
        }
        
        return delegate.tachedStreamWindowUIComponent(self,
                                                      shouldItemIsHide: streamId)
    }
}

private extension FcrCoHostTachedWindowUIComponent {    
    func startRenderVideo(streamId: String,
                          view: FcrWindowRenderVideoView) {
        view.renderingStream = streamId
        
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

extension FcrCoHostTachedWindowUIComponent: AgoraEduStreamHandler {
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

extension FcrCoHostTachedWindowUIComponent: AgoraEduMediaHandler {
    func onVolumeUpdated(volume: Int,
                         streamUuid: String) {
        updateVolume(streamId: streamUuid,
                     volume: volume)
    }
}
