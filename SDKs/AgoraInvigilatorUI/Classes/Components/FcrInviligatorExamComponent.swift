//
//  FcrInviligatorExamComponent.swift
//  AgoraInvigilatorUI
//
//  Created by LYY on 2022/9/1.
//

import AgoraUIBaseViews
import AgoraEduContext

@objc public protocol FcrInviligatorExamComponentDelegate: NSObjectProtocol {
    func onExamExit()
}

@objc public class FcrInviligatorExamComponent: UIViewController,
                                        AgoraUIContentContainer {
    /**views**/
    private lazy var exitButton = UIButton()
    private lazy var nameLabel = UILabel()
    private lazy var countDot = UIView()
    private lazy var countLabel = UILabel()
    private lazy var leaveButton = UIButton()
    private lazy var renderView = FcrInviligatorRenderView()
    
    /**context**/
    private weak var delegate: FcrInviligatorExamComponentDelegate?
    private let roomController: AgoraEduRoomContext
    private let userController: AgoraEduUserContext
    private let mediaController: AgoraEduMediaContext
    private let streamController: AgoraEduStreamContext
    
    @objc public init(roomController: AgoraEduRoomContext,
                      userController: AgoraEduUserContext,
                      mediaController: AgoraEduMediaContext,
                      streamController: AgoraEduStreamContext,
                      delegate: FcrInviligatorExamComponentDelegate?) {
        self.roomController = roomController
        self.userController = userController
        self.mediaController = mediaController
        self.streamController = streamController
        self.delegate = delegate
        
        super.init(nibName: nil,
                   bundle: nil)
    }
    
    public override func viewDidLoad() {
        super.viewDidLoad()
        
        initViews()
        initViewFrame()
        updateViewProperties()
    }
    
    public func initViews() {

        
//        let roomName = contextPool.room.getRoomInfo().roomName
//        let roomState = contextPool.room.getClassInfo().state
//        let userName = contextPool.user.getLocalUserInfo().userName
        
        view.addSubviews([exitButton,
                          nameLabel,
                          countDot,
                          countLabel,
                          leaveButton,
                          renderView])
    }
    
    public func initViewFrame() {
        
    }
    
    public func updateViewProperties() {

    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}

// MARK: - private
private extension FcrInviligatorExamComponent {
    @objc func onClickExitRoom() {
        
    }
}
