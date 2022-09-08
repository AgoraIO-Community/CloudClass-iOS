//
//  VcrHostingSceneUIManager.swift
//  AgoraEduUI
//
//  Created by Jonathan on 2022/6/27.
//

import AgoraUIBaseViews
import AgoraEduContext
import AudioToolbox
import AgoraWidget

/** 伪直播（托管课堂）的UIManager*/
@objc public class VcrHostingUIScene: FcrUIScene {

    /** 房间状态 控制器*/
    private lazy var stateController = FcrRoomStateUIComponent(roomController: contextPool.room,
                                                               userController: contextPool.user,
                                                               monitorController: contextPool.monitor,
                                                               groupController: contextPool.group) 
    /** 全局状态 控制器（自身不包含UI）*/
    private lazy var globalController = FcrRoomGlobalUIComponent(roomController: contextPool.room,
                                                                 userController: contextPool.user,
                                                                 monitorController: contextPool.monitor,
                                                                 streamController: contextPool.stream,
                                                                 groupController: contextPool.group,
                                                                 exitDelegate: self)
    /** 视频渲染 控制器*/
    private lazy var renderController = VcrHostingPlayerUIComponent(roomController: contextPool.room,
                                                                    monitorController: contextPool.monitor)
    /** 聊天窗口 控制器*/
    private lazy var chatController = FcrChatUIComponent(roomController: contextPool.room,
                                                         userController: contextPool.user,
                                                         widgetController: contextPool.widget)
    
    private var isJoinedRoom = false
        
    @objc public init(contextPool: AgoraEduContextPool,
                      delegate: FcrUISceneDelegate?) {
        super.init(sceneType: .lecture,
                   contextPool: contextPool,
                   delegate: delegate)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    public override func viewDidLoad() {
        super.viewDidLoad()
        
        contextPool.room.joinRoom { [weak self] in
            AgoraLoading.hide()
            guard let `self` = self else {
                return
            }
            self.isJoinedRoom = true
            
            if self.contextPool.user.getLocalUserInfo().userRole == .teacher {
                self.contextPool.media.openLocalDevice(systemDevice: .frontCamera)
                self.contextPool.media.openLocalDevice(systemDevice: .mic)
            }
        } failure: { [weak self] error in
            AgoraLoading.hide()
            self?.exitScene(reason: .normal)
        }
    }
        
    public override func initViews() {
        super.initViews()
        addChild(stateController)
        contentView.addSubview(stateController.view)
        
        addChild(globalController)
        globalController.viewDidLoad()

        addChild(chatController)
        contentView.addSubview(chatController.view)
        contentView.sendSubviewToBack(chatController.view)
        
        renderController.roomDelegate = self
        renderController.view.layer.cornerRadius = AgoraFit.scale(2)
        renderController.view.clipsToBounds = true
        addChild(renderController)
        contentView.addSubview(renderController.view)
    }
    
    public override func initViewFrame() {
        super.initViewFrame()
        
        stateController.view.mas_makeConstraints { make in
            make?.top.left().right().equalTo()(0)
            make?.height.equalTo()(AgoraFit.scale(34))
        }
        
        chatController.view.mas_makeConstraints { make in
            make?.top.equalTo()(stateController.view.mas_bottom)?.offset()(AgoraFit.scale(2))
            make?.width.equalTo()(AgoraFit.scale(170))
            make?.right.bottom().equalTo()(0)
        }
        
        renderController.view.mas_makeConstraints { make in
            make?.top.equalTo()(stateController.view.mas_bottom)?.offset()(AgoraFit.scale(2))
            make?.left.bottom().equalTo()(0)
            make?.right.equalTo()(chatController.view.mas_left)?.offset()(-2)
        }
    }
    
    public override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        if isJoinedRoom == false {
            AgoraLoading.loading()
        }
    }
}
