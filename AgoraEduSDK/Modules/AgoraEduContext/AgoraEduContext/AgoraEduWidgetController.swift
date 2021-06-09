//
//  AgoraEduWidgetController.swift
//  AgoraEduContext
//
//  Created by Cavan on 2021/5/9.
//

import AgoraWidget

public class AgoraEduWidgetController: AgoraWidgetController, AgoraEduWidgetContext {
    public func createWidget(info: AgoraWidgetInfo,
                             contextPool: AgoraEduContextPool) -> AgoraEduWidget {
        guard let classType = info.widgetClass as? AgoraEduWidget.Type else {
            fatalError()
        }
        
        let instance = classType.init(widgetId: info.widgetId,
                                      contextPool: contextPool,
                                      properties: info.properties)

        return instance
    }
}
