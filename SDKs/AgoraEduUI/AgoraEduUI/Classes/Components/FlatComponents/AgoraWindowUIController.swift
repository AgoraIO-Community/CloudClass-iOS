//
//  AgoraSpreadUIController.swift
//  AgoraEduUI
//
//  Created by Jonathan on 2022/1/7.
//

import AgoraEduContext
import AgoraWidget
import UIKit

protocol AgoraWindowUIControllerDelegate: NSObjectProtocol {
    /** 开始展开大窗*/
    func startSpreadForUser(with userId: String) -> UIView?
    /** 将要结束展开大窗，拿到目标的视图*/
    func willStopSpreadForUser(with userId: String) -> UIView?
    /** 已经结束展开大窗，目标可以重新渲染*/
    func didStopSpreadForUser(with userId: String)
}

fileprivate class AgoraCameraWindowInfo: NSObject {
    var renderModel: AgoraRenderMemberModel
    var renderView: AgoraRenderMemberView
    
    init(renderModel: AgoraRenderMemberModel,
         renderView: AgoraRenderMemberView) {
        self.renderModel = renderModel
        self.renderView = renderView
    }
}

fileprivate class AgoraSharingWindowInfo: NSObject {
    var userUuid: String
    var streamUuid: String
    
    init(userUuid: String,
         streamUuid: String) {
        self.userUuid = userUuid
        self.streamUuid = streamUuid
    }
}

fileprivate enum AgoraStreamWindowType: Equatable {
    case video(AgoraCameraWindowInfo)
    case screen(AgoraSharingWindowInfo)
    
    static func == (lhs: Self,
                    rhs: Self) -> Bool {
        switch (lhs, rhs) {
        case (let .video(_), let .video(_)):   return true
        case (let .screen(_), let .screen(_)): return true
        default:                               return false
        }
    }
}

class AgoraWindowUIController: UIViewController {
    /** SDK环境*/
    private var contextPool: AgoraEduContextPool!
    private var subRoom: AgoraEduSubRoomContext?
    
    private var userController: AgoraEduUserContext {
        if let `subRoom` = subRoom {
            return subRoom.user
        } else {
            return contextPool.user
        }
    }
    
    private var streamController: AgoraEduStreamContext {
        if let `subRoom` = subRoom {
            return subRoom.stream
        } else {
            return contextPool.stream
        }
    }
    
    private var widgetController: AgoraEduWidgetContext {
        if let `subRoom` = subRoom {
            return subRoom.widget
        } else {
            return contextPool.widget
        }
    }
    
    private var roomId: String {
        if let `subRoom` = subRoom {
            return subRoom.getSubRoomInfo().subRoomUuid
        } else {
            return contextPool.room.getRoomInfo().roomUuid
        }
    }
    
    weak var delegate: AgoraWindowUIControllerDelegate?
    
    /**widgetId: AgoraBaseWidget **/
    private var widgetDic = [String: AgoraBaseWidget]() {
        didSet {
            self.view.isHidden = (widgetDic.count == 0)
        }
    }
    /**widgetId: AgoraStreamWindowType **/
    private var modelDic = [String: AgoraStreamWindowType]()
    
    init(context: AgoraEduContextPool,
         subRoom: AgoraEduSubRoomContext? = nil) {
        super.init(nibName: nil,
                   bundle: nil)
        self.contextPool = context
        self.subRoom = subRoom
    }
    
    override func loadView() {
        view = AgoraBaseUIContainer()
    }
        
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
        
    override func viewDidLoad() {
        super.viewDidLoad()
        if let `subRoom` = subRoom {
            subRoom.registerSubRoomEventHandler(self)
        } else {
            contextPool.room.registerRoomEventHandler(self)
        }
        
        contextPool.media.registerMediaEventHandler(self)
    }
    
    deinit {
        print("\(#function): \(self.classForCoder)")
    }
    
    func viewWillActive() {
        widgetController.add(self)
        streamController.registerStreamEventHandler(self)
        contextPool.group.registerGroupEventHandler(self)
        createAllActiveWidgets()
    }
    
    func viewWillInactive() {
        widgetController.remove(self)
        streamController.unregisterStreamEventHandler(self)
        contextPool.group.unregisterGroupEventHandler(self)
        releaseAllWidgets()
    }
}

// MARK: - AgoraEduRoomHandler
extension AgoraWindowUIController: AgoraEduRoomHandler {
    func onJoinRoomSuccess(roomInfo: AgoraEduContextRoomInfo) {
        viewWillActive()
    }
}

extension AgoraWindowUIController: AgoraEduSubRoomHandler {
    func onJoinSubRoomSuccess(roomInfo: AgoraEduContextRoomInfo) {
        viewWillActive()
    }
}

// MARK: - AgoraWidgetActivityObserver
extension AgoraWindowUIController: AgoraWidgetActivityObserver {
    public func onWidgetActive(_ widgetId: String) {
        createWidget(widgetId)
    }
    
    public func onWidgetInactive(_ widgetId: String) {
        releaseWidget(widgetId)
    }
}

// MARK: - AgoraEduGroupHandler
extension AgoraWindowUIController: AgoraEduGroupHandler {
    func onUserListAddedToSubRoom(userList: Array<String>,
                                  subRoomUuid: String,
                                  operatorUser: AgoraEduContextUserInfo?) {
        guard let teacherId = contextPool.user.getUserList(role: .teacher)?.first?.userUuid,
              userList.contains(teacherId) else {
            return
        }
        // 学生加入子房间会走coHost
        view.isHidden = true
    }
    
    func onGroupInfoUpdated(groupInfo: AgoraEduContextGroupInfo) {
        if !groupInfo.state,
           widgetDic.count > 0 {
               view.isHidden = false
           }
    }
}

// MARK: - AgoraWidgetSyncFrameObserver
extension AgoraWindowUIController: AgoraWidgetSyncFrameObserver {
    func onWidgetSyncFrameUpdated(_ syncFrame: CGRect,
                                  widgetId: String) {
        // TODO: 2.3.0暂不需移动，缩放和动画
//        guard let targetView = widgetDic[widgetId]?.view else {
//            return
//        }
//
//        let frame = syncFrame.displayFrameFromSyncFrame(superView: self.view)
//
//        self.view.bringSubviewToFront(targetView)
//        self.view.layoutIfNeeded()
//
//        targetView.mas_remakeConstraints { make in
//            make?.left.equalTo()(frame.minX)
//            make?.top.equalTo()(frame.minY)
//            make?.width.equalTo()(frame.width)
//            make?.height.equalTo()(frame.height)
//        }
//
//        UIView.animate(withDuration: TimeInterval.agora_animation) {
//            self.view.layoutIfNeeded()
//        }
    }
}

// MARK: - AgoraWidgetMessageObserver
extension AgoraWindowUIController: AgoraWidgetMessageObserver {
    func onMessageReceived(_ message: String,
                           widgetId: String) {
        guard let widget = widgetDic[widgetId],
              let signal = message.toWindowSignal(),
              !modelDic.keys.contains(widgetId) else {
                  return
              }
        
        switch signal {
        case .RenderInfo(let renderInfo):
            guard let stream = streamController.getStreamList(userUuid: renderInfo.userUuid)?.first(where: {$0.streamUuid == renderInfo.streamId}) else {
                return
            }
            switch stream.videoSourceType {
            case .camera:
                addCameraRenderInfo(stream: stream,
                                    renderInfo: renderInfo,
                                    widget: widget)
            case .screen:
                addScreenSharingInfo(stream: stream,
                                     renderInfo: renderInfo,
                                     widget: widget)
            default:
                break
            }
        }
    }
}
// MARK: - AgoraRenderMemberViewDelegate
extension AgoraWindowUIController: AgoraRenderMemberViewDelegate {
    func memberViewRender(memberView: AgoraRenderMemberView,
                          in view: UIView,
                          renderID: String) {
        startRenderOnWindow(view,
                            isCamera: true,
                            streamId: renderID)
    }

    func memberViewCancelRender(memberView: AgoraRenderMemberView,
                                renderID: String) {
        
    }
}


// MARK: - AgoraEduStreamHandler
extension AgoraWindowUIController: AgoraEduStreamHandler {
    func onStreamJoined(stream: AgoraEduContextStreamInfo,
                        operatorUser: AgoraEduContextUserInfo?) {
        self.updateStreamInfo(stream)
    }
    
    func onStreamUpdated(stream: AgoraEduContextStreamInfo,
                         operatorUser: AgoraEduContextUserInfo?) {
        self.updateStreamInfo(stream)
    }
    
    func onStreamLeft(stream: AgoraEduContextStreamInfo,
                      operatorUser: AgoraEduContextUserInfo?) {
        self.updateStreamInfo(stream.toEmptyStream())
    }
}

// MARK: - AgoraEduMediaHandler
extension AgoraWindowUIController: AgoraEduMediaHandler {
    func onVolumeUpdated(volume: Int,
                         streamUuid: String) {
        let widgetId = streamUuid.makeWidgetId()
        guard let type = modelDic[widgetId],
              case AgoraStreamWindowType.video(let renderInfo) = type else {
                  return
              }
        renderInfo.renderModel.volume = volume
    }
}

// MARK: - Widget create & relase
private extension AgoraWindowUIController {
    func createAllActiveWidgets() {
        let allWidgetActivity = widgetController.getAllWidgetActivity()
        
        guard allWidgetActivity.count > 0 else {
            return
        }
        
        for (widgetId, activityNumber) in allWidgetActivity {
            let active = activityNumber.boolValue
            
            guard widgetId.hasPrefix(kWindowWidgetId),
                  active == true else {
                continue
            }
            
            createWidget(widgetId)
        }
    }
    
    func releaseAllWidgets() {
        for widgetId in widgetDic.keys {
            releaseWidget(widgetId)
        }
    }
    
    func createWidget(_ widgetId: String) {
        guard widgetId.hasPrefix(kWindowWidgetId),
              !self.widgetDic.keys.contains(widgetId),
              let config = widgetController.getWidgetConfig(kWindowWidgetId),
              let streamId = widgetId.splitStreamId() else {
            return
        }
        
        config.widgetId = widgetId
        widgetController.add(self,
                             widgetId: widgetId)
        
        let widget = widgetController.create(config)
        self.widgetDic[widgetId] = widget
        
        view.addSubview(widget.view)
        
        // TODO: v2.3.0暂时铺满
//        let syncFrame = contextPool.widget.getWidgetSyncFrame(widget.info.widgetId)
//        let frame = syncFrame.displayFrameFromSyncFrame(superView: self.view)
        let frame = CGRect(x: 0,
                           y: 0,
                           width: self.view.width,
                           height: self.view.height)
        
        widget.view.mas_makeConstraints { make in
            make?.left.equalTo()(frame.minX)
            make?.top.equalTo()(frame.minY)
            make?.width.equalTo()(frame.width)
            make?.height.equalTo()(frame.height)
        }
    }
    
    func releaseWidget(_ widgetId: String) {
        guard let widget = widgetDic[widgetId],
              let streamId = widgetId.splitStreamId() else {
            return
        }
        
        // stop render
        var isCamera = false
        if let type = modelDic[widgetId],
           case AgoraStreamWindowType.video(let renderInfo) = type {
            isCamera = true
        }
        stopRenderOnWindow(streamId: streamId,
                           isCamera: isCamera)
        
        // TODO: 2.3.0暂时不需要动画，后期大窗需要stopSpreadObj(widgetId: widgetId)
        widget.view.removeFromSuperview()
        widgetDic.removeValue(forKey: widgetId)
        modelDic.removeValue(forKey: widgetId)
        
        widgetController.remove(self,
                                widgetId: widgetId)
        widgetController.removeObserver(forWidgetSyncFrame: self,
                                        widgetId: widgetId)
    }
}

// MARK: - Private
private extension AgoraWindowUIController {
    func addCameraRenderInfo(stream: AgoraEduContextStreamInfo,
                             renderInfo: AgoraStreamWindowWidgetRenderInfo,
                             widget: AgoraBaseWidget) {
        let renderModel = makeRenderModel(userId: renderInfo.userUuid,
                                          stream: stream)
        let renderView = AgoraRenderMemberView(frame: .zero)
        
        let spreadInfo = AgoraCameraWindowInfo(renderModel: renderModel,
                                               renderView: renderView)

        widget.view.addSubview(renderView)
        spreadInfo.renderView = renderView
        renderView.mas_makeConstraints { make in
            make?.left.right().top().bottom().equalTo()(0)
        }
        
        modelDic[widget.info.widgetId] = .video(spreadInfo)
        // 开启渲染视频窗大流
        renderView.setModel(model: renderModel,
                            delegate: self)
    }
    
    func addScreenSharingInfo(stream: AgoraEduContextStreamInfo,
                              renderInfo: AgoraStreamWindowWidgetRenderInfo,
                              widget: AgoraBaseWidget) {
        guard let targetView =  widgetDic[widget.info.widgetId]?.view else {
            return
        }
        let sharingInfo = AgoraSharingWindowInfo(userUuid: renderInfo.userUuid,
                                                 streamUuid: renderInfo.streamId)
        modelDic[widget.info.widgetId] = .screen(sharingInfo)
        // 开启渲染屏幕共享
        startRenderOnWindow(targetView,
                            isCamera: false,
                            streamId: renderInfo.streamId)
    }
    
    func updateStreamInfo(_ stream: AgoraEduContextStreamInfo) {
        let widgetId = stream.streamUuid.makeWidgetId()
        guard stream.videoSourceType != .screen,
        let type = modelDic[widgetId],
        case AgoraStreamWindowType.video(let renderInfo) = type else {
            return
        }
        renderInfo.renderModel.updateStream(stream)
    }
    
    func makeRenderModel(userId: String,
                         stream: AgoraEduContextStreamInfo) -> AgoraRenderMemberModel {
        guard let user = userController.getAllUserList().first(where: {$0.userUuid == userId}) else {
            return AgoraRenderMemberModel()
        }
        var model = AgoraRenderMemberModel()
        model.uuid = user.userUuid
        model.name = user.userName
        model.updateStream(stream)
        model.rendEnable = true
        return model
    }
    
    func getUidWithStreamId(_ streamId: String) -> String? {
        let widgetId = streamId.makeWidgetId()
        guard let type = modelDic[widgetId] else {
            return nil
        }
        
        var userId: String?
        switch type {
        case .video(let cameraInfo):
            userId = cameraInfo.renderModel.uuid
        case .screen(let screenInfo):
            userId = screenInfo.userUuid
        }
        return userId
    }
    
    func startRenderOnWindow(_ view: UIView,
                             isCamera: Bool,
                             streamId: String) {
        if let uid = getUidWithStreamId(streamId),
           isCamera {
            delegate?.startSpreadForUser(with: uid)
        }
        
        let renderConfig = AgoraEduContextRenderConfig()
        renderConfig.mode = isCamera ? .hidden : .fit
        renderConfig.isMirror = false
        streamController.setRemoteVideoStreamSubscribeLevel(streamUuid: streamId,
                                                            level: .high)
        
        contextPool.media.startRenderVideo(roomUuid: roomId,
                                           view: view,
                                           renderConfig: renderConfig,
                                           streamUuid: streamId)
    }
    
    func stopRenderOnWindow(streamId: String,
                            isCamera: Bool) {
        contextPool.media.stopRenderVideo(streamUuid: streamId)
        if let uid = getUidWithStreamId(streamId),
           isCamera {
            delegate?.didStopSpreadForUser(with: uid)
        }
    }
}

extension String {
    func splitStreamId() -> String? {
        let subStringArr = self.split(separator: "-")
        guard subStringArr.count == 2 else {
            return nil
        }
        return String(subStringArr[1])
    }
    
    func makeWidgetId() -> String {
        return "\(kWindowWidgetId)-\(self)"
    }
}
