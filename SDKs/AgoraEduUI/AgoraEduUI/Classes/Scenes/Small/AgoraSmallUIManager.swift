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
@objc public class AgoraSmallUIManager: AgoraEduUIManager {
    // MARK: - Flat components
    /** 房间状态 控制器*/
    private lazy var stateController = AgoraRoomStateUIController(context: contextPool)
    
    /** 视窗渲染 控制器*/
    private lazy var renderController = FcrSmallWindowRenderUIController(context: contextPool,
                                                                         delegate: self,
                                                                         controllerDataSource: self)
    
    /** 白板的渲染 控制器*/
    private lazy var boardController = AgoraBoardUIController(context: contextPool,
                                                              delegate: self)
    
    /** 白板翻页 控制器（观众端没有）*/
    private lazy var boardPageController = AgoraBoardPageUIController(context: contextPool)
    
    /** 外部链接 控制器*/
    private lazy var webViewController = AgoraWebViewUIController(context: contextPool)
    
    /** 大窗 控制器*/
    private lazy var windowController = FcrStreamWindowUIController(context: contextPool,
                                                                    delegate: self,
                                                                    controllerDataSource: self)
    
    /** 工具栏*/
    private lazy var toolBarController = AgoraToolBarUIController(context: contextPool,
                                                                  delegate: self)
    
    /** 教具 控制器*/
    private lazy var classToolsController = AgoraClassToolsUIController(context: contextPool)
    
    /** 课堂状态 控制器（仅教师端）*/
    private lazy var classStateController = AgoraClassStateUIController(context: contextPool,
                                                                        delegate: self)
    
    /** 全局状态 控制器（自身不包含UI）*/
    private lazy var globalController = AgoraRoomGlobalUIController(context: contextPool,
                                                                    delegate: self)
    
    // MARK: - Suspend components
    /** 设置界面 控制器*/
    private lazy var settingController = AgoraSettingUIController(context: contextPool,
                                                                  roomDelegate: self)
    
    /** 聊天窗口 控制器*/
    private lazy var chatController = AgoraChatUIController(context: contextPool,
                                                            delegate: self)
    
    /** 工具集合 控制器（观众端没有）*/
    private lazy var toolCollectionController = AgoraToolCollectionUIController(context: contextPool,
                                                                                delegate: self)
    
    /** 花名册 控制器*/
    private lazy var nameRollController = AgoraUserListUIController(context: contextPool)
    
    /** 视窗菜单 控制器（仅教师端）*/
    private lazy var renderMenuController = AgoraRenderMenuUIController(context: contextPool,
                                                                        delegate: self)
    
    /** 举手列表 控制器（仅老师端）*/
    private lazy var handsListController = AgoraHandsListUIController(context: contextPool,
                                                                      delegate: self)
    
    /** 云盘 控制器（仅教师端）*/
    private lazy var cloudController = AgoraCloudUIController(context: contextPool,
                                                              delegate: self)
    
    private var isJoinedRoom = false
    private var curStageOn = true
    
    deinit {
        print("\(#function): \(self.classForCoder)")
    }
    
    public override func viewDidLoad() {
        super.viewDidLoad()
        initViews()
        initViewFrame()
        updateViewProperties()
        
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

// MARK: - AgoraUIContentContainer
extension AgoraSmallUIManager: AgoraUIContentContainer {
    func initViews() {
        let userRole = contextPool.user.getLocalUserInfo().userRole
        
        // Flat components
        addChild(stateController)
        contentView.addSubview(stateController.view)
        
        addChild(renderController)
        contentView.addSubview(renderController.view)
        
        boardController.view.clipsToBounds = true
        addChild(boardController)
        contentView.addSubview(boardController.view)
        
        addChild(webViewController)
        contentView.addSubview(webViewController.view)
        
        addChild(windowController)
        contentView.addSubview(windowController.view)
        
        if userRole != .observer {
            addChild(boardPageController)
            contentView.addSubview(boardPageController.view)
        }
        
        addChild(toolBarController)
        contentView.addSubview(toolBarController.view)
        
        addChild(classToolsController)
        contentView.addSubview(classToolsController.view)
        
        switch userRole {
        case .teacher:
            toolBarController.tools = [.setting,
                                       .message,
                                       .nameRoll,
                                       .handsList]
            
            addChild(classStateController)
            classStateController.view.isHidden = true
            contentView.addSubview(classStateController.view)
        case .student:
            toolBarController.tools = [.setting,
                                       .message,
                                       .nameRoll,
                                       .handsup]
        default:
            toolBarController.tools = [.setting,
                                       .message]
        }
        
        // Suspend components
        addChild(settingController)
        
        if userRole == .observer {
            chatController.hideInput = true
        }
        
        chatController.hideMiniButton = true
        addChild(chatController)
        
        switch userRole {
        case .teacher:
            addChild(nameRollController)
            
            addChild(handsListController)
            
            addChild(renderMenuController)
            renderMenuController.view.isHidden = true
            contentView.addSubview(renderMenuController.view)
            
            addChild(toolCollectionController)
            contentView.addSubview(toolCollectionController.view)
            
            addChild(cloudController)
            cloudController.view.isHidden = true
            contentView.addSubview(cloudController.view)
        case .student:
            addChild(nameRollController)
            
            addChild(toolCollectionController)
            contentView.addSubview(toolCollectionController.view)
        default:
            break
        }
        
        // Flat components
        globalController.roomDelegate = self
        addChild(globalController)
        globalController.viewDidLoad()
    }
    
    func initViewFrame() {
        let userRole = contextPool.user.getLocalUserInfo().userRole
        
        stateController.view.mas_makeConstraints { make in
            make?.top.left().right().equalTo()(0)
            make?.height.equalTo()(UIDevice.current.agora_is_pad ? 20 : 14)
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
        
        self.toolBarController.view.mas_remakeConstraints { make in
            make?.right.equalTo()(self.boardController.view.mas_right)?.offset()(UIDevice.current.agora_is_pad ? -15 : -12)
            make?.bottom.equalTo()(self.boardController.mas_bottomLayoutGuideBottom)?.offset()(UIDevice.current.agora_is_pad ? -20 : -15)
            make?.width.equalTo()(self.toolBarController.suggestSize.width)
            make?.height.equalTo()(self.toolBarController.suggestSize.height)
        }
        
        if userRole != .observer {
            toolCollectionController.view.mas_makeConstraints { make in
                make?.centerX.equalTo()(self.toolBarController.view.mas_centerX)
                make?.bottom.equalTo()(boardController.view)?.offset()(UIDevice.current.agora_is_pad ? -20 : -15)
                make?.width.height().equalTo()(toolCollectionController.suggestLength)
            }
            
            boardPageController.view.mas_makeConstraints { make in
                make?.left.equalTo()(contentView)?.offset()(UIDevice.current.agora_is_pad ? 15 : 12)
                make?.bottom.equalTo()(boardController.view)?.offset()(UIDevice.current.agora_is_pad ? -20 : -15)
                make?.height.equalTo()(UIDevice.current.agora_is_pad ? 34 : 32)
                make?.width.equalTo()(168)
            }
        }
        
        webViewController.view.mas_makeConstraints { make in
            make?.left.right().top().bottom().equalTo()(boardController.view)
        }
        
        windowController.view.mas_makeConstraints { make in
            make?.left.right().top().bottom().equalTo()(boardController.view)
        }
        
        classToolsController.view.mas_makeConstraints { make in
            make?.left.right().top().bottom().equalTo()(boardController.view)
        }
        
        updateRenderCollectionLayout()
    }
    
    func updateViewProperties() {
        AgoraUIGroup().color.borderSet(layer: chatController.view.layer)
    }
}

// MARK: - AgoraToolBarDelegate
extension AgoraSmallUIManager: AgoraToolBarDelegate {
    func toolsViewDidSelectTool(tool: AgoraToolBarUIController.ItemType,
                                selectView: UIView) {
        switch tool {
        case .setting:
            settingController.view.frame = CGRect(origin: .zero,
                                                  size: settingController.suggestSize)
            ctrlView = settingController.view
        case .nameRoll:
            nameRollController.view.frame = CGRect(origin: .zero,
                                                   size: nameRollController.suggestSize)
            ctrlView = nameRollController.view
        case .message:
            chatController.view.frame = CGRect(origin: .zero,
                                               size: chatController.suggestSize)
            ctrlView = chatController.view
        case .handsList:
            guard handsListController.dataSource.count > 0 else {
                return
            }
            
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

// MARK: - FcrStreamWindowUIControllerDelegate
extension AgoraSmallUIManager: FcrStreamWindowUIControllerDelegate {
    func onNeedWindowRenderViewFrameOnTopWindow(userId: String) -> CGRect? {
        guard let renderView = renderController.getRenderView(userId: userId) else {
            return nil
        }
        
        let frame = renderView.convert(renderView.frame,
                                       to: UIWindow.ag_topWindow())
        
        return frame
    }
    
    func onWillStartRenderVideoStream(streamId: String) {
        guard let item = renderController.getItem(streamId: streamId),
              let data = item.data else {
            return
        }
        
        let new = FcrWindowRenderViewState.create(isHide: true,
                                                  data: data)
        
        renderController.updateItem(new,
                                    animation: false)
    }
    
    func onDidStopRenderVideoStream(streamId: String) {
        guard let item = renderController.getItem(streamId: streamId),
              let data = item.data else {
            return
        }
        
        let new = FcrWindowRenderViewState.create(isHide: false,
                                                  data: data)
        
        renderController.updateItem(new,
                                    animation: false)
    }
}

// MARK: - AgoraCloudUIControllerDelegate
extension AgoraSmallUIManager: AgoraCloudUIControllerDelegate {
    func onOpenAlfCourseware(urlString: String,
                             resourceId: String) {
        webViewController.openWebView(urlString: urlString,
                                      resourceId: resourceId)
    }
}

// MARK: - AgoraToolCollectionUIControllerDelegate
extension AgoraSmallUIManager: AgoraToolCollectionUIControllerDelegate {
    func toolCollectionDidSelectCell(view: UIView) {
        toolBarController.deselectAll()
        ctrlView = view
        ctrlViewAnimationFromView(toolCollectionController.view)
    }
    
    func toolCollectionCellNeedSpread(_ spread: Bool) {
        if spread {
            toolCollectionController.view.mas_remakeConstraints { make in
                make?.centerX.equalTo()(self.toolBarController.view.mas_centerX)
                make?.bottom.equalTo()(contentView)?.offset()(UIDevice.current.agora_is_pad ? -20 : -15)
                make?.width.equalTo()(toolCollectionController.suggestLength)
                make?.height.equalTo()(toolCollectionController.suggestSpreadHeight)
            }
        } else {
            toolCollectionController.view.mas_remakeConstraints { make in
                make?.centerX.equalTo()(self.toolBarController.view.mas_centerX)
                make?.bottom.equalTo()(contentView)?.offset()(UIDevice.current.agora_is_pad ? -20 : -15)
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
        case .saveBoard:
            boardController.saveBoard()
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
                    make?.right.equalTo()(self.boardController.view.mas_right)?.offset()(UIDevice.current.agora_is_pad ? -15 : -12)
                    make?.bottom.equalTo()(self.toolCollectionController.view.mas_top)?.offset()(UIDevice.current.agora_is_pad ? -15 : -12)
                    make?.width.equalTo()(self.toolBarController.suggestSize.width)
                    make?.height.equalTo()(self.toolBarController.suggestSize.height)
                }
            } else {
                self.toolBarController.view.mas_remakeConstraints { make in
                    make?.right.equalTo()(self.boardController.view.mas_right)?.offset()(UIDevice.current.agora_is_pad ? -15 : -12)
                    make?.bottom.equalTo()(self.boardController.mas_bottomLayoutGuideBottom)?.offset()(UIDevice.current.agora_is_pad ? -20 : -15)
                    make?.width.equalTo()(self.toolBarController.suggestSize.width)
                    make?.height.equalTo()(self.toolBarController.suggestSize.height)
                }
            }
        }, completion: nil)
    }
}
// MARK: - AgoraChatUIControllerDelegate
extension AgoraSmallUIManager: AgoraHandsListUIControllerDelegate {
    func updateHandsListRedLabel(_ count: Int) {
        if count == 0,
           ctrlView == handsListController.view {
            ctrlView = nil
        }
        toolBarController.updateHandsListCount(count)
    }
}

// MARK: - AgoraChatUIControllerDelegate
extension AgoraSmallUIManager: AgoraChatUIControllerDelegate {
    func updateChatRedDot(isShow: Bool) {
        toolBarController.updateChatRedDot(isShow: isShow)
    }
}

// MARK: - FcrWindowRenderUIControllerDelegate
extension AgoraSmallUIManager: FcrWindowRenderUIControllerDelegate {
    func renderUIController(_ controller: FcrWindowRenderUIController,
                            didPressItem item: FcrWindowRenderViewState,
                            view: UIView) {
        guard contextPool.user.getLocalUserInfo().userRole == .teacher,
              let data = item.data else {
            return
        }
        
        let rect = view.convert(view.bounds,
                                to: contentView)
        let centerX = rect.center.x - contentView.width / 2
        
        let userId = data.userId
        
        var role = AgoraEduContextUserRole.student
        if let teacehr = contextPool.user.getUserList(role: .teacher)?.first,
           teacehr.userUuid == userId {
            role = .teacher
        }
        
        if let menuId = renderMenuController.userId,
           menuId == userId {
            // 若当前已存在menu，且当前menu的userId为点击的userId，menu切换状态
            renderMenuController.dismissView()
        } else {
            // 1. 当前menu的userId不为点击的userId，切换用户
            // 2. 当前不存在menu，显示
            renderMenuController.show(roomType: .small,
                                      userUuid: userId,
                                      showRoleType: role)
            renderMenuController.view.mas_remakeConstraints { make in
                make?.top.equalTo()(view.mas_bottom)?.offset()(2)
                make?.centerX.equalTo()(centerX)
                make?.height.equalTo()(30)
                make?.width.equalTo()(renderMenuController.menuWidth)
            }
        }
    }
}

// MARK: - AgoraRenderMenuUIControllerDelegate
extension AgoraSmallUIManager: AgoraRenderMenuUIControllerDelegate {
    func onMenuUserLeft() {
        renderMenuController.dismissView()
    }
}

// MARK: - AgoraClassStateUIControllerDelegate
extension AgoraSmallUIManager: AgoraClassStateUIControllerDelegate {
    func onShowStartClass() {
        guard contextPool.user.getLocalUserInfo().userRole == .teacher else {
            return
        }
        
        classStateController.view.isHidden = false
        
        classStateController.view.mas_makeConstraints { make in
            make?.left.equalTo()(boardPageController.view.mas_right)?.offset()(UIDevice.current.agora_is_pad ? 15 : 12)
            make?.bottom.equalTo()(boardPageController.view.mas_bottom)
            make?.size.equalTo()(classStateController.suggestSize)
        }
    }
}

// MARK: - AgoraRoomGlobalUIControllerDelegate
extension AgoraSmallUIManager: AgoraRoomGlobalUIControllerDelegate {
    func onLocalUserAddedToSubRoom(subRoomId: String) {
        if let vc = presentedViewController,
           let _ = vc as? AgoraSubRoomUIManager  {
            return
        }
        
        guard let subRoom = contextPool.group.createSubRoomObject(subRoomUuid: subRoomId) else {
            return
        }
        
        for child in children {
            guard let vc = child as? AgoraUIActivity else {
                continue
            }
            
            vc.viewWillInactive()
        }
        
        ctrlView = nil
        
        let vc = AgoraSubRoomUIManager(contextPool: contextPool,
                                       subRoom: subRoom,
                                       subDelegate: self,
                                       mainDelegate: self)
        
        vc.modalPresentationStyle = .fullScreen
        present(vc,
                animated: true)
    }
    
    func onLocalUserRemovedFromSubRoom(subRoomId: String,
                                       isKickOut: Bool) {
        guard let vc = presentedViewController,
              let subRoom = vc as? AgoraSubRoomUIManager else {
            return
        }
        
        let reason: AgoraClassRoomExitReason = (isKickOut ? .kickOut : .normal)
        
        subRoom.dismiss(reason: reason,
                        animated: true)
    }
}

// MARK: - AgoraBoardUIControllerDelegate
extension AgoraSmallUIManager: AgoraBoardUIControllerDelegate {
    func onStageStateChanged(stageOn: Bool) {
        guard curStageOn != stageOn else {
            return
        }
        curStageOn = stageOn
        if curStageOn {
            renderController.view.isHidden = false
            boardController.view.mas_remakeConstraints { make in
                make?.height.equalTo()(AgoraFit.scale(307))
                make?.left.right().bottom().equalTo()(0)
            }
            
            renderController.view.mas_remakeConstraints { make in
                make?.left.right().equalTo()(0)
                make?.top.equalTo()(stateController.view.mas_bottom)?.offset()(AgoraFit.scale(1))
                make?.bottom.equalTo()(boardController.view.mas_top)?.offset()(AgoraFit.scale(-1))
            }
        } else {
            renderController.view.isHidden = true
            boardController.view.mas_remakeConstraints { make in
                make?.height.equalTo()(AgoraFit.scale(307))
                make?.left.right().equalTo()(0)
                make?.centerY.equalTo()(contentView.mas_centerY)?.offset()(UIDevice.current.agora_is_pad ? 10 : 7)
            }
        }
    }
    
    func onBoardActiveStateChanged(isActive: Bool) {
        toolCollectionController.updateBoardActiveState(isActive: isActive)
        boardPageController.updateBoardActiveState(isActive: isActive)
    }
    
    func onBoardGrantedUserListAdded(userList: [String]) {
        updateWindowRenderItemBoardPrivilege(true,
                                             userList: userList)
        updateStreamWindowItemBoardPrivilege(true,
                                             userList: userList)
        toolCollectionController.onBoardPrivilegeListChaned(true,
                                                            userList: userList)
        boardPageController.onBoardPrivilegeListChaned(true,
                                                       userList: userList)
    }
    
    func onBoardGrantedUserListRemoved(userList: [String]) {
        updateWindowRenderItemBoardPrivilege(false,
                                             userList: userList)
        updateStreamWindowItemBoardPrivilege(false,
                                             userList: userList)
        toolCollectionController.onBoardPrivilegeListChaned(false,
                                                            userList: userList)
        boardPageController.onBoardPrivilegeListChaned(false,
                                                       userList: userList)
    }
    
    func updateWindowRenderItemBoardPrivilege(_ privilege: Bool,
                                              userList: [String]) {
        for (index, item) in renderController.coHost.dataSource.enumerated() {
            guard var data = item.data,
                  userList.contains(data.userId) else {
                continue
            }
            
            guard let user = contextPool.user.getUserInfo(userUuid: data.userId),
                  user.userRole != .teacher else {
                continue
            }
            
            let privilege = FcrBoardPrivilegeViewState.create(privilege)
            data.boardPrivilege = privilege
            
            let new = FcrWindowRenderViewState.create(isHide: item.isHide,
                                                      data: data)
            
            renderController.coHost.updateItem(new,
                                               index: index)
        }
    }
    
    func updateStreamWindowItemBoardPrivilege(_ privilege: Bool,
                                              userList: [String]) {
        for (index, item) in windowController.dataSource.enumerated() {
            var data = item.data
            
            guard userList.contains(data.userId) else {
                continue
            }
            
            guard let user = contextPool.user.getUserInfo(userUuid: data.userId),
                  user.userRole != .teacher else {
                continue
            }
            
            let privilege = FcrBoardPrivilegeViewState.create(privilege)
            data.boardPrivilege = privilege
            
            windowController.updateItemData(data,
                                            index: index)
        }
    }
}

// MARK: - FcrUIControllerDataSource
extension AgoraSmallUIManager: FcrUIControllerDataSource {
    func controllerNeedGrantedUserList() -> [String] {
        return boardController.grantedUsers
    }
}

// MARK: - AgoraEduUIManagerCallBack
extension AgoraSmallUIManager: AgoraEduUIManagerCallback {
    public func manager(_ manager: AgoraEduUIManager,
                        didExit reason: AgoraClassRoomExitReason) {
        for child in children {
            guard let vc = child as? AgoraUIActivity else {
                continue
            }
            
            vc.viewWillActive()
        }
    }
}

// MARK: - AgoraEduUISubManagerCallBack
extension AgoraSmallUIManager: AgoraEduUISubManagerCallback {
    public func subNeedExitAllRooms(reason: AgoraClassRoomExitReason) {
        if let vc = presentedViewController,
           let subRoom = vc as? AgoraSubRoomUIManager {
            
            subRoom.dismiss(reason: reason,
                            animated: false) { [weak self] in
                self?.exitClassRoom(reason: reason,
                                    roomType: .main)
            }
        } else {
            exitClassRoom(reason: reason,
                          roomType: .main)
        }
    }
}

// MARK: - Creations
private extension AgoraSmallUIManager {
    func updateRenderCollectionLayout() {
        view.layoutIfNeeded()
        let kItemGap: CGFloat = 2
        
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .horizontal
        
        let itemWidth = (renderController.view.bounds.width + kItemGap) / 7.0 - kItemGap
        
        layout.itemSize = CGSize(width: itemWidth,
                                 height: renderController.view.bounds.height)
        layout.minimumLineSpacing = kItemGap
        renderController.updateLayout(layout)
    }
}
