//
//  AgoraEduContextProtocols.swift
//  AgoraUIEduBaseViews
//
//  Created by SRS on 2021/3/7.
//

import AgoraWidget
import UIKit

public typealias AgoraEduContextSuccess = () -> (Void)
public typealias AgoraEduContextSuccessWithString = (String) -> (Void)
public typealias AgoraEduContextFail = (AgoraEduContextError) -> (Void)

// MARK: - Private communication
@objc public protocol AgoraEduPrivateChatHandler: NSObjectProtocol {
    // 收到开始私密语音通知
    @objc optional func onStartPrivateChat(_ info: AgoraEduContextPrivateChatInfo)
    // 收到结束私密语音通知
    @objc optional func onEndPrivateChat()
}

@objc public protocol AgoraEduPrivateChatContext: NSObjectProtocol {
    // 开始私密语音
    func updatePrivateChat(_ userUuid: String)
    // 停止私密语音
    func endPrivateChat()
    // 事件监听
    func registerEventHandler(_ handler: AgoraEduPrivateChatHandler)
}

// MARK: - WhiteBoard
@objc public protocol AgoraEduWhiteBoardHandler: NSObjectProtocol {
    // 课件下载失败
    @objc optional func onDownloadError(_ url: String)
    // 课件下载取消
    @objc optional func onCancelCurDownload()
    
    /** 新增接口 **/
    // 获取白板容器View, 真正的白板会放在这个容器里面
    @objc optional func onBoardContentView(_ view: UIView)
    /*
     设置是否可以画
     文案显示：
     enabled == true -> "你可以使用白板了" 【文案名：UnMuteBoardText】
     enabled == false -> "你现在无权使用白板了" 【文案名：MuteBoardText】
     */
    @objc optional func onDrawingEnabled(_ enabled: Bool)
    
    // 白板加载状态
    @objc optional func onLoadingVisible(_ visible: Bool)
    
    // 课件下载进度，url是课件地址，progress:0-100
    @objc optional func onDownloadProgress(_ url: String,
                                           progress: Float)
    // 课件下载时间过长，一次课件下载超过了15秒，会有该调用
    @objc optional func onDownloadTimeOut(_ url: String)
    
    // 课件下载完成
    @objc optional func onDownloadComplete(_ url: String)
}

@objc public protocol AgoraEduWhiteBoardContext: NSObjectProtocol {
    // 设置是否可以使用教具
    func boardInputEnable(_ enable: Bool)
    // 跳过课件下载
    func skipDownload(_ url: String)
    // 取消课件下载
    func cancelDownload(_ url: String)
    // 课件下载重试
    func retryDownload(_ url: String)
    // 刷新白板大小， 在白板容器大小发送变化的时候，需要调用该方法
    func boardRefreshSize()
    
    // 获取白板内容的 View, 如果白板没有初始化成功， 返回为nil
    func getContentView() -> UIView?
    
    // 事件监听
    func registerBoardEventHandler(_ handler: AgoraEduWhiteBoardHandler)
    
    /// 设置当前场景
    /// - parameter 路径
    func setScenePath(_ path: String)
    
    /// 插入新的场景
    /// - parameter dir 目录位置
    /// - parameter scenes 要插入的场景数组
    /// - parameter index 插入的位置
    func pushScenes(dir: String,
                    scenes: [AgoraEduContextWhiteScene],
                    index: UInt)
    
    /// 获取课件列表
    /// - Returns: 课件列表
    func getCoursewares() -> [AgoraEduContextCourseware]
}

@objc public protocol AgoraEduWhiteBoardToolContext: NSObjectProtocol {
    // 选择教具
    func applianceSelected(_ mode: AgoraEduContextApplianceType)
    // 选择颜色
    func colorSelected(_ color: UIColor)
    // 选择字体大小
    func fontSizeSelected(_ size: Int)
    // 选择粗细
    func thicknessSelected(_ thick: Int)
}

@objc public protocol AgoraEduWhiteBoardPageControlHandler: NSObjectProtocol {
    /** 新增接口 **/
    // 设置总页数，当前第几页
    @objc optional func onPageIndex(_ pageIndex: NSInteger,
                                    pageCount: NSInteger)
    // 设置是否全屏，注意和onResizeFullScreenEnable的区别
    @objc optional func onFullScreen(_ fullScreen: Bool)
    
    // 是否可以翻页
    @objc optional func onPagingEnable(_ enable: Bool)
    // 是否可以放大、缩小
    @objc optional func onZoomEnable(_ zoomOutEnable: Bool,
                                     zoomInEnable: Bool)
    // 是否可以全屏，注意和onFullScreen的区别
    @objc optional func onResizeFullScreenEnable(_ enable: Bool)
}

@objc public protocol AgoraEduWhiteBoardPageControlContext: NSObjectProtocol {
    // 放大白板，每次10%
    func zoomIn()
    // 缩小白板，每次10%
    func zoomOut()
    // 选择上一页
    func prevPage()
    // 选择下一页
    func nextPage()
    // 事件监听
    func registerPageControlEventHandler(_ handler: AgoraEduWhiteBoardPageControlHandler)
}

// MARK: - Classroom
@objc public protocol AgoraEduRoomHandler: NSObjectProtocol {
    /// 房间自定义属性更新
    ///
    /// - parameter changedProperties: 本次更新的部分 properties
    /// - parameter cause: 更新的原因
    /// - parameter operator: 该操作的执行者
    @objc optional func onRoomPropertiesUpdated(changedProperties: [String: Any],
                                                cause: [String: Any]?,
                                                operator: AgoraEduContextUserInfo?)
    /// 房间自定义属性删除
    ///
    /// - parameter keyPaths: 被删除的属性的key path数组
    /// - parameter cause: 原因
    /// - parameter operator: 该操作的执行者
    @objc optional func onRoomPropertiesDeleted(keyPaths: [String],
                                                cause: [String: Any]?,
                                                operator: AgoraEduContextUserInfo?)
    /// 房间关闭
    @objc optional func onRoomClosed()
    /// 课堂状态更新
    ///
    /// - parameter state: 当前的课堂状态
    @objc optional func onClassStateUpdated(state: AgoraEduContextClassState)
}

@objc public protocol AgoraEduRoomContext: NSObjectProtocol {
    /// 事件监听
    func registerEventHandler(_ handler: AgoraEduRoomHandler)
    /// 加入房间
    func joinRoom(success: (() -> Void)?,
                  fail: ((AgoraEduContextError) -> Void)?)
    /// 离开房间
    func leaveRoom()
    /// 获取房间信息
    func getRoomInfo() -> AgoraEduContextRoomInfo
    /// 更新自定义房间属性，如果没有就增加
    /// 支持path修改和整体修改
    /// - parameter properties: {"key.subkey":"1"}  和 {"key":{"subkey":"1"}}
    /// - parameter cause: 修改的原因，可为空
    func updateRoomProperties(_ properties: [String: String],
                              cause: [String: String]?,
                              success: (() -> Void)?,
                              fail: ((AgoraEduContextError) -> Void)?)
    /// 删除房间自定义属性
    func deleteRoomProperties(_ keyPaths: [String],
                              cause: [String: Any]?,
                              success: (() -> Void)?,
                              fail: ((AgoraEduContextError) -> Void)?)
    /// 在加入房间后，不立即上课，而是老师手动触发上课
    func startClass(success: (() -> Void)?,
                    fail: ((AgoraEduContextError) -> Void)?)
    /// 获取课堂信息
    func getClassInfo() -> AgoraEduContextClassInfo
}

// MARK: - User
@objc public protocol AgoraEduUserHandler: NSObjectProtocol {
    /// 远端用户加入(v2.0.0)
    /// - parameter user: 加入的远端用户
    @objc optional func onRemoteUserJoined(user: AgoraEduContextUserInfo)
    
    /// 远端用户离开(v2.0.0)
    /// - parameter user: 离开的远端用户
    /// - parameter operator: 操作者，可为空
    /// - parameter reason: 离开的原因（默认为normal）
    @objc optional func onRemoteUserLeft(user: AgoraEduContextUserInfo,
                                         operator: AgoraEduContextUserInfo?,
                                         reason: AgoraEduContextUserLeaveReason)
    
    /// 用户信息更新(v2.0.0)
    /// - parameter user: 更新的用户
    /// - parameter operator: 操作者，可为空
    @objc optional func onUserUpdated(user: AgoraEduContextUserInfo,
                                      operator: AgoraEduContextUserInfo?)

    /// 用户自定义属性更新(v2.0.0)
    /// - parameter user: 更新的用户
    /// - parameter changedProperties: 更新的用户属性字典
    /// - parameter cause: 更新的原因，可为空
    /// - parameter operator: 操作者，可为空
    @objc optional func onUserPropertiesUpdated(user: AgoraEduContextUserInfo,
                                                changedProperties: [String: String],
                                                cause: [String: String]?,
                                                operator: AgoraEduContextUserInfo?)
    
    /// 用户自定义属性删除(v2.0.0)
    /// - parameter user: 更新的用户
    /// - parameter deletedProperties: 删除的用户属性列表
    /// - parameter cause: 更新的原因，可为空
    /// - parameter operator: 操作者，可为空
    @objc optional func onUserPropertiesDeleted(user: AgoraEduContextUserInfo,
                                                deletedProperties: [String],
                                                cause: [String: String]?,
                                                operator: AgoraEduContextUserInfo?)

    /// 用户收到奖励（v2.0.0)
    /// - parameter user: 收到奖励的用户
    /// - parameter rewardCount: 奖励数量
    /// - parameter operator: 发奖者
    @objc optional func onUserRewarded(user: AgoraEduContextUserInfo,
                                       rewardCount: Int,
                                       operator: AgoraEduContextUserInfo)
    
    /// 自己被踢出（v2.0.0)
    @objc optional func onLocalUserKickedOut()
    
    /// 用户挥手（v2.0.0)
    /// - parameter fromUser: 手放下的用户
    /// - parameter duration: 举手的时长，单位秒
    @objc optional func onUserHandsWave(fromUser: AgoraEduContextUserInfo,
                                        duration: Int)
    
    /// 用户手放下，结束上台申请（v2.0.0)
    /// - parameter user: 收到奖励的用户
    /// - parameter duration: 收到奖励的用户
    /// - note: 无论是用户自己取消举手，还是举手申请被接受，都要走这个回调
    @objc optional func onUserHandsDown(fromUser: AgoraEduContextUserInfo)
}

@objc public protocol AgoraEduUserContext: NSObjectProtocol {
    /// 获取本地用户信息(v2.0.0)
    /// - Returns: 本地用户信息
    func getLocalUserInfo() -> AgoraEduContextUserInfo
    
    /// 获取所有在线用户信息 (v2.0.0)
    /// - returns: 用户列表数组
    func getCoHostList() -> [AgoraEduContextUserInfo]
    
    /// 获取指定角色的用户信息数组 (v2.0.0)
    /// - parameter role: 角色
    /// - returns: 用户信息数组
    func getUserList(role: AgoraEduContextUserRole) -> [AgoraEduContextUserInfo]?
    
    /// 获取所有用户信息 (v2.0.0)
    /// - parameter role: 角色
    /// - returns: 用户信息数组
    func getAllUserList() -> [AgoraEduContextUserInfo]
    
    /// 更新用户自定义属性 (v2.0.0)
    /// - parameter userUuid: 用户id
    /// - parameter properties: 更新属性。支持path修改和整体修改 {"key.subkey":"1"}  和 {"key":{"subkey":"1"}}
    /// - parameter cause: 修改原因。可为空, nullable
    /// - parameter success: 请求成功
    /// - parameter failure: 请求失败
    /// - returns: void
    func updateUserProperties(userUuid: String,
                              properties: [String: Any],
                              cause:[String: Any]?,
                              success: AgoraEduContextSuccess?,
                              failure: AgoraEduContextFail?)
    
    /// 删除用户自定义属性 (v2.0.0)
    /// - parameter userUuid: 用户id
    /// - parameter keyPaths: 要删除的属性
    /// - parameter cause: 删除原因。可为空, nullable
    /// - parameter success: 请求成功
    /// - parameter failure: 请求失败
    /// - returns: void
    func deleteUserProperties(userUuid: String,
                              keyPaths: [String],
                              cause:[String: Any]?,
                              success: AgoraEduContextSuccess?,
                              failure: AgoraEduContextFail?)
    
    /// 获取用户自定义属性 (v2.0.0)
    /// - parameter userUuid: 用户id
    /// - returns: 用户自定义属性，可为空
    func getUserProperties(userUuid: String) -> [String: Any]?

    /// 事件监听
    /// - parameter handler: 监听者
    func registerEventHandler(_ handler: AgoraEduUserHandler)
    
    /// 指定用户上台 (v2.0.0)
    /// - parameter userUuid: 用户id
    /// - parameter success: 请求成功
    /// - parameter failure: 请求失败
    /// - returns: void
    func addCoHost(userUuid: String,
                   success: AgoraEduContextSuccess?,
                   failure: AgoraEduContextFail?)
    
    /// 指定用户下台(v2.0.0)
    /// - parameter userUuid: 用户id
    /// - parameter success: 请求成功
    /// - parameter failure: 请求失败
    /// - returns: void
    func removeCoHost(userUuid: String,
                      success: AgoraEduContextSuccess?,
                      failure: AgoraEduContextFail?)
    
    /// 所有学生下台(v2.0.0)
    /// - parameter success: 请求成功
    /// - parameter failure: 请求失败
    /// - returns: void
    func removeAllCoHosts(success: AgoraEduContextSuccess?,
                          failure: AgoraEduContextFail?)
    
    /// 给用户发奖 (v2.0.0)
    /// - parameter userUuid: 用户id
    /// - parameter rewardCount: 奖杯数量
    /// - parameter success: 请求成功
    /// - parameter failure: 请求失败
    /// - returns: void
    func rewardUsers(userUuids: [String],
                     rewardCount: Int,
                     success: AgoraEduContextSuccess?,
                     failure: AgoraEduContextFail?)
    
    /// 踢人 (v2.0.0)
    /// - parameter userUuid: 用户id
    /// - parameter forever: 是否永久踢出该用户
    /// - parameter success: 请求成功
    /// - parameter failure: 请求失败
    /// - returns: void
    func kickOutUser(userUuid: String,
                     forever: Bool,
                     success: AgoraEduContextSuccess?,
                     failure: AgoraEduContextFail?)
    /// 举手，申请上台 (v1.2.0)
    /// - parameter duration: 举手申请的时长，单位秒
    /// - parameter success: 请求成功
    /// - parameter failure: 请求失败
    /// - returns: void
    func handsWave(duration: Int,
                   success: AgoraEduContextSuccess?,
                   failure: AgoraEduContextFail?)

    /// 手放下，取消申请上台 (v2.0.0)
    /// - parameter success: 请求成功
    /// - parameter failure: 请求失败
    /// - returns: void
    func handsDown(success: AgoraEduContextSuccess?,
                   failure: AgoraEduContextFail?)
}

// MARK: - HandsUp
@objc public protocol AgoraEduHandsUpHandler: NSObjectProtocol {
    
    /** 新增接口 **/
    /* 是否可以举手
     * 文案显示：
     * enabled == true -> "老师开启了举手功能" 【文案名：OpenHandsUpText】
     * enabled == false -> "老师关闭了举手功能" 【文案名：CloseHandsUpText】
     */
    @objc optional func onHandsUpEnable(_ enable: Bool)
    
    /* 当前举手状态
     * 文案显示：
     * state == handsUp -> "举手成功" 【文案名：HandsUpSuccessText】
     * enabled == handsDown -> "取消举手成功" 【文案名：HandsDownSuccessText】
     */
    @objc optional func onHandsUpState(_ state: AgoraEduContextHandsUpState)
    
    // 更新举手状态结果，如果error不为空，代表失败
    /* 是否可以举手
     * 文案显示：
     * 如果error不为空，展示error的msg
     */
    @objc optional func onHandsUpError(_ error: AgoraEduContextError?)
    
    // 新增的回调，举手申请的结果
    @objc optional func onHandsUpResult(_ result: AgoraEduContextHandsUpResult)
}

@objc public protocol AgoraEduHandsUpContext: NSObjectProtocol {
    // 更新举手状态【即将废弃】
    func updateHandsUpState(_ state: AgoraEduContextHandsUpState)
    // 事件监听
    func registerEventHandler(_ handler: AgoraEduHandsUpHandler)
    
    /** 新增接口 **/
    func updateWaveArmsState(_ state: AgoraEduContextHandsUpState,
                            timeout: Int)
}

@objc public protocol AgoraEduMediaHandler: NSObjectProtocol {
    /// 音量变化 (v2.0.0)
    /// - parameter volume: 音量
    /// - parameter streamUuid: 流 Id
    /// - returns: Void
    @objc optional  func onVolumeUpdated(volume: Int,
                         streamUuid: String)
    
    /// 设备状态更新 (v2.0.0)
    /// - parameter device: 设备信息
    /// - parameter state: 设备状态
    /// - returns: Void
    @objc optional func onLocalDeviceStateUpdated(device: AgoraEduContextDeviceInfo,
                                   state: AgoraEduContextDeviceState)
}

// MARK: - Media
@objc public protocol AgoraEduMediaContext: NSObjectProtocol {
    /// 获取设备列表 (v2.0.0)
    /// - parameter deviceType: 设备类型
    /// - returns: [AgoraEduContextDeviceInfo], 设备列表
    func getLocalDevices(deviceType: AgoraEduContextDeviceType) -> [AgoraEduContextDeviceInfo]
    
    /// 打开设备 (v2.0.0)
    /// - parameter device: 设备信息
    /// - returns: AgoraEduContextError, 返回错误
    func openLocalDevice(device: AgoraEduContextDeviceInfo) -> AgoraEduContextError?
    
    /// 关闭设备 (v2.0.0)
    /// - parameter device: 设备信息
    /// - returns: AgoraEduContextError, 返回错误
    func closeLocalDevice(device: AgoraEduContextDeviceInfo) -> AgoraEduContextError?
    
    /// 获取设备状态 (v2.0.0)
    /// - parameter device: 设备信息
    /// - parameter success: 参数正确，返回设备状态
    /// - parameter fail: 参数错误
    /// - returns: AgoraEduContextError, 返回错误
    func getLocalDeviceState(device: AgoraEduContextDeviceInfo,
                             success: (AgoraEduContextDeviceState) -> (),
                             fail: (AgoraEduContextError) -> ())
    
    /// 渲染本地视频流 (v2.0.0)
    /// - parameter view: 渲染视频的容器
    /// - parameter renderConfig: 渲染配置
    /// - parameter streamUuid: 流 Id
    /// - returns: AgoraEduContextError, 返回错误
    func startRenderLocalVideo(view: UIView,
                               renderConfig: AgoraEduContextRenderConfig,
                               streamUuid: String) -> AgoraEduContextError?
    
    /// 停止渲染本地视频流 (v2.0.0)
    /// - parameter streamUuid: 流 Id
    /// - returns: AgoraEduContextError, 返回错误
    func stopRenderLocalVideo(streamUuid: String) -> AgoraEduContextError?
    
    /// 渲染远端视视频流 (v2.0.0)
    /// - parameter view: 渲染视频的容器
    /// - parameter renderConfig: 渲染配置
    /// - parameter streamUuid: 流 Id
    /// - returns: AgoraEduContextError, 返回错误
    func startRenderRemoteVideo(view: UIView,
                                renderConfig: AgoraEduContextRenderConfig,
                                streamUuid: String) -> AgoraEduContextError?
    
    /// 停止渲染远端视频流 (v2.0.0)
    /// - parameter streamUuid: 流 Id
    /// - returns: AgoraEduContextError, 返回错误
    func stopRenderRemoteVideo(streamUuid: String) -> AgoraEduContextError?
    
    /// 注册事件监听
    /// - returns: Void
    func registerMediaEventHandler(_ handler: AgoraEduMediaHandler)
}

// MARK: - Widget
@objc public protocol AgoraEduWidgetContext: AgoraWidgetProtocol {
    func getAgoraWidgetProperties(type: EduContextWidgetType) -> [String: Any]?
}

// MARK: - Stream
@objc public protocol AgoraEduStreamHandler: NSObjectProtocol {
    
    /// 远端流加入频道事件 (v1.2.0)
    /// - parameter stream: 流信息
    /// - parameter operator: 操作人，可以为空
    /// - returns: void
    @objc optional func onStreamJoin(stream: AgoraEduContextStream,
                                     operator: AgoraEduContextUserInfo?)
    
    /// 远端流离开频道事件 (v1.2.0)
    /// - parameter stream: 流信息
    /// - parameter operator: 操作人，可以为空
    /// - returns: void
    @objc optional func onStreamLeave(stream: AgoraEduContextStream,
                                      operator: AgoraEduContextUserInfo?)
    
    /// 远端流更新事件 (v1.2.0)
    /// - parameter stream: 流信息
    /// - parameter operator: 操作人，可以为空
    /// - returns: void
    @objc optional func onStreamUpdate(stream: AgoraEduContextStream,
                                       operator: AgoraEduContextUserInfo?)
}

@objc public protocol AgoraEduStreamContext: NSObjectProtocol {
    /// 禁止或允许远端用户发视频流 (v1.2.0)
    /// - parameter userUuid: 用户id
    /// - parameter mute: 是否禁止发流
    /// - parameter success: 请求成功
    /// - parameter failure: 请求失败
    /// - returns: void
    func muteRemoteVideo(streamUuids: [String],
                         mute: Bool,
                         success: AgoraEduContextSuccess?,
                         failure: AgoraEduContextFail?)
    
    /// 禁止或允许远端用户发音频流 (v1.2.0)
    /// - parameter userUuid: 用户id
    /// - parameter mute: 是否禁止发流
    /// - parameter success: 请求成功
    /// - parameter failure: 请求失败
    /// - returns: void
    func muteRemoteAudio(streamUuids: [String],
                         mute: Bool,
                         success: AgoraEduContextSuccess?,
                         failure: AgoraEduContextFail?)
    
    /// 获取某个用户的一组流信息 (v1.2.0)
    /// - parameter userUuid: 用户Id
    /// - returns: [AgoraEduContextStream]， 流信息的数组，可以为空
    func getStreamsInfo(userUuid: String) -> [AgoraEduContextStream]?
    
    /// 选择订阅高/低分辨率的视频流 (v1.2.0)
    /// - parameter streamUuid: 流Id
    /// - parameter level: 分辨率类型
    /// - returns: void
    func subscribeVideoStreamLevel(streamUuid: String,
                                   level: AgoraEduContextVideoStreamSubscribeLevel)
    
    /// 注册流事件回调 (v1.2.0)
    /// - parameter handler: 遵守 AgoraEduStreamHandler 的对象
    /// - returns: void
    func registerStreamEventHandler(_ handler: AgoraEduStreamHandler)
}

// MARK: - Monitor
@objc public protocol AgoraEduMonitorContext: NSObjectProtocol {
    /// 上传日志(v2.0.0)
    /// - parameter success: 上传成功，获取日志的id
    /// - parameter failure: 上传失败
    /// - returns: void
    func uploadLog(success: AgoraEduContextSuccessWithString?,
                   failure: AgoraEduContextFail?)
    
    /// 注册SDK状态监控事件回调 (v2.0.0)
    /// - parameter handler: 遵守 AgoraEduMonitorHandler 的对象
    /// - returns: void
    func registerMonitorEventHandler(_ handler: AgoraEduMonitorHandler)
}

@objc public protocol AgoraEduMonitorHandler: NSObjectProtocol {
    /// 本地网络质量更新(v2.0.0)
    /// - parameter quality: 网络质量
    /// - returns: void
    @objc optional func onLocalNetworkQualityUpdated(quality: AgoraEduContextNetworkQuality)
    
    /// 本地与服务器的连接状态
    /// - parameter state: 连接
    /// - returns: void
    @objc optional func onLocalConnectionUpdated(state: AgoraEduContextConnectionState)
}
