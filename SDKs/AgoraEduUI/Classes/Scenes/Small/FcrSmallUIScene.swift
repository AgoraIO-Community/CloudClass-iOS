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
@objc public class FcrSmallUIScene: FcrUIScene {
    // MARK: - Flat components
    /** 房间状态 控制器*/
    private lazy var stateComponent = FcrRoomStateUIComponent(context: contextPool)
    
    /** 视窗渲染 控制器*/
    private lazy var renderComponent = FcrSmallWindowRenderUIComponent(context: contextPool,
                                                                       delegate: self,
                                                                       componentDataSource: self)
    
    /** 白板的渲染 控制器*/
    private lazy var boardComponent = FcrBoardUIComponent(context: contextPool,
                                                          delegate: self)
    
    /** 外部链接 控制器*/
    private lazy var webViewComponent = FcrWebViewUIComponent(context: contextPool)
    
    /** 大窗 控制器*/
    private lazy var windowComponent = FcrStreamWindowUIComponent(context: contextPool,
                                                                  delegate: self,
                                                                  componentDataSource: self)
    
    /** 工具栏*/
    private lazy var toolBarComponent = FcrToolBarUIComponent(context: contextPool,
                                                              delegate: self)
    
    /** 教具 控制器*/
    private lazy var classToolsComponent = FcrClassToolsUIComponent(context: contextPool)
    
    /** 课堂状态 控制器（仅教师端）*/
    private lazy var classStateComponent = FcrClassStateUIComponent(context: contextPool,
                                                                    delegate: self)
    
    /** 全局状态 控制器（自身不包含UI）*/
    private lazy var globalComponent = FcrRoomGlobalUIComponent(context: contextPool,
                                                                delegate: self)
    
    // MARK: - Suspend components
    /** 设置界面 控制器*/
    private lazy var settingComponent = FcrSettingUIComponent(context: contextPool,
                                                              exitDelegate: self)
    
    /** 聊天窗口 控制器*/
    private lazy var chatComponent = FcrChatUIComponent(context: contextPool,
                                                        delegate: self)
    
    /** 工具集合 控制器（观众端没有）*/
    private lazy var toolCollectionComponent = FcrToolCollectionUIComponent(context: contextPool,
                                                                            delegate: self)
    
    /** 花名册 控制器*/
    private lazy var nameRollComponent = FcrUserListUIComponent(context: contextPool)
    
    /** 视窗菜单 控制器（仅教师端）*/
    private lazy var renderMenuComponent = FcrRenderMenuUIComponent(context: contextPool,
                                                                    delegate: self)
    
    /** 举手列表 控制器（仅老师端）*/
    private lazy var handsListComponent = FcrHandsListUIComponent(context: contextPool,
                                                                  delegate: self)
    
    /** 云盘 控制器（仅教师端）*/
    private lazy var cloudComponent = FcrCloudUIComponent(context: contextPool,
                                                          delegate: self)
    
    private var isJoinedRoom = false
    private var curStageOn = true
    
    @objc public init(contextPool: AgoraEduContextPool,
                      delegate: FcrUISceneDelegate?) {
        super.init(sceneType: .small,
                   contextPool: contextPool,
                   delegate: delegate)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    public override func viewDidLoad() {
        super.viewDidLoad()
        
        contextPool.room.joinRoom { [weak self] in
            AgoraLoading.hide()
            guard let `self` = self else {
                return
            }
            self.isJoinedRoom = true
            
            if self.contextPool.user.getLocalUserInfo().userRole != .observer {
                self.contextPool.media.openLocalDevice(systemDevice: .frontCamera)
                self.contextPool.media.openLocalDevice(systemDevice: .mic)
            }
        } failure: { [weak self] error in
            AgoraLoading.hide()
            self?.exitScene(reason: .normal)
        }
    }
    
    public override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        if isJoinedRoom == false {
            AgoraLoading.loading()
        } else {
            let message = "fcr_group_back_main_room".agedu_localized()
            AgoraLoading.loading(message: message)
        }
    }
    
    public override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        if isJoinedRoom {
            AgoraLoading.hide()
        }
    }
    
    public override func didClickCtrlMaskView() {
        super.didClickCtrlMaskView()
        toolBarComponent.deselectAll()
    }
    
    // MARK: AgoraUIContentContainer
    public override func initViews() {
        super.initViews()
        let userRole = contextPool.user.getLocalUserInfo().userRole
        
        // Flat components
        addChild(stateComponent)
        contentView.addSubview(stateComponent.view)
        
        addChild(renderComponent)
        contentView.addSubview(renderComponent.view)
        
        boardComponent.view.clipsToBounds = true
        addChild(boardComponent)
        contentView.addSubview(boardComponent.view)
        
        addChild(webViewComponent)
        contentView.addSubview(webViewComponent.view)
        
        addChild(windowComponent)
        contentView.addSubview(windowComponent.view)
        
        addChild(toolBarComponent)
        contentView.addSubview(toolBarComponent.view)
        
        addChild(classToolsComponent)
        contentView.addSubview(classToolsComponent.view)
        
        switch userRole {
        case .teacher:
            toolBarComponent.updateTools([.setting,
                                          .message,
                                          .roster,
                                          .handsList])
            
            addChild(classStateComponent)
            classStateComponent.view.agora_enable = UIConfig.classState.enable
            classStateComponent.view.agora_visible = false
            contentView.addSubview(classStateComponent.view)
        case .student:
            toolBarComponent.updateTools([.setting,
                                          .message,
                                          .roster,
                                          .waveHands])
        default:
            toolBarComponent.updateTools([.setting,
                                          .message])
        }
        
        // Suspend components
        addChild(settingComponent)
        
        addChild(chatComponent)
        
        switch userRole {
        case .teacher:
            addChild(nameRollComponent)
            nameRollComponent.view.agora_enable = UIConfig.roster.enable
            nameRollComponent.view.agora_visible = UIConfig.roster.enable
            
            addChild(handsListComponent)
            handsListComponent.view.agora_enable = UIConfig.handsList.enable
            handsListComponent.view.agora_visible = UIConfig.handsList.enable
            
            addChild(renderMenuComponent)
            contentView.addSubview(renderMenuComponent.view)
            renderMenuComponent.view.agora_enable = UIConfig.renderMenu.enable
            renderMenuComponent.view.agora_visible = false
            
            addChild(toolCollectionComponent)
            contentView.addSubview(toolCollectionComponent.view)
            toolCollectionComponent.view.agora_enable = UIConfig.toolCollection.enable
            toolCollectionComponent.view.agora_visible = UIConfig.toolCollection.enable
            
            addChild(cloudComponent)
            cloudComponent.view.isHidden = true
            contentView.addSubview(cloudComponent.view)
        case .student:
            addChild(nameRollComponent)
            nameRollComponent.view.agora_enable = UIConfig.roster.enable
            nameRollComponent.view.agora_visible = UIConfig.roster.enable
            
            addChild(toolCollectionComponent)
            contentView.addSubview(toolCollectionComponent.view)
            toolCollectionComponent.view.agora_enable = UIConfig.toolCollection.enable
            toolCollectionComponent.view.agora_visible = UIConfig.toolCollection.enable
        default:
            break
        }
        
        // Flat components
        globalComponent.roomDelegate = self
        addChild(globalComponent)
        globalComponent.viewDidLoad()
        
        stateComponent.view.agora_enable = UIConfig.stateBar.enable
        stateComponent.view.agora_visible = UIConfig.stateBar.visible
        
        boardComponent.view.agora_enable = UIConfig.netlessBoard.enable
        boardComponent.view.agora_visible = UIConfig.netlessBoard.visible
        
        settingComponent.view.agora_enable = UIConfig.setting.enable
        settingComponent.view.agora_visible = UIConfig.setting.visible
        
        toolBarComponent.view.agora_enable = UIConfig.toolBar.enable
        toolBarComponent.view.agora_visible = UIConfig.toolBar.visible
        
        classToolsComponent.view.agora_enable = UIConfig.toolBox.enable
        classToolsComponent.view.agora_visible = UIConfig.toolBox.visible
        
        chatComponent.view.agora_enable = UIConfig.agoraChat.enable
        chatComponent.view.agora_visible = UIConfig.agoraChat.visible
    }
    
    public override func initViewFrame() {
        super.initViewFrame()
        let userRole = contextPool.user.getLocalUserInfo().userRole
        
        stateComponent.view.mas_makeConstraints { make in
            make?.top.left().right().equalTo()(0)
            make?.height.equalTo()(UIDevice.current.agora_is_pad ? 20 : 14)
        }
        
        boardComponent.view.mas_makeConstraints { make in
            make?.height.equalTo()(AgoraFit.scale(307))
            make?.left.right().bottom().equalTo()(0)
            make?.bottom.equalTo()(0)
        }
        
        renderComponent.view.mas_makeConstraints { make in
            make?.left.right().equalTo()(0)
            make?.top.equalTo()(stateComponent.view.mas_bottom)?.offset()(2)
            make?.bottom.equalTo()(boardComponent.view.mas_top)?.offset()(-2)
        }
        
        self.toolBarComponent.view.mas_remakeConstraints { make in
            make?.right.equalTo()(self.boardComponent.view.mas_right)?.offset()(UIDevice.current.agora_is_pad ? -15 : -12)
            make?.bottom.equalTo()(self.boardComponent.mas_bottomLayoutGuideBottom)?.offset()(UIDevice.current.agora_is_pad ? -20 : -15)
            make?.width.equalTo()(self.toolBarComponent.suggestSize.width)
            make?.height.equalTo()(self.toolBarComponent.suggestSize.height)
        }
        
        if userRole != .observer {
            toolCollectionComponent.view.mas_makeConstraints { make in
                make?.centerX.equalTo()(self.toolBarComponent.view.mas_centerX)
                make?.bottom.equalTo()(boardComponent.view)?.offset()(UIDevice.current.agora_is_pad ? -20 : -15)
                make?.width.height().equalTo()(toolCollectionComponent.suggestLength)
            }
        }
        
        webViewComponent.view.mas_makeConstraints { make in
            make?.left.right().top().bottom().equalTo()(boardComponent.view)
        }
        
        windowComponent.view.mas_makeConstraints { make in
            make?.left.right().top().bottom().equalTo()(boardComponent.view)
        }
        
        classToolsComponent.view.mas_makeConstraints { make in
            make?.left.right().top().bottom().equalTo()(boardComponent.view)
        }
        
        updateRenderCollectionLayout()
    }
    
    public override func updateViewProperties() {
        super.updateViewProperties()
    }
}

// MARK: - AgoraToolBarDelegate
extension FcrSmallUIScene: FcrToolBarComponentDelegate {
    func toolsViewDidSelectTool(tool: FcrToolBarItemType,
                                selectView: UIView) {
        switch tool {
        case .setting:
            settingComponent.view.frame = CGRect(origin: .zero,
                                                 size: settingComponent.suggestSize)
            ctrlView = settingComponent.view
        case .roster:
            nameRollComponent.view.frame = CGRect(origin: .zero,
                                                  size: nameRollComponent.suggestSize)
            ctrlView = nameRollComponent.view
        case .message:
            chatComponent.view.frame = CGRect(origin: .zero,
                                              size: chatComponent.suggestSize)
            ctrlView = chatComponent.view
        case .handsList:
            guard handsListComponent.dataSource.count > 0 else {
                return
            }
            
            handsListComponent.view.frame = CGRect(origin: .zero,
                                                   size: handsListComponent.suggestSize)
            ctrlView = handsListComponent.view
        default:
            break
        }
        ctrlViewAnimationFromView(selectView)
    }
    
    func toolsViewDidDeselectTool(tool: FcrToolBarItemType) {
        ctrlView = nil
    }
}

// MARK: - FcrStreamWindowUIComponentDelegate
extension FcrSmallUIScene: FcrStreamWindowUIComponentDelegate {
    func onNeedWindowRenderViewFrameOnTopWindow(userId: String) -> CGRect? {
        guard let renderView = renderComponent.getRenderView(userId: userId) else {
            return nil
        }
        
        let frame = renderView.convert(renderView.frame,
                                       to: UIWindow.agora_top_window())
        
        return frame
    }
    
    func onWillStartRenderVideoStream(streamId: String) {
        guard let item = renderComponent.getItem(streamId: streamId),
              let data = item.data else {
                  return
              }
        
        let new = FcrWindowRenderViewState.create(isHide: true,
                                                  data: data)
        
        renderComponent.updateItem(new,
                                   animation: false)
    }
    
    func onDidStopRenderVideoStream(streamId: String) {
        guard let item = renderComponent.getItem(streamId: streamId),
              let data = item.data else {
                  return
              }
        
        let new = FcrWindowRenderViewState.create(isHide: false,
                                                  data: data)
        
        renderComponent.updateItem(new,
                                   animation: false)
    }
}

// MARK: - AgoraCloudUIComponentDelegate
extension FcrSmallUIScene: FcrCloudUIComponentDelegate {
    func onOpenAlfCourseware(urlString: String,
                             resourceId: String) {
        webViewComponent.openWebView(urlString: urlString,
                                     resourceId: resourceId)
    }
}

// MARK: - AgoraToolCollectionUIComponentDelegate
extension FcrSmallUIScene: FcrToolCollectionUIComponentDelegate {
    func toolCollectionDidSelectCell(view: UIView) {
        toolBarComponent.deselectAll()
        ctrlView = view
        ctrlViewAnimationFromView(toolCollectionComponent.view)
    }
    
    func toolCollectionCellNeedSpread(_ spread: Bool) {
        if spread {
            toolCollectionComponent.view.mas_remakeConstraints { make in
                make?.centerX.equalTo()(self.toolBarComponent.view.mas_centerX)
                make?.bottom.equalTo()(contentView)?.offset()(UIDevice.current.agora_is_pad ? -20 : -15)
                make?.width.equalTo()(toolCollectionComponent.suggestLength)
                make?.height.equalTo()(toolCollectionComponent.suggestSpreadHeight)
            }
        } else {
            toolCollectionComponent.view.mas_remakeConstraints { make in
                make?.centerX.equalTo()(self.toolBarComponent.view.mas_centerX)
                make?.bottom.equalTo()(contentView)?.offset()(UIDevice.current.agora_is_pad ? -20 : -15)
                make?.width.height().equalTo()(toolCollectionComponent.suggestLength)
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
            if cloudComponent.view.isHidden {
                cloudComponent.view.mas_makeConstraints { make in
                    make?.left.right().top().bottom().equalTo()(boardComponent.view)
                }
            }
            cloudComponent.view.isHidden = !cloudComponent.view.isHidden
        case .saveBoard:
            boardComponent.saveBoard()
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
                self.toolBarComponent.view.mas_remakeConstraints { make in
                    make?.right.equalTo()(self.boardComponent.view.mas_right)?.offset()(UIDevice.current.agora_is_pad ? -15 : -12)
                    make?.bottom.equalTo()(self.toolCollectionComponent.view.mas_top)?.offset()(UIDevice.current.agora_is_pad ? -15 : -12)
                    make?.width.equalTo()(self.toolBarComponent.suggestSize.width)
                    make?.height.equalTo()(self.toolBarComponent.suggestSize.height)
                }
            } else {
                self.toolBarComponent.view.mas_remakeConstraints { make in
                    make?.right.equalTo()(self.boardComponent.view.mas_right)?.offset()(UIDevice.current.agora_is_pad ? -15 : -12)
                    make?.bottom.equalTo()(self.boardComponent.mas_bottomLayoutGuideBottom)?.offset()(UIDevice.current.agora_is_pad ? -20 : -15)
                    make?.width.equalTo()(self.toolBarComponent.suggestSize.width)
                    make?.height.equalTo()(self.toolBarComponent.suggestSize.height)
                }
            }
        }, completion: nil)
    }
}
// MARK: - AgoraChatUIComponentDelegate
extension FcrSmallUIScene: FcrHandsListUIComponentDelegate {
    func updateHandsListRedLabel(_ count: Int) {
        if count == 0,
           ctrlView == handsListComponent.view {
            ctrlView = nil
        }
        toolBarComponent.updateHandsListCount(count)
    }
}

// MARK: - AgoraChatUIComponentDelegate
extension FcrSmallUIScene: FcrChatUIComponentDelegate {
    func updateChatRedDot(isShow: Bool) {
        toolBarComponent.updateChatRedDot(isShow: isShow)
    }
}

// MARK: - FcrWindowRenderUIComponentDelegate
extension FcrSmallUIScene: FcrWindowRenderUIComponentDelegate {
    func renderUIComponent(_ component: FcrWindowRenderUIComponent,
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
        
        if let menuId = renderMenuComponent.userId,
           menuId == userId {
            // 若当前已存在menu，且当前menu的userId为点击的userId，menu切换状态
            renderMenuComponent.dismissView()
        } else {
            // 1. 当前menu的userId不为点击的userId，切换用户
            // 2. 当前不存在menu，显示
            renderMenuComponent.show(roomType: .small,
                                     userUuid: userId,
                                     showRoleType: role)
            renderMenuComponent.view.mas_remakeConstraints { make in
                make?.top.equalTo()(view.mas_bottom)?.offset()(2)
                make?.centerX.equalTo()(centerX)
                make?.height.equalTo()(30)
                make?.width.equalTo()(renderMenuComponent.menuWidth)
            }
        }
    }
}

// MARK: - AgoraRenderMenuUIComponentDelegate
extension FcrSmallUIScene: FcrRenderMenuUIComponentDelegate {
    func onMenuUserLeft() {
        renderMenuComponent.dismissView()
    }
}

// MARK: - AgoraClassStateUIComponentDelegate
extension FcrSmallUIScene: FcrClassStateUIComponentDelegate {
    func onShowStartClass() {
        guard contextPool.user.getLocalUserInfo().userRole == .teacher else {
            return
        }
        
        classStateComponent.view.isHidden = false
        
        let left: CGFloat = UIDevice.current.agora_is_pad ? 198 : 192
        classStateComponent.view.mas_makeConstraints { make in
            make?.left.equalTo()(contentView)?.offset()(left)
            make?.bottom.equalTo()(contentView)?.offset()(UIDevice.current.agora_is_pad ? -20 : -15)
            make?.size.equalTo()(classStateComponent.suggestSize)
        }
    }
}

// MARK: - AgoraRoomGlobalUIControllerDelegate
extension FcrSmallUIScene: FcrRoomGlobalUIComponentDelegate {
    func onLocalUserAddedToSubRoom(subRoomId: String) {
        if let vc = presentedViewController,
           let _ = vc as? FcrSubRoomUIScene  {
            return
        }
        
        guard UIConfig.breakoutRoom.enable,
              let subRoom = contextPool.group.createSubRoomObject(subRoomUuid: subRoomId) else {
                  return
              }
        
        for child in children {
            guard let vc = child as? AgoraUIActivity else {
                continue
            }
            
            vc.viewWillInactive()
        }
        
        ctrlView = nil
        
        let vc = FcrSubRoomUIScene(contextPool: contextPool,
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
              let subRoom = vc as? FcrSubRoomUIScene else {
                  return
              }
        
        let reason: FcrUISceneExitReason = (isKickOut ? .kickOut : .normal)
        
        subRoom.dismiss(reason: reason,
                        animated: true)
    }
}

// MARK: - AgoraBoardUIComponentDelegate
extension FcrSmallUIScene: FcrBoardUIComponentDelegate {
    func onStageStateChanged(stageOn: Bool) {
        guard curStageOn != stageOn else {
            return
        }
        curStageOn = stageOn
        if curStageOn {
            renderComponent.view.isHidden = false
            boardComponent.view.mas_remakeConstraints { make in
                make?.height.equalTo()(AgoraFit.scale(307))
                make?.left.right().bottom().equalTo()(0)
            }
            
            renderComponent.view.mas_remakeConstraints { make in
                make?.left.right().equalTo()(0)
                make?.top.equalTo()(stateComponent.view.mas_bottom)?.offset()(AgoraFit.scale(1))
                make?.bottom.equalTo()(boardComponent.view.mas_top)?.offset()(AgoraFit.scale(-1))
            }
        } else {
            renderComponent.view.isHidden = true
            boardComponent.view.mas_remakeConstraints { make in
                make?.height.equalTo()(AgoraFit.scale(307))
                make?.left.right().equalTo()(0)
                make?.centerY.equalTo()(contentView.mas_centerY)?.offset()(UIDevice.current.agora_is_pad ? 10 : 7)
            }
        }
    }
    
    func onBoardActiveStateChanged(isActive: Bool) {
        toolCollectionComponent.updateBoardActiveState(isActive: isActive)
    }
    
    func onBoardGrantedUserListAdded(userList: [String]) {
        updateWindowRenderItemBoardPrivilege(true,
                                             userList: userList)
        updateStreamWindowItemBoardPrivilege(true,
                                             userList: userList)
        toolCollectionComponent.onBoardPrivilegeListChaned(true,
                                                           userList: userList)
    }
    
    func onBoardGrantedUserListRemoved(userList: [String]) {
        updateWindowRenderItemBoardPrivilege(false,
                                             userList: userList)
        updateStreamWindowItemBoardPrivilege(false,
                                             userList: userList)
        toolCollectionComponent.onBoardPrivilegeListChaned(false,
                                                           userList: userList)
    }
    
    func updateWindowRenderItemBoardPrivilege(_ privilege: Bool,
                                              userList: [String]) {
        for (index, item) in renderComponent.coHost.dataSource.enumerated() {
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
            
            renderComponent.coHost.updateItem(new,
                                              index: index)
        }
    }
    
    func updateStreamWindowItemBoardPrivilege(_ privilege: Bool,
                                              userList: [String]) {
        for (index, item) in windowComponent.dataSource.enumerated() {
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
            
            windowComponent.updateItemData(data,
                                           index: index)
        }
    }
}

// MARK: - FcrUIcomponentDataSource
extension FcrSmallUIScene: FcrUIComponentDataSource {
    func componentNeedGrantedUserList() -> [String] {
        return boardComponent.grantedUsers
    }
}

// MARK: - AgoraEduUIManagerCallBack
extension FcrSmallUIScene: FcrUISceneDelegate {
    public func scene(_ manager: FcrUIScene,
                      didExit reason: FcrUISceneExitReason) {
        for child in children {
            guard let vc = child as? AgoraUIActivity else {
                continue
            }
            
            vc.viewWillActive()
        }
    }
}

// MARK: - AgoraEduUISubManagerCallBack
extension FcrSmallUIScene: AgoraEduUISubManagerCallback {
    public func subNeedExitAllRooms(reason: FcrUISceneExitReason) {
        if let vc = presentedViewController,
           let subRoom = vc as? FcrSubRoomUIScene {
            
            subRoom.dismiss(reason: reason,
                            animated: false) { [weak self] in
                self?.exitScene(reason: reason,
                                type: .main)
            }
        } else {
            exitScene(reason: reason,
                      type: .main)
        }
    }
}

// MARK: - Creations
private extension FcrSmallUIScene {
    func updateRenderCollectionLayout() {
        view.layoutIfNeeded()
        let kItemGap: CGFloat = 2
        
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .horizontal
        
        let itemWidth = (renderComponent.view.bounds.width + kItemGap) / 7.0 - kItemGap
        
        layout.itemSize = CGSize(width: itemWidth,
                                 height: renderComponent.view.bounds.height)
        layout.minimumLineSpacing = kItemGap
        renderComponent.updateLayout(layout)
    }
}
