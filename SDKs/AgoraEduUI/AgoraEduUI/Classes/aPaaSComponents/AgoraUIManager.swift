//
//  AgoraUIManager.swift
//  AgoraEduUI
//
//  Created by Cavan on 2021/11/18.
//

import AgoraEduContext
import AgoraWidget
import UIKit

@objc public enum AgoraEduUIExitReason: Int {
    case normal, kickOut
}

@objc public protocol AgoraEduUIManagerDelegate: NSObjectProtocol {
    func manager(_ manager: AgoraEduUIManager,
                 didExited reason: AgoraEduUIExitReason)
}

@objc public class AgoraEduUIManager: UIViewController {
    /** 容器视图，用来框出一块16：9的适配区域*/
    public var contentView: UIView!
    
    weak var delegate: AgoraEduUIManagerDelegate?
    
    var contextPool: AgoraEduContextPool!
    /// 弹窗控制器
    /** 控制器遮罩层，用来盛装控制器和处理手势触发消失事件*/
    private var ctrlMaskView: UIView!
    /** 弹出显示的控制widget视图*/
    public weak var ctrlView: UIView? {
        willSet {
            if let view = ctrlView {
                ctrlView?.removeFromSuperview()
                ctrlMaskView.isHidden = true
            }
            if let view = newValue {
                self.view.bringSubviewToFront(self.ctrlMaskView)
                ctrlMaskView.isHidden = false
                self.view.addSubview(view)
            }
        }
    }
    
    public override init(nibName nibNameOrNil: String?,
                         bundle nibBundleOrNil: Bundle?) {
        super.init(nibName: nibNameOrNil,
                   bundle: nibBundleOrNil)
    }
    
    public init(contextPool: AgoraEduContextPool,
                delegate: AgoraEduUIManagerDelegate) {
        super.init(nibName: nil,
                   bundle: nil)
        self.contextPool = contextPool
        self.delegate = delegate
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    public override func viewDidLoad() {
        super.viewDidLoad()
        self.view.backgroundColor = UIColor(hex: 0xF9F9FC)
        // create content view
        self.contentView = UIView()
        self.view.addSubview(self.contentView)
        let width = max(UIScreen.main.bounds.width, UIScreen.main.bounds.height)
        let height = min(UIScreen.main.bounds.width, UIScreen.main.bounds.height)
        if width/height > 667.0/375.0 {
            contentView.mas_makeConstraints { make in
                make?.center.equalTo()(contentView.superview)
                make?.height.equalTo()(height)
                make?.width.equalTo()(height * 16.0/9.0)
            }
        } else {
            contentView.mas_makeConstraints { make in
                make?.center.equalTo()(contentView.superview)
                make?.width.equalTo()(width)
                make?.height.equalTo()(width * 9.0/16.0)
            }
        }
        // create ctrl mask view
        ctrlMaskView = UIView(frame: .zero)
        ctrlMaskView.isHidden = true
        let tap = UITapGestureRecognizer(
            target: self, action: #selector(onClickCtrlMaskView(_:)))
        ctrlMaskView.addGestureRecognizer(tap)
        view.addSubview(ctrlMaskView)
        ctrlMaskView.mas_makeConstraints { make in
            make?.left.right().top().bottom().equalTo()(self.view)
        }
        
    }
    
    @objc private func onClickCtrlMaskView(_ sender: UITapGestureRecognizer) {
        ctrlView = nil
        didClickCtrlMaskView()
    }
    /** mask空白区域被点击时子类的处理*/
    public func didClickCtrlMaskView() {
        // for override
    }
    
    public override var shouldAutorotate: Bool {
        return true
    }
    
    public override var preferredInterfaceOrientationForPresentation: UIInterfaceOrientation {
        return .landscapeRight
    }
    
    public override var supportedInterfaceOrientations: UIInterfaceOrientationMask {
        return .landscapeRight
    }
    
    public func exit(reason: AgoraEduUIExitReason) {
        self.delegate?.manager(self,
                               didExited: reason)
    }
    
    public func createChatWidget() -> AgoraBaseWidget? {
        // easemobIM
        guard let chatConfig = contextPool.widget.getWidgetConfig("easemobIM") else {
            return nil
        }
        
        return createHxChat(config: chatConfig)
        
//        guard let widgetConfigs = contextPool.widget.getWidgetConfigs() else {
//            return nil
//        }
//        var agoraChatWidget: AgoraBaseWidget?
//        if let chatInfo = widgetConfigs.first(where: {$0.widgetId == "easemobIM"}) {

//            agoraChatWidget = createHxChat(info: chatInfo)
//        }else if let agoraChatInfo = widgetInfos.first(where: {$0.widgetId == "AgoraChatWidget"}) {
//            agoraChatInfo.properties = ["contextPool": contextPool]
//            let chatWidget = contextPool.widget.create(with: agoraChatInfo)
//            agoraChatWidget = chatWidget
//
//            let hasConversation = (contextPool.room.getRoomInfo().roomType == .oneToOne ? 0 : 1)
//            if let message = ["hasConversation": hasConversation].jsonString() {
//                chatWidget.onMessageReceived(message)
//            }
//
//            let isMin = (contextPool.room.getRoomInfo().roomType == .lecture ? 0 : 1)
//            if let message = ["isMinSize": isMin].jsonString() {
//                chatWidget.onMessageReceived(message)
//            }
//        }
//        return agoraChatWidget
    }
    
    private func createHxChat(config: AgoraWidgetConfig) -> AgoraBaseWidget? {
        let userInfo = contextPool.user.getLocalUserInfo()
        let roomInfo = contextPool.room.getRoomInfo()

        var properties = [String: Any]()
        
        if let flexProps = contextPool.user.getUserProperties(userUuid: userInfo.userUuid),
           let url = flexProps["avatarurl"] as? String {
            properties["avatarurl"] = url
        }
//
//        properties["userName"] = userInfo.userName
//        properties["userUuid"] = userInfo.userUuid
//        properties["roomUuid"] = roomInfo.roomUuid
//        properties["roomName"] = roomInfo.roomName
//        properties["password"] = userInfo.userUuid
        
        
        let widget = contextPool.widget.create(config)
        
        return widget
//
//        if let imProperties = contextPool.widget.getAgoraWidgetProperties(type: .im),
//           let hxProperties = imProperties["huanxin"] as? [String: Any],
//           let appKey = hxProperties["appKey"] as? String,
//           let chatRoomId = hxProperties["chatRoomId"] as? String {
//            properties["appkey"] = appKey
//            properties["chatRoomId"] = chatRoomId
//        }
//
//        info.properties = properties
//
//        let chat = contextPool.widget.create(with: info)
//
//        if contextPool.room.getRoomInfo().roomType != .oneToOne {
//            chat.onMessageReceived("min")
//        }
//
//        return chat
        return nil
    }
    
    func createWhiteboard(info: AgoraWidgetInfo) {
        
    }
}

extension Dictionary {
    func jsonString() -> String? {
        guard let data = try? JSONSerialization.data(withJSONObject: self,
                                                     options: .prettyPrinted) else {
            return nil
        }

        guard let jsonString = String(data: data,
                                      encoding: .utf8) else {
            return nil
        }
        return jsonString
    }
}

extension String {
    func json() -> [String: Any]? {
        guard let data = self.data(using: .utf8) else {
            return nil
        }

        return data.json()
    }
}

extension Data {
    func json() -> [String: Any]? {
        guard let object = try? JSONSerialization.jsonObject(with: self,
                                                             options: [.mutableContainers]) else {
            return nil
        }

        guard let dic = object as? [String: Any] else {
            return nil
        }

        return dic
    }
}
