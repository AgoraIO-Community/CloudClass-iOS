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
    private var nameRollController: AgoraUserListUIController!
    /** 屏幕分享 控制器*/
    private var screenSharingController: AgoraScreenSharingUIController!
    /** 画板工具 控制器*/
    private var brushToolsController: AgoraBoardToolsUIController!
    /** 聊天窗口 控制器*/
    private var chatController: AgoraChatUIController!
    /** 设置界面 控制器*/
    private lazy var settingViewController: AgoraSettingUIController = {
        let vc = AgoraSettingUIController(context: contextPool)
        vc.roomDelegate = self
        self.addChild(vc)
        return vc
    }()
    /** 举手 控制器*/
    private var handsUpController: AgoraHandsUpUIController!
    
    private var isJoinedRoom = false
        
    deinit {
        print("\(#function): \(self.classForCoder)")
    }
    
    public override func viewDidLoad() {
        super.viewDidLoad()
        
        self.createViews()
        self.createConstrains()
        
        contextPool.room.joinRoom { [weak self] in
            AgoraLoading.hide()
            guard let `self` = self else {
                return
            }
            self.isJoinedRoom = true
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
        } failure: { [weak self] error in
            AgoraLoading.hide()
            self?.exitClassRoom(reason: .normal)
        }
    }
    
    public override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        if isJoinedRoom == false {
            AgoraLoading.loading()
        }
    }
    
    public override func didClickCtrlMaskView() {
        toolsView.deselectAll()
        handsUpController.deselect()
        brushToolsController.button.isSelected = false
    }
}

// MARK: - HandsUpViewControllerDelegate
extension AgoraSmallUIManager: AgoraHandsUpUIControllerDelegate {
    func onShowHandsUpList(_ view: UIView) {
        toolsView.deselectAll()
        brushToolsController.button.isSelected = false
        ctrlView = view
        view.mas_makeConstraints { make in
            make?.bottom.equalTo()(handsUpController.view)
            make?.width.equalTo()(220)
            make?.height.equalTo()(245)
            make?.right.equalTo()(handsUpController.view.mas_left)?.offset()(-10)
        }
    }
    func onHideHandsUpList(_ view: UIView) {
        ctrlView = nil
    }
}

// MARK: - AgoraToolListViewDelegate
extension AgoraSmallUIManager: AgoraRoomToolsViewDelegate {
    func toolsViewDidSelectTool(_ tool: AgoraRoomToolstView.AgoraRoomToolType) {
        handsUpController.deselect()
        brushToolsController.button.isSelected = false
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
                  let info = extAppInfos.first(where: {$0.appIdentifier == "io.agora.answer"}) else {
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
            handsUpController.deselect()
            ctrlView = brushToolsController.view
            ctrlView?.mas_makeConstraints { make in
                make?.right.equalTo()(brushToolsController.button.mas_left)?.offset()(-7)
                make?.bottom.equalTo()(brushToolsController.button)?.offset()(-10)
            }
        } else {
            ctrlView = nil
        }
    }
}

// MARK: - Creations
private extension AgoraSmallUIManager {
    func createViews() {
        stateController = AgoraRoomStateUIController(context: contextPool)
        stateController.roomDelegate = self
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
        
        brushToolsController = AgoraBoardToolsUIController(context: contextPool)
        brushToolsController.delegate = self
        addChild(brushToolsController)
        view.addSubview(brushToolsController.button)
        
        handsUpController = AgoraHandsUpUIController(context: contextPool)
        handsUpController.delegate = self
        addChild(handsUpController)
        view.addSubview(handsUpController.view)
        
        screenSharingController = AgoraScreenSharingUIController(context: contextPool)
        addChild(screenSharingController)
        contentView.addSubview(screenSharingController.view)
        
        toolsView = AgoraRoomToolstView(frame: view.bounds)
        toolsView.delegate = self
        toolsView.tools = [.setting, .nameRoll, .message]
        contentView.addSubview(toolsView)
        
        nameRollController = AgoraUserListUIController(context: contextPool)
        addChild(nameRollController)
    }
    
    func createConstrains() {
        stateController.view.mas_makeConstraints { make in
            make?.top.left().right().equalTo()(0)
            make?.height.equalTo()(AgoraFit.scale(14))
        }
        boardController.view.mas_makeConstraints { make in
            make?.height.equalTo()(AgoraFit.scale(307))
            make?.left.right().bottom().equalTo()(0)
        }
        renderController.view.mas_makeConstraints { make in
            make?.left.right().equalTo()(0)
            make?.top.equalTo()(stateController.view.mas_bottom)?.offset()(AgoraFit.scale(1))
            make?.bottom.equalTo()(boardController.view.mas_top)?.offset()(AgoraFit.scale(-1))
        }
        screenSharingController.view.mas_makeConstraints { make in
            make?.top.equalTo()(renderController.view.mas_bottom)?.offset()(AgoraFit.scale(1))
            make?.left.right().bottom().equalTo()(0)
        }
        brushToolsController.button.mas_makeConstraints { make in
            make?.right.equalTo()(contentView)?.offset()(AgoraFit.scale(-6))
            make?.bottom.equalTo()(contentView)?.offset()(AgoraFit.scale(-6))
            make?.width.height().equalTo()(36)
        }
        handsUpController.view.mas_makeConstraints { make in
            make?.width.height().equalTo()(36)
            make?.centerX.equalTo()(brushToolsController.button)
            make?.bottom.equalTo()(brushToolsController.button.mas_top)?.offset()(-8)
        }
        toolsView.mas_makeConstraints { make in
            make?.right.equalTo()(brushToolsController.button)
            make?.bottom.equalTo()(handsUpController.view.mas_top)?.offset()(-8)
        }
    }
    
    func createChatController() {
        chatController = AgoraChatUIController(context: contextPool)
        chatController.hideMiniButton = true
        chatController.view.layer.shadowColor = UIColor(rgb: 0x2F4192,
                                                        alpha: 0.15).cgColor
        chatController.view.layer.shadowOffset = CGSize(width: 0,
                                                        height: 2)
        chatController.view.layer.shadowOpacity = 1
        chatController.view.layer.shadowRadius = 6
        addChild(chatController)
    }
}
