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
    private var delegate: AgoraDeviceControllerDelegate?
    
    private var eventDispatcher: AgoraUIEventDispatcher = AgoraUIEventDispatcher()
    
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
    
    public func updateRteStreamStates(_ rteStreamStates: [String: AgoraDeviceStreamState], deviceType: AgoraDeviceStateType) {
        self.vm?.updateRteStreamStates(rteStreamStates, deviceType: deviceType)
    }
    
    public func updateDeviceState(rteLocalUserStream: AgoraRTEStream,
                                  successBlock: (() -> Void)?,
                                  failureBlock: ((_ error: AgoraEduContextError) -> Void)?) {
        self.vm?.updateDeviceState(rteLocalUserStream: rteLocalUserStream,
                                   successBlock: nil,
                                   failureBlock: nil)
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
    private func deviceStateChanged(cameraState: AgoraEduContextDeviceState, microState: AgoraEduContextDeviceState, fromUser: AgoraRTEUser) {
        
        if let message = self.vm?.getDeviceTipMessage(user: fromUser, state: cameraState, type: .camera) {
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
        eventDispatcher.register(object: handler)
    }
}
