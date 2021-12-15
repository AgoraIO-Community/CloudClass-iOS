//
//  AgoraWhiteboardConfig.swift
//  AgoraWidgets
//
//  Created by LYY on 2021/12/6.
//

import Whiteboard

enum AgoraWhiteboardLogType {
    case info,warning,error
}

struct AgoraWhiteboardSize: Decodable {
    var width: Int32
    var height: Int32
}

struct AgoraWhiteboardPosition: Decodable {
    var xAxis: Int32
    var yAxis: Int32
}

struct AgoraWhiteboardPropExtra: Decodable {
    var boardAppId: String
    var boardId: String
    var boardToken: String
    var boardRegion: String
    var follow: Int32? // 是否跟随
    var grantUsers: [String]?
}

struct AgoraWhiteboardProperties: Decodable {
    var size: AgoraWhiteboardSize?
    var position: AgoraWhiteboardPosition?
    var extra: AgoraWhiteboardPropExtra
}

struct AgoraWhiteboardExtraInfo : Convertable {
    var useMultiViews: Bool? = true
    var coursewareDirectory: String = NSSearchPathForDirectoriesInDomains(.cachesDirectory,
                                                                          .userDomainMask,
                                                                          true)[0].appending("AgoraDownload")
    var autoFit: Bool = false
    var fonts: Dictionary<String,String>?
    var collectorStyles: Dictionary<String,String>?
}

@objcMembers class AgoraWhiteBoardTask: NSObject {
    var resourceUuid: String = ""
    var taskUuid: String = ""
    var extra: String = ""
}


@objcMembers public class AgoraWhiteboardGlobalState: WhiteGlobalState {
    var materialList: [AgoraWhiteBoardTask]?
    var currentSceneIndex: Int = 0
    var grantUsers = Array<String>()
}

@objc class AgoraWhiteBoardCameraConfig : NSObject {
    /** 白板视角中心 X 坐标，该坐标为中心在白板内部坐标系 X 轴中的坐标 */
    var centerX: CGFloat = 0
    /** 白板视角中心 Y 坐标，该坐标为中心在白板内部坐标系 Y 轴中的坐标 */
    var centerY: CGFloat = 0
    /** 缩放比例，白板视觉中心与白板的投影距离 */
    var scale: CGFloat = 1
}
