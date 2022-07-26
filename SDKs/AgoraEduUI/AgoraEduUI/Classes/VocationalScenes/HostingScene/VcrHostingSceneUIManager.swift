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
@objc public class VcrHostingSceneUIManager: AgoraEduUIManager {

    /** 房间状态 控制器*/
    private lazy var stateController = VocationalRoomStateUIController(context: contextPool)
    /** 全局状态 控制器（自身不包含UI）*/
    private lazy var globalController = AgoraRoomGlobalUIController(context: contextPool,
                                                                    delegate: nil)
    /** 视频渲染 控制器*/
    private lazy var renderController = VcrHostingPlayerUIController(context: contextPool)
    /** 聊天窗口 控制器*/
    private lazy var chatController = AgoraChatUIController(context: contextPool)
    
    private var isJoinedRoom = false
        
    deinit {
        print("\(#function): \(self.classForCoder)")
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
            self?.exitClassRoom(reason: .normal)
        }
    }
        
    override func initViews() {
        super.initViews()
        stateController.roomDelegate = self
        addChild(stateController)
        contentView.addSubview(stateController.view)
        
        globalController.roomDelegate = self
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
    
    override func initViewFrame() {
        super.initViewFrame()
        
        UIConfig = FcrLectrueConfig()
        
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
            make?.right.equalTo()(chatController.view.mas_left)
        }
    }
    
    public override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        if isJoinedRoom == false {
            AgoraLoading.loading()
        }
    }
}
