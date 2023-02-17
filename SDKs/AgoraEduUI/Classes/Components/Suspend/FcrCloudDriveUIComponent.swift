//
//  AgoraCloudUIController.swift
//  AgoraEduUI
//
//  Created by DoubleCircle on 2022/2/4.
//

import AgoraEduCore
import AgoraWidget

protocol FcrCloudDriveUIComponentDelegate: NSObjectProtocol {
    func onSelectedFile(fileJson: [String: Any],
                        fileExt: String)
}

class FcrCloudDriveUIComponent: FcrUIComponent {
    private var widget: AgoraBaseWidget?
    
    private weak var delegate: FcrCloudDriveUIComponentDelegate?
    
    private var widgetSize: CGSize {
        switch roomController.getRoomInfo().roomType {
        case .lecture:
            return CGSize(width: 360,
                          height: 214)
        default:
            return CGSize(width: 435,
                          height: 253)
        }
    }
    
    /**context**/
    private let subRoom: AgoraEduSubRoomContext?
    private let roomController: AgoraEduRoomContext
    private let widgetController: AgoraEduWidgetContext
    private let userController: AgoraEduUserContext
    
    init(roomController: AgoraEduRoomContext,
         widgetController: AgoraEduWidgetContext,
         userController: AgoraEduUserContext,
         subRoom: AgoraEduSubRoomContext? = nil,
         delegate: FcrCloudDriveUIComponentDelegate?) {
        self.roomController = roomController
        self.widgetController = widgetController
        self.userController = userController
        self.subRoom = subRoom
        self.delegate = delegate
        
        super.init(nibName: nil,
                   bundle: nil)
        
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
    
    func show() {
        view.isHidden = false
    }
    
    func hide() {
        view.isHidden = true
    }
}

// MARK: - AgoraEduRoomHandler
extension FcrCloudDriveUIComponent: AgoraEduRoomHandler {
    func onJoinRoomSuccess(roomInfo: AgoraEduContextRoomInfo) {
        initWidget()
    }
}

// MARK: - AgoraEduSubRoomHandler
extension FcrCloudDriveUIComponent: AgoraEduSubRoomHandler {
    func onJoinSubRoomSuccess(roomInfo: AgoraEduContextSubRoomInfo) {
        initWidget()
    }
}

// MARK: - AgoraWidgetMessageObserver
extension FcrCloudDriveUIComponent: AgoraWidgetMessageObserver {
    func onMessageReceived(_ message: String,
                           widgetId: String) {
        guard widgetId == CloudDriveWidgetId,
              let json = message.json()
        else {
            return
        }
        
        // Selected file
        if let fileJson = ValueTransform(value: json["selectedFile"],
                                         result: [String: Any].self),
            let ext = ValueTransform(value: fileJson["ext"],
                                     result: String.self) {
            delegate?.onSelectedFile(fileJson: fileJson,
                                     fileExt: ext)
            
        // Close cloud drive
        } else if let _ = json["close"] {
            hide()
        }
    }
}

// MARK: - private
extension FcrCloudDriveUIComponent {
    @objc func onDrag(_ sender: UIPanGestureRecognizer) {
        guard sender.state == .changed,
              let targetView = widget?.view else {
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
    
    func initWidget() {
        guard UIConfig.cloudStorage.enable,
              userController.getLocalUserInfo().userRole == .teacher,
              let cloudConfig = widgetController.getWidgetConfig(CloudDriveWidgetId) else {
            return
        }
        
        let cloudWidget = widgetController.create(cloudConfig)
        widgetController.add(self,
                             widgetId: CloudDriveWidgetId)
        view.isUserInteractionEnabled = true
        view.addSubview(cloudWidget.view)
        self.widget = cloudWidget
        
        let gesture = UIPanGestureRecognizer(target: self,
                                             action: #selector(onDrag(_:)))
        
        cloudWidget.view.addGestureRecognizer(gesture)
        
        cloudWidget.view.mas_makeConstraints { make in
            make?.center.equalTo()(view)
            make?.width.equalTo()(widgetSize.width)
            make?.height.equalTo()(widgetSize.height)
        }
    }
}
