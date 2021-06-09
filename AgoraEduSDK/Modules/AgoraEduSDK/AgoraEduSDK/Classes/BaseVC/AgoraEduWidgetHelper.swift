//
//  AgoraEduWidgetHelper.swift
//  AgoraEduSDK
//
//  Created by Cavan on 2021/5/15.
//

import UIKit
import AgoraWidget
import AgoraEduContext
import AgoraUIEduAppViews

public class AgoraEduWidgetHelper: NSObject {
    @objc public func registerWidgets(_ controller: AgoraEduWidgetController) {
        let chat = AgoraWidgetConfiguration(with: AgoraChatWidget.self,
                                            widgetId: "AgoraChatWidget")
        controller.registerWidgets([chat])
    }
}
