//
//  AgoraCloudUIController.swift
//  AgoraEduUI
//
//  Created by DoubleCircle on 2022/2/4.
//

import AgoraEduContext
import AgoraWidget

protocol FcrCloudUIComponentDelegate: NSObjectProtocol {
    func onOpenAlfCourseware(urlString: String,
                             resourceId: String)
}

class FcrCloudUIComponent: UIViewController {
    private var cloudWidget: AgoraBaseWidget?
    
    private weak var delegate: FcrCloudUIComponentDelegate?
    
    private var widgetSize: CGSize!
    
    /**context**/
    private let subRoom: AgoraEduSubRoomContext?
    private let roomController: AgoraEduRoomContext
    private let widgetController: AgoraEduWidgetContext
    private let userController: AgoraEduUserContext
    
    init(roomController: AgoraEduRoomContext,
         widgetController: AgoraEduWidgetContext,
         userController: AgoraEduUserContext,
         subRoom: AgoraEduSubRoomContext? = nil,
         delegate: FcrCloudUIComponentDelegate?) {
        self.roomController = roomController
        self.widgetController = widgetController
        self.userController = userController
        self.subRoom = subRoom
        self.delegate = delegate
        
        super.init(nibName: nil,
                   bundle: nil)
        
        initData()
        view.backgroundColor = .clear
        
        if let `subRoom` = subRoom {
            subRoom.registerSubRoomEventHandler(self)
        } else {
            roomController.registerRoomEventHandler(self)
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
extension FcrCloudUIComponent: AgoraEduRoomHandler {
    func onJoinRoomSuccess(roomInfo: AgoraEduContextRoomInfo) {
        initWidget()
    }
}

// MARK: - AgoraEduSubRoomHandler
extension FcrCloudUIComponent: AgoraEduSubRoomHandler {
    func onJoinSubRoomSuccess(roomInfo: AgoraEduContextSubRoomInfo) {
        initWidget()
    }
}

// MARK: - AgoraWidgetMessageObserver
extension FcrCloudUIComponent: AgoraWidgetMessageObserver {
    func onMessageReceived(_ message: String,
                           widgetId: String) {
        guard widgetId == kCloudWidgetId,
              let signal = message.toCloudSignal() else {
            return
        }
        switch signal {
        case .openCourseware(let courseware):
            if courseware.ext == "alf" {
                delegate?.onOpenAlfCourseware(urlString: courseware.resourceUrl,
                                              resourceId: courseware.resourceUuid)
                break
            }
            if let message = AgoraBoardWidgetSignal.openCourseware(courseware.toBoard()).toMessageString() {
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

// MARK: - private
extension FcrCloudUIComponent {
    @objc func didDragTab(_ sender: UIPanGestureRecognizer) {
        guard sender.state == .changed,
              let targetView = cloudWidget?.view else {
            return
        }
        
        let point = sender.translation(in: view)
        
        let viewWidth = targetView.width
        let viewHeight = targetView.height
        
        let transLeft = targetView.frame.minX + point.x
        let transTop = targetView.frame.minY + point.y
        
        var finalLeft = (transLeft >= 0) ? transLeft : 0
        finalLeft = (finalLeft + viewWidth <= view.width) ? finalLeft : (view.width - viewWidth)
        
        var finalTop = (transTop >= 0) ? transTop : 0
        finalTop = (finalTop + viewHeight <= view.height) ? finalTop : (view.height - viewHeight)
        
        targetView.mas_remakeConstraints { make in
            make?.left.equalTo()(finalLeft)
            make?.top.equalTo()(finalTop)
            
            make?.width.equalTo()(widgetSize.width)
            make?.height.equalTo()(widgetSize.height)
        }
        
        sender.setTranslation(.zero,
                              in: view)
    }
    
    func initData() {
        switch roomController.getRoomInfo().roomType {
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
        guard UIConfig.cloudStorage.enable,
              userController.getLocalUserInfo().userRole == .teacher,
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
        cloudWidget.view.mas_makeConstraints { make in
            make?.center.equalTo()(view)
            make?.width.equalTo()(widgetSize.width)
            make?.height.equalTo()(widgetSize.height)
        }
    }
}
