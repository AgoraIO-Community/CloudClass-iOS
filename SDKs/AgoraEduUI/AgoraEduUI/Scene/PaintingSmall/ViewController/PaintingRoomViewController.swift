//
//  PaintingRoomViewController.swift
//  AgoraEduUI
//
//  Created by HeZhengQing on 2021/9/22.
//

import UIKit
import SnapKit
import AgoraExtApp
import AgoraWidget
import AgoraEduContext
import AgoraUIBaseViews

private let kCurRoomType: AgoraEduContextRoomType = .paintingSmall
class PaintingRoomViewController: UIViewController {
    /// 视图部分，支持feature的UI交互显示
    /** 状态栏*/
    private var stateView: PaintingClassRoomStatusBar!
    /** 工具栏*/
    private var toolsView: PaintingSmallToolsView!
    /** 画笔工具*/
    private var brushToolButton: UIButton!
    /// 控制器部分，除了视图显示，还包含和SDK之间的事件及数据交互
    /** 远程视窗渲染控制器*/
    private var renderController: PaintingRenderViewController!
    /** 白板的渲染 控制器*/
    private var whiteBoardController: AgoraWhiteBoardUIController!
    /// 弹窗控制器
    /** 控制器遮罩层，用来盛装控制器和处理手势触发消失事件*/
    private var ctrlMaskView: UIView!
    /** 弹出显示的控制widget视图*/
    private var ctrlView: UIView? {
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
    /** 工具箱 视图*/
    private lazy var toolBoxView: PaintingToolBoxView = {
        let v = PaintingToolBoxView(frame: .zero)
        v.delegate = self
        return v
    }()
    /** 用户列表 控制器*/
    private var nameRollController: AgoraUserListUIController?
    /** 画板工具 控制器*/
    private lazy var brushToolsViewController: BrushToolsViewController = {
        let vc = BrushToolsViewController(context: contextPool)
        self.addChild(vc)
        return vc
    }()
    /** 聊天窗口 控制器*/
    private var messageController: AgoraBaseWidget?
    /** 设置界面 控制器*/
    private lazy var settingViewController: PaintingSettingViewController = {
        let vc = PaintingSettingViewController(context: contextPool)
        self.addChild(vc)
        return vc
    }()
    /** 成员菜单 控制器*/
    private lazy var memberMenuViewController: MemberMenuViewController = {
        let vc = MemberMenuViewController(context: contextPool)
        self.addChild(vc)
        return vc
    }()
    /** SDK环境*/
    var contextPool: AgoraEduContextPool!
    
    deinit {
        print("\(#function): \(self.classForCoder)")
    }
    
    init(context: AgoraEduContextPool) {
        super.init(nibName: nil, bundle: nil)
        contextPool = context
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.view = AgoraBaseUIView()
        
        createViews()
        createConstrains()
        contextPool.room.registerEventHandler(self)
    }
}
// MARK: - Actions
extension PaintingRoomViewController {
    @objc func onClickBrushTools(_ sender: UIButton) {
        sender.isSelected = !sender.isSelected
        if sender.isSelected {
            toolsView.deselectAll()
            ctrlView = brushToolsViewController.view
            ctrlView?.snp.makeConstraints { make in
                make.right.equalTo(brushToolButton.snp.left).offset(-7)
                make.bottom.equalTo(brushToolButton).offset(-10)
            }
        } else {
            ctrlView = nil
        }
    }
}
// MARK: - AgoraEduRoomHandler
extension PaintingRoomViewController: AgoraEduRoomHandler {
    
}
// MARK: - PaintingRenderViewControllerDelegate
extension PaintingRoomViewController: PaintingRenderViewControllerDelegate {
    
    func onDoubleTapMember(at index: Int) {
        
    }
    
    func onClickMemberAt(view: UIView) {
        ctrlView = memberMenuViewController.view
        ctrlView?.snp.makeConstraints { make in
            make.width.equalTo(182)
            make.height.equalTo(36)
            make.top.equalTo(view.snp.bottom)
            make.centerX.equalTo(view)
        }
    }
}

// MARK: - PaintingSmallToolsViewDelegate
extension PaintingRoomViewController: PaintingSmallToolsViewDelegate {
    
    @objc func onClickCtrlMaskView(_ sender: UITapGestureRecognizer) {
        toolsView.deselectAll()
        if self.brushToolButton.isSelected {
            self.brushToolButton.isSelected = false
        }
        ctrlView = nil
    }
    
    func toolsViewDidSelectTool(_ tool: PaintingSmallToolsView.PaintingSmallTool) {
        if self.brushToolButton.isSelected {
            self.brushToolButton.isSelected = false
        }
        switch tool {
        case .setting:
            ctrlView = settingViewController.view
            ctrlView?.snp.makeConstraints { make in
                make.width.equalTo(201)
                make.height.equalTo(281)
                make.right.equalTo(toolsView.snp.left).offset(-7)
                make.centerY.equalTo(toolsView)
            }
        case .toolBox:
            ctrlView = toolBoxView
            ctrlView?.snp.makeConstraints { make in
                make.width.equalTo(300)
                make.height.equalTo(160)
                make.right.equalTo(toolsView.snp.left).offset(-7)
                make.centerY.equalTo(toolsView)
            }
        default: break
        }
    }
    
    func toolsViewDidDeselectTool(_ tool: PaintingSmallToolsView.PaintingSmallTool) {
        ctrlView = nil
    }
}
// MARK: - PaintingToolBoxViewDelegate
extension PaintingRoomViewController: PaintingToolBoxViewDelegate {
    func toolBoxDidSelectTool(_ tool: PaintingToolBoxTool) {
        toolsView.deselectAll()
        ctrlView = nil
        switch tool {
        case .cloudStorage:
            // 云盘工具操作
            
            break
        case .saveBoard: break
        case .record: break
        case .vote: break
        case .countDown: break
        case .answerSheet: break
        default: break
        }
    }
}
// MARK: - AgoraWhiteBoardUIControllerDelegate
extension PaintingRoomViewController: AgoraWhiteBoardUIControllerDelegate {
    func whiteBoard(_ controller: AgoraWhiteBoardUIController,
                    willUpdateDisplayMode isFullScreen: Bool) {
        
    }
    
    func whiteBoard(_ controller: AgoraWhiteBoardUIController,
                    didPresseStudentListButton button: UIButton) {
        
    }
}

// MARK: - Creations
private extension PaintingRoomViewController {
    func createViews() {
        stateView = PaintingClassRoomStatusBar(frame: .zero)
        stateView.backgroundColor = .white
        view.addSubview(stateView)
        
        whiteBoardController = AgoraWhiteBoardUIController(viewType: kCurRoomType,
                                                           delegate: self,
                                                           contextProvider: self)
        view.addSubview(whiteBoardController.containerView)
        
        renderController = PaintingRenderViewController(context: contextPool)
        renderController.delegate = self
        self.addChild(renderController)
        view.addSubview(renderController.view)
        
        ctrlMaskView = UIView(frame: .zero)
        ctrlMaskView.isHidden = true
        let tap = UITapGestureRecognizer(
            target: self, action: #selector(onClickCtrlMaskView(_:)))
        ctrlMaskView.addGestureRecognizer(tap)
        view.addSubview(ctrlMaskView)
                
        brushToolButton = ToolsZoomButton(type: .custom)
        brushToolButton.setImage(AgoraUIImage(object: self,
                                              name: "ic_white_board_pencil"), for: .normal)
        brushToolButton.addTarget(self, action: #selector(onClickBrushTools(_:)),
                                  for: .touchUpInside)
        view.addSubview(brushToolButton)
        
        toolsView = PaintingSmallToolsView(frame: view.bounds)
        toolsView.delegate = self
        view.addSubview(toolsView)
    }
    
    func createConstrains() {
        stateView.snp.makeConstraints { make in
            make.top.left.right.equalToSuperview()
            make.height.equalTo(20)
        }
        renderController.view.snp.makeConstraints { make in
            make.left.right.equalToSuperview()
            make.top.equalTo(stateView.snp.bottom)
            make.height.equalTo(AgoraFit.scale(80))
        }
        whiteBoardController.containerView.snp.makeConstraints { make in
            make.top.equalTo(stateView.snp.bottom)
            make.left.right.bottom.equalToSuperview()
        }
        ctrlMaskView.snp.makeConstraints { make in
            make.left.right.top.bottom.equalTo(self.view)
        }
        brushToolButton.snp.makeConstraints { make in
            make.right.equalTo(-9)
            make.bottom.equalTo(-14)
            make.width.height.equalTo(46)
        }
        toolsView.snp.makeConstraints { make in
            make.right.equalTo(brushToolButton)
            make.centerY.equalToSuperview()
        }
    }
}

// MARK: - AgoraControllerContextProvider
extension PaintingRoomViewController: AgoraControllerContextProvider {
    func controllerNeedWhiteBoardContext() -> AgoraEduWhiteBoardContext {
        return contextPool.whiteBoard
    }
    
    func controllerNeedWhiteBoardToolContext() -> AgoraEduWhiteBoardToolContext {
        return contextPool.whiteBoardTool
    }
    
    func controllerNeedWhiteBoardPageControlContext() -> AgoraEduWhiteBoardPageControlContext {
        return contextPool.whiteBoardPageControl
    }
    
    func controllerNeedRoomContext() -> AgoraEduRoomContext {
        return contextPool.room
    }
    
    func controllerNeedDeviceContext() -> AgoraEduDeviceContext {
        return contextPool.device
    }
    
    func controllerNeedChatContext() -> AgoraEduMessageContext {
        return contextPool.chat
    }
    
    func controllerNeedUserContext() -> AgoraEduUserContext {
        return contextPool.user
    }
    
    func controllerNeedHandsUpContext() -> AgoraEduHandsUpContext {
        return contextPool.handsUp
    }
    
    func controllerNeedPrivateChatContext() -> AgoraEduPrivateChatContext {
        return contextPool.privateChat
    }
    
    func controllerNeedScreenContext() -> AgoraEduScreenShareContext {
        return contextPool.screenSharing
    }
    
    func controllerNeedExtAppContext() -> AgoraEduExtAppContext {
        return contextPool.extApp
    }
    
    func controllerNeedMediaContext() -> AgoraEduMediaContext {
        return contextPool.media
    }
}
