//
//  AgoraEduUI+Small.swift
//  AgoraEduUI
//
//  Created by HeZhengQing on 2021/4/16.
//

import AgoraUIBaseViews
import AgoraEduCore
import AgoraWidget

/// 房间控制器:
/// 用以处理全局状态和子控制器之间的交互关系
@objc public class FcrSmallUIScene: FcrUIScene {
    // MARK: - Flat components
    /** 全局状态 控制器（自身不包含UI）*/
    private lazy var globalComponent = FcrRoomGlobalUIComponent(roomController: contextPool.room,
                                                                userController: contextPool.user,
                                                                monitorController: contextPool.monitor,
                                                                streamController: contextPool.stream,
                                                                groupController: contextPool.group,
                                                                delegate: self,
                                                                exitDelegate: self)
    
    /** 音频流 控制器（自身不包含UI）*/
    private lazy var audioComponent = FcrAudioStreamUIComponent(roomController: contextPool.room,
                                                                streamController: contextPool.stream,
                                                                userController: contextPool.user,
                                                                mediaController: contextPool.media)
    
    /** 房间状态 控制器*/
    private lazy var stateComponent = FcrRoomStateUIComponent(roomController: contextPool.room,
                                                              userController: contextPool.user,
                                                              monitorController: contextPool.monitor,
                                                              groupController: contextPool.group)
    
    /** 视窗渲染 控制器*/
    private lazy var renderComponent = FcrSmallTachedWindowUIComponent(roomController: contextPool.room,
                                                                       userController: contextPool.user,
                                                                       streamController: contextPool.stream,
                                                                       mediaController: contextPool.media,
                                                                       widgetController: contextPool.widget,
                                                                       delegate: self,
                                                                       componentDataSource: self)
    
    /** 白板的渲染 控制器*/
    private lazy var boardComponent = FcrBoardUIComponent(roomController: contextPool.room,
                                                          userController: contextPool.user,
                                                          widgetController: contextPool.widget,
                                                          mediaController: contextPool.media,
                                                          delegate: self)
    
    /** 外部链接 控制器*/
    private lazy var webViewComponent = FcrWebViewUIComponent(roomController: contextPool.room,
                                                              userController: contextPool.user,
                                                              widgetController: contextPool.widget)
    
    /** 大窗 控制器*/
    private lazy var windowComponent = FcrDetachedStreamWindowExUIComponent(roomController: contextPool.room,
                                                                            userController: contextPool.user,
                                                                            streamController: contextPool.stream,
                                                                            mediaController: contextPool.media,
                                                                            widgetController: contextPool.widget,
                                                                            delegate: self,
                                                                            componentDataSource: self)
    
    /** 工具栏*/
    private lazy var toolBarComponent = FcrToolBarUIComponent(userController: contextPool.user,
                                                              delegate: self)
    
    /** 教具 控制器*/
    private lazy var classToolsComponent = FcrClassToolsUIComponent(roomController: contextPool.room,
                                                                    userController: contextPool.user,
                                                                    monitorController: contextPool.monitor,
                                                                    widgetController: contextPool.widget)
    
    /** 课堂状态 控制器（仅教师端）*/
    private lazy var classStateComponent = FcrClassStateUIComponent(roomController: contextPool.room,
                                                                    widgetController: contextPool.widget,
                                                                    delegate: self)
    
    // MARK: - Suspend components
    /** 设置界面 控制器*/
    private lazy var settingComponent = FcrSettingUIComponent(mediaController: contextPool.media,
                                                              widgetController: contextPool.widget,
                                                              delegate: self,
                                                              exitDelegate: self)
    
    /** 聊天窗口 控制器*/
    private lazy var chatComponent = FcrChatUIComponent(roomController: contextPool.room,
                                                        userController: contextPool.user,
                                                        widgetController: contextPool.widget,
                                                        delegate: self)
    
    /** 工具集合 控制器（观众端没有）*/
    private lazy var toolCollectionComponent = FcrToolCollectionUIComponent(userController: contextPool.user,
                                                                            widgetController: contextPool.widget,
                                                                            delegate: self)
    
    /** 花名册 控制器*/
    private lazy var nameRollComponent = FcrSmallRosterUIComponent(userController: contextPool.user,
                                                                   streamController: contextPool.stream,
                                                                   widgetController: contextPool.widget)
    
    /** 视窗菜单 控制器（仅教师端）*/
    private lazy var renderMenuComponent = FcrRenderMenuUIComponent(userController: contextPool.user,
                                                                    streamController: contextPool.stream,
                                                                    widgetController: contextPool.widget,
                                                                    delegate: self)
    
    /** 举手列表 控制器（仅老师端）*/
    private lazy var handsListComponent = FcrHandsListUIComponent(userController: contextPool.user,
                                                                  delegate: self)
    
    /** 云盘 控制器（仅教师端）*/
    private lazy var cloudComponent = FcrCloudUIComponent(roomController: contextPool.room,
                                                          widgetController: contextPool.widget,
                                                          userController: contextPool.user,
                                                          delegate: self)
    
    private var subRoom: FcrSubRoomUIScene?
    
    private lazy var watermarkWidget: AgoraBaseWidget? = {
        guard let config = contextPool.widget.getWidgetConfig(kWatermarkWidgetId) else {
            return nil
        }
        return contextPool.widget.create(config)
    }()
    
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
        if contextPool.user.getLocalUserInfo().userRole != .observer {
            contextPool.media.openLocalDevice(systemDevice: .frontCamera)
            contextPool.media.openLocalDevice(systemDevice: .mic)
        }
        
        contextPool.room.joinRoom {
            AgoraLoading.hide()
        } failure: { [weak self] error in
            AgoraLoading.hide()
            self?.exitScene(reason: .normal)
        }
        
        if let watermark = watermarkWidget?.view {
            view.addSubview(watermark)
            
            watermark.mas_makeConstraints { make in
                make?.top.equalTo()(boardComponent.view.mas_top)
                make?.bottom.equalTo()(boardComponent.view.mas_bottom)
                make?.left.equalTo()(contentView.mas_left)
                make?.right.equalTo()(contentView.mas_right)
            }
        }
        
        AgoraLoading.loading(in: view)
    }
    
    public override func didClickCtrlMaskView() {
        super.didClickCtrlMaskView()
        toolBarComponent.deselectAll()
    }
    
    // MARK: AgoraUIContentContainer
    public override func initViews() {
        super.initViews()
        
        let userRole = contextPool.user.getLocalUserInfo().userRole
        
        var componentList: [UIViewController] = [stateComponent,
                                                 settingComponent,
                                                 renderComponent,
                                                 boardComponent,
                                                 webViewComponent,
                                                 windowComponent,
                                                 nameRollComponent,
                                                 classToolsComponent,
                                                 toolBarComponent,
                                                 toolCollectionComponent,
                                                 chatComponent,
                                                 audioComponent,
                                                 globalComponent]
        
        switch userRole {
        case .teacher:
            let teacherList = [classStateComponent,
                               cloudComponent,
                               renderMenuComponent,
                               handsListComponent]
            componentList.append(contentsOf: teacherList)
            
            classStateComponent.view.agora_visible = false
            cloudComponent.view.agora_visible = false
            renderMenuComponent.view.agora_visible = false
        case .student:
            break
        case .assistant:
            break
        case .observer:
            componentList.removeAll([toolCollectionComponent,
                                     nameRollComponent,
                                     classToolsComponent])
        }
        
        for component in componentList {
            addChild(component)
            
            if [settingComponent,
                handsListComponent,
                nameRollComponent,
                chatComponent].contains(component) {
                continue
            }
            
            if [globalComponent,
                audioComponent].contains(component) {
                component.viewDidLoad()
                continue
            }
            
            contentView.addSubview(component.view)
        }
        
        // special
        boardComponent.view.clipsToBounds = true
        
        switch userRole {
        case .teacher:
            toolBarComponent.updateTools([.setting,
                                          .message,
                                          .roster,
                                          .handsList])
        case .student:
            toolBarComponent.updateTools([.setting,
                                          .message,
                                          .roster,
                                          .waveHands])
        default:
            toolBarComponent.updateTools([.setting,
                                          .message])
        }
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
        
        renderComponent.view.mas_makeConstraints { [weak self] make in
            guard let `self` = self else {
                return
            }
            
            make?.left.right().equalTo()(0)
            make?.top.equalTo()(self.stateComponent.view.mas_bottom)?.offset()(2)
            make?.bottom.equalTo()(self.boardComponent.view.mas_top)?.offset()(-2)
        }
        
        toolBarComponent.view.mas_remakeConstraints { [weak self] make in
            guard let `self` = self else {
                return
            }
            
            let right = CGFloat(UIDevice.current.agora_is_pad ? -15 : -12)
            let bottom = CGFloat(UIDevice.current.agora_is_pad ? -20 : -15)
            
            make?.right.equalTo()(self.boardComponent.view.mas_right)?.offset()(right)
            make?.bottom.equalTo()(self.boardComponent.mas_bottomLayoutGuideBottom)?.offset()(bottom)
            make?.width.equalTo()(self.toolBarComponent.suggestSize.width)
            make?.height.equalTo()(self.toolBarComponent.suggestSize.height)
        }
        
        if userRole != .observer {
            toolCollectionComponent.view.mas_makeConstraints { [weak self] make in
                guard let `self` = self else {
                    return
                }
                
                let bottom = CGFloat(UIDevice.current.agora_is_pad ? -20 : -15)
                
                make?.centerX.equalTo()(self.toolBarComponent.view.mas_centerX)
                make?.bottom.equalTo()(self.boardComponent.view)?.offset()(bottom)
                make?.width.height().equalTo()(self.toolCollectionComponent.suggestLength)
            }
        }
        
        webViewComponent.view.mas_makeConstraints { [weak self] make in
            guard let `self` = self else {
                return
            }
            
            make?.left.right().top().bottom().equalTo()(self.boardComponent.view)
        }
        
        windowComponent.view.mas_makeConstraints { [weak self] make in
            guard let `self` = self else {
                return
            }
            
            make?.left.right().top().bottom().equalTo()(self.boardComponent.view)
        }
        
        classToolsComponent.view.mas_makeConstraints { [weak self] make in
            guard let `self` = self else {
                return
            }
            
            make?.left.right().top().bottom().equalTo()(self.boardComponent.view)
        }
        
        updateRenderCollectionLayout()
    }
    
    func showStageArea(show: Bool) {
        if show {
            renderComponent.view.agora_visible = true
            boardComponent.view.mas_remakeConstraints { make in
                make?.height.equalTo()(AgoraFit.scale(307))
                make?.left.right().bottom().equalTo()(0)
            }
        } else {
            renderComponent.view.agora_visible = false
            boardComponent.view.mas_remakeConstraints { [weak self] make in
                guard let `self` = self else {
                    return
                }
                
                make?.top.equalTo()(self.stateComponent.view.mas_bottom)?.offset()(AgoraFit.scale(1))
                make?.bottom.equalTo()(self.contentView.mas_bottom)?.offset()(AgoraFit.scale(1))
                make?.left.right().equalTo()(0)
            }
        }
        
        boardComponent.updateBoardRatio()
        
        contentView.layoutIfNeeded()
    }
}

// MARK: - FcrSettingUIComponentDelegate
extension FcrSmallUIScene: FcrSettingUIComponentDelegate {
    func onShowShareView(_ view: UIView) {
        ctrlView = nil
        toolBarComponent.deselectAll()
        self.view.addSubview(view)
        view.mas_makeConstraints { make in
            make?.top.left().bottom().right().equalTo()(0)
        }
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

// MARK: - FcrDetachedStreamWindowUIComponentDelegate
extension FcrSmallUIScene: FcrDetachedStreamWindowUIComponentDelegate {
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
              let data = item.data
        else {
            return
        }
        
        let new = FcrTachedWindowRenderViewState.create(isHide: true,
                                                        data: data)
        
        renderComponent.updateItem(new,
                                   animation: false)
    }
    
    func onDidStopRenderVideoStream(streamId: String) {
        guard let item = renderComponent.getItem(streamId: streamId),
              let data = item.data
        else {
            return
        }
        
        let new = FcrTachedWindowRenderViewState.create(isHide: false,
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
            toolCollectionComponent.view.mas_remakeConstraints { [weak self] make in
                guard let `self` = self else {
                    return
                }
                
                let bottom = CGFloat(UIDevice.current.agora_is_pad ? -20 : -15)
                
                make?.centerX.equalTo()(self.toolBarComponent.view.mas_centerX)
                make?.bottom.equalTo()(self.contentView)?.offset()(bottom)
                make?.width.equalTo()(self.toolCollectionComponent.suggestLength)
                make?.height.equalTo()(self.toolCollectionComponent.suggestSpreadHeight)
            }
        } else {
            toolCollectionComponent.view.mas_remakeConstraints { [weak self] make in
                guard let `self` = self else {
                    return
                }
                
                let bottom = CGFloat(UIDevice.current.agora_is_pad ? -20 : -15)
                
                make?.centerX.equalTo()(self.toolBarComponent.view.mas_centerX)
                make?.bottom.equalTo()(self.contentView)?.offset()(bottom)
                make?.width.height().equalTo()(self.toolCollectionComponent.suggestLength)
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
            if !cloudComponent.view.agora_visible {
                cloudComponent.view.mas_remakeConstraints { [weak self] make in
                    guard let `self` = self else {
                        return
                    }
                    
                    make?.left.right().top().bottom().equalTo()(self.boardComponent.view)
                }
            }
            
            cloudComponent.view.agora_visible = !cloudComponent.view.agora_visible
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
                self.toolBarComponent.view.mas_remakeConstraints { [weak self] make in
                    guard let `self` = self else {
                        return
                    }
                    
                    let right = CGFloat(UIDevice.current.agora_is_pad ? -15 : -12)
                    let bottom = CGFloat(UIDevice.current.agora_is_pad ? -15 : -12)
                    
                    make?.right.equalTo()(self.boardComponent.view.mas_right)?.offset()(right)
                    make?.bottom.equalTo()(self.toolCollectionComponent.view.mas_top)?.offset()(bottom)
                    make?.width.equalTo()(self.toolBarComponent.suggestSize.width)
                    make?.height.equalTo()(self.toolBarComponent.suggestSize.height)
                }
            } else {
                self.toolBarComponent.view.mas_remakeConstraints { [weak self] make in
                    guard let `self` = self else {
                        return
                    }
                    
                    let right = CGFloat(UIDevice.current.agora_is_pad ? -15 : -12)
                    let bottom = CGFloat(UIDevice.current.agora_is_pad ? -20 : -15)
                    
                    make?.right.equalTo()(self.boardComponent.view.mas_right)?.offset()(right)
                    make?.bottom.equalTo()(self.boardComponent.mas_bottomLayoutGuideBottom)?.offset()(bottom)
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
extension FcrSmallUIScene: FcrTachedStreamWindowUIComponentDelegate {
    func tachedStreamWindowUIComponent(_ component: FcrTachedStreamWindowUIComponent,
                                       didPressItem item: FcrTachedWindowRenderViewState,
                                       view: UIView) {
        guard contextPool.user.getLocalUserInfo().userRole == .teacher,
              let data = item.data
        else {
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
            renderMenuComponent.view.mas_remakeConstraints { [weak self, weak view] make in
                guard let `self` = self,
                      let `view` = view else {
                    return
                }
                
                make?.top.equalTo()(view.mas_bottom)?.offset()(2)
                make?.centerX.equalTo()(centerX)
                make?.height.equalTo()(30)
                make?.width.equalTo()(self.renderMenuComponent.menuWidth)
            }
        }
    }
    
    func tachedStreamWindowUIComponent(_ component: FcrTachedStreamWindowUIComponent,
                                       shouldItemIsHide streamId: String) -> Bool {
        if let _ = windowComponent.dataSource.firstItem(streamId: streamId) {
            return true
        } else {
            return false
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
        
        classStateComponent.view.agora_visible = true
        
        let left: CGFloat = UIDevice.current.agora_is_pad ? 198 : 192
        
        classStateComponent.view.mas_makeConstraints { [weak self] make in
            guard let `self` = self else {
                return
            }
            
            let bottom = CGFloat(UIDevice.current.agora_is_pad ? -20 : -15)
            
            make?.left.equalTo()(self.contentView)?.offset()(left)
            make?.bottom.equalTo()(self.contentView)?.offset()(bottom)
            make?.size.equalTo()(self.classStateComponent.suggestSize)
        }
    }
}

// MARK: - FcrRoomGlobalUIComponentDelegate
extension FcrSmallUIScene: FcrRoomGlobalUIComponentDelegate {
    func onAreaUpdated(type: FcrAreaViewType) {
        if !type.contains(.stage) {
            showStageArea(show: false)
            renderComponent.viewWillInactive()
        }
        
        if type.contains(.videoGallery) {
            windowComponent.startPreviewLocalVideo()
        } else {
            windowComponent.stopPreviewLocalVideo()
        }
        
        if type.contains(.stage) {
            showStageArea(show: true)
            renderComponent.viewWillActive()
        } else {
            
        }
    }
    
    func onLocalUserAddedToSubRoom(subRoomId: String) {
        guard UIConfig.breakoutRoom.enable,
              let subRoom = contextPool.group.createSubRoomObject(subRoomUuid: subRoomId)
        else {
            return
        }
        
        for child in children {
            guard let vc = child as? AgoraUIActivity else {
                continue
            }
            
            vc.viewWillInactive()
        }
        
        presentedViewController?.dismiss(animated: false)
        
        self.ctrlView = nil
        
        let vc = FcrSubRoomUIScene(contextPool: contextPool,
                                   subRoom: subRoom,
                                   subDelegate: self,
                                   mainDelegate: self)
        
        vc.modalPresentationStyle = .fullScreen
        
        present(vc,
                animated: true)
        
        self.subRoom = vc
    }
    
    func onLocalUserRemovedFromSubRoom(subRoomId: String,
                                       isKickOut: Bool) {
        let reason: FcrUISceneExitReason = (isKickOut ? .kickOut : .normal)
        
        subRoom?.dismiss(reason: reason,
                         animated: true)
        
        for child in children {
            guard let vc = child as? AgoraUIActivity else {
                continue
            }
            
            if let component = vc as? FcrRoomGlobalUIComponent,
               globalComponent.area.contains(.videoGallery) {
                continue
            }
            
            vc.viewWillActive()
        }
        
        self.subRoom = nil
    }
}

// MARK: - AgoraBoardUIComponentDelegate
extension FcrSmallUIScene: FcrBoardUIComponentDelegate {
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
        webViewComponent.onBoardPrivilegeListChaned(true,
                                                    userList: userList)
    }
    
    func onBoardGrantedUserListRemoved(userList: [String]) {
        updateWindowRenderItemBoardPrivilege(false,
                                             userList: userList)
        updateStreamWindowItemBoardPrivilege(false,
                                             userList: userList)
        toolCollectionComponent.onBoardPrivilegeListChaned(false,
                                                           userList: userList)
        webViewComponent.onBoardPrivilegeListChaned(false,
                                                    userList: userList)
    }
    
    func updateWindowRenderItemBoardPrivilege(_ privilege: Bool,
                                              userList: [String]) {
        for (index, item) in renderComponent.coHost.dataSource.enumerated() {
            guard var data = item.data,
                  userList.contains(data.userId)
            else {
                continue
            }
            
            guard let user = contextPool.user.getUserInfo(userUuid: data.userId),
                  user.userRole != .teacher
            else {
                continue
            }
            
            let privilege = FcrBoardPrivilegeViewState.create(privilege)
            data.boardPrivilege = privilege
            
            let new = FcrTachedWindowRenderViewState.create(isHide: item.isHide,
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
                  user.userRole != .teacher
            else {
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

// MARK: - FcrUISceneDelegate
extension FcrSmallUIScene: FcrUISceneDelegate {
    public func scene(_ manager: FcrUIScene,
                      didExit reason: FcrUISceneExitReason) {
    }
}

// MARK: - AgoraEduUISubManagerCallBack
extension FcrSmallUIScene: AgoraEduUISubManagerCallback {
    public func subNeedExitAllRooms(reason: FcrUISceneExitReason) {
        subRoom?.dismiss(reason: reason,
                         animated: false,
                         completion: { [weak self] in
            self?.exitScene(reason: reason,
                            type: .main)
        })
        
        self.subRoom = nil
    }
}

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
