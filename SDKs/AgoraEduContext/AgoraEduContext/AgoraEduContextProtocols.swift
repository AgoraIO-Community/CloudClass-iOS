//
//  AgoraEduContextProtocols.swift
//  AgoraUIEduBaseViews
//
//  Created by SRS on 2021/3/7.
//

import UIKit
import AgoraWidget

// MARK: - PrivateChat
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
    
    /** 即将弃用接口 **/
    @available(*, deprecated, message: "use onBoardContentView instead of it")
    @objc optional func onGetBoardContainer() -> UIView?
    
    @available(*, deprecated, message: "use onDrawingEnabled instead of it")
    @objc optional func onSetDrawingEnabled(_ enabled: Bool)
    
    @available(*, deprecated, message: "use onLoadingVisible instead of it")
    @objc optional func onSetLoadingVisible(_ visible: Bool)
    
    @available(*, deprecated, message: "use onDownloadProgress instead of it")
    @objc optional func onSetDownloadProgress(_ url: String,
                                            progress: Float)
    @available(*, deprecated, message: "use onDownloadTimeOut instead of it")
    @objc optional func onSetDownloadTimeOut(_ url: String)
    
    @available(*, deprecated, message: "use onDownloadComplete instead of it")
    @objc optional func onSetDownloadComplete(_ url: String)

    @available(*, deprecated, message: "add tips in onDrawingEnabled")
    @objc optional func onShowPermissionTips(_ granted: Bool)
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

// MARK: - WhiteBoardPageControl
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
    
    /** 即将弃用接口 **/
    @available(*, deprecated, message: "use onPageIndex instead of it")
    @objc optional func onSetPageIndex(_ pageIndex: NSInteger,
                                     pageCount: NSInteger)
    
    @available(*, deprecated, message: "use onFullScreen instead of it")
    @objc optional func onSetFullScreen(_ fullScreen: Bool)
    
    @available(*, deprecated, message: "use onPagingEnable instead of it")
    @objc optional func onSetPagingEnable(_ enable: Bool)
    
    @available(*, deprecated, message: "use onZoomEnable instead of it")
    @objc optional func onSetZoomEnable(_ zoomOutEnable: Bool,
                                      zoomInEnable: Bool)
    
    @available(*, deprecated, message: "use onResizeFullScreenEnable instead of it")
    @objc optional func onSetResizeFullScreenEnable(_ enable: Bool)
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

// MARK: - Room
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
    @objc optional func onFlexRoomPropertiesChanged(_ changedProperties: [String: Any],
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

    /** 即将弃用接口 **/
    @available(*, deprecated, message: "use onClassroomName instead of it")
    @objc optional func onSetClassroomName(_ name: String)
    
    @available(*, deprecated, message: "use onClassState instead of it")
    @objc optional func onSetClassState(_ state: AgoraEduContextClassState)
    
    @available(*, deprecated, message: "use onClassTimeInfo instead of it")
    @objc optional func onSetClassTime(_ time: String)

    /* 该方法曾用于展示上课期间的提示：
     * 课程还有5分钟结束
     * 课程结束咯，还有5分钟关闭教室
     * 距离教室关闭还有1分钟
     * 现与onSetClassTime方法合并为onClassTimeInfo(startTime:differTime:duration:closeDelay:)方法，由UI层执行计时、显示tips等
     */
    @available(*, deprecated, message: "add tips in onClassTimeInfo instead of it")
    @objc optional func onShowClassTips(_ message: String)
    
    @available(*, deprecated, message: "use onNetworkQuality instead of it")
    @objc optional func onSetNetworkQuality(_ quality: AgoraEduContextNetworkQuality)
    
    @available(*, deprecated, message: "use onConnectionState instead of it")
    @objc optional func onSetConnectionState(_ state: AgoraEduContextConnectionState)
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
}

// MARK: - Chat
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
                                                info: AgoraEduContextChatInfo?)
    
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
    
    /** 即将弃用接口 **/
    /* 该方法曾用于显示聊天过程中提示信息：
     * 禁言模式开启
     * 禁言模式关闭
     * 现由UI层在onUpdateChatPermission方法中执行显示tips的操作
     */
    @available(*, deprecated, message: "add tips in onUpdateChatPermission instead of it")
    @objc optional func onShowChatTips(_ message: String)
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
    
    /** 即将弃用接口 **/
    /* 该方法曾用于显示提示信息
     * 你的摄像头被关闭了
     * 你的麦克风被关闭了
     * 你的摄像头被打开了
     * 你的麦克风被打开了
     * 现由UI层在AgoraEduDeviceHandler的onCameraDeviceEnableChanged,onMicDeviceEnabledChanged方法中执行显示tips的操作
     */
    @available(*, deprecated, message: "add tips in onCameraDeviceEnableChanged、onMicDeviceEnabledChanged in AgoraEduDeviceHandler instead of it")
    @objc optional func onShowUserTips(_ message: String)
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
    
    /** 即将弃用接口 **/
    @available(*, deprecated, message: "use publishStream in AgoraEduMediaContext instead of it")
    func muteVideo(_ mute: Bool)
    
    @available(*, deprecated, message: "use unpublishStream in AgoraEduMediaContext instead of it")
    func muteAudio(_ mute: Bool)
    
    @available(*, deprecated, message: "use renderRemoteView in AgoraEduMediaContext instead of it")
    func renderView(_ view: UIView?, streamUuid: String)
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
    
    /** 即将弃用接口 **/
    @available(*, deprecated, message: "use onHandsUpEnable instead of it")
    @objc optional func onSetHandsUpEnable(_ enable: Bool)
    
    @available(*, deprecated, message: "use onHandsUpState instead of it")
    @objc optional func onSetHandsUpState(_ state: AgoraEduContextHandsUpState)
    
    @available(*, deprecated, message: "use onHandsUpError instead of it")
    @objc optional func onUpdateHandsUpStateResult(_ error: AgoraEduContextError?)
    
    /* 该方法曾用于显示举手相关消息
     * 举手超时
     * 老师拒绝了你的举手申请x
     * 老师同意了你的举手申请
     * 你被老师下台了
     * 举手成功
     * 取消举手成功
     * 老师关闭了举手功能
     * 老师开启了举手功能
     * 现由UI层在onHandsUpEnable,onHandsUpState,onHandsUpError方法中执行显示tips的操作
     */
    @available(*, deprecated, message: "add tips in onHandsUpError instead of it")
    @objc optional func onShowHandsUpTips(_ message: String)
    
    // 新增的回调，举手申请的结果
    @objc optional func onHandsUpResult(_ result: AgoraEduContextHandsUpResult)
}

@objc public protocol AgoraEduHandsUpContext: NSObjectProtocol {
    // 更新举手状态
    func updateHandsUpState(_ state: AgoraEduContextHandsUpState)
    // 事件监听
    func registerEventHandler(_ handler: AgoraEduHandsUpHandler)
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
    
    /** 即将弃用接口 **/
    /* 该方法曾用于显示屏幕分享相关消息
     * XXX开启了屏幕分享
     * XXX关闭了屏幕分享
     * 现由UI层在onUpdateScreenShareState方法中执行显示tips的操作
     */
    @available(*, deprecated, message: "add tips in onUpdateScreenShareState instead of it")
    @objc optional func onShowScreenShareTips(_ message: String)
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
    
    /** 即将弃用接口 **/
    /* 原用于显示设备相关信息提示
    * 老师视频可能出现问题
    * 该文案已弃用
    */
    @objc optional func onDeviceTips(message: String)
}

@objc public protocol AgoraEduDeviceContext: NSObjectProtocol {
    func setCameraDeviceEnable(enable: Bool)
    func switchCameraFacing()
    func setMicDeviceEnable(enable: Bool)
    func setSpeakerEnable(enable: Bool)

    // 事件监听
    func registerDeviceEventHandler(_ handler: AgoraEduDeviceHandler)
}

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
    func publishStream(type: EduContextMediaStreamType)
    // 停止推流
    func unpublishStream(type: EduContextMediaStreamType)
    // 渲染或者关闭远端渲染，view为nil代表关闭渲染
    func renderRemoteView(_ view: UIView?, streamUuid: String)
    // 配置视频参数 (you must set Video Config before startOrUpdateLocalStream)
    func setVideoConfig(_ videoConfig: AgoraEduContextVideoConfig)
}

@objc public protocol AgoraEduWidgetContext: AgoraWidgetProtocol {
    
    func getAgoraWidgetProperties(type: EduContextWidgetType) -> [String: Any]?
    
    /** 新增接口 **/
//    func create(with: AgoraWidgetInfo) -> AgoraBaseWidget
    
    /** 已弃用接口 **/
    // 创建组件
    // info:组件配置信息
    // contextPool:给组件传递实现了协议的接口对象
    // func createWidget(info: AgoraWidgetInfo, contextPool: AgoraEduContextPool) -> AgoraEduWidget
}
