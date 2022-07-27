//
//  AgoraEduContext.swift
//  AgoraEduContext
//
//  Created by SRS on 2021/4/16.
//

import AgoraWidget
import Foundation

public typealias AgoraEduWidgetContext = AgoraWidgetProtocol

/* AgoraEduContextPool: 能力池
 * 你可以通过这个对象使用和监听目前灵动课堂提供的各种业务能力
 */
@objc public protocol AgoraEduContextPool: NSObjectProtocol {
    /// 房间
    var room: AgoraEduRoomContext { get }
    /// 媒体
    var media: AgoraEduMediaContext { get }
    /// 用户
    var user: AgoraEduUserContext { get }
    /// widget 插件
    var widget: AgoraEduWidgetContext { get }
    /// 流
    var stream: AgoraEduStreamContext { get }
    /// 监视器
    var monitor: AgoraEduMonitorContext { get }
    /// 分组
    var group: AgoraEduGroupContext { get }
}
