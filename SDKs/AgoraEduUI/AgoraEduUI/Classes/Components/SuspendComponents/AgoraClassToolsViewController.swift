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
    /**Frame*/
    private var pollSize = CGSize.zero
    private var popupQuizSize = CGSize.zero
    private var countdownTimeSize = CGSize.zero
    
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
        if let size = parseSizeMessage(widgetId: widgetId,
                                       message: message) {
            updateWidgetFrame(widgetId,
                              size: size)
        }
    }
}

extension AgoraClassToolsViewController: AgoraWidgetSyncFrameObserver {
    func onWidgetSyncFrameUpdated(_ syncFrame: CGRect,
                                  widgetId: String) {
        let size = getWidgetSize(widgetId)
        updateWidgetFrame(widgetId,
                          size: size)
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
    
    func parseSizeMessage(widgetId: String,
                          message: String) -> CGSize? {
        guard let json = message.json(),
           let sizeDic = json["size"] as? [String: Any],
           let width = sizeDic["width"] as? CGFloat,
           let height = sizeDic["height"] as? CGFloat else {
            return nil
        }
        
        let size = CGSize(width: width,
                          height: height)
        
        switch widgetId {
        case PollWidgetId:
            pollSize = size
        case PopupQuizWidgetId:
            popupQuizSize = size
        case CountdownTimerWidgetId:
            countdownTimeSize = size
        default:
            break
        }
        
        return size
    }
    
    func getWidgetSize(_ widgetId: String) -> CGSize {
        switch widgetId {
        case PollWidgetId:
            return pollSize
        case PopupQuizWidgetId:
            return popupQuizSize
        case CountdownTimerWidgetId:
            return countdownTimeSize
        default:
            return .zero
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
        
        widgetController.addObserver(forWidgetSyncFrame: self,
                                     widgetId: widgetId)
        widgetController.add(self,
                             widgetId: widgetId)
        
        let widget = widgetController.create(config)
        
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
        
        sendWidgetCurrentTimestamp(widgetId)
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
    
    func updateWidgetFrame(_ widgetId: String,
                           size: CGSize) {
        guard widgetIdList.contains(widgetId) else {
            return
        }
        
        guard let targetView = getWidget(widgetId)?.view else {
            return
        }
        
        let widget = contextPool.widget
        let syncFrame = widget.getWidgetSyncFrame(widgetId)
        
        let frame = syncFrame.displayFrameFromSyncFrame(superView: self.view,
                                                        displayWidth: size.width,
                                                        displayHeight: size.height)
        
        view.bringSubviewToFront(targetView)
        view.layoutIfNeeded()
        
        targetView.mas_remakeConstraints { make in
            make?.left.equalTo()(frame.origin.x)
            make?.top.equalTo()(frame.origin.y)
            make?.width.equalTo()(size.width)
            make?.height.equalTo()(size.height)
        }
        
        UIView.animate(withDuration: TimeInterval.agora_animation) {
            self.view.layoutIfNeeded()
        }
    }
    
    func sendWidgetCurrentTimestamp(_ widgetId: String) {
        let syncTimestamp = contextPool.monitor.getSyncTimestamp()
        let tsDic = ["syncTimestamp": syncTimestamp]
        
        if let string = tsDic.jsonString() {
            contextPool.widget.sendMessage(toWidget: widgetId,
                                           message: string)
        }
    }
}
