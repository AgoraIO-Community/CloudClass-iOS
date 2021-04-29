//
//  AgoraEduContext.swift
//  AgoraEduContext
//
//  Created by SRS on 2021/4/16.
//

import Foundation
import AgoraExtApp

public typealias AgoraEduExtAppContext = AgoraExtAppProtocol

/* AgoraEduContextPool: 能力池
 * 你可以通过这个对象使用和监听目前灵动课堂提供的各种业务能力
 */
public protocol AgoraEduContextPool {
    // 白板通用控制，包含下载
    var whiteBoard: AgoraEduWhiteBoardContext { get }
    // 白板教具
    var whiteBoardTool: AgoraEduWhiteBoardToolContext { get }
    // 白板页控制
    var whiteBoardPageControl: AgoraEduWhiteBoardPageControlContext { get }
    // 白板页控制
    var room: AgoraEduRoomContext { get }
    // 聊天
    var chat: AgoraEduMessageContext { get }
    // 个人
    var user: AgoraEduUserContext { get }
    // 举手
    var handsUp: AgoraEduHandsUpContext { get }
    // 私密语音：目前只支持个人对个人
    var privateChat: AgoraEduPrivateChatContext { get }
    // 屏幕分享
    var shareScreen: AgoraEduScreenShareContext { get }
    // 扩展容器：该应用容器提供了生命周期、扩展
    var extApp: AgoraEduExtAppContext { get }
}
