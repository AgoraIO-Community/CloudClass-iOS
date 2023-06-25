//
//  FcrAudioStreamUIComponent.swift
//  AgoraEduUI
//
//  Created by Cavan on 2022/12/9.
//

import AgoraUIBaseViews
import AgoraEduCore

class FcrAudioStreamUIComponent: FcrUIComponent {
    private let roomController: AgoraEduRoomContext
    private let streamController: AgoraEduStreamContext
    private let userController: AgoraEduUserContext
    private let mediaController: AgoraEduMediaContext
    private let subRoom: AgoraEduSubRoomContext?
    private let subscribeAll: Bool
    
    private var roomId: String {
        if let `subRoom` = subRoom {
            return subRoom.getSubRoomInfo().subRoomUuid
        } else {
            return roomController.getRoomInfo().roomUuid
        }
    }
    
    init(roomController: AgoraEduRoomContext,
         streamController: AgoraEduStreamContext,
         userController: AgoraEduUserContext,
         mediaController: AgoraEduMediaContext,
         subRoom: AgoraEduSubRoomContext? = nil,
         subscribeAll: Bool = false) {
        self.roomController = roomController
        self.streamController = streamController
        self.userController = userController
        self.mediaController = mediaController
        
        self.subRoom = subRoom
        
        self.subscribeAll = subscribeAll
        
        super.init(nibName: nil,
                   bundle: nil)
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
}

extension FcrAudioStreamUIComponent: AgoraUIActivity {
    func viewWillActive() {
        startPlayAllAudioStream()
        
        streamController.registerStreamEventHandler(self)
        userController.registerUserEventHandler(self)
    }
    
    func viewWillInactive() {
        stopPlayAllAudioStream()
        
        streamController.unregisterStreamEventHandler(self)
        userController.unregisterUserEventHandler(self)
    }
}

private extension FcrAudioStreamUIComponent {
    func startPlayAllAudioStream() {
        guard let list = streamController.getAllStreamList() else {
            return
        }
        
        for stream in list {
            guard stream.hasAudio else {
                continue
            }
            
            startPlayAudioStream(stream: stream)
        }
    }
    
    func stopPlayAllAudioStream() {
        guard let list = streamController.getAllStreamList() else {
            return
        }
        
        for stream in list {
            stopPlayAudioStream(stream: stream)
        }
    }
    
    func startPlayAudioStream(stream: AgoraEduContextStreamInfo) {
        if subscribeAll {
            mediaController.startPlayAudio(roomUuid: roomId,
                                           streamUuid: stream.streamUuid)
            return
        }
        
        let condition1 = stream.owner.userRole == .teacher
        let condition2 = streamOwnerIsCoHost(stream: stream)
        
        guard condition1 || condition2 else {
            return
        }
        
        mediaController.startPlayAudio(roomUuid: roomId,
                                       streamUuid: stream.streamUuid)
    }
    
    func stopPlayAudioStream(stream: AgoraEduContextStreamInfo) {
        mediaController.stopPlayAudio(roomUuid: roomId,
                                      streamUuid: stream.streamUuid)
    }
    
    func streamOwnerIsCoHost(stream: AgoraEduContextStreamInfo) -> Bool {
        guard let list = userController.getCoHostList() else {
            return false
        }
        
        guard let _ = list.firstIndex(where: {$0.userUuid == stream.owner.userUuid}) else {
            return false
        }
        
        return true
    }
}

extension FcrAudioStreamUIComponent: AgoraEduSubRoomHandler {
    func onJoinSubRoomSuccess(roomInfo: AgoraEduContextSubRoomInfo) {
        viewWillActive()
    }
}

extension FcrAudioStreamUIComponent: AgoraEduRoomHandler {
    func onJoinRoomSuccess(roomInfo: AgoraEduContextRoomInfo) {
        viewWillActive()
    }
}

extension FcrAudioStreamUIComponent: AgoraEduStreamHandler {
    func onStreamJoined(stream: AgoraEduContextStreamInfo,
                        operatorUser: AgoraEduContextUserInfo?) {
        guard stream.hasAudio else {
            return
        }
        
        startPlayAudioStream(stream: stream)
    }
    
    func onStreamUpdated(stream: AgoraEduContextStreamInfo,
                         operatorUser: AgoraEduContextUserInfo?) {
        if stream.hasAudio {
            startPlayAudioStream(stream: stream)
        } else {
            stopPlayAudioStream(stream: stream)
        }
    }
    
    func onStreamLeft(stream: AgoraEduContextStreamInfo,
                      operatorUser: AgoraEduContextUserInfo?) {
        stopPlayAudioStream(stream: stream)
    }
}

extension FcrAudioStreamUIComponent: AgoraEduUserHandler {
    func onCoHostUserListRemoved(userList: [AgoraEduContextUserInfo],
                                 operatorUser: AgoraEduContextUserInfo?) {
        for user in userList {
            guard let streams = streamController.getStreamList(userUuid: user.userUuid) else {
                continue
            }
            
            for stream in streams {
                stopPlayAudioStream(stream: stream)
            }
        }
    }
}
