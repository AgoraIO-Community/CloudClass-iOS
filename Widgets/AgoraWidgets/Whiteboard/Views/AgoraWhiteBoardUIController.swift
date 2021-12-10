////
////  AgoraWhiteBoardController.swift
////  AFNetworking
////
////  Created by Cavan on 2021/4/15.
////
//
//import AgoraUIEduBaseViews
//import AgoraUIBaseViews
//import AgoraEduContext
//
//protocol AgoraWhiteBoardUIControllerDelegate: NSObjectProtocol {
//    func whiteBoard(_ controller: AgoraWhiteBoardUIController,
//                    willUpdateDisplayMode isFullScreen: Bool)
//    
//    func whiteBoard(_ controller: AgoraWhiteBoardUIController,
//                    didPresseStudentListButton button: UIButton)
//}
//
//class AgoraWhiteBoardUIController: NSObject, AgoraUIController, AgoraUIControllerContainerDelegate {
//    var toastShowedStates: [String] = []
//
//    // Contexts
//    var boardContext: AgoraEduWhiteBoardContext? {
//        return contextProvider?.controllerNeedWhiteBoardContext()
//    }
//    
//    var boardToolContext: AgoraEduWhiteBoardToolContext? {
//        return contextProvider?.controllerNeedWhiteBoardToolContext()
//    }
//    
//    var boardPageControlContext: AgoraEduWhiteBoardPageControlContext? {
//        return contextProvider?.controllerNeedWhiteBoardPageControlContext()
//    }
//    
//    var extAppContext: AgoraEduExtAppContext? {
//        return contextProvider?.controllerNeedExtAppContext()
//    }
//    
//    // Views
//    weak var boardContentView: UIView?
//    
//    let boardToolsView = AgoraBoardToolsView(frame: .zero)
//    let boardView = AgoraBoardView(frame: .zero)
//    let boardPageControl = AgoraBoardPageControlView(frame: .zero)
//    let unfoldButton = AgoraBoardToolsUnfoldButton(frame: .zero)
//    weak var colorButton: UIButton?
//    weak var pencilButton: UIButton?
//    weak var userListButton: UIButton?
//    
//    var containerView = AgoraUIControllerContainer(frame: .zero)
//    
//    // States
//    let boardToolsState = AgoraBoardToolsState()
//    let boardState = AgoraWhiteBoardState()
//    let boardPageControlState = AgoraBoardPageControlState()
//    
//    private(set) var viewType: AgoraEduContextRoomType
//    
//    weak var delegate: AgoraWhiteBoardUIControllerDelegate?
//    weak var contextProvider: AgoraControllerContextProvider?
//    var needTransparent = false {
//        didSet {
//            boardPageControl.isScreenVisible = needTransparent
//            boardView.allTransparent(needTransparent)
//        }
//    }
//    
//    init(viewType: AgoraEduContextRoomType,
//         delegate: AgoraWhiteBoardUIControllerDelegate,
//         contextProvider: AgoraControllerContextProvider) {
//        self.viewType = viewType
//        self.delegate = delegate
//        self.contextProvider = contextProvider
//        super.init()
//    
//        initViews()
//        initLayout()
//        initState()
//    }
//    
//    func initViews() {
//        containerView.delegate = self
//        containerView.addSubview(boardView)
//        containerView.addSubview(boardToolsView)
//        containerView.addSubview(boardPageControl)
//        containerView.addSubview(unfoldButton)
//        
//        boardToolsView.backgroundColor = .white
//        boardToolsView.didFoldCompletion = { [unowned self] (isFold) in
//            guard isFold else {
//                return
//            }
//            
//            self.didFoldAnimation(isFold)
//        }
//        
//        unfoldButton.addTarget(self,
//                               action: #selector(doUnfolodButton),
//                               for: .touchUpInside)
//        
//        boardPageControl.delegate = self
//    }
//    
//    func initLayout() {
//        boardView.agora_x = 0
//        boardView.agora_y = 0
//        boardView.agora_right = 0
//        boardView.agora_bottom = 0
//        boardView.setupShadow(cornerRadius: 4)
//        
//        boardToolsView.agora_x = 10
//        boardToolsView.agora_y = 10
//        boardToolsView.agora_width = 42
//        boardToolsView.toolButtonLineSpace = 10
//        boardToolsView.toolButtonListBottomSpace = 20
//        boardToolsView.setupShadow(cornerRadius: 21)
//        boardToolsView.setupPopover()
//        boardToolsView.isHidden = true
//        
//        unfoldButton.agora_x = -150
//        unfoldButton.agora_y = 10
//        unfoldButton.agora_width = 84
//        unfoldButton.agora_height = 42
//        
//        boardPageControl.agora_x = 10
//        boardPageControl.agora_bottom = 10
//        boardPageControl.agora_height = 40
//        boardPageControl.agora_width = 260
//        boardPageControl.setupShadow(cornerRadius: 20)
//        
//        guard let contentView = boardContext?.getContentView() else {
//            return
//        }
//        contentView.translatesAutoresizingMaskIntoConstraints = false
//        contentView.agora_equal_to_superView(attribute: .top)
//        contentView.agora_equal_to_superView(attribute: .left)
//        contentView.agora_equal_to_superView(attribute: .right)
//        contentView.agora_equal_to_superView(attribute: .bottom)
//    }
//    
//    func initState() {
//        boardToolsState.delegate = self
//        boardState.delegate = self
//        boardPageControlState.delegate = self
//    }
//    
//    // AgoraUIControllerContainerDelegate
//    func containerLayoutSubviews() {
//        boardToolsViewHeight()
//    }
//
//    func boardToolsViewHeight(animation: Bool = false) {
//        let toolsViewWithPageControlDistance: CGFloat = 12
//        let boardToolsViewBottom = boardPageControl.agora_bottom + boardPageControl.agora_height + toolsViewWithPageControlDistance
//        let limitToolsViewMaxHeight = containerView.bounds.height - boardToolsView.agora_y - boardToolsViewBottom
//        boardToolsView.maxHeight = limitToolsViewMaxHeight
//        
//        guard animation else {
//            return
//        }
//        
//        UIView.animate(withDuration: TimeInterval.agora_animation) { [unowned self] in
//            self.containerView.layoutIfNeeded()
//        }
//    }
//}
//
//extension UIView {
//    func setupShadow(cornerRadius: CGFloat) {
//        let shadowColor = UIColor(rgb: 0x2F4192).cgColor
//        let shadowOpacity: Float = 0.15
//        let shadowOffset = CGSize(width: 0,
//                                  height: 2)
//        
//        layer.cornerRadius = cornerRadius
//        layer.shadowColor = shadowColor
//        layer.shadowOffset = shadowOffset
//        layer.shadowOpacity = shadowOpacity
//    }
//    
//    func allTransparent(_ transparent: Bool) {
//        backgroundColor = transparent ? .clear : .white
//        isOpaque = !transparent
//        for v in subviews {
//            v.isOpaque = !transparent
//        }
//    }
//}
//
//fileprivate extension AgoraBoardToolsView {
//    func setupPopover() {
//        let shadowColor = UIColor(rgb: 0x2F4192).cgColor
//        let shadowOpacity: Float = 0.15
//        let shadowOffset = CGSize(width: 0,
//                                  height: 2)
//        
//        popover.borderColor = UIColor(rgb: 0xE1E1EA)
//        popover.layer.shadowColor = shadowColor
//        popover.layer.shadowOffset = shadowOffset
//        popover.layer.shadowOpacity = shadowOpacity
//    }
//}
