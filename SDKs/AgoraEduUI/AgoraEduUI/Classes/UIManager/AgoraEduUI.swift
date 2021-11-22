//
//  AgoraEduUI.swift
//  AgoraEduUI
//
//  Created by SRS on 2021/3/13.
//

import AgoraUIEduBaseViews
import AgoraUIBaseViews
import AgoraEduContext
import AudioToolbox
import AgoraExtApp
import AgoraWidget

@objcMembers public class AgoraEduUI: NSObject {
    public private(set) var presentedUIManager: AgoraUIManager?
    
    public func launch(roomType: AgoraEduContextRoomType,
                       contextPool: AgoraEduContextPool,
                       region: String) -> AgoraUIManager {
        var manager: AgoraUIManager
        
        switch roomType {
        case .oneToOne:
            manager = AgoraOneToOneUIManager(contextPool: contextPool)
        case .small:
            manager = AgoraSmallUIManager(contextPool: contextPool)
        case .lecture:
            manager = AgoraLectureUIManager(contextPool: contextPool,
                                            region: region)
        case .paintingSmall:
            manager = AgoraPaintingUIManager(contextPool: contextPool)
        default:
            fatalError()
        }
        
        presentedUIManager = manager
        
        return manager
    }
    
    deinit {
        print("ui deinit")
    }
}

@objcMembers public class AgoraUIManager: UIViewController {
    var contextPool: AgoraEduContextPool!
    public override init(nibName nibNameOrNil: String?,
                         bundle nibBundleOrNil: Bundle?) {
        super.init(nibName: nibNameOrNil,
                   bundle: nibBundleOrNil)

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
    
    public func createChatWidget() -> AgoraBaseWidget? {
        guard let widgetInfos = contextPool.widget.getWidgetInfos() else {
            return nil
        }
        var agoraChatWidget: AgoraBaseWidget?
        if let chatInfo = widgetInfos.first(where: {$0.widgetId == "HyChatWidget"}) {
            agoraChatWidget = createHxChat(info: chatInfo)
        }else if let agoraChatInfo = widgetInfos.first(where: {$0.widgetId == "AgoraChatWidget"}) {
            agoraChatInfo.properties = ["contextPool": contextPool]
            let chatWidget = contextPool.widget.create(with: agoraChatInfo)
            agoraChatWidget = chatWidget
            
            let hasConversation = (contextPool.room.getRoomInfo().roomType == .oneToOne ? 0 : 1)
            if let message = ["hasConversation": hasConversation].jsonString() {
                chatWidget.widgetDidReceiveMessage(message)
            }
            
            let isMin = (contextPool.room.getRoomInfo().roomType == .lecture ? 0 : 1)
            if let message = ["isMinSize": isMin].jsonString() {
                chatWidget.widgetDidReceiveMessage(message)
            }
        }
        return agoraChatWidget
    }
    
    private func createHxChat(info: AgoraWidgetInfo) -> AgoraBaseWidget? {
        let userInfo = contextPool.user.getLocalUserInfo()
        let roomInfo = contextPool.room.getRoomInfo()

        var properties = [String: Any]()
        
        if let flexProps = contextPool.user.getFlexUserProperties(userUuid: userInfo.userUuid),
           let url = flexProps["avatarurl"] as? String {
            properties["avatarurl"] = url
        }
        
        properties["userName"] = userInfo.userName
        properties["userUuid"] = userInfo.userUuid
        properties["roomUuid"] = roomInfo.roomUuid
        properties["roomName"] = roomInfo.roomName
        properties["password"] = userInfo.userUuid
        
        if let imProperties = contextPool.widget.getAgoraWidgetProperties(type: .im),
           let hxProperties = imProperties["huanxin"] as? [String: Any],
           let appKey = hxProperties["appKey"] as? String,
           let chatRoomId = hxProperties["chatRoomId"] as? String {
            properties["appkey"] = appKey
            properties["chatRoomId"] = chatRoomId
        }
        
        info.properties = properties
        
        let chat = contextPool.widget.create(with: info)
        
        if contextPool.room.getRoomInfo().roomType != .oneToOne {
            chat.widgetDidReceiveMessage("min")
        }
        
        return chat
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
