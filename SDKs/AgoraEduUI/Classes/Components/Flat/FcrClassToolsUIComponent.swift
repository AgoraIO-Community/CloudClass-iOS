//
//  AgoraClassToolsViewController.swift
//  AgoraEduUI
//
//  Created by Cavan on 2022/3/5.
//

import AgoraEduContext
import AgoraWidget
import UIKit

class FcrClassToolsUIComponent: UIViewController {
    private var widgetController: AgoraEduWidgetContext {
        if let `subRoom` = subRoom {
            return subRoom.widget
        } else {
            return contextPool.widget
        }
    }
    
    private var userController: AgoraEduUserContext {
        if let `subRoom` = subRoom {
            return subRoom.user
        } else {
            return contextPool.user
        }
    }
    
    private var contextPool: AgoraEduContextPool
    private var subRoom: AgoraEduSubRoomContext?
    
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
    
    init(context: AgoraEduContextPool,
         subRoom: AgoraEduSubRoomContext? = nil) {
        self.contextPool = context
        self.subRoom = subRoom
        
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
        
        if let `subRoom` = subRoom {
            subRoom.registerSubRoomEventHandler(self)
        } else {
            contextPool.room.registerRoomEventHandler(self)
        }
    }
}

// MARK: - AgoraUIActivity
extension FcrClassToolsUIComponent: AgoraUIActivity {
    func viewWillActive() {
        widgetController.add(self)
        createAllActiveWidgets()
    }
    
    func viewWillInactive() {
        widgetController.remove(self)
        relaseAllWidgets()
    }
}

// MARK: - AgoraEduRoomHandler
extension FcrClassToolsUIComponent: AgoraEduRoomHandler {
    func onJoinRoomSuccess(roomInfo: AgoraEduContextRoomInfo) {
        viewWillActive()
    }
}

extension FcrClassToolsUIComponent: AgoraEduSubRoomHandler {
    func onJoinSubRoomSuccess(roomInfo: AgoraEduContextSubRoomInfo) {
        viewWillActive()
    }
}

// MARK: - AgoraWidgetActivityObserver
extension FcrClassToolsUIComponent: AgoraWidgetActivityObserver {
    func onWidgetActive(_ widgetId: String) {
        createWidget(widgetId)
    }
    
    func onWidgetInactive(_ widgetId: String) {
        releaseWidget(widgetId)
    }
}

// MARK: - AgoraWidgetMessageObserver
extension FcrClassToolsUIComponent: AgoraWidgetMessageObserver {
    func onMessageReceived(_ message: String,
                           widgetId: String) {
        guard let size = parseSizeMessage(widgetId: widgetId,
                                          message: message) else {
            return
        }
        
        updateWidgetFrame(widgetId,
                          size: size)
    }
}

extension FcrClassToolsUIComponent: AgoraWidgetSyncFrameObserver {
    func onWidgetSyncFrameUpdated(_ syncFrame: CGRect,
                                  widgetId: String,
                                  operatorUser: AgoraWidgetUserInfo?) {
        guard operatorUser?.userUuid != userController.getLocalUserInfo().userUuid else {
            return
        }
        let size = getWidgetSize(widgetId)
        updateWidgetFrame(widgetId,
                          size: size)
    }
}

// MARK: - private
private extension FcrClassToolsUIComponent {
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
    
    func createAllActiveWidgets() {
        let allWidgetActivity = widgetController.getAllWidgetActivity()
        
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
    
    func relaseAllWidgets() {
        releaseWidget(PollWidgetId)
        releaseWidget(PopupQuizWidgetId)
        releaseWidget(CountdownTimerWidgetId)
    }
    
    func createWidget(_ widgetId: String) {
        guard isEnabledWidgetId(widgetId),
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
        
        if userController.getLocalUserInfo().userRole == .observer {
            widgetController.sendMessage(toWidget: widgetId,
                                         message: "hideSubmit")
        }
        
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
        
        widgetController.remove(self,
                                widgetId: widgetId)
        widgetController.removeObserver(forWidgetSyncFrame: self,
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
        
        let syncFrame = widgetController.getWidgetSyncFrame(widgetId)
        
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
            widgetController.sendMessage(toWidget: widgetId,
                                         message: string)
        }
    }
    
    func isEnabledWidgetId(_ widgetId: String) -> Bool {
        guard widgetIdList.contains(widgetId) else {
            return false
        }
        switch widgetId {
        case PollWidgetId:           return UIConfig.poll.enable
        case CountdownTimerWidgetId: return UIConfig.counter.enable
        case PopupQuizWidgetId:      return UIConfig.popupQuiz.enable
        default:                     return false
        }
    }
}
