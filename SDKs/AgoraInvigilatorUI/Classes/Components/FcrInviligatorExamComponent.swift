//
//  FcrInviligatorExamComponent.swift
//  AgoraInvigilatorUI
//
//  Created by LYY on 2022/9/1.
//

import AgoraUIBaseViews
import AgoraEduContext

@objc public class FcrInviligatorExamComponent: UIViewController,
                                        AgoraUIContentContainer {
    /**views**/
    private lazy var renderView = FcrInviligatorRenderView()
    private lazy var examView = FcrInviligatorExamView()
    
    /**context**/
    private var contextPool: AgoraEduContextPool
    
    @objc public init(contextPool: AgoraEduContextPool) {
        self.contextPool = contextPool
        
        super.init(nibName: nil,
                   bundle: nil)
    }
    
    @objc public init() {
        
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
        if #available(iOS 13.0, *) {
            overrideUserInterfaceStyle = (agora_ui_mode == .agoraDark) ? .dark : .light
        }
        
//        let roomName = contextPool.room.getRoomInfo().roomName
//        let roomState = contextPool.room.getClassInfo().state
//        let userName = contextPool.user.getLocalUserInfo().userName
        
        let roomName = "room"
        let roomState = AgoraEduContextClassState.before
        let userName = "user"
        
        deviceTestView.roomName = roomName
        deviceTestView.roomState = roomState.toUI
        deviceTestView.userName = userName
        
        deviceTestView.exitButton.addTarget(self,
                                            action: #selector(onClickExitRoom),
                                            for: .touchUpInside)
        
        deviceTestView.enterButton.addTarget(self,
                                             action: #selector(onClickEnterRoom),
                                             for: .touchUpInside)
        
        examView.exitButton.addTarget(self,
                                      action: #selector(onClickExitRoom),
                                      for: .touchUpInside)
        
        examView.leaveButton.addTarget(self,
                                       action: #selector(onClickExitRoom),
                                       for: .touchUpInside)
        
        view.addSubviews([deviceTestView,
                          renderView,
                          examView])
        
        let config = UIConfig
        
        deviceTestView.agora_enable = config.deviceTest.enable
        deviceTestView.agora_visible = true
        
        renderView.agora_enable = config.render.enable
        renderView.agora_visible = false
        
        examView.agora_enable = config.exam.enable
        examView.agora_visible = false
    }
    
    public func initViewFrame() {
        deviceTestView.mas_makeConstraints { make in
            make?.left.right().top().bottom().equalTo()(0)
        }
        
        renderView.mas_makeConstraints { make in
            make?.top.equalTo()(213)
            make?.left.right().bottom().equalTo()(0)
        }
        
        examView.mas_makeConstraints { make in
            make?.left.right().top().bottom().equalTo()(0)
        }
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
