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

@objc public enum VocationalCDNType: Int {
    case noCDN
    case onlyCDN
    case mixedCDN
}

/// 房间控制器:
/// 用以处理全局状态和子控制器之间的交互关系
@objc public class AgoraVocationalUIManager: AgoraEduUIManager {
    
    @objc public var cdnType: VocationalCDNType = .noCDN {
        didSet {
            switch cdnType {
            case .onlyCDN:
                self.teacherRenderController.isRenderByRTC = false
            default: break
            }
        }
    }
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
    private lazy var toolBarController = VocationalToolBarUIController(context: contextPool)
    /** 房间状态 控制器*/
    private lazy var stateController = AgoraRoomStateUIController(context: contextPool)
    /** 全局状态 控制器（自身不包含UI）*/
    private lazy var globalController = AgoraRoomGlobalUIController(context: contextPool,
                                                                    delegate: nil)
    /** 课堂状态 控制器（仅教师端）*/
    private lazy var classStateController = AgoraClassStateUIController(context: contextPool,
                                                                        delegate: self)
    /** 老师渲染 控制器*/
    private lazy var teacherRenderController = VocationalTeacherRenderController(context: contextPool,
                                                                                 delegate: self)
    /** 白板 控制器*/
    private lazy var boardController = AgoraBoardUIController(context: contextPool)
    
    /** 工具集合 控制器（观众端没有）*/
    private lazy var toolCollectionController = AgoraToolCollectionUIController(context: contextPool,
                                                                                delegate: self)
    /** 白板翻页 控制器（观众端没有）*/
    private lazy var boardPageController = AgoraBoardPageUIController(context: contextPool)
    /** 大窗 控制器*/
    private lazy var windowController = VocationalWindowUIController(context: contextPool)
    /** 云盘 控制器（仅教师端）*/
    private lazy var cloudController = AgoraCloudUIController(context: contextPool,
                                                              delegate: nil)
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
        
        initViews()
        initViewFrame()
        updateViewProperties()
        
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
            self.updateCDNState()
        } failure: { [weak self] error in
            AgoraLoading.hide()
            self?.exitClassRoom(reason: .normal)
        }
        contextPool.stream.registerStreamEventHandler(self)
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
    
    func updateCDNState() {
        let localUserId = contextPool.user.getLocalUserInfo().userUuid
        if self.cdnType == .noCDN {
            self.teacherRenderController.isRenderByRTC = true
            self.windowController.isRenderByRTC = true
        } else if self.cdnType == .onlyCDN {
            self.teacherRenderController.isRenderByRTC = false
            self.windowController.isRenderByRTC = false
        } else if self.cdnType == .mixedCDN {
            // 混合CDN上台
            if let coHosts = self.contextPool.user.getCoHostList(),
               coHosts.contains(where: {$0.userUuid == localUserId}) {
                self.teacherRenderController.isRenderByRTC = true
                self.windowController.isRenderByRTC = true
            } else {
                self.teacherRenderController.isRenderByRTC = false
                self.windowController.isRenderByRTC = false
            }
        }
    }
}
// MARK: - AgoraEduUserHandler
extension AgoraVocationalUIManager: AgoraEduStreamHandler {
    public func onStreamJoined(stream: AgoraEduContextStreamInfo,
                               operatorUser: AgoraEduContextUserInfo?) {
        guard self.cdnType == .mixedCDN,
              stream.owner.userUuid == contextPool.user.getLocalUserInfo().userUuid else {
            return
        }
        self.teacherRenderController.isRenderByRTC = true
        self.windowController.isRenderByRTC = true
        let config = FcrRtmpStreamConfig(streamUuid: stream.streamUuid,
                                         dimensionWidth: 320,
                                         dimensionHeight: 240,
                                         bitRate: 200, seiOptions: nil)
        self.contextPool.stream.startPublishStreamToCdn(config: config, success: {
            // Do Noting
        }, failure: { erro in // 子线程
            DispatchQueue.main.async {
                AgoraToast.toast(msg: "推CDN流失败", type: .error)
            }
        })
    }
    public func onStreamLeft(stream: AgoraEduContextStreamInfo,
                             operatorUser: AgoraEduContextUserInfo?) {
        guard self.cdnType == .mixedCDN,
              stream.owner.userUuid == contextPool.user.getLocalUserInfo().userUuid else {
            return
        }
        self.teacherRenderController.isRenderByRTC = false
        self.windowController.isRenderByRTC = false
        self.contextPool.stream.stopPublishStreamToCdn(streamUuid: stream.streamUuid) {
            // Do Noting
        } failure: { erro in // 子线程
            DispatchQueue.main.async {
                AgoraToast.toast(msg: "关CDN流失败", type: .error)
            }
        }
    }
}

// MARK: - AgoraUIContentContainer
@objc extension AgoraVocationalUIManager: AgoraUIContentContainer {
    func initViews() {
        let userRole = contextPool.user.getLocalUserInfo().userRole
        
        addChild(stateController)
        contentView.addSubview(stateController.view)
        
        globalController.roomDelegate = self
        addChild(globalController)
        globalController.viewDidLoad()
        
        teacherRenderController.view.layer.cornerRadius = AgoraFit.scale(2)
        teacherRenderController.view.clipsToBounds = true
        addChild(teacherRenderController)
        contentView.addSubview(teacherRenderController.view)
        
        // 视图层级：白板，大窗，工具
        boardController.view.layer.cornerRadius = AgoraFit.scale(2)
        boardController.view.borderWidth = 1
        boardController.view.borderColor = UIColor(hex: 0xECECF1)
        boardController.view.clipsToBounds = true
        addChild(boardController)
        contentView.addSubview(boardController.view)
        
        windowController.delegate = self
        addChild(windowController)
        contentView.addSubview(windowController.view)
        
        toolBarController.delegate = self
        
        addChild(classToolsController)
        contentView.addSubview(classToolsController.view)

        if userRole == .teacher {
            addChild(toolCollectionController)
            contentView.addSubview(toolCollectionController.view)
            
            contentView.addSubview(boardPageController.view)
            addChild(boardPageController)
            if self.cdnType == .onlyCDN {
                toolBarController.tools = [.setting, .nameRoll, .handsList]
            } else {
                toolBarController.tools = [.setting, .nameRoll]
            }
            addChild(classStateController)
            addChild(handsListController)
            addChild(nameRollController)
            addChild(renderMenuController)
            contentView.addSubview(renderMenuController.view)
            addChild(cloudController)
            contentView.addSubview(cloudController.view)
            
            renderMenuController.view.isHidden = true
            cloudController.view.isHidden = true
            toolCollectionController.view.isHidden = false
            boardPageController.view.isHidden = false
        } else if userRole == .student {
            addChild(toolCollectionController)
            contentView.addSubview(toolCollectionController.view)
            
            contentView.addSubview(boardPageController.view)
            addChild(boardPageController)
            if self.cdnType == .onlyCDN {
                toolBarController.tools = [.setting]
            } else if self.cdnType == .mixedCDN {
                toolBarController.tools = [.setting, .handsup]
                toolBarController.handsupDuration = 5
            } else {
                toolBarController.tools = [.setting, .handsup]
                toolBarController.handsupDuration = 3
            }
            toolCollectionController.view.isHidden = true
            boardPageController.view.isHidden = true
        } else {
            toolBarController.tools = [.setting]
        }
        contentView.addSubview(toolBarController.view)
        
        chatController.hideMiniButton = true
        if contextPool.user.getLocalUserInfo().userRole == .observer {
            chatController.hideInput = true
        }
        addChild(chatController)
        FcrUIColorGroup.borderSet(layer: chatController.view.layer)
        contentView.addSubview(chatController.view)
        contentView.sendSubviewToBack(chatController.view)
    }
    
    func initViewFrame() {
        let userRole = contextPool.user.getLocalUserInfo().userRole

        stateController.view.mas_makeConstraints { make in
            make?.top.left().right().equalTo()(0)
            make?.height.equalTo()(AgoraFit.scale(14))
        }
        windowController.view.mas_makeConstraints { make in
            make?.left.right().top().bottom().equalTo()(boardController.view)
        }
        teacherRenderController.view.mas_makeConstraints { make in
            make?.top.equalTo()(stateController.view.mas_bottom)?.offset()(AgoraFit.scale(2))
            make?.right.equalTo()(0)
            make?.width.equalTo()(AgoraFit.scale(170))
            make?.height.equalTo()(AgoraFit.scale(112))
        }
        boardController.view.mas_makeConstraints { make in
            make?.left.bottom().equalTo()(0)
            make?.right.equalTo()(teacherRenderController.view.mas_left)?.offset()(AgoraFit.scale(-2))
            make?.top.equalTo()(self.stateController.view.mas_bottom)?.offset()(AgoraFit.scale(2))
        }
        if userRole == .teacher {
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
        if userRole != .observer {
            toolCollectionController.view.mas_makeConstraints { make in
                make?.centerX.equalTo()(self.toolBarController.view.mas_centerX)
                make?.bottom.equalTo()(contentView)?.offset()(UIDevice.current.agora_is_pad ? -20 : -15)
                make?.width.height().equalTo()(toolCollectionController.suggestLength)
            }
            boardPageController.view.mas_makeConstraints { make in
                make?.left.equalTo()(contentView)?.offset()(UIDevice.current.agora_is_pad ? 15 : 12)
                make?.bottom.equalTo()(contentView)?.offset()(UIDevice.current.agora_is_pad ? -20 : -15)
                make?.height.equalTo()(UIDevice.current.agora_is_pad ? 34 : 32)
                make?.width.equalTo()(168)
            }
        }

        chatController.view.mas_makeConstraints { make in
            make?.top.equalTo()(teacherRenderController.view.mas_bottom)?.offset()(AgoraFit.scale(2))
            make?.left.right().equalTo()(teacherRenderController.view)
            make?.bottom.equalTo()(0)
        }
        
        classToolsController.view.mas_makeConstraints { make in
            make?.left.right().top().bottom().equalTo()(boardController.view)
        }
        
        updateRenderLayout()
    }
    
    func updateViewProperties() {
        
    }
}

// MARK: - AgoraWindowUIControllerDelegate
extension AgoraVocationalUIManager: VocationalWindowUIControllerDelegate {
    func getTargetView(with userId: String) -> UIView? {
        return teacherRenderController.getRenderViewForUser(with: userId)
    }
    
    func getTargetSuperView() -> UIView? {
        return teacherRenderController.view
    }
    
    func startSpreadForUser(with userId: String) {
        teacherRenderController.setRenderEnable(with: userId,
                                                rendEnable: false)
    }
    
    func stopSpreadForUser(with userId: String) {
        teacherRenderController.setRenderEnable(with: userId,
                                                rendEnable: true)
    }
}

// MARK: - AgoraToolBarDelegate
extension AgoraVocationalUIManager: AgoraToolBarDelegate {
    func toolsViewDidSelectTool(tool: FcrToolBarItemType,
                                selectView: UIView) {
        switch tool {
        case .setting:
            settingViewController.view.frame = CGRect(origin: .zero,
                                                      size: settingViewController.suggestSize)
            ctrlView = settingViewController.view
        case .nameRoll:
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
extension AgoraVocationalUIManager: AgoraRenderMenuUIControllerDelegate {
    func onMenuUserLeft() {
        renderMenuController.dismissView()
        renderMenuController.view.isHidden = true
    }
}

// MARK: - AgoraRenderUIControllerDelegate
extension AgoraVocationalUIManager: AgoraRenderUIControllerDelegate {
    func onClickMemberAt(view: UIView,
                         userId: String) {
        guard contextPool.user.getLocalUserInfo().userRole == .teacher else {
            return
        }
        
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
                make?.top.equalTo()(view.mas_bottom)?.offset()(1)
                make?.centerX.equalTo()(view.mas_centerX)
                make?.height.equalTo()(30)
                make?.width.equalTo()(renderMenuController.menuWidth)
            }
        }
    }
}

// MARK: - AgoraChatUIControllerDelegate
extension AgoraVocationalUIManager: AgoraHandsListUIControllerDelegate {
    func updateHandsListRedLabel(_ count: Int) {
        if count == 0,
           ctrlView == handsListController.view {
            ctrlView = nil
        }
        toolBarController.updateHandsListCount(count)
    }
}

// MARK: - AgoraToolCollectionUIControllerDelegate
extension AgoraVocationalUIManager: AgoraToolCollectionUIControllerDelegate {
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
extension AgoraVocationalUIManager: AgoraClassStateUIControllerDelegate {
    func onShowStartClass() {
        guard contextPool.user.getLocalUserInfo().userRole == .teacher else {
            return
        }
        contentView.addSubview(classStateController.view)
        
        classStateController.view.mas_makeConstraints { make in
            make?.left.equalTo()(boardPageController.view.mas_right)?.offset()(UIDevice.current.agora_is_pad ? 15 : 12)
            make?.bottom.equalTo()(boardPageController.view.mas_bottom)
            make?.size.equalTo()(classStateController.suggestSize)
        }
    }
}


private extension AgoraVocationalUIManager {
    func updateRenderLayout() {
        view.layoutIfNeeded()
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .horizontal
        
        layout.itemSize = CGSize(width: AgoraFit.scale(170),
                                 height: teacherRenderController.view.height - 2)
        layout.minimumLineSpacing = 2
        teacherRenderController.updateLayout(layout)
    }
}
