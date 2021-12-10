//
//  AgoraEduUI+Lecture.swift
//  AgoraEduSDK
//
//  Created by Cavan on 2021/4/22.
//

import AgoraUIEduBaseViews
import AgoraUIBaseViews
import AgoraEduContext
import AudioToolbox
import AgoraExtApp
import AgoraWidget

/// 房间控制器:
/// 用以处理全局状态和子控制器之间的交互关系
@objc public class AgoraLectureUIManager: AgoraEduUIManager {
    private let roomType: AgoraEduContextRoomType = .lecture
    /// 视图部分，支持feature的UI交互显示
    /** 工具栏*/
    private var toolsView: AgoraRoomToolstView!
    /** 画笔工具*/
    private var brushToolButton: AgoraRoomToolZoomButton!
    /// 控制器部分，除了视图显示，还包含和SDK之间的事件及数据交互
    /** 房间状态 控制器*/
    private var stateController: AgoraRoomStateUIController!
    /** 学生列表渲染 控制器*/
    private var studentsRenderController: AgoraStudentsRenderUIController!
    /** 老师渲染 控制器*/
    private var teacherRenderController: AgoraTeacherRenderUIController!
    /** 白板的渲染 控制器*/
    private var whiteBoardController: AgoraPaintingBoardUIController!
    /** 工具箱 控制器*/
    private lazy var toolBoxViewController: AgoraToolBoxUIController = {
        let vc = AgoraToolBoxUIController(context: contextPool)
        vc.delegate = self
        self.addChild(vc)
        return vc
    }()
    /** 画板工具 控制器*/
    private lazy var brushToolsViewController: AgoraBoardToolsUIController = {
        let vc = AgoraBoardToolsUIController(context: contextPool)
        vc.delegate = self
        self.addChild(vc)
        return vc
    }()
    /** 聊天窗口 控制器*/
    private var chatController: AgoraChatUIController!
    /** 设置界面 控制器*/
    private lazy var settingViewController: AgoraSettingUIController = {
        let vc = AgoraSettingUIController(context: contextPool)
        vc.delegate = self
        self.addChild(vc)
        return vc
    }()
    /** 举手 控制器*/
    private var handsUpController: AgoraHandsUpUIController!
        
    deinit {
        print("\(#function): \(self.classForCoder)")
    }
    
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
        self.createViews()
        self.createConstrains()
        self.contextPool.user.registerEventHandler(self)
        self.contextPool.monitor.registerMonitorEventHandler(self)
        
        AgoraLoading.loading()
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
        toolsView.deselectAll()
        brushToolButton.isSelected = false
    }
}

// MARK: - Actions
extension AgoraLectureUIManager {
    @objc func onClickBrushTools(_ sender: UIButton) {
        sender.isSelected = !sender.isSelected
        if sender.isSelected {
            toolsView.deselectAll()
            ctrlView = brushToolsViewController.view
            ctrlView?.mas_makeConstraints { make in
                make?.right.equalTo()(brushToolButton.mas_left)?.offset()(-7)
                make?.bottom.equalTo()(brushToolButton)?.offset()(-10)
            }
        } else {
            ctrlView = nil
        }
    }
}

// MARK: - AgoraEduMonitorHandler
extension AgoraLectureUIManager: AgoraEduMonitorHandler {
    // 连接状态
    func onLocalConnectionUpdated(_ state: AgoraEduContextConnectionState) {
        switch state {
        case .aborted:
            // 踢出
            AgoraLoading.hide()
            AgoraToast.toast(msg: AgoraKitLocalizedString("LoginOnAnotherDeviceText"))
            contextPool.room.leaveRoom()
        case .connecting:
            AgoraLoading.loading(msg: AgoraKitLocalizedString("LoaingText"))
        case .disconnected, .reconnecting:
            AgoraLoading.loading(msg: AgoraKitLocalizedString("ReconnectingText"))
        case .connected:
            AgoraLoading.hide()
        }
    }
}

// MARK: - AgoraEduUserHandler
extension AgoraLectureUIManager: AgoraEduUserHandler {
    public func onLocalUserKickedOut() {
        AgoraAlert()
            .setTitle(AgoraKitLocalizedString("KickOutNoticeText"))
            .setMessage(AgoraKitLocalizedString("KickOutText"))
            .addAction(action: AgoraAlertAction(title: AgoraKitLocalizedString("SureText"), action: {
                self.contextPool.room.leaveRoom()
            }))
            .show(in: self)
    }
    
    func onShowUserReward(_ user: AgoraEduContextUserInfo) {
        
    }
}

// MARK: - AgoraToolListViewDelegate
extension AgoraLectureUIManager: AgoraRoomToolsViewDelegate {
    func toolsViewDidSelectTool(_ tool: AgoraRoomToolstView.AgoraRoomToolType) {
        brushToolButton.isSelected = false
        switch tool {
        case .setting:
            ctrlView = settingViewController.view
            ctrlView?.mas_makeConstraints { make in
                make?.width.equalTo()(201)
                make?.height.equalTo()(220)
                make?.right.equalTo()(toolsView.mas_left)?.offset()(-7)
                make?.top.equalTo()(self.toolsView)?.priority()(998)
                make?.bottom.lessThanOrEqualTo()(-10)?.priority()(999)
            }
        default: break
        }
    }
    
    func toolsViewDidDeselectTool(_ tool: AgoraRoomToolstView.AgoraRoomToolType) {
        ctrlView = nil
    }
}
// MARK: - PaintingToolBoxViewDelegate
extension AgoraLectureUIManager: AgoraToolBoxUIControllerDelegate {
    func toolBoxDidSelectTool(_ tool: AgoraToolBoxToolType) {
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
        case .answerSheet: // 答题器
            guard let extAppInfos = contextPool.extApp.getExtAppInfos(),
                  let info = extAppInfos.first(where: {$0.appIdentifier == "io.agora.answerSheet"}) else {
                return
            }
            contextPool.extApp.willLaunchExtApp(info.appIdentifier)
        default: break
        }
    }
}

// MARK: - AgoraBoardToolsUIControllerDelegate
extension AgoraLectureUIManager: AgoraBoardToolsUIControllerDelegate {
    func brushToolsViewDidBrushChanged(_ tool: AgoraBoardToolItem) {
        brushToolButton.setImage(tool.image(self))
    }
}

// MARK: - PaintingBoardUIControllerDelegate
extension AgoraLectureUIManager: AgoraPaintingBoardUIControllerDelegate {
    func controller(_ controller: AgoraPaintingBoardUIController,
                    didUpdateBoard permission: Bool) {
        // 当白板变为未授权时，弹窗取消
        if !permission,
           let view = ctrlView,
           view == brushToolsViewController.view {
            ctrlView = nil
        }
        brushToolButton.isHidden = !permission
    }
}

// MARK: - AgoraPaintingHandsUpUIControllerDelegate
extension AgoraLectureUIManager: AgoraHandsUpUIControllerDelegate {
    func onShowHandsUpList(_ view: UIView) {
        toolsView.deselectAll()
        brushToolButton.isSelected = false
        ctrlView = view
        view.mas_makeConstraints { make in
            make?.bottom.equalTo()(handsUpController.view)
            make?.width.equalTo()(220)
            make?.height.equalTo()(245)
            make?.right.equalTo()(handsUpController.view.mas_left)?.offset()(-10)
        }
    }
    
    func onHideHandsUpList(_ view: UIView) {
        ctrlView = nil
    }
}

// MARK: - Creations
private extension AgoraLectureUIManager {
    func createViews() {
        stateController = AgoraRoomStateUIController(context: contextPool)
        addChild(stateController)
        contentView.addSubview(stateController.view)
        
        whiteBoardController = AgoraPaintingBoardUIController(context: contextPool)
        whiteBoardController.delegate = self
        contentView.addSubview(whiteBoardController.view)
        
        studentsRenderController = AgoraStudentsRenderUIController(context: contextPool)
        addChild(studentsRenderController)
        contentView.addSubview(studentsRenderController.view)
        
        teacherRenderController = AgoraTeacherRenderUIController(context: contextPool)
        teacherRenderController.view.layer.cornerRadius = AgoraFit.scale(2)
        teacherRenderController.view.clipsToBounds = true
        addChild(teacherRenderController)
        contentView.addSubview(teacherRenderController.view)
        
        brushToolButton = AgoraRoomToolZoomButton(frame: CGRect(x: 0,
                                                        y: 0,
                                                        width: 44,
                                                        height: 44))
        brushToolButton.isHidden = true
        brushToolButton.setImage(AgoraUIImage(object: self,
                                              name: "ic_brush_pencil"))
        brushToolButton.addTarget(self,
                                  action: #selector(onClickBrushTools(_:)),
                                  for: .touchUpInside)
        view.addSubview(brushToolButton)
        
        toolsView = AgoraRoomToolstView(frame: .zero)
        toolsView.tools = [.setting, .toolBox, .nameRoll]
        toolsView.delegate = self
        view.addSubview(toolsView)
        
        handsUpController = AgoraHandsUpUIController(context: contextPool)
        handsUpController.delegate = self
        addChild(handsUpController)
        view.addSubview(handsUpController.view)
    }
    
    func createConstrains() {
        stateController.view.mas_makeConstraints { make in
            make?.top.left().right().equalTo()(stateController.view.superview)
            make?.height.equalTo()(20)
        }
        whiteBoardController.view.mas_makeConstraints { make in
            make?.left.bottom().equalTo()(0)
            make?.width.equalTo()(AgoraFit.scale(465))
            make?.height.equalTo()(AgoraFit.scale(262))
        }
        studentsRenderController.view.mas_makeConstraints { make in
            make?.top.equalTo()(stateController.view.mas_bottom)?.offset()(AgoraFit.scale(2))
            make?.left.equalTo()(0)
            make?.right.equalTo()(whiteBoardController.view)
            make?.bottom.equalTo()(whiteBoardController.view.mas_top)?.offset()(AgoraFit.scale(-2))
        }
        teacherRenderController.view.mas_makeConstraints { make in
            make?.top.equalTo()(stateController.view.mas_bottom)?.offset()(AgoraFit.scale(2))
            make?.left.equalTo()(studentsRenderController.view.mas_right)?.offset()(AgoraFit.scale(2))
            make?.right.equalTo()(0)
            make?.height.equalTo()(AgoraFit.scale(112))
        }
        brushToolButton.mas_makeConstraints { make in
            make?.right.equalTo()(whiteBoardController.view)?.offset()(AgoraFit.scale(-6))
            make?.bottom.equalTo()(whiteBoardController.view)?.offset()(AgoraFit.scale(-6))
            make?.width.height().equalTo()(36)
        }
        handsUpController.view.mas_makeConstraints { make in
            make?.width.height().equalTo()(36)
            make?.centerX.equalTo()(brushToolButton)
            make?.bottom.equalTo()(brushToolButton.mas_top)?.offset()(-8)
        }
        toolsView.mas_makeConstraints { make in
            make?.right.equalTo()(brushToolButton)
            make?.bottom.equalTo()(handsUpController.view.mas_top)?.offset()(-8)
        }
    }
    
    func createChatController() {
        chatController = AgoraChatUIController()
        chatController.contextPool = contextPool
        addChild(chatController)
        contentView.addSubview(chatController.view)
        chatController.view.mas_makeConstraints { make in
            make?.top.equalTo()(teacherRenderController.view.mas_bottom)?.offset()(AgoraFit.scale(2))
            make?.left.equalTo()(whiteBoardController.view.mas_right)?.offset()(AgoraFit.scale(2))
            make?.right.bottom().equalTo()(0)
        }
    }
}

// MARK: - AgoraSettingUIControllerDelegate
extension AgoraLectureUIManager: AgoraSettingUIControllerDelegate {
    func settingUIControllerDidPressedLeaveRoom(controller: AgoraSettingUIController) {
        exit(reason: .normal)
    }
}
