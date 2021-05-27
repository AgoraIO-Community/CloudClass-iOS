//
//  AgoraWhiteBoardController.swift
//  AFNetworking
//
//  Created by Cavan on 2021/4/15.
//

import UIKit
import AgoraUIEduBaseViews
import AgoraUIBaseViews
import AgoraEduContext

protocol AgoraWhiteBoardUIControllerDelegate: NSObjectProtocol {
    func whiteBoard(_ controller: AgoraWhiteBoardUIController,
                    willUpdateDisplayMode isFullScreen: Bool)
    
    func whiteBoard(_ controller: AgoraWhiteBoardUIController,
                    didPresseStudentListButton button: UIButton)
}

class AgoraWhiteBoardUIController: NSObject, AgoraUIController, AgoraUIControllerContainerDelegate {
    // Contexts
    var boardContext: AgoraEduWhiteBoardContext? {
        return contextProvider?.controllerNeedWhiteBoardContext()
    }
    
    var boardToolContext: AgoraEduWhiteBoardToolContext? {
        return contextProvider?.controllerNeedWhiteBoardToolContext()
    }
    
    var boardPageControlContext: AgoraEduWhiteBoardPageControlContext? {
        return contextProvider?.controllerNeedWhiteBoardPageControlContext()
    }
    
    var extAppContext: AgoraEduExtAppContext? {
        return contextProvider?.controllerNeedExtAppContext()
    }
    
    // Views
    let boardToolsView = AgoraBoardToolsView(frame: .zero)
    let boardView = AgoraBoardView(frame: .zero)
    let boardPageControl = AgoraBoardPageControlView(frame: .zero)
    let unfoldButton = AgoraBoardToolsUnfoldButton(frame: .zero)
    weak var colorButton: UIButton?
    
    var containerView = AgoraUIControllerContainer(frame: .zero)
    
    // States
    let boardToolsState = AgoraBoardToolsState()
    let boardState = AgoraWhiteBoardState()
    let boardPageControlState = AgoraBoardPageControlState()
    
    private(set) var viewType: AgoraEduContextAppType
    
    weak var delegate: AgoraWhiteBoardUIControllerDelegate?
    weak var contextProvider: AgoraControllerContextProvider?
    weak var eventRegister: AgoraControllerEventRegister?
    
    init(viewType: AgoraEduContextAppType,
         delegate: AgoraWhiteBoardUIControllerDelegate,
         contextProvider: AgoraControllerContextProvider,
         eventRegister: AgoraControllerEventRegister) {
        self.viewType = viewType
        self.delegate = delegate
        self.contextProvider = contextProvider
        self.eventRegister = eventRegister
        super.init()
        
        observeEvent(register: eventRegister)
        initViews()
        initLayout()
        initState()
    }
    
    func observeEvent(register: AgoraControllerEventRegister) {
        register.controllerRegisterWhiteBoardEvent(self)
        register.controllerRegisterWhiteBoardPageControlEvent(self)
    }
    
    func updateBoardViewOpaque(sharing: Bool) {
        if sharing {
            boardView.backgroundColor = UIColor.clear
            boardView.isOpaque = false
            for v in boardView.subviews {
                v.isOpaque = false
            }
        } else {
            boardView.backgroundColor = UIColor.white
        }
        
        self.boardPageControl.isScreenVisible = sharing
    }
    
    func initViews() {
        containerView.delegate = self
        containerView.addSubview(boardView)
        containerView.addSubview(boardToolsView)
        containerView.addSubview(boardPageControl)
        containerView.addSubview(unfoldButton)
        
        boardToolsView.backgroundColor = .white
        boardToolsView.didFoldCompletion = { [unowned self] (isFold) in
            guard isFold else {
                return
            }
            
            self.didFoldAnimation(isFold)
        }
        
        unfoldButton.addTarget(self,
                               action: #selector(doUnfolodButton),
                               for: .touchUpInside)
        
        boardPageControl.delegate = self
    }
    
    func initLayout() {
        boardView.agora_x = 0
        boardView.agora_y = 0
        boardView.agora_right = 0
        boardView.agora_bottom = 0
        boardView.setupShadow(cornerRadius: 4)
        
        boardToolsView.agora_x = 10
        boardToolsView.agora_y = 10
        boardToolsView.agora_width = 42
        boardToolsView.toolButtonLineSpace = 10
        boardToolsView.toolButtonListBottomSpace = 20
        boardToolsView.setupShadow(cornerRadius: 21)
        boardToolsView.setupPopover()
        boardToolsView.isHidden = true
        
        unfoldButton.agora_x = -150
        unfoldButton.agora_y = 10
        unfoldButton.agora_width = 84
        unfoldButton.agora_height = 42
        
        boardPageControl.agora_x = 10
        boardPageControl.agora_bottom = 10
        boardPageControl.agora_height = 40
        boardPageControl.agora_width = 260
        boardPageControl.setupShadow(cornerRadius: 20)
    }
    
    func initState() {
        boardToolsState.delegate = self
        boardState.delegate = self
        boardPageControlState.delegate = self
    }
    
    // AgoraUIControllerContainerDelegate
    func containerLayoutSubviews() {
        boardToolsViewHeight()
    }

    func boardToolsViewHeight(animation: Bool = false) {
        let toolsViewWithPageControlDistance: CGFloat = 12
        let boardToolsViewBottom = boardPageControl.agora_bottom + boardPageControl.agora_height + toolsViewWithPageControlDistance
        let limitToolsViewMaxHeight = containerView.bounds.height - boardToolsView.agora_y - boardToolsViewBottom
        boardToolsView.maxHeight = limitToolsViewMaxHeight
        
        guard animation else {
            return
        }
        
        UIView.animate(withDuration: TimeInterval.agora_animation) { [unowned self] in
            self.containerView.layoutIfNeeded()
        }
    }
}

fileprivate extension UIView {
    func setupShadow(cornerRadius: CGFloat) {
        let shadowColor = UIColor(rgb: 0x2F4192).cgColor
        let shadowOpacity: Float = 0.15
        let shadowOffset = CGSize(width: 0,
                                  height: 2)
        
        layer.cornerRadius = cornerRadius
        layer.shadowColor = shadowColor
        layer.shadowOffset = shadowOffset
        layer.shadowOpacity = shadowOpacity
    }
}

fileprivate extension AgoraBoardToolsView {
    func setupPopover() {
        let shadowColor = UIColor(rgb: 0x2F4192).cgColor
        let shadowOpacity: Float = 0.15
        let shadowOffset = CGSize(width: 0,
                                  height: 2)
        
        popover.borderColor = UIColor(rgb: 0xE1E1EA)
        popover.layer.shadowColor = shadowColor
        popover.layer.shadowOffset = shadowOffset
        popover.layer.shadowOpacity = shadowOpacity
    }
}
