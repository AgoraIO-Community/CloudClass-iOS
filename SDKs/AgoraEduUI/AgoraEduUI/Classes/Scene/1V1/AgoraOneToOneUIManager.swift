//
//  AgoraOneToOneUIManager.swift
//  AgoraEduUI
//
//  Created by Jonathan on 2021/11/15.
//

import AgoraUIEduBaseViews
import AgoraUIBaseViews
import AgoraEduContext
import Masonry

class AgoraOneToOneUIManager: AgoraEduUIManager {
    
    private let roomType: AgoraEduContextRoomType = .oneToOne
    /** 状态栏 控制器*/
    private var stateController: AgoraOneToOneStateUIController!
    /** 渲染 控制器*/
    private var renderController: AgoraOneToOneRenderUIController!
    
    private var boardController: UIViewController!
    
    private var chatController: UIViewController!
    
    /** 设置界面 控制器*/
    private lazy var settingViewController: AgoraSettingUIController = {
        let vc = AgoraSettingUIController(context: contextPool)
        vc.delegate = self
        self.addChild(vc)
        return vc
    }()
    
    /// 弹窗控制器
    /** 控制器遮罩层，用来盛装控制器和处理手势触发消失事件*/
    private var ctrlMaskView: UIView!
    /** 弹出显示的控制widget视图*/
    private weak var ctrlView: UIView? {
        willSet {
            if let view = ctrlView {
                ctrlView?.removeFromSuperview()
                ctrlMaskView.isHidden = true
            }
            if let view = newValue {
                ctrlMaskView.isHidden = false
                self.view.addSubview(view)
            }
        }
    }
    
    public override init(contextPool: AgoraEduContextPool,
                         delegate: AgoraEduUIManagerDelegate) {
        super.init(contextPool: contextPool,
                   delegate: delegate)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = UIColor(hex: 0xF9F9FC)
        createViews()
        createConstrains()
        
        contextPool.room.joinClassroom()
    }
}
// Mark: - Actions
private extension AgoraOneToOneUIManager {
    @objc func onClickCtrlMaskView(_ sender: UITapGestureRecognizer) {
        ctrlView = nil
        stateController.deSelect()
    }
}
// Mark: - AgoraOneToOneStateUIControllerDelegate
extension AgoraOneToOneUIManager: AgoraOneToOneStateUIControllerDelegate {
    func onSettingSelected(isSelected: Bool) {
        if isSelected {
            ctrlView = settingViewController.view
            ctrlView?.mas_makeConstraints { make in
                make?.width.equalTo()(201)
                make?.height.equalTo()(281)
                make?.top.equalTo()(44)
                make?.right.equalTo()(-16)
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
        view.addSubview(stateController.view)
        
        boardController = UIViewController()
        addChild(boardController)
        view.addSubview(boardController.view)
        
        renderController = AgoraOneToOneRenderUIController(context: contextPool)
        addChild(renderController)
        view.addSubview(renderController.view)
        
        chatController = UIViewController()
        addChild(chatController)
        view.addSubview(chatController.view)
        
        ctrlMaskView = UIView(frame: .zero)
        ctrlMaskView.isHidden = true
        let tap = UITapGestureRecognizer(
            target: self, action: #selector(onClickCtrlMaskView(_:)))
        ctrlMaskView.addGestureRecognizer(tap)
        view.addSubview(ctrlMaskView)
    }
    
    func createConstrains() {
        stateController.view.mas_makeConstraints { [unowned self] make in
            make?.top.equalTo()(self.view)
            make?.left.right().equalTo()(0)
            make?.height.equalTo()(AgoraFit.scale(44))
        }
        renderController.view.mas_makeConstraints { [unowned self] make in
            if #available(iOS 11.0, *) {
                make?.right.equalTo()(self.view.mas_safeAreaLayoutGuideRight)
            } else {
                make?.right.equalTo()(20)
            }
            make?.top.equalTo()(stateController.view.mas_bottom)?.offset()(2)
            make?.width.equalTo()(168)
            make?.bottom.equalTo()(self.view)
        }
        ctrlMaskView.mas_makeConstraints { make in
            make?.top.equalTo()(stateController.view.mas_bottom)
            make?.left.right().bottom().equalTo()(0)
        }
        boardControllerLayout()
        chatControllerLayout()
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
    
    func chatControllerLayout() {
        let isTraditional = UIDevice.current.isTraditionalChineseLanguage
        //let chatOriginalSize = chatController.originalSize
        
        chatController.view.mas_makeConstraints { make in
            let space: CGFloat = 10
            
            if isTraditional {
                make?.left.equalTo()(boardController.view.mas_left)?.offset()(space)
            } else {
                make?.right.equalTo()(boardController.view.mas_right)?.offset()(-space)
            }
            
            make?.bottom.equalTo()(boardController.view.mas_bottom)?.offset()(-space)
//            make?.height.equalTo()(chatOriginalSize.height)
//            make?.width.equalTo()(chatOriginalSize.width)
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
