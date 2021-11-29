//
//  AgoraEduUI+Small.swift
//  AgoraEduUI
//
//  Created by SRS on 2021/4/16.
//

import AgoraUIEduBaseViews
import AgoraUIBaseViews
import AgoraEduContext
import AudioToolbox
import AgoraExtApp
import AgoraWidget

/// 房间控制器:
/// 用以处理全局状态和子控制器之间的交互关系
class AgoraSmallUIManager: AgoraEduUIManager {
    private let roomType: AgoraEduContextRoomType = .paintingSmall
    /// 视图部分，支持feature的UI交互显示
    /** 容器视图，用以保持比例*/
    private var contentView: UIView!
    /** 工具栏*/
    private var toolsView: AgoraRoomToolstView!
    /** 画笔工具*/
    private var brushToolButton: AgoraRoomToolZoomButton!
    /// 控制器部分，除了视图显示，还包含和SDK之间的事件及数据交互
    /** 房间状态 控制器*/
    private var stateController: AgoraRoomStateUIController!
    /** 远程视窗渲染 控制器*/
    private var renderController: AgoraPaintingRenderUIController!
    /** 白板的渲染 控制器*/
    private var whiteBoardController: AgoraPaintingBoardUIController!
    /// 弹窗控制器
    /** 控制器遮罩层，用来盛装控制器和处理手势触发消失事件*/
    private var ctrlMaskView: UIView!
    /** 弹出显示的控制widget视图*/
    private weak var ctrlView: UIView? {
        willSet {
            if let view = ctrlView {
                ctrlView?.removeFromSuperview()
                ctrlMaskView.isHidden = true
            }
            if let view = newValue {
                ctrlMaskView.isHidden = false
                self.view.addSubview(view)
            }
        }
    }
    /** 工具箱 控制器*/
    private lazy var toolBoxViewController: AgoraToolBoxUIController = {
        let vc = AgoraToolBoxUIController(context: contextPool)
        vc.delegate = self
        self.addChild(vc)
        return vc
    }()
    /** 花名册 控制器*/
    private lazy var nameRollController: AgoraPaintingUserListUIController = {
        let vc = AgoraPaintingUserListUIController(context: contextPool)
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
    /** 举手 控制器*/
    private lazy var handsUpViewController: AgoraPaintingHandsUpUIController = {
        let vc = AgoraPaintingHandsUpUIController(context: contextPool)
        vc.delegate = self
        self.addChild(vc)
        return vc
    }()
        
    deinit {
        print("\(#function): \(self.classForCoder)")
    }
    
    public override init(contextPool: AgoraEduContextPool,
                         delegate: AgoraEduUIManagerDelegate) {
        super.init(contextPool: contextPool,
                   delegate: delegate)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        contextPool.room.joinClassroom()
        
        createViews()
        createConstrains()
        contextPool.room.registerEventHandler(self)
        contextPool.user.registerEventHandler(self)
        contextPool.monitor.registerMonitorEventHandler(self)
    }
}

// MARK: - Actions
extension AgoraSmallUIManager {
    @objc func onClickBrushTools(_ sender: UIButton) {
        sender.isSelected = !sender.isSelected
        if sender.isSelected {
            toolsView.deselectAll()
            handsUpViewController.deselect()
            ctrlView = brushToolsViewController.view
            ctrlView?.mas_makeConstraints { make in
                make?.right.equalTo()(brushToolButton.mas_left)?.offset()(-7)
                make?.bottom.equalTo()(brushToolButton)?.offset()(-10)
            }
        } else {
            ctrlView = nil
        }
    }
    
    @objc func onClickCtrlMaskView(_ sender: UITapGestureRecognizer) {
        toolsView.deselectAll()
        handsUpViewController.deselect()
        brushToolButton.isSelected = false
        ctrlView = nil
    }
}

// MARK: - AgoraEduRoomHandler
extension AgoraSmallUIManager: AgoraEduRoomHandler {
    func onClassroomJoined() {
        initWidgets()
    }
    
    func onShowErrorInfo(_ error: AgoraEduContextError) {
        AgoraToast.toast(msg: error.message)
    }
}

extension AgoraSmallUIManager: AgoraEduMonitorHandler {
    func onLocalConnectionUpdated(state: AgoraEduContextConnectionState) {
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
extension AgoraSmallUIManager: AgoraEduUserHandler {
    func onLocalUserKickedOut() {
        let btnLabel = AgoraAlertLabelModel()
        btnLabel.text = AgoraKitLocalizedString("SureText")
        let btnModel = AgoraAlertButtonModel()
        
        btnModel.titleLabel = btnLabel
        btnModel.tapActionBlock = { [weak self] (index) -> Void in
            self?.contextPool.room.leaveRoom()
        }
        AgoraUtils.showAlert(imageModel: nil,
                             title: AgoraKitLocalizedString("KickOutNoticeText"),
                             message: AgoraKitLocalizedString("KickOutText"),
                             btnModels: [btnModel])
    }
    
    func onShowUserReward(_ user: AgoraEduContextUserInfo) {
        
    }
}
// MARK: - HandsUpViewControllerDelegate
extension AgoraSmallUIManager: AgoraPaintingHandsUpUIControllerDelegate {
    func onShowHandsUpList(_ view: UIView) {
        toolsView.deselectAll()
        brushToolButton.isSelected = false
        ctrlView = view
        view.mas_makeConstraints { make in
            make?.bottom.equalTo()(handsUpViewController.view)
            make?.width.equalTo()(220)
            make?.height.equalTo()(245)
            make?.right.equalTo()(handsUpViewController.view.mas_left)?.offset()(-10)
        }
    }
    func onHideHandsUpList(_ view: UIView) {
        ctrlView = nil
    }
}

// MARK: - AgoraToolListViewDelegate
extension AgoraSmallUIManager: AgoraRoomToolsViewDelegate {
    func toolsViewDidSelectTool(_ tool: AgoraRoomToolstView.AgoraRoomToolType) {
        handsUpViewController.deselect()
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
        case .nameRoll:
            ctrlView = nameRollController.view
            ctrlView?.mas_makeConstraints { make in
                make?.right.equalTo()(toolsView.mas_left)?.offset()(-7)
                make?.centerY.equalTo()(toolsView)
            }
        case .message:
            if let message = messageController {
                message.widgetDidReceiveMessage("max")
                
                ctrlView = message.containerView
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
        if tool == .message,
        let message = messageController {
            message.widgetDidReceiveMessage("min")
        }
    }
}
// MARK: - PaintingToolBoxViewDelegate
extension AgoraSmallUIManager: AgoraToolBoxUIControllerDelegate {
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
extension AgoraSmallUIManager: AgoraBoardToolsUIControllerDelegate {
    func brushToolsViewDidBrushChanged(_ tool: AgoraBoardToolItem) {
        brushToolButton.setImage(tool.image(self))
    }
}

// MARK: - PaintingBoardUIControllerDelegate
extension AgoraSmallUIManager: AgoraPaintingBoardUIControllerDelegate {
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
private extension AgoraSmallUIManager {
    func createViews() {
        view.backgroundColor = .black
        
        contentView = UIView(frame: self.view.bounds)
        contentView.backgroundColor = UIColor(rgb: 0xECECF1)
        view.addSubview(contentView)
        
        stateController = AgoraRoomStateUIController(context: contextPool)
        stateController.themeColor = UIColor(rgb: 0x1D35AD)
        addChild(stateController)
        contentView.addSubview(stateController.view)
        
        whiteBoardController = AgoraPaintingBoardUIController(context: contextPool)
        whiteBoardController.delegate = self
        contentView.addSubview(whiteBoardController.view)
        
        renderController = AgoraPaintingRenderUIController(context: contextPool)
        renderController.themeColor = UIColor(rgb: 0x75C0FE)
        addChild(renderController)
        contentView.addSubview(renderController.view)
        
        ctrlMaskView = UIView(frame: .zero)
        ctrlMaskView.isHidden = true
        let tap = UITapGestureRecognizer(
            target: self, action: #selector(onClickCtrlMaskView(_:)))
        ctrlMaskView.addGestureRecognizer(tap)
        contentView.addSubview(ctrlMaskView)
        
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
        
        toolsView = AgoraRoomToolstView(frame: view.bounds)
        toolsView.delegate = self
        toolsView.tools = [.setting, .nameRoll, .message]
        contentView.addSubview(toolsView)
        
        contentView.addSubview(handsUpViewController.view)
    }
    
    func initWidgets() {
        guard let widgetInfos = contextPool.widget.getWidgetInfos() else {
            return
        }
        
        if let message = createChatWidget() {
            messageController = message
            message.addMessageObserver(self)
            contentView.addSubview(message.containerView)
        }
    }
    
    func createConstrains() {
        let width = max(UIScreen.main.bounds.width, UIScreen.main.bounds.height)
        let height = min(UIScreen.main.bounds.width, UIScreen.main.bounds.height)
        if width/height > 667.0/375.0 {
            contentView.mas_makeConstraints { make in
                make?.center.equalTo()(contentView.superview)
                make?.height.equalTo()(height)
                make?.width.equalTo()(height * 16.0/9.0)
            }
        } else {
            contentView.mas_makeConstraints { make in
                make?.center.equalTo()(contentView.superview)
                make?.width.equalTo()(width)
                make?.height.equalTo()(width * 9.0/16.0)
            }
        }
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
        ctrlMaskView.mas_makeConstraints { make in
            make?.left.right().top().bottom().equalTo()(self.view)
        }
        brushToolButton.mas_makeConstraints { make in
            make?.right.equalTo()(-9)
            make?.bottom.equalTo()(-14)
            make?.width.height().equalTo()(AgoraFit.scale(46))
        }
        toolsView.mas_makeConstraints { make in
            make?.right.equalTo()(brushToolButton)
            make?.centerY.equalTo()(toolsView.superview)
        }
        handsUpViewController.view.mas_makeConstraints { make in
            make?.width.height().equalTo()(AgoraFit.scale(46))
            make?.centerX.equalTo()(toolsView)
            make?.top.equalTo()(toolsView.mas_bottom)?.offset()(12)
        }
    }
}

// MARK: - AgoraWidgetDelegate
extension AgoraSmallUIManager: AgoraWidgetDelegate {
    func widget(_ widget: AgoraBaseWidget,
                didSendMessage message: String) {
        switch widget.widgetId {
        case "AgoraChatWidget":
            if let dic = message.json(),
               let isMin = dic["isMinSize"] as? Bool,
               isMin{
                ctrlView == nil
            }
        case "HyChatWidget":
            if message == "min" {
                ctrlView == nil
            }
        default:
            break
        }
    }
}

// MARK: - AgoraSettingUIControllerDelegate
extension AgoraSmallUIManager: AgoraSettingUIControllerDelegate {
    func settingUIControllerDidPressedLeaveRoom(controller: AgoraSettingUIController) {
        exit(reason: .normal)
    }
}
