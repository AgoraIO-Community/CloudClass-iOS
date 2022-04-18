//
//  AgoraCloudUIController.swift
//  AgoraEduUI
//
//  Created by DoubleCircle on 2022/2/4.
//

import AgoraEduContext
import AgoraWidget

class AgoraCloudUIController: UIViewController {
    private var contextPool: AgoraEduContextPool!
    private var subRoom: AgoraEduSubRoomContext?
    private var cloudWidget: AgoraBaseWidget?
    
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
    
    private var widgetSize: CGSize!
    
    init(context: AgoraEduContextPool,
         subRoom: AgoraEduSubRoomContext? = nil) {
        super.init(nibName: nil,
                   bundle: nil)
        self.contextPool = context
        self.subRoom = subRoom
        
        initData()
        view.backgroundColor = .clear
        
        if let `subRoom` = subRoom {
            subRoom.registerSubRoomEventHandler(self)
        } else {
            contextPool.room.registerRoomEventHandler(self)
        }
    }
    
    override func loadView() {
        view = AgoraBaseUIContainer()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

// MARK: - AgoraEduRoomHandler
extension AgoraCloudUIController: AgoraEduRoomHandler {
    func onJoinRoomSuccess(roomInfo: AgoraEduContextRoomInfo) {
        initWidget()
    }
}

extension AgoraCloudUIController: AgoraEduSubRoomHandler {
    func onJoinSubRoomSuccess(roomInfo: AgoraEduContextRoomInfo) {
        initWidget()
    }
}

// MARK: - AgoraWidgetMessageObserver
extension AgoraCloudUIController: AgoraWidgetMessageObserver{
    func onMessageReceived(_ message: String,
                           widgetId: String) {
        if widgetId == kCloudWidgetId,
        let signal = message.toCloudSignal() {
            switch signal {
            case .OpenCourseware(let courseware):
                if let message = AgoraBoardWidgetSignal.OpenCourseware(courseware.toBoard()).toMessageString() {
                    widgetController.sendMessage(toWidget: kBoardWidgetId,
                                                 message: message)
                }
            case .CloseCloud:
                view.isHidden = true
            default:
                break
            }
        }
    }
}

// MARK: - private
extension AgoraCloudUIController {
    @objc func didDragTab(_ sender: UIPanGestureRecognizer) {
        guard sender.state == .changed,
              let targetView = cloudWidget?.view,
              sender.location(in: targetView).y <= 60 else {
            return
        }
        let currentOrigin = targetView.frame.origin
        
        let translation = sender.translation(in: targetView)

        var finalX = currentOrigin.x + translation.x
        var finalY = currentOrigin.y + translation.y
        if finalX < 0 {
            finalX = 0
        }
        if finalX > (view.bounds.width - widgetSize.width) {
            finalX = view.bounds.width - widgetSize.width
        }
        if finalY < 0 {
            finalY = 0
        }
        if finalY > (view.bounds.height - widgetSize.height) {
            finalY = view.bounds.height - widgetSize.height
        }
        
        targetView.frame.origin = CGPoint(x: finalX,
                                          y: finalY)

        UIView.animate(withDuration: TimeInterval.agora_animation) {
            self.view.layoutIfNeeded()
        }
    }
    
    func initData() {
        switch contextPool.room.getRoomInfo().roomType {
        case .oneToOne:
            widgetSize = CGSize(width: 435,
                                height: 253)
        case .lecture:
            widgetSize = CGSize(width: 360,
                                height: 214)
        default:
            widgetSize = CGSize(width: 435,
                                height: 253)
        }
    }
    
    func initWidget() {
        guard userController.getLocalUserInfo().userRole == .teacher,
           let cloudConfig = widgetController.getWidgetConfig(kCloudWidgetId) else {
            return
        }
        
        let cloudWidget = widgetController.create(cloudConfig)
        widgetController.add(self,
                             widgetId: kCloudWidgetId)
        view.isUserInteractionEnabled = true
        view.addSubview(cloudWidget.view)
        self.cloudWidget = cloudWidget
        
        let gesture = UIPanGestureRecognizer(target: self,
                                             action: #selector(didDragTab(_:)))
        cloudWidget.view.addGestureRecognizer(gesture)
        cloudWidget.view.mas_remakeConstraints { make in
            make?.center.equalTo()(view)
            make?.width.equalTo()(widgetSize.width)
            make?.height.equalTo()(widgetSize.height)
        }
    }
}
