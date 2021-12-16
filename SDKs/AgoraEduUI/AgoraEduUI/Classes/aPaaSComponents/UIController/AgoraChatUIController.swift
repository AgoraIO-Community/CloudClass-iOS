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
    private var contextPool: AgoraEduContextPool!
    
    public var hideTopBar = false
    
    public var hideMiniButton = false
    
    public var hideAnnouncement = false
    
    init(context: AgoraEduContextPool) {
        super.init(nibName: nil, bundle: nil)
        contextPool = context
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
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
           let url = flexProps["avatarurl"] as? String,
            let message = ["avatarurl": url].jsonString() {
                contextPool.widget.sendMessage(toWidget: chatWidgetId,
                                               message: message)
        }
        if hideTopBar {
            contextPool.widget.sendMessage(toWidget: chatWidgetId,
                                           message: "hideTopBar")
        }
        if hideMiniButton {
            contextPool.widget.sendMessage(toWidget: chatWidgetId,
                                           message: "hideMiniButton")
        }
        if hideAnnouncement {
            contextPool.widget.sendMessage(toWidget: chatWidgetId,
                                           message: "hideAnnouncement")
        }
        return widget
    }
}
