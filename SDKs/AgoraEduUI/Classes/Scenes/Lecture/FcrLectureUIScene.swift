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
@objc public class FcrLectureUIScene: FcrUIScene {
    /** 花名册 控制器 （教师端）*/
    private lazy var nameRollComponent = FcrUserListUIComponent(context: contextPool)
    
    /** 设置界面 控制器*/
    private lazy var settingViewComponent: FcrSettingUIComponent = {
        let vc = FcrSettingUIComponent(context: contextPool,
                                       exitDelegate: self)
        self.addChild(vc)
        return vc
    }()
    /** 举手列表 控制器（仅教师端）*/
    private lazy var handsListComponent: FcrHandsListUIComponent = {
        let vc = FcrHandsListUIComponent(context: contextPool,
                                         delegate: self)
        self.addChild(vc)
        return vc
    }()
    /** 视窗菜单 控制器（仅教师端）*/
    private lazy var renderMenuComponent: FcrRenderMenuUIComponent = {
        let vc = FcrRenderMenuUIComponent(context: contextPool)
        vc.delegate = self
        return vc
    }()
    
    /** 工具栏*/
    private lazy var toolBarComponent = FcrToolBarUIComponent(context: contextPool)
    /** 房间状态 控制器*/
    private lazy var stateComponent = FcrRoomStateUIComponent(context: contextPool)
    /** 全局状态 控制器（自身不包含UI）*/
    private lazy var globalComponent = FcrRoomGlobalUIComponent(context: contextPool,
                                                                delegate: nil)
    /** 课堂状态 控制器（仅教师端）*/
    private lazy var classStateComponent = FcrClassStateUIComponent(context: contextPool,
                                                                    delegate: self)
    /** 老师渲染 控制器*/
    private lazy var teacherRenderComponent = FcrLectureWindowRenderUIComponent(context: contextPool,
                                                                                dataSource: [FcrWindowRenderViewState.none],
                                                                                reverseItem: false,
                                                                                delegate: self)
    /** 白板 控制器*/
    private lazy var boardComponent = FcrLectureBoardUIComponent(context: contextPool,
                                                                 delegate: self)
    
    /** 工具集合 控制器（观众端没有）*/
    private lazy var toolCollectionComponent = FcrToolCollectionUIComponent(context: contextPool,
                                                                            delegate: self)
    /** 大窗 控制器*/
    private lazy var windowComponent = FcrLectureStreamWindowUIComponent(context: contextPool,
                                                                         delegate: self,
                                                                         componentDataSource: self)
    /** 外部链接 控制器*/
    private lazy var webViewComponent = FcrWebViewUIComponent(context: contextPool)
    /** 云盘 控制器（仅教师端）*/
    private lazy var cloudComponent = FcrCloudUIComponent(context: contextPool,
                                                          delegate: self)
    /** 教具 控制器*/
    private lazy var classToolsComponent = FcrClassToolsUIComponent(context: contextPool)
    /** 聊天窗口 控制器*/
    private lazy var chatComponent = FcrChatUIComponent(context: contextPool)
    
    private var isJoinedRoom = false
    
    @objc public init(contextPool: AgoraEduContextPool,
                      delegate: FcrUISceneDelegate?) {
        super.init(sceneType: .lecture,
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
            
            if self.contextPool.user.getLocalUserInfo().userRole == .teacher {
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
        
        addChild(stateComponent)
        contentView.addSubview(stateComponent.view)
        
        globalComponent.roomDelegate = self
        addChild(globalComponent)
        globalComponent.viewDidLoad()
        
        addChild(teacherRenderComponent)
        contentView.addSubview(teacherRenderComponent.view)
        
        // 视图层级：白板，大窗，工具
        addChild(boardComponent)
        contentView.addSubview(boardComponent.view)
        
        addChild(webViewComponent)
        contentView.addSubview(webViewComponent.view)
        
        addChild(windowComponent)
        contentView.addSubview(windowComponent.view)
        
        toolBarComponent.delegate = self
        
        if userRole == .teacher {
            addChild(classToolsComponent)
            contentView.addSubview(classToolsComponent.view)
            classToolsComponent.view.agora_enable = UIConfig.toolBox.enable
            classToolsComponent.view.agora_visible = UIConfig.toolBox.visible
            
            addChild(toolCollectionComponent)
            contentView.addSubview(toolCollectionComponent.view)
            toolCollectionComponent.view.agora_enable = UIConfig.toolCollection.enable
            toolCollectionComponent.view.agora_visible = false
            
            toolBarComponent.updateTools([.setting, .roster, .handsList])
            addChild(classStateComponent)
            addChild(handsListComponent)
            addChild(nameRollComponent)
            addChild(renderMenuComponent)
            contentView.addSubview(renderMenuComponent.view)
            addChild(cloudComponent)
            contentView.addSubview(cloudComponent.view)
            
            renderMenuComponent.view.isHidden = true
            cloudComponent.view.isHidden = true
        } else if userRole == .student {
            addChild(classToolsComponent)
            contentView.addSubview(classToolsComponent.view)
            classToolsComponent.view.agora_enable = UIConfig.toolBox.enable
            classToolsComponent.view.agora_visible = UIConfig.toolBox.visible
            
            addChild(toolCollectionComponent)
            contentView.addSubview(toolCollectionComponent.view)
            toolCollectionComponent.view.agora_enable = UIConfig.toolCollection.enable
            toolCollectionComponent.view.agora_visible = false
            
            toolBarComponent.updateTools([.setting, .waveHands])
        } else {
            toolBarComponent.updateTools([.setting])
        }
        contentView.addSubview(toolBarComponent.view)
        
        addChild(chatComponent)
        contentView.addSubview(chatComponent.view)
        contentView.sendSubviewToBack(chatComponent.view)
        
        stateComponent.view.agora_enable = UIConfig.stateBar.enable
        stateComponent.view.agora_visible = UIConfig.stateBar.visible
        
        boardComponent.view.agora_enable = UIConfig.netlessBoard.enable
        boardComponent.view.agora_visible = UIConfig.netlessBoard.visible
        
        settingViewComponent.view.agora_enable = UIConfig.setting.enable
        settingViewComponent.view.agora_visible = UIConfig.setting.visible
        
        toolBarComponent.view.agora_enable = UIConfig.toolBar.enable
        toolBarComponent.view.agora_visible = UIConfig.toolBar.visible
    }
    
    public override func initViewFrame() {
        super.initViewFrame()
        let userRole = contextPool.user.getLocalUserInfo().userRole
        
        stateComponent.view.mas_makeConstraints { make in
            make?.top.left().right().equalTo()(0)
            make?.height.equalTo()(UIDevice.current.agora_is_pad ? 24 : 14)
        }
        
        webViewComponent.view.mas_makeConstraints { make in
            make?.left.right().top().bottom().equalTo()(boardComponent.view)
        }
        
        windowComponent.view.mas_makeConstraints { make in
            make?.left.right().top().bottom().equalTo()(boardComponent.view)
        }
        
        teacherRenderComponent.view.mas_makeConstraints { make in
            make?.top.equalTo()(stateComponent.view.mas_bottom)?.offset()(2)
            make?.right.equalTo()(0)
            make?.width.equalTo()(AgoraFit.scale(170))
            make?.height.equalTo()(AgoraFit.scale(112))
        }
        
        boardComponent.view.mas_makeConstraints { make in
            make?.left.bottom().equalTo()(0)
            make?.right.equalTo()(teacherRenderComponent.view.mas_left)?.offset()(-2)
            make?.top.equalTo()(self.stateComponent.view.mas_bottom)?.offset()(2)
        }
        
        toolBarComponent.view.mas_remakeConstraints { make in
            make?.right.equalTo()(self.boardComponent.view.mas_right)?.offset()(UIDevice.current.agora_is_pad ? -15 : -12)
            make?.bottom.equalTo()(self.boardComponent.mas_bottomLayoutGuideBottom)?.offset()(UIDevice.current.agora_is_pad ? -20 : -15)
            make?.width.equalTo()(self.toolBarComponent.suggestSize.width)
            make?.height.equalTo()(self.toolBarComponent.suggestSize.height)
        }
        
        if userRole != .observer {
            toolCollectionComponent.view.mas_makeConstraints { make in
                make?.centerX.equalTo()(self.toolBarComponent.view.mas_centerX)
                make?.bottom.equalTo()(contentView)?.offset()(UIDevice.current.agora_is_pad ? -20 : -15)
                make?.width.height().equalTo()(toolCollectionComponent.suggestLength)
            }
            classToolsComponent.view.mas_makeConstraints { make in
                make?.left.right().top().bottom().equalTo()(boardComponent.view)
            }
        }
        
        chatComponent.view.mas_makeConstraints { make in
            make?.top.equalTo()(teacherRenderComponent.view.mas_bottom)?.offset()(2)
            make?.left.right().equalTo()(teacherRenderComponent.view)
            make?.bottom.equalTo()(0)
        }
        
        updateRenderLayout()
    }
    
    public override func updateViewProperties() {
        super.updateViewProperties()
        teacherRenderComponent.view.layer.cornerRadius = FcrUIFrameGroup.windowCornerRadius
        teacherRenderComponent.view.clipsToBounds = true
    }
}


// MARK: - AgoraBoardUIComponentDelegate
extension FcrLectureUIScene: FcrBoardUIComponentDelegate {
    func onStageStateChanged(stageOn: Bool) {
        
    }
    
    func onBoardActiveStateChanged(isActive: Bool) {
        toolCollectionComponent.updateBoardActiveState(isActive: isActive)
    }
    
    func onBoardGrantedUserListAdded(userList: [String]) {
        updateStreamWindowItemBoardPrivilege(true,
                                             userList: userList)
        toolCollectionComponent.onBoardPrivilegeListChaned(true,
                                                           userList: userList)
    }
    
    func onBoardGrantedUserListRemoved(userList: [String]) {
        updateStreamWindowItemBoardPrivilege(false,
                                             userList: userList)
        toolCollectionComponent.onBoardPrivilegeListChaned(false,
                                                           userList: userList)
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

// MARK: - FcrStreamWindowUIComponentDelegate
extension FcrLectureUIScene: FcrStreamWindowUIComponentDelegate {
    func onNeedWindowRenderViewFrameOnTopWindow(userId: String) -> CGRect? {
        guard let renderView = teacherRenderComponent.getRenderView(userId: userId) else {
            return nil
        }
        
        let frame = renderView.convert(renderView.frame,
                                       to: UIWindow.agora_top_window())
        
        return frame
    }
    
    func onWillStartRenderVideoStream(streamId: String) {
        guard let item = teacherRenderComponent.getItem(streamId: streamId),
              let data = item.data else {
                  return
              }
        
        let new = FcrWindowRenderViewState.create(isHide: true,
                                                  data: data)
        
        teacherRenderComponent.updateItem(new,
                                          animation: false)
    }
    
    func onDidStopRenderVideoStream(streamId: String) {
        guard let item = teacherRenderComponent.getItem(streamId: streamId),
              let data = item.data else {
                  return
              }
        
        let new = FcrWindowRenderViewState.create(isHide: false,
                                                  data: data)
        
        teacherRenderComponent.updateItem(new,
                                          animation: false)
    }
}

// MARK: - AgoraCloudUIComponentDelegate
extension FcrLectureUIScene: FcrCloudUIComponentDelegate {
    func onOpenAlfCourseware(urlString: String,
                             resourceId: String) {
        webViewComponent.openWebView(urlString: urlString,
                                     resourceId: resourceId)
    }
}

// MARK: - AgoraToolBarDelegate
extension FcrLectureUIScene: FcrToolBarComponentDelegate {
    func toolsViewDidSelectTool(tool: FcrToolBarItemType,
                                selectView: UIView) {
        switch tool {
        case .setting:
            settingViewComponent.view.frame = CGRect(origin: .zero,
                                                     size: settingViewComponent.suggestSize)
            ctrlView = settingViewComponent.view
        case .roster:
            nameRollComponent.view.frame = CGRect(origin: .zero,
                                                  size: nameRollComponent.suggestSize)
            ctrlView = nameRollComponent.view
        case .handsList:
            if handsListComponent.dataSource.count > 0 {
                handsListComponent.view.frame = CGRect(origin: .zero,
                                                       size: handsListComponent.suggestSize)
                ctrlView = handsListComponent.view
            }
        default:
            break
        }
        ctrlViewAnimationFromView(selectView)
    }
    
    func toolsViewDidDeselectTool(tool: FcrToolBarItemType) {
        ctrlView = nil
    }
}

// MARK: - AgoraRenderMenuUIComponentDelegate
extension FcrLectureUIScene: FcrRenderMenuUIComponentDelegate {
    func onMenuUserLeft() {
        renderMenuComponent.dismissView()
        renderMenuComponent.view.isHidden = true
    }
}

// MARK: - FcrWindowRenderUIComponentDelegate
extension FcrLectureUIScene: FcrWindowRenderUIComponentDelegate {
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
            renderMenuComponent.show(roomType: .lecture,
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

// MARK: - AgoraChatUIComponentDelegate
extension FcrLectureUIScene: FcrHandsListUIComponentDelegate {
    func updateHandsListRedLabel(_ count: Int) {
        if count == 0,
           ctrlView == handsListComponent.view {
            ctrlView = nil
        }
        toolBarComponent.updateHandsListCount(count)
    }
}

// MARK: - AgoraToolCollectionUIComponentDelegate
extension FcrLectureUIScene: FcrToolCollectionUIComponentDelegate {
    func toolCollectionDidSelectCell(view: UIView) {
        renderMenuComponent.dismissView()
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

// MARK: - AgoraClassStateUIComponentDelegate
extension FcrLectureUIScene: FcrClassStateUIComponentDelegate {
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

// MARK: - FcrUIcomponentDataSource
extension FcrLectureUIScene: FcrUIComponentDataSource {
    func componentNeedGrantedUserList() -> [String] {
        return boardComponent.grantedUsers
    }
}

private extension FcrLectureUIScene {
    func updateRenderLayout() {
        view.layoutIfNeeded()
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .horizontal
        
        layout.itemSize = CGSize(width: teacherRenderComponent.view.width - 2,
                                 height: teacherRenderComponent.view.height - 2)
        layout.minimumLineSpacing = 2
        teacherRenderComponent.updateLayout(layout)
    }
}
