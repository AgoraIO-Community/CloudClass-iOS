//
//  AgoraEduUI+Lecture.swift
//  AgoraEduSDK
//
//  Created by Cavan on 2021/4/22.
//

import AgoraUIBaseViews
import AgoraEduContext
import AudioToolbox
import AgoraWidget

/// 房间控制器:
/// 用以处理全局状态和子控制器之间的交互关系
@objc public class AgoraLectureUIManager: AgoraEduUIManager {
    /** 花名册 控制器 （教师端）*/
    private lazy var nameRollController: AgoraUserListUIController = {
        return AgoraUserListUIController(context: contextPool)
    }()
    
    /** 设置界面 控制器*/
    private lazy var settingViewController: AgoraSettingUIController = {
        let vc = AgoraSettingUIController(context: contextPool)
        vc.roomDelegate = self
        self.addChild(vc)
        return vc
    }()
    /** 举手列表 控制器（仅教师端）*/
    private lazy var handsListController: AgoraHandsListUIController = {
        let vc = AgoraHandsListUIController(context: contextPool)
        vc.delegate = self
        self.addChild(vc)
        return vc
    }()
    /** 视窗菜单 控制器（仅教师端）*/
    private lazy var renderMenuController: AgoraRenderMenuUIController = {
        let vc = AgoraRenderMenuUIController(context: contextPool)
        vc.delegate = self
        return vc
    }()
    
    /** 工具栏*/
    private var toolBarController: AgoraToolBarUIController!
    /** 房间状态 控制器*/
    private var stateController: AgoraRoomStateUIController!
    /** 全局状态 控制器（自身不包含UI）*/
    private var globalController: AgoraRoomGlobalUIController!
    /** 课堂状态 控制器（仅教师端）*/
    private lazy var classStateController: AgoraClassStateUIController = {
        return AgoraClassStateUIController(context: contextPool,
                                           delegate: self)
    }()
    /** 老师渲染 控制器*/
    private var teacherRenderController: AgoraRenderMembersUIController!
    /** 白板 控制器*/
    private var boardController: AgoraBoardUIController!
    
    /** 工具集合 控制器（观众端没有）*/
    private var toolCollectionController: AgoraToolCollectionUIController!
    /** 白板翻页 控制器（观众端没有）*/
    private var boardPageController: AgoraBoardPageUIController!
    /** 大窗 控制器*/
    private var windowController: AgoraWindowUIController!
    /** 云盘 控制器（仅教师端）*/
    private lazy var cloudController: AgoraCloudUIController = {
        let vc = AgoraCloudUIController(context: contextPool)
        return vc
    }()
    /** 教具 控制器*/
    private var classToolsController: AgoraClassToolsViewController!
    /** 聊天窗口 控制器*/
    private var chatController: AgoraChatUIController!
    
    
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
        super.didClickCtrlMaskView()
        toolBarController.deselectAll()
    }
}

// MARK: - AgoraWindowUIControllerDelegate
extension AgoraLectureUIManager: AgoraWindowUIControllerDelegate {
    func startSpreadForUser(with userId: String) -> UIView? {
        guard userId == contextPool.user.getUserList(role: .teacher)?.first?.userUuid else {
            return nil
        }
        self.teacherRenderController.setRenderEnable(with: userId,
                                                     rendEnable: false)
        return self.teacherRenderController.getRenderViewForUser(with: userId)
    }
    
    func willStopSpreadForUser(with userId: String) -> UIView? {
        guard userId == contextPool.user.getUserList(role: .teacher)?.first?.userUuid else {
            return nil
        }
        return self.teacherRenderController.getRenderViewForUser(with: userId)
    }
    
    func didStopSpreadForUser(with userId: String) {
        guard userId == contextPool.user.getUserList(role: .teacher)?.first?.userUuid else {
            return
        }
        self.teacherRenderController.setRenderEnable(with: userId,
                                                     rendEnable: true)
    }
}

// MARK: - AgoraToolBarDelegate
extension AgoraLectureUIManager: AgoraToolBarDelegate {
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
        case .handsList:
            if handsListController.dataSource.count > 0 {
                handsListController.view.frame = CGRect(origin: .zero,
                                                         size: handsListController.suggestSize)
                ctrlView = handsListController.view
            }
        default:
            break
        }
        ctrlViewAnimationFromView(selectView)
    }
    
    func toolsViewDidDeselectTool(tool: AgoraToolBarUIController.ItemType) {
        ctrlView = nil
    }
}

// MARK: - AgoraRenderMenuUIControllerDelegate
extension AgoraLectureUIManager: AgoraRenderMenuUIControllerDelegate {
    func onMenuUserLeft() {
        renderMenuController.dismissView()
        renderMenuController.view.isHidden = true
    }
}

// MARK: - AgoraRenderUIControllerDelegate
extension AgoraLectureUIManager: AgoraRenderUIControllerDelegate {
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
            renderMenuController.show(roomType: .lecture,
                                      userUuid: UUID,
                                      showRoleType: role)
            renderMenuController.view.mas_remakeConstraints { make in
                make?.top.equalTo()(view.mas_bottom)?.offset()(1)
                make?.centerX.equalTo()(view.mas_centerX)
                make?.height.equalTo()(30)
                make?.width.equalTo()(renderMenuController.menuWidth)
            }
        }
    }
}

// MARK: - AgoraChatUIControllerDelegate
extension AgoraLectureUIManager: AgoraHandsListUIControllerDelegate {
    func updateHandsListRedLabel(_ count: Int) {
        if count == 0,
           ctrlView == handsListController.view {
            ctrlView = nil
        }
        toolBarController.updateHandsListCount(count)
    }
}

// MARK: - AgoraToolCollectionUIControllerDelegate
extension AgoraLectureUIManager: AgoraToolCollectionUIControllerDelegate {
    func toolCollectionDidSelectCell(view: UIView) {
        renderMenuController.dismissView()
        toolBarController.deselectAll()
        ctrlView = view
        ctrlViewAnimationFromView(toolCollectionController.view)
    }
    
    func toolCollectionCellNeedSpread(_ spread: Bool) {
        if spread {
            toolCollectionController.view.mas_remakeConstraints { make in
                make?.centerX.equalTo()(self.toolBarController.view.mas_centerX)
                make?.bottom.equalTo()(contentView)?.offset()(UIDevice.current.isPad ? -20 : -15)
                make?.width.equalTo()(toolCollectionController.suggestLength)
                make?.height.equalTo()(toolCollectionController.suggestSpreadHeight)
            }
        } else {
            toolCollectionController.view.mas_remakeConstraints { make in
                make?.centerX.equalTo()(self.toolBarController.view.mas_centerX)
                make?.bottom.equalTo()(contentView)?.offset()(UIDevice.current.isPad ? -20 : -15)
                make?.width.height().equalTo()(toolCollectionController.suggestLength)
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
    
    func toolCollectionDidChangeAppearance(_ appear: Bool) {
        UIView.animate(withDuration: TimeInterval.agora_animation,
                       delay: 0,
                       options: .curveEaseInOut,
                       animations: { [weak self] in
                        guard let `self` = self else {
                            return
                        }
                        
                        if appear {
                            self.toolBarController.view.mas_remakeConstraints { make in
                                make?.right.equalTo()(self.boardController.view.mas_right)?.offset()(UIDevice.current.isPad ? -15 : -12)
                                make?.bottom.equalTo()(self.toolCollectionController.view.mas_top)?.offset()(UIDevice.current.isPad ? -15 : -12)
                                make?.width.equalTo()(self.toolBarController.suggestSize.width)
                                make?.height.equalTo()(self.toolBarController.suggestSize.height)
                            }
                        } else {
                            self.toolBarController.view.mas_remakeConstraints { make in
                                make?.right.equalTo()(self.boardController.view.mas_right)?.offset()(UIDevice.current.isPad ? -15 : -12)
                                make?.bottom.equalTo()(self.boardController.mas_bottomLayoutGuideBottom)?.offset()(UIDevice.current.isPad ? -20 : -15)
                                make?.width.equalTo()(self.toolBarController.suggestSize.width)
                                make?.height.equalTo()(self.toolBarController.suggestSize.height)
                            }
                        }
                       }, completion: nil)

    }
}

// MARK: - AgoraClassStateUIControllerDelegate
extension AgoraLectureUIManager: AgoraClassStateUIControllerDelegate {
    func onShowStartClass() {
        guard contextPool.user.getLocalUserInfo().userRole == .teacher else {
            return
        }
        contentView.addSubview(classStateController.view)
        
        classStateController.view.mas_makeConstraints { make in
            make?.left.equalTo()(boardPageController.view.mas_right)?.offset()(UIDevice.current.isPad ? 15 : 12)
            make?.bottom.equalTo()(boardPageController.view.mas_bottom)
            make?.size.equalTo()(classStateController.suggestSize)
        }
    }
}

// MARK: - Creations
private extension AgoraLectureUIManager {
    func createViews() {
        let userRole = contextPool.user.getLocalUserInfo().userRole
        
        stateController = AgoraRoomStateUIController(context: contextPool)
        addChild(stateController)
        contentView.addSubview(stateController.view)
        
        globalController = AgoraRoomGlobalUIController(context: contextPool,
                                                       delegate: nil)
        globalController.roomDelegate = self
        
        teacherRenderController = AgoraRenderMembersUIController(context: contextPool,
                                                                 delegate: self,
                                                                 containRoles: [.teacher],
                                                                 max: 1,
                                                                 dataSource: [AgoraRenderMemberViewModel.defaultNilValue()])
        teacherRenderController.view.layer.cornerRadius = AgoraFit.scale(2)
        teacherRenderController.view.clipsToBounds = true
        addChild(teacherRenderController)
        contentView.addSubview(teacherRenderController.view)
        
        // 视图层级：白板，大窗，工具
        boardController = AgoraBoardUIController(context: contextPool)
        boardController.view.layer.cornerRadius = AgoraFit.scale(2)
        boardController.view.borderWidth = 1
        boardController.view.borderColor = UIColor(hex: 0xECECF1)
        boardController.view.clipsToBounds = true
        addChild(boardController)
        contentView.addSubview(boardController.view)
        
        windowController = AgoraWindowUIController(context: contextPool)
        windowController.delegate = self
        addChild(windowController)
        contentView.addSubview(windowController.view)
        
        toolBarController = AgoraToolBarUIController(context: contextPool)
        toolBarController.delegate = self
        
        classToolsController = AgoraClassToolsViewController(context: contextPool)
        addChild(classToolsController)
        contentView.addSubview(classToolsController.view)

        if userRole == .teacher {
            toolCollectionController = AgoraToolCollectionUIController(context: contextPool,
                                                                       delegate: self)
            contentView.addSubview(toolCollectionController.view)
            addChild(toolCollectionController)
            
            boardPageController = AgoraBoardPageUIController(context: contextPool)
            contentView.addSubview(boardPageController.view)
            addChild(boardPageController)
            
            toolBarController.tools = [.setting, .nameRoll, .handsList]
            addChild(classStateController)
            addChild(handsListController)
            addChild(nameRollController)
            addChild(renderMenuController)
            contentView.addSubview(renderMenuController.view)
            addChild(cloudController)
            contentView.addSubview(cloudController.view)
            
            renderMenuController.view.isHidden = true
            cloudController.view.isHidden = true
            toolCollectionController.view.isHidden = false
            boardPageController.view.isHidden = false
        } else if userRole == .student {
            toolCollectionController = AgoraToolCollectionUIController(context: contextPool,
                                                                       delegate: self)
            contentView.addSubview(toolCollectionController.view)
            addChild(toolCollectionController)
            
            boardPageController = AgoraBoardPageUIController(context: contextPool)
            contentView.addSubview(boardPageController.view)
            addChild(boardPageController)
            
            toolBarController.tools = [.setting, .handsup]
            toolCollectionController.view.isHidden = true
            boardPageController.view.isHidden = true
        } else {
            toolBarController.tools = [.setting]
        }
        contentView.addSubview(toolBarController.view)
        
        chatController = AgoraChatUIController(context: contextPool)
        chatController.hideMiniButton = true
        if contextPool.user.getLocalUserInfo().userRole == .observer {
            chatController.hideInput = true
        }
        addChild(chatController)
        AgoraUIGroup().color.borderSet(layer: chatController.view.layer)
        contentView.addSubview(chatController.view)
        contentView.sendSubviewToBack(chatController.view)
    }
    
    func createConstraint() {
        let userRole = contextPool.user.getLocalUserInfo().userRole

        stateController.view.mas_makeConstraints { make in
            make?.top.left().right().equalTo()(0)
            make?.height.equalTo()(AgoraFit.scale(14))
        }
        boardController.view.mas_makeConstraints { make in
            make?.left.bottom().equalTo()(0)
            make?.width.equalTo()(AgoraFit.scale(465))
            make?.height.equalTo()(AgoraFit.scale(262))
        }
        windowController.view.mas_makeConstraints { make in
            make?.left.right().top().bottom().equalTo()(boardController.view)
        }
        teacherRenderController.view.mas_makeConstraints { make in
            make?.top.equalTo()(stateController.view.mas_bottom)?.offset()(AgoraFit.scale(2))
            make?.left.equalTo()(boardController.view.mas_right)?.offset()(AgoraFit.scale(2))
            make?.right.equalTo()(0)
            make?.height.equalTo()(AgoraFit.scale(112))
        }
        if userRole == .teacher {
            self.toolBarController.view.mas_remakeConstraints { make in
                make?.right.equalTo()(self.boardController.view.mas_right)?.offset()(UIDevice.current.isPad ? -15 : -12)
                make?.bottom.equalTo()(self.toolCollectionController.view.mas_top)?.offset()(UIDevice.current.isPad ? -15 : -12)
                make?.width.equalTo()(self.toolBarController.suggestSize.width)
                make?.height.equalTo()(self.toolBarController.suggestSize.height)
            }
        } else {
            self.toolBarController.view.mas_remakeConstraints { make in
                make?.right.equalTo()(self.boardController.view.mas_right)?.offset()(UIDevice.current.isPad ? -15 : -12)
                make?.bottom.equalTo()(self.boardController.mas_bottomLayoutGuideBottom)?.offset()(UIDevice.current.isPad ? -20 : -15)
                make?.width.equalTo()(self.toolBarController.suggestSize.width)
                make?.height.equalTo()(self.toolBarController.suggestSize.height)
            }
        }
        if userRole != .observer {
            toolCollectionController.view.mas_makeConstraints { make in
                make?.centerX.equalTo()(self.toolBarController.view.mas_centerX)
                make?.bottom.equalTo()(contentView)?.offset()(UIDevice.current.isPad ? -20 : -15)
                make?.width.height().equalTo()(toolCollectionController.suggestLength)
            }
            boardPageController.view.mas_makeConstraints { make in
                make?.left.equalTo()(contentView)?.offset()(UIDevice.current.isPad ? 15 : 12)
                make?.bottom.equalTo()(contentView)?.offset()(UIDevice.current.isPad ? -20 : -15)
                make?.height.equalTo()(UIDevice.current.isPad ? 34 : 32)
                make?.width.equalTo()(168)
            }
        }

        chatController.view.mas_makeConstraints { make in
            make?.top.equalTo()(teacherRenderController.view.mas_bottom)?.offset()(AgoraFit.scale(2))
            make?.left.equalTo()(boardController.view.mas_right)?.offset()(AgoraFit.scale(2))
            make?.right.bottom().equalTo()(0)
        }
        
        classToolsController.view.mas_makeConstraints { make in
            make?.left.right().top().bottom().equalTo()(boardController.view)
        }
    }
}
