//
//  AgoraHandsUpUIController.swift
//  AgoraEduUI
//
//  Created by SRS on 2021/4/18.
//

import AgoraUIEduBaseViews
import AgoraUIBaseViews
import AgoraEduContext

class AgoraHandsUpUIController: NSObject, AgoraUIController {
    private let handsUpView = AgoraHandsUpView(frame: .zero)
    
    private(set) var viewType: AgoraEduContextRoomType
    private weak var contextProvider: AgoraControllerContextProvider?
    
    private var toastShowedStates: [String] = []
    
    private var context: AgoraEduHandsUpContext? {
        return contextProvider?.controllerNeedHandsUpContext()
    }
    
    var containerView = AgoraUIControllerContainer(frame: .zero)
    
    var isCoHost: Bool = false {
        didSet {
            handsUpView.isCoHost = isCoHost
        }
    }
    
    init(viewType: AgoraEduContextRoomType,
         contextProvider: AgoraControllerContextProvider) {
        self.viewType = viewType
        self.contextProvider = contextProvider
        
        super.init()
        initViews()
        initLayout()
    }
    
    private func initViews() {
        containerView.backgroundColor = .clear
        containerView.addSubview(handsUpView)
        handsUpView.delegate = self
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
    public func onHandsUpEnable(_ enable: Bool) {
        if toastShowedStates.contains(#function) {
            AgoraUtils.showToast(message: AgoraUILocalizedString(enable ? "OpenHandsUpText" : "CloseHandsUpText",
                                                                 object: self))
        } else {
            toastShowedStates.append(#function)
        }
        
        handsUpView.setHandsUpEnable(enable)
    }
    
    // 当前举手状态
    public func onHandsUpState(_ state: AgoraEduContextHandsUpState) {
        guard state != .default else {
            return
        }
        if toastShowedStates.contains(#function) {
            switch state {
            case .handsUp:
                let text = AgoraUILocalizedString("HandsUpSuccessText",
                                                  object: self)
                AgoraUtils.showToast(message: text)
            case .handsDown:
                break
            default:
                break
            }
        } else {
            toastShowedStates.append(#function)
        }
        
        handsUpView.updateHandsUp(state.uiType)
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
    // 该方法被废弃，使用其他状态或事件的回调来显示 tips
    public func onShowHandsUpTips(_ message: String) {
        
    }
    
    public func onHandsUpResult(_ result: AgoraEduContextHandsUpResult) {
        var text: String
        
        switch result {
        case .accepted:
            text = AgoraUILocalizedString("AcceptedCoHostText",
                                          object: self)
            
        case .rejected:
            text = AgoraUILocalizedString("RejectedCoHostText",
                                          object: self)
        case .timeout:
            text = AgoraUILocalizedString("HandsUpTimeOutText",
                                          object: self)
        }
        
        AgoraUtils.showToast(message: text)
    }
}

extension AgoraHandsUpUIController: AgoraHandsUpViewDelegate {
    func handsUpVieWillHandsUp(_ view: AgoraHandsUpView) {
        context?.updateHandsUpState(.handsUp)
    }
    
    func handsUpVieWillHandsDown(_ view: AgoraHandsUpView) {
        context?.updateHandsUpState(.handsDown)
    }
    
}

fileprivate extension AgoraHandsUpView.HandsUpState {
    var contextType: AgoraEduContextHandsUpState {
        switch self {
        case .default:   return .default
        case .handsUp:   return .handsUp
        case .handsDown: return .handsDown
        }
    }
}

fileprivate extension AgoraEduContextHandsUpState {
    var uiType: AgoraHandsUpView.HandsUpState {
        switch self {
        case .default:   return .default
        case .handsUp:   return .handsUp
        case .handsDown: return .handsDown
        }
    }
}
