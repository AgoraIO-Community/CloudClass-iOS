//
//  AgoraOneToOneUIManager.swift
//  AgoraEduUI
//
//  Created by Jonathan on 2021/11/15.
//

import AgoraUIBaseViews
import AgoraEduContext
import AgoraWidget
import Masonry
import UIKit

@objc public class FcrOneToOneUIScene: FcrUIScene {
    /** 课堂状态 控制器（仅教师端）*/
    private lazy var classStateComponent = FcrClassStateUIComponent(roomController: contextPool.room,
                                                                    widgetController: contextPool.widget,
                                                                    delegate: self)
    
    /** 视窗菜单 控制器（仅教师端）*/
    private lazy var renderMenuComponent = FcrRenderMenuUIComponent(userController: contextPool.user,
                                                                    streamController: contextPool.stream,
                                                                    widgetController: contextPool.widget,
                                                                    delegate: self)
    
    /** 云盘 控制器（仅教师端）*/
    private lazy var cloudComponent = FcrCloudUIComponent(roomController: contextPool.room,
                                                          widgetController: contextPool.widget,
                                                          userController: contextPool.user,
                                                          delegate: self)
    
    /** 设置界面 控制器*/
    private lazy var settingComponent: FcrSettingUIComponent = {
        let vc = FcrSettingUIComponent(mediaController: contextPool.media,
                                       exitDelegate: self)
        self.addChild(vc)
        return vc
    }()
    
    /** 状态栏 控制器*/
    private lazy var stateComponent = FcrRoomStateUIComponent(roomController: contextPool.room,
                                                              userController: contextPool.user,
                                                              monitorController: contextPool.monitor,
                                                              groupController: contextPool.group)
    /** 全局状态 控制器（自身不包含UI）*/
    private lazy var globalComponent = FcrRoomGlobalUIComponent(roomController: contextPool.room,
                                                                userController: contextPool.user,
                                                                monitorController: contextPool.monitor,
                                                                streamController: contextPool.stream,
                                                                groupController: contextPool.group,
                                                                exitDelegate: self)
    /** 工具栏*/
    private lazy var toolBarComponent = FcrToolBarUIComponent(userController: contextPool.user,
                                                              delegate: self)
    
    /** 渲染 控制器*/
    private lazy var renderComponent = FcrOneToOneWindowRenderUIComponent(roomController: contextPool.room,
                                                                          userController: contextPool.user,
                                                                          mediaController: contextPool.media,
                                                                          streamController: contextPool.stream,
                                                                          widgetController: contextPool.widget,
                                                                          delegate: self,
                                                                          componentDataSource: self)
                                                                          
    /** 外部链接 控制器*/
    private lazy var webViewComponent = FcrWebViewUIComponent(roomController: contextPool.room,
                                                              userController: contextPool.user,
                                                              widgetController: contextPool.widget)
    /** 白板 控制器*/
    private lazy var boardComponent = FcrBoardUIComponent(roomController: contextPool.room,
                                                          userController: contextPool.user,
                                                          widgetController: contextPool.widget,
                                                          mediaController: contextPool.media,
                                                          delegate: self)
    
    /** 工具集合 控制器（观众端没有）*/
    private lazy var toolCollectionComponent = FcrToolCollectionUIComponent(userController: contextPool.user,
                                                                            widgetController: contextPool.widget,
                                                                            delegate: self)
    /** 聊天 控制器*/
    private lazy var chatComponent = FcrChatUIComponent(roomController: contextPool.room,
                                                        userController: contextPool.user,
                                                        widgetController: contextPool.widget,
                                                        delegate: self)
    /** 教具 控制器*/
    private lazy var classToolsComponent = FcrClassToolsUIComponent(roomController: contextPool.room,
                                                                    userController: contextPool.user,
                                                                    monitorController: contextPool.monitor,
                                                                    widgetController: contextPool.widget)
    /** 大窗 控制器*/
    private lazy var windowComponent = FcrStreamWindowUIComponent(roomController: contextPool.room,
                                                                  userController: contextPool.user,
                                                                  streamController: contextPool.stream,
                                                                  mediaController: contextPool.media,
                                                                  widgetController: contextPool.widget,
                                                                  delegate: self,
                                                                  componentDataSource: self)
    
    private var isJoinedRoom = false
    
    private var fileWriter = FcrUIFileWriter()
    
    @objc public init(contextPool: AgoraEduContextPool,
                      delegate: FcrUISceneDelegate?) {
        super.init(sceneType: .oneToOne,
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
            
            // 打开本地音视频设备
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
        
        var componentList: [UIViewController] = [stateComponent,
                                                 settingComponent,
                                                 globalComponent,
                                                 boardComponent,
                                                 renderComponent,
                                                 webViewComponent,
                                                 windowComponent,
                                                 classToolsComponent,
                                                 toolBarComponent,
                                                 toolCollectionComponent,
                                                 chatComponent]
        
        switch userRole {
        case .teacher:
            let teacherList = [classStateComponent,
                               cloudComponent,
                               renderMenuComponent]
            componentList.append(contentsOf: teacherList)
            for item in teacherList {
                item.view.agora_visible = false
            }
        case .student:
            break
        case .assistant:
            break
        case .observer:
            componentList.removeAll([toolCollectionComponent,
                                     classToolsComponent])
        }
        
        for component in componentList {
            addChild(component)
            
            if component == settingComponent {
                continue
            }
            
            if component == chatComponent,
               !UIDevice.current.agora_is_pad {
                continue
            }
            
            if component == globalComponent {
                globalComponent.viewDidLoad()
                continue
            }
            
            contentView.addSubview(component.view)
        }
        
        // special
        if UIDevice.current.agora_is_pad {
            toolBarComponent.updateTools([.setting])
        } else {
            toolBarComponent.updateTools([.setting,
                                          .message])
        }
    }
    
    public override func initViewFrame() {
        super.initViewFrame()
        
        let userRole = contextPool.user.getLocalUserInfo().userRole
        stateComponent.view.mas_makeConstraints { make in
            make?.top.left().right().equalTo()(0)
            make?.height.equalTo()(UIDevice.current.agora_is_pad ? 24 : 14)
        }
        
        if UIDevice.current.agora_is_pad {
            renderComponent.view.mas_makeConstraints { make in
                make?.top.equalTo()(stateComponent.view.mas_bottom)?.offset()(2)
                make?.right.equalTo()(0)
                make?.width.equalTo()(244)
                make?.height.equalTo()(276)
            }
            
            chatComponent.view.mas_makeConstraints { make in
                make?.top.equalTo()(renderComponent.view.mas_bottom)?.offset()(2)
                make?.left.right().equalTo()(renderComponent.view)
                make?.bottom.equalTo()(0)
            }
        } else {
            renderComponent.view.mas_makeConstraints { make in
                make?.top.equalTo()(stateComponent.view.mas_bottom)?.offset()(2)
                make?.width.equalTo()(157)
                make?.bottom.right().equalTo()(0)
            }
        }
        
        boardComponent.view.mas_makeConstraints { make in
            make?.left.bottom().equalTo()(0)
            make?.right.equalTo()(renderComponent.view.mas_left)?.offset()(-2)
            make?.top.equalTo()(self.stateComponent.view.mas_bottom)?.offset()(2)
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
        }
        
        updateRenderLayout()
    }
    
    public override func updateViewProperties() {
        super.updateViewProperties()
        
        view.backgroundColor = FcrUIColorGroup.systemBackgroundColor
    }
}

// MARK: - AgoraBoardUIComponentDelegate
extension FcrOneToOneUIScene: FcrBoardUIComponentDelegate {
    func onStageStateChanged(stageOn: Bool) {
        
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
        for (index, item) in renderComponent.dataSource.enumerated() {
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
            
            renderComponent.updateItem(new,
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

// MARK: - AgoraWindowUIComponentDelegate
extension FcrOneToOneUIScene: FcrStreamWindowUIComponentDelegate {
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
extension FcrOneToOneUIScene: FcrCloudUIComponentDelegate {
    func onOpenAlfCourseware(urlString: String,
                             resourceId: String) {
        webViewComponent.openWebView(urlString: urlString,
                                     resourceId: resourceId)
    }
}

// MARK: - AgoraToolBarDelegate
extension FcrOneToOneUIScene: FcrToolBarComponentDelegate {
    func toolsViewDidSelectTool(tool: FcrToolBarItemType,
                                selectView: UIView) {
        switch tool {
        case .setting:
            settingComponent.view.frame = CGRect(origin: .zero,
                                                     size: settingComponent.suggestSize)
            ctrlView = settingComponent.view
        case .message:
            chatComponent.view.frame = CGRect(origin: .zero,
                                              size: chatComponent.suggestSize)
            ctrlView = chatComponent.view
        default:
            break
        }
        ctrlViewAnimationFromView(selectView)
    }
    
    func toolsViewDidDeselectTool(tool: FcrToolBarItemType) {
        ctrlView = nil
    }
}

// MARK: - AgoraChatUIComponentDelegate
extension FcrOneToOneUIScene: FcrChatUIComponentDelegate {
    func updateChatRedDot(isShow: Bool) {
        toolBarComponent.updateChatRedDot(isShow: isShow)
    }
}

// MARK: - AgoraToolCollectionUIComponentDelegate
extension FcrOneToOneUIScene: FcrToolCollectionUIComponentDelegate {
    func toolCollectionDidSelectCell(view: UIView) {
        toolBarComponent.deselectAll()
        renderMenuComponent.dismissView()
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
            if !cloudComponent.view.agora_visible {
                cloudComponent.view.mas_remakeConstraints { make in
                    make?.left.right().top().bottom().equalTo()(boardComponent.view)
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

// MARK: - FcrWindowRenderUIComponentDelegate
extension FcrOneToOneUIScene: FcrWindowRenderUIComponentDelegate {
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
            renderMenuComponent.show(roomType: .oneToOne,
                                     userUuid: userId,
                                     showRoleType: role)
            renderMenuComponent.view.mas_remakeConstraints { make in
                make?.bottom.equalTo()(view.mas_bottom)?.offset()(-5)
                make?.centerX.equalTo()(centerX)
                make?.height.equalTo()(30)
                make?.width.equalTo()(renderMenuComponent.menuWidth)
            }
        }
    }
}

// MARK: - AgoraRenderMenuUIComponentDelegate
extension FcrOneToOneUIScene: FcrRenderMenuUIComponentDelegate {
    func onMenuUserLeft() {
        renderMenuComponent.dismissView()
        renderMenuComponent.view.agora_visible = false
    }
}

// MARK: - AgoraClassStateUIComponentDelegate
extension FcrOneToOneUIScene: FcrClassStateUIComponentDelegate {
    func onShowStartClass() {
        guard contextPool.user.getLocalUserInfo().userRole == .teacher else {
            return
        }
        
        classStateComponent.view.agora_visible = true
        
        let left: CGFloat = UIDevice.current.agora_is_pad ? 198 : 192
        classStateComponent.view.mas_makeConstraints { make in
            make?.left.equalTo()(contentView)?.offset()(left)
            make?.bottom.equalTo()(contentView)?.offset()(UIDevice.current.agora_is_pad ? -20 : -15)
            make?.size.equalTo()(classStateComponent.suggestSize)
        }
    }
}

extension FcrOneToOneUIScene: FcrUIComponentDataSource {
    func componentNeedGrantedUserList() -> [String] {
        return boardComponent.grantedUsers
    }
}

// MARK: - Creations
private extension FcrOneToOneUIScene {
    func updateRenderLayout() {
        view.layoutIfNeeded()
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .vertical
        
        layout.itemSize = CGSize(width: renderComponent.view.width,
                                 height: (renderComponent.view.height - 2) / 2)
        layout.minimumLineSpacing = 2
        renderComponent.updateLayout(layout)
    }
}
