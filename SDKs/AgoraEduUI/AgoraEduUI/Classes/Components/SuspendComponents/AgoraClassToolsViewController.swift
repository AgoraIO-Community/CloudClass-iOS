//
//  AgoraClassToolsViewController.swift
//  AgoraEduUI
//
//  Created by Cavan on 2022/3/5.
//

import AgoraEduContext
import AgoraWidget
import UIKit

class AgoraClassToolsViewController: UIViewController {
    /**Data*/
    private var contextPool: AgoraEduContextPool!
    private let widgetIdList = [PollWidgetId,
                                PopupQuizWidgetId,
                                CountdownTimerWidgetId]
    
    /**Widgets**/
    private var popupQuizWidget: AgoraBaseWidget?
    private var pollWidget: AgoraBaseWidget?
    private var countdownTimerWidget: AgoraBaseWidget?
    
    init(context: AgoraEduContextPool) {
        self.contextPool = context
        super.init(nibName: nil,
                   bundle: nil)
    }
    
    override func loadView() {
        view = AgoraBaseUIContainer()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    } 
    
    override func viewDidLoad() {
        super.viewDidLoad()
        contextPool.room.registerRoomEventHandler(self)
        contextPool.widget.add(self)
    }
}

// MARK: - AgoraEduRoomHandler
extension AgoraClassToolsViewController: AgoraEduRoomHandler {
    func onJoinRoomSuccess(roomInfo: AgoraEduContextRoomInfo) {
        setup()
    }
}

// MARK: - AgoraWidgetActivityObserver
extension AgoraClassToolsViewController: AgoraWidgetActivityObserver {
    func onWidgetActive(_ widgetId: String) {
        createWidget(widgetId)
    }
    
    func onWidgetInactive(_ widgetId: String) {
        releaseWidget(widgetId)
    }
}

// MARK: - AgoraWidgetMessageObserver
extension AgoraClassToolsViewController: AgoraWidgetMessageObserver {
    func onMessageReceived(_ message: String,
                           widgetId: String) {
        guard let signal = message.toCountdownSignal() else {
            return
        }
        switch signal {
        case .getTimestamp:
            let ts = contextPool.monitor.getSyncTimestamp()
            if let message = AgoraCountdownWidgetSignal.sendTimestamp(ts).toMessageString() {
                contextPool.widget.sendMessage(toWidget: CountdownTimerWidgetId,
                                               message: message)
            }
        default:
            break
        }
    }
}

extension AgoraClassToolsViewController: AgoraWidgetSyncFrameObserver {
    func onWidgetSyncFrameUpdated(_ syncFrame: CGRect,
                                  widgetId: String) {
        updateWidgetFrame(widgetId)
    }
}

// MARK: - private
private extension AgoraClassToolsViewController {
    func setup() {
        let allWidgetActivity = contextPool.widget.getAllWidgetActivity()
        
        guard allWidgetActivity.count > 0 else {
            return
        }
        
        for (widgetId, activityNumber) in allWidgetActivity {
            let active = activityNumber.boolValue
            
            if active == true {
                createWidget(widgetId)
            }
        }
    }
    
    func createWidget(_ widgetId: String) {
        let widgetController = contextPool.widget
        
        guard widgetIdList.contains(widgetId),
              let config = widgetController.getWidgetConfig(widgetId) else {
            return
        }
        
        if let _ = getWidget(widgetId) {
            return
        }
        
        let widget = widgetController.create(config)
        widgetController.addObserver(forWidgetSyncFrame: self,
                                     widgetId: widgetId)
        widgetController.add(self,
                             widgetId: widgetId)
        
        view.addSubview(widget.view)
        
        switch widgetId {
        case PollWidgetId:
            pollWidget = widget
        case CountdownTimerWidgetId:
            countdownTimerWidget = widget
        case PopupQuizWidgetId:
            popupQuizWidget = widget
        default:
            return
        }
        
        let syncTimestamp = contextPool.monitor.getSyncTimestamp()
        let tsDic = ["syncTimestamp": syncTimestamp]
        
        if let string = tsDic.jsonString() {
            widgetController.sendMessage(toWidget: widgetId,
                                         message: string)
        }
        
        updateWidgetFrame(widgetId)
    }
    
    func getWidget(_ widgetId: String) -> AgoraBaseWidget? {
        switch widgetId {
        case PollWidgetId:
            return pollWidget
        case CountdownTimerWidgetId:
            return countdownTimerWidget
        case PopupQuizWidgetId:
            return popupQuizWidget
        default:
            return nil
        }
    }
    
    func releaseWidget(_ widgetId: String) {
        guard widgetIdList.contains(widgetId) else {
            return
        }
        
        switch widgetId {
        case PollWidgetId:
            pollWidget?.view.removeFromSuperview()
            pollWidget = nil
        case CountdownTimerWidgetId:
            countdownTimerWidget?.view.removeFromSuperview()
            countdownTimerWidget = nil
        case PopupQuizWidgetId:
            popupQuizWidget?.view.removeFromSuperview()
            popupQuizWidget = nil
        default:
            break
        }
        
        let widget = contextPool.widget
        
        widget.remove(self,
                      widgetId: widgetId)
        widget.removeObserver(forWidgetSyncFrame: self,
                              widgetId: widgetId)
    }
    
    func updateWidgetFrame(_ widgetId: String) {
        guard widgetIdList.contains(widgetId) else {
            return
        }
        
        guard let targetView = getWidget(widgetId)?.view else {
            return
        }
        
        let widget = contextPool.widget
        let syncFrame = widget.getWidgetSyncFrame(widgetId)
        
        var widgetWidth: CGFloat = 0
        var widgetHeight: CGFloat = 0
        
        switch widgetId {
        case PollWidgetId:
            widgetWidth = 240
            widgetHeight = 238
        case CountdownTimerWidgetId:
            widgetWidth = 184
            widgetHeight = 102
        case PopupQuizWidgetId:
            widgetWidth = 240
            widgetHeight = 180
        default:
            return
        }
        
        let frame = syncFrame.displayFrameFromSyncFrame(superView: self.view,
                                                        displayWidth: widgetWidth,
                                                        displayHeight: widgetHeight)
        
        view.bringSubviewToFront(targetView)
        view.layoutIfNeeded()
        
        targetView.mas_remakeConstraints { make in
            make?.left.equalTo()(frame.origin.x)
            make?.top.equalTo()(frame.origin.y)
            make?.width.equalTo()(widgetWidth)
            make?.height.equalTo()(widgetHeight)
        }
        
        UIView.animate(withDuration: TimeInterval.agora_animation) {
            self.view.layoutIfNeeded()
        }
    }
}
