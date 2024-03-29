//
//  AgoraOneToOneUIManager.swift
//  AgoraEduUI
//
//  Created by Jonathan on 2021/11/15.
//

import AgoraUIBaseViews
import AgoraEduCore
import AgoraWidget
import Masonry
import UIKit

@objc public class FcrOneToOneUIScene: FcrUIScene {
    /** 全局状态 控制器（自身不包含UI）*/
    private lazy var globalComponent = FcrRoomGlobalUIComponent(roomController: contextPool.room,
                                                                userController: contextPool.user,
                                                                monitorController: contextPool.monitor,
                                                                streamController: contextPool.stream,
                                                                groupController: contextPool.group,
                                                                exitDelegate: self)
    
    /** 音频流 控制器（自身不包含UI）*/
    private lazy var audioComponent = FcrAudioStreamUIComponent(roomController: contextPool.room,
                                                                streamController: contextPool.stream,
                                                                userController: contextPool.user,
                                                                mediaController: contextPool.media,
                                                                subscribeAll: true)
    
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
    private lazy var cloudComponent = FcrCloudDriveUIComponent(roomController: contextPool.room,
                                                               widgetController: contextPool.widget,
                                                               userController: contextPool.user,
                                                               delegate: self)
    
    /** 设置界面 控制器*/
    private lazy var settingComponent = FcrSettingUIComponent(mediaController: contextPool.media,
                                                              widgetController: contextPool.widget,
                                                              delegate: self,
                                                              exitDelegate: self)
    
    /** 状态栏 控制器*/
    private lazy var stateComponent = FcrRoomStateUIComponent(roomController: contextPool.room,
                                                              userController: contextPool.user,
                                                              monitorController: contextPool.monitor,
                                                              groupController: contextPool.group,
                                                              delegate: self)
    
    private lazy var networkStatsComponent = FcrNetworkStatsUIComponent(roomId: contextPool.room.getRoomInfo().roomUuid,
                                                                        monitorController: contextPool.monitor)
   
    /** 工具栏*/
    private lazy var toolBarComponent = FcrToolBarUIComponent(userController: contextPool.user,
                                                              delegate: self)
    
    /** 渲染 控制器*/
    private lazy var renderComponent = FcrOneToOneTachedWindowUIComponent(roomController: contextPool.room,
                                                                          userController: contextPool.user,
                                                                          mediaController: contextPool.media,
                                                                          streamController: contextPool.stream,
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
    private lazy var windowComponent = FcrDetachedStreamWindowUIComponent(roomController: contextPool.room,
                                                                          userController: contextPool.user,
                                                                          streamController: contextPool.stream,
                                                                          mediaController: contextPool.media,
                                                                          widgetController: contextPool.widget,
                                                                          delegate: self,
                                                                          componentDataSource: self)
    
    private lazy var watermarkComponent = FcrWatermarkUIComponent(widgetController: contextPool.widget)
    
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
                                                 boardComponent,
                                                 renderComponent,
                                                 webViewComponent,
                                                 windowComponent,
                                                 classToolsComponent,
                                                 toolBarComponent,
                                                 toolCollectionComponent,
                                                 chatComponent,
                                                 watermarkComponent,
                                                 audioComponent,
                                                 globalComponent]
        
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
            componentList.removeAll([toolCollectionComponent])
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
            
            if [globalComponent,
                audioComponent].contains(component) {
                component.viewDidLoad()
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
            let height = CGFloat(UIDevice.current.agora_is_pad ? 24 : 14)
            make?.top.left().right().equalTo()(0)
            make?.height.equalTo()(height)
        }
        
        if UIDevice.current.agora_is_pad {
            renderComponent.view.mas_makeConstraints { [weak self] make in
                guard let `self` = self else {
                    return
                }
                
                make?.top.equalTo()(self.stateComponent.view.mas_bottom)?.offset()(2)
                make?.right.equalTo()(0)
                make?.width.equalTo()(244)
                make?.height.equalTo()(276)
            }
            
            chatComponent.view.mas_makeConstraints { [weak self] make in
                guard let `self` = self else {
                    return
                }
                
                make?.top.equalTo()(self.renderComponent.view.mas_bottom)?.offset()(2)
                make?.left.right().equalTo()(self.renderComponent.view)
                make?.bottom.equalTo()(0)
            }
        } else {
            renderComponent.view.mas_makeConstraints { [weak self] make in
                guard let `self` = self else {
                    return
                }
                
                make?.top.equalTo()(self.stateComponent.view.mas_bottom)?.offset()(2)
                make?.width.equalTo()(157)
                make?.bottom.right().equalTo()(0)
            }
        }
        
        boardComponent.view.mas_makeConstraints { [weak self] make in
            guard let `self` = self else {
                return
            }
            
            make?.left.bottom().equalTo()(0)
            make?.right.equalTo()(self.renderComponent.view.mas_left)?.offset()(-2)
            make?.top.equalTo()(self.stateComponent.view.mas_bottom)?.offset()(2)
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
                make?.bottom.equalTo()(self.contentView)?.offset()(bottom)
                make?.width.height().equalTo()(self.toolCollectionComponent.suggestLength)
            }
        }
        
        classToolsComponent.view.mas_makeConstraints { [weak self] make in
            guard let `self` = self else {
                return
            }
            
            make?.left.right().top().bottom().equalTo()(self.boardComponent.view)
        }
        
        watermarkComponent.view.mas_makeConstraints { [weak self] make in
            guard let `self` = self else {
                return
            }
            
            make?.top.equalTo()(self.boardComponent.view.mas_top)
            make?.bottom.equalTo()(self.boardComponent.view.mas_bottom)
            make?.left.equalTo()(self.contentView.mas_left)
            make?.right.equalTo()(self.contentView.mas_right)
        }
        
        updateRenderLayout()
    }
}

// MARK: - FcrSettingUIComponentDelegate
extension FcrOneToOneUIScene: FcrSettingUIComponentDelegate {
    func onShowShareView(_ view: UIView) {
        ctrlView = nil
        toolBarComponent.deselectAll()
        self.view.addSubview(view)
        view.mas_makeConstraints { make in
            make?.top.left().bottom().right().equalTo()(0)
        }
    }
}

// MARK: - AgoraBoardUIComponentDelegate
extension FcrOneToOneUIScene: FcrBoardUIComponentDelegate {
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

// MARK: - AgoraWindowUIComponentDelegate
extension FcrOneToOneUIScene: FcrDetachedStreamWindowUIComponentDelegate {
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
extension FcrOneToOneUIScene: FcrCloudDriveUIComponentDelegate {
    func onSelectedFile(fileJson: [String: Any],
                        fileExt: String) {
        switch fileExt {
        case "alf":
            webViewComponent.openWebView(fileJson: fileJson)
        default:
            boardComponent.openFile(fileJson)
            break
        }
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

// MARK: - FcrWindowRenderUIComponentDelegate
extension FcrOneToOneUIScene: FcrTachedStreamWindowUIComponentDelegate {
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
            renderMenuComponent.show(roomType: .oneToOne,
                                     userUuid: userId,
                                     showRoleType: role)
            
            renderMenuComponent.view.mas_remakeConstraints { [weak self,
                                                              weak view] make in
                guard let `self` = self,
                      let `view` = view
                else {
                    return
                }
                
                make?.bottom.equalTo()(view.mas_bottom)?.offset()(-5)
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
        
        classStateComponent.view.mas_makeConstraints { [weak self] make in
            guard let `self` = self else {
                return
            }
            
            let bottom = CGFloat(UIDevice.current.agora_is_pad ? -20 : -15)
            
            make?.left.equalTo()(contentView)?.offset()(left)
            make?.bottom.equalTo()(contentView)?.offset()(bottom)
            make?.size.equalTo()(classStateComponent.suggestSize)
        }
    }
    
    func onHideStartClass() {
        guard contextPool.user.getLocalUserInfo().userRole == .teacher else {
            return
        }
        
        classStateComponent.view.agora_visible = false
    }
}

// MARK: - FcrRoomStateUIComponentDelegate
extension FcrOneToOneUIScene: FcrRoomStateUIComponentDelegate {
    func onPressedNetworkState() {
        ctrlView = nil
        
        networkStatsComponent.view.frame = CGRect(x: 0,
                                                  y: 0,
                                                  width: 130,
                                                  height: 136)
        
        showPopover(contentView: networkStatsComponent.view,
                    fromView: stateComponent.stateView.netStateView)
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
