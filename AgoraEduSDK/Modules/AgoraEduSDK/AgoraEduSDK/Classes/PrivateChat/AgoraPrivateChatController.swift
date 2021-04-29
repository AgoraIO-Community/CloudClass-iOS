//
//  AgoraPrivateChatController.swift
//  AgoraEduSDK
//
//  Created by SRS on 2021/4/9.
//  Copyright © 2021 Agora. All rights reserved.
//

import Foundation
import EduSDK
import AgoraUIBaseViews
import AgoraUIEduBaseViews
import AgoraEduContext

@objc public protocol AgoraPrivateChatControllerDelegate: NSObjectProtocol {
//    func privateChatController(_ controller: AgoraPrivateChatController,
//                         didUpdateUsers userId: [String])
    
    func privateChatController(_ controller: AgoraPrivateChatController,
                         didOccurError error: AgoraEduContextError)
}

extension AgoraPrivateChatController: AgoraEduMessageHandler {
    // 收到房间消息
    public func onAddRoomMessage(_ info: AgoraEduContextChatInfo) {
        
    }
    // 收到聊天权限变化
    public func onUpdateChatPermission(_ allow: Bool) {
        
    }
    // 本地发送消息结果（包含首次和后面重发），如果error不为空，代表失败
    public func onSendRoomMessageResult(_ error: AgoraEduContextError?, info: AgoraEduContextChatInfo?) {
        
    }
    // 查询历史消息结果，如果error不为空，代表失败
    public func onFetchHistoryMessagesResult(_ error: AgoraEduContextError?, list: [AgoraEduContextChatInfo]?) {
        
    }
    /* 显示聊天过程中提示信息
     * 禁言模式开启
     * 禁言模式关闭
     */
    public func onShowChatTips(_ message: String) {
        
    }
}

@objcMembers public class AgoraPrivateChatController: NSObject, AgoraController {
    
    public var vm: AgoraPrivateChatVM?
    public weak var delegate: AgoraPrivateChatControllerDelegate?
    
    private var eventDispatcher: AgoraUIEventDispatcher = AgoraUIEventDispatcher()

    public init(vmConfig: AgoraVMConfig,
                delegate: AgoraPrivateChatControllerDelegate?) {
        self.vm = AgoraPrivateChatVM(config: vmConfig)
        self.delegate = delegate
    }
    
    // 有流加入
    public func addRemoteStream(_ rteStream: AgoraRTEStream) {
        self.vm?.addRemoteStream(rteStream)
    }
    
    // Init PrivateChat
    public func initPrivateChat() {
        self.vm?.initPrivateChat({[weak self] in
            guard let `self` = self, let vm = self.vm else {
                return
            }
            
            if let kitPrivateChatInfo = vm.kitPrivateChatInfo {
                self.eventDispatcher.onStartPrivateChat(kitPrivateChatInfo)
            } else {
//                self.kitPrivateChatProtocol?.onEndPrivateChat()
            }
            
        }, failureBlock: {[weak self] (error) in
            guard let `self` = self else {
                return
            }
            self.delegate?.privateChatController(self, didOccurError: error)
        })
    }
    
    // Changed PrivateChat
    public func updatePrivateChat(cause: Any?) {
        
        self.vm?.updatePrivateChat(cause: cause, successBlock: {[weak self] in
            guard let `self` = self, let vm = self.vm else {
                return
            }
            
            if let kitPrivateChatInfo = vm.kitPrivateChatInfo {
                self.eventDispatcher.onStartPrivateChat(kitPrivateChatInfo)
            } else {
                self.eventDispatcher.onEndPrivateChat()
            }
        }, failureBlock: {[weak self] (error) in
            guard let `self` = self else {
                return
            }
            self.delegate?.privateChatController(self, didOccurError: error)
        })
    }
}

// MARK: - Life cycle
extension AgoraPrivateChatController {
    public func viewWillAppear() {
        
    }
    
    public func viewDidLoad() {
        
    }
    
    public func viewDidAppear() {
        
    }
    
    public func viewWillDisappear() {
        
    }
    
    public func viewDidDisappear() {
        
    }
}

extension AgoraPrivateChatController: AgoraEduPrivateChatContext {
    public func updatePrivateChat(_ userUuid: String) {
        self.vm?.updatePrivateChat(toUserUuid: userUuid, successBlock: {
            
        }, failureBlock: {[weak self] (error) in
            guard let `self` = self else {
                return
            }
            self.delegate?.privateChatController(self, didOccurError: error)
        })
    }
    public func endPrivateChat() {
        self.vm?.updatePrivateChat(toUserUuid: nil, successBlock: {
            
        }, failureBlock: {[weak self] (error) in
            guard let `self` = self else {
                return
            }
            self.delegate?.privateChatController(self, didOccurError: error)
        })
    }
    // 事件监听
    public func registerEventHandler(_ handler: AgoraEduPrivateChatHandler) {
        
    }
}
