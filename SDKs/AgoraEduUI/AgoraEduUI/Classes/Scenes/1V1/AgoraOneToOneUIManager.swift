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
    private lazy var cloudController = AgoraCloudUIController(context: contextPool)
    
    /** 设置界面 控制器*/
    private lazy var settingViewController: AgoraSettingUIController = {
        let vc = AgoraSettingUIController(context: contextPool)
        vc.roomDelegate = self
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
    private lazy var renderController: AgoraRenderMembersUIController = {
        // 1V1中需要默认两个model
        var models = [AgoraRenderMemberViewModel]()
        let localInfo = contextPool.user.getLocalUserInfo()
        let localStream = contextPool.stream.getStreamList(userUuid: localInfo.userUuid)?.first(where: {$0.videoSourceType == .camera})
        if localInfo.userRole == .student {
            models.append(AgoraRenderMemberViewModel.defaultNilValue(role: .teacher))
            models.append(AgoraRenderMemberViewModel.model(user: localInfo,
                                                           stream: localStream))
        } else {
            models.append(AgoraRenderMemberViewModel.model(user: localInfo,
                                                           stream: localStream))
            models.append(AgoraRenderMemberViewModel.defaultNilValue(role: .student))
        }
        let renderController = AgoraRenderMembersUIController(context: contextPool,
                                                         delegate: self,
                                                         containRoles: [.student,.teacher],
                                                         max: 2,
                                                         dataSource: models)
        return renderController
    }()
    
    /** 右边用来切圆角和显示背景色的容器视图*/
    private lazy var rightContentView = UIView()
    /** 白板 控制器*/
    private lazy var boardController = AgoraBoardUIController(context: contextPool)
   
    /** 工具集合 控制器（观众端没有）*/
    private lazy var toolCollectionController = AgoraToolCollectionUIController(context: contextPool,
                                                                                delegate: self)
    /** 白板翻页 控制器（观众端没有）*/
    private lazy var boardPageController = AgoraBoardPageUIController(context: contextPool)
    /** 聊天 控制器*/
    private lazy var chatController = AgoraChatUIController(context: contextPool)
    /** 教具 控制器*/
    private lazy var classToolsController = AgoraClassToolsUIController(context: contextPool)
    /** 大窗 控制器*/
    private lazy var windowController = AgoraWindowUIController(context: contextPool)
    private lazy var tabSelectView = AgoraOneToOneTabView(frame: .zero,
                                                     delegate: self)
    
    private var isJoinedRoom = false
    
    private var fileWriter = FcrUIFileWriter()
    
    deinit {
        print("\(#function): \(self.classForCoder)")
    }
    
    public override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = UIColor(hex: 0xF9F9FC)
        
        initViews()
        initViewFrame()
        updateViewProperties()
         
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
    
    private func startTestAudioData() {
        let media = contextPool.media
        let config = FcrAudioRawDataConfig()
        
        let sampleSize: Int32 = 2
        let duration: Int32 = 10 // second
        
        fileWriter.byteLimit = Int64(config.sampleRate * Int32(config.channels) * sampleSize * duration)
        
        media.setAudioRawDataConfig(config: config,
                                    position: .record)
        media.addAudioRawDataObserver(observer: self,
                                      position: .record)
    }
    
    private func stopTestAudioData() {
        let media = contextPool.media
        media.removeAudioRawDataObserver(observer: self,
                                         position: .record)
    }
}

extension AgoraOneToOneUIManager: FcrAudioRawDataObserver {
    public func onAudioRawDataRecorded(data: FcrAudioRawData) {
        fileWriter.write(data: data.buffer,
                         to: "audiorawdata.pcm")
    }
}
// MARK: - AgoraUIContentContainer
extension AgoraOneToOneUIManager: AgoraUIContentContainer {
    func initViews() {
        let userRole = contextPool.user.getLocalUserInfo().userRole
        
        addChild(stateController)
        contentView.addSubview(stateController.view)
        
        globalController.roomDelegate = self
        addChild(globalController)
        globalController.viewDidLoad()
        
        // 视图层级：白板，大窗，工具
        addChild(boardController)
        contentView.addSubview(boardController.view)
        
        rightContentView.clipsToBounds = true
        contentView.addSubview(rightContentView)
        
        addChild(renderController)
        rightContentView.addSubview(renderController.view)
        
        windowController.delegate = self
        addChild(windowController)
        contentView.addSubview(windowController.view)
        
        toolBarController.delegate = self
        toolBarController.tools = [.setting]
        contentView.addSubview(toolBarController.view)
        
        addChild(classToolsController)
        contentView.addSubview(classToolsController.view)
        
        if userRole != .observer {
            toolCollectionController.view.isHidden = true
            view.addSubview(toolCollectionController.view)
            
            contentView.addSubview(boardPageController.view)
            boardPageController.view.isHidden = true
            addChild(boardPageController)
        }
        
        if userRole == .teacher {
            addChild(classStateController)
            addChild(cloudController)
            contentView.addSubview(cloudController.view)
            addChild(renderMenuController)
            contentView.addSubview(renderMenuController.view)
            
            renderMenuController.view.isHidden = true
            cloudController.view.isHidden = true
            toolCollectionController.view.isHidden = false
            boardPageController.view.isHidden = false
        }
        
        createChatController()
        
        if !UIDevice.current.isPad {
            rightContentView.addSubview(tabSelectView)
        }
    }
    
    func initViewFrame() {
        let userRole = contextPool.user.getLocalUserInfo().userRole
        stateController.view.mas_makeConstraints { make in
            make?.top.left().right().equalTo()(0)
            make?.height.equalTo()(AgoraFit.scale(23))
        }
        boardController.view.mas_makeConstraints { make in
            make?.left.bottom().equalTo()(0)
            make?.right.equalTo()(rightContentView.mas_left)?.offset()(AgoraFit.scale(-2))
            make?.top.equalTo()(self.stateController.view.mas_bottom)?.offset()(AgoraFit.scale(2))
        }
        windowController.view.mas_makeConstraints { make in
            make?.left.right().top().bottom().equalTo()(boardController.view)
        }
        classToolsController.view.mas_makeConstraints { make in
            make?.left.right().top().bottom().equalTo()(boardController.view)
        }
        
        if userRole == .teacher {
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
        
        if userRole != .observer {
            toolCollectionController.view.mas_makeConstraints { make in
                make?.centerX.equalTo()(self.toolBarController.view.mas_centerX)
                make?.bottom.equalTo()(contentView)?.offset()(UIDevice.current.isPad ? -20 : -15)
                make?.width.height().equalTo()(toolCollectionController.suggestLength)
            }
            boardPageController.view.mas_makeConstraints { make in
                make?.left.equalTo()(contentView)?.offset()(UIDevice.current.isPad ? 15 : 12)
                make?.bottom.equalTo()(contentView)?.offset()(UIDevice.current.isPad ? -20 : -15)
                make?.height.equalTo()(UIDevice.current.isPad ? 34 : 32)
                make?.width.equalTo()(168)
            }
        }
        
        if UIDevice.current.isPad {
            rightContentView.mas_makeConstraints { make in
                make?.top.equalTo()(stateController.view.mas_bottom)?.offset()(AgoraFit.scale(2))
                make?.bottom.right().equalTo()(0)
                make?.width.equalTo()(AgoraFit.scale(170))
            }
            renderController.view.mas_makeConstraints { make in
                make?.top.left().right().equalTo()(0)
                make?.bottom.equalTo()(rightContentView.mas_centerY)
            }
        } else {
            rightContentView.mas_makeConstraints { make in
                make?.top.equalTo()(stateController.view.mas_bottom)?.offset()(AgoraFit.scale(2))
                make?.bottom.right().equalTo()(0)
                make?.width.equalTo()(AgoraFit.scale(170))
            }
            tabSelectView.mas_makeConstraints { make in
                make?.top.left().right().equalTo()(0)
                make?.height.equalTo()(AgoraFit.scale(33))
            }
            renderController.view.mas_makeConstraints { make in
                make?.top.equalTo()(tabSelectView.mas_bottom)?.offset()(AgoraFit.scale(1))
                make?.left.right().bottom().equalTo()(0)
            }
        }
        
        updateRenderLayout()
    }
    
    func updateViewProperties() {
        let ui = AgoraUIGroup()
        
        rightContentView.backgroundColor = ui.color.one_right_content_bg_color
        rightContentView.layer.cornerRadius = ui.frame.one_room_right_corner_radius
    }
}

// MARK: - AgoraOneToOneTabViewDelegate
extension AgoraOneToOneUIManager: AgoraOneToOneTabViewDelegate {
    func onChatTabSelectChanged(isSelected: Bool) {
        renderMenuController.dismissView()
        guard let v = chatController.view else {
            return
        }
        if isSelected {
            rightContentView.addSubview(v)
            v.mas_makeConstraints { make in
                make?.top.equalTo()(tabSelectView.mas_bottom)
                make?.left.right().bottom().equalTo()(0)
            }
        } else {
            v.removeFromSuperview()
        }
    }
}

// MARK: - AgoraWindowUIControllerDelegate
extension AgoraOneToOneUIManager: AgoraWindowUIControllerDelegate {
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

// MARK: - AgoraToolBarDelegate
extension AgoraOneToOneUIManager: AgoraToolBarDelegate {
    func toolsViewDidSelectTool(tool: AgoraToolBarUIController.ItemType,
                                selectView: UIView) {
        switch tool {
        case .setting:
            settingViewController.view.frame = CGRect(origin: .zero,
                                                      size: settingViewController.suggestSize)
            ctrlView = settingViewController.view
        default:
            break
        }
        ctrlViewAnimationFromView(selectView)
    }
    
    func toolsViewDidDeselectTool(tool: AgoraToolBarUIController.ItemType) {
        ctrlView = nil
    }
}

// MARK: - AgoraChatUIControllerDelegate
extension AgoraOneToOneUIManager: AgoraChatUIControllerDelegate {
    func updateChatRedDot(isShow: Bool) {
        tabSelectView.updateChatRedDot(isShow: isShow)
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
                cloudController.view.mas_remakeConstraints { make in
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
}

// MARK: - AgoraRenderUIControllerDelegate
extension AgoraOneToOneUIManager: AgoraRenderUIControllerDelegate {
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
            renderMenuController.show(roomType: .oneToOne,
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

// MARK: - AgoraRenderMenuUIControllerDelegate
extension AgoraOneToOneUIManager: AgoraRenderMenuUIControllerDelegate {
    func onMenuUserLeft() {
        renderMenuController.dismissView()
        renderMenuController.view.isHidden = true
    }
}

// MARK: - AgoraClassStateUIControllerDelegate
extension AgoraOneToOneUIManager: AgoraClassStateUIControllerDelegate {
    func onShowStartClass() {
        guard contextPool.user.getLocalUserInfo().userRole == .teacher else {
            return
        }
        contentView.addSubview(classStateController.view)
        
        classStateController.view.mas_makeConstraints { make in
            make?.left.equalTo()(boardPageController.view.mas_right)?.offset()(UIDevice.current.isPad ? 15 : 12)
            make?.bottom.equalTo()(boardPageController.view.mas_bottom)
            make?.size.equalTo()(classStateController.suggestSize)
        }
    }
}

// MARK: - Creations
private extension AgoraOneToOneUIManager {
    func settingViewAnimationFromView(_ formView: UIView) {
        guard let animaView = ctrlView else {
            return
        }
        // 算出落点的frame
        let rect = formView.convert(formView.bounds,
                                    to: self.view)
        var point = CGPoint(x: rect.maxX - animaView.frame.size.width, y: rect.maxY + 8)
        animaView.frame = CGRect(origin: point, size: animaView.frame.size)
        // 运算动画锚点
        let anchorConvert = formView.convert(formView.bounds, to: animaView)
        let anchor = CGPoint(x: anchorConvert.origin.x/animaView.frame.width, y: 0)
        // 开始动画运算
        let oldFrame = animaView.frame
        let position = CGPoint(x: animaView.layer.position.x + (anchor.x - 0.5) * animaView.bounds.width,
                               y: animaView.layer.position.y + (anchor.y - 0.5) * animaView.bounds.height)
        animaView.layer.anchorPoint = anchor
        animaView.frame = oldFrame
        animaView.alpha = 0.2
        animaView.transform = CGAffineTransform(scaleX: 0.8, y: 0.8)
        self.view.layoutIfNeeded()
        UIView.animate(withDuration: 0.1) {
            animaView.transform = .identity
            animaView.alpha = 1
        } completion: { finish in
        }
    }

    func updateRenderLayout() {
        view.layoutIfNeeded()
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .vertical
        
        layout.itemSize = CGSize(width: AgoraFit.scale(170),
                                 height: (renderController.view.height - 2) / 2)
        layout.minimumLineSpacing = 2
        renderController.updateLayout(layout)
    }
    
    func createChatController() {
        if UIDevice.current.isPad {
            chatController.hideMiniButton = true
            chatController.hideAnnouncement = true
        } else {
            chatController.hideTopBar = true
        }
        if contextPool.user.getLocalUserInfo().userRole == .observer {
            chatController.hideInput = true
        }
        addChild(chatController)
        if UIDevice.current.isPad {
            rightContentView.addSubview(chatController.view)
            chatController.view.mas_makeConstraints { make in
                make?.left.right().bottom().equalTo()(0)
                make?.top.equalTo()(rightContentView.mas_centerY)
            }
        } else {
            let _ = chatController.view
        }

        chatController.delegate = self
    }
}
