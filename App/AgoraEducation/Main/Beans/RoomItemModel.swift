//
//  RoomItemModel.swift
//  AgoraEducation
//
//  Created by Jonathan on 2022/9/9.
//  Copyright © 2022 Agora. All rights reserved.
//

import Foundation
#if canImport(AgoraClassroomSDK_iOS)
import AgoraClassroomSDK_iOS
#else
import AgoraClassroomSDK
#endif

class RoomInputInfoModel {
    var userName: String?
    var roomName: String?
    var roomId: String?
    var roleType: AgoraEduUserRole = .student
    var roomType: AgoraEduRoomType = .oneToOne
    var appId: String?
    var token: String?
    
    var userUuid: String? {
        guard let userName = userName else {
            return nil
        }
        return "\(userName.md5())\(roleType.rawValue)"
    }
    
    var roomUuid: String? {
        guard let roomName = roomName else {
            return nil
        }
        return "\(roomName.md5())\(roomType.rawValue)"
    }
}

class RoomItemModel {
    var roomName: String = ""
    var roomId: String = ""
    var roomType: UInt = 0
    var roomState: UInt = 0
    var startTime: UInt = 0
    var endTime: UInt = 0
    
    init(roomName: String,
         roomId: String,
         roomType: UInt,
         roomState: UInt,
         startTime: UInt,
         endTime: UInt) {
        self.roomName = roomName
        self.roomId = roomId
        self.roomType = roomType
        self.roomState = roomState
        self.startTime = startTime
        self.endTime = endTime
    }
    
    static func modelWith(dict: [String: Any]) -> RoomItemModel? {
        guard let roomName = dict["roomName"] as? String,
              let roomId = dict["roomId"] as? String,
              let roomType = dict["roomType"] as? UInt,
              let roomState = dict["roomState"] as? UInt,
              let startTime = dict["startTime"] as? UInt,
              let endTime = dict["endTime"] as? UInt
        else {
            return nil
        }
        let model = RoomItemModel(roomName: roomName,
                                  roomId: roomId,
                                  roomType: roomType,
                                  roomState: roomState,
                                  startTime: startTime,
                                  endTime: endTime)
        return model
    }
    
    static func arrayWithDataList(_ list: [Dictionary<String, Any>]) -> [RoomItemModel] {
        var ary = [RoomItemModel]()
        for item in list {
            guard let model = modelWith(dict: item) else {
                continue
            }
            ary.append(model)
        }
        return ary
    }
}
