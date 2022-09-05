//
//  FcrInviligatorScene.swift
//  AgoraInvigilatorUI
//
//  Created by LYY on 2022/9/1.
//

import AgoraUIBaseViews
import AgoraEduContext

@objc public class FcrInviligatorScene: UIViewController,
                                        AgoraUIContentContainer {
    /**views**/
    private lazy var deviceTestView = FcrInviligatorDeviceTestView(renderView: renderView)
    private lazy var renderView = FcrInviligatorRenderView()
    private lazy var examView = FcrInviligatorExamView()
    
    /**context**/
    let contextPool: AgoraEduContextPool
    
    @objc public init(contextPool: AgoraEduContextPool) {
        self.contextPool = contextPool
        
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
        
        let roomName = contextPool.room.getRoomInfo().roomName
        let roomState = contextPool.room.getClassInfo().state
        let userName = contextPool.user.getLocalUserInfo().userName
        
        deviceTestView.roomName = roomName
        deviceTestView.roomState = roomState.toUI
        deviceTestView.userName = userName
        
        view.addSubviews([deviceTestView,
                          renderView,
                          examView])
        
        let config = UIConfig
        
        deviceTestView.agora_enable = config.deviceTest.enable
        deviceTestView.agora_visible = true
        
        renderView.agora_enable = config.render.enable
        renderView.agora_visible = true
        
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
