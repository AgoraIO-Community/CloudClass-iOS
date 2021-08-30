//
//  AgoraUIEventDispatcher.swift
//  AgoraUIEduAppViews
//
//  Created by Cavan on 2021/4/17.
//

import UIKit
import WebKit
import AgoraEduContext

/// For OC
@objc public enum AgoraUIEventType : Int {
    case whiteBoard
    case whiteBoardPageControl
    case privateChat
    case room
    case message
    case user
    case handsup
    case shareScreen
    case device
}

public enum AgoraUIEvent {
    case whiteBoard(object: AgoraEduWhiteBoardHandler)
    case whiteBoardPageControl(object: AgoraEduWhiteBoardPageControlHandler)
    case privateChat(object: AgoraEduPrivateChatHandler)
    case room(object: AgoraEduRoomHandler)
    case message(object: AgoraEduMessageHandler)
    case user(object: AgoraEduUserHandler)
    case handsup(object: AgoraEduHandsUpHandler)
    case shareScreen(object: AgoraEduScreenShareHandler)
    case device(object: AgoraEduDeviceHandler)

    static let WhiteBoardId = "WhiteBoardId"
    static let WhiteBoardPageControlId = "WhiteBoardPageControlId"
    static let PrivateChatId = "PrivateChatId"
    static let RoomId = "RoomId"
    static let MessageId = "MessageId"
    static let UserId = "UserId"
    static let HandsupId = "HandsupId"
    static let ShareScreenId = "ShareScreenId"
    static let DeviceId = "DeviceId"

    var id: String {
        switch self {
        case .whiteBoard:               return AgoraUIEvent.WhiteBoardId
        case .whiteBoardPageControl:    return AgoraUIEvent.WhiteBoardPageControlId
        case .privateChat:              return AgoraUIEvent.PrivateChatId
        case .room:                     return AgoraUIEvent.RoomId
        case .message:                  return AgoraUIEvent.MessageId
        case .user:                     return AgoraUIEvent.UserId
        case .handsup:                  return AgoraUIEvent.HandsupId
        case .shareScreen:              return AgoraUIEvent.ShareScreenId
        case .device:                   return AgoraUIEvent.DeviceId
        }
    }
}

@objcMembers public class AgoraUIEventDispatcher: NSObject {
    var observerGroup = [String: NSPointerArray]() // UIEvent description

    public func register(object: NSObjectProtocol, eventType: AgoraUIEventType) {
        
        var event: AgoraUIEvent?
        
        if let `object` = object as? AgoraEduWhiteBoardHandler {
            event = .whiteBoard(object: object)
            self.register(event: event!)
        }
        if let `object` = object as? AgoraEduWhiteBoardPageControlHandler {
            event = .whiteBoardPageControl(object: object)
            self.register(event: event!)
        }
        if let `object` = object as? AgoraEduPrivateChatHandler {
            event = .privateChat(object: object)
            self.register(event: event!)
        }
        if let `object` = object as? AgoraEduRoomHandler {
            event = .room(object: object)
            self.register(event: event!)
        }
        if let `object` = object as? AgoraEduMessageHandler {
            event = .message(object: object)
            self.register(event: event!)
        }
        if let `object` = object as? AgoraEduUserHandler {
            event = .user(object: object)
            self.register(event: event!)
        }
        if let `object` = object as? AgoraEduHandsUpHandler {
            event = .handsup(object: object)
            self.register(event: event!)
        }
        if let `object` = object as? AgoraEduScreenShareHandler {
            event = .shareScreen(object: object)
            self.register(event: event!)
        }
        if let `object` = object as? AgoraEduDeviceHandler {
            event = .device(object: object)
            self.register(event: event!)
        }
    }
    
    public func register(event: AgoraUIEvent) {
   
        var observers: NSPointerArray

        if let array = observerGroup[event.id] {
            observers = array
        } else {
            observers = NSPointerArray.weakObjects()
            observerGroup[event.id] = observers
        }

        let size = MemoryLayout<NSObject>.size

        var tObject: NSObjectProtocol

        switch event {
        case .whiteBoard(let object):            tObject = object
        case .whiteBoardPageControl(let object): tObject = object
        case .privateChat(let object):           tObject = object
        case .room(let object):                  tObject = object
        case .message(let object):               tObject = object
        case .user(let object):                  tObject = object
        case .handsup(let object):               tObject = object
        case .shareScreen(let object):           tObject = object
        case .device(let object):                tObject = object
        }

        let pointer = Unmanaged.passUnretained(tObject).toOpaque()
        if !observers.contains(pointer) {
            observers.addPointer(pointer)
        }
    }

    func observerse(eventId: String) -> NSPointerArray? {
        return observerGroup[eventId]
    }
}

extension AgoraUIEventDispatcher {
    // 获取白板容器View, 真正的白板会放在这个容器里面
    @objc public func onGetBoardContainer(_ webview: WKWebView) -> UIView? {
        guard let observers = observerse(eventId: AgoraUIEvent.WhiteBoardId) else {
            return nil
        }

        return observers.object(at: 0, type: AgoraEduWhiteBoardHandler.self)?.onGetBoardContainer?(webview)
    }

    // 设置是否可以画
    @objc public func onSetDrawingEnabled(_ enabled: Bool) {
        guard let observers = observerse(eventId: AgoraUIEvent.WhiteBoardId) else {
            return
        }

        observers.traverse(type: AgoraEduWhiteBoardHandler.self) { (object) in
            object.onSetDrawingEnabled?(enabled)
        }
    }

    // 白板加载状态
    @objc public func onSetLoadingVisible(_ visible: Bool) {
        guard let observers = observerse(eventId: AgoraUIEvent.WhiteBoardId) else {
            return
        }

        observers.traverse(type: AgoraEduWhiteBoardHandler.self) { (object) in
            object.onSetLoadingVisible?(visible)
        }
    }

    // 课件下载进度，url是课件地址，progress:0-100
    @objc public func onSetDownloadProgress(_ url: String,
                                   progress: Float) {
        guard let observers = observerse(eventId: AgoraUIEvent.WhiteBoardId) else {
            return
        }

        observers.traverse(type: AgoraEduWhiteBoardHandler.self) { (object) in
            object.onSetDownloadProgress?(url,
                                        progress: progress)
        }
    }

    // 课件下载时间过长，一次课件下载超过了15秒，会有该调用
    @objc public func onSetDownloadTimeOut(_ url: String) {
        guard let observers = observerse(eventId: AgoraUIEvent.WhiteBoardId) else {
            return
        }

        observers.traverse(type: AgoraEduWhiteBoardHandler.self) { (object) in
            object.onSetDownloadTimeOut?(url)
        }
    }

    // 课件下载完成
    @objc public func onSetDownloadComplete(_ url: String) {
        guard let observers = observerse(eventId: AgoraUIEvent.WhiteBoardId) else {
            return
        }

        observers.traverse(type: AgoraEduWhiteBoardHandler.self) { (object) in
            object.onSetDownloadComplete?(url)
        }
    }

    // 课件下载失败
    @objc public func onDownloadError(_ url: String) {
        guard let observers = observerse(eventId: AgoraUIEvent.WhiteBoardId) else {
            return
        }

        observers.traverse(type: AgoraEduWhiteBoardHandler.self) { (object) in
            object.onDownloadError?(url)
        }
    }

    // 课件下载取消
    @objc public func onCancelCurDownload() {
        guard let observers = observerse(eventId: AgoraUIEvent.WhiteBoardId) else {
            return
        }

        observers.traverse(type: AgoraEduWhiteBoardHandler.self) { (object) in
            object.onCancelCurDownload?()
        }
    }

    // 显示白板权限信息
    @objc public func onShowPermissionTips(_ granted: Bool) {
        guard let observers = observerse(eventId: AgoraUIEvent.WhiteBoardId) else {
            return
        }

        observers.traverse(type: AgoraEduWhiteBoardHandler.self) { (object) in
            object.onShowPermissionTips?(granted)
        }
    }
    
    @objc public func onWhiteGlobalStateChanged(_ state: [String: Any]) {
        guard let observers = observerse(eventId: AgoraUIEvent.WhiteBoardId) else {
            return
        }

        observers.traverse(type: AgoraEduWhiteBoardHandler.self) { (object) in
            object.onWhiteGlobalStateChanged?(state)
        }
    }
}

extension AgoraUIEventDispatcher: AgoraEduWhiteBoardPageControlHandler {
    @objc public func onSetPageIndex(_ pageIndex: NSInteger,
                            pageCount: NSInteger) {
        guard let observers = observerse(eventId: AgoraUIEvent.WhiteBoardPageControlId) else {
            return
        }

        observers.traverse(type: AgoraEduWhiteBoardPageControlHandler.self) { (object) in
            object.onSetPageIndex?(pageIndex, pageCount: pageCount)
        }
    }

    // 设置是否全屏，注意和onSetResizeFullScreenEnable的区别
    @objc public func onSetFullScreen(_ fullScreen: Bool) {
        guard let observers = observerse(eventId: AgoraUIEvent.WhiteBoardPageControlId) else {
            return
        }

        observers.traverse(type: AgoraEduWhiteBoardPageControlHandler.self) { (object) in
            object.onSetFullScreen?(fullScreen)
        }
    }

    // 是否可以翻页
    @objc public func onSetPagingEnable(_ enable: Bool) {
        guard let observers = observerse(eventId: AgoraUIEvent.WhiteBoardPageControlId) else {
            return
        }

        observers.traverse(type: AgoraEduWhiteBoardPageControlHandler.self) { (object) in
            object.onSetPagingEnable?(enable)
        }
    }

    // 是否可以放大、缩小
    @objc public func onSetZoomEnable(_ zoomOutEnable: Bool,
                                      zoomInEnable: Bool) {
        guard let observers = observerse(eventId: AgoraUIEvent.WhiteBoardPageControlId) else {
            return
        }

        observers.traverse(type: AgoraEduWhiteBoardPageControlHandler.self) { (object) in
            object.onSetZoomEnable?(zoomOutEnable,
                                  zoomInEnable: zoomInEnable)
        }
    }

    // 是否可以全屏，注意和onSetFullScreen的区别
    @objc public func onSetResizeFullScreenEnable(_ enable: Bool) {
        guard let observers = observerse(eventId: AgoraUIEvent.WhiteBoardPageControlId) else {
            return
        }

        observers.traverse(type: AgoraEduWhiteBoardPageControlHandler.self) { (object) in
            object.onSetResizeFullScreenEnable?(enable)
        }
    }
}

extension AgoraUIEventDispatcher: AgoraEduPrivateChatHandler {
    // 收到开始私密语音通知
    @objc public func onStartPrivateChat(_ info: AgoraEduContextPrivateChatInfo) {
        observerse(eventId: AgoraUIEvent.PrivateChatId)?.traverse(type: AgoraEduPrivateChatHandler.self) { (object) in
            object.onStartPrivateChat?(info)
        }
    }
    // 收到结束私密语音通知
    @objc public func onEndPrivateChat() {
        observerse(eventId: AgoraUIEvent.PrivateChatId)?.traverse(type: AgoraEduPrivateChatHandler.self) { (object) in
            object.onEndPrivateChat?()
        }
    }
}

extension AgoraUIEventDispatcher: AgoraEduRoomHandler {
    // 设置课程名称
    @objc public func onSetClassroomName(_ name: String) {
        observerse(eventId: AgoraUIEvent.RoomId)?.traverse(type: AgoraEduRoomHandler.self) { (object) in
            object.onSetClassroomName?(name)
        }
    }
    // 设置课程状态
    @objc public func onSetClassState(_ state: AgoraEduContextClassState) {
        observerse(eventId: AgoraUIEvent.RoomId)?.traverse(type: AgoraEduRoomHandler.self) { (object) in
            object.onSetClassState?(state)
        }
    }
    /* 显示课程时间:
     * 上课前：`距离上课还有：X分X秒`
     * 开始上课：`已开始上课:X分X秒`
     * 结束上课：`已开始上课:X分X秒`
     */
    @objc public func onSetClassTime(_ time: String) {
        observerse(eventId: AgoraUIEvent.RoomId)?.traverse(type: AgoraEduRoomHandler.self) { (object) in
            object.onSetClassTime?(time)
        }
    }
    /* 上课期间的提示
     * 课程还有5分钟结束
     * 课程结束咯，还有5分钟关闭教室
     * 距离教室关闭还有1分钟
     * 设置上课期间的提示
     */
    @objc public func onShowClassTips(_ message: String) {
        observerse(eventId: AgoraUIEvent.RoomId)?.traverse(type: AgoraEduRoomHandler.self) { (object) in
            object.onShowClassTips?(message)
        }
    }
    
    // 网络状态
    @objc public func onSetNetworkQuality(_ quality: AgoraEduContextNetworkQuality) {
        observerse(eventId: AgoraUIEvent.RoomId)?.traverse(type: AgoraEduRoomHandler.self) { (object) in
            object.onSetNetworkQuality?(quality)
        }
    }
    
    // 连接状态
    @objc public func onSetConnectionState(_ state: AgoraEduContextConnectionState) {
        observerse(eventId: AgoraUIEvent.RoomId)?.traverse(type: AgoraEduRoomHandler.self) { (object) in
            object.onSetConnectionState?(state)
        }
    }
    
    // 日志上传成功
    @objc public func onUploadLogSuccess(_ logId: String) {
        observerse(eventId: AgoraUIEvent.RoomId)?.traverse(type: AgoraEduRoomHandler.self) { (object) in
            object.onUploadLogSuccess?(logId)
        }
    }
    
    // 上课过程中，错误信息
    @objc public func onShowErrorInfo(_ error: AgoraEduContextError) {
        observerse(eventId: AgoraUIEvent.RoomId)?.traverse(type: AgoraEduRoomHandler.self) { (object) in
            object.onShowErrorInfo?(error)
        }
    }
    
    @objc public func onClassroomJoined() {
        observerse(eventId: AgoraUIEvent.RoomId)?.traverse(type: AgoraEduRoomHandler.self) { (object) in
            object.onClassroomJoined?()
        }
    }

    // 自定义房间属性更新
    @objc public func onFlexRoomPropertiesInitialize(_ properties: [String: Any]) {
        observerse(eventId: AgoraUIEvent.RoomId)?.traverse(type: AgoraEduRoomHandler.self) { (object) in
            object.onFlexRoomPropertiesInitialize?(properties)
        }
    }
    
    // 自定义房间属性更新
    @objc public func onFlexRoomPropertiesChanged(_ changedProperties: [String: Any],
                                                  properties: [String: Any],
                                                  cause: [String: Any]?,
                                                  operator:AgoraEduContextUserInfo?) {
        observerse(eventId: AgoraUIEvent.RoomId)?.traverse(type: AgoraEduRoomHandler.self) { (object) in
            object.onFlexRoomPropertiesChanged?(changedProperties,
                                                properties: properties,
                                                cause: cause,
                                                operator: `operator`)
        }
    }
}

extension AgoraUIEventDispatcher: AgoraEduMessageHandler {
    // 收到房间消息
    @objc public func onAddRoomMessage(_ info: AgoraEduContextChatInfo) {
        observerse(eventId: AgoraUIEvent.MessageId)?.traverse(type: AgoraEduMessageHandler.self) { (object) in
            object.onAddRoomMessage?(info)
        }
    }
    // 收到提问消息
    @objc public func onAddConversationMessage(_ info: AgoraEduContextChatInfo) {
        observerse(eventId: AgoraUIEvent.MessageId)?.traverse(type: AgoraEduMessageHandler.self) { (object) in
            object.onAddConversationMessage?(info)
        }
    }
    // 收到聊天权限变化
    @objc public func onUpdateChatPermission(_ allow: Bool) {
        observerse(eventId: AgoraUIEvent.MessageId)?.traverse(type: AgoraEduMessageHandler.self) { (object) in
            object.onUpdateChatPermission?(allow)
        }
    }
    
    @objc public func onUpdateLocalChatPermission(_ allow: Bool,
                                                  toUser:AgoraEduContextUserInfo,
                                                  operatorUser:AgoraEduContextUserInfo) {
        observerse(eventId: AgoraUIEvent.MessageId)?.traverse(type: AgoraEduMessageHandler.self) { (object) in
            object.onUpdateLocalChatPermission?(allow,
                                                toUser:toUser,
                                                operatorUser: operatorUser)
        }
    }
    
    @objc public func onUpdateRemoteChatPermission(_ allow: Bool,
                                                   toUser:AgoraEduContextUserInfo,
                                                   operatorUser:AgoraEduContextUserInfo) {
        observerse(eventId: AgoraUIEvent.MessageId)?.traverse(type: AgoraEduMessageHandler.self) { (object) in
            object.onUpdateRemoteChatPermission?(allow,
                                                 toUser:toUser,
                                                 operatorUser: operatorUser)
        }
    }
    
    // 本地发送消息结果（包含首次和后面重发），如果error不为空，代表失败
    @objc public func onSendRoomMessageResult(_ error: AgoraEduContextError?,
                                              info: AgoraEduContextChatInfo?) {
        observerse(eventId: AgoraUIEvent.MessageId)?.traverse(type: AgoraEduMessageHandler.self) { (object) in
            object.onSendRoomMessageResult?(error,
                                            info: info)
        }
    }
    @objc public func onSendConversationMessageResult(_ error: AgoraEduContextError?,
                                                        info: AgoraEduContextChatInfo?) {
        observerse(eventId: AgoraUIEvent.MessageId)?.traverse(type: AgoraEduMessageHandler.self) { (object) in
            object.onSendConversationMessageResult?(error,
                                                    info: info)
        }
    }
    
    // 查询历史消息结果，如果error不为空，代表失败
    @objc public func onFetchHistoryMessagesResult(_ error: AgoraEduContextError?,
                                                   list: [AgoraEduContextChatInfo]?) {
        observerse(eventId: AgoraUIEvent.MessageId)?.traverse(type: AgoraEduMessageHandler.self) { (object) in
            object.onFetchHistoryMessagesResult?(error,
                                                 list: list)
        }
    }

    @objc public func onFetchConversationHistoryMessagesResult(_ error: AgoraEduContextError?,
                                                               list: [AgoraEduContextChatInfo]?) {
        observerse(eventId: AgoraUIEvent.MessageId)?.traverse(type: AgoraEduMessageHandler.self) { (object) in
            object.onFetchConversationHistoryMessagesResult?(error,
                                                             list: list)
        }
    }
    
    /* 显示聊天过程中提示信息
     * 禁言模式开启
     * 禁言模式关闭
     */
    @objc public func onShowChatTips(_ message: String) {
        observerse(eventId: AgoraUIEvent.MessageId)?.traverse(type: AgoraEduMessageHandler.self) { (object) in
            object.onShowChatTips?(message)
        }
    }
}

extension AgoraUIEventDispatcher: AgoraEduUserHandler {
    // 更新人员信息列表，只显示在线人员信息
    @objc public func onUpdateUserList(_ list: [AgoraEduContextUserDetailInfo]) {
        observerse(eventId: AgoraUIEvent.UserId)?.traverse(type: AgoraEduUserHandler.self) { (object) in
            object.onUpdateUserList?(list)
        }
    }
    // 更新人员信息列表，只显示台上人员信息。（台上会包含不在线的）
    @objc public func onUpdateCoHostList(_ list: [AgoraEduContextUserDetailInfo]) {
        observerse(eventId: AgoraUIEvent.UserId)?.traverse(type: AgoraEduUserHandler.self) { (object) in
            object.onUpdateCoHostList?(list)
        }
    }
    // 自己被踢出
    @objc public func onKickedOut() {
        observerse(eventId: AgoraUIEvent.UserId)?.traverse(type: AgoraEduUserHandler.self) { (object) in
            object.onKickedOut?()
        }
    }
    // 音量提示
    @objc public func onUpdateAudioVolumeIndication(_ value: Int,
                                                    streamUuid: String) {
        observerse(eventId: AgoraUIEvent.UserId)?.traverse(type: AgoraEduUserHandler.self) { (object) in
            object.onUpdateAudioVolumeIndication?(value, streamUuid: streamUuid)
        }
    }
    /* 显示提示信息
     * 你的摄像头被关闭了
     * 你的麦克风被关闭了
     * 你的摄像头被打开了
     * 你的麦克风被打开了
     */
    @objc public func onShowUserTips(_ message: String) {
        observerse(eventId: AgoraUIEvent.UserId)?.traverse(type: AgoraEduUserHandler.self) { (object) in
            object.onShowUserTips?(message)
        }
    }
    // 收到奖励（自己或者其他学生）
    @objc public func onShowUserReward(_ user: AgoraEduContextUserInfo) {
        observerse(eventId: AgoraUIEvent.UserId)?.traverse(type: AgoraEduUserHandler.self) { (object) in
            object.onShowUserReward?(user)
        }
    }
    // 自定义房间属性更新
    @objc public func onFlexUserPropertiesChanged(_ changedProperties: [String: Any],
                                                  properties: [String: Any],
                                                  cause: [String: Any]?,
                                                  fromUser:AgoraEduContextUserDetailInfo,
                                                  operator:AgoraEduContextUserInfo?) {
        observerse(eventId: AgoraUIEvent.RoomId)?.traverse(type: AgoraEduUserHandler.self) { (object) in
            object.onFlexUserPropertiesChanged?(changedProperties,
                                                properties: properties,
                                                cause: cause,
                                                fromUser: fromUser,
                                                operator: `operator`)
        }
    }
}

extension AgoraUIEventDispatcher: AgoraEduHandsUpHandler {
    // 是否可以举手
    @objc public func onSetHandsUpEnable(_ enable: Bool) {
        observerse(eventId: AgoraUIEvent.HandsupId)?.traverse(type: AgoraEduHandsUpHandler.self) { (object) in
            object.onSetHandsUpEnable?(enable)
        }
    }
    // 当前举手状态
    @objc public func onSetHandsUpState(_ state: AgoraEduContextHandsUpState) {
        observerse(eventId: AgoraUIEvent.HandsupId)?.traverse(type: AgoraEduHandsUpHandler.self) { (object) in
            object.onSetHandsUpState?(state)
        }
    }
    // 更新举手状态结果，如果error不为空，代表失败
    @objc public func onUpdateHandsUpStateResult(_ error: AgoraEduContextError?) {
        observerse(eventId: AgoraUIEvent.HandsupId)?.traverse(type: AgoraEduHandsUpHandler.self) { (object) in
            object.onUpdateHandsUpStateResult?(error)
        }
    }
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
    @objc public func onShowHandsUpTips(_ message: String) {
        observerse(eventId: AgoraUIEvent.HandsupId)?.traverse(type: AgoraEduHandsUpHandler.self) { (object) in
            object.onShowHandsUpTips?(message)
        }
    }
}

extension AgoraUIEventDispatcher: AgoraEduScreenShareHandler {
    // 开启或者关闭屏幕分享
    @objc public func onUpdateScreenShareState(_ state: AgoraEduContextScreenShareState, streamUuid: String) {
        observerse(eventId: AgoraUIEvent.ShareScreenId)?.traverse(type: AgoraEduScreenShareHandler.self) { (object) in
            object.onUpdateScreenShareState?(state, streamUuid: streamUuid)
        }
    }

    // 切换屏幕课件Tab
    @objc public func onSelectedScreenShareState(_ selected: Bool) {
        observerse(eventId: AgoraUIEvent.ShareScreenId)?.traverse(type: AgoraEduScreenShareHandler.self) { (object) in
            object.onSelectScreenShare?(selected)
        }
    }

    /* 屏幕分享相关消息
     * XXX开启了屏幕分享
     * XXX关闭了屏幕分享
     */
    @objc public func onShowScreenShareTips(_ message: String) {
        observerse(eventId: AgoraUIEvent.ShareScreenId)?.traverse(type: AgoraEduScreenShareHandler.self) { (object) in
            object.onShowScreenShareTips?(message)
        }
    }
}

extension AgoraUIEventDispatcher: AgoraEduDeviceHandler {
    @objc public func onCameraDeviceEnableChanged(enabled: Bool) {
        observerse(eventId: AgoraUIEvent.DeviceId)?.traverse(type: AgoraEduDeviceHandler.self) { (object) in
            object.onCameraDeviceEnableChanged?(enabled: enabled)
        }
    }
    @objc public func onCameraFacingChanged(facing: EduContextCameraFacing) {
        observerse(eventId: AgoraUIEvent.DeviceId)?.traverse(type: AgoraEduDeviceHandler.self) { (object) in
            object.onCameraFacingChanged?(facing: facing)
        }
    }
    @objc public func onMicDeviceEnabledChanged(enabled: Bool) {
        observerse(eventId: AgoraUIEvent.DeviceId)?.traverse(type: AgoraEduDeviceHandler.self) { (object) in
            object.onMicDeviceEnabledChanged?(enabled: enabled)
        }
    }
    @objc public func onSpeakerEnabledChanged(enabled: Bool) {
        observerse(eventId: AgoraUIEvent.DeviceId)?.traverse(type: AgoraEduDeviceHandler.self) { (object) in
            object.onSpeakerEnabledChanged?(enabled: enabled)
        }
    }
    @objc public func onDeviceTips(message: String) {
        observerse(eventId: AgoraUIEvent.DeviceId)?.traverse(type: AgoraEduDeviceHandler.self) { (object) in
            object.onDeviceTips?(message: message)
        }
    }
}

fileprivate extension NSPointerArray {
    func add(object: NSObject) {
        let pointer = Unmanaged.passUnretained(object).toOpaque()
        addPointer(pointer)
    }

    func contains(_ pointer: UnsafeMutableRawPointer) -> Bool {
        guard count > 0  else {
            return false
        }
        
        for index in 0...(count - 1) {
            let value = self.pointer(at: index)
            if pointer == value {
                return true
            }
        }
        
        return false
    }
    
    func object<T: Any>(at index: Int,
                        type: T.Type) -> T? {
        guard index < self.count,
              index >= 0,
              let pointer = pointer(at: index) else {
            return nil
        }

        let object = Unmanaged<NSObject>.fromOpaque(pointer).takeUnretainedValue()

        if let obj = object as? T {
            return obj
        } else {
            return nil
        }
    }

    func traverse<T>(type: T.Type,
                     perObject: (T) -> Void) {
        for index in 0...(count - 1) {
            guard let obj = object(at: index,
                                   type: type) else {
                continue
            }

            perObject(obj)
        }
    }
}
