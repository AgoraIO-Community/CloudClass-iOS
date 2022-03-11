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

@objc public class AgoraOneToOneUIManager: AgoraEduUIManager {
    
    private let roomType: AgoraEduContextRoomType = .oneToOne
    /** 状态栏 控制器*/
    private var stateController: AgoraOneToOneStateUIController!
    /** 渲染 控制器*/
    private var renderController: AgoraOneToOneRenderUIController!
    /** 视窗菜单 控制器（仅教师端）*/
    private lazy var renderMenuController: AgoraRenderMenuUIController = {
        let vc = AgoraRenderMenuUIController(context: contextPool)
        vc.delegate = self
        return vc
    }()
    /** 右边用来切圆角和显示背景色的容器视图*/
    private var rightContentView: UIView!
    /** 白板 控制器*/
    private var boardController: AgoraBoardUIController!
    /** 云盘 控制器（仅教师端）*/
    private lazy var cloudController: AgoraCloudUIController = {
        let vc = AgoraCloudUIController(context: contextPool)
        return vc
    }()
    /** 工具集合 控制器*/
    private var toolCollectionController: AgoraToolCollectionUIController!
    /** 白板翻页 控制器*/
    private var boardPageController: AgoraBoardPageUIController!
    /** 聊天 控制器*/
    private var chatController: AgoraChatUIController?
    /** 屏幕分享 控制器*/
    private var screenSharingController: AgoraScreenSharingUIController!
    /** 教具 控制器*/
    private var classToolsController: AgoraClassToolsViewController!
    private var tabSelectView: AgoraOneToOneTabView?
    /** 设置界面 控制器*/
    private lazy var settingViewController: AgoraSettingUIController = {
        let vc = AgoraSettingUIController(context: contextPool)
        vc.roomDelegate = self
        self.addChild(vc)
        return vc
    }()
    
    private var isJoinedRoom = false
    
    deinit {
        print("\(#function): \(self.classForCoder)")
    }
    
    public override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = UIColor(hex: 0xF9F9FC)
        
        self.createViews()
        self.createConstrains()
        if UIDevice.current.isPad {
            self.createPadViews()
        } else {
            self.createPhoneViews()
        }
        contextPool.room.joinRoom { [weak self] in
            AgoraLoading.hide()
            guard let `self` = self else {
                return
            }
            self.isJoinedRoom = true
            self.createChatController()
            // 打开本地音视频设备
            self.contextPool.media.openLocalDevice(systemDevice: .frontCamera)
            self.contextPool.media.openLocalDevice(systemDevice: .mic)
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
        stateController.deSelect()
    }
}
// MARK: - AgoraOneToOneTabViewDelegate
extension AgoraOneToOneUIManager: AgoraOneToOneTabViewDelegate {
    func onChatTabSelectChanged(isSelected: Bool) {
        renderMenuController.dismissView()
        guard let v = chatController?.view else {
            return
        }
        if isSelected {
            rightContentView.addSubview(v)
            v.mas_makeConstraints { make in
                make?.top.equalTo()(tabSelectView?.mas_bottom)
                make?.left.right().bottom().equalTo()(0)
            }
        } else {
            v.removeFromSuperview()
        }
    }
}

// MARK: - AgoraChatUIControllerDelegate
extension AgoraOneToOneUIManager: AgoraChatUIControllerDelegate {
    func updateChatRedDot(isShow: Bool) {
        tabSelectView?.updateChatRedDot(isShow: isShow)
    }
}
// MARK: - AgoraOneToOneStateUIControllerDelegate
extension AgoraOneToOneUIManager: AgoraOneToOneStateUIControllerDelegate {
    func onSettingSelected(isSelected: Bool) {
        renderMenuController.dismissView()
        if isSelected {
            settingViewController.view.frame = CGRect(origin: .zero,
                                                      size: settingViewController.suggestSize)
            ctrlView = settingViewController.view
            settingViewAnimationFromView(stateController.settingButton)
        } else {
            ctrlView = nil
        }
    }
}
// MARK: - AgoraToolCollectionUIControllerDelegate
extension AgoraOneToOneUIManager: AgoraToolCollectionUIControllerDelegate {
    func toolCollectionDidSelectCell(view: UIView) {
        renderMenuController.dismissView()
        ctrlView = view
        ctrlViewAnimationFromView(toolCollectionController.view)
    }
    
    func toolCollectionCellNeedSpread(_ spread: Bool) {
        if spread {
            toolCollectionController.view.mas_remakeConstraints { make in
                make?.right.equalTo()(boardController.view)?.offset()(AgoraFit.scale(-12))
                make?.bottom.equalTo()(contentView)?.offset()(AgoraFit.scale(-15))
                make?.width.equalTo()(AgoraFit.scale(32))
                make?.height.equalTo()(AgoraFit.scale(80))
            }
        } else {
            toolCollectionController.view.mas_remakeConstraints { make in
                make?.right.equalTo()(boardController.view)?.offset()(AgoraFit.scale(-12))
                make?.bottom.equalTo()(contentView)?.offset()(AgoraFit.scale(-15))
                make?.width.equalTo()(AgoraFit.scale(32))
                make?.height.equalTo()(AgoraFit.scale(32))
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
                    make?.center.equalTo()(boardController.view)
                    make?.width.equalTo()(AgoraFit.scale(435))
                    make?.height.equalTo()(AgoraFit.scale(253))
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

// MARK: - AgoraBoardPageUIControllerDelegate
extension AgoraOneToOneUIManager: AgoraBoardPageUIControllerDelegate {
    func boardPageUINeedMove(coursewareMin: Bool) {
        UIView.animate(withDuration: TimeInterval.agora_animation,
                       delay: 0,
                       options: .curveEaseInOut,
                       animations: { [weak self] in
            self?.boardPageController.view.transform = CGAffineTransform(translationX: coursewareMin ? 32 : 0,
                                                                         y: 0)
        }, completion: nil)
    }
}

// MARK: - AgoraRenderUIControllerDelegate
extension AgoraOneToOneUIManager: AgoraRenderUIControllerDelegate {
    func onClickMemberAt(view: UIView,
                         UUID: String) {
        guard contextPool.user.getLocalUserInfo().userRole == .teacher else {
            return
        }
        
        var role = AgoraEduContextUserRole.student
        if let teacehr = contextPool.user.getUserList(role: .teacher)?.first,
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
            renderMenuController.show(roomType: .oneToOne,
                                      userUuid: UUID,
                                      showRoleType: role)
            renderMenuController.view.mas_remakeConstraints { make in
                make?.bottom.equalTo()(view.mas_bottom)?.offset()(AgoraFit.scale(1))
                make?.centerX.equalTo()(view.mas_centerX)
                make?.height.equalTo()(AgoraFit.scale(36))
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
        return
    }
}

// MARK: - AgoraRenderMenuUIControllerDelegate
extension AgoraOneToOneUIManager: AgoraRenderMenuUIControllerDelegate {
    func onMenuUserLeft() {
        renderMenuController.dismissView()
        renderMenuController.view.isHidden = true
    }
}

// MARK: - Creations
private extension AgoraOneToOneUIManager {
    func settingViewAnimationFromView(_ formView: UIView) {
        guard let animaView = ctrlView else {
            return
        }
        // 算出落点的frame
        let rect = formView.convert(formView.bounds, to: self.view)
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
    func createViews() {
        stateController = AgoraOneToOneStateUIController(context: contextPool)
        stateController.delegate = self
        stateController.roomDelegate = self
        addChild(stateController)
        contentView.addSubview(stateController.view)
        
        boardController = AgoraBoardUIController(context: contextPool)
        addChild(boardController)
        contentView.addSubview(boardController.view)
        
        rightContentView = UIView()
        rightContentView.backgroundColor = .white
        rightContentView.layer.cornerRadius = 4.0
        rightContentView.clipsToBounds = true
        contentView.addSubview(rightContentView)
        
        renderController = AgoraOneToOneRenderUIController(context: contextPool,
                                                           delegate: self)
        addChild(renderController)
        rightContentView.addSubview(renderController.view)
        
        screenSharingController = AgoraScreenSharingUIController(context: contextPool)
        addChild(screenSharingController)
        contentView.addSubview(screenSharingController.view)
        
        toolCollectionController = AgoraToolCollectionUIController(context: contextPool,
                                                                   delegate: self)
        toolCollectionController.view.isHidden = true
        view.addSubview(toolCollectionController.view)
        
        boardPageController = AgoraBoardPageUIController(context: contextPool,
                                                         delegate: self)
        contentView.addSubview(boardPageController.view)
        boardPageController.view.isHidden = true
        addChild(boardPageController)
        
        classToolsController = AgoraClassToolsViewController(context: contextPool)
        addChild(classToolsController)
        contentView.addSubview(classToolsController.view)
        
        if contextPool.user.getLocalUserInfo().userRole == .teacher {
            addChild(cloudController)
            contentView.addSubview(cloudController.view)
            addChild(renderMenuController)
            contentView.addSubview(renderMenuController.view)
            
            renderMenuController.view.isHidden = true
            cloudController.view.isHidden = true
            toolCollectionController.view.isHidden = false
            boardPageController.view.isHidden = false
        }
    }
    
    func createConstrains() {
        stateController.view.mas_makeConstraints { make in
            make?.top.left().right().equalTo()(0)
            make?.height.equalTo()(AgoraFit.scale(23))
        }
        boardController.view.mas_makeConstraints { make in
            make?.left.bottom().equalTo()(0)
            make?.right.equalTo()(rightContentView.mas_left)?.offset()(AgoraFit.scale(-2))
            make?.top.equalTo()(self.stateController.view.mas_bottom)?.offset()(AgoraFit.scale(2))
        }
        toolCollectionController.view.mas_makeConstraints { make in
            make?.right.equalTo()(boardController.view)?.offset()(AgoraFit.scale(-12))
            make?.bottom.equalTo()(boardController.view)?.offset()(AgoraFit.scale(-15))
            make?.width.equalTo()(AgoraFit.scale(32))
            make?.height.equalTo()(AgoraFit.scale(80))
        }
        screenSharingController.view.mas_makeConstraints { make in
            make?.left.bottom().equalTo()(0)
            make?.top.equalTo()(self.stateController.view.mas_bottom)?.offset()(2)
            make?.right.equalTo()(rightContentView.mas_left)
        }
        boardPageController.view.mas_makeConstraints { make in
            make?.left.equalTo()(contentView)?.offset()(AgoraFit.scale(12))
            make?.bottom.equalTo()(contentView)?.offset()(AgoraFit.scale(-15))
            make?.height.equalTo()(AgoraFit.scale(32))
            make?.width.equalTo()(AgoraFit.scale(168))
        }
        classToolsController.view.mas_makeConstraints { make in
            make?.left.right().top().bottom().equalTo()(boardController.view)
        }
    }
    
    func createPhoneViews() {
        let v = AgoraOneToOneTabView(frame: .zero)
        v.delegate = self
        rightContentView.addSubview(v)
        tabSelectView = v
        
        rightContentView.mas_makeConstraints { make in
            make?.top.equalTo()(stateController.view.mas_bottom)?.offset()(AgoraFit.scale(2))
            make?.bottom.right().equalTo()(0)
            make?.width.equalTo()(AgoraFit.scale(170))
        }
        tabSelectView?.mas_makeConstraints { make in
            make?.top.left().right().equalTo()(0)
            make?.height.equalTo()(AgoraFit.scale(33))
        }
        renderController.view.mas_makeConstraints { make in
            make?.top.equalTo()(tabSelectView?.mas_bottom)?.offset()(AgoraFit.scale(1))
            make?.left.right().bottom().equalTo()(0)
        }
    }
    
    func createPadViews() {
        rightContentView.mas_makeConstraints { make in
            make?.top.equalTo()(stateController.view.mas_bottom)?.offset()(AgoraFit.scale(2))
            make?.bottom.right().equalTo()(0)
            make?.width.equalTo()(AgoraFit.scale(170))
        }
        renderController.view.mas_makeConstraints { make in
            make?.top.left().right().equalTo()(0)
            make?.bottom.equalTo()(rightContentView.mas_centerY)
        }
    }
    
    func createChatController() {
        let controller = AgoraChatUIController(context: contextPool)
        if UIDevice.current.isPad {
            controller.hideMiniButton = true
            controller.hideAnnouncement = true
        } else {
            controller.hideTopBar = true
        }
        addChild(controller)
        if UIDevice.current.isPad {
            rightContentView.addSubview(controller.view)
            controller.view.mas_makeConstraints { make in
                make?.left.right().bottom().equalTo()(0)
                make?.top.equalTo()(rightContentView.mas_centerY)
            }
        } else {
            let _ = controller.view
        }
        chatController = controller
        chatController?.delegate = self
    }
}
