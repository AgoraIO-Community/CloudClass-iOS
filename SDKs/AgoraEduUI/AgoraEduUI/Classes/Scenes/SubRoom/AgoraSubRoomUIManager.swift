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
    private lazy var stateController: AgoraRoomStateUIController = AgoraRoomStateUIController(context: contextPool,
                                                                                              subRoom: subRoom)
    
    /** 视窗渲染 控制器*/
    private lazy var renderController: AgoraSmallMembersUIController = AgoraSmallMembersUIController(context: contextPool,
                                                                                                     delegate: self,
                                                                                                     containRoles: [.student],
                                                                                                     max: 6,
                                                                                                     subRoom: subRoom,
                                                                                                     expandFlag: true)
    
    /** 白板的渲染 控制器*/
    private lazy var boardController: AgoraBoardUIController = AgoraBoardUIController(context: contextPool, subRoom: subRoom)
    
    /** 白板翻页 控制器（观众端没有）*/
    private lazy var boardPageController: AgoraBoardPageUIController = AgoraBoardPageUIController(context: contextPool, subRoom: subRoom)
    
    
    /** 大窗 控制器*/
    private lazy var windowController: AgoraWindowUIController = AgoraWindowUIController(context: contextPool,
                                                                                         subRoom: subRoom,
                                                                                         delegate: self)
    
    /** 工具栏*/
    private lazy var toolBarController: AgoraToolBarUIController = AgoraToolBarUIController(context: contextPool,
                                                                                            subRoom: subRoom,
                                                                                            delegate: self)
    
    /** 教具 控制器*/
    private lazy var classToolsController: AgoraClassToolsUIController = AgoraClassToolsUIController(context: contextPool,
                                                                                                     subRoom: subRoom)
    
    /** 全局状态 控制器（自身不包含UI）*/
    private lazy var globalController: AgoraRoomGlobalUIController = AgoraRoomGlobalUIController(context: contextPool,
                                                                                                 subRoom: subRoom)
    
    // MARK: - Suspend components
    /** 设置界面 控制器*/
    private lazy var settingController = AgoraSettingUIController(context: contextPool,
                                                                  subRoom: subRoom,
                                                                  roomDelegate: self)
    
    /** 聊天窗口 控制器*/
    private lazy var chatController: AgoraChatUIController = AgoraChatUIController(context: contextPool,
                                                                                   subRoom: subRoom,
                                                                                   delegate: self)
    
    /** 工具集合 控制器（观众端没有）*/
    private lazy var toolCollectionController: AgoraToolCollectionUIController = AgoraToolCollectionUIController(context: contextPool,
                                                                                                                 subRoom: subRoom,
                                                                                                                 delegate: self)
    
    /** 花名册 控制器*/
    private lazy var nameRollController: AgoraUserListUIController = AgoraUserListUIController(context: contextPool,
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
                                                              subRoom: subRoom)
        
    private weak var mainDelegate: AgoraEduUISubManagerCallback?
    
    private var subRoom: AgoraEduSubRoomContext
    
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
        AgoraLoading.loading()
        
        subRoom.joinSubRoom { [weak self] in
            AgoraLoading.hide()
            guard let `self` = self else {
                return
            }
            
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
    
    public override func didClickCtrlMaskView() {
        super.didClickCtrlMaskView()
        toolBarController.deselectAll()
    }
    
    @objc public override func exitClassRoom(reason: AgoraClassRoomExitReason,
                                             roomType: AgoraClassRoomExitRoomType) {
        switch roomType {
        case .main:
            dismiss(reason: reason,
                    animated: true) { [weak self] in
                guard let `self` = self else {
                    return
                }
                
                self.mainDelegate?.subNeedExitAllRooms(reason: reason)
            }
        case .sub:
            let roomId = subRoom.getSubRoomInfo().subRoomUuid
            let userId = subRoom.user.getLocalUserInfo().userUuid
            contextPool.group.removeUserListFromSubRoom(userList: [userId],
                                                        subRoomUuid: roomId,
                                                        success: nil,
                                                        failure: nil)
            dismiss(reason: reason,
                    animated: true)
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
            
            boardPageController.view.isHidden = false
        case .student:
            toolBarController.tools = [.help,
                                       .setting,
                                       .message,
                                       .nameRoll,
                                       .handsup]
            
            boardPageController.view.isHidden = true
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
        chatController.viewDidLoad()
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
            toolCollectionController.view.isHidden = false
            contentView.addSubview(toolCollectionController.view)
        case .student:
            addChild(nameRollController)
            
            addChild(toolCollectionController)
            toolCollectionController.view.isHidden = true
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
            make?.height.equalTo()(UIDevice.current.isPad ? 20 : 14)
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
        
        if userRole == .teacher {
            toolBarController.view.mas_remakeConstraints { make in
                make?.right.equalTo()(self.boardController.view.mas_right)?.offset()(UIDevice.current.isPad ? -15 : -12)
                make?.bottom.equalTo()(self.toolCollectionController.view.mas_top)?.offset()(UIDevice.current.isPad ? -15 : -12)
                make?.width.equalTo()(self.toolBarController.suggestSize.width)
                make?.height.equalTo()(self.toolBarController.suggestSize.height)
            }
        } else {
            toolBarController.view.mas_remakeConstraints { make in
                make?.right.equalTo()(self.boardController.view.mas_right)?.offset()(UIDevice.current.isPad ? -15 : -12)
                make?.bottom.equalTo()(self.boardController.view)?.offset()(UIDevice.current.isPad ? -20 : -15)
                make?.width.equalTo()(self.toolBarController.suggestSize.width)
                make?.height.equalTo()(self.toolBarController.suggestSize.height)
            }
        }
        
        if userRole != .observer {
            toolCollectionController.view.mas_makeConstraints { make in
                make?.centerX.equalTo()(self.toolBarController.view.mas_centerX)
                make?.bottom.equalTo()(boardController.view)?.offset()(UIDevice.current.isPad ? -20 : -15)
                make?.width.height().equalTo()(toolCollectionController.suggestLength)
            }
            
            boardPageController.view.mas_makeConstraints { make in
                make?.left.equalTo()(contentView)?.offset()(UIDevice.current.isPad ? 15 : 12)
                make?.bottom.equalTo()(boardController.view)?.offset()(UIDevice.current.isPad ? -20 : -15)
                make?.height.equalTo()(UIDevice.current.isPad ? 34 : 32)
                make?.width.equalTo()(168)
            }
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
            if teacherInLocalSubRoom() {
                AgoraToast.toast(msg: "fcr_group_teacher_exist_hint".agedu_localized(),
                                 type: .warning)
            } else if let userList = contextPool.user.getUserList(role: .teacher),
                      let teacherUserId = userList.first?.userUuid {
                let roomId = subRoom.getSubRoomInfo().subRoomUuid
                
                contextPool.group.inviteUserListToSubRoom(userList: [teacherUserId],
                                                          subRoomUuid: roomId,
                                                          success: nil,
                                                          failure: nil)
            }
            break
        default:
            break
        }
        ctrlViewAnimationFromView(selectView)
    }
    
    func toolsViewDidDeselectTool(tool: AgoraToolBarUIController.ItemType) {
        ctrlView = nil
    }
}

// MARK: - AgoraWindowUIControllerDelegate
extension AgoraSubRoomUIManager: AgoraWindowUIControllerDelegate {
    func startSpreadForUser(with userId: String) -> UIView? {
        self.renderController.setRenderEnable(with: userId,
                                              rendEnable: false)
        return self.renderController.getRenderViewForUser(with: userId)
    }
    
    func willStopSpreadForUser(with userId: String) -> UIView? {
        return self.renderController.getRenderViewForUser(with: userId)
    }
    
    func didStopSpreadForUser(with userId: String) {
        self.renderController.setRenderEnable(with: userId,
                                              rendEnable: true)
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
                                make?.right.equalTo()(self.boardController.view.mas_right)?.offset()(UIDevice.current.isPad ? -15 : -12)
                                make?.bottom.equalTo()(self.toolCollectionController.view.mas_top)?.offset()(UIDevice.current.isPad ? -15 : -12)
                                make?.width.equalTo()(self.toolBarController.suggestSize.width)
                                make?.height.equalTo()(self.toolBarController.suggestSize.height)
                            }
                        } else {
                            self.toolBarController.view.mas_remakeConstraints { make in
                                make?.right.equalTo()(self.boardController.view.mas_right)?.offset()(UIDevice.current.isPad ? -15 : -12)
                                make?.bottom.equalTo()(self.boardController.mas_bottomLayoutGuideBottom)?.offset()(UIDevice.current.isPad ? -20 : -15)
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
                make?.bottom.equalTo()(contentView)?.offset()(UIDevice.current.isPad ? -20 : -15)
                make?.width.equalTo()(toolCollectionController.suggestLength)
                make?.height.equalTo()(toolCollectionController.suggestSpreadHeight)
            }
        } else {
            toolCollectionController.view.mas_remakeConstraints { make in
                make?.centerX.equalTo()(self.toolBarController.view.mas_centerX)
                make?.bottom.equalTo()(contentView)?.offset()(UIDevice.current.isPad ? -20 : -15)
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

// MARK: - AgoraRenderUIControllerDelegate
extension AgoraSubRoomUIManager: AgoraRenderUIControllerDelegate {
    func onClickMemberAt(view: UIView,
                         UUID: String) {
        guard subRoom.user.getLocalUserInfo().userRole == .teacher else {
            return
        }
        
        var role = AgoraEduContextUserRole.student
        if let teacehr = subRoom.user.getUserList(role: .teacher)?.first,
           teacehr.userUuid == UUID {
            role = .teacher
        }
        
        if let menuId = renderMenuController.userId,
           menuId == UUID {
            // 若当前已存在menu，且当前menu的userId为点击的userId，menu切换状态
            renderMenuController.dismissView()
        } else {
            // 1. 当前menu的userId不为点击的userId，切换用户
            // 2. 当前不存在menu，显示
            renderMenuController.show(roomType: .small,
                                      userUuid: UUID,
                                      showRoleType: role)
            renderMenuController.view.mas_remakeConstraints { make in
                make?.top.equalTo()(view.mas_bottom)?.offset()(1)
                make?.centerX.equalTo()(view.mas_centerX)
                make?.height.equalTo()(30)
                make?.width.equalTo()(renderMenuController.menuWidth)
            }
        }
    }
    
    func onRequestSpread(firstOpen: Bool,
                         userId: String,
                         streamId: String,
                         fromView: UIView,
                         xaxis: CGFloat,
                         yaxis: CGFloat,
                         width: CGFloat,
                         height: CGFloat) {
    }
}

// MARK: - AgoraRenderMenuUIControllerDelegate
extension AgoraSubRoomUIManager: AgoraRenderMenuUIControllerDelegate {
    func onMenuUserLeft() {
        renderMenuController.dismissView()
        renderMenuController.view.isHidden = true
    }
}

// MARK: - Private
private extension AgoraSubRoomUIManager {
    func updateRenderCollectionLayout() {
        view.layoutIfNeeded()
        let kItemGap: CGFloat = AgoraFit.scale(4)
        
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .horizontal
        
        let itemWidth = (renderController.view.bounds.width + kItemGap) / 7.0 - kItemGap
        
        layout.itemSize = CGSize(width: itemWidth,
                                 height: renderController.view.bounds.height)
        layout.minimumLineSpacing = kItemGap
        renderController.updateLayout(layout)
    }
    
    func teacherInLocalSubRoom() -> Bool {
        let group = contextPool.group
        let user = contextPool.user
        
        guard let subRoomList = group.getSubRoomList(),
              let teacher = user.getUserList(role: .teacher)?.first else {
            return true
        }
        
        let localUserId = user.getLocalUserInfo().userUuid
        let teacherId = teacher.userUuid
        
        for item in subRoomList {
            guard let userList = group.getUserListFromSubRoom(subRoomUuid: item.subRoomUuid),
                  userList.contains([localUserId,teacherId]) else {
                continue
            }
            
            return true
        }
        
        return true
    }
}
