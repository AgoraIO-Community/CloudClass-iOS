//
//  AgoraUIManager.swift
//  AgoraEduUI
//
//  Created by Cavan on 2021/11/18.
//

import AgoraEduContext
import AgoraWidget
import UIKit

public protocol AgoraEduUIManagerDelegate: NSObjectProtocol {
    func manager(manager: AgoraEduUIManager,
                 didExited reason: AgoraEduUIExitReason)
}

public class AgoraEduUIManager: UIViewController {
    weak var delegate: AgoraEduUIManagerDelegate?
    var contextPool: AgoraEduContextPool!
    
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
        self.delegate?.manager(manager: self,
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
