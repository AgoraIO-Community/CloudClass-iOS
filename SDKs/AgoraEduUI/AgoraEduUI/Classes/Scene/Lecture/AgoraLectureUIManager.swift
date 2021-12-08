//
//  AgoraEduUI+Lecture.swift
//  AgoraEduSDK
//
//  Created by Cavan on 2021/4/22.
//

import AgoraUIEduBaseViews
import AgoraUIBaseViews
import AgoraEduContext
import AudioToolbox
import AgoraExtApp
import AgoraWidget

/// 房间控制器:
/// 用以处理全局状态和子控制器之间的交互关系
@objc public class AgoraLectureUIManager: AgoraEduUIManager {
    private let roomType: AgoraEduContextRoomType = .lecture
    /// 视图部分，支持feature的UI交互显示
    /** 工具栏*/
    private var toolsView: AgoraRoomToolstView!
    /** 画笔工具*/
    private var brushToolButton: AgoraRoomToolZoomButton!
    /// 控制器部分，除了视图显示，还包含和SDK之间的事件及数据交互
    /** 房间状态 控制器*/
    private var stateController: AgoraRoomStateUIController!
    /** 远程视窗渲染 控制器*/
    private var renderController: AgoraHorizListRenderUIController!
    /** 白板的渲染 控制器*/
    private var whiteBoardController: AgoraPaintingBoardUIController!
    /** 工具箱 控制器*/
    private lazy var toolBoxViewController: AgoraToolBoxUIController = {
        let vc = AgoraToolBoxUIController(context: contextPool)
        vc.delegate = self
        self.addChild(vc)
        return vc
    }()
    /** 画板工具 控制器*/
    private lazy var brushToolsViewController: AgoraBoardToolsUIController = {
        let vc = AgoraBoardToolsUIController(context: contextPool)
        vc.delegate = self
        self.addChild(vc)
        return vc
    }()
    /** 聊天窗口 控制器*/
    private var messageController: AgoraBaseWidget?
    /** 设置界面 控制器*/
    private lazy var settingViewController: AgoraSettingUIController = {
        let vc = AgoraSettingUIController(context: contextPool)
        vc.delegate = self
        self.addChild(vc)
        return vc
    }()
        
    deinit {
        print("\(#function): \(self.classForCoder)")
    }
    
    @objc public override init(contextPool: AgoraEduContextPool,
                               delegate: AgoraEduUIManagerDelegate) {
        super.init(contextPool: contextPool,
                   delegate: delegate)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    public override func viewDidLoad() {
        super.viewDidLoad()
        AgoraLoading.loading()
        contextPool.room.joinRoom { [weak self] in
            AgoraLoading.hide()
            guard let `self` = self else {
                return
            }
            self.createViews()
            self.createConstrains()
            self.contextPool.user.registerEventHandler(self)
            self.contextPool.monitor.registerMonitorEventHandler(self)
            
            self.initWidgets()
        } fail: { [weak self] error in
            AgoraLoading.hide()
            self?.contextPool.room.leaveRoom()
        }
    }
    
    public override func didClickCtrlMaskView() {
        super.didClickCtrlMaskView()
        toolsView.deselectAll()
        brushToolButton.isSelected = false
    }
}

// MARK: - Actions
extension AgoraLectureUIManager {
    @objc func onClickBrushTools(_ sender: UIButton) {
        sender.isSelected = !sender.isSelected
        if sender.isSelected {
            toolsView.deselectAll()
            ctrlView = brushToolsViewController.view
            ctrlView?.mas_makeConstraints { make in
                make?.right.equalTo()(brushToolButton.mas_left)?.offset()(-7)
                make?.bottom.equalTo()(brushToolButton)?.offset()(-10)
            }
        } else {
            ctrlView = nil
        }
    }
}

// MARK: - AgoraEduMonitorHandler
extension AgoraLectureUIManager: AgoraEduMonitorHandler {
    // 连接状态
    func onLocalConnectionUpdated(_ state: AgoraEduContextConnectionState) {
        switch state {
        case .aborted:
            // 踢出
            AgoraLoading.hide()
            AgoraToast.toast(msg: AgoraKitLocalizedString("LoginOnAnotherDeviceText"))
            contextPool.room.leaveRoom()
        case .connecting:
            AgoraLoading.loading(msg: AgoraKitLocalizedString("LoaingText"))
        case .disconnected, .reconnecting:
            AgoraLoading.loading(msg: AgoraKitLocalizedString("ReconnectingText"))
        case .connected:
            AgoraLoading.hide()
        }
    }
}

// MARK: - AgoraEduUserHandler
extension AgoraLectureUIManager: AgoraEduUserHandler {
    public func onLocalUserKickedOut() {
        AgoraAlert()
            .setTitle(AgoraKitLocalizedString("KickOutNoticeText"))
            .setMessage(AgoraKitLocalizedString("KickOutText"))
            .addAction(action: AgoraAlertAction(title: AgoraKitLocalizedString("SureText"), action: {
                self.contextPool.room.leaveRoom()
            }))
            .show(in: self)
    }
    
    func onShowUserReward(_ user: AgoraEduContextUserInfo) {
        
    }
}

// MARK: - AgoraToolListViewDelegate
extension AgoraLectureUIManager: AgoraRoomToolsViewDelegate {
    func toolsViewDidSelectTool(_ tool: AgoraRoomToolstView.AgoraRoomToolType) {
        brushToolButton.isSelected = false
        switch tool {
        case .setting:
            ctrlView = settingViewController.view
            ctrlView?.mas_makeConstraints { make in
                make?.width.equalTo()(201)
                make?.height.equalTo()(281)
                make?.right.equalTo()(toolsView.mas_left)?.offset()(-7)
                make?.centerY.equalTo()(toolsView)
            }
        case .message:
            if let message = messageController {
                message.onMessageReceived("max")
                
                ctrlView = message.view
                ctrlView?.mas_remakeConstraints { make in
                    make?.right.equalTo()(toolsView.mas_left)?.offset()(-7)
                    make?.centerY.equalTo()(toolsView)
                    make?.width.equalTo()(200)
                    make?.height.equalTo()(287)
                }
            }
        default: break
        }
    }
    
    func toolsViewDidDeselectTool(_ tool: AgoraRoomToolstView.AgoraRoomToolType) {
        ctrlView = nil
    }
}
// MARK: - PaintingToolBoxViewDelegate
extension AgoraLectureUIManager: AgoraToolBoxUIControllerDelegate {
    func toolBoxDidSelectTool(_ tool: AgoraToolBoxToolType) {
        toolsView.deselectAll()
        ctrlView = nil
        switch tool {
        case .cloudStorage:
            // 云盘工具操作
            
            break
        case .saveBoard: break
        case .record: break
        case .vote: break
        case .countDown: break
        case .answerSheet: // 答题器
            guard let extAppInfos = contextPool.extApp.getExtAppInfos(),
                  let info = extAppInfos.first(where: {$0.appIdentifier == "io.agora.answerSheet"}) else {
                return
            }
            contextPool.extApp.willLaunchExtApp(info.appIdentifier)
        default: break
        }
    }
}

// MARK: - AgoraBoardToolsUIControllerDelegate
extension AgoraLectureUIManager: AgoraBoardToolsUIControllerDelegate {
    func brushToolsViewDidBrushChanged(_ tool: AgoraBoardToolItem) {
        brushToolButton.setImage(tool.image(self))
    }
}

// MARK: - PaintingBoardUIControllerDelegate
extension AgoraLectureUIManager: AgoraPaintingBoardUIControllerDelegate {
    func controller(_ controller: AgoraPaintingBoardUIController,
                    didUpdateBoard permission: Bool) {
        // 当白板变为未授权时，弹窗取消
        if !permission,
           let view = ctrlView,
           view == brushToolsViewController.view {
            ctrlView = nil
        }
        
        brushToolButton.isHidden = !permission
    }
}

// MARK: - Creations
private extension AgoraLectureUIManager {
    func createViews() {
        stateController = AgoraRoomStateUIController(context: contextPool)
        addChild(stateController)
        contentView.addSubview(stateController.view)
        
        whiteBoardController = AgoraPaintingBoardUIController(context: contextPool)
        whiteBoardController.delegate = self
        contentView.addSubview(whiteBoardController.view)
        
        renderController = AgoraHorizListRenderUIController(context: contextPool)
        renderController.themeColor = UIColor(rgb: 0x75C0FE)
        addChild(renderController)
        contentView.addSubview(renderController.view)
        
        brushToolButton = AgoraRoomToolZoomButton(frame: CGRect(x: 0,
                                                        y: 0,
                                                        width: 44,
                                                        height: 44))
        brushToolButton.isHidden = true
        brushToolButton.setImage(AgoraUIImage(object: self,
                                              name: "ic_brush_pencil"))
        brushToolButton.addTarget(self,
                                  action: #selector(onClickBrushTools(_:)),
                                  for: .touchUpInside)
        contentView.addSubview(brushToolButton)
        
        toolsView = AgoraRoomToolstView(frame: .zero)
        toolsView.tools = [.setting, .message]
        toolsView.delegate = self
        contentView.addSubview(toolsView)
    }
    
    func initWidgets() {
//        guard let widgetInfos = contextPool.widget.getWidgetInfos() else {
//            return
//        }
//        
//        if let message = createChatWidget() {
//            messageController = message
//            message.addMessageObserver(self)
//            contentView.addSubview(message.containerView)
//        }
    }
    
    func createConstrains() {
        stateController.view.mas_makeConstraints { make in
            make?.top.left().right().equalTo()(stateController.view.superview)
            make?.height.equalTo()(20)
        }
        renderController.view.mas_makeConstraints { make in
            make?.left.right().equalTo()(renderController.view.superview)
            make?.top.equalTo()(stateController.view.mas_bottom)
            make?.height.equalTo()(AgoraFit.scale(80))
        }
        whiteBoardController.view.mas_makeConstraints { make in
            make?.top.equalTo()(renderController.view.mas_bottom)
            make?.left.right().bottom().equalTo()(whiteBoardController.view.superview)
        }
        brushToolButton.mas_makeConstraints { make in
            make?.right.equalTo()(-9)
            make?.bottom.equalTo()(-14)
            make?.width.height().equalTo()(AgoraFit.scale(46))
        }
        toolsView.mas_makeConstraints { make in
            make?.right.equalTo()(brushToolButton)
            make?.centerY.equalTo()(0)
        }
    }
}

// MARK: - AgoraWidgetMessageObserver
extension AgoraLectureUIManager: AgoraWidgetMessageObserver {
    public func onMessageReceived(_ message: String,
                                  widgetId: String) {
        switch widgetId {
        case "AgoraChatWidget":
            if let dic = message.json(),
               let isMin = dic["isMinSize"] as? Bool,
               isMin{
                ctrlView == nil
            }
        case "easemobIM":
            if message == "min" {
                ctrlView == nil
            }
        default:
            break
        }
    }
}

// MARK: - AgoraSettingUIControllerDelegate
extension AgoraLectureUIManager: AgoraSettingUIControllerDelegate {
    func settingUIControllerDidPressedLeaveRoom(controller: AgoraSettingUIController) {
        exit(reason: .normal)
    }
}
