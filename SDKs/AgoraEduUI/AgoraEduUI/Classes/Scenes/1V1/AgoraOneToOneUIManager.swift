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

@objc public class AgoraOneToOneUIManager: AgoraEduUIManager {
    /** 课堂状态 控制器（仅教师端）*/
    private lazy var classStateController = AgoraClassStateUIController(context: contextPool,
                                                                        delegate: self)
    
    /** 视窗菜单 控制器（仅教师端）*/
    private lazy var renderMenuController: AgoraRenderMenuUIController = {
        let vc = AgoraRenderMenuUIController(context: contextPool)
        vc.delegate = self
        return vc
    }()
    
    /** 云盘 控制器（仅教师端）*/
    private lazy var cloudController = AgoraCloudUIController(context: contextPool,
                                                              delegate: self)
    
    /** 设置界面 控制器*/
    private lazy var settingViewController: AgoraSettingUIController = {
        let vc = AgoraSettingUIController(context: contextPool,
                                          roomDelegate: self)
        self.addChild(vc)
        return vc
    }()
    
    /** 状态栏 控制器*/
    private lazy var stateController = AgoraRoomStateUIController(context: contextPool)
    /** 全局状态 控制器（自身不包含UI）*/
    private lazy var globalController = AgoraRoomGlobalUIController(context: contextPool,
                                                                    delegate: nil)
    /** 工具栏*/
    private lazy var toolBarController = AgoraToolBarUIController(context: contextPool)
    
    /** 渲染 控制器*/
    private lazy var renderController = FcrOneToOneWindowRenderUIController(context: contextPool,
                                                                            delegate: self,
                                                                            controllerDataSource: self)
    /** 外部链接 控制器*/
    private lazy var webViewController = AgoraWebViewUIController(context: contextPool)
    /** 右边用来切圆角和显示背景色的容器视图*/
//    private lazy var rightContentView = UIView()
    /** 白板 控制器*/
    private lazy var boardController = AgoraBoardUIController(context: contextPool,
                                                              delegate: self)
   
    /** 工具集合 控制器（观众端没有）*/
    private lazy var toolCollectionController = AgoraToolCollectionUIController(context: contextPool,
                                                                                delegate: self)
    /** 聊天 控制器*/
    private lazy var chatController = AgoraChatUIController(context: contextPool)
    /** 教具 控制器*/
    private lazy var classToolsController = AgoraClassToolsUIController(context: contextPool)
    /** 大窗 控制器*/
    private lazy var windowController = FcrStreamWindowUIController(context: contextPool,
                                                                    delegate: self,
                                                                    controllerDataSource: self)
    
    private var isJoinedRoom = false
    
    private var fileWriter = FcrUIFileWriter()
    
    deinit {
        print("\(#function): \(self.classForCoder)")
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
    
    // MARK: AgoraUIContentContainer
    override func initViews() {
        super.initViews()
        UIConfig = FcrOneToOneUIConfig()
        
        let userRole = contextPool.user.getLocalUserInfo().userRole
        
        addChild(stateController)
        contentView.addSubview(stateController.view)
        
        globalController.roomDelegate = self
        addChild(globalController)
        globalController.viewDidLoad()
        
        // 视图层级：白板，大窗，工具
        addChild(boardController)
        contentView.addSubview(boardController.view)
        
        addChild(renderController)
        contentView.addSubview(renderController.view)
        
        addChild(webViewController)
        contentView.addSubview(webViewController.view)
        
        addChild(windowController)
        contentView.addSubview(windowController.view)
        
        toolBarController.delegate = self
        toolBarController.updateTools([.setting, .message])
        contentView.addSubview(toolBarController.view)
        
        addChild(classToolsController)
        contentView.addSubview(classToolsController.view)
        
        if userRole != .observer {
            view.addSubview(toolCollectionController.view)
        }
        
        if userRole == .teacher {
            addChild(classStateController)
            contentView.addSubview(classStateController.view)
            classStateController.view.agora_enable = UIConfig.classState.enable
            classStateController.view.agora_visible = false
            
            addChild(cloudController)
            contentView.addSubview(cloudController.view)
            
            addChild(renderMenuController)
            contentView.addSubview(renderMenuController.view)
            renderMenuController.view.agora_enable = UIConfig.renderMenu.enable
            renderMenuController.view.agora_visible = false
            
            cloudController.view.isHidden = true
        }
        
        createChatController()
        
        stateController.view.agora_enable = UIConfig.stateBar.enable
        stateController.view.agora_visible = UIConfig.stateBar.visible
        
        boardController.view.agora_enable = UIConfig.netlessBoard.enable
        boardController.view.agora_visible = UIConfig.netlessBoard.visible
        
        
        settingViewController.view.agora_enable = UIConfig.setting.enable
        settingViewController.view.agora_visible = UIConfig.setting.visible
        
        toolBarController.view.agora_enable = UIConfig.toolBar.enable
        toolBarController.view.agora_visible = UIConfig.toolBar.visible
        
        toolCollectionController.view.agora_enable = UIConfig.toolCollection.enable
        toolCollectionController.view.agora_visible = UIConfig.toolCollection.visible
        
        classToolsController.view.agora_enable = UIConfig.toolBox.enable
        classToolsController.view.agora_visible = UIConfig.toolBox.visible
        
        chatController.view.agora_enable = UIConfig.agoraChat.enable
        chatController.view.agora_visible = UIConfig.agoraChat.visible
    }
    
    override func initViewFrame() {
        super.initViewFrame()
        
        let userRole = contextPool.user.getLocalUserInfo().userRole
        stateController.view.mas_makeConstraints { make in
            make?.top.left().right().equalTo()(0)
            make?.height.equalTo()(UIDevice.current.agora_is_pad ? 24 : 14)
        }
        
        if UIDevice.current.agora_is_pad {
            renderController.view.mas_makeConstraints { make in
                make?.top.equalTo()(stateController.view.mas_bottom)?.offset()(2)
                make?.right.equalTo()(0)
                make?.width.equalTo()(244)
                make?.height.equalTo()(276)
            }
            
            chatController.view.mas_makeConstraints { make in
                make?.top.equalTo()(renderController.view.mas_bottom)?.offset()(2)
                make?.left.right().equalTo()(renderController.view)
                make?.bottom.equalTo()(0)
            }
        } else {
            renderController.view.mas_makeConstraints { make in
                make?.top.equalTo()(stateController.view.mas_bottom)?.offset()(2)
                make?.width.equalTo()(157)
                make?.bottom.right().equalTo()(0)
            }
        }
        
        boardController.view.mas_makeConstraints { make in
            make?.left.bottom().equalTo()(0)
            make?.right.equalTo()(renderController.view.mas_left)?.offset()(-2)
            make?.top.equalTo()(self.stateController.view.mas_bottom)?.offset()(2)
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
        
        self.toolBarController.view.mas_remakeConstraints { make in
            make?.right.equalTo()(self.boardController.view.mas_right)?.offset()(UIDevice.current.agora_is_pad ? -15 : -12)
            make?.bottom.equalTo()(self.boardController.mas_bottomLayoutGuideBottom)?.offset()(UIDevice.current.agora_is_pad ? -20 : -15)
            make?.width.equalTo()(self.toolBarController.suggestSize.width)
            make?.height.equalTo()(self.toolBarController.suggestSize.height)
        }
        
        if userRole != .observer {
            toolCollectionController.view.mas_makeConstraints { make in
                make?.centerX.equalTo()(self.toolBarController.view.mas_centerX)
                make?.bottom.equalTo()(contentView)?.offset()(UIDevice.current.agora_is_pad ? -20 : -15)
                make?.width.height().equalTo()(toolCollectionController.suggestLength)
            }
        }
        
        updateRenderLayout()
    }
    
    override func updateViewProperties() {
        super.updateViewProperties()
        
        view.backgroundColor = FcrUIColorGroup.systemBackgroundColor
    }
}

// MARK: - AgoraBoardUIControllerDelegate
extension AgoraOneToOneUIManager: AgoraBoardUIControllerDelegate {
    func onStageStateChanged(stageOn: Bool) {
        
    }
    
    func onBoardActiveStateChanged(isActive: Bool) {
        toolCollectionController.updateBoardActiveState(isActive: isActive)
    }
    
    func onBoardGrantedUserListAdded(userList: [String]) {
        updateWindowRenderItemBoardPrivilege(true,
                                             userList: userList)
        updateStreamWindowItemBoardPrivilege(true,
                                             userList: userList)
        toolCollectionController.onBoardPrivilegeListChaned(true,
                                                            userList: userList)
    }
    
    func onBoardGrantedUserListRemoved(userList: [String]) {
        updateWindowRenderItemBoardPrivilege(false,
                                             userList: userList)
        updateStreamWindowItemBoardPrivilege(false,
                                             userList: userList)
        toolCollectionController.onBoardPrivilegeListChaned(false,
                                                            userList: userList)
    }
    
    func updateWindowRenderItemBoardPrivilege(_ privilege: Bool,
                                              userList: [String]) {
        for (index, item) in renderController.dataSource.enumerated() {
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
            
            renderController.updateItem(new,
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

// MARK: - AgoraWindowUIControllerDelegate
extension AgoraOneToOneUIManager: FcrStreamWindowUIControllerDelegate {
    func onNeedWindowRenderViewFrameOnTopWindow(userId: String) -> CGRect? {
        guard let renderView = renderController.getRenderView(userId: userId) else {
            return nil
        }
        
        let frame = renderView.convert(renderView.frame,
                                       to: UIWindow.agora_top_window())
        
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
extension AgoraOneToOneUIManager: AgoraCloudUIControllerDelegate {
    func onOpenAlfCourseware(urlString: String,
                             resourceId: String) {
        webViewController.openWebView(urlString: urlString,
                                      resourceId: resourceId)
    }
}

// MARK: - AgoraToolBarDelegate
extension AgoraOneToOneUIManager: AgoraToolBarDelegate {
    func toolsViewDidSelectTool(tool: FcrToolBarItemType,
                                selectView: UIView) {
        switch tool {
        case .setting:
            settingViewController.view.frame = CGRect(origin: .zero,
                                                      size: settingViewController.suggestSize)
            ctrlView = settingViewController.view
        case .message:
            chatController.view.frame = CGRect(origin: .zero,
                                               size: chatController.suggestSize)
            ctrlView = chatController.view
        default:
            break
        }
        ctrlViewAnimationFromView(selectView)
    }
    
    func toolsViewDidDeselectTool(tool: FcrToolBarItemType) {
        ctrlView = nil
    }
}

// MARK: - AgoraChatUIControllerDelegate
extension AgoraOneToOneUIManager: AgoraChatUIControllerDelegate {
    func updateChatRedDot(isShow: Bool) {
        toolBarController.updateChatRedDot(isShow: isShow)
    }
}

// MARK: - AgoraToolCollectionUIControllerDelegate
extension AgoraOneToOneUIManager: AgoraToolCollectionUIControllerDelegate {
    func toolCollectionDidSelectCell(view: UIView) {
        toolBarController.deselectAll()
        renderMenuController.dismissView()
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
                cloudController.view.mas_remakeConstraints { make in
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

// MARK: - FcrWindowRenderUIControllerDelegate
extension AgoraOneToOneUIManager: FcrWindowRenderUIControllerDelegate {
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
            renderMenuController.show(roomType: .oneToOne,
                                      userUuid: userId,
                                      showRoleType: role)
            renderMenuController.view.mas_remakeConstraints { make in
                make?.bottom.equalTo()(view.mas_bottom)?.offset()(-5)
                make?.centerX.equalTo()(centerX)
                make?.height.equalTo()(30)
                make?.width.equalTo()(renderMenuController.menuWidth)
            }
        }
    }
}

// MARK: - AgoraRenderMenuUIControllerDelegate
extension AgoraOneToOneUIManager: AgoraRenderMenuUIControllerDelegate {
    func onMenuUserLeft() {
        renderMenuController.dismissView()
        renderMenuController.view.agora_visible = false
    }
}

// MARK: - AgoraClassStateUIControllerDelegate
extension AgoraOneToOneUIManager: AgoraClassStateUIControllerDelegate {
    func onShowStartClass() {
        guard contextPool.user.getLocalUserInfo().userRole == .teacher else {
            return
        }
        
        classStateController.view.isHidden = false
        
        let left: CGFloat = UIDevice.current.agora_is_pad ? 198 : 192
        classStateController.view.mas_makeConstraints { make in
            make?.left.equalTo()(contentView)?.offset()(left)
            make?.bottom.equalTo()(contentView)?.offset()(UIDevice.current.agora_is_pad ? -20 : -15)
            make?.size.equalTo()(classStateController.suggestSize)
        }
    }
}

extension AgoraOneToOneUIManager: FcrUIControllerDataSource {
    func controllerNeedGrantedUserList() -> [String] {
        return boardController.grantedUsers
    }
}

// MARK: - Creations
private extension AgoraOneToOneUIManager {
    func updateRenderLayout() {
        view.layoutIfNeeded()
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .vertical
        
        layout.itemSize = CGSize(width: renderController.view.width,
                                 height: (renderController.view.height - 2) / 2)
        layout.minimumLineSpacing = 2
        renderController.updateLayout(layout)
    }
    
    func createChatController() {
        addChild(chatController)
        if UIDevice.current.agora_is_pad {
            contentView.addSubview(chatController.view)
        }

        chatController.delegate = self
    }
}
