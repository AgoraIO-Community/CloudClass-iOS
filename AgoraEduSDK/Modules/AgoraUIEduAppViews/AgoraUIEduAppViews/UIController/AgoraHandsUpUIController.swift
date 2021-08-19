//
//  AgoraHandsUpUIController.swift
//  AgoraUIEduAppViews
//
//  Created by SRS on 2021/4/18.
//

import UIKit
import AgoraUIEduBaseViews
import AgoraUIBaseViews
import AgoraEduContext

protocol AgoraHandsUpUIControllerDelegate: NSObjectProtocol {
    func handsUpController(_ controller: AgoraHandsUpUIController,
                           didHandsPressed: Bool)
}

class AgoraHandsUpUIController: NSObject, AgoraUIController {

    private weak var delegate: AgoraHandsUpUIControllerDelegate?
    
    var containerView = AgoraHandsUpContainer(frame: .zero)
    var isCoHost: Bool = false {
        didSet {
            self.handsUpView.isCoHost = isCoHost
        }
    }
    
    let handsUpView = AgoraHandsUpView(frame: .zero)

    private(set) var viewType: AgoraEduContextAppType
    private weak var contextProvider: AgoraControllerContextProvider?
    private weak var eventRegister: AgoraControllerEventRegister?
    
    init(viewType: AgoraEduContextAppType,
         contextProvider: AgoraControllerContextProvider,
         eventRegister: AgoraControllerEventRegister,
         delegate: AgoraHandsUpUIControllerDelegate) {

        self.viewType = viewType
        self.contextProvider = contextProvider
        self.eventRegister = eventRegister
        self.delegate = delegate
        
        super.init()
        initViews()
        initLayout()
        initData()
    }
    
    func updateMenu(width: CGFloat, height: CGFloat) {
        self.handsUpView.updateLayout(width: width, height: height)
    }
    
    private func initData() {
        self.eventRegister?.controllerRegisterHandsUpEvent(self)
        handsUpView.context = self.contextProvider?.controllerNeedHandsUpContext()
        
        handsUpView.handsPressedBlock = { [weak self] in
            if let `self` = self {
                self.delegate?.handsUpController(self, didHandsPressed: true)
            }
        }
    }

    private func initViews() {
        containerView.backgroundColor = .clear
        containerView.addSubview(handsUpView)
    }

    private func initLayout() {
        handsUpView.agora_x = 0
        handsUpView.agora_y = 0
        handsUpView.agora_right = 0
        handsUpView.agora_bottom = 0
    }
}

// MARK: - AgoraEduHandsUpHandler
extension AgoraHandsUpUIController: AgoraEduHandsUpHandler {
    
    // 是否可以举手
    public func onSetHandsUpEnable(_ enable: Bool) {
        self.handsUpView.onSetHandsUpEnable(enable)
    }
    // 当前举手状态
    public func onSetHandsUpState(_ state: AgoraEduContextHandsUpState) {
        self.handsUpView.onSetHandsUpState(state)
    }
    // 更新举手状态结果，如果error不为空，代表失败
    public func onUpdateHandsUpStateResult(_ error: AgoraEduContextError?) {
        self.handsUpView.onUpdateHandsUpStateResult(error)
    }
    /* 显示举手相关消息
     * 举手超时
     * 老师拒绝了你的举手申请x
     * 老师同意了你的举手申请
     * 你被老师下台了
     * 举手成功
     * 取消举手成功
     * 老师关闭了举手功能
     * 老师开启了举手功能
     */
    public func onShowHandsUpTips(_ message: String) {
        self.handsUpView.onShowHandsUpTips(message)
    }
}

class AgoraHandsUpContainer: AgoraUIControllerContainer {
    public override func hitTest(_ point: CGPoint,
                                 with event: UIEvent?) -> UIView? {
        let hitView = super.hitTest(point, with: event)
        if hitView == self {
            return nil
        }
        
        return hitView
    }
}
