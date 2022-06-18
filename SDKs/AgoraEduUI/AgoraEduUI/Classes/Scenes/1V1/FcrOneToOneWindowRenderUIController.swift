//
//  FcrOneToOneWindowRenderUIController.swift
//  AgoraEduUI
//
//  Created by Cavan on 2022/6/3.
//

import AgoraEduContext
import AgoraWidget
import UIKit

class FcrOneToOneWindowRenderUIController: FcrWindowRenderUIController {
    private let contextPool: AgoraEduContextPool
    private let teacherItemIndex = 0
    private let studentItemIndex = 1
    
    init(context: AgoraEduContextPool) {
        let dataSource = [FcrWindowRenderViewState.none,
                          FcrWindowRenderViewState.none]
        
        self.contextPool = context
        
        super.init(dataSource: dataSource,
                   maxShowItemCount: dataSource.count)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        contextPool.room.registerRoomEventHandler(self)
        contextPool.user.registerUserEventHandler(self)
        contextPool.stream.registerStreamEventHandler(self)
        contextPool.media.registerMediaEventHandler(self)
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

private extension FcrOneToOneWindowRenderUIController {
    func updateItemOfTeacher() {
        guard let teacher = contextPool.user.getUserList(role: .teacher)?.first else {
            return
        }
        
        updateItem(by: teacher,
                   index: teacherItemIndex)
    }
    
    func updateItemOfStudent() {
        guard let student = contextPool.user.getUserList(role: .student)?.first else {
            return
        }
        
        updateItem(by: student,
                   index: studentItemIndex)
    }
    
    func updateItem(by user: AgoraEduContextUserInfo,
                    index: Int) {
        guard let stream = contextPool.stream.firstCameraStream(of: user) else {
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
        let data = stream.toWindowRenderData
        
        let isActive = contextPool.widget.streamWindowWidgetIsActive(of: stream)
        
        let item = FcrWindowRenderViewState.create(isHide: isActive,
                                                   data: data)
        
        return item
    }
}

private extension FcrOneToOneWindowRenderUIController {
    func startPlayAudio(streamId: String) {
        let roomId = contextPool.room.getRoomInfo().roomUuid
        contextPool.media.startPlayAudio(roomUuid: roomId,
                                         streamUuid: streamId)
    }
    
    func stopPlayAudio(streamId: String) {
        let roomId = contextPool.room.getRoomInfo().roomUuid
        contextPool.media.stopPlayAudio(roomUuid: roomId,
                                        streamUuid: streamId)
    }
    
    func startRenderVideo(streamId: String,
                          view: FcrWindowRenderVideoView) {
//        if let renderingStream = view.renderingStream,
//           renderingStream == streamId {
//            return
//        }
//        
//        view.renderingStream = streamId
        
        let renderConfig = AgoraEduContextRenderConfig()
        renderConfig.mode = .hidden
        
        contextPool.media.startRenderVideo(view: view,
                                           renderConfig: renderConfig,
                                           streamUuid: streamId)
    }
    
    func stopRenderVideo(streamId: String,
                         view: FcrWindowRenderVideoView) {
        contextPool.media.stopRenderVideo(streamUuid: streamId)
    }
}

extension FcrOneToOneWindowRenderUIController: AgoraEduRoomHandler {
    func onJoinRoomSuccess(roomInfo: AgoraEduContextRoomInfo) {
        updateItemOfTeacher()
        updateItemOfStudent()
    }
}

extension FcrOneToOneWindowRenderUIController: AgoraEduUserHandler {
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
}

extension FcrOneToOneWindowRenderUIController: AgoraEduStreamHandler {
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

extension FcrOneToOneWindowRenderUIController: AgoraEduMediaHandler {
    func onVolumeUpdated(volume: Int,
                         streamUuid: String) {
        updateVolume(streamId: streamUuid,
                     volume: volume)
    }
}
