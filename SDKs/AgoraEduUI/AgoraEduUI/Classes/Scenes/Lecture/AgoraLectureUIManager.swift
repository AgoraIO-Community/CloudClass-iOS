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
    private lazy var nameRollController = AgoraUserListUIController(context: contextPool)
    
    /** 设置界面 控制器*/
    private lazy var settingViewController: AgoraSettingUIController = {
        let vc = AgoraSettingUIController(context: contextPool,
                                          roomDelegate: self)
        self.addChild(vc)
        return vc
    }()
    /** 举手列表 控制器（仅教师端）*/
    private lazy var handsListController: AgoraHandsListUIController = {
        let vc = AgoraHandsListUIController(context: contextPool,
                                            delegate: self)
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
    private lazy var toolBarController = AgoraToolBarUIController(context: contextPool)
    /** 房间状态 控制器*/
    private lazy var stateController = AgoraRoomStateUIController(context: contextPool)
    /** 全局状态 控制器（自身不包含UI）*/
    private lazy var globalController = AgoraRoomGlobalUIController(context: contextPool,
                                                                    delegate: nil)
    /** 课堂状态 控制器（仅教师端）*/
    private lazy var classStateController = AgoraClassStateUIController(context: contextPool,
                                                                        delegate: self)
    /** 老师渲染 控制器*/
    private lazy var teacherRenderController = FcrLectureWindowRenderUIController(context: contextPool,
                                                                                  dataSource: [FcrWindowRenderViewState.none],
                                                                                  reverseItem: false,
                                                                                  delegate: self)
    /** 白板 控制器*/
    private lazy var boardController = AgoraLectureBoardUIController(context: contextPool,
                                                                     delegate: self)
    
    /** 工具集合 控制器（观众端没有）*/
    private lazy var toolCollectionController = AgoraToolCollectionUIController(context: contextPool,
                                                                                delegate: self)
    /** 大窗 控制器*/
    private lazy var windowController = FcrLectureStreamWindowUIController(context: contextPool,
                                                                           delegate: self,
                                                                           controllerDataSource: self)
    /** 外部链接 控制器*/
    private lazy var webViewController = AgoraWebViewUIController(context: contextPool)
    /** 云盘 控制器（仅教师端）*/
    private lazy var cloudController = AgoraCloudUIController(context: contextPool,
                                                              delegate: self)
    /** 教具 控制器*/
    private lazy var classToolsController = AgoraClassToolsUIController(context: contextPool)
    /** 聊天窗口 控制器*/
    private lazy var chatController = AgoraChatUIController(context: contextPool)
    
    private var isJoinedRoom = false
    
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
    
    // MARK: AgoraUIContentContainer
    override func initViews() {
        super.initViews()
        
        UIConfig = FcrLectrueConfig()
        
        let userRole = contextPool.user.getLocalUserInfo().userRole
        
        addChild(stateController)
        contentView.addSubview(stateController.view)
        
        globalController.roomDelegate = self
        addChild(globalController)
        globalController.viewDidLoad()
        
        addChild(teacherRenderController)
        contentView.addSubview(teacherRenderController.view)
        
        // 视图层级：白板，大窗，工具
        addChild(boardController)
        contentView.addSubview(boardController.view)
        
        addChild(webViewController)
        contentView.addSubview(webViewController.view)
        
        addChild(windowController)
        contentView.addSubview(windowController.view)
        
        toolBarController.delegate = self
        
        if userRole == .teacher {
            addChild(classToolsController)
            contentView.addSubview(classToolsController.view)
            classToolsController.view.agora_enable = UIConfig.toolBox.enable
            classToolsController.view.agora_visible = UIConfig.toolBox.visible
            
            addChild(toolCollectionController)
            contentView.addSubview(toolCollectionController.view)
            toolCollectionController.view.agora_enable = UIConfig.toolCollection.enable
            toolCollectionController.view.agora_visible = false
            
            toolBarController.updateTools([.setting, .roster, .handsList])
            addChild(classStateController)
            addChild(handsListController)
            addChild(nameRollController)
            addChild(renderMenuController)
            contentView.addSubview(renderMenuController.view)
            addChild(cloudController)
            contentView.addSubview(cloudController.view)
            
            renderMenuController.view.isHidden = true
            cloudController.view.isHidden = true
        } else if userRole == .student {
            addChild(classToolsController)
            contentView.addSubview(classToolsController.view)
            classToolsController.view.agora_enable = UIConfig.toolBox.enable
            classToolsController.view.agora_visible = UIConfig.toolBox.visible
            
            addChild(toolCollectionController)
            contentView.addSubview(toolCollectionController.view)
            toolCollectionController.view.agora_enable = UIConfig.toolCollection.enable
            toolCollectionController.view.agora_visible = false
            
            toolBarController.updateTools([.setting, .waveHands])
        } else {
            toolBarController.updateTools([.setting])
        }
        contentView.addSubview(toolBarController.view)
        
        chatController.hideMiniButton = true
        if contextPool.user.getLocalUserInfo().userRole == .observer {
            chatController.hideInput = true
        }
        addChild(chatController)
        contentView.addSubview(chatController.view)
        contentView.sendSubviewToBack(chatController.view)
        
        stateController.view.agora_enable = UIConfig.stateBar.enable
        stateController.view.agora_visible = UIConfig.stateBar.visible
        
        boardController.view.agora_enable = UIConfig.netlessBoard.enable
        boardController.view.agora_visible = UIConfig.netlessBoard.visible
        
        settingViewController.view.agora_enable = UIConfig.setting.enable
        settingViewController.view.agora_visible = UIConfig.setting.visible
        
        toolBarController.view.agora_enable = UIConfig.toolBar.enable
        toolBarController.view.agora_visible = UIConfig.toolBar.visible
    }
    
    override func initViewFrame() {
        super.initViewFrame()
        let userRole = contextPool.user.getLocalUserInfo().userRole
        
        stateController.view.mas_makeConstraints { make in
            make?.top.left().right().equalTo()(0)
            make?.height.equalTo()(UIDevice.current.agora_is_pad ? 24 : 14)
        }
        
        webViewController.view.mas_makeConstraints { make in
            make?.left.right().top().bottom().equalTo()(boardController.view)
        }
        
        windowController.view.mas_makeConstraints { make in
            make?.left.right().top().bottom().equalTo()(boardController.view)
        }
        
        teacherRenderController.view.mas_makeConstraints { make in
            make?.top.equalTo()(stateController.view.mas_bottom)?.offset()(2)
            make?.right.equalTo()(0)
            make?.width.equalTo()(AgoraFit.scale(170))
            make?.height.equalTo()(AgoraFit.scale(112))
        }
        
        boardController.view.mas_makeConstraints { make in
            make?.left.bottom().equalTo()(0)
            make?.right.equalTo()(teacherRenderController.view.mas_left)?.offset()(-2)
            make?.top.equalTo()(self.stateController.view.mas_bottom)?.offset()(2)
        }
        
        toolBarController.view.mas_remakeConstraints { make in
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
            classToolsController.view.mas_makeConstraints { make in
                make?.left.right().top().bottom().equalTo()(boardController.view)
            }
        }
        
        chatController.view.mas_makeConstraints { make in
            make?.top.equalTo()(teacherRenderController.view.mas_bottom)?.offset()(2)
            make?.left.right().equalTo()(teacherRenderController.view)
            make?.bottom.equalTo()(0)
        }
        
        updateRenderLayout()
    }
    
    override func updateViewProperties() {
        super.updateViewProperties()
        teacherRenderController.view.layer.cornerRadius = FcrUIFrameGroup.windowCornerRadius
        teacherRenderController.view.clipsToBounds = true
    }
}


// MARK: - AgoraBoardUIControllerDelegate
extension AgoraLectureUIManager: AgoraBoardUIControllerDelegate {
    func onStageStateChanged(stageOn: Bool) {
        
    }
    
    func onBoardActiveStateChanged(isActive: Bool) {
        toolCollectionController.updateBoardActiveState(isActive: isActive)
    }
    
    func onBoardGrantedUserListAdded(userList: [String]) {
        updateStreamWindowItemBoardPrivilege(true,
                                             userList: userList)
        toolCollectionController.onBoardPrivilegeListChaned(true,
                                                            userList: userList)
    }
    
    func onBoardGrantedUserListRemoved(userList: [String]) {
        updateStreamWindowItemBoardPrivilege(false,
                                             userList: userList)
        toolCollectionController.onBoardPrivilegeListChaned(false,
                                                            userList: userList)
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

// MARK: - FcrStreamWindowUIControllerDelegate
extension AgoraLectureUIManager: FcrStreamWindowUIControllerDelegate {
    func onNeedWindowRenderViewFrameOnTopWindow(userId: String) -> CGRect? {
        guard let renderView = teacherRenderController.getRenderView(userId: userId) else {
            return nil
        }
        
        let frame = renderView.convert(renderView.frame,
                                       to: UIWindow.ag_topWindow())
        
        return frame
    }
    
    func onWillStartRenderVideoStream(streamId: String) {
        guard let item = teacherRenderController.getItem(streamId: streamId),
              let data = item.data else {
            return
        }
        
        let new = FcrWindowRenderViewState.create(isHide: true,
                                                  data: data)
        
        teacherRenderController.updateItem(new,
                                           animation: false)
    }
    
    func onDidStopRenderVideoStream(streamId: String) {
        guard let item = teacherRenderController.getItem(streamId: streamId),
              let data = item.data else {
            return
        }
        
        let new = FcrWindowRenderViewState.create(isHide: false,
                                                  data: data)
        
        teacherRenderController.updateItem(new,
                                           animation: false)
    }
}

// MARK: - AgoraCloudUIControllerDelegate
extension AgoraLectureUIManager: AgoraCloudUIControllerDelegate {
    func onOpenAlfCourseware(urlString: String,
                             resourceId: String) {
        webViewController.openWebView(urlString: urlString,
                                      resourceId: resourceId)
    }
}

// MARK: - AgoraToolBarDelegate
extension AgoraLectureUIManager: AgoraToolBarDelegate {
    func toolsViewDidSelectTool(tool: FcrToolBarItemType,
                                selectView: UIView) {
        switch tool {
        case .setting:
            settingViewController.view.frame = CGRect(origin: .zero,
                                                      size: settingViewController.suggestSize)
            ctrlView = settingViewController.view
        case .roster:
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
    
    func toolsViewDidDeselectTool(tool: FcrToolBarItemType) {
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

// MARK: - FcrWindowRenderUIControllerDelegate
extension AgoraLectureUIManager: FcrWindowRenderUIControllerDelegate {
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
            renderMenuController.show(roomType: .lecture,
                                      userUuid: userId,
                                      showRoleType: role)
            renderMenuController.view.mas_remakeConstraints { make in
                make?.bottom.equalTo()(view.mas_bottom)?.offset()(1)
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

// MARK: - AgoraClassStateUIControllerDelegate
extension AgoraLectureUIManager: AgoraClassStateUIControllerDelegate {
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

// MARK: - FcrUIControllerDataSource
extension AgoraLectureUIManager: FcrUIControllerDataSource {
    func controllerNeedGrantedUserList() -> [String] {
        return boardController.grantedUsers
    }
}

private extension AgoraLectureUIManager {
    func updateRenderLayout() {
        view.layoutIfNeeded()
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .horizontal
        
        layout.itemSize = CGSize(width: 244,
                                 height: teacherRenderController.view.height - 2)
        layout.minimumLineSpacing = 2
        teacherRenderController.updateLayout(layout)
    }
}
