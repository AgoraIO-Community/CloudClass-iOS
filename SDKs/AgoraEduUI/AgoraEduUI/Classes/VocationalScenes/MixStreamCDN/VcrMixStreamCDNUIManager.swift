//
//  VcrMixStreamCDNUIManager.swift
//  AgoraEduUI
//
//  Created by Jonathan on 2022/6/23.
//

import AgoraUIBaseViews
import AgoraEduContext
import AudioToolbox
import AgoraWidget

/** 合流转推的UIManager*/
@objc public class VcrMixStreamCDNUIManager: AgoraEduUIManager {
    /** 房间状态 控制器*/
    private lazy var stateController = VocationalRoomStateUIController(context: contextPool)
    /** 全局状态 控制器（自身不包含UI）*/
    private lazy var globalController = AgoraRoomGlobalUIController(context: contextPool,
                                                                    delegate: nil)
    /** CDN渲染 控制器*/
    private lazy var renderController = VcrMixStreamCDNRenderUIController(context: contextPool)
    /** 聊天窗口 控制器*/
    private lazy var chatController = AgoraChatUIController(context: contextPool)
    
    private var isJoinedRoom = false
        
    deinit {
        print("\(#function): \(self.classForCoder)")
    }
    
    public override func viewDidLoad() {
        super.viewDidLoad()
        
        initViews()
        initViewFrame()
        updateViewProperties()
        
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
    
    public override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        if isJoinedRoom == false {
            AgoraLoading.loading()
        }
    }
}
// MARK: - AgoraUIContentContainer
@objc extension VcrMixStreamCDNUIManager: AgoraUIContentContainer {
    func initViews() {
        stateController.roomDelegate = self
        addChild(stateController)
        contentView.addSubview(stateController.view)
        
        globalController.roomDelegate = self
        addChild(globalController)
        globalController.viewDidLoad()
        
        chatController.hideMiniButton = true
        if contextPool.user.getLocalUserInfo().userRole == .observer {
            chatController.hideInput = true
        }
        addChild(chatController)
        FcrUIColorGroup.borderSet(layer: chatController.view.layer)
        contentView.addSubview(chatController.view)
        contentView.sendSubviewToBack(chatController.view)
        
        renderController.view.layer.cornerRadius = AgoraFit.scale(2)
        renderController.view.clipsToBounds = true
        addChild(renderController)
        contentView.addSubview(renderController.view)
    }
    
    func initViewFrame() {
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
    
    func updateViewProperties() {
        
    }
}
