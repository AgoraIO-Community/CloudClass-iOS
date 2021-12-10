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
    private var boardController: UIViewController!
    /** 聊天 控制器*/
    private var messageController: AgoraChatUIController?
    
    private var tabSelectView: AgoraOneToOneTabView?
    
    /** 设置界面 控制器*/
    private lazy var settingViewController: AgoraSettingUIController = {
        let vc = AgoraSettingUIController(context: contextPool)
        vc.delegate = self
        self.addChild(vc)
        return vc
    }()
    
    @objc public override init(contextPool: AgoraEduContextPool,
                               delegate: AgoraEduUIManagerDelegate) {
        super.init(contextPool: contextPool,
                   delegate: delegate)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
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
            self.createChatController()
        } fail: { [weak self] error in
            AgoraLoading.hide()
            self?.contextPool.room.leaveRoom()
        }
    }
    
    public override func didClickCtrlMaskView() {
        super.didClickCtrlMaskView()
        stateController.deSelect()
    }
}

extension AgoraOneToOneUIManager: AgoraOneToOneTabViewDelegate {
    func onChatTabSelectChanged(isSelected: Bool) {
        messageController?.view.isHidden = !isSelected
    }
}

// Mark: - AgoraOneToOneStateUIControllerDelegate
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
// Mark: - Creations
private extension AgoraOneToOneUIManager {
    func createViews() {
        stateController = AgoraOneToOneStateUIController(context: contextPool)
        stateController.delegate = self
        addChild(stateController)
        contentView.addSubview(stateController.view)
        
        boardController = UIViewController()
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
    }
    
    func createConstrains() {
        stateController.view.mas_makeConstraints { [unowned self] make in
            make?.top.left().right().equalTo()(0)
            make?.height.equalTo()(AgoraFit.scale(23))
        }
        boardController.view.mas_makeConstraints { make in
            make?.left.bottom().equalTo()(0)
            make?.top.equalTo()(self.stateController.view.mas_bottom)?.offset()(3)
        }
    }
    
    func createPhoneViews() {
        let v = AgoraOneToOneTabView(frame: .zero)
        v.delegate = self
        rightContentView.addSubview(v)
        tabSelectView = v
        
        rightContentView.mas_makeConstraints { make in
            make?.top.equalTo()(stateController.view.mas_bottom)?.offset()(2)
            make?.bottom.right().equalTo()(0)
            make?.width.equalTo()(AgoraFit.scale(170))
        }
        tabSelectView?.mas_makeConstraints { make in
            make?.top.left().right().equalTo()(0)
            make?.height.equalTo()(AgoraFit.scale(33))
        }
        renderController.view.mas_makeConstraints { make in
            make?.top.equalTo()(tabSelectView?.mas_bottom)
            make?.left.right().bottom().equalTo()(0)
        }
    }
    
    func createPadViews() {
        rightContentView.mas_makeConstraints { make in
            make?.top.equalTo()(stateController.view)
            make?.bottom.right().equalTo()(0)
            make?.width.equalTo()(340)
        }
        renderController.view.mas_makeConstraints { make in
            make?.top.left().right().equalTo()(0)
        }
    }
    
    func createChatController() {
        let controller = AgoraChatUIController()
        controller.contextPool = contextPool
        
        controller.view.isHidden = true
        rightContentView.addSubview(controller.view)
        
        if UIDevice.current.isPad {
            controller.view.mas_makeConstraints { make in
                make?.top.equalTo()(renderController.view.mas_bottom)
                make?.left.right().bottom().equalTo()(0)
            }
        } else {
            controller.view.mas_makeConstraints { make in
                make?.top.equalTo()(tabSelectView?.mas_bottom)
                make?.left.right().bottom().equalTo()(0)
            }
        }
        
        messageController = controller
    }
}

// MARK: - Layout
private extension AgoraOneToOneUIManager {
    
    func boardControllerLayout(isFullScreen: Bool = false,
                               needAnimation: Bool = false) {
        defer {
            if needAnimation {
                UIView.animate(withDuration: TimeInterval.agora_animation) { [unowned self] in
                    self.view.layoutIfNeeded()
                }
            } else {
                view.layoutIfNeeded()
            }
        }
        
        let isTraditional = UIDevice.current.isTraditionalChineseLanguage
        
        boardController.view.mas_remakeConstraints { [unowned self] make in
            let space: CGFloat = 12
            
            let rightSpace: CGFloat = (isFullScreen ? 0 : space)
            let leftSpace: CGFloat = (isFullScreen ? 0 : space)
            let bottomSpace: CGFloat = (isFullScreen ? 0 : space)
            let topSpace: CGFloat = (isFullScreen ? 0 : space)
            
            // right
            if isTraditional {
                if #available(iOS 11.0, *) {
                    make?.right.equalTo()(self.view.mas_safeAreaLayoutGuideRight)?.offset()(-rightSpace)
                } else {
                    make?.right.equalTo()(-rightSpace)
                }
            } else {
                if isFullScreen {
                    if #available(iOS 11.0, *) {
                        make?.right.equalTo()(self.view.mas_safeAreaLayoutGuideRight)?.offset()(-rightSpace)
                    } else {
                        make?.right.equalTo()(-rightSpace)
                    }
                } else {
                    make?.right.equalTo()(self.renderController.view.mas_left)?.offset()(-rightSpace)
                }
            }
            
            // left
            if isTraditional {
                if isFullScreen {
                    if #available(iOS 11.0, *) {
                        make?.left.equalTo()(self.view.mas_safeAreaLayoutGuideLeft)?.offset()(leftSpace)
                    } else {
                        make?.left.equalTo()(leftSpace)
                    }
                } else {
                    make?.left.equalTo()(self.renderController.view.mas_right)?.offset()(leftSpace)
                }
            } else {
                if #available(iOS 11.0, *) {
                    make?.left.equalTo()(self.view.mas_safeAreaLayoutGuideLeft)?.offset()(leftSpace)
                } else {
                    make?.left.equalTo()(leftSpace)
                }
            }
            
            // top
            make?.top.equalTo()(stateController.view.mas_bottom)?.offset()(topSpace)
            
            // bottom
            if #available(iOS 11.0, *) {
                make?.bottom.equalTo()(self.view.mas_safeAreaLayoutGuideBottom)?.offset()(-bottomSpace)
            } else {
                make?.bottom.equalTo()(-bottomSpace)
            }
        }
    }
}
// MARK: - AkBoardUIControllerDelegate
extension AgoraOneToOneUIManager {
    func onFullScreenMode(isFullScreen: Bool) {
        boardControllerLayout(isFullScreen: isFullScreen,
                              needAnimation: true)
    }
}

// MARK: - AgoraSettingUIControllerDelegate
extension AgoraOneToOneUIManager: AgoraSettingUIControllerDelegate {
    func settingUIControllerDidPressedLeaveRoom(controller: AgoraSettingUIController) {
        exit(reason: .normal)
    }
}
