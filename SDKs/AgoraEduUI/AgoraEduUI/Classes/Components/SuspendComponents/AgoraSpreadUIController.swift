//
//  AgoraSpreadUIController.swift
//  AgoraEduUI
//
//  Created by Jonathan on 2022/1/7.
//

import AgoraEduContext
import AgoraWidget
import UIKit

fileprivate enum AgoraSpreadAction: Int {
    case start = 0, move = 1, change = 2, close = 3
}

protocol AgoraSpreadUIControllerDelegate: NSObjectProtocol {
    /** 开始展开大窗*/
    func startSpreadForUser(with userId: String) -> UIView?
    /** 将要结束展开大窗，拿到目标的视图*/
    func willStopSpreadForUser(with userId: String) -> UIView?
    /** 已经结束展开大窗，目标可以重新渲染*/
    func didStopSpreadForUser(with userId: String)
}

fileprivate class AgoraWidgetContentView: UIView  {
    override func hitTest(_ point: CGPoint,
                          with event: UIEvent?) -> UIView? {
        let view = super.hitTest(point,
                                 with: event)
        if view == self {
            return nil
        } else {
            return view
        }
    }
}

fileprivate class AgoraSpreadObject: NSObject {
    
    var widget: AgoraBaseWidget?
    
    var renderModel: AgoraRenderMemberModel?
    
    var renderView: AgoraRenderMemberView?
}

class AgoraSpreadUIController: UIViewController {
    weak var delegate: AgoraSpreadUIControllerDelegate?
    
    private var dataSource = [AgoraSpreadObject]()
    
    /** SDK环境*/
    var contextPool: AgoraEduContextPool!
    
    deinit {
        print("\(#function): \(self.classForCoder)")
    }
    
    init(context: AgoraEduContextPool) {
        super.init(nibName: nil, bundle: nil)
        
        contextPool = context
    }
    
    override func loadView() {
        view = AgoraWidgetContentView()
    }
        
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
        
    override func viewDidLoad() {
        super.viewDidLoad()
                        
        contextPool.widget.add(self)
        contextPool.stream.registerStreamEventHandler(self)
        contextPool.media.registerMediaEventHandler(self)
        contextPool.room.registerRoomEventHandler(self)
    }
}

// MARK: - Private
private extension AgoraSpreadUIController {
    func setup() {
        let allWidgetActivity = contextPool.widget.getAllWidgetActivity()
        
        guard allWidgetActivity.count > 0 else {
            return
        }
        
        for (widgetId, activityNumber) in allWidgetActivity {
            let active = activityNumber.boolValue
            
            guard widgetId.hasPrefix(kSpreadWidgetId),
                  active == true else {
                continue
            }
            
            self.onWidgetActive(widgetId)
        }
    }
    
    func updateStream(stream: AgoraEduContextStreamInfo?) {
        guard stream?.videoSourceType != .screen else {
            return
        }
        for obj in self.dataSource {
            if obj.renderModel?.uuid == stream?.owner.userUuid {
                obj.renderModel?.updateStream(stream)
            }
        }
    }
    
    func startSpreadUser(with widgetId: String,
                         userId: String,
                         to frame: CGRect) {
        guard let obj = dataSource.first(where: {$0.widget?.info.widgetId == widgetId}),
              let targetView = obj.widget?.view else {
            return
        }
        
        self.view.bringSubviewToFront(targetView)
        
        if let fromView = self.delegate?.startSpreadForUser(with: userId) {
            targetView.mas_remakeConstraints { make in
                make?.left.right().top().bottom().equalTo()(fromView)
            }
        } else {
            targetView.mas_remakeConstraints { make in
                make?.center.equalTo()(0)
                make?.width.equalTo()(200)
                make?.height.equalTo()(160)
            }
        }
        
        self.view.layoutIfNeeded()
        targetView.isHidden = false
        obj.renderModel = self.createRenderModel(with: userId)
        obj.renderView?.setModel(model: obj.renderModel,
                                 delegate: self)
        
        targetView.mas_remakeConstraints { make in
            make?.left.equalTo()(frame.minX)
            make?.top.equalTo()(frame.minY)
            make?.width.equalTo()(frame.width)
            make?.height.equalTo()(frame.height)
        }
        
        UIView.animate(withDuration: TimeInterval.agora_animation) {
            self.view.layoutIfNeeded()
        } completion: { finish in
            obj.renderModel?.rendEnable = true
        }
    }
    
    func moveSpread(with widgetId: String,
                    userId: String,
                    to frame: CGRect) {
        guard let obj = dataSource.first(where: {$0.widget?.info.widgetId == widgetId}),
              let targetView = obj.widget?.view else {
            return
        }
        self.view.bringSubviewToFront(targetView)
        self.view.layoutIfNeeded()
        
        targetView.mas_remakeConstraints { make in
            make?.left.equalTo()(frame.minX)
            make?.top.equalTo()(frame.minY)
            make?.width.equalTo()(frame.width)
            make?.height.equalTo()(frame.height)
        }
        
        UIView.animate(withDuration: TimeInterval.agora_animation) {
            self.view.layoutIfNeeded()
        }
    }
    
    func stopSpreadObj(with obj: AgoraSpreadObject) {
        guard let targetView = obj.widget?.view,
        let userId = obj.renderModel?.uuid else {
            return
        }
        obj.renderModel?.rendEnable = false
        self.view.layoutIfNeeded()
        if let view = self.delegate?.willStopSpreadForUser(with: userId) {
            targetView.mas_remakeConstraints { make in
                make?.left.right().top().bottom().equalTo()(view)
            }
        } else {
            targetView.mas_remakeConstraints { make in
                make?.center.equalTo()(0)
                make?.width.equalTo()(200)
                make?.height.equalTo()(160)
            }
        }
        
        UIView.animate(withDuration: TimeInterval.agora_animation) {
            self.view.layoutIfNeeded()
        } completion: { finish in
            self.delegate?.didStopSpreadForUser(with: userId)
            self.dataSource.removeAll(obj)
            obj.widget?.view.removeFromSuperview()
        }
    }
    
    func frameFromRect(_ rect: CGRect) -> CGRect {
        let width = self.view.width * rect.width
        let height = self.view.height * rect.height
        let MEDx = self.view.width - width
        let MEDy = self.view.height - height
        let x = MEDx * rect.minX
        let y = MEDy * rect.minY
        return CGRect(x: x,
                      y: y,
                      width: width,
                      height: height)
    }
    
    func createRenderModel(with userId: String) -> AgoraRenderMemberModel {
        guard let user = contextPool.user.getAllUserList().first(where: {$0.userUuid == userId}) else {
            return AgoraRenderMemberModel()
        }
        let model = AgoraRenderMemberModel.model(with: contextPool,
                                                 uuid: user.userUuid,
                                                 name: user.userName)
        model.rendEnable = false
        let stream = contextPool.stream.getStreamList(userUuid: userId)?.first
        model.updateStream(stream)
        return model
    }
}

// MARK: - AgoraWidgetActivityObserver
extension AgoraSpreadUIController: AgoraWidgetActivityObserver {
    public func onWidgetActive(_ widgetId: String) {
        if widgetId.hasPrefix(kSpreadWidgetId), // 条件创建大窗
           (self.dataSource.contains(where: {$0.widget?.info.widgetId == widgetId}) == false),
           var config = contextPool.widget.getWidgetConfig(widgetId) {
            config.widgetId = widgetId
            contextPool.widget.add(self,
                                   widgetId: widgetId)
            let spreadOBJ = AgoraSpreadObject()
            self.dataSource.append(spreadOBJ)
            let widget = contextPool.widget.create(config)
            spreadOBJ.widget = widget
            view.addSubview(widget.view)
            widget.view.isHidden = true
            
            let renderView = AgoraRenderMemberView(frame: .zero)
            widget.view.addSubview(renderView)
            spreadOBJ.renderView = renderView
            renderView.mas_makeConstraints { make in
                make?.left.right().top().bottom().equalTo()(0)
            }
        }
    }
    
    public func onWidgetInactive(_ widgetId: String) {
        guard self.dataSource.contains(where: {$0.widget?.info.widgetId == widgetId}) else {
            return
        }
        
        self.dataSource.removeAll { obj in
            if obj.widget?.info.widgetId == widgetId {
                contextPool.widget.remove(self,
                                          widgetId: widgetId)
                self.stopSpreadObj(with: obj)
                return true
            } else {
                return false
            }
        }
    }
}
// MARK: - AgoraWidgetMessageObserver
extension AgoraSpreadUIController: AgoraWidgetMessageObserver {
    func onMessageReceived(_ message: String,
                           widgetId: String) {
        guard let signal = message.toSpreadSignal() else {
            return
        }
        switch signal {
        case .start(let renderInfo):
            self.startSpreadUser(with: widgetId,
                                 userId: renderInfo.user.userId,
                                 to: self.frameFromRect(renderInfo.frame))
        case .changeFrame(let renderInfo):
            self.moveSpread(with: widgetId,
                            userId: renderInfo.user.userId,
                            to: self.frameFromRect(renderInfo.frame))
        default: return
        }
    }
}
// MARK: - AgoraRenderMemberViewDelegate
extension AgoraSpreadUIController: AgoraRenderMemberViewDelegate {
    func memberViewRender(memberView: AgoraRenderMemberView,
                          in view: UIView,
                          renderID: String) {
        let renderConfig = AgoraEduContextRenderConfig()
        renderConfig.mode = .hidden
        renderConfig.isMirror = true
        contextPool.stream.setRemoteVideoStreamSubscribeLevel(streamUuid: renderID,
                                                              level: .high)
        contextPool.media.startRenderVideo(view: view,
                                           renderConfig: renderConfig,
                                           streamUuid: renderID)
    }

    func memberViewCancelRender(memberView: AgoraRenderMemberView, renderID: String) {
        contextPool.media.stopRenderVideo(streamUuid: renderID)
    }
}
// - AgoraEduRoomHandler
extension AgoraSpreadUIController: AgoraEduRoomHandler {
    func onJoinRoomSuccess(roomInfo: AgoraEduContextRoomInfo) {
        // 平滑显示加一秒，加不加无所谓，没什么实际影响
        DispatchQueue.main.asyncAfter(deadline: .now() + 1) { [weak self] in
            self?.setup()
        }
    }
}
// MARK: - AgoraEduStreamHandler
extension AgoraSpreadUIController: AgoraEduStreamHandler {
    func onStreamJoined(stream: AgoraEduContextStreamInfo,
                        operatorUser: AgoraEduContextUserInfo?) {
        self.updateStream(stream: stream)
    }
    
    func onStreamUpdated(stream: AgoraEduContextStreamInfo,
                         operatorUser: AgoraEduContextUserInfo?) {
        self.updateStream(stream: stream)
    }
    
    func onStreamLeft(stream: AgoraEduContextStreamInfo,
                      operatorUser: AgoraEduContextUserInfo?) {
        let emptyStream = AgoraEduContextStreamInfo(streamUuid: stream.streamUuid,
                                                    streamName: stream.streamName,
                                                    streamType: .none,
                                                    videoSourceType: .none,
                                                    audioSourceType: .none,
                                                    videoSourceState: .error,
                                                    audioSourceState: .error,
                                                    owner: stream.owner)
        self.updateStream(stream: emptyStream)
    }
}
// MARK: - AgoraEduMediaHandler
extension AgoraSpreadUIController: AgoraEduMediaHandler {
    func onVolumeUpdated(volume: Int,
                         streamUuid: String) {
        for obj in self.dataSource {
            if obj.renderModel?.streamID == streamUuid {
                obj.renderModel?.volume = volume
            }
        }
    }
}
