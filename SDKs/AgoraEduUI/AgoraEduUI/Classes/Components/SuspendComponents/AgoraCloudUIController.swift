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
    
    init(context: AgoraEduContextPool) {
        super.init(nibName: nil, bundle: nil)
        contextPool = context
        view.backgroundColor = .clear
        
        contextPool.room.registerRoomEventHandler(self)
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
            
            cloudWidget.view.mas_makeConstraints { make in
                make?.left.right().top().bottom().equalTo()(0)
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
            case .OpenCoursewares(let courseware):
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
    func initCoursewares() {
        
    }
}
