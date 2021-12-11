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
@objc public class AgoraSmallUIManager: AgoraEduUIManager {
    private let roomType: AgoraEduContextRoomType = .paintingSmall
    /// 视图部分，支持feature的UI交互显示
    /** 工具栏*/
    private var toolsView: AgoraRoomToolstView!
    /// 控制器部分，除了视图显示，还包含和SDK之间的事件及数据交互
    /** 房间状态 控制器*/
    private var stateController: AgoraRoomStateUIController!
    /** 远程视窗渲染 控制器*/
    private var renderController: AgoraMembersHorizeRenderUIController!
    /** 白板的渲染 控制器*/
    private var boardController: AgoraBoardUIController!
    /** 工具箱 控制器*/
    private lazy var toolBoxViewController: AgoraToolBoxUIController = {
        let vc = AgoraToolBoxUIController(context: contextPool)
        vc.delegate = self
        self.addChild(vc)
        return vc
    }()
    /** 花名册 控制器*/
    private lazy var nameRollController: AgoraUserListUIController = {
        let vc = AgoraUserListUIController(context: contextPool)
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
    private var chatController: AgoraChatUIController!
    /** 设置界面 控制器*/
    private lazy var settingViewController: AgoraSettingUIController = {
        let vc = AgoraSettingUIController(context: contextPool)
        vc.delegate = self
        self.addChild(vc)
        return vc
    }()
    /** 举手 控制器*/
    private lazy var handsUpViewController: AgoraHandsUpUIController = {
        let vc = AgoraHandsUpUIController(context: contextPool)
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
        
        self.createViews()
        self.createConstrains()
        self.contextPool.user.registerEventHandler(self)
        self.contextPool.monitor.registerMonitorEventHandler(self)
        
        AgoraLoading.loading()
        contextPool.room.joinRoom { [weak self] in
            AgoraLoading.hide()
            guard let `self` = self else {
                return
            }
            self.createChatController()
            // 打开本地音视频设备
            let cameras = self.contextPool.media.getLocalDevices(deviceType: .camera)
            if let camera = cameras.first(where: {$0.deviceName.contains(kFrontCameraStr)}) {
                let ero = self.contextPool.media.openLocalDevice(device: camera)
                print(ero)
            }
            if let mic = self.contextPool.media.getLocalDevices(deviceType: .mic).first {
                self.contextPool.media.openLocalDevice(device: mic)
            }
        } fail: { [weak self] error in
            AgoraLoading.hide()
            self?.contextPool.room.leaveRoom()
        }
    }
    
    public override func didClickCtrlMaskView() {
        toolsView.deselectAll()
        handsUpViewController.deselect()
        brushToolsViewController.button.isSelected = false
    }
}

extension AgoraSmallUIManager: AgoraEduMonitorHandler {
    public func onLocalConnectionUpdated(state: AgoraEduContextConnectionState) {
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
    public func onLocalUserKickedOut() {
        AgoraAlert()
            .setTitle(AgoraKitLocalizedString("KickOutNoticeText"))
            .setMessage(AgoraKitLocalizedString("KickOutText"))
            .addAction(action: AgoraAlertAction(title: AgoraKitLocalizedString("SureText"), action: {
                self.contextPool.room.leaveRoom()
            }))
            .show(in: self)
    }
}
// MARK: - HandsUpViewControllerDelegate
extension AgoraSmallUIManager: AgoraHandsUpUIControllerDelegate {
    func onShowHandsUpList(_ view: UIView) {
        toolsView.deselectAll()
        brushToolsViewController.button.isSelected = false
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
        brushToolsViewController.button.isSelected = false
        switch tool {
        case .setting:
            ctrlView = settingViewController.view
            ctrlView?.mas_makeConstraints { make in
                make?.width.equalTo()(201)
                make?.height.equalTo()(220)
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
            ctrlView = chatController.view
            ctrlView?.mas_remakeConstraints { make in
                make?.right.equalTo()(toolsView.mas_left)?.offset()(-7)
                make?.centerY.equalTo()(toolsView)
                make?.width.equalTo()(200)
                make?.height.equalTo()(287)
            }
        default: break
        }
    }
    
    func toolsViewDidDeselectTool(_ tool: AgoraRoomToolstView.AgoraRoomToolType) {
        ctrlView = nil
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
    func onShowBrushTools(isShow: Bool) {
        if isShow {
            toolsView.deselectAll()
            handsUpViewController.deselect()
            ctrlView = brushToolsViewController.view
            ctrlView?.mas_makeConstraints { make in
                make?.right.equalTo()(brushToolsViewController.button.mas_left)?.offset()(-7)
                make?.bottom.equalTo()(brushToolsViewController.button)?.offset()(-10)
            }
        } else {
            ctrlView = nil
        }
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
        
        brushToolsViewController.button.isHidden = !permission
    }
}

// MARK: - Creations
private extension AgoraSmallUIManager {
    func createViews() {
        stateController = AgoraRoomStateUIController(context: contextPool)
        addChild(stateController)
        contentView.addSubview(stateController.view)
        
        renderController = AgoraMembersHorizeRenderUIController(context: contextPool)
        addChild(renderController)
        contentView.addSubview(renderController.view)
        
        boardController = AgoraBoardUIController(context: contextPool)
        boardController.view.layer.cornerRadius = AgoraFit.scale(2)
        boardController.view.borderWidth = 1
        boardController.view.borderColor = UIColor(hex: 0xECECF1)
        boardController.view.clipsToBounds = true
        addChild(boardController)
        contentView.addSubview(boardController.view)
        
        contentView.addSubview(brushToolsViewController.button)
        
        toolsView = AgoraRoomToolstView(frame: view.bounds)
        toolsView.delegate = self
        toolsView.tools = [.setting, .nameRoll, .message]
        contentView.addSubview(toolsView)
        
        contentView.addSubview(handsUpViewController.view)
    }
    
    func createConstrains() {
        stateController.view.mas_makeConstraints { make in
            make?.top.left().right().equalTo()(0)
            make?.height.equalTo()(AgoraFit.scale(14))
        }
        renderController.view.mas_makeConstraints { make in
            make?.left.right().equalTo()(0)
            make?.top.equalTo()(stateController.view.mas_bottom)?.offset()(AgoraFit.scale(1))
            make?.height.equalTo()(AgoraFit.scale(52))
        }
        boardController.view.mas_makeConstraints { make in
            make?.top.equalTo()(renderController.view.mas_bottom)?.offset()(AgoraFit.scale(1))
            make?.left.right().bottom().equalTo()(0)
        }
        brushToolsViewController.button.mas_makeConstraints { make in
            make?.right.equalTo()(-9)
            make?.bottom.equalTo()(-14)
            make?.width.height().equalTo()(AgoraFit.scale(36))
        }
        toolsView.mas_makeConstraints { make in
            make?.right.equalTo()(brushToolsViewController.button)
            make?.centerY.equalTo()(toolsView.superview)
        }
        handsUpViewController.view.mas_makeConstraints { make in
            make?.width.height().equalTo()(AgoraFit.scale(36))
            make?.centerX.equalTo()(toolsView)
            make?.top.equalTo()(toolsView.mas_bottom)?.offset()(12)
        }
    }
    
    func createChatController() {
        chatController = AgoraChatUIController()
        chatController.contextPool = contextPool
    }
}

// MARK: - AgoraSettingUIControllerDelegate
extension AgoraSmallUIManager: AgoraSettingUIControllerDelegate {
    func settingUIControllerDidPressedLeaveRoom(controller: AgoraSettingUIController) {
        exit(reason: .normal)
    }
}
