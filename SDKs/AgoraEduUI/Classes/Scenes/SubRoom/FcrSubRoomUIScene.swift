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

@objc public protocol AgoraEduUISubManagerCallback: NSObjectProtocol {
    func subNeedExitAllRooms(reason: FcrUISceneExitReason)
}
/// 房间控制器:
/// 用以处理全局状态和子控制器之间的交互关系
@objc public class FcrSubRoomUIScene: FcrUIScene {
    // MARK: - Flat components
    /** 房间状态 控制器*/
    private lazy var stateComponent = FcrRoomStateUIComponent(context: contextPool,
                                                              subRoom: subRoom)
    
    /** 视窗渲染 控制器*/
    private lazy var renderComponent = FcrSmallWindowRenderUIComponent(context: contextPool,
                                                                       subRoom: subRoom,
                                                                       delegate: self,
                                                                       componentDataSource: self)
    
    /** 白板的渲染 控制器*/
    private lazy var boardComponent = FcrBoardUIComponent(context: contextPool,
                                                          subRoom: subRoom,
                                                          delegate: self)
    
    /** 大窗 控制器*/
    private lazy var windowComponent = FcrStreamWindowUIComponent(context: contextPool,
                                                                  subRoom: subRoom,
                                                                  delegate: self,
                                                                  componentDataSource: self)
    
    /** 外部链接 控制器*/
    private lazy var webViewComponent = FcrWebViewUIComponent(context: contextPool)
    
    /** 工具栏*/
    private lazy var toolBarComponent = FcrToolBarUIComponent(context: contextPool,
                                                              subRoom: subRoom,
                                                              delegate: self)
    
    /** 教具 控制器*/
    private lazy var classToolsComponent = FcrClassToolsUIComponent(context: contextPool,
                                                                    subRoom: subRoom)
    
    /** 全局状态 控制器（自身不包含UI）*/
    private lazy var globalComponent = FcrRoomGlobalUIComponent(context: contextPool,
                                                                subRoom: subRoom)
    
    // MARK: - Suspend components
    /** 设置界面 控制器*/
    private lazy var settingComponent = FcrSettingUIComponent(context: contextPool,
                                                              subRoom: subRoom,
                                                              exitDelegate: self)
    
    /** 聊天窗口 控制器*/
    private lazy var chatComponent = FcrChatUIComponent(context: contextPool,
                                                        subRoom: subRoom,
                                                        delegate: self)
    
    /** 工具集合 控制器（观众端没有）*/
    private lazy var toolCollectionComponent = FcrToolCollectionUIComponent(context: contextPool,
                                                                            subRoom: subRoom,
                                                                            delegate: self)
    
    /** 花名册 控制器*/
    private lazy var nameRollComponent = FcrUserListUIComponent(context: contextPool,
                                                                subRoom: subRoom)
    
    /** 视窗菜单 控制器（仅教师端）*/
    private lazy var renderMenuComponent = FcrRenderMenuUIComponent(context: contextPool,
                                                                    subRoom: subRoom,
                                                                    delegate: self)
    
    /** 举手列表 控制器（仅老师端）*/
    private lazy var handsListComponent = FcrHandsListUIComponent(context: contextPool,
                                                                  subRoom: subRoom,
                                                                  delegate: self)
    
    /** 云盘 控制器（仅教师端）*/
    private lazy var cloudComponent = FcrCloudUIComponent(context: contextPool,
                                                          delegate: self,
                                                          subRoom: subRoom)
    
    private weak var mainDelegate: AgoraEduUISubManagerCallback?
    
    private var subRoom: AgoraEduSubRoomContext
    
    private var isJoinedRoom = false
    private var curStageOn = true
    
    init(contextPool: AgoraEduContextPool,
         subRoom: AgoraEduSubRoomContext,
         subDelegate: FcrUISceneDelegate?,
         mainDelegate: AgoraEduUISubManagerCallback?) {
        self.subRoom = subRoom
        self.mainDelegate = mainDelegate
        super.init(sceneType: .small,
                   contextPool: contextPool,
                   delegate: subDelegate)
    }
    
    deinit {
        print("\(#function): \(self.classForCoder)")
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    public override func viewDidLoad() {
        super.viewDidLoad()
        
        updateRenderCollectionLayout()
        
        subRoom.joinSubRoom { [weak self] in
            AgoraLoading.hide()
            
            guard let `self` = self else {
                return
            }
            
            self.isJoinedRoom = true
            self.view.agora_visible = UIConfig.breakoutRoom.visible
            
            if self.subRoom.user.getLocalUserInfo().userRole == .teacher {
                self.contextPool.media.openLocalDevice(systemDevice: .frontCamera)
                self.contextPool.media.openLocalDevice(systemDevice: .mic)
            }
        } failure: { [weak self] error in
            AgoraLoading.hide()
            self?.exitScene(reason: .normal,
                            type: .sub)
        }
    }
    
    public override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        if isJoinedRoom == false {
            let subRoomName = subRoom.getSubRoomInfo().subRoomName
            let message = "fcr_group_joining".agedu_localized().replacingOccurrences(of: String.agedu_localized_replacing_x(),
                                                                                     with: subRoomName)
            
            AgoraLoading.loading(message: message)
        }
    }
    
    public override func didClickCtrlMaskView() {
        super.didClickCtrlMaskView()
        toolBarComponent.deselectAll()
    }
    
    @objc public override func exitScene(reason: FcrUISceneExitReason,
                                         type: FcrUISceneExitType) {
        let roomId = subRoom.getSubRoomInfo().subRoomUuid
        let userId = subRoom.user.getLocalUserInfo().userUuid
        let group = contextPool.group
        
        switch type {
        case .main:
            group.removeUserListFromSubRoom(userList: [userId],
                                            subRoomUuid: roomId,
                                            success: { [weak self] in
                guard let `self` = self else {
                    return
                }
                
                self.mainDelegate?.subNeedExitAllRooms(reason: reason)
            }, failure: nil)
        case .sub:
            group.removeUserListFromSubRoom(userList: [userId],
                                            subRoomUuid: roomId,
                                            success: nil,
                                            failure: nil)
        }
    }
    
    func dismiss(reason: FcrUISceneExitReason,
                 animated flag: Bool,
                 completion: (() -> Void)? = nil) {
        subRoom.leaveSubRoom()
        
        dismiss(animated: flag) { [weak self] in
            guard let `self` = self else {
                return
            }
            
            self.delegate?.scene(self,
                                 didExit: reason)
            
            completion?()
        }
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
        case .student:
            toolBarComponent.updateTools([.help,
                                          .setting,
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
            
            addChild(handsListComponent)
            
            addChild(renderMenuComponent)
            renderMenuComponent.view.isHidden = true
            contentView.addSubview(renderMenuComponent.view)
            
            addChild(cloudComponent)
            cloudComponent.view.isHidden = true
            contentView.addSubview(cloudComponent.view)
            
            addChild(toolCollectionComponent)
            toolCollectionComponent.view.isHidden = true
            
            contentView.addSubview(toolCollectionComponent.view)
        case .student:
            addChild(nameRollComponent)
            
            addChild(toolCollectionComponent)
            contentView.addSubview(toolCollectionComponent.view)
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
        }
        
        renderComponent.view.mas_makeConstraints { make in
            make?.left.right().equalTo()(0)
            make?.top.equalTo()(stateComponent.view.mas_bottom)?.offset()(AgoraFit.scale(1))
            make?.bottom.equalTo()(boardComponent.view.mas_top)?.offset()(AgoraFit.scale(-1))
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
    }
    
    public override func updateViewProperties() {
        super.updateViewProperties()
    }
}

// MARK: - FcrWindowRenderUIComponentDelegate
extension FcrSubRoomUIScene: FcrWindowRenderUIComponentDelegate {
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
                make?.bottom.equalTo()(view.mas_bottom)?.offset()(1)
                make?.centerX.equalTo()(view.mas_centerX)
                make?.height.equalTo()(30)
                make?.width.equalTo()(renderMenuComponent.menuWidth)
            }
        }
    }
}

// MARK: - AgoraBoardUIComponentDelegate
extension FcrSubRoomUIScene: FcrBoardUIComponentDelegate {
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

// MARK: - AgoraToolBarDelegate
extension FcrSubRoomUIScene: FcrToolBarComponentDelegate {
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
            if handsListComponent.dataSource.count > 0 {
                handsListComponent.view.frame = CGRect(origin: .zero,
                                                       size: handsListComponent.suggestSize)
                ctrlView = handsListComponent.view
            }
        case .help:
            toolsViewDidSelectHelp()
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
extension FcrSubRoomUIScene: FcrStreamWindowUIComponentDelegate {
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
extension FcrSubRoomUIScene: FcrCloudUIComponentDelegate {
    func onOpenAlfCourseware(urlString: String,
                             resourceId: String) {
        webViewComponent.openWebView(urlString: urlString,
                                     resourceId: resourceId)
    }
}

// MARK: - AgoraToolCollectionUIComponentDelegate
extension FcrSubRoomUIScene: FcrToolCollectionUIComponentDelegate {
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
}
// MARK: - AgoraChatUIComponentDelegate
extension FcrSubRoomUIScene: FcrHandsListUIComponentDelegate {
    func updateHandsListRedLabel(_ count: Int) {
        if count == 0,
           ctrlView == handsListComponent.view {
            ctrlView = nil
        }
        toolBarComponent.updateHandsListCount(count)
    }
}

// MARK: - AgoraChatUIComponentDelegate
extension FcrSubRoomUIScene: FcrChatUIComponentDelegate {
    func updateChatRedDot(isShow: Bool) {
        toolBarComponent.updateChatRedDot(isShow: isShow)
    }
}

// MARK: - AgoraRenderMenuUIComponentDelegate
extension FcrSubRoomUIScene: FcrRenderMenuUIComponentDelegate {
    func onMenuUserLeft() {
        renderMenuComponent.dismissView()
        renderMenuComponent.view.isHidden = true
    }
}

// MARK: - FcrUIcomponentDataSource
extension FcrSubRoomUIScene: FcrUIComponentDataSource {
    func componentNeedGrantedUserList() -> [String] {
        return boardComponent.grantedUsers
    }
}

// MARK: - Private
private extension FcrSubRoomUIScene {
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
    
    func teacherInRoom() -> FcrTeacherInRoomType {
        let group = contextPool.group
        let mainUser = contextPool.user
        let subUser = subRoom.user
        
        guard let mainTeacher = mainUser.getUserList(role: .teacher)?.first else {
            return .none
        }
        
        let localSubTeacher = subUser.getUserList(role: .teacher)?.first
        
        guard localSubTeacher == nil else {
            return .localSub
        }
        
        guard let subRoomList = group.getSubRoomList() else {
            return .none
        }
        
        let localUserId = subUser.getLocalUserInfo().userUuid
        let teacherId = mainTeacher.userUuid
        
        for item in subRoomList {
            if let userList = group.getUserListFromSubRoom(subRoomUuid: item.subRoomUuid),
               userList.contains(teacherId),
               !userList.contains(localUserId) {
                return .otherSub
            }
        }
        
        return .none
    }
    
    func toolsViewDidSelectHelp() {
        switch teacherInRoom() {
        case .localSub:
            AgoraToast.toast(message: "fcr_group_teacher_exist_hint".agedu_localized(),
                             type: .warning)
        case .otherSub:
            AgoraToast.toast(message: "fcr_group_teacher_is_helping_others_msg".agedu_localized(),
                             type: .warning)
        default:
            guard let userList = contextPool.user.getUserList(role: .teacher),
                  let teacherUserId = userList.first?.userUuid else {
                      break
                  }
            
            globalComponent.isRequestingHelp = true
            
            let actionInvite = AgoraAlertAction(title: "fcr_group_invite".agedu_localized(), action: { [weak self] in
                guard let `self` = self else {
                    return
                }
                let roomId = self.subRoom.getSubRoomInfo().subRoomUuid
                self.contextPool.group.inviteUserListToSubRoom(userList: [teacherUserId],
                                                               subRoomUuid: roomId,
                                                               success: nil,
                                                               failure: nil)
            })
            
            let actionCancel = AgoraAlertAction(title: "fcr_group_cancel".agedu_localized(),
                                                action: nil)
            
            AgoraAlertModel()
                .setTitle("fcr_group_help_title".agedu_localized())
                .setMessage("fcr_group_help_content".agedu_localized())
                .addAction(action: actionCancel)
                .addAction(action: actionInvite)
                .show(in: self)
        }
    }
}
