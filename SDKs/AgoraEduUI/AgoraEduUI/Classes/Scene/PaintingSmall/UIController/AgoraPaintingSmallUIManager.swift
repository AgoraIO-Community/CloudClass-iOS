//
//  PaintingRoomViewController.swift
//  AgoraEduUI
//
//  Created by HeZhengQing on 2021/9/22.
//

import AgoraUIEduBaseViews
import AgoraUIBaseViews
import AgoraEduContext
import AudioToolbox
import AgoraExtApp
import AgoraWidget

/// 房间控制器:
/// 用以处理全局状态和子控制器之间的交互关系
@objc public class AgoraPaintingSmallUIManager: AgoraEduUIManager {
    private let roomType: AgoraEduContextRoomType = .paintingSmall
    /** 工具栏*/
    private var toolBarController: AgoraToolBarUIController!
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
    private lazy var brushToolsController: AgoraBoardToolsUIController = {
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
        vc.roomDelegate = self
        self.addChild(vc)
        return vc
    }()
    
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
        toolBarController.deselectAll()
    }
}

// MARK: - AgoraToolBarDelegate
extension AgoraPaintingSmallUIManager: AgoraToolBarDelegate {
    func toolsViewDidSelectTool(tool: AgoraToolBarUIController.ItemType,
                                selectView: UIView) {
        switch tool {
        case .setting:
            settingViewController.view.frame = CGRect(origin: .zero,
                                                      size: settingViewController.suggestSize)
            ctrlView = settingViewController.view
        case .nameRoll:
            nameRollController.view.frame = CGRect(origin: .zero,
                                                   size: nameRollController.suggestSize)
            ctrlView = nameRollController.view
        case .message:
            chatController.view.frame = CGRect(origin: .zero,
                                               size: chatController.suggestSize)
            ctrlView = chatController.view
        case .brushTool:
            brushToolsController.view.frame = CGRect(origin: .zero,
                                                     size: brushToolsController.suggestSize)
            ctrlView = brushToolsController.view
        default: break
        }
        ctrlViewAnimationFromView(selectView)
    }
    
    func toolsViewDidDeselectTool(tool: AgoraToolBarUIController.ItemType) {
        ctrlView = nil
    }
}
// MARK: - AgoraChatUIControllerDelegate
extension AgoraPaintingSmallUIManager: AgoraChatUIControllerDelegate {
    func updateChatRedDot(isShow: Bool) {
        toolBarController.updateChatRedDot(isShow: isShow)
    }
}
// MARK: - PaintingToolBoxViewDelegate
extension AgoraPaintingSmallUIManager: AgoraToolBoxUIControllerDelegate {
    func toolBoxDidSelectTool(_ tool: AgoraToolBoxToolType) {
        toolBarController.deselectAll()
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
extension AgoraPaintingSmallUIManager: AgoraBoardToolsUIControllerDelegate {
    
    func didUpdateBrushSetting(image: UIImage?,
                               colorHex: Int) {
        toolBarController.updateBrushButton(image: image,
                                            colorHex: colorHex)
    }
}

// MARK: - Creations
private extension AgoraPaintingSmallUIManager {
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
        
        screenSharingController = AgoraScreenSharingUIController(context: contextPool)
        addChild(screenSharingController)
        contentView.addSubview(screenSharingController.view)
        
        toolBarController = AgoraToolBarUIController(context: contextPool)
        toolBarController.delegate = self
        toolBarController.tools = [.setting, .nameRoll, .message, .handsup, .brushTool]
        view.addSubview(toolBarController.view)
        
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
        toolBarController.view.mas_makeConstraints { make in
            make?.right.equalTo()(contentView)?.offset()(-12)
            make?.bottom.equalTo()(contentView)?.offset()(-15)
        }
    }
    
    func createChatController() {
        chatController = AgoraChatUIController(context: contextPool)
        chatController.hideMiniButton = true
        chatController.view.layer.shadowColor = UIColor(hex: 0x2F4192,
                                                        transparency: 0.15)?.cgColor
        chatController.view.layer.shadowOffset = CGSize(width: 0,
                                                        height: 2)
        chatController.view.layer.shadowOpacity = 1
        chatController.view.layer.shadowRadius = 6
        chatController.delegate = self
        addChild(chatController)
    }
}
