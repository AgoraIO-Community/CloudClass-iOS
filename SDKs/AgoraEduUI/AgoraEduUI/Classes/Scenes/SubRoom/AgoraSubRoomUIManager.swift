//
//  AgoraSubRoomUIManager.swift
//  AgoraEduUI
//
//  Created by DoubleCircle on 2022/3/20.
//

import AgoraUIBaseViews
import AgoraEduContext
import AudioToolbox
import AgoraWidget

@objc public protocol AgoraEduUISubManagerCallBack: NSObjectProtocol {
    func subNeedExitAllRooms(reason: AgoraClassRoomExitReason)
}
/// 房间控制器:
/// 用以处理全局状态和子控制器之间的交互关系
@objc public class AgoraSubRoomUIManager: AgoraEduUIManager {
    /** 课堂状态 控制器（仅教师端）*/
    private lazy var classStateController: AgoraClassStateUIController = {
        return AgoraClassStateUIController(context: contextPool,
                                           delegate: self)
    }()
    
    /** 云盘 控制器（仅教师端）*/
    private lazy var cloudController: AgoraCloudUIController = {
        let vc = AgoraCloudUIController(context: contextPool)
        return vc
    }()
    
    /** 设置界面 控制器*/
    private lazy var settingViewController: AgoraSettingUIController = {
        let vc = AgoraSettingUIController(context: contextPool,
                                          subRoom: subRoom)
        vc.roomDelegate = self
        self.addChild(vc)
        return vc
    }()
    
    /** 举手列表 控制器*/
    private lazy var handsListController: AgoraHandsListUIController = {
        let vc = AgoraHandsListUIController(context: contextPool,
                                            subRoom: subRoom)
        vc.delegate = self
        return vc
    }()
    
    /** 视窗菜单 控制器（仅教师端）*/
    private lazy var renderMenuController: AgoraRenderMenuUIController = {
        let vc = AgoraRenderMenuUIController(context: contextPool,
                                             subRoom: subRoom)
        vc.delegate = self
        return vc
    }()
    
    /** 工具栏*/
    private var toolBarController: AgoraToolBarUIController!
    
    /** 房间状态 控制器*/
    private var stateController: AgoraRoomStateUIController!
    
    /** 全局状态 控制器（自身不包含UI）*/
    private var globalController: AgoraRoomGlobalUIController!
   
    /** 远程视窗渲染 控制器*/
    private var renderController: AgoraSmallMembersUIController!
    
    /** 白板的渲染 控制器*/
    private var boardController: AgoraBoardUIController!
  
    /** 花名册 控制器*/
    private var nameRollController: AgoraUserListUIController!
  
    /** 工具集合 控制器*/
    private var toolCollectionController: AgoraToolCollectionUIController!
    
    /** 白板翻页 控制器*/
    private var boardPageController: AgoraBoardPageUIController!
    
    /** 聊天窗口 控制器*/
    private var chatController: AgoraChatUIController!
    
    /** 教具 控制器*/
    private var classToolsController: AgoraClassToolsViewController!
    /** 大窗 控制器*/
    private var windowController: AgoraWindowUIController!
        
    private weak var mainDelegate: AgoraEduUISubManagerCallBack?
    
    private var subRoom: AgoraEduSubRoomContext
    
    deinit {
        print("\(#function): \(self.classForCoder)")
    }
    
    init(contextPool: AgoraEduContextPool,
         subRoom: AgoraEduSubRoomContext,
         subDelegate: AgoraEduUIManagerCallBack?,
         mainDelegate: AgoraEduUISubManagerCallBack?) {
        self.subRoom = subRoom
        self.mainDelegate = mainDelegate
        super.init(contextPool: contextPool,
                   delegate: subDelegate)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    public override func viewDidLoad() {
        super.viewDidLoad()
        createViews()
        createConstraint()
        updateRenderCollectionLayout()
        
        AgoraLoading.hide()
        AgoraLoading.loading()
        
        subRoom.joinSubRoom { [weak self] in
            AgoraLoading.hide()
            guard let `self` = self else {
                return
            }
            
            if self.subRoom.user.getLocalUserInfo().userRole == .teacher {
                self.contextPool.media.openLocalDevice(systemDevice: .frontCamera)
                self.contextPool.media.openLocalDevice(systemDevice: .mic)
            }
        } failure: { [weak self] error in
            AgoraLoading.hide()
            self?.exitClassRoom(reason: .normal,
                                roomType: .sub)
        }
    }
    
    public override func didClickCtrlMaskView() {
        super.didClickCtrlMaskView()
        toolBarController.deselectAll()
    }
    
    @objc public override func exitClassRoom(reason: AgoraClassRoomExitReason,
                                             roomType: AgoraClassRoomExitRoomType) {
        switch roomType {
        case .main:
            self.contextPool.room.leaveRoom()
            
            self.dismiss(animated: true) { [weak self] in
                guard let `self` = self else {
                    return
                }
                
                self.mainDelegate?.subNeedExitAllRooms(reason: reason)
            }
        case .sub:
            let roomId = subRoom.getSubRoomInfo().subRoomUuid
            let userId = subRoom.user.getLocalUserInfo().userUuid
            contextPool.group.removeUserListFromSubRoom(userList: [userId],
                                                        subRoomUuid: roomId,
                                                        success: nil,
                                                        failure: nil)
        }
    }
    
    func dismiss(reason: AgoraClassRoomExitReason,
                 animated flag: Bool,
                 completion: (() -> Void)? = nil) {
        chatController?.viewWillInactive()
        subRoom.leaveSubRoom()
        
        dismiss(animated: flag) { [weak self] in
            guard let `self` = self else {
                return
            }
            
            self.delegate?.manager(self,
                                   didExit: reason)
            
            completion?()
        }
    }
}

// MARK: - AgoraToolBarDelegate
extension AgoraSubRoomUIManager: AgoraToolBarDelegate {
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
            if handsListController.dataSource.count > 0 {
                handsListController.view.frame = CGRect(origin: .zero,
                                                         size: handsListController.suggestSize)
                ctrlView = handsListController.view
            }
        case .help:
            if teacherInLocalSubRoom() {
                AgoraToast.toast(msg: "fcr_group_teacher_exist_hint".agedu_localized(),
                                 type: .warning)
            } else if let userList = contextPool.user.getUserList(role: .teacher),
                      let teacherUserId = userList.first?.userUuid {
                let roomId = subRoom.getSubRoomInfo().subRoomUuid
                
                contextPool.group.inviteUserListToSubRoom(userList: [teacherUserId],
                                                          subRoomUuid: roomId,
                                                          success: nil,
                                                          failure: nil)
            }
            break
        default:
            break
        }
        ctrlViewAnimationFromView(selectView)
    }
    
    func toolsViewDidDeselectTool(tool: AgoraToolBarUIController.ItemType) {
        ctrlView = nil
    }
}

// MARK: - AgoraWindowUIControllerDelegate
extension AgoraSubRoomUIManager: AgoraWindowUIControllerDelegate {
    func startSpreadForUser(with userId: String) -> UIView? {
        self.renderController.setRenderEnable(with: userId,
                                              rendEnable: false)
        return self.renderController.getRenderViewForUser(with: userId)
    }
    
    func willStopSpreadForUser(with userId: String) -> UIView? {
        return self.renderController.getRenderViewForUser(with: userId)
    }
    
    func didStopSpreadForUser(with userId: String) {
        self.renderController.setRenderEnable(with: userId,
                                              rendEnable: true)
    }
}

// MARK: - AgoraToolCollectionUIControllerDelegate
extension AgoraSubRoomUIManager: AgoraToolCollectionUIControllerDelegate {
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
    
    func toolCollectionDidSelectCell(view: UIView) {
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
}
// MARK: - AgoraChatUIControllerDelegate
extension AgoraSubRoomUIManager: AgoraHandsListUIControllerDelegate {
    func updateHandsListRedLabel(_ count: Int) {
        if count == 0,
           ctrlView == handsListController.view {
            ctrlView = nil
        }
        toolBarController.updateHandsListCount(count)
    }
}

// MARK: - AgoraChatUIControllerDelegate
extension AgoraSubRoomUIManager: AgoraChatUIControllerDelegate {
    func updateChatRedDot(isShow: Bool) {
        toolBarController.updateChatRedDot(isShow: isShow)
    }
}

// MARK: - AgoraRenderUIControllerDelegate
extension AgoraSubRoomUIManager: AgoraRenderUIControllerDelegate {
    func onClickMemberAt(view: UIView,
                         UUID: String) {
        guard subRoom.user.getLocalUserInfo().userRole == .teacher else {
            return
        }
        
        var role = AgoraEduContextUserRole.student
        if let teacehr = subRoom.user.getUserList(role: .teacher)?.first,
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
                make?.top.equalTo()(view.mas_bottom)?.offset()(1)
                make?.centerX.equalTo()(view.mas_centerX)
                make?.height.equalTo()(30)
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
    }
}

// MARK: - AgoraRenderMenuUIControllerDelegate
extension AgoraSubRoomUIManager: AgoraRenderMenuUIControllerDelegate {
    func onMenuUserLeft() {
        renderMenuController.dismissView()
        renderMenuController.view.isHidden = true
    }
}

// MARK: - AgoraClassStateUIControllerDelegate
extension AgoraSubRoomUIManager: AgoraClassStateUIControllerDelegate {
    func onShowStartClass() {
        guard subRoom.user.getLocalUserInfo().userRole == .teacher else {
            return
        }
        contentView.addSubview(classStateController.view)
        
        classStateController.view.mas_makeConstraints { make in
            make?.left.equalTo()(boardPageController.view.mas_right)?.offset()(15)
            make?.bottom.equalTo()(boardPageController.view.mas_bottom)
            make?.size.equalTo()(classStateController.suggestSize)
        }
    }
}

// MARK: - Creations
private extension AgoraSubRoomUIManager {
    func createViews() {
        stateController = AgoraRoomStateUIController(context: contextPool,
                                                     subRoom: subRoom)
        addChild(stateController)
        contentView.addSubview(stateController.view)
        
        globalController = AgoraRoomGlobalUIController(context: contextPool,
                                                       delegate: nil,
                                                       subRoom: subRoom)
        globalController.roomDelegate = self
        
        renderController = AgoraSmallMembersUIController(context: contextPool,
                                                         delegate: self,
                                                         containRoles: [.student],
                                                         max: 6,
                                                         subRoom: subRoom)
        addChild(renderController)
        contentView.addSubview(renderController.view)
        
        // 视图层级：白板，大窗，工具
        boardController = AgoraBoardUIController(context: contextPool,
                                                 subRoom: subRoom)
        boardController.view.clipsToBounds = true
        addChild(boardController)
        contentView.addSubview(boardController.view)
        
        windowController = AgoraWindowUIController(context: contextPool,
                                                   subRoom: subRoom)
        windowController.delegate = self
        addChild(windowController)
        contentView.addSubview(windowController.view)
        
        toolBarController = AgoraToolBarUIController(context: contextPool,
                                                     subRoom: subRoom)
        toolBarController.delegate = self
        
        toolCollectionController = AgoraToolCollectionUIController(context: contextPool,
                                                                   delegate: self,
                                                                   subRoom: subRoom)
        contentView.addSubview(toolCollectionController.view)
        addChild(toolCollectionController)
        
        boardPageController = AgoraBoardPageUIController(context: contextPool,
                                                         subRoom: subRoom)
        contentView.addSubview(boardPageController.view)
        addChild(boardPageController)
        
        if subRoom.user.getLocalUserInfo().userRole == .teacher {
            toolBarController.tools = [.setting, .message,.nameRoll, .handsList]
            addChild(renderMenuController)
            contentView.addSubview(renderMenuController.view)
            renderMenuController.view.isHidden = true
            addChild(classStateController)
            addChild(cloudController)
            contentView.addSubview(cloudController.view)
            cloudController.view.isHidden = true
            toolCollectionController.view.isHidden = false
            boardPageController.view.isHidden = false
            
            addChild(handsListController)
        } else {
            toolBarController.tools = [.help, .setting, .message, .nameRoll, .handsup]
            toolCollectionController.view.isHidden = true
            boardPageController.view.isHidden = true
        }
        contentView.addSubview(toolBarController.view)
        
        nameRollController = AgoraUserListUIController(context: contextPool,
                                                       subRoom: subRoom)
        addChild(nameRollController)
        
        classToolsController = AgoraClassToolsViewController(context: contextPool,
                                                             subRoom: subRoom)
        addChild(classToolsController)
        contentView.addSubview(classToolsController.view)
        
        // Chat
        chatController = AgoraChatUIController(context: contextPool,
                                               subRoom: subRoom)
        chatController.hideMiniButton = true
        AgoraUIGroup().color.borderSet(layer: chatController.view.layer)
        chatController.delegate = self
        addChild(chatController)
    }
    
    func createConstraint() {
        stateController.view.mas_makeConstraints { make in
            make?.top.left().right().equalTo()(0)
            make?.height.equalTo()(UIDevice.current.isPad ? 20 : 14)
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
        
        if contextPool.user.getLocalUserInfo().userRole == .teacher {
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
        
        toolCollectionController.view.mas_makeConstraints { make in
            make?.centerX.equalTo()(toolBarController.view.mas_centerX)
            make?.bottom.equalTo()(contentView)?.offset()(UIDevice.current.isPad ? -20 : -15)
            make?.width.height().equalTo()(toolCollectionController.suggestLength)
        }
        
        boardPageController.view.mas_makeConstraints { make in
            make?.left.equalTo()(contentView)?.offset()(UIDevice.current.isPad ? 15 : 12)
            make?.bottom.equalTo()(contentView)?.offset()(UIDevice.current.isPad ? -20 : -15)
            make?.height.equalTo()(UIDevice.current.isPad ? 34 : 32)
            make?.width.equalTo()(168)
        }
        
        classToolsController.view.mas_makeConstraints { make in
            make?.left.right().top().bottom().equalTo()(boardController.view)
        }
        
        windowController.view.mas_makeConstraints { make in
            make?.left.right().top().bottom().equalTo()(boardController.view)
        }
    }
    
    func updateRenderCollectionLayout() {
        view.layoutIfNeeded()
        let kItemGap: CGFloat = AgoraFit.scale(4)
        
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .horizontal
        
        let itemWidth = (renderController.view.bounds.width + kItemGap) / 7.0 - kItemGap
        
        layout.itemSize = CGSize(width: itemWidth,
                                 height: renderController.view.bounds.height)
        layout.minimumLineSpacing = kItemGap
        renderController.updateLayout(layout)
    }
    
    func teacherInLocalSubRoom() -> Bool {
        var flag = false
        guard let subRoomList = contextPool.group.getSubRoomList(),
              let teacherId = contextPool.user.getUserList(role: .teacher)?.first?.userUuid else {
            return flag
        }
        let localUserId = contextPool.user.getLocalUserInfo().userUuid
        for item in subRoomList {
            if let userList = contextPool.group.getUserListFromSubRoom(subRoomUuid: item.subRoomUuid),
               userList.contains([localUserId,teacherId]) {
                flag = true
                break
            }
        }
        return flag
    }
}
