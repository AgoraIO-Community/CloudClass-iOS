//
//  AgoraEduUI+Small.swift
//  AgoraEduUI
//
//  Created by HeZhengQing on 2021/4/16.
//

import AgoraUIBaseViews
import AgoraEduContext
import AudioToolbox
import AgoraWidget

/// 房间控制器:
/// 用以处理全局状态和子控制器之间的交互关系
@objc public class AkSmallUIManager: AgoraEduUIManager {
    private let roomType: AgoraEduContextRoomType = .small
    /** 工具栏*/
    private var toolBarController: AgoraToolBarUIController!
    /** 房间状态 控制器*/
    private var stateController: AkRoomStateUIController!
    /** 远程视窗渲染 控制器*/
    private var renderController: AkMembersHorizeRenderUIController!
    /** 白板的渲染 控制器*/
    private var boardController: AkBoardUIController!
    /** 云盘 控制器（仅教师端）*/
    private lazy var cloudController: AgoraCloudUIController = {
        let vc = AgoraCloudUIController(context: contextPool)
        return vc
    }()
    /** 花名册 控制器*/
    private var nameRollController: AgoraUserListUIController!
    /** 屏幕分享 控制器*/
    private var screenSharingController: AgoraScreenSharingUIController!
    /** 视窗菜单 控制器（仅教师端）*/
    private lazy var renderMenuController: AgoraRenderMenuUIController = {
        let vc = AgoraRenderMenuUIController(context: contextPool)
        vc.delegate = self
        return vc
    }()
    /** 工具集合 控制器*/
    private var toolCollectionController: AgoraToolCollectionUIController!
    /** 白板翻页 控制器*/
    private var boardPageController: AgoraBoardPageUIController!
    /** 聊天窗口 控制器*/
    private var chatController: AgoraChatUIController!
    /** 设置界面 控制器*/
    private lazy var settingViewController: AgoraSettingUIController = {
        let vc = AgoraSettingUIController(context: contextPool)
        vc.roomDelegate = self
        self.addChild(vc)
        return vc
    }()
    /** 举手列表 控制器*/
    private lazy var handsListController: AgoraHandsListUIController = {
        let vc = AgoraHandsListUIController(context: contextPool)
        vc.delegate = self
        return vc
    }()
    /** 教具 控制器*/
    private var classToolsController: AgoraClassToolsViewController!
    
    private var isJoinedRoom = false
        
    deinit {
        print("\(#function): \(self.classForCoder)")
    }
    
    public override func viewDidLoad() {
        super.viewDidLoad()
        
        self.createViews()
        self.createConstraint()
        
        contextPool.room.joinRoom { [weak self] in
            AgoraLoading.hide()
            guard let `self` = self else {
                return
            }
            self.isJoinedRoom = true
            self.createChatController()
            if self.contextPool.user.getLocalUserInfo().userRole == .teacher {
                self.contextPool.media.openLocalDevice(systemDevice: .frontCamera)
                self.contextPool.media.openLocalDevice(systemDevice: .mic)
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
        toolBarController.deselectAll()
    }
}

// MARK: - AgoraToolBarDelegate
extension AkSmallUIManager: AgoraToolBarDelegate {
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
        case .handsList:
            handsListController.view.frame = CGRect(origin: .zero,
                                                    size: handsListController.suggestSize)
            ctrlView = handsListController.view
        default:
            break
        }
        ctrlViewAnimationFromView(selectView)
    }
    
    func toolsViewDidDeselectTool(tool: AgoraToolBarUIController.ItemType) {
        ctrlView = nil
    }
}

// MARK: - AgoraToolCollectionUIControllerDelegate
extension AkSmallUIManager: AgoraToolCollectionUIControllerDelegate {
    func toolCollectionDidSelectCell(view: UIView) {
        toolBarController.deselectAll()
        ctrlView = view
        ctrlViewAnimationFromView(toolCollectionController.view)
    }
    
    func toolCollectionCellNeedSpread(_ spread: Bool) {
        if spread {
            toolCollectionController.view.mas_remakeConstraints { make in
                make?.centerX.equalTo()(self.toolBarController.view.mas_centerX)
                make?.bottom.equalTo()(contentView)?.offset()(AgoraFit.scale(-15))
                make?.width.equalTo()(AgoraFit.scale(32))
                make?.height.equalTo()(AgoraFit.scale(80))
            }
        } else {
            toolCollectionController.view.mas_remakeConstraints { make in
                make?.centerX.equalTo()(self.toolBarController.view.mas_centerX)
                make?.bottom.equalTo()(contentView)?.offset()(AgoraFit.scale(-15))
                make?.width.equalTo()(AgoraFit.scale(32))
                make?.height.equalTo()(AgoraFit.scale(32))
            }
        }
    }
    
    func toolCollectionDidDeselectCell() {
        ctrlView = nil
    }
    
    func toolCollectionDidSelectTeachingAid(type: AgoraTeachingAidType) {
        // 选择插件（答题器、投票器...）
        ctrlView = nil
        switch type {
        case .cloudStorage:
            if cloudController.view.isHidden {
                cloudController.view.mas_makeConstraints { make in
                    make?.left.right().top().bottom().equalTo()(boardController.view)
                }
            }
            cloudController.view.isHidden = !cloudController.view.isHidden
        case .vote:
            break
        case .countDown:
            break
        case .answerSheet:
            break
        default:
            break
        }
    }
}
// MARK: - AgoraChatUIControllerDelegate
extension AkSmallUIManager: AgoraHandsListUIControllerDelegate {
    func updateHandsListRedLabel(_ count: Int) {
        toolBarController.updateHandsListCount(count)
    }
}

// MARK: - AgoraChatUIControllerDelegate
extension AkSmallUIManager: AgoraChatUIControllerDelegate {
    func updateChatRedDot(isShow: Bool) {
        toolBarController.updateChatRedDot(isShow: isShow)
    }
}

// MARK: - AgoraRenderUIControllerDelegate
extension AkSmallUIManager: AgoraRenderUIControllerDelegate {
    func onClickMemberAt(view: UIView,
                         UUID: String) {
        guard contextPool.user.getLocalUserInfo().userRole == .teacher else {
            return
        }
        
        var role = AgoraEduContextUserRole.student
        if let teacehr = contextPool.user.getUserList(role: .teacher)?.first,
           teacehr.userUuid == UUID {
            role = .teacher
        }
        
        if let menuId = renderMenuController.userId,
           menuId == UUID {
            // 若当前已存在menu，且当前menu的userId为点击的userId，menu切换状态
            renderMenuController.dismissView()
        } else {
            // 1. 当前menu的userId不为点击的userId，切换用户
            // 2. 当前不存在menu，显示
            renderMenuController.show(roomType: .small,
                                      userUuid: UUID,
                                      showRoleType: role)
            renderMenuController.view.mas_remakeConstraints { make in
                make?.top.equalTo()(view.mas_bottom)?.offset()(AgoraFit.scale(1))
                make?.centerX.equalTo()(view.mas_centerX)
                make?.height.equalTo()(AgoraFit.scale(36))
                make?.width.equalTo()(renderMenuController.menuWidth)
            }
        }
    }
    
    func onRequestSpread(firstOpen: Bool,
                         userId: String,
                         streamId: String,
                         fromView: UIView,
                         xaxis: CGFloat,
                         yaxis: CGFloat,
                         width: CGFloat,
                         height: CGFloat) {
        return
    }
}

// MARK: - AgoraRenderMenuUIControllerDelegate
extension AkSmallUIManager: AgoraRenderMenuUIControllerDelegate {
    func onMenuUserLeft() {
        renderMenuController.dismissView()
        renderMenuController.view.isHidden = true
    }
}

// MARK: - AgoraBoardPageUIControllerDelegate
extension AkSmallUIManager: AgoraBoardPageUIControllerDelegate {
    func boardPageUINeedMove(coursewareMin: Bool) {
        UIView.animate(withDuration: TimeInterval.agora_animation,
                       delay: 0,
                       options: .curveEaseInOut,
                       animations: { [weak self] in
            self?.boardPageController.view.transform = CGAffineTransform(translationX: coursewareMin ? 32 : 0,
                                                                         y: 0)
        }, completion: nil)
    }
}

// MARK: - Creations
private extension AkSmallUIManager {
    func createViews() {
        stateController = AkRoomStateUIController(context: contextPool)
        stateController.roomDelegate = self
        addChild(stateController)
        contentView.addSubview(stateController.view)
        
        renderController = AkMembersHorizeRenderUIController(context: contextPool)
        renderController.delegate = self
        addChild(renderController)
        contentView.addSubview(renderController.view)
        
        boardController = AkBoardUIController(context: contextPool)
        addChild(boardController)
        contentView.addSubview(boardController.view)
        
        screenSharingController = AgoraScreenSharingUIController(context: contextPool)
        addChild(screenSharingController)
        contentView.addSubview(screenSharingController.view)
        
        toolBarController = AgoraToolBarUIController(context: contextPool)
        toolBarController.delegate = self
        
        toolCollectionController = AgoraToolCollectionUIController(context: contextPool,
                                                                   delegate: self)
        contentView.addSubview(toolCollectionController.view)
        addChild(toolCollectionController)
        
        boardPageController = AgoraBoardPageUIController(context: contextPool,
                                                         delegate: self)
        contentView.addSubview(boardPageController.view)
        addChild(boardPageController)
        
        if contextPool.user.getLocalUserInfo().userRole == .teacher {
            toolBarController.tools = [.setting, .nameRoll, .message, .handsList]
            addChild(renderMenuController)
            contentView.addSubview(renderMenuController.view)
            renderMenuController.view.isHidden = true
            
            addChild(cloudController)
            contentView.addSubview(cloudController.view)
            cloudController.view.isHidden = true
            toolCollectionController.view.isHidden = false
            boardPageController.view.isHidden = false
            
            addChild(handsListController)
        } else {
            toolBarController.tools = [.setting, .nameRoll, .message, .handsup]
            toolCollectionController.view.isHidden = true
            boardPageController.view.isHidden = true
        }
        contentView.addSubview(toolBarController.view)
        
        nameRollController = AgoraUserListUIController(context: contextPool)
        addChild(nameRollController)
        
        classToolsController = AgoraClassToolsViewController(context: contextPool)
        addChild(classToolsController)
        contentView.addSubview(classToolsController.view)
    }
    
    func createConstraint() {
        stateController.view.mas_makeConstraints { make in
            make?.top.left().right().equalTo()(0)
            make?.height.equalTo()(AgoraFit.scale(14))
        }
        let width = max(UIScreen.main.bounds.width,
                        UIScreen.main.bounds.height)
        let height = min(UIScreen.main.bounds.width,
                         UIScreen.main.bounds.height)
        
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
            make?.right.equalTo()(contentView)?.offset()(-6)
            make?.top.equalTo()(self.boardController.mas_topLayoutGuideTop)?.offset()(AgoraFit.scale(32))
        }
        toolCollectionController.view.mas_makeConstraints { make in
            make?.centerX.equalTo()(self.toolBarController.view.mas_centerX)
            make?.bottom.equalTo()(contentView)?.offset()(AgoraFit.scale(-15))
            make?.width.equalTo()(AgoraFit.scale(32))
            make?.height.equalTo()(AgoraFit.scale(80))
        }
        boardPageController.view.mas_makeConstraints { make in
            make?.left.equalTo()(contentView)?.offset()(AgoraFit.scale(12))
            make?.bottom.equalTo()(contentView)?.offset()(AgoraFit.scale(-15))
            make?.height.equalTo()(UIDevice.current.isPad ? 34 : 32)
            make?.width.equalTo()(168)
        }
        classToolsController.view.mas_makeConstraints { make in
            make?.left.right().top().bottom().equalTo()(boardController.view)
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
