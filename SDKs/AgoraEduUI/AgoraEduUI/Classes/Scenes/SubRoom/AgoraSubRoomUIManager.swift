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
    func subNeedExitAllRooms(reason: AgoraClassRoomExitReason)
}
/// 房间控制器:
/// 用以处理全局状态和子控制器之间的交互关系
@objc public class AgoraSubRoomUIManager: AgoraEduUIManager {
    // MARK: - Flat components
    /** 房间状态 控制器*/
    private lazy var stateController = AgoraRoomStateUIController(context: contextPool,
                                                                  subRoom: subRoom)
    
    /** 视窗渲染 控制器*/
    private lazy var renderController = FcrSmallWindowRenderUIController(context: contextPool,
                                                                         subRoom: subRoom,
                                                                         delegate: self,
                                                                         controllerDataSource: self)
    
    /** 白板的渲染 控制器*/
    private lazy var boardController = AgoraBoardUIController(context: contextPool,
                                                              subRoom: subRoom,
                                                              delegate: self)
    
    /** 白板翻页 控制器（观众端没有）*/
    private lazy var boardPageController = AgoraBoardPageUIController(context: contextPool,
                                                                      subRoom: subRoom)
    
    /** 大窗 控制器*/
    private lazy var windowController = FcrStreamWindowUIController(context: contextPool,
                                                                    subRoom: subRoom,
                                                                    delegate: self,
                                                                    controllerDataSource: self)
    
    /** 外部链接 控制器*/
    private lazy var webViewController = AgoraWebViewUIController(context: contextPool)
    
    /** 工具栏*/
    private lazy var toolBarController = AgoraToolBarUIController(context: contextPool,
                                                                  subRoom: subRoom,
                                                                  delegate: self)
    
    /** 教具 控制器*/
    private lazy var classToolsController = AgoraClassToolsUIController(context: contextPool,
                                                                        subRoom: subRoom)
    
    /** 全局状态 控制器（自身不包含UI）*/
    private lazy var globalController = AgoraRoomGlobalUIController(context: contextPool,
                                                                    subRoom: subRoom)
    
    // MARK: - Suspend components
    /** 设置界面 控制器*/
    private lazy var settingController = AgoraSettingUIController(context: contextPool,
                                                                  subRoom: subRoom,
                                                                  roomDelegate: self)
    
    /** 聊天窗口 控制器*/
    private lazy var chatController = AgoraChatUIController(context: contextPool,
                                                            subRoom: subRoom,
                                                            delegate: self)
    
    /** 工具集合 控制器（观众端没有）*/
    private lazy var toolCollectionController = AgoraToolCollectionUIController(context: contextPool,
                                                                                subRoom: subRoom,
                                                                                delegate: self)
    
    /** 花名册 控制器*/
    private lazy var nameRollController = AgoraUserListUIController(context: contextPool,
                                                                    subRoom: subRoom)
    
    /** 视窗菜单 控制器（仅教师端）*/
    private lazy var renderMenuController = AgoraRenderMenuUIController(context: contextPool,
                                                                        subRoom: subRoom,
                                                                        delegate: self)
    
    /** 举手列表 控制器（仅老师端）*/
    private lazy var handsListController = AgoraHandsListUIController(context: contextPool,
                                                                      subRoom: subRoom,
                                                                      delegate: self)
    
    /** 云盘 控制器（仅教师端）*/
    private lazy var cloudController = AgoraCloudUIController(context: contextPool,
                                                              delegate: self,
                                                              subRoom: subRoom)
    
    private weak var mainDelegate: AgoraEduUISubManagerCallback?
    
    private var subRoom: AgoraEduSubRoomContext
    
    private var isJoinedRoom = false
    private var curStageOn = true
    
    init(contextPool: AgoraEduContextPool,
         subRoom: AgoraEduSubRoomContext,
         subDelegate: AgoraEduUIManagerCallback?,
         mainDelegate: AgoraEduUISubManagerCallback?) {
        self.subRoom = subRoom
        self.mainDelegate = mainDelegate
        super.init(contextPool: contextPool,
                   delegate: subDelegate)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    deinit {
        print("\(#function): \(self.classForCoder)")
    }
    
    public override func viewDidLoad() {
        super.viewDidLoad()
        initViews()
        initViewFrame()
        updateViewProperties()
        updateRenderCollectionLayout()
        
        AgoraLoading.hide()
        
        subRoom.joinSubRoom { [weak self] in
            AgoraLoading.hide()
            
            guard let `self` = self else {
                return
            }
            
            self.isJoinedRoom = true
            
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
    
    public override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        if isJoinedRoom == false {
            let subRoomName = subRoom.getSubRoomInfo().subRoomName
            let message = "fcr_group_joining".agedu_localized().replacingOccurrences(of: String.agedu_localized_replacing_x(),
                                                                                     with: subRoomName)
            
            AgoraLoading.loading(msg: message)
        }
    }
    
    public override func didClickCtrlMaskView() {
        super.didClickCtrlMaskView()
        toolBarController.deselectAll()
    }
    
    @objc public override func exitClassRoom(reason: AgoraClassRoomExitReason,
                                             roomType: AgoraClassRoomExitRoomType) {
        let roomId = subRoom.getSubRoomInfo().subRoomUuid
        let userId = subRoom.user.getLocalUserInfo().userUuid
        let group = contextPool.group
        
        switch roomType {
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
    
    func dismiss(reason: AgoraClassRoomExitReason,
                 animated flag: Bool,
                 completion: (() -> Void)? = nil) {
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

// MARK: - AgoraUIContentContainer
extension AgoraSubRoomUIManager: AgoraUIContentContainer {
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
        
        if userRole != .observer {
            addChild(boardPageController)
            contentView.addSubview(boardPageController.view)
        }
        
        addChild(windowController)
        contentView.addSubview(windowController.view)
        
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
        case .student:
            toolBarController.tools = [.help,
                                       .setting,
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
            
            addChild(cloudController)
            cloudController.view.isHidden = true
            contentView.addSubview(cloudController.view)
            
            addChild(toolCollectionController)
            contentView.addSubview(toolCollectionController.view)
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
    }
    
    func updateViewProperties() {
        AgoraUIGroup().color.borderSet(layer: chatController.view.layer)
    }
}

// MARK: - FcrWindowRenderUIControllerDelegate
extension AgoraSubRoomUIManager: FcrWindowRenderUIControllerDelegate {
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
                make?.bottom.equalTo()(view.mas_bottom)?.offset()(1)
                make?.centerX.equalTo()(view.mas_centerX)
                make?.height.equalTo()(30)
                make?.width.equalTo()(renderMenuController.menuWidth)
            }
        }
    }
}

// MARK: - AgoraBoardUIControllerDelegate
extension AgoraSubRoomUIManager: AgoraBoardUIControllerDelegate {
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

// MARK: - AgoraToolBarDelegate
extension AgoraSubRoomUIManager: AgoraToolBarDelegate {
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
            if handsListController.dataSource.count > 0 {
                handsListController.view.frame = CGRect(origin: .zero,
                                                        size: handsListController.suggestSize)
                ctrlView = handsListController.view
            }
        case .help:
            toolsViewDidSelectHelp()
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
extension AgoraSubRoomUIManager: FcrStreamWindowUIControllerDelegate {
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
extension AgoraSubRoomUIManager: AgoraCloudUIControllerDelegate {
    func onOpenAlfCourseware(urlString: String,
                             resourceId: String) {
        webViewController.openWebView(urlString: urlString,
                                      resourceId: resourceId)
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

// MARK: - AgoraRenderMenuUIControllerDelegate
extension AgoraSubRoomUIManager: AgoraRenderMenuUIControllerDelegate {
    func onMenuUserLeft() {
        renderMenuController.dismissView()
        renderMenuController.view.isHidden = true
    }
}

// MARK: - FcrUIControllerDataSource
extension AgoraSubRoomUIManager: FcrUIControllerDataSource {
    func controllerNeedGrantedUserList() -> [String] {
        return boardController.grantedUsers
    }
}

// MARK: - Private
private extension AgoraSubRoomUIManager {
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
            AgoraToast.toast(msg: "fcr_group_teacher_exist_hint".agedu_localized(),
                             type: .warning)
        case .otherSub:
            AgoraToast.toast(msg: "fcr_group_teacher_is_helping_others_msg".agedu_localized(),
                             type: .warning)
        default:
            guard let userList = contextPool.user.getUserList(role: .teacher),
                  let teacherUserId = userList.first?.userUuid else {
                      break
                  }
                
                globalController.isRequestingHelp = true
                
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
