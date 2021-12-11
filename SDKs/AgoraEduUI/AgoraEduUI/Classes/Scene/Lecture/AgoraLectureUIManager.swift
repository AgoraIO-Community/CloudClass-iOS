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
    /// 控制器部分，除了视图显示，还包含和SDK之间的事件及数据交互
    /** 房间状态 控制器*/
    private var stateController: AgoraRoomStateUIController!
    /** 学生列表渲染 控制器*/
    private var studentsRenderController: AgoraStudentsRenderUIController!
    /** 老师渲染 控制器*/
    private var teacherRenderController: AgoraTeacherRenderUIController!
    /** 白板的渲染 控制器*/
    private var boardController: AgoraBoardUIController!
    /** 工具箱 控制器*/
    private lazy var toolBoxViewController: AgoraToolBoxUIController = {
        let vc = AgoraToolBoxUIController(context: contextPool)
        vc.delegate = self
        self.addChild(vc)
        return vc
    }()
    /** 画板工具 控制器*/
    private lazy var brushToolsController: AgoraBoardToolsUIController = {
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
        
        AgoraLoading.loading()
        contextPool.room.joinRoom { [weak self] in
            AgoraLoading.hide()
            guard let `self` = self else {
                return
            }
            self.createChatController()
            // 打开本地音视频设备
            let cameras = self.contextPool.media.getLocalDevices(deviceType: .camera)
            if let camera = cameras.first(where: {$0.deviceName.contains(kFrontCameraStr)}) {
                let ero = self.contextPool.media.openLocalDevice(device: camera)
                print(ero)
            }
            if let mic = self.contextPool.media.getLocalDevices(deviceType: .mic).first {
                self.contextPool.media.openLocalDevice(device: mic)
            }
        } fail: { [weak self] error in
            AgoraLoading.hide()
            self?.contextPool.room.leaveRoom()
        }
    }
    
    public override func didClickCtrlMaskView() {
        super.didClickCtrlMaskView()
        toolsView.deselectAll()
        brushToolsController.button.isSelected = false
    }
}

// MARK: - AgoraToolListViewDelegate
extension AgoraLectureUIManager: AgoraRoomToolsViewDelegate {
    func toolsViewDidSelectTool(_ tool: AgoraRoomToolstView.AgoraRoomToolType) {
        brushToolsController.button.isSelected = false
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
    func onShowBrushTools(isShow: Bool) {
        if isShow {
            toolsView.deselectAll()
            handsUpController.deselect()
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

// MARK: - AgoraPaintingHandsUpUIControllerDelegate
extension AgoraLectureUIManager: AgoraHandsUpUIControllerDelegate {
    func onShowHandsUpList(_ view: UIView) {
        toolsView.deselectAll()
        brushToolsController.button.isSelected = false
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
        
        studentsRenderController = AgoraStudentsRenderUIController(context: contextPool)
        addChild(studentsRenderController)
        contentView.addSubview(studentsRenderController.view)
        
        teacherRenderController = AgoraTeacherRenderUIController(context: contextPool)
        teacherRenderController.view.layer.cornerRadius = AgoraFit.scale(2)
        teacherRenderController.view.clipsToBounds = true
        addChild(teacherRenderController)
        contentView.addSubview(teacherRenderController.view)
        
        boardController = AgoraBoardUIController(context: contextPool)
        boardController.view.layer.cornerRadius = AgoraFit.scale(2)
        boardController.view.borderWidth = 1
        boardController.view.borderColor = UIColor(hex: 0xECECF1)
        boardController.view.clipsToBounds = true
        addChild(boardController)
        contentView.addSubview(boardController.view)
        
        brushToolsController = AgoraBoardToolsUIController(context: contextPool)
        brushToolsController.delegate = self
        self.addChild(brushToolsController)
        view.addSubview(brushToolsController.button)
        
        handsUpController = AgoraHandsUpUIController(context: contextPool)
        handsUpController.delegate = self
        self.addChild(handsUpController)
        view.addSubview(handsUpController.view)
        
        toolsView = AgoraRoomToolstView(frame: view.bounds)
        toolsView.delegate = self
        toolsView.tools = [.setting, .message]
        contentView.addSubview(toolsView)
    }
    
    func createConstrains() {
        stateController.view.mas_makeConstraints { make in
            make?.top.left().right().equalTo()(stateController.view.superview)
            make?.height.equalTo()(20)
        }
        boardController.view.mas_makeConstraints { make in
            make?.left.bottom().equalTo()(0)
            make?.width.equalTo()(AgoraFit.scale(465))
            make?.height.equalTo()(AgoraFit.scale(262))
        }
        studentsRenderController.view.mas_makeConstraints { make in
            make?.top.equalTo()(stateController.view.mas_bottom)?.offset()(AgoraFit.scale(2))
            make?.left.equalTo()(0)
            make?.right.equalTo()(boardController.view)
            make?.bottom.equalTo()(boardController.view.mas_top)?.offset()(AgoraFit.scale(-2))
        }
        teacherRenderController.view.mas_makeConstraints { make in
            make?.top.equalTo()(stateController.view.mas_bottom)?.offset()(AgoraFit.scale(2))
            make?.left.equalTo()(studentsRenderController.view.mas_right)?.offset()(AgoraFit.scale(2))
            make?.right.equalTo()(0)
            make?.height.equalTo()(AgoraFit.scale(112))
        }
        brushToolsController.button.mas_makeConstraints { make in
            make?.right.equalTo()(boardController.view)?.offset()(AgoraFit.scale(-6))
            make?.bottom.equalTo()(boardController.view)?.offset()(AgoraFit.scale(-6))
            make?.width.height().equalTo()(36)
        }
        handsUpController.view.mas_makeConstraints { make in
            make?.width.height().equalTo()(36)
            make?.centerX.equalTo()(brushToolsController.button)
            make?.bottom.equalTo()(brushToolsController.button.mas_top)?.offset()(-8)
        }
        toolsView.mas_makeConstraints { make in
            make?.right.equalTo()(brushToolsController.button)
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
            make?.left.equalTo()(boardController.view.mas_right)?.offset()(AgoraFit.scale(2))
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
