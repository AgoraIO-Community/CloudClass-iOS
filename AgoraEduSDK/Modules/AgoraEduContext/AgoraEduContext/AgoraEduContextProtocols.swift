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
    // 获取白板容器View, 真正的白板会放在这个容器里面
    @objc optional func onGetBoardContainer() -> UIView
    // 设置是否可以画
    @objc optional func onSetDrawingEnabled(_ enabled: Bool)
    // 白板加载状态
    @objc optional func onSetLoadingVisible(_ visible: Bool)
    
    // 课件下载进度，url是课件地址，progress:0-100
    @objc optional func onSetDownloadProgress(_ url: String,
                                            progress: Float)
    // 课件下载时间过长，一次课件下载超过了15秒，会有该调用
    @objc optional func onSetDownloadTimeOut(_ url: String)
    // 课件下载完成
    @objc optional func onSetDownloadComplete(_ url: String)
    // 课件下载失败
    @objc optional func onDownloadError(_ url: String)
    // 课件下载取消
    @objc optional func onCancelCurDownload()
    // 显示白板权限信息
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
    // 设置总页数，当前第几页
    @objc optional func onSetPageIndex(_ pageIndex: NSInteger,
                                     pageCount: NSInteger)
    // 设置是否全屏，注意和onSetResizeFullScreenEnable的区别
    @objc optional func onSetFullScreen(_ fullScreen: Bool)
    
    // 是否可以翻页
    @objc optional func onSetPagingEnable(_ enable: Bool)
    // 是否可以放大、缩小
    @objc optional func onSetZoomEnable(_ zoomOutEnable: Bool,
                                      zoomInEnable: Bool)
    // 是否可以全屏，注意和onSetFullScreen的区别
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
    // 设置课程名称
    @objc optional func onSetClassroomName(_ name: String)
    // 设置课程状态
    @objc optional func onSetClassState(_ state: AgoraEduContextClassState)
    /* 显示课程时间:
     * 上课前：`距离上课还有：X分X秒`
     * 开始上课：`已开始上课:X分X秒`
     * 结束上课：`已开始上课:X分X秒`
     */
    @objc optional func onSetClassTime(_ time: String)
    /* 上课期间的提示
     * 课程还有5分钟结束
     * 课程结束咯，还有5分钟关闭教室
     * 距离教室关闭还有1分钟
     * 设置上课期间的提示
     */
    @objc optional func onShowClassTips(_ message: String)
    // 网络状态
    @objc optional func onSetNetworkQuality(_ quality: AgoraEduContextNetworkQuality)
    // 连接状态
    @objc optional func onSetConnectionState(_ state: AgoraEduContextConnectionState)
    // 日志上传成功
    @objc optional func onUploadLogSuccess(_ logId: String)
    // 上课过程中，错误信息
    @objc optional func onShowErrorInfo(_ error: AgoraEduContextError)
    
    @objc optional func onClassroomJoined()
}

@objc public protocol AgoraEduRoomContext: NSObjectProtocol {
    // 房间信息
    func getRoomInfo() -> AgoraEduContextRoomInfo
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
    // 收到聊天权限变化
    @objc optional func onUpdateChatPermission(_ allow: Bool)
    @objc optional func onUpdateLocalChatPermission(_ allow: Bool,
                                                    toUser: AgoraEduContextUserInfo,
                                                    operatorUser: AgoraEduContextUserInfo)
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
    
    /* 显示聊天过程中提示信息
     * 禁言模式开启
     * 禁言模式关闭
     */
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
    @objc optional func onUpdateAudioVolumeIndication(_ value: Int, streamUuid: String)
    /* 显示提示信息
     * 你的摄像头被关闭了
     * 你的麦克风被关闭了
     * 你的摄像头被打开了
     * 你的麦克风被打开了
     */
    @objc optional func onShowUserTips(_ message: String)
    // 收到奖励（自己或者其他学生）
    @objc optional func onShowUserReward(_ user: AgoraEduContextUserInfo)
}

@objc public protocol AgoraEduUserContext: NSObjectProtocol {
    // 获取本地用户信息
    func getLocalUserInfo() -> AgoraEduContextUserInfo
    
    // mute本地视频
    func muteVideo(_ mute: Bool)
    // mute本地音频
    func muteAudio(_ mute: Bool)
    // 渲染或者关闭渲染流，view为nil代表关闭流渲染
    func renderView(_ view: UIView?, streamUuid: String)
    // 事件监听
    func registerEventHandler(_ handler: AgoraEduUserHandler)
}

// MARK: - HandsUp
@objc public protocol AgoraEduHandsUpHandler: NSObjectProtocol {
    // 是否可以举手
    @objc optional func onSetHandsUpEnable(_ enable: Bool)
    // 当前举手状态
    @objc optional func onSetHandsUpState(_ state: AgoraEduContextHandsUpState)
    // 更新举手状态结果，如果error不为空，代表失败
    @objc optional func onUpdateHandsUpStateResult(_ error: AgoraEduContextError?)
    /* 显示举手相关消息
     * 举手超时
     * 老师拒绝了你的举手申请x
     * 老师同意了你的举手申请
     * 你被老师下台了
     * 举手成功
     * 取消举手成功
     * 老师关闭了举手功能
     * 老师开启了举手功能
     */
    @objc optional func onShowHandsUpTips(_ message: String)
}

@objc public protocol AgoraEduHandsUpContext: NSObjectProtocol {
    // 更新举手状态
    func updateHandsUpState(_ state: AgoraEduContextHandsUpState)
    // 事件监听
    func registerEventHandler(_ handler: AgoraEduHandsUpHandler)
}

// MARK: - ScreenShare
@objc public protocol AgoraEduScreenShareHandler: NSObjectProtocol {
    // 开启或者关闭屏幕分享
    @objc optional func onUpdateScreenShareState(_ state: AgoraEduContextScreenShareState,
                                               streamUuid: String)

    // 切换屏幕课件Tab
    @objc optional func onSelectScreenShare(_ selected: Bool)
    
    /* 屏幕分享相关消息
     * XXX开启了屏幕分享
     * XXX关闭了屏幕分享
     */
    @objc optional func onShowScreenShareTips(_ message: String)
}

@objc public protocol AgoraEduScreenShareContext: NSObjectProtocol {
    // 事件监听
    func registerEventHandler(_ handler: AgoraEduScreenShareHandler)
}

// MARK: - Device
@objc public protocol AgoraEduDeviceHandler: NSObjectProtocol {
    @objc optional func onCameraDeviceEnableChanged(enabled: Bool)
    @objc optional func onCameraFacingChanged(facing: EduContextCameraFacing)
    @objc optional func onMicDeviceEnabledChanged(enabled: Bool)
    @objc optional func onSpeakerEnabledChanged(enabled: Bool)
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

@objc public protocol AgoraEduWidgetContext: AgoraWidgetProtocol {
    func createWidget(info: AgoraWidgetInfo,
                      contextPool: AgoraEduContextPool) -> AgoraEduWidget
    func getWidgetInfos() -> [AgoraWidgetInfo]?
    func getAgoraWidgetProperties(type: EduContextWidgetType) -> [String: Any]?
}
