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
    /** 获取父视图需要忽略计算的Rect大小*/
    func discaredSpreadRect() -> CGRect
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
    
    private var widgetIdPrefix = "streamwindow"
    
    private var spreadUserId: String?
    
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
        
        self.view.backgroundColor = UIColor.init(white: 0.5, alpha: 0.5)
        
        setupRenderModel()
        
        contextPool.widget.add(self)
        contextPool.user.registerUserEventHandler(self)
        contextPool.stream.registerStreamEventHandler(self)
        contextPool.media.registerMediaEventHandler(self)
    }
}
// MARK: - Private
private extension AgoraSpreadUIController {
    
    func setupRenderModel() {
        guard let userId = self.spreadUserId,
        let user = contextPool.user.getAllUserList().first(where: {$0.userUuid == userId}) else {
            return
        }
        let model = AgoraRenderMemberModel.model(with: contextPool,
                                                 uuid: user.userUuid,
                                                 name: user.userName)
//        self.renderModel = model
//        let stream = contextPool.stream.getStreamList(userUuid: userId)?.first
//        self.renderModel?.updateStream(stream)
//        self.renderView.setModel(model: renderModel,
//                                 delegate: self)
    }
    
    func updateStream(stream: AgoraEduContextStreamInfo?) {
        guard stream?.videoSourceType != .screen else {
            return
        }
        for obj in self.dataSource {
            if obj.renderModel?.streamID == stream?.streamUuid {
                obj.renderModel?.updateStream(stream)
            }
        }
    }
    
    func startSpreadUser(with userId: String,
                         to rect: CGRect?) {
        guard let superView = self.view.superview,
              let frame = rect else {
                  return
              }
        superView.bringSubviewToFront(self.view)
        if let view = self.delegate?.startSpreadForUser(with: userId) {
            self.view.mas_remakeConstraints { make in
                make?.left.right().top().bottom().equalTo()(view)
            }
        } else {
            self.view.mas_remakeConstraints { make in
                make?.center.equalTo()(0)
                make?.width.equalTo()(200)
                make?.height.equalTo()(160)
            }
        }
        superView.layoutIfNeeded()
        self.view.mas_remakeConstraints { make in
            make?.left.equalTo()(frame.minX)
            make?.top.equalTo()(frame.minY)
            make?.width.equalTo()(frame.width)
            make?.height.equalTo()(frame.height)
        }
        UIView.animate(withDuration: 0.2) {
            superView.layoutIfNeeded()
        }
    }
    
    func moveSpread(to rect: CGRect?) {
        guard let superView = self.view.superview,
              let frame = rect else {
                  return
              }
        superView.bringSubviewToFront(self.view)
        superView.layoutIfNeeded()
        self.view.mas_remakeConstraints { make in
            make?.left.equalTo()(frame.minX)
            make?.top.equalTo()(frame.minY)
            make?.width.equalTo()(frame.width)
            make?.height.equalTo()(frame.height)
        }
        UIView.animate(withDuration: 0.2) {
            superView.layoutIfNeeded()
        }
    }
    
    func stopSpreadUser() {
        guard let superView = self.view.superview,
              let userId = self.spreadUserId else {
                  return
              }
        superView.layoutIfNeeded()
        if let view = self.delegate?.willStopSpreadForUser(with: userId) {
            self.view.mas_remakeConstraints { make in
                make?.left.right().top().bottom().equalTo()(view)
            }
        } else {
            self.view.mas_remakeConstraints { make in
                make?.center.equalTo()(0)
                make?.width.equalTo()(200)
                make?.height.equalTo()(160)
            }
        }
        UIView.animate(withDuration: 0.2) {
            superView.layoutIfNeeded()
        } completion: { finish in
            self.delegate?.didStopSpreadForUser(with: userId)
            self.spreadUserId = nil
        }
    }
    
    func rectFromDict(_ dict: [String: Any]) -> CGRect? {
        guard let superView = self.view.superview,
              let x_rate = dict["xaxis"] as? CGFloat,
              let y_rate = dict["yaxis"] as? CGFloat,
              let width_rate = dict["width"] as? CGFloat,
              let height_rate = dict["height"] as? CGFloat else {
                  return nil
              }
        let discaredRect = delegate?.discaredSpreadRect() ?? .zero
        let width = superView.width * width_rate
        let height = (superView.height - discaredRect.height) * height_rate
        let MEDx = superView.width - width
        let MEDy = (superView.height - discaredRect.height) - height
        let x = MEDx * x_rate
        let y = MEDy * y_rate
        return CGRect(x: x, y: y, width: width, height: height)
    }
}
// MARK: - AgoraWidgetActivityObserver
extension AgoraSpreadUIController: AgoraWidgetActivityObserver {
    public func onWidgetActive(_ widgetId: String) {
        if widgetId.hasPrefix("streamwindow"), // 条件创建大窗
           let config = contextPool.widget.getWidgetConfig(widgetId) {
            contextPool.widget.add(self,
                                   widgetId: widgetId)
            let spreadOBJ = AgoraSpreadObject()
            self.dataSource.append(spreadOBJ)
            let widget = contextPool.widget.create(config)
            spreadOBJ.widget = widget
            view.addSubview(widget.view)
            
            let renderView = AgoraRenderMemberView(frame: .zero)
            widget.view.addSubview(renderView)
            spreadOBJ.renderView = renderView
            renderView.mas_makeConstraints { make in
                make?.left.right().top().bottom().equalTo()(0)
            }
        }
    }
    
    public func onWidgetInactive(_ widgetId: String) {
        self.dataSource.removeAll { obj in
            if obj.widget?.info.widgetId == widgetId {
                obj.widget?.view.removeFromSuperview()
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
//        guard self.widgetId == widgetId else {
//            return
//        }
        guard let messageDic = message.json(),
              let action = messageDic["widgetAction"] as? Int,
              let streamId = messageDic["spreadStreamId"] as? String,
              let userId = messageDic["operatedUuid"] as? String else {
                  return
              }
        let widgetAction = AgoraSpreadAction.init(rawValue: action)
        switch widgetAction {
        case .start:
            let rect = self.rectFromDict(messageDic)
            self.startSpreadUser(with: userId,
                                 to: rect)
        case .move:
            let rect = self.rectFromDict(messageDic)
            self.moveSpread(to: rect)
        case .change:
            // Do Noting
            return
        case .close:
            self.stopSpreadUser()
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
// MARK: - AgoraEduUserHandler
extension AgoraSpreadUIController: AgoraEduUserHandler {
    func onCoHostUserListRemoved(userList: [AgoraEduContextUserInfo],
                                 operatorUser: AgoraEduContextUserInfo?) {
        for user in userList {
            if user.userUuid == self.spreadUserId {
                self.stopSpreadUser()
                break
            }
        }
    }
    
    func onRemoteUserLeft(user: AgoraEduContextUserInfo,
                          operatorUser: AgoraEduContextUserInfo?,
                          reason: AgoraEduContextUserLeaveReason) {
        if user.userUuid == self.spreadUserId {
            self.stopSpreadUser()
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
