//
//  AgoraScreenUIController.swift
//  AgoraEduUI
//
//  Created by SRS on 2021/4/18.
//

import AgoraUIEduBaseViews
import AgoraUIBaseViews
import AgoraEduContext

protocol AgoraScreenUIControllerDelegate: NSObjectProtocol {
    func screenController(_ controller: AgoraScreenUIController,
                         didUpdateState state: AgoraEduContextScreenShareState)
    func screenController(_ controller: AgoraScreenUIController,
                         didSelectScreen selected: Bool)
}

class AgoraScreenUIController: NSObject, AgoraUIController {
    private var context: AgoraEduMediaContext? {
        return contextProvider?.controllerNeedMediaContext()
    }
    
    private var toastShowedStates: [String] = []

    private let screenView = AgoraBaseUIView(frame: .zero)

    private(set) var viewType: AgoraEduContextRoomType
    private weak var delegate: AgoraScreenUIControllerDelegate?
    private weak var contextProvider: AgoraControllerContextProvider?
    
    var containerView = AgoraUIControllerContainer(frame: .zero)
    
    init(viewType: AgoraEduContextRoomType,
         delegate: AgoraScreenUIControllerDelegate,
         contextProvider: AgoraControllerContextProvider) {
        self.viewType = viewType
        self.delegate = delegate
        self.contextProvider = contextProvider
        
        super.init()
        initViews()
        initLayout()
    }
    
    private func initViews() {
        containerView.backgroundColor = .clear
        containerView.addSubview(screenView)
        containerView.isHidden = true
    }

    private func initLayout() {
        screenView.agora_x = 0
        screenView.agora_y = 0
        screenView.agora_right = 0
        screenView.agora_bottom = 0
    }
}

// MARK: - AgoraEduScreenShareHandler
extension AgoraScreenUIController: AgoraEduScreenShareHandler {
    // 开启或者关闭屏幕分享onUpdateScreenShareState
    func onUpdateScreenShareState(_ state: AgoraEduContextScreenShareState,
                                  streamUuid: String) {
        if toastShowedStates.contains(#function) {
            switch state {
            case .start:
                AgoraUtils.showToast(message: AgoraUILocalizedString("ScreensharedBySb",
                                                                     object: self))
            case .stop:
                AgoraUtils.showToast(message: AgoraUILocalizedString("ScreenshareStoppedBySb",
                                                                     object: self))
            default:
                break
            }
        } else {
            toastShowedStates.append(#function)
        }
        
        self.delegate?.screenController(self,
                                        didUpdateState: state)
        
        if state != .stop {
            containerView.isHidden = false
            
            let config = AgoraEduContextRenderConfig()
            config.mode = .fit
            context?.startRenderRemoteVideo(view: screenView,
                                            renderConfig: config,
                                            streamUuid: streamUuid)
        } else {
            containerView.isHidden = true
            
            context?.stopRenderRemoteVideo(streamUuid: streamUuid)
        }
    }
    
    //onSelectScreenShare
    func onSelectScreenShare(_ selected: Bool) {
        containerView.isHidden = !selected
        delegate?.screenController(self,
                                   didSelectScreen: selected)
    }

    /* 屏幕分享相关消息
     * XXX开启了屏幕分享
     * XXX关闭了屏幕分享
     */
    func onShowScreenShareTips(_ message: String) {
        AgoraUtils.showToast(message: message)
    }
}
