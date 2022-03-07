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
    private let widgetIdList = [PollerWidgetId,
                                AnswerSelectorWidgetId,
                                CountdownWidgetId]
    
    /**Widgets**/
    private var answerSelectorWidget: AgoraBaseWidget?
    private var pollerWidget: AgoraBaseWidget?
    private var countdownWidget: AgoraBaseWidget?
    
    init(context: AgoraEduContextPool) {
        self.contextPool = context
        super.init(nibName: nil,
                   bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.isHidden = true
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
                contextPool.widget.sendMessage(toWidget: CountdownWidgetId,
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
        let frame = syncFrame.displayFrameFromSyncFrame(superView: self.view)
        
        guard let targetView = getWidget(widgetId)?.view else {
            return
        }
        
        view.bringSubviewToFront(targetView)
        view.layoutIfNeeded()
        
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
        
        let widget = contextPool.widget.create(config)
        contextPool.widget.addObserver(forWidgetSyncFrame: self,
                                       widgetId: widgetId)
        contextPool.widget.add(self,
                               widgetId: widgetId)
        
        view.isUserInteractionEnabled = true
        view.addSubview(widget.view)
        
        switch widgetId {
        case PollerWidgetId:
            pollerWidget = widget
        case CountdownWidgetId:
            countdownWidget = widget
        case AnswerSelectorWidgetId:
            answerSelectorWidget = widget
        default:
            return
        }
        
        if widgetId != AnswerSelectorWidgetId {
            widget.view.mas_makeConstraints { make in
                make?.left.right().top().bottom().equalTo()(0)
            }
        } else {
            let syncTimestamp = contextPool.monitor.getSyncTimestamp()
            let tsDic = ["syncTimestamp": syncTimestamp]
            
            if let string = tsDic.jsonString() {
                contextPool.widget.sendMessage(toWidget: widgetId,
                                               message: string)
            }
            
            widget.view.mas_makeConstraints { (make) in
                make?.centerX.equalTo()(0)
                make?.centerY.equalTo()(0)
                make?.width.equalTo()(240)
                make?.height.equalTo()(180)
            }
        }
    }
    
    func getWidget(_ widgetId: String) -> AgoraBaseWidget? {
        switch widgetId {
        case PollerWidgetId:
            return pollerWidget
        case CountdownWidgetId:
            return countdownWidget
        case AnswerSelectorWidgetId:
            return answerSelectorWidget
        default:
            return nil
        }
    }
    
    func releaseWidget(_ widgetId: String) {
        guard widgetIdList.contains(widgetId) else {
            return
        }
        
        switch widgetId {
        case PollerWidgetId:
            pollerWidget?.view.removeFromSuperview()
            pollerWidget = nil
        case CountdownWidgetId:
            countdownWidget?.view.removeFromSuperview()
            countdownWidget = nil
        case AnswerSelectorWidgetId:
            answerSelectorWidget?.view.removeFromSuperview()
            answerSelectorWidget = nil
        default:
            break
        }
        
        let widget = contextPool.widget
        
        widget.remove(self,
                      widgetId: widgetId)
        widget.removeObserver(forWidgetSyncFrame: self,
                              widgetId: widgetId)
    }
}
