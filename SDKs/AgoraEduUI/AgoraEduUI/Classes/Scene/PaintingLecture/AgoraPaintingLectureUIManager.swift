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

/// 房间控制器:
/// 用以处理全局状态和子控制器之间的交互关系
@objc public class AgoraPaintingLectureUIManager: AgoraEduUIManager {
    private let roomType: AgoraEduContextRoomType = .lecture
    /** 工具栏*/
    private var toolBarController: AgoraToolBarUIController!
    /** 房间状态 控制器*/
    private var stateController: AgoraRoomStateUIController!
    /** 学生列表渲染 控制器*/
    private var studentsRenderController: AgoraStudentsRenderUIController!
    /** 老师渲染 控制器*/
    private var teacherRenderController: AgoraTeacherRenderUIController!
    /** 白板的渲染 控制器*/
    private var boardController: AgoraBoardUIController!
    /** 屏幕分享 控制器*/
    private var screenSharingController: AgoraScreenSharingUIController!
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
        vc.roomDelegate = self
        self.addChild(vc)
        return vc
    }()
    /** 大窗 控制器*/
    private var spreadController: AgoraWindowUIController!
    
    private var isJoinedRoom = false
        
    deinit {
        print("\(#function): \(self.classForCoder)")
    }
    
    public override func viewDidLoad() {
        super.viewDidLoad()
        self.createViews()
        self.createConstraint()
        
        contextPool.room.joinRoom { [weak self] in
            AgoraLoading.hide()
            guard let `self` = self else {
                return
            }
            self.isJoinedRoom = true
            self.createChatController()
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

// MARK: - AgoraToolBarDelegate
extension AgoraPaintingLectureUIManager: AgoraToolBarDelegate {
    
    func toolsViewDidSelectTool(tool: AgoraToolBarUIController.ItemType,
                                selectView: UIView) {
        switch tool {
        case .setting:
            settingViewController.view.frame = CGRect(origin: .zero,
                                                      size: settingViewController.suggestSize)
            ctrlView = settingViewController.view
        case .brushTool:
            brushToolsController.view.frame = CGRect(origin: .zero,
                                                     size: brushToolsController.suggestSize)
            ctrlView = brushToolsController.view
        default: break
        }
        ctrlViewAnimationFromView(selectView)
    }
    
    func toolsViewDidDeselectTool(tool: AgoraToolBarUIController.ItemType) {
        ctrlView = nil
    }
}
// MARK: - AgoraWindowUIControllerDelegate
extension AgoraPaintingLectureUIManager: AgoraWindowUIControllerDelegate {
    
    func startSpreadForUser(with userId: String) -> UIView? {
        var view: UIView?
        if let targetView = self.teacherRenderController.renderViewForUser(with: userId) {
            view = targetView
            self.teacherRenderController.setRenderEnable(with: userId,
                                                         rendEnable: false)
        } else if let targetView = self.studentsRenderController.renderViewForUser(with: userId) {
            view = targetView
            self.studentsRenderController.setRenderEnable(with: userId,
                                                          rendEnable: false)
        }
        return view
    }
    
    func willStopSpreadForUser(with userId: String) -> UIView? {
        var view: UIView?
        if let targetView = self.teacherRenderController.renderViewForUser(with: userId) {
            view = targetView
        } else if let targetView = self.studentsRenderController.renderViewForUser(with: userId) {
            view = targetView
        }
        return view
    }
    
    func didStopSpreadForUser(with userId: String) {
        self.teacherRenderController.setRenderEnable(with: userId,
                                                     rendEnable: true)
        self.studentsRenderController.setRenderEnable(with: userId,
                                                      rendEnable: true)
    }
}
// MARK: - AgoraBoardToolsUIControllerDelegate
extension AgoraPaintingLectureUIManager: AgoraBoardToolsUIControllerDelegate {
    func didUpdateBrushSetting(image: UIImage?,
                               colorHex: Int) {
        toolBarController.updateBrushButton(image: image,
                                            colorHex: colorHex)
    }
}
// MARK: - PaintingToolBoxViewDelegate
extension AgoraPaintingLectureUIManager: AgoraToolBoxUIControllerDelegate {
    func toolBoxDidSelectTool(_ tool: AgoraTeachingAidType) {
        toolBarController.deselectAll()
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
            break
        default: break
        }
    }
}
// MARK: - Creations
private extension AgoraPaintingLectureUIManager {
    func createViews() {
        stateController = AgoraRoomStateUIController(context: contextPool)
        stateController.roomDelegate = self
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
        
        screenSharingController = AgoraScreenSharingUIController(context: contextPool)
        addChild(screenSharingController)
        contentView.addSubview(screenSharingController.view)
        
        toolBarController = AgoraToolBarUIController(context: contextPool)
        toolBarController.delegate = self
        toolBarController.tools = [.setting, .handsup, .brushTool]
        view.addSubview(toolBarController.view)
        
        spreadController = AgoraWindowUIController(context: contextPool)
        spreadController.delegate = self
        addChild(spreadController)
        contentView.addSubview(spreadController.view)
    }
    
    func createConstraint() {
        stateController.view.mas_makeConstraints { make in
            make?.top.left().right().equalTo()(stateController.view.superview)
            make?.height.equalTo()(20)
        }
        boardController.view.mas_makeConstraints { make in
            make?.left.bottom().equalTo()(0)
            make?.width.equalTo()(AgoraFit.scale(465))
            make?.height.equalTo()(AgoraFit.scale(262))
        }
        screenSharingController.view.mas_makeConstraints { make in
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
        toolBarController.view.mas_makeConstraints { make in
            make?.right.equalTo()(boardController.view.mas_right)?.offset()(UIDevice.current.isPad ? -9 : -6)
            make?.bottom.equalTo()(boardController.view)?.offset()(-15)
            make?.width.equalTo()(toolBarController.suggestSize.width)
            make?.height.equalTo()(toolBarController.suggestSize.height)
        }
        spreadController.view.mas_makeConstraints { make in
            make?.left.right().top().bottom().equalTo()(boardController.view)
        }
    }
    
    func createChatController() {
        chatController = AgoraChatUIController(context: contextPool)
        chatController.hideMiniButton = true
        addChild(chatController)
        AgoraUIGroup().color.borderSet(layer: chatController.view.layer)
        contentView.addSubview(chatController.view)
        chatController.view.mas_makeConstraints { make in
            make?.top.equalTo()(teacherRenderController.view.mas_bottom)?.offset()(AgoraFit.scale(2))
            make?.left.equalTo()(boardController.view.mas_right)?.offset()(AgoraFit.scale(2))
            make?.right.bottom().equalTo()(0)
        }
    }
}
