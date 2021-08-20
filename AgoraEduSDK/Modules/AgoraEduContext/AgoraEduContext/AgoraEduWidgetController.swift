//
//  AgoraEduWidgetController.swift
//  AgoraEduContext
//
//  Created by Cavan on 2021/5/9.
//

import AgoraWidget

public class AgoraEduWidgetController: AgoraWidgetController, AgoraEduWidgetContext {
    
    var roomProperties: [String: Any]?

    public func getAgoraWidgetProperties(type: EduContextWidgetType) -> [String : Any]? {
        guard let properties = roomProperties else {
            return nil
        }
        
        let widgetProperties = properties[type.roomPropertiesKey] as? [String: Any]
        return widgetProperties
    }
    
    @objc public func updateRoomProperties(_ properties: [String: Any]?) {
        self.roomProperties = properties
    }
    
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

fileprivate extension EduContextWidgetType {
    var roomPropertiesKey: String {
        switch self {
        case .im: return "im"
        }
    }
}
