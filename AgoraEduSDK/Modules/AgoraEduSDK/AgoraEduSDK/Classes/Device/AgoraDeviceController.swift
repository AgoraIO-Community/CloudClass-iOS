//
//  AgoraDeviceController.swift
//  AgoraEduSDK
//
//  Created by SRS on 2021/5/7.
//  Copyright © 2021 Agora. All rights reserved.
//

import Foundation
import EduSDK
import AgoraUIBaseViews
import AgoraUIEduBaseViews
import AgoraEduContext

@objc public protocol AgoraDeviceControllerDelegate: NSObjectProtocol {
    
    @objc func deviceController(_ controller: AgoraDeviceController,
                                didOccurError error: AgoraEduContextError)
    
    @objc func deviceController(_ controller: AgoraDeviceController,
                                didCameraStateChanged cameraState: AgoraEduContextDeviceState,
                                didMicroStateChanged microState: AgoraEduContextDeviceState,
                                fromUser user: AgoraRTEUser)
}

@objcMembers public class AgoraDeviceController: NSObject, AgoraController {
    
    private var vm: AgoraDeviceVM?
    private weak var delegate: AgoraDeviceControllerDelegate?
    
    private var eventDispatcher: AgoraUIEventDispatcher
    
    public init(vmConfig: AgoraVMConfig,
                delegate: AgoraDeviceControllerDelegate) {
        self.vm = AgoraDeviceVM(config: vmConfig)
        self.eventDispatcher = AgoraUIEventDispatcher()
        self.delegate = delegate
        super.init()
    }
    
    public func initDeviceState() {
        self.vm?.initDeviceState(successBlock: { [weak self] (deviceConfig) in
            guard let `self` = self else {
                return
            }
            
            self.eventDispatcher.onCameraDeviceEnableChanged(enabled: deviceConfig.cameraEnabled)
            self.eventDispatcher.onCameraFacingChanged(facing: deviceConfig.cameraFacing)
            self.eventDispatcher.onMicDeviceEnabledChanged(enabled: deviceConfig.micEnabled)
            self.eventDispatcher.onSpeakerEnabledChanged(enabled: deviceConfig.speakerEnabled)
        }, failureBlock: { (error) in
            
        })
    }
    
    public func updateRteStreamStates(_ rteStreamStates: [String: AgoraDeviceStreamState],
                                      deviceType: AgoraDeviceStateType) {
        self.vm?.updateRteStreamStates(rteStreamStates, deviceType: deviceType)
    }
    
    // 更新本地rtc设备
    public func updateLocalDeviceState(_ rteLocalUserStream: AgoraRTEStream) {
        self.vm?.updateDeviceState(rteLocalUserStream: rteLocalUserStream,
                                   successBlock: nil,
                                   failureBlock: nil)
    }
    // 流变化的时候 更新本地设备状态值
    public func updateDeviceState(rteStreamEvents: [AgoraRTEStreamEvent],
                                  changeType: AgoraInfoChangeType) {
        var rteStreams = [AgoraRTEStream]()
        rteStreamEvents.map({rteStreams.append($0.modifiedStream)})
        self.updateDeviceState(rteStreams: rteStreams,
                               changeType: changeType)
    }
    public func updateDeviceState(rteStreams: [AgoraRTEStream],
                                  changeType: AgoraInfoChangeType) {
        
        AgoraEduManager.share().roomManager?.getFullUserList(success: { [weak self] (rteUsers) in
            
            guard let `self` = self, let vm = self.vm else {
                return
            }
            
            for rteStream in rteStreams {
                let rteBaseUser = rteStream.userInfo
                guard let rteUser = rteUsers.first(where: {$0.userUuid == rteBaseUser.userUuid}) else {
                    continue
                }
                
                let stream = changeType == .remove ? nil : rteStream
                let cameraState = vm.getUserDeviceState(.camera,
                                                        rteUser: rteUser,
                                                        rteStream: stream)
                let microState = vm.getUserDeviceState(.microphone,
                                                       rteUser: rteUser,
                                                       rteStream: stream)
                self.deviceStateChanged(cameraState: cameraState,
                                        microState: microState,
                                        fromUser: rteUser)
            }
            
        }, failure: { (error) in
            
        })
    }
    
    public func updateDeviceState(user: AgoraRTEUser,
                                  cause: Any?) {
        
        self.vm?.updateDeviceState(rteUser: user,
                                   cause: cause,
                                   successBlock: { [weak self ] (user,
                                                                 cameraState,
                                                                 microState) in
                                    self?.deviceStateChanged(cameraState: cameraState,
                                                             microState: microState,
                                                             fromUser: user)
                                   }, failureBlock: { (error) in
                                    
                                   })
    }
    
    public func getCameraState(user: AgoraRTEUser, stream: AgoraRTEStream?) -> AgoraEduContextDeviceState {
        return self.vm?.getUserDeviceState(.camera,
                                           rteUser: user,
                                           rteStream: stream) ?? .available
    }
    
    public func getMicroState(user: AgoraRTEUser, stream: AgoraRTEStream?) -> AgoraEduContextDeviceState {
        return self.vm?.getUserDeviceState(.microphone,
                                           rteUser: user,
                                           rteStream: stream) ?? .available
    }
}

// MARK: - Private
extension AgoraDeviceController {
    private func deviceStateChanged(cameraState: AgoraEduContextDeviceState,
                                    microState: AgoraEduContextDeviceState,
                                    fromUser: AgoraRTEUser) {
        if let message = self.vm?.getDeviceTipMessage(user: fromUser,
                                                      state: cameraState,
                                                      type: .camera) {
            self.eventDispatcher.onDeviceTips(message: message)
        }
        
        self.delegate?.deviceController(self,
                                        didCameraStateChanged: cameraState,
                                        didMicroStateChanged: microState,
                                        fromUser: fromUser)
    }
    private func occurError(error: AgoraEduContextError) {
        self.delegate?.deviceController(self,
                                        didOccurError: error)
    }
}

// MARK: - Life cycle
extension AgoraDeviceController {
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

extension AgoraDeviceController: AgoraEduDeviceContext {
    public func setCameraDeviceEnable(enable: Bool) {
        
        // 直接更新本地状态
        self.vm?.updateLocalDeviceState(.camera,
                                        enable: enable,
                                        successBlock: { [weak self] (rteUser,
                                                                     cameraState,
                                                                     microState) in
                                            self?.deviceStateChanged(cameraState: cameraState,
                                                                     microState: microState,
                                                                     fromUser: rteUser)
                                        },
                                        failureBlock: { [weak self] (error) in
                                            self?.occurError(error: error)
                                        })
        
        // 更新本地设备状态的时候， 0或者1 不可以 更新状态2。 状态2首先初始化为0.
        self.vm?.setCameraDeviceEnable(enable: enable,
                                       successBlock: {
                                        
                                       },
                                       failureBlock: {[weak self] (error) in
                                        self?.occurError(error: error)
                                       })
    }
    
    public func switchCameraFacing() {
        self.vm?.switchCameraFacing(successBlock: {
            
        },
        failureBlock: {[weak self] (error) in
            if let `self` = self {
                self.delegate?.deviceController(self, didOccurError: error)
            }
        })
    }
    
    public func setMicDeviceEnable(enable: Bool) {
        // 直接更新本地状态
        self.vm?.updateLocalDeviceState(.microphone,
                                        enable: enable,
                                        successBlock: { [weak self] (rteUser,
                                                                     cameraState,
                                                                     microState) in
                                            self?.deviceStateChanged(cameraState: cameraState,
                                                                     microState: microState,
                                                                     fromUser: rteUser)
                                        },
                                        failureBlock: { [weak self] (error) in
                                            self?.occurError(error: error)
                                        })
        
        // 更新本地设备状态的时候， 0或者1 不可以 更新状态2。 状态2首先初始化为0.
        self.vm?.setMicDeviceEnable(enable: enable,
                                    successBlock: {
                                        
                                    },
                                    failureBlock: {[weak self] (error) in
                                        self?.occurError(error: error)
                                    })
    }
    
    public func setSpeakerEnable(enable: Bool) {
        self.vm?.setSpeakerEnable(enable: enable,
                                  successBlock: {
                                    
                                  },
                                  failureBlock: {[weak self] (error) in
                                    self?.occurError(error: error)
                                  })
    }
    
    public func registerDeviceEventHandler(_ handler: AgoraEduDeviceHandler) {
        eventDispatcher.register(event: .device(object: handler))
    }
}
