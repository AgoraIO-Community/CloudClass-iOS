//
//  AgoraEduWidget.swift
//  AgoraEduContext
//
//  Created by Cavan on 2021/5/10.
//

import UIKit
import AgoraWidget

@objcMembers open class AgoraEduWidget: AgoraBaseWidget {
    public weak var contextPool: AgoraEduContextPool?
    
    required public init(widgetId: String,
                         contextPool: AgoraEduContextPool,
                         properties: [AnyHashable : Any]?) {
        self.contextPool = contextPool
        super.init(widgetId: widgetId,
                   properties: properties)
    }
}
