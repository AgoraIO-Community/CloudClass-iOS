//
//  AgoraCloudUIController.swift
//  AgoraEduUI
//
//  Created by DoubleCircle on 2022/2/4.
//

import AgoraEduContext
import AgoraWidget

class AgoraCloudUIController: UIViewController {
    var cloudWidget: AgoraBaseWidget?
    var contextPool: AgoraEduContextPool!
    
    private var widgetSize: CGSize!
    
    init(context: AgoraEduContextPool) {
        super.init(nibName: nil, bundle: nil)
        contextPool = context
        initData()
        view.backgroundColor = .clear
        
        contextPool.room.registerRoomEventHandler(self)
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
        if contextPool.user.getLocalUserInfo().userRole == .teacher,
           let cloudConfig = contextPool.widget.getWidgetConfig(kCloudWidgetId) {
            let cloudWidget = contextPool.widget.create(cloudConfig)
            contextPool.widget.add(self,
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
                    contextPool.widget.sendMessage(toWidget: kBoardWidgetId,
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
    
    func initData(){
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
}
