//
//  File.swift
//  AgoraEducation
//
//  Created by Cavan on 2021/12/28.
//  Copyright © 2021 Agora. All rights reserved.
//

#if canImport(AgoraClassroomSDK_iOS)
import AgoraClassroomSDK_iOS
#else
import AgoraClassroomSDK
#endif
import Foundation

/** 房间信息项*/
enum RoomInfoItemType: Int, CaseIterable {
    // 房间名
    case roomName = 0
    // 昵称
    case nickName
    // 类型
    case roomStyle
    // 角色
    case roleType
    // 区域
    case region
    // IM
    case im
    // 时长
    case duration
    // 密钥
    case encryptKey
    // 模式
    case encryptMode
}

/** 区域选择类型*/
enum RoomRegionType: String, CaseIterable  {
    case CN, NA, EU, AP
}

enum IMType: String {
    case rtm, easemob
}

/** 房间可选项*/
let kRoomOptions: [(AgoraEduRoomType, String)] = [
    (.oneToOne, NSLocalizedString("Login_onetoone", comment: "")),
    (.small, NSLocalizedString("Login_small", comment: "")),
    (.lecture, NSLocalizedString("Login_lecture", comment: "")),
    (.paintingSmall, NSLocalizedString("login_painting_small", comment: ""))
]

/** 区域可选项*/
let kRegionOptions: [(RoomRegionType, String)] = [
    (.CN, "CN"),
    (.NA, "NA"),
    (.EU, "EU"),
    (.AP, "AP")
]

/** 角色可选项*/
let kRoleOptions: [(AgoraEduUserRole, String)] = [
//    (.teacher, NSLocalizedString("login_role_teacher", comment: "")),
    (.student, NSLocalizedString("login_role_student", comment: "")),
]

let kIMOptions: [(IMType, String)] = [
    (.rtm, "rtm"),
    (.easemob, "easemon")
]

/** 加密方式可选项*/
let kEncryptionOptions: [(AgoraEduMediaEncryptionMode, String)] = [
    (.none, "None"),
    (.SM4128ECB, "sm4-128-ecb"),
    (.AES128GCM2, "aes-128-gcm2"),
    (.AES256GCM2, "aes-256-gcm2"),
]

/** 入参模型*/
struct RoomInfoModel {
    var roomName: String?
    var nickName: String?
    var roomStyle: AgoraEduRoomType?
    var roleType: AgoraEduUserRole = .student
    var region: RoomRegionType = .CN
    var im: IMType = .easemob
    var duration: Int = 1800
    var encryptKey: String?
    var encryptMode: AgoraEduMediaEncryptionMode = .none
    /** 入参默认值 */
    static func defaultValue() -> RoomInfoModel {
        var room = RoomInfoModel()
        room.roomName = nil
        room.nickName = nil
        return room
    }
}

extension RoomRegionType {
    var eduType: AgoraEduRegion {
        switch self {
        case .CN: return .CN
        case .NA: return .NA
        case .EU: return .EU
        case .AP: return .AP
        }
    }
}
