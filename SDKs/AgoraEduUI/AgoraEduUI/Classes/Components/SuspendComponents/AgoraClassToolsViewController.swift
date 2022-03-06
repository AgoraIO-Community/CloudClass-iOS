//
//  AgoraClassToolsViewController.swift
//  AgoraEduUI
//
//  Created by Cavan on 2022/3/5.
//

import AgoraEduContext
import AgoraWidget
import UIKit

// TODO: wait for pc to change
fileprivate let kAnswerSelectorId = "selector"
fileprivate let kCountdownId = "countdown"
//    fileprivate let kAnswerSelectorId = "AnswerSelector"
//    fileprivate let kCountdownId = "CountdownTimer"

class AgoraClassToolsViewController: UIViewController {
    /**Data*/
    private var contextPool: AgoraEduContextPool!
    private let kWidgetIds = [kPollerWidgetId, kAnswerSelectorId, kCountdownId]
    
    /**Widgets**/
    private var answerSelector: AgoraBaseWidget?
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
        guard kWidgetIds.contains(widgetId),
              let config = contextPool.widget.getWidgetConfig(widgetId) else {
                  return
              }
        
        if (widgetId == kPollerWidgetId && pollerWidget != nil) ||
           (widgetId == kCountdownId && countdownWidget != nil) ||
            (widgetId == kAnswerSelectorId && answerSelector != nil) {
            return
        }
        
        let widget = contextPool.widget.create(config)
        contextPool.widget.addObserver(forWidgetSyncFrame: self,
                                       widgetId: widgetId)
        contextPool.widget.add(self,
                               widgetId: widgetId)
        
        view.isUserInteractionEnabled = true
        view.addSubview(widget.view)
        
        if widgetId == kPollerWidgetId {
            self.pollerWidget = widget
        } else if widgetId == kCountdownId {
            self.countdownWidget = widget
        } else if widgetId == kAnswerSelectorId {
            self.answerSelector = widget
        }
        
        widget.view.mas_makeConstraints { make in
            make?.left.right().top().bottom().equalTo()(0)
        }
    }
    
    func onWidgetInactive(_ widgetId: String) {
        guard kWidgetIds.contains(widgetId) else {
            return
        }
        
        if widgetId == kPollerWidgetId {
            self.pollerWidget?.view.removeFromSuperview()
            self.pollerWidget = nil
        } else if widgetId == kCountdownId {
            self.countdownWidget?.view.removeFromSuperview()
            self.countdownWidget = nil
        } else if widgetId == kAnswerSelectorId {
            self.answerSelector?.view.removeFromSuperview()
            self.answerSelector = nil
        }
        contextPool.widget.remove(self,
                                  widgetId: widgetId)
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
                contextPool.widget.sendMessage(toWidget: kCountdownId,
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

// MARK: - private
private extension AgoraClassToolsViewController {
    func createAnswerSelector() {
        let widget = contextPool.widget
        
        guard let config = widget.getWidgetConfig(kAnswerSelectorId) else {
            return
        }
        
        let answerSelector = widget.create(config)
        view.addSubview(answerSelector.view)
        answerSelector.view.backgroundColor = .red
        
        answerSelector.view.frame = CGRect(x: 100,
                                           y: 100,
                                           width: 240,
                                           height: 208)
        
//        answerSelector.view.agora_x = 100
//        answerSelector.view.agora_y = 100
//        answerSelector.view.agora_width = 240
//        answerSelector.view.agora_height = 208
        
        self.answerSelector = answerSelector
    }
    
    func setup() {
        let allWidgetActivity = contextPool.widget.getAllWidgetActivity()
        
        guard allWidgetActivity.count > 0 else {
            return
        }
        
        for (widgetId, activityNumber) in allWidgetActivity {
            let active = activityNumber.boolValue
            
            if kWidgetIds.contains(widgetId),
               active == true {
                self.onWidgetActive(widgetId)
            }
        }
    }
    
    func getWidget(_ id: String) -> AgoraBaseWidget? {
        if id == kPollerWidgetId {
            return self.pollerWidget
        } else if id == kCountdownId {
            return self.countdownWidget
        } else if id == kAnswerSelectorId {
            return self.answerSelector
        }
        return nil
    }
}
