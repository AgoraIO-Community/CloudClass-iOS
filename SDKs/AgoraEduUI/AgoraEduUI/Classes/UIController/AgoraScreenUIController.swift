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
