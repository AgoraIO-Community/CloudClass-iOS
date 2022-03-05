//
//  AgoraPollerUIController.swift
//  AgoraWidgets
//
//  Created by LYY on 2022/3/2.
//

import AgoraEduContext
import AgoraWidget
import UIKit

class AgoraPollerUIController: UIViewController {
    private var pollerWidget: AgoraBaseWidget?
    private var contextPool: AgoraEduContextPool!
    
    init(context: AgoraEduContextPool) {
        super.init(nibName: nil,
                   bundle: nil)
        
        contextPool = context
        
        contextPool.room.registerRoomEventHandler(self)
        contextPool.widget.add(self)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

// MARK: - AgoraEduRoomHandler
extension AgoraPollerUIController: AgoraEduRoomHandler {
    func onJoinRoomSuccess(roomInfo: AgoraEduContextRoomInfo) {
        setup()
    }
}

// MARK: - AgoraWidgetActivityObserver
extension AgoraPollerUIController: AgoraWidgetActivityObserver {
    func onWidgetActive(_ widgetId: String) {
        guard widgetId == kPollerWidgetId,
              let pollerConfig = contextPool.widget.getWidgetConfig(widgetId) else {
                  return
              }
        let pollerWidget = contextPool.widget.create(pollerConfig)
        contextPool.widget.add(self,
                               widgetId: pollerConfig.widgetId)
        view.isUserInteractionEnabled = true
        view.addSubview(pollerWidget.view)
        self.pollerWidget = pollerWidget
        
        pollerWidget.view.mas_makeConstraints { make in
            make?.left.right().top().bottom().equalTo()(0)
        }
    }
    
    func onWidgetInactive(_ widgetId: String) {
        guard widgetId == kPollerWidgetId else {
            return
        }
        self.pollerWidget?.view.removeFromSuperview()
        self.pollerWidget = nil
        contextPool.widget.remove(self,
                                  widgetId: kPollerWidgetId)
    }
}

// MARK: - AgoraWidgetMessageObserver
extension AgoraPollerUIController: AgoraWidgetMessageObserver {
    func onMessageReceived(_ message: String,
                           widgetId: String) {
        guard widgetId == kPollerWidgetId,
              let signal = message.toPollerSignal() else {
                  return
              }
        switch signal {
        case .frameChange(let rect):
            let frame = frameFromRect(rect)
            guard let targetView = pollerWidget?.view else {
                return
            }
            self.view.bringSubviewToFront(targetView)
            self.view.layoutIfNeeded()
            
            targetView.mas_remakeConstraints { make in
                make?.left.equalTo()(frame.minX)
                make?.top.equalTo()(frame.minY)
                make?.width.equalTo()(frame.width)
                make?.height.equalTo()(frame.height)
            }
            
            UIView.animate(withDuration: TimeInterval.agora_animation) {
                self.view.layoutIfNeeded()
            }
        }
    }
}

// MARK: - private
private extension AgoraPollerUIController {
    func frameFromRect(_ rect: CGRect) -> CGRect {
        let width = self.view.width * rect.width
        let height = self.view.height * rect.height
        let MEDx = self.view.width - width
        let MEDy = self.view.height - height
        let x = MEDx * rect.minX
        let y = MEDy * rect.minY
        return CGRect(x: x,
                      y: y,
                      width: width,
                      height: height)
    }
    
    func setup() {
        let allWidgetActivity = contextPool.widget.getAllWidgetActivity()
        
        guard allWidgetActivity.count > 0 else {
            return
        }
        
        for (widgetId, activityNumber) in allWidgetActivity {
            let active = activityNumber.boolValue
            
            guard widgetId.hasPrefix(kPollerWidgetId),
                  active == true else {
                continue
            }
            
            self.onWidgetActive(widgetId)
        }
    }
}
