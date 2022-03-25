//
//  AkOneToOneUIManager.swift
//  AgoraClassroomSDK_iOS
//
//  Created by LYY on 2022/3/8.
//

import AgoraUIBaseViews
import AgoraEduContext
import AgoraWidget
import Masonry

@objc public class AkOneToOneUIManager: AgoraEduUIManager {
    private let roomType: AgoraEduContextRoomType = .oneToOne
    /** 状态栏 控制器*/
    private var stateController: AgoraRoomStateUIController!
    /** 渲染 控制器*/
    private var renderController: AkOneToOneRenderUIController!
    /** 工具栏*/
    private var toolBarController: AgoraToolBarUIController!
    /** 视窗菜单 控制器（仅教师端）*/
    private lazy var renderMenuController: AkOneToOneRenderUIController = {
        let vc = AkOneToOneRenderUIController(context: contextPool,
                                              delegate: self)
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
    private var chatController: AgoraChatUIController!
    /** 屏幕分享 控制器*/
    private var screenSharingController: AgoraScreenSharingUIController!
    /** 教具 控制器*/
    private var classToolsController: AgoraClassToolsViewController!
    /** 设置界面 控制器*/
    private lazy var settingViewController: AgoraSettingUIController = {
        let vc = AgoraSettingUIController(context: contextPool)
        vc.roomDelegate = self
        self.addChild(vc)
        return vc
    }()
    
    private lazy var logoImageView: UIImageView = {
        let imgView = UIImageView()
        imgView.image = UIImage.agedu_named(UIDevice.current.isPad ? "ak_ipad_logo" : "ak_iphone_logo")
        return imgView
    }()
    
    private var isJoinedRoom = false
    
    deinit {
        print("\(#function): \(self.classForCoder)")
    }
    
    public override func viewDidLoad() {
        super.viewDidLoad()
        
        self.createViews()
        self.createConstraint()
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
        toolBarController.deselectAll()
    }
}

// MARK: - AgoraChatUIControllerDelegate
extension AkOneToOneUIManager: AgoraChatUIControllerDelegate {
    func updateChatRedDot(isShow: Bool) {
        toolBarController.updateChatRedDot(isShow: isShow)
    }
}

// MARK: - AgoraToolCollectionUIControllerDelegate
extension AkOneToOneUIManager: AgoraToolCollectionUIControllerDelegate {
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
extension AkOneToOneUIManager: AgoraRenderUIControllerDelegate {
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

// MARK: - AgoraToolBarDelegate
extension AkOneToOneUIManager: AgoraToolBarDelegate {
    func toolsViewDidSelectTool(tool: AgoraToolBarUIController.ItemType,
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
    
    func toolsViewDidDeselectTool(tool: AgoraToolBarUIController.ItemType) {
        ctrlView = nil
    }
}

// MARK: - Creations
private extension AkOneToOneUIManager {
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
    func createViews() {
        stateController = AgoraRoomStateUIController(context: contextPool)
        stateController.roomDelegate = self
        addChild(stateController)
        contentView.addSubview(stateController.view)

        boardController = AgoraBoardUIController(context: contextPool)
        addChild(boardController)
        contentView.addSubview(boardController.view)
        
        rightContentView = UIView()
        rightContentView.backgroundColor = AgoraColorGroup().room_bg_color
        rightContentView.layer.cornerRadius = 4.0
        rightContentView.clipsToBounds = true
        contentView.addSubview(rightContentView)
        
        renderController = AkOneToOneRenderUIController(context: contextPool,
                                                           delegate: self)
        addChild(renderController)
        rightContentView.addSubview(renderController.view)
        if UIDevice.current.isPad {
            stateController.view.addSubview(logoImageView)
        } else {
            rightContentView.addSubview(logoImageView)
        }
        
        toolBarController = AgoraToolBarUIController(context: contextPool)
        toolBarController.delegate = self
        toolBarController.tools = [.setting]
        contentView.addSubview(toolBarController.view)
        
        toolCollectionController = AgoraToolCollectionUIController(context: contextPool,
                                                                   delegate: self)
        toolCollectionController.view.isHidden = true
        view.addSubview(toolCollectionController.view)
        
        boardPageController = AgoraBoardPageUIController(context: contextPool)
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
        
        screenSharingController = AgoraScreenSharingUIController(context: contextPool)
        addChild(screenSharingController)
        contentView.addSubview(screenSharingController.view)
    }
    
    func createConstraint() {
        stateController.view.mas_makeConstraints { make in
            make?.top.left().right().equalTo()(0)
            make?.height.equalTo()(24)
        }
        boardController.view.mas_makeConstraints { make in
            make?.left.bottom().equalTo()(0)
            make?.right.equalTo()(rightContentView.mas_left)?.offset()(-2)
            make?.top.equalTo()(self.stateController.view.mas_bottom)?.offset()(2)
        }
        if contextPool.user.getLocalUserInfo().userRole == .teacher {
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
        toolCollectionController.view.mas_makeConstraints { make in
            make?.centerX.equalTo()(self.toolBarController.view.mas_centerX)
            make?.bottom.equalTo()(contentView)?.offset()(UIDevice.current.isPad ? -20 : -15)
            make?.width.height().equalTo()(toolCollectionController.suggestLength)
        }
        screenSharingController.view.mas_makeConstraints { make in
            make?.left.bottom().equalTo()(0)
            make?.top.equalTo()(self.stateController.view.mas_bottom)?.offset()(2)
            make?.right.equalTo()(rightContentView.mas_left)
        }
        boardPageController.view.mas_makeConstraints { make in
            make?.left.equalTo()(contentView)?.offset()(UIDevice.current.isPad ? 15 : 12)
            make?.bottom.equalTo()(contentView)?.offset()(UIDevice.current.isPad ? -20 : -15)
            make?.height.equalTo()(UIDevice.current.isPad ? 34 : 32)
            make?.width.equalTo()(168)
        }
        classToolsController.view.mas_makeConstraints { make in
            make?.left.right().top().bottom().equalTo()(boardController.view)
        }
    }
    
    func createPhoneViews() {
        rightContentView.mas_makeConstraints { make in
            make?.top.equalTo()(stateController.view.mas_bottom)?.offset()(AgoraFit.scale(2))
            make?.bottom.right().equalTo()(0)
            make?.width.equalTo()(AgoraFit.scale(170))
        }
        logoImageView.mas_makeConstraints { make in
            make?.centerX.equalTo()(0)
            make?.bottom.equalTo()(0)
            make?.height.equalTo()(AgoraFit.scale(20))
            make?.width.equalTo()(AgoraFit.scale(82))
        }
        renderController.view.mas_makeConstraints { make in
            make?.top.equalTo()(AgoraFit.scale(1))
            make?.bottom.equalTo()(logoImageView.mas_top)?.offset()(AgoraFit.scale(-6))
            make?.left.right().equalTo()(0)
        }
    }
    
    func createPadViews() {
        rightContentView.mas_makeConstraints { make in
            make?.top.equalTo()(stateController.view.mas_bottom)?.offset()(AgoraFit.scale(2))
            make?.bottom.right().equalTo()(0)
            make?.width.equalTo()(AgoraFit.scale(170))
        }
        logoImageView.mas_makeConstraints { make in
            make?.centerX.centerY().equalTo()(stateController.view)
        }
        renderController.view.mas_makeConstraints { make in
            make?.top.left().right().equalTo()(0)
            make?.bottom.equalTo()(rightContentView.mas_centerY)
        }
    }
    
    func createChatController() {
        chatController = AgoraChatUIController(context: contextPool)
        chatController.hideAnnouncement = true
        chatController.hideMiniButton = true
        
        chatController.delegate = self
        
        AgoraUIGroup().color.borderSet(layer: chatController.view.layer)
        addChild(chatController)
        if UIDevice.current.isPad {
            rightContentView.addSubview(chatController.view)
            chatController.view.mas_makeConstraints { make in
                make?.left.right().bottom().equalTo()(0)
                make?.top.equalTo()(rightContentView.mas_centerY)
            }
        }
    }
}

