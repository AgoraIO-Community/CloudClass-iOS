//
//  AgoraEduContextProtocols.swift
//  AgoraUIEduBaseViews
//
//  Created by SRS on 2021/3/7.
//

import AgoraWidget
import UIKit

public typealias AgoraEduContextSuccess = () -> (Void)
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
    // 日志上传成功
    @objc optional func onUploadLogSuccess(_ logId: String)
    // 上课过程中，错误信息
    @objc optional func onShowErrorInfo(_ error: AgoraEduContextError)
    
    // 加入教室成功
    @objc optional func onClassroomJoined()
    
    // 房间属性初始化， 如果没有设置Flex属性，怎么不会回调
    // properties：用户自定义全量房间属性
    @objc optional func onFlexRoomPropertiesInitialize(_ properties: [String: Any])
    // 房间属性变化
    // properties：用户自定义全量房间属性
    // server更新的时候operator为空
    @objc optional func onFlexRoomPropertiesChanged(_ changedProperties: [String],
                                                    properties: [String: Any],
                                                    cause: [String: Any]?,
                                                    operator:AgoraEduContextUserInfo?)
    
    /** 新增接口 **/
    // 设置课程名称
    @objc optional func onClassroomName(_ name: String)
    // 设置课程状态
    @objc optional func onClassState(_ state: AgoraEduContextClassState)
    
    /* 显示课程时间(课堂时间相关信息传递给UI层，UI层自己处理相关逻辑):
     * 上课前：`距离上课还有：X分X秒` 【文案名：ClassBeforeStartText,ClassTimeMinuteText,ClassTimeSecondText】
     * 开始上课：`已开始上课:X分X秒` 【文案名：ClassAfterStartText,ClassTimeMinuteText,ClassTimeSecondText】
     * 结束上课：`已开始上课:X分X秒` 【文案名：ClassAfterStartText,ClassTimeMinuteText,ClassTimeSecondText】
     * 上课期间的提示:
     * 课程还有5分钟结束 【文案名：ClassEndWarningStartText,ClassEndWarningEndText】
     * 课程结束咯，还有10分钟关闭教室 【文案名：ClassCloseWarningStartText,ClassCloseWarningEnd2Text,ClassCloseWarningEndText】
     * 距离教室关闭还有1分钟 【文案名：ClassCloseWarningStart2Text,ClassCloseWarningEnd2Text】
     */
    @objc optional func onClassTimeInfo(startTime: Int64,
                                        differTime: Int64,
                                        duration: Int64,
                                        closeDelay: Int64)
    
    // 网络状态
    @objc optional func onNetworkQuality(_ quality: AgoraEduContextNetworkQuality)
    // 连接状态
    @objc optional func onConnectionState(_ state: AgoraEduContextConnectionState)
}

@objc public protocol AgoraEduRoomContext: NSObjectProtocol {
    // 房间信息
    func getRoomInfo() -> AgoraEduContextRoomInfo
    
    // 加入房间
    func joinClassroom()
    
    // 更新自定义房间属性，如果没有就增加
    // 支持path修改和整体修改
    // properties: {"key.subkey":"1"}  和 {"key":{"subkey":"1"}}
    // cause: 修改的原因，可为空
    func updateFlexRoomProperties(_ properties:[String: String],
                                  cause:[String: String]?)
    
    // 离开教室
    func leaveRoom()
    // 上传日志
    func uploadLog()
    // 事件监听
    func registerEventHandler(_ handler: AgoraEduRoomHandler)
    
    /** 新增接口 **/
    // 刷新房间
    func refresh()
}

// MARK: - Message
@objc public protocol AgoraEduMessageHandler: NSObjectProtocol {
    // 收到房间消息
    @objc optional func onAddRoomMessage(_ info: AgoraEduContextChatInfo)
    // 收到提问消息
    @objc optional func onAddConversationMessage(_ info: AgoraEduContextChatInfo)
    
    /* 收到聊天权限变化
     * 文案显示：
     * allow == true -> "禁言模式开启" 【文案名： ChatDisableToastText】
     * allow == false -> "禁言模式关闭" 【文案名： ChatEnableToastText】
     */
    @objc optional func onUpdateChatPermission(_ allow: Bool)
    
    /* 收到本地聊天权限变化
     * 文案显示：
     * allow == true -> "你被xx禁言了"
     * allow == false -> "你被xx解除了禁言"
     */
    @objc optional func onUpdateLocalChatPermission(_ allow: Bool,
                                                    toUser: AgoraEduContextUserInfo,
                                                    operatorUser: AgoraEduContextUserInfo)
    
    /* 收到远端聊天权限变化
     * 文案显示：
     * allow == true -> "xx被xx禁言了"
     * allow == false -> "xx被xx解除了禁言"
     */
    @objc optional func onUpdateRemoteChatPermission(_ allow: Bool,
                                                     toUser: AgoraEduContextUserInfo,
                                                     operatorUser: AgoraEduContextUserInfo)
    
    // 本地发送消息结果（包含首次和后面重发），如果error不为空，代表失败
    @objc optional func onSendRoomMessageResult(_ error: AgoraEduContextError?,
                                                info: AgoraEduContextChatInfo)
    
    // 本地发送提问消息结果（包含首次和后面重发），如果error不为空，代表失败
    @objc optional func onSendConversationMessageResult(_ error: AgoraEduContextError?,
                                                        info: AgoraEduContextChatInfo?)
    
    // 查询历史消息结果，如果error不为空，代表失败
    @objc optional func onFetchHistoryMessagesResult(_ error: AgoraEduContextError?,
                                                     list: [AgoraEduContextChatInfo]?)
    
    @objc optional func onFetchConversationHistoryMessagesResult(_ error: AgoraEduContextError?,
                                                                 list: [AgoraEduContextChatInfo]?)
    
    /** 新增接口 **/
    // 房间消息列表更新
    @objc optional func onUpdateRoomMessageList(_ list: [AgoraEduContextChatInfo])
    // 提问消息列表更新
    @objc optional func onUpdateConversationMessageList(_ list: [AgoraEduContextChatInfo])
}

@objc public protocol AgoraEduMessageContext: NSObjectProtocol {
    // 发送房间信息
    func sendRoomMessage(_ message: String)
    // 发送提问信息
    func sendConversationMessage(_ message: String)
    /* 重发房间信息
     * messageId: AgoraEduContextChatInfo内id
     */
    func resendRoomMessage(_ message: String,
                           messageId: String)
    
    /* 重发提问信息
     * messageId: AgoraEduContextChatInfo内id
     */
    func resendConversationMessage(_ message: String,
                                   messageId: String)
    /* 获取历史消息
     * startId: 从哪个开始获取，AgoraEduContextChatInfo内id
     * count: 要获取多少条数据
     */
    func fetchHistoryMessages(_ startId: String,
                              count: Int)
    
    /* 获取提问历史消息
     * startId: 从哪个开始获取，AgoraEduContextChatInfo内id
     * count: 要获取多少条数据
     */
    func fetchConversationHistoryMessages(_ startId: String,
                                          count: Int)
    
    // 事件监听
    func registerEventHandler(_ handler: AgoraEduMessageHandler)
}

// MARK: - User
@objc public protocol AgoraEduUserHandler: NSObjectProtocol {
    // 更新人员信息列表，只显示在线人员信息
    @objc optional func onUpdateUserList(_ list: [AgoraEduContextUserDetailInfo])
    
    // 更新人员信息列表，只显示台上人员信息。（台上会包含不在线的）
    @objc optional func onUpdateCoHostList(_ list: [AgoraEduContextUserDetailInfo])
    
    // 自己被踢出
    @objc optional func onKickedOut()
    
    // 音量提示
    @objc optional func onUpdateAudioVolumeIndication(_ value: Int,
                                                      streamUuid: String)
    
    // 收到奖励（自己或者其他学生）
    @objc optional func onShowUserReward(_ user: AgoraEduContextUserInfo)
    
    // 人员属性变化
    // properties：人员全量自定义属性信息返回
    @objc optional func onFlexUserPropertiesChanged(_ changedProperties: [String : Any],
                                                    properties: [String: Any],
                                                    cause: [String : Any]?,
                                                    fromUser: AgoraEduContextUserDetailInfo,
                                                    operator: AgoraEduContextUserInfo?)
    
    @objc optional func onStreamUpdated(_ streamType: EduContextMediaStreamType,
                                        fromUser: AgoraEduContextUserDetailInfo,
                                        operator: AgoraEduContextUserInfo?)
    
    @objc optional func onRemoteUserLeft(users: [AgoraEduContextUserInfo])
    @objc optional func onRemoteUserJoin(users: [AgoraEduContextUserInfo])
}

@objc public protocol AgoraEduUserContext: NSObjectProtocol {
    
    /* 人员属性变化
     * 支持path修改和整体修改
     * {"key.subkey":"1"}  和 {"key":{"subkey":"1"}}
     */
    func updateFlexUserProperties(_ userUuid: String,
                                  properties: [String: String],
                                  cause:[String: String]?)
    
    // 事件监听
    func registerEventHandler(_ handler: AgoraEduUserHandler)
    
    /** 新增接口 **/
    // 获取本地用户信息
    func getLocalUserInfo() -> AgoraEduContextUserInfo
    
    /// 获取用户自定义属性 (v1.2.0)
    /// - parameter userUuid: 用户id
    /// - returns: 用户自定义属性字典
    func getFlexUserProperties(userUuid: String) -> [String: Any]?
    
    /// 获取所有上台用户信息 (v1.2.0)
    /// - returns: 用户列表数组
    func getUserInfoList() -> [AgoraEduContextUserDetailInfo]

    /// 获取所有在线用户信息 (v1.2.0)
    /// - returns: 用户列表数组
    func getCoUserInfoList() -> [AgoraEduContextUserDetailInfo]
    
    /// 指定用户上台 (v1.2.0)
    /// - parameter userUuids: 用户id
    /// - returns: void
    func addCoHosts(userUuids: [String],
                    success: AgoraEduContextSuccess?,
                    failure: AgoraEduContextFail?)
    
    /// 指定用户下台 (v1.2.0)
    /// - parameter userUuids: 用户id
    /// - parameter success: 请求成功
    /// - parameter failure: 请求失败
    /// - returns: void
    func removeCoHosts(userUuids: [String],
                       success: AgoraEduContextSuccess?,
                       failure: AgoraEduContextFail?)
    
    /// 授权/取消用户的白板操作权限 (v1.2.0)
    /// - parameter userUuid: 用户id
    /// - parameter granted: 是否授权
    /// - returns: void
    func updateBoardGranted(userUuids: [String],
                            granted: Bool)
    
    /// 给用户发奖 (v1.2.0)
    /// - parameter userUuid: 用户id
    /// - parameter rewardCount: 奖杯数量
    /// - parameter success: 请求成功
    /// - parameter failure: 请求失败
    /// - returns: void
    func rewardUsers(userUuids: [String],
                     rewardCount: Int,
                     success: AgoraEduContextSuccess?,
                     failure: AgoraEduContextFail?)
    
    /// 踢人 (v1.2.0)
    /// - parameter userUuid: 用户id
    /// - parameter forever: 是否永久踢出该用户
    /// - parameter success: 请求成功
    /// - parameter failure: 请求失败
    /// - returns: void
    func kickOut(userUuids: [String],
                 forever: Bool,
                 success: AgoraEduContextSuccess?,
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

// MARK: - ScreenSharing
@objc public protocol AgoraEduScreenShareHandler: NSObjectProtocol {
    /* 开启或者关闭屏幕分享
     * 文案显示：
     * state == .start -> "老师发起了屏幕共享" 【文案名：ScreensharedBySb】
     * state == .stop -> "老师停止了屏幕共享" 【文案名：ScreenshareStoppedBySb】
     *
     */
    @objc optional func onUpdateScreenShareState(_ state: AgoraEduContextScreenShareState,
                                                 streamUuid: String)
    
    // 切换屏幕课件Tab
    @objc optional func onSelectScreenShare(_ selected: Bool)
}

@objc public protocol AgoraEduScreenShareContext: NSObjectProtocol {
    // 事件监听
    func registerEventHandler(_ handler: AgoraEduScreenShareHandler)
}

// MARK: - Device
@objc public protocol AgoraEduDeviceHandler: NSObjectProtocol {
    /* 摄像头开关
     * 文案显示：
     *   enabled == true -> "你的摄像头被打开了" 【文案名：CameraUnMuteText】
     *   enabled == false -> "你的摄像头被关闭了" 【文案名：CameraMuteText】
     *
     * 你的麦克风被关闭了
     *
     * 你的麦克风被打开了
     */
    @objc optional func onCameraDeviceEnableChanged(enabled: Bool)
    
    // 摄像头切换
    @objc optional func onCameraFacingChanged(facing: EduContextCameraFacing)
    
    /* 麦克风开关
     *   enabled == true -> "你可以发言了" 【文案名：MicrophoneUnMuteText】
     *   enabled == false -> "你暂时不能发言了" 【文案名：MicrophoneMuteText】
     *
     * 你的麦克风被关闭了
     *
     * 你的麦克风被打开了
     */
    @objc optional func onMicDeviceEnabledChanged(enabled: Bool)
    
    // 扬声器开关
    @objc optional func onSpeakerEnabledChanged(enabled: Bool)
}

@objc public protocol AgoraEduDeviceContext: NSObjectProtocol {
    func setCameraDeviceEnable(enable: Bool)
    func switchCameraFacing()
    func setMicDeviceEnable(enable: Bool)
    func setSpeakerEnable(enable: Bool)

    // 事件监听
    func registerDeviceEventHandler(_ handler: AgoraEduDeviceHandler)
}

// MARK: - Media
@objc public protocol AgoraEduMediaContext: NSObjectProtocol {
    // 开启摄像头
    func openCamera()
    // 关闭摄像头
    func closeCamera()
    // 开启本地视频预览
    func startPreview(_ view: UIView)
    // 停止本地视频预览
    func stopPreview()
    // 开启麦克风
    func openMicrophone()
    // 关闭麦克风
    func closeMicrophone()
    // 开始推流
    func publishStream(streamUuid: String,
                       type: EduContextMediaStreamType)
    // 停止推流
    func unpublishStream(streamUuid: String,
                         type: EduContextMediaStreamType)
    // 配置视频参数
    func setVideoConfig(_ videoConfig: AgoraEduContextVideoConfig)
    // 渲染本地视频流
    func startRenderLocalVideo(view: UIView,
                               renderConfig: AgoraEduContextRenderConfig,
                               streamUuid: String)
    // 停止渲染本地视频流
    func stopRenderLocalVideo(streamUuid: String)
    // 开始渲染远端视频流
    func startRenderRemoteVideo(view: UIView,
                                renderConfig: AgoraEduContextRenderConfig,
                                streamUuid: String)
    // 停止渲染远端视频流
    func stopRenderRemoteVideo(streamUuid: String)
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
