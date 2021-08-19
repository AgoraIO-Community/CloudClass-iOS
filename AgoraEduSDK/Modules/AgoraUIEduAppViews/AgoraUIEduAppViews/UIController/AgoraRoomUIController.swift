//
//  AgoraRoomUIController.swift
//  AgoraUIEduAppViews
//
//  Created by SRS on 2021/4/18.
//

import Foundation
import AgoraUIEduBaseViews
import AgoraUIBaseViews
import AgoraEduContext

protocol AgoraRoomUIControllerDelegate: NSObjectProtocol {
//    func roomController(_ controller: AgoraRoomUIController,
//                         didClicked button: AgoraBaseUIButton)
}

class AgoraRoomUIController: NSObject, AgoraUIController {
    // Contexts
    private var context: AgoraEduRoomContext? {
        return contextProvider?.controllerNeedRoomContext()
    }
    
    private let navigationBar = AgoraUINavigationBar(frame: .zero)
    private var loadingView: AgoraAlertView?
    
    private weak var contextProvider: AgoraControllerContextProvider?
    private weak var eventRegister: AgoraControllerEventRegister?
    private weak var delegate: AgoraRoomUIControllerDelegate?
    
    var containerView = AgoraUIControllerContainer(frame: .zero)

    public init(contextProvider: AgoraControllerContextProvider,
                eventRegister: AgoraControllerEventRegister,
                delegate: AgoraRoomUIControllerDelegate) {
        self.contextProvider = contextProvider
        self.eventRegister = eventRegister
        self.delegate = delegate
        
        super.init()
        initViews()
        initLayout()
        observeEvent(register: eventRegister)
    }
}

private extension AgoraRoomUIController {
    func initViews() {
        containerView.backgroundColor = .white
        containerView.addSubview(navigationBar)
    }
    
    func initLayout() {
        navigationBar.agora_x = 0
        navigationBar.agora_y = 0
        navigationBar.agora_right = 0
        navigationBar.agora_bottom = 0
    }
    
    func observeEvent(register: AgoraControllerEventRegister) {
        register.controllerRegisterRoomEvent(self)
    }
    
    public func uploadLog() {
        self.context?.uploadLog()
    }
}

private extension AgoraRoomUIController {
    
    func classOverAlert() {
        let ButtonLabel = AgoraAlertLabelModel()
        ButtonLabel.text = AgoraKitLocalizedString("SureText")
        
        let button = AgoraAlertButtonModel()
        button.titleLabel = ButtonLabel
        button.tapActionBlock = { [unowned self] (index) -> Void in
            self.context?.leaveRoom()
        }
        
        AgoraUtils.showAlert(imageModel: nil,
                             title: AgoraKitLocalizedString("ClassOverNoticeText"),
                             message: AgoraKitLocalizedString("ClassOverText"),
                             btnModels: [button])
    }
}

// MARK: - AgoraEduRoomHandler
extension AgoraRoomUIController: AgoraEduRoomHandler {
    // 设置课程名称
    public func onSetClassroomName(_ name: String) {
        navigationBar.setClassroomName(name)
    }
    
    // 设置课程状态
    public func onSetClassState(_ state: AgoraEduContextClassState) {
        switch state {
        case .close:
            classOverAlert()
            navigationBar.timeLabel.textColor = .red
        case .end:
            navigationBar.timeLabel.textColor = .red
        default:
            navigationBar.timeLabel.textColor = UIColor(rgb: 0x677386)
        }
    }
    
    /* 显示课程时间:
     * 上课前：`距离上课还有：X分X秒`
     * 开始上课：`已开始上课:X分X秒`
     * 结束上课：`已开始上课:X分X秒`
     */
    public func onSetClassTime(_ time: String) {
        navigationBar.setClassTime(time)
    }
    
    /* 上课期间的提示
     * 课程还有5分钟结束
     * 课程结束咯，还有5分钟关闭教室
     * 距离教室关闭还有1分钟
     * 设置上课期间的提示
     */

    public func onShowClassTips(_ message: String) {
        AgoraUtils.showToast(message: message)
    }
    
    // 网络状态
    public func onSetNetworkQuality(_ quality: AgoraEduContextNetworkQuality) {
        navigationBar.setNetworkQuality(quality.barType)
    }
    
    // 连接状态
    public func onSetConnectionState(_ state: AgoraEduContextConnectionState) {
        switch state {
        case .aborted:
            // 踢出
            loadingView?.removeFromSuperview()
            loadingView = nil
            AgoraUtils.showToast(message: AgoraKitLocalizedString("LoginOnAnotherDeviceText"))
            context?.leaveRoom()
        case .connecting:
            if loadingView?.superview == nil {
                self.loadingView = AgoraUtils.showLoading(message: AgoraKitLocalizedString("LoaingText"), shared: true)
            }
        case .disconnected, .reconnecting:
            if loadingView?.superview == nil {
                self.loadingView = AgoraUtils.showLoading(message: AgoraKitLocalizedString("ReconnectingText"), shared: true)
            }
        case .connected:
            loadingView?.removeFromSuperview()
            loadingView = nil
        }
    }
    
    // 上课过程中，错误信息
    public func onShowErrorInfo(_ error: AgoraEduContextError) {
        AgoraUtils.showToast(message: error.message ?? "")
    }
    
    public func onUploadLogSuccess(_ logId: String) {
        let title = AgoraKitLocalizedString("UploadLog")
        
        let button = AgoraAlertButtonModel()
        let buttonTitleProperties = AgoraAlertLabelModel()
        buttonTitleProperties.text = AgoraKitLocalizedString("OK")
        button.titleLabel = buttonTitleProperties
        
        AgoraUtils.showAlert(imageModel: nil,
                             title: title,
                             message: logId,
                             btnModels: [button])
    }
}

fileprivate extension AgoraEduContextNetworkQuality {
    var barType: AgoraUINavigationBar.NetworkQuality {
        switch self {
        case .good:    return .good
        case .medium:  return .medium
        case .bad:     return .bad
        case .unknown: return .unknown
        }
    }
}
