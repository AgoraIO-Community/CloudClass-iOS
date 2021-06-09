//
//  AgoraPrivateChatController.swift
//  AgoraEduSDK
//
//  Created by SRS on 2021/4/9.
//  Copyright © 2021 Agora. All rights reserved.
//
//
import Foundation
import EduSDK
import AgoraUIBaseViews
import AgoraUIEduBaseViews
import AgoraEduContext

@objc public protocol AgoraPrivateChatControllerDelegate: NSObjectProtocol {
    func privateChatController(_ controller: AgoraPrivateChatController,
                         didOccurError error: AgoraEduContextError)
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
        eventDispatcher.register(event: .privateChat(object: handler))
    }
}
