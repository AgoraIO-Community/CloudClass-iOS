//
//  FcrLectureStreamWindowUIController.swift
//  AgoraEduUI
//
//  Created by Cavan on 2022/6/17.
//

import AgoraEduContext
import UIKit

class FcrLectureStreamWindowUIComponent: FcrStreamWindowUIComponent {
    override func onStreamUpdated(stream: AgoraEduContextStreamInfo,
                                  operatorUser: AgoraEduContextUserInfo?) {
        super.onStreamUpdated(stream: stream,
                              operatorUser: operatorUser)
        guard stream.hasAudio else {
            return
        }
        
        contextPool.media.startPlayAudio(roomUuid: roomId,
                                         streamUuid: stream.streamUuid)
    }
    
    override func onStreamJoined(stream: AgoraEduContextStreamInfo,
                                 operatorUser: AgoraEduContextUserInfo?) {
        super.onStreamJoined(stream: stream, operatorUser: operatorUser)
        if stream.hasAudio {
            contextPool.media.startPlayAudio(roomUuid: roomId,
                                             streamUuid: stream.streamUuid)
        } else {
            contextPool.media.stopPlayAudio(roomUuid: roomId,
                                            streamUuid: stream.streamUuid)
        }
    }
    
    func onStreamLeft(stream: AgoraEduContextStreamInfo,
                      operatorUser: AgoraEduContextUserInfo?) {
        contextPool.media.stopPlayAudio(roomUuid: roomId,
                                        streamUuid: stream.streamUuid)
    }
}
