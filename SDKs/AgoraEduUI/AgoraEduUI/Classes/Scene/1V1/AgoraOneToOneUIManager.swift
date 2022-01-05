//
//  AgoraOneToOneUIManager.swift
//  AgoraEduUI
//
//  Created by Jonathan on 2021/11/15.
//

import AgoraUIEduBaseViews
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
    /** 右边用来切圆角和显示背景色的容器视图*/
    private var rightContentView: UIView!
    /** 白板 控制器*/
    private var boardController: AgoraBoardUIController!
    /** 画板工具 控制器*/
    private var brushToolsController: AgoraBoardToolsUIController!
    /** 聊天 控制器*/
    private var chatController: AgoraChatUIController?
    /** 屏幕分享 控制器*/
    private var screenSharingController: AgoraScreenSharingUIController!
    
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
        brushToolsController.button.isSelected = false
    }
}
// MARK: - AgoraOneToOneTabViewDelegate
extension AgoraOneToOneUIManager: AgoraOneToOneTabViewDelegate {
    func onChatTabSelectChanged(isSelected: Bool) {
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
        if isSelected {
            ctrlView = settingViewController.view
            ctrlView?.mas_makeConstraints { make in
                make?.width.equalTo()(201)
                make?.height.equalTo()(220)
                make?.top.equalTo()(AgoraFit.scale(30))
                make?.right.equalTo()(self.contentView)?.offset()((-10))
            }
        } else {
            ctrlView = nil
        }
    }
}
// MARK: - AgoraBoardToolsUIControllerDelegate
extension AgoraOneToOneUIManager: AgoraBoardToolsUIControllerDelegate {
    func onShowBrushTools(isShow: Bool) {
        if isShow {
            stateController.deSelect()
            ctrlView = brushToolsController.view
            ctrlView?.mas_makeConstraints { make in
                make?.right.equalTo()(brushToolsController.button.mas_left)?.offset()(-7)
                make?.bottom.equalTo()(brushToolsController.button)?.offset()(-10)
            }
        } else {
            ctrlView = nil
        }
    }
}
// MARK: - Creations
private extension AgoraOneToOneUIManager {
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
        
        renderController = AgoraOneToOneRenderUIController(context: contextPool)
        addChild(renderController)
        rightContentView.addSubview(renderController.view)
        
        screenSharingController = AgoraScreenSharingUIController(context: contextPool)
        addChild(screenSharingController)
        contentView.addSubview(screenSharingController.view)
        
        brushToolsController = AgoraBoardToolsUIController(context: contextPool)
        brushToolsController.delegate = self
        self.addChild(brushToolsController)
        view.addSubview(brushToolsController.button)
    }
    
    func createConstrains() {
        stateController.view.mas_makeConstraints { [unowned self] make in
            make?.top.left().right().equalTo()(0)
            make?.height.equalTo()(AgoraFit.scale(23))
        }
        boardController.view.mas_makeConstraints { make in
            make?.left.bottom().equalTo()(0)
            make?.right.equalTo()(rightContentView.mas_left)?.offset()(AgoraFit.scale(-2))
            make?.top.equalTo()(self.stateController.view.mas_bottom)?.offset()(AgoraFit.scale(2))
        }
        brushToolsController.button.mas_makeConstraints { make in
            make?.right.equalTo()(boardController.view)?.offset()(AgoraFit.scale(-6))
            make?.bottom.equalTo()(boardController.view)?.offset()(AgoraFit.scale(-6))
            make?.width.height().equalTo()(36)
        }
        screenSharingController.view.mas_makeConstraints { make in
            make?.left.bottom().equalTo()(0)
            make?.top.equalTo()(self.stateController.view.mas_bottom)?.offset()(2)
            make?.right.equalTo()(rightContentView.mas_left)
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
