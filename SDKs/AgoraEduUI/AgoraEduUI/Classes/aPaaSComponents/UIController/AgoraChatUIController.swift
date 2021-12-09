//
//  AgoraChatUIController.swift
//  AgoraEduUI
//
//  Created by Cavan on 2021/12/9.
//

import AgoraEduContext
import AgoraWidget
import Masonry
import UIKit

class AgoraChatUIController: UIViewController {
    private let chatWidgetId = "easemobIM"
    private var widget: AgoraBaseWidget?
    
    /** SDK环境*/
    var contextPool: AgoraEduContextPool!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        widget = createWidget()
    }
    
    public func createWidget() -> AgoraBaseWidget? {
        guard let chatConfig = contextPool.widget.getWidgetConfig(chatWidgetId) else {
            return nil
        }
        
        let widget = contextPool.widget.create(chatConfig)
        view.addSubview(widget.view)
        
        widget.view.mas_makeConstraints { make in
            make?.top.left().right().bottom().equalTo()(0)
        }
        
        let userInfo = contextPool.user.getLocalUserInfo()
        
        if let flexProps = contextPool.user.getUserProperties(userUuid: userInfo.userUuid),
           let url = flexProps["avatarurl"] as? String {
            let properties = ["avatarurl": url]
            if let message = properties.jsonString() {
                contextPool.widget.sendMessage(toWidget: message,
                                               widgetId: chatWidgetId)
            }
        }
        
        return widget
    }
}

//extension AgoraChatUIController: AgoraWidgetMessageObserver {
//    func onMessageReceived(_ message: String,
//                           widgetId: String!) {
//
//    }
//}
