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
    private let mediaController: AgoraEduMediaContext
    private var subRoom: AgoraEduSubRoomContext?
    
    private var roomId: String {
        if let `subRoom` = subRoom {
            return subRoom.getSubRoomInfo().subRoomUuid
        } else {
            return roomController.getRoomInfo().roomUuid
        }
    }
    
    init(roomController: AgoraEduRoomContext,
         streamController: AgoraEduStreamContext,
         mediaController: AgoraEduMediaContext,
         subRoom: AgoraEduSubRoomContext? = nil) {
        self.roomController = roomController
        self.streamController = streamController
        self.mediaController = mediaController
        
        self.subRoom = subRoom
        
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
        
        streamController.registerStreamEventHandler(self)
    }
}

extension FcrAudioStreamUIComponent: AgoraUIActivity {
    func viewWillActive() {
        startPlayAllAudioStream()
    }
    
    func viewWillInactive() {
        stopPlayAllAudioStream()
    }
}

private extension FcrAudioStreamUIComponent {
    func startPlayAllAudioStream() {
        guard let list = streamController.getAllStreamList() else {
            return
        }
        
        for stream in list {
            mediaController.startPlayAudio(roomUuid: roomId,
                                           streamUuid: stream.streamUuid)
        }
    }
    
    func stopPlayAllAudioStream() {
        guard let list = streamController.getAllStreamList() else {
            return
        }
        
        for stream in list {
            mediaController.stopPlayAudio(roomUuid: roomId,
                                          streamUuid: stream.streamUuid)
        }
    }
}

extension FcrAudioStreamUIComponent: AgoraEduSubRoomHandler {
    func onJoinSubRoomSuccess(roomInfo: AgoraEduContextSubRoomInfo) {
        startPlayAllAudioStream()
    }
}

extension FcrAudioStreamUIComponent: AgoraEduRoomHandler {
    func onJoinRoomSuccess(roomInfo: AgoraEduContextRoomInfo) {
        startPlayAllAudioStream()
    }
}

extension FcrAudioStreamUIComponent: AgoraEduStreamHandler {
    func onStreamJoined(stream: AgoraEduContextStreamInfo,
                        operatorUser: AgoraEduContextUserInfo?) {
        guard stream.hasAudio else {
            return
        }
        
        mediaController.startPlayAudio(roomUuid: roomId,
                                       streamUuid: stream.streamUuid)
    }
    
    func onStreamUpdated(stream: AgoraEduContextStreamInfo,
                         operatorUser: AgoraEduContextUserInfo?) {
        if stream.hasAudio {
            mediaController.startPlayAudio(roomUuid: roomId,
                                           streamUuid: stream.streamUuid)
        } else {
            mediaController.stopPlayAudio(roomUuid: roomId,
                                          streamUuid: stream.streamUuid)
        }
    }
    
    func onStreamLeft(stream: AgoraEduContextStreamInfo,
                      operatorUser: AgoraEduContextUserInfo?) {
        mediaController.stopPlayAudio(roomUuid: roomId,
                                      streamUuid: stream.streamUuid)
    }
}
