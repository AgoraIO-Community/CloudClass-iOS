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
class AgoraSpreadUIController: UIViewController {
    
    private let widgetId = "streamwindow"
    private var spreadWidget: AgoraBaseWidget?
    weak var delegate: AgoraSpreadUIControllerDelegate?
    
    private var spreadUserId: String?
    /** SDK环境*/
    var contextPool: AgoraEduContextPool!
    
    deinit {
        print("\(#function): \(self.classForCoder)")
    }
    
    init(context: AgoraEduContextPool) {
        super.init(nibName: nil, bundle: nil)
        contextPool = context
        createWidget()
        contextPool.widget.add(self,
                               widgetId: widgetId)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
        
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.view.isHidden = true
        self.view.backgroundColor = .orange
        
        widgetConstraint()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        // add event handler
        contextPool.user.registerUserEventHandler(self)
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        // remove event handler
        contextPool.user.unregisterUserEventHandler(self)
    }
}
// MARK: - Private
private extension AgoraSpreadUIController {
    
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
        self.view.isHidden = false
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
// MARK: - AgoraWidgetMessageObserver
extension AgoraSpreadUIController: AgoraWidgetMessageObserver {
    func onMessageReceived(_ message: String,
                           widgetId: String) {
        guard self.widgetId == widgetId else {
            return
        }
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
// MARK: - Creations
private extension AgoraSpreadUIController {
    func createWidget() {
        if let spreadConfig = contextPool.widget.getWidgetConfig(widgetId) {
            let spreadWidget = contextPool.widget.create(spreadConfig)
            contextPool.widget.add(self,
                                   widgetId: widgetId)

            self.spreadWidget = spreadWidget

        }
    }
    
    func widgetConstraint() {
        guard let widget = spreadWidget else {
            return
        }
        view.addSubview(widget.view)
        widget.view.mas_makeConstraints { make in
            make?.left.right().top().bottom().equalTo()(0)
        }
    }
}
