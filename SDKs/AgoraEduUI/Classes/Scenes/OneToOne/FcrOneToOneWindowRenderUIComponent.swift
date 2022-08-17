//
//  FcrOneToOneWindowRenderUIController.swift
//  AgoraEduUI
//
//  Created by Cavan on 2022/6/3.
//

import AgoraEduContext
import AgoraWidget
import UIKit

class FcrOneToOneWindowRenderUIComponent: FcrWindowRenderUIComponent {
    private let roomController: AgoraEduRoomContext
    private let userController: AgoraEduUserContext
    private let mediaController: AgoraEduMediaContext
    private let streamController: AgoraEduStreamContext
    private let widgetController: AgoraEduWidgetContext
    
    private let teacherItemIndex = 0
    private let studentItemIndex = 1
    
    private weak var componentDataSource: FcrUIComponentDataSource?
    
    init(roomController: AgoraEduRoomContext,
         userController: AgoraEduUserContext,
         mediaController: AgoraEduMediaContext,
         streamController: AgoraEduStreamContext,
         widgetController: AgoraEduWidgetContext,
         delegate: FcrWindowRenderUIComponentDelegate? = nil,
         componentDataSource: FcrUIComponentDataSource? = nil) {
        let dataSource = [FcrWindowRenderViewState.none,
                          FcrWindowRenderViewState.none]
        
        self.roomController = roomController
        self.userController = userController
        self.mediaController = mediaController
        self.streamController = streamController
        self.widgetController = widgetController
        
        self.componentDataSource = componentDataSource
        
        super.init(dataSource: dataSource,
                   maxShowItemCount: dataSource.count,
                   delegate: delegate)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        roomController.registerRoomEventHandler(self)
        userController.registerUserEventHandler(self)
        streamController.registerStreamEventHandler(self)
        mediaController.registerMediaEventHandler(self)
    }
    
    override func initViews() {
        super.initViews()
        
        let teacherIndexPath = IndexPath(item: teacherItemIndex,
                                         section: 0)
        let studentIndexPath = IndexPath(item: studentItemIndex,
                                         section: 0)
        let teacherView = collectionView.cellForItem(at: teacherIndexPath)
        let studentView = collectionView.cellForItem(at: studentIndexPath)
        
        teacherView?.agora_enable = UIConfig.teacherVideo.enable
        teacherView?.agora_visible = UIConfig.teacherVideo.visible
        
        studentView?.agora_enable = UIConfig.studentVideo.enable
        studentView?.agora_visible = UIConfig.studentVideo.visible
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

private extension FcrOneToOneWindowRenderUIComponent {
    func updateItemOfTeacher() {
        guard let teacher = userController.getUserList(role: .teacher)?.first else {
            return
        }
        
        updateItem(by: teacher,
                   index: teacherItemIndex)
    }
    
    func updateItemOfStudent() {
        guard let student = userController.getUserList(role: .student)?.first else {
            return
        }
        
        updateItem(by: student,
                   index: studentItemIndex)
    }
    
    func updateItem(by user: AgoraEduContextUserInfo,
                    index: Int) {
        guard let stream = streamController.firstCameraStream(of: user) else {
            return
        }
        
        let item = createItem(with: stream)
        
        updateItem(item,
                   index: index)
    }
    
    func deleteItemOfTeacher() {
        updateItem(.none,
                   index: teacherItemIndex)
    }
    
    func deleteItemOfStudent() {
        updateItem(.none,
                   index: studentItemIndex)
    }
    
    func createItem(with stream: AgoraEduContextStreamInfo) -> FcrWindowRenderViewState {
        var boardPrivilege: Bool = false
        
        let userId = stream.owner.userUuid
        
        if let userList = componentDataSource?.componentNeedGrantedUserList(),
           userList.contains(userId),
           stream.owner.userRole != .teacher {
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
}

private extension FcrOneToOneWindowRenderUIComponent {
    func startPlayAudio(streamId: String) {
        let roomId = roomController.getRoomInfo().roomUuid
        mediaController.startPlayAudio(roomUuid: roomId,
                                         streamUuid: streamId)
    }
    
    func stopPlayAudio(streamId: String) {
        let roomId = roomController.getRoomInfo().roomUuid
        mediaController.stopPlayAudio(roomUuid: roomId,
                                        streamUuid: streamId)
    }
    
    func startRenderVideo(streamId: String,
                          view: FcrWindowRenderVideoView) {
        let renderConfig = AgoraEduContextRenderConfig()
        renderConfig.mode = .hidden
        
        mediaController.startRenderVideo(view: view,
                                           renderConfig: renderConfig,
                                           streamUuid: streamId)
    }
    
    func stopRenderVideo(streamId: String,
                         view: FcrWindowRenderVideoView) {
        mediaController.stopRenderVideo(streamUuid: streamId)
    }
}

extension FcrOneToOneWindowRenderUIComponent: AgoraEduRoomHandler {
    func onJoinRoomSuccess(roomInfo: AgoraEduContextRoomInfo) {
        updateItemOfTeacher()
        updateItemOfStudent()
    }
}

extension FcrOneToOneWindowRenderUIComponent: AgoraEduUserHandler {
    func onRemoteUserJoined(user: AgoraEduContextUserInfo) {
        switch user.userRole {
        case .teacher:
            updateItemOfTeacher()
        case .student:
            updateItemOfStudent()
        default:
            break
        }
    }
    
    func onRemoteUserLeft(user: AgoraEduContextUserInfo,
                          operatorUser: AgoraEduContextUserInfo?,
                          reason: AgoraEduContextUserLeaveReason) {
        switch user.userRole {
        case .teacher:
            deleteItemOfTeacher()
        case .student:
            deleteItemOfStudent()
        default:
            break
        }
    }
    
    func onUserRewarded(user: AgoraEduContextUserInfo,
                        rewardCount: Int,
                        operatorUser: AgoraEduContextUserInfo?) {
        guard user.userRole == .student else {
            return
        }
        
        updateItemOfStudent()
    }
}

extension FcrOneToOneWindowRenderUIComponent: AgoraEduStreamHandler {
    func onStreamJoined(stream: AgoraEduContextStreamInfo,
                        operatorUser: AgoraEduContextUserInfo?) {
        switch stream.owner.userRole {
        case .teacher:
            updateItemOfTeacher()
        case .student:
            updateItemOfStudent()
        default:
            break
        }
    }
    
    func onStreamUpdated(stream: AgoraEduContextStreamInfo,
                         operatorUser: AgoraEduContextUserInfo?) {
        switch stream.owner.userRole {
        case .teacher:
            updateItemOfTeacher()
        case .student:
            updateItemOfStudent()
        default:
            break
        }
    }
}

extension FcrOneToOneWindowRenderUIComponent: AgoraEduMediaHandler {
    func onVolumeUpdated(volume: Int,
                         streamUuid: String) {
        updateVolume(streamId: streamUuid,
                     volume: volume)
    }
}
