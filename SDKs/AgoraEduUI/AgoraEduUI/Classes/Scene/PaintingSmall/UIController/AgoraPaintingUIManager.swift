//
//  PaintingRoomViewController.swift
//  AgoraEduUI
//
//  Created by HeZhengQing on 2021/9/22.
//

import AgoraUIEduBaseViews
import AgoraUIBaseViews
import AgoraEduContext
import AgoraExtApp
import AgoraWidget
import Masonry
import UIKit

/// 房间控制器:
/// 用以处理全局状态和子控制器之间的交互关系
class AgoraPaintingUIManager: AgoraEduUIManager {
    private let roomType: AgoraEduContextRoomType = .paintingSmall
    /// 视图部分，支持feature的UI交互显示
    /** 容器视图，用以保持比例*/
    private var contentView: UIView!
    /** 工具栏*/
    private var toolsView: AgoraRoomToolstView!
    /** 画笔工具*/
    private var brushToolButton: AgoraRoomToolZoomButton!
    /// 控制器部分，除了视图显示，还包含和SDK之间的事件及数据交互
    /** 房间状态 控制器*/
    private var stateController: AgoraRoomStateUIController!
    /** 远程视窗渲染 控制器*/
    private var renderController: AgoraPaintingRenderUIController!
    /** 白板的渲染 控制器*/
    private var whiteBoardController: AgoraPaintingBoardUIController!
    /** 大窗口视频渲染 */
    private var spreadRenderController: AgoraBaseWidget?
    /** 云盘控制器 */
    private var cloudController: AgoraBaseWidget?
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
    /** 工具箱 控制器*/
    private lazy var toolBoxViewController: AgoraToolBoxUIController = {
        let vc = AgoraToolBoxUIController(context: contextPool)
        vc.delegate = self
        self.addChild(vc)
        return vc
    }()
    /** 花名册 控制器*/
    private lazy var nameRollController: AgoraPaintingUserListUIController = {
        let vc = AgoraPaintingUserListUIController(context: contextPool)
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
    private var messageController: AgoraBaseWidget?
    /** 设置界面 控制器*/
    private lazy var settingViewController: AgoraSettingUIController = {
        let vc = AgoraSettingUIController(context: contextPool)
        vc.delegate = self
        self.addChild(vc)
        return vc
    }()
    /** 成员菜单 控制器*/
    private lazy var memberMenuViewController: AgoraRenderMenuUIController = {
        let vc = AgoraRenderMenuUIController(context: contextPool)
        vc.delegate = self
        self.addChild(vc)
        return vc
    }()
    /** 举手 控制器*/
    private lazy var handsUpViewController: AgoraPaintingHandsUpUIController = {
        let vc = AgoraPaintingHandsUpUIController(context: contextPool)
        vc.delegate = self
        self.addChild(vc)
        return vc
    }()
    
    deinit {
        print("\(#function): \(self.classForCoder)")
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
        self.view.backgroundColor = .white
        
        self.createViews()
        self.createConstrains()
        if self.contextPool.user.getLocalUserInfo().role == .teacher {
            self.toolsView.tools = [.setting, .toolBox, .message]
        } else if self.contextPool.user.getLocalUserInfo().role == .student {
            self.toolsView.tools = [.setting, .message]
        }
        self.contextPool.user.registerEventHandler(self)
        self.contextPool.monitor.registerMonitorEventHandler(self)
        
        AgoraLoading.loading()
        contextPool.room.joinRoom { [weak self] in
            AgoraLoading.hide()
            guard let `self` = self else {
                return
            }
            self.initWidgets()
            if self.contextPool.user.getLocalUserInfo().role == .teacher {
                self.contextPool.room.startClass {
                } fail: { error in
                    AgoraToast.toast(msg: error.message, type: .erro)
                }
            }
        } fail: { [weak self] error in
            AgoraLoading.hide()
            self?.contextPool.room.leaveRoom()
        }
    }
}

// MARK: - Actions
extension AgoraPaintingUIManager {
    @objc func onClickBrushTools(_ sender: UIButton) {
        sender.isSelected = !sender.isSelected
        if sender.isSelected {
            toolsView.deselectAll()
            handsUpViewController.deselect()
            ctrlView = brushToolsViewController.view
            ctrlView?.mas_makeConstraints { make in
                make?.right.equalTo()(brushToolButton.mas_left)?.offset()(-7)
                make?.bottom.equalTo()(brushToolButton)?.offset()(-10)
            }
        } else {
            ctrlView = nil
        }
    }
    
    @objc func onClickCtrlMaskView(_ sender: UITapGestureRecognizer) {
        toolsView.deselectAll()
        handsUpViewController.deselect()
        brushToolButton.isSelected = false
        ctrlView = nil
    }
}

// MARK: - AgoraEduMonitorHandler
extension AgoraPaintingUIManager: AgoraEduMonitorHandler {
    // 连接状态
    func onLocalConnectionUpdated(state: AgoraEduContextConnectionState) {
        switch state {
        case .aborted:
            AgoraLoading.hide()
            // 踢出
            AgoraToast.toast(msg: AgoraKitLocalizedString("LoginOnAnotherDeviceText"))
            contextPool.room.leaveRoom()
            exit(reason: .kickOut)
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
extension AgoraPaintingUIManager: AgoraEduUserHandler {
    func onKickedOut() {
        AgoraAlert()
            .setTitle(AgoraKitLocalizedString("KickOutNoticeText"))
            .setMessage(AgoraKitLocalizedString("KickOutText"))
            .addAction(action: AgoraAlertAction(title: AgoraKitLocalizedString("SureText"), action: {
                self.contextPool.room.leaveRoom()
                self.exit(reason: .kickOut)
            }))
            .show(in: self)
    }
    
    func onShowUserReward(_ user: AgoraEduContextUserInfo) {
        
    }
}
// MARK: - HandsUpViewControllerDelegate
extension AgoraPaintingUIManager: AgoraPaintingHandsUpUIControllerDelegate {
    func onShowHandsUpList(_ view: UIView) {
        toolsView.deselectAll()
        brushToolButton.isSelected = false
        ctrlView = view
        view.mas_makeConstraints { make in
            make?.bottom.equalTo()(handsUpViewController.view)
            make?.width.equalTo()(220)
            make?.height.equalTo()(245)
            make?.right.equalTo()(handsUpViewController.view.mas_left)?.offset()(-10)
        }
    }
    func onHideHandsUpList(_ view: UIView) {
        ctrlView = nil
    }
}
// MARK: - AgoraRenderMenuUIControllerDelegate
extension AgoraPaintingUIManager: AgoraRenderMenuUIControllerDelegate {
    func onMenuResignedUser() {
        if ctrlView == self.memberMenuViewController.view {
            ctrlView = nil
        }
    }
}

// MARK: - AgoraPaintingRenderUIControllerDelegate
extension AgoraPaintingUIManager: AgoraPaintingRenderUIControllerDelegate {
    func onRequestSpread(firstOpen: Bool,
                         userId: String,
                         streamId: String,
                         fromView: UIView,
                         xaxis: CGFloat,
                         yaxis: CGFloat,
                         width: CGFloat,
                         height: CGFloat) {
        if contextPool.user.getLocalUserInfo().role != .teacher {
            return
        }
        if firstOpen {
            startSpreadRender(fromView: fromView,
                              userId: userId,
                              streamId: streamId,
                              xaxis: xaxis,
                              yaxis: yaxis,
                              width: width,
                              height: height)
        } else {
            // change stream
            dispatchMessage(action: 2,
                            userId: userId,
                            streamId: streamId)
        }
    }

    func onClickMemberAt(view: UIView, UUID: String) {
        if contextPool.user.getLocalUserInfo().role != .teacher {
            return
        }
        memberMenuViewController.userUUID = UUID
        ctrlView = memberMenuViewController.view
        ctrlView?.mas_remakeConstraints { make in
            make?.top.equalTo()(view.mas_bottom)
            make?.centerX.equalTo()(view)
        }
    }
}

// MARK: - AgoraToolListViewDelegate
extension AgoraPaintingUIManager: AgoraRoomToolsViewDelegate {
    func toolsViewDidSelectTool(_ tool: AgoraRoomToolstView.AgoraRoomToolType) {
        handsUpViewController.deselect()
        brushToolButton.isSelected = false
        switch tool {
        case .setting:
            ctrlView = settingViewController.view
            ctrlView?.mas_makeConstraints { make in
                make?.width.equalTo()(201)
                make?.height.equalTo()(281)
                make?.right.equalTo()(toolsView.mas_left)?.offset()(-7)
                make?.centerY.equalTo()(toolsView)
            }
        case .toolBox:
            if contextPool.user.getLocalUserInfo().role != .teacher {
                break
            }
            ctrlView = toolBoxViewController.view
            ctrlView?.mas_makeConstraints { make in
                make?.right.equalTo()(toolsView.mas_left)?.offset()(-7)
                make?.centerY.equalTo()(toolsView)
            }
        case .nameRoll:
            ctrlView = nameRollController.view
            ctrlView?.mas_makeConstraints { make in
                make?.right.equalTo()(toolsView.mas_left)?.offset()(-7)
                make?.centerY.equalTo()(toolsView)
            }
        case .message:
            if let message = messageController {
                message.onMessageReceived("max")
                
                ctrlView = message.view
                ctrlView?.mas_remakeConstraints { make in
                    make?.right.equalTo()(toolsView.mas_left)?.offset()(-7)
                    make?.centerY.equalTo()(toolsView)
                    make?.width.equalTo()(200)
                    make?.height.equalTo()(287)
                }
            }
        default: break
        }
    }
    
    func toolsViewDidDeselectTool(_ tool: AgoraRoomToolstView.AgoraRoomToolType) {
        ctrlView = nil
    }
}
// MARK: - PaintingToolBoxViewDelegate
extension AgoraPaintingUIManager: AgoraToolBoxUIControllerDelegate {
    func toolBoxDidSelectTool(_ tool: AgoraToolBoxToolType) {
        toolsView.deselectAll()
        ctrlView = nil
        switch tool {
        case .cloudStorage:
            // 云盘工具操作
            ctrlView = cloudController?.view
            ctrlView?.mas_makeConstraints { make in
                make?.width.equalTo()(550)
                make?.height.equalTo()(260)
                make?.right.equalTo()(toolsView.mas_left)?.offset()(-7)
                make?.centerY.equalTo()(toolsView)
            }
            break
        case .saveBoard: break
        case .record: break
        case .vote: break
        case .countDown: break
        case .answerSheet: // 答题器
            guard let extAppInfos = contextPool.extApp.getExtAppInfos(),
                  let info = extAppInfos.first(where: {$0.appIdentifier == "io.agora.answer"}) else {
                return
            }
            contextPool.extApp.willLaunchExtApp(info.appIdentifier)
        default: break
        }
    }
}

// MARK: - AgoraBoardToolsUIControllerDelegate
extension AgoraPaintingUIManager: AgoraBoardToolsUIControllerDelegate {
    func brushToolsViewDidBrushChanged(_ tool: AgoraBoardToolItem) {
        brushToolButton.setImage(tool.image(self))
    }
}

// MARK: - PaintingBoardUIControllerDelegate
extension AgoraPaintingUIManager: AgoraPaintingBoardUIControllerDelegate {
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

extension AgoraPaintingUIManager: AgoraSettingUIControllerDelegate {
    func settingUIControllerDidPressedLeaveRoom(controller: AgoraSettingUIController) {
        exit(reason: .normal)
    }
}


// MARK: - Creations
private extension AgoraPaintingUIManager {
    func createViews() {
        view.backgroundColor = .black
        
        contentView = UIView(frame: self.view.bounds)
        contentView.backgroundColor = UIColor(rgb: 0xECECF1)
        view.addSubview(contentView)
        
        stateController = AgoraRoomStateUIController(context: contextPool)
        addChild(stateController)
        contentView.addSubview(stateController.view)
        
        whiteBoardController = AgoraPaintingBoardUIController(context: contextPool)
        whiteBoardController.delegate = self
        contentView.addSubview(whiteBoardController.view)
        
        renderController = AgoraPaintingRenderUIController(context: contextPool)
        renderController.delegate = self
        addChild(renderController)
        contentView.addSubview(renderController.view)
        
        ctrlMaskView = UIView(frame: .zero)
        ctrlMaskView.isHidden = true
        let tap = UITapGestureRecognizer(
            target: self, action: #selector(onClickCtrlMaskView(_:)))
        ctrlMaskView.addGestureRecognizer(tap)
        contentView.addSubview(ctrlMaskView)
        
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
        contentView.addSubview(brushToolButton)
        
        toolsView = AgoraRoomToolstView(frame: .zero)
        toolsView.delegate = self
        contentView.addSubview(toolsView)
        
        contentView.addSubview(handsUpViewController.view)
    }
    
    func initWidgets() {
//        guard let widgetInfos = contextPool.widget.getWidgetInfos() else {
//            return
//        }
//        if let message = createChatWidget() {
//            messageController = message
//            message.addMessageObserver(self)
//            contentView.addSubview(message.containerView)
//        }
//
//        if let info = widgetInfos.first(where: {$0.widgetId == "big-window"}) {
//            info.properties = ["contextPool": contextPool]
//            let renderSpread = contextPool.widget.create(with: info)
//
//            spreadRenderController = renderSpread
//            contentView.addSubview(renderSpread.containerView)
//            renderSpread.addMessageObserver(self)
//        }
//
//        if let cloudWidgetInfo = widgetInfos.first(where: {$0.widgetId == "AgoraCloudWidget"}) {
//            cloudWidgetInfo.properties = ["contextPool" : contextPool]
//            let cloudWidget = contextPool.widget.create(with: cloudWidgetInfo)
//            cloudWidget.addMessageObserver(self)
//            cloudController = cloudWidget
//        }
    }
    
    func createConstrains() {
        let width = max(UIScreen.main.bounds.width, UIScreen.main.bounds.height)
        let height = min(UIScreen.main.bounds.width, UIScreen.main.bounds.height)
        if width/height > 667.0/375.0 {
            contentView.mas_makeConstraints { make in
                make?.center.equalTo()(contentView.superview)
                make?.height.equalTo()(height)
                make?.width.equalTo()(height * 16.0/9.0)
            }
        } else {
            contentView.mas_makeConstraints { make in
                make?.center.equalTo()(contentView.superview)
                make?.width.equalTo()(width)
                make?.height.equalTo()(width * 9.0/16.0)
            }
        }
        stateController.view.mas_makeConstraints { make in
            make?.top.left().right().equalTo()(stateController.view.superview)
            make?.height.equalTo()(20)
        }
        renderController.view.mas_makeConstraints { make in
            make?.left.right().equalTo()(renderController.view.superview)
            make?.top.equalTo()(stateController.view.mas_bottom)
            make?.height.equalTo()(AgoraFit.scale(64))
        }
        whiteBoardController.view.mas_makeConstraints { make in
            make?.top.equalTo()(renderController.view.mas_bottom)
            make?.left.right().bottom().equalTo()(whiteBoardController.view.superview)
        }
        ctrlMaskView.mas_makeConstraints { make in
            make?.left.right().top().bottom().equalTo()(self.view)
        }
        brushToolButton.mas_makeConstraints { make in
            make?.right.equalTo()(-9)
            make?.bottom.equalTo()(-14)
            make?.width.height().equalTo()(AgoraFit.scale(36))
        }
        toolsView.mas_makeConstraints { make in
            make?.right.equalTo()(brushToolButton)
            make?.centerY.equalTo()(toolsView.superview)
        }
        handsUpViewController.view.mas_makeConstraints { make in
            make?.width.height().equalTo()(AgoraFit.scale(36))
            make?.centerX.equalTo()(toolsView)
            make?.top.equalTo()(toolsView.mas_bottom)?.offset()(12)
        }
    }
    
    func spreadRenderWidgetMessageHandle(message: String) {
        guard let messageDic = message.json(),
              let widgetAction = messageDic["widgetAction"] as? Int,
              let spreadStreamId = messageDic["spreadStreamId"] as? String,
              let operatedUuid = messageDic["operatedUuid"] as? String else {
                  return
              }
        
        switch widgetAction {
        case 0:
            // start
            guard let cell = renderController.getSpreadCell(userId: operatedUuid) else {
                return
            }
            renderController.updateSpreadIndex(spreadFlag: true,
                                               userId: operatedUuid,
                                               streamId: spreadStreamId)
            guard let xaxis = messageDic["xaxis"] as? CGFloat,
                  let yaxis = messageDic["yaxis"] as? CGFloat,
                  let width = messageDic["width"] as? CGFloat,
                  let height = messageDic["height"] as? CGFloat else {
                      return
                  }
            self.startSpreadRender(fromView: cell,
                                   userId: operatedUuid,
                                   streamId: spreadStreamId,
                                   xaxis: xaxis,
                                   yaxis: yaxis,
                                   width: width,
                                   height: height)
        case 1:
            // move
            guard let spreadView = spreadRenderController?.view,
                  let xaxis = messageDic["xaxis"] as? CGFloat,
                  let yaxis = messageDic["yaxis"] as? CGFloat,
                  let width = messageDic["width"] as? CGFloat,
                  let height = messageDic["height"] as? CGFloat else {
                      return
                  }
            moveSpreadRender(xaxis: xaxis,
                             yaxis: yaxis,
                             width: width,
                             height: height)
            break
        case 2:
            // change
            break
        case 3:
            // close
            guard let cell = renderController.getSpreadCell(userId: operatedUuid) else {
                return
            }
            self.closeSpreadRenderItem(toView: cell,
                                       userId: operatedUuid,
                                       streamId: spreadStreamId)
        default:
                break
        }

    }
    
    func startSpreadRender(fromView: UIView,
                           userId: String,
                           streamId: String,
                           xaxis: CGFloat,
                           yaxis: CGFloat,
                           width: CGFloat,
                           height: CGFloat) {
        guard let spread = spreadRenderController else {
            return
        }
        
        dispatchMessage(action: 0,
                        userId: userId,
                        streamId: streamId)

        let spreadWidth = contentView.width * width

        let spreadHeight = (contentView.height - settingViewController.view.agora_height) * height
  
        let MEDx = contentView.width - spreadWidth
        let MEDy = contentView.height - stateController.view.frame.height - spreadHeight
        
        spread.view.mas_remakeConstraints { make in
            make?.width.height().equalTo()(fromView)
            make?.center.equalTo()(fromView)
        }
        view.layoutIfNeeded()
        spread.view.mas_remakeConstraints { make in
            make?.width.equalTo()(spreadWidth)
            make?.height.equalTo()(spreadHeight)
            make?.left.equalTo()(MEDx * xaxis)
            make?.top.equalTo()(MEDy * yaxis)
        }

        UIView.animate(withDuration: 0.25) {
            self.view.layoutIfNeeded()
        }
    }
    
    func moveSpreadRender(xaxis: CGFloat,
                           yaxis: CGFloat,
                           width: CGFloat,
                           height: CGFloat) {
        guard let spread = spreadRenderController else {
            return
        }
        
        let tempWidth: CGFloat = 0.5
        let spreadWidth = view.width * tempWidth
//        let spreadHeight = (view.height - settingViewController.view.agora_height - spread.containerView.height) * height
        let spreadHeight = spreadWidth / 16 * 9
  
        let MEDx = view.width - spreadWidth
        let MEDy = view.height - settingViewController.view.agora_height - spreadHeight
        
        spread.view.mas_remakeConstraints { make in
            make?.width.equalTo()(spreadWidth)
            make?.height.equalTo()(spreadHeight)
            make?.left.equalTo()(MEDx * xaxis)
            make?.top.equalTo()(MEDy * yaxis)
        }
        
        UIView.animate(withDuration: 0.25) {
            self.view.layoutIfNeeded()
        }
    }
    
    func closeSpreadRenderItem(toView: UIView,
                               userId: String,
                               streamId: String) {
        guard let spread = spreadRenderController else {
            return
        }

        spread.view.mas_remakeConstraints { make in
            make?.width.height().equalTo()(toView)
            make?.center.equalTo()(toView)
        }
        
        UIView.animate(withDuration: 0.25) {
            self.view.layoutIfNeeded()
        } completion: {[weak self] complete in
            guard let `self` = self else {
                return
            }
            // 通知spread widget关闭渲染
            self.dispatchMessage(action: 3,
                                 userId: userId,
                                 streamId: streamId)
            
            // 通知render开启渲染
            self.renderController.updateSpreadIndex(spreadFlag: false,
                                                    userId: userId,
                                                    streamId: streamId)
        }
        
    }
    
    func dispatchMessage(action: Int,
                         userId: String,
                         streamId: String){
        let dic: [String: Any] = ["action":action,
                                  "userId": userId,
                                  "streamId":streamId]
        if let message = dic.jsonString() {
            spreadRenderController?.onMessageReceived(message)
        }
    }
}

// MARK: - AgoraWidgetMessageObserver
extension AgoraPaintingUIManager: AgoraWidgetMessageObserver {
    func onMessageReceived(_ message: String,
                           widgetId: String!) {
        switch widgetId {
        case "big-window":
            spreadRenderWidgetMessageHandle(message: message)
        case "AgoraChatWidget":
            if let dic = message.json(),
               let isMin = dic["isMinSize"] as? Bool,
               isMin {
                ctrlView == nil
                toolsView.deselectAll()
            }
        case "HyChatWidget":
            if message == "min" {
                ctrlView == nil
                toolsView.deselectAll()
            }
        default:
            break
        }
    }
}
