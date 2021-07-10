//
//  AgoraDeviceVM.swift
//  AgoraEduSDK
//
//  Created by SRS on 2021/5/7.
//  Copyright © 2021 Agora. All rights reserved.
//

import EduSDK
import AgoraEduContext
import AgoraReport

@objcMembers public class AgoraDeviceStateCountInfo: NSObject {
    public var cameraCount: Int = 0
    public var microCount: Int = 0
}

@objcMembers public class AgoraDeviceVM: AgoraBaseVM {
    
    // 自己的流状态 用于本地记录，比较
    fileprivate var streamConfig = AgoraRTEStreamConfig(streamUuid: "0")
    // 自己的设备状态
    fileprivate var deviceConfig: AgoraEduContextDeviceConfig?
    
    // 流状态 [streamUuid: AgoraRTEStreamState]
    fileprivate var rteStreamStates: [String: AgoraDeviceStreamState] = [:]
    fileprivate var rteLocalStreamState = AgoraDeviceStreamState()
    
    private var teaCameraState: AgoraEduContextDeviceState = .available
    private var teaMicroState: AgoraEduContextDeviceState = .available
    
    // 用于判断远端设备状态
    fileprivate var threadTimer: AgoraSubThreadTimer?
    fileprivate var rteStreamCountInfo: [String: AgoraDeviceStateCountInfo] = [:]
    
//    fileprivate var deviceLock: NSLock = NSLock()
    
    public override init(config: AgoraVMConfig) {
        super.init(config: config)
        
        self.rteLocalStreamState.camera = .failed
        self.rteLocalStreamState.microphone = .failed
        
        threadTimer = AgoraSubThreadTimer(threadName: "io.agora.timer.event", timeInterval: 2.0)
        threadTimer?.delegate = self
        
        threadTimer?.start()
    }
    
    public func initDeviceState(successBlock: ((AgoraEduContextDeviceConfig) -> Void)?,
                                failureBlock: ((_ error: AgoraEduContextError) -> Void)?) {
        AgoraEduManager.share().roomManager?.getLocalUser(success: { [weak self] (rteLocalUser) in
            guard let `self` = self else {
                return
            }
            
            var cameraEnabled = true
            var cameraFacing = EduContextCameraFacing.front
            var micEnabled = true
            var speakerEnabled = false
            
            if let properties = rteLocalUser.userProperties as? Dictionary<String, Any>,
               let device = properties["device"] as? Dictionary<String, Any> {
                
                let camera = device[AgoraDeviceType.camera.rawValue] as? Int ?? 1
                let mic = device[AgoraDeviceType.microphone.rawValue] as? Int ?? 1
                // 默认不开启麦克风
                let speaker = device[AgoraDeviceType.speaker.rawValue] as? Int ?? 0
                // 默认前置摄像头
                let facing = device[AgoraDeviceType.facing.rawValue] as? Int ?? 0

                cameraEnabled = (camera != 2)
                cameraFacing = (facing == 0) ? .front : .back
                micEnabled = (mic != 2)
                speakerEnabled = (speaker == 1)
            }
            
            self.deviceConfig = AgoraEduContextDeviceConfig(cameraEnabled: cameraEnabled,
                                                            cameraFacing: cameraFacing,
                                                            micEnabled: micEnabled,
                                                            speakerEnabled: speakerEnabled)
            // rtc只有switch 要单独处理
            if cameraFacing == .back {
                self.switchCamera()
            }
            
            self.updateDeviceState(rteLocalUserStream: rteLocalUser.streams.first,
                                   successBlock: nil,
                                   failureBlock: nil)
            
            successBlock?(self.deviceConfig!)
            
        }, failure: { [weak self] (error) in
            if let err = self?.kitError(error) {
                failureBlock?(err)
            }
        })
    }
    public func updateDeviceState(rteLocalUserStream: AgoraRTEStream?,
                                  successBlock: (() -> Void)?,
                                  failureBlock: ((_ error: AgoraEduContextError) -> Void)?) {
        
        guard let deviceConfig = self.deviceConfig else {
            return
        }
        
        let cameraEnabled = deviceConfig.cameraEnabled
        let micEnabled = deviceConfig.micEnabled
        let speakerEnabled = deviceConfig.speakerEnabled
        
        // update rtc
        self.speakerEnabled(speakerEnabled)
        
        guard let rteStream = rteLocalUserStream else {
            return
        }
        
        let cameraStreamEnabled = (cameraEnabled && rteStream.hasVideo)
        let microStreamEnabled = (micEnabled && rteStream.hasAudio)
        
        self.streamConfig.enableCamera = cameraStreamEnabled
        self.streamConfig.enableMicrophone = microStreamEnabled
        
        self.updateLocalStream(successBlock: {
            successBlock?()
        }, failureBlock: { (error) in
            failureBlock?(error)
        })
    }
    
    public func resetRteStreamStates(_ rteStreamStates: [String: AgoraDeviceStreamState]) {
        // 判断是否上报
        self.rteStreamStates = rteStreamStates
    }
    public func updateRteStreamStates(_ rteStreamStates: [String: AgoraDeviceStreamState],
                                      deviceType: AgoraDeviceStateType) {
        // 判断是否上报
        self.rteStreamStates = rteStreamStates
        
        if let deviceConfig = self.deviceConfig {
            if deviceType == .camera && !deviceConfig.cameraEnabled {
                return
            } else if deviceType == .microphone && !deviceConfig.micEnabled {
                return
            }
        }
        
        // TODO：添加同步锁， 保证不上传多次
        AgoraEduManager.share().roomManager?.getLocalUser(success: { [weak self] (rteLocalUser) in
            
            guard let `self` = self else {
                return
            }
            
            if let rteStreamState = rteStreamStates[rteLocalUser.streamUuid] {
                
                var camera: Int?
                var micro: Int?
                
                if deviceType == .camera {
                    let cameraState = rteStreamState.camera
                    let targetV = (cameraState == .failed) ? 0 : 1
                    let currentV = (self.rteLocalStreamState.camera == .failed)  ? 0 : 1
                    if targetV != currentV {
                        camera = targetV
                    } else {
                        return
                    }
                } else {
                    let microState = rteStreamState.microphone
                    let targetV = (microState == .failed) ? 0 : 1
                    let currentV = (self.rteLocalStreamState.microphone == .failed)  ? 0 : 1

                    if targetV != currentV {
                        micro = targetV
                    } else {
                        return
                    }
                }
                
                self.updateDevices(camera: camera,
                                   micro: micro,
                                   speaker: nil,
                                   facing: nil) { [weak self] in
                    
                    if deviceType == .camera {
                        self?.rteLocalStreamState.camera = rteStreamState.camera
                    } else {
                        self?.rteLocalStreamState.microphone = rteStreamState.microphone
                    }
                } failureBlock: { (error) in
                    
                }
            }
        }, failure: { (error) in
            
        })
    }
    
    deinit {
        threadTimer?.stop()
    }
    
    // MARK: DeviceChanged
    public func updateDeviceState(rteUser: AgoraRTEUser,
                                  cause: Any?,
                                  successBlock: ((AgoraRTEUser,
                                                  AgoraEduContextDeviceState,
                                                  AgoraEduContextDeviceState) -> Void)?,
                                  failureBlock: ((_ error: AgoraEduContextError) -> Void)?) {

        guard let `cause` = cause as? Dictionary<String, Any>,
              (cause["cmd"] as? Int ?? 0) == AgoraCauseType.device.rawValue else {
            return
        }
        
        AgoraEduManager.share().roomManager?.getFullStreamList(success: { [weak self] (rteStreams) in
            
            guard let `self` = self else {
                return
            }
            
            let rteStream = rteStreams.first(where: {$0.streamUuid == rteUser.streamUuid})
            let cameraState: AgoraEduContextDeviceState = self.getUserDeviceState(.camera,
                                                                                  rteUser: rteUser,
                                                                                  rteStream: rteStream)
            let microState: AgoraEduContextDeviceState = self.getUserDeviceState(.microphone,
                                                                                 rteUser: rteUser,
                                                                                 rteStream: rteStream)
            successBlock?(rteUser,
                          cameraState,
                          microState)
        }, failure: { [weak self] (error) in
            if let err = self?.kitError(error) {
                failureBlock?(err)
            }
        })
    }
    
    public func updateLocalDeviceState(_ deviceType: AgoraDeviceStateType,
                                       enable: Bool,
                                       successBlock: ((AgoraRTEUser,
                                                       AgoraEduContextDeviceState,
                                                       AgoraEduContextDeviceState) -> Void)?,
                                       failureBlock: ((_ error: AgoraEduContextError) -> Void)?) {

        switch deviceType {
        case .camera:
            self.deviceConfig?.cameraEnabled = enable
        case .microphone:
            self.deviceConfig?.micEnabled = enable
        }
        
        AgoraEduManager.share().roomManager?.getLocalUser(success: { (rteLocalUser) in
            AgoraEduManager.share().roomManager?.getFullStreamList(success: { [weak self] (rteStreams) in

                guard let `self` = self else {
                    return
                }
                
                let rteStream = rteStreams.first(where: {$0.streamUuid == rteLocalUser.streamUuid})

                let cameraState = self.getUserDeviceState(.camera,
                                                          rteUser: rteLocalUser,
                                                          rteStream: rteStream)
                let microState = self.getUserDeviceState(.microphone,
                                                         rteUser: rteLocalUser,
                                                         rteStream: rteStream)

                successBlock?(rteLocalUser,
                              cameraState,
                              microState)
            }, failure: { [weak self] (error) in
                if let err = self?.kitError(error) {
                    failureBlock?(err)
                }
            })
        }, failure: { [weak self] (error) in
            if let err = self?.kitError(error) {
                failureBlock?(err)
            }
        })
    }
    
    public func getUserDeviceState(_ type: AgoraDeviceType,
                                   rteUser: AgoraRTEUser,
                                   rteStream: AgoraRTEStream?) -> AgoraEduContextDeviceState {
        
        var deviceStreamState: AgoraEduContextDeviceState = .available
        var resetRteStreamCount = true
        
        // 只有自己的时候需要deviceConfig判断
        if rteUser.userUuid == self.config.userUuid {
            // 0和1 不能来修改2
            if let deviceConfig = self.deviceConfig {
                if type == .camera && !deviceConfig.cameraEnabled {
                    return .close
                } else if type == .microphone && !deviceConfig.micEnabled {
                    return .close
                }
                
                switch type {
                case .camera:
                    deviceStreamState = deviceConfig.cameraEnabled ? .available : .close
                case .microphone:
                    deviceStreamState = deviceConfig.micEnabled ? .available : .close
                default:
                    break
                }
            }
        } else {
            // 不是自己的时候，从property里面获取
            if let properties = rteUser.userProperties as? Dictionary<String, Any>,
                  let device = properties["device"] as? Dictionary<String, Any>,
                  let value = device[type.rawValue] as? Int {
                
                if let state = AgoraEduContextDeviceState(rawValue: value) {
                    deviceStreamState = state
                }
            }
        }
        
        // 设备关闭
        if deviceStreamState == .close {
            return .close
        }
        
        // TODO：没有业务流， 代表不在台上， 暂时显示close
        guard let rteStream = rteStream else {
            return .close
        }
        
        // mute, 设备正常
        if (!rteStream.hasVideo && type == .camera) ||
            !rteStream.hasAudio && type == .microphone {
            return .available
        }
        
        // 是否frozen或者stop
        // 默认正常， 有可能远端设备坏的， 而且网络不好
        let deviceStreamStates = self.rteStreamStates[rteUser.streamUuid]
        let streamStates = (type == .camera ? deviceStreamStates?.camera : deviceStreamStates?.microphone) ?? .running
        
        // local
        if rteUser.userUuid == self.config.userUuid {
            if streamStates != .failed {
                return .available
            }
            return .notAvailable
        }
        
        // remote
        if streamStates == .frozen || streamStates == .stopped {
            // 联系记录2次以上
            let stateCountInfo = rteStreamCountInfo[rteUser.streamUuid] ?? AgoraDeviceStateCountInfo()
            let count = (type == .camera) ? stateCountInfo.cameraCount : stateCountInfo.microCount
            if count >= 2 {
                resetRteStreamCount = false
                return .notAvailable
            }
            return .available
        }
        
        defer {
            if rteUser.userUuid != self.config.userUuid && resetRteStreamCount {
                
                let stateType: AgoraDeviceStateType = (type == .camera) ? .camera : .microphone
                resetRteStreamCountInfo(streamUuid: rteUser.streamUuid, type: stateType)
            }
        }
    
        // device里面没有找到， 默认认为是好的
        return .available
    }
    
    public func getDeviceTipMessage(user: AgoraRTEUser, state: AgoraEduContextDeviceState, type: AgoraDeviceStateType) -> String? {
        
        // 现在只显示video
        if type != .camera {
            return nil
        }
            
        // 不是老师
        if user.role != .teacher {
            return nil
        }
        
        // 一样的状态
        if teaCameraState == state {
            return nil
        }
        teaCameraState = state
        
        // 不是坏的设备
        if state != .notAvailable {
            return nil
        }
    
        return self.localizedString("TeacherVideoFailText")
    }
    
    public func setCameraDeviceEnable(enable: Bool,
                                      successBlock: @escaping () -> Void,
                                      failureBlock: @escaping (_ error: AgoraEduContextError) -> Void) {
        
        self.deviceConfig?.cameraEnabled = enable
        self.updateDeviceState { [weak self] in
            self?.updateDevices(camera: enable ? 1:2,
                                micro: nil,
                                speaker: nil,
                                facing: nil) {
                successBlock()
            } failureBlock: { (error) in
                failureBlock(error)
            }
        } failureBlock: { (error) in
            failureBlock(error)
        }
    }
    
    public func setMicDeviceEnable(enable: Bool,
                                   successBlock: @escaping () -> Void,
                                   failureBlock: @escaping (_ error: AgoraEduContextError) -> Void) {
        
        self.deviceConfig?.micEnabled = enable
        self.updateDeviceState { [weak self] in
            self?.updateDevices(camera: nil,
                                micro: enable ? 1:2,
                                speaker: nil,
                                facing: nil) {
                successBlock()
            } failureBlock: { (error) in
                failureBlock(error)
            }
        } failureBlock: { (error) in
            failureBlock(error)
        }
    }
    
    public func switchCameraFacing(successBlock: @escaping () -> Void,
                                   failureBlock: @escaping (_ error: AgoraEduContextError) -> Void) {
        
        guard let cameraFacing = self.deviceConfig?.cameraFacing else {
            return
        }
        
        let targetCameraFacing = cameraFacing == .front ? EduContextCameraFacing.back : EduContextCameraFacing.front
        self.deviceConfig?.cameraFacing = targetCameraFacing
        self.switchCamera()
        
        let targetValue = targetCameraFacing == .front ? 0 : 1
        self.updateDevices(camera: nil,
                           micro: nil,
                           speaker: nil,
                           facing: targetValue) {
            successBlock()
        } failureBlock: { (error) in
            failureBlock(error)
        }
    }
    
    public func setSpeakerEnable(enable: Bool,
                                 successBlock: @escaping () -> Void,
                                 failureBlock: @escaping (_ error: AgoraEduContextError) -> Void) {
        
        self.deviceConfig?.speakerEnabled = enable
        self.updateDeviceState { [weak self] in
            self?.updateDevices(camera: nil,
                                micro: nil,
                                speaker: enable ? 1:0,
                                facing: nil) {
                successBlock()
            } failureBlock: { (error) in
                failureBlock(error)
            }
        } failureBlock: { (error) in
            failureBlock(error)
        }
    }
}

// MARK: Private
private extension AgoraDeviceVM {
    func updateDeviceState(successBlock: @escaping () -> Void,
                           failureBlock: @escaping (_ error: AgoraEduContextError) -> Void) {
        
        AgoraEduManager.share().roomManager?.getLocalUser(success: { [weak self] (rteLocalUser) in
            guard let `self` = self else {
                return
            }
            
            self.updateDeviceState(rteLocalUserStream: rteLocalUser.streams.first,
                                   successBlock: nil,
                                   failureBlock: nil)
            
            successBlock()
            
        }, failure: { [weak self] (error) in
            if let err = self?.kitError(error) {
                failureBlock(err)
            }
        })
    }
    
    func switchCamera() {
        AgoraEduManager.share().studentService?.switchCamera()
    }
    
    func speakerEnabled(_ enable: Bool) {
        AgoraEduManager.share().studentService?.setEnableSpeakerphone(enable)
    }
    
    func updateLocalStream(successBlock: (() -> Void)? = nil,
                           failureBlock: ((_ error: AgoraEduContextError) -> Void)? = nil) {
        
        AgoraEduManager.share().studentService?.startOrUpdateLocalStream(self.streamConfig, success: { (rteStream) in
            successBlock?()
        }, failure: {[weak self] (error) in
            if let err = self?.kitError(error) {
                failureBlock?(err)
            }
        })
    }
}

// MARK: HTTP
private extension AgoraDeviceVM {
    // 1可用 0 不可用
    func updateDevices(camera:Int?,
                              micro:Int?,
                              speaker:Int?,
                              facing:Int?,
                              successBlock: @escaping () -> Void,
                              failureBlock: @escaping (_ error: AgoraEduContextError) -> Void) {
        let baseURL = self.config.baseURL
        let appId = self.config.appId
        let roomUuid = self.config.roomUuid
        let userUuid = self.config.userUuid
        let token = self.config.token
        
        let url = "\(baseURL)/edu/apps/\(appId)/v2/rooms/\(roomUuid)/users/\(userUuid)/device"

        let headers = AgoraHTTPManager.headers(withUId: userUuid,
                                               userToken: "",
                                               token: token)
        
        var parameters: [String : Int] = [:]
        if let camera = camera {
            parameters["camera"] = camera
        }
        
        if let micro = micro {
            parameters["mic"] = micro
        }
        
        if let speaker = speaker {
            parameters["speaker"] = speaker
        }
        
        if let facing = facing {
            parameters["facing"] = facing
        }
        
        AgoraHTTPManager.fetchDispatch(.put, url: url,
                                       parameters: parameters,
                                       headers: headers,
                                       parseClass: AgoraBaseModel.self) { (any) in
            if let _ = any as? AgoraBaseModel {
                successBlock()
            }
            
        } failure: {[weak self] (error, code) in
            if let err = self?.kitError(error) {
                failureBlock(err)
            }
        }
    }
}

// MARK: Timer
extension AgoraDeviceVM: AgoraSubThreadTimerDelegate {
    func resetRteStreamCountInfo(streamUuid: String, type: AgoraDeviceStateType) {
        let countInfo = rteStreamCountInfo[streamUuid] ?? AgoraDeviceStateCountInfo()
        if type == .camera {
            countInfo.cameraCount = 0
        }
        if type == .microphone {
            countInfo.microCount = 0
        }
        rteStreamCountInfo[streamUuid] = countInfo
    }
    
    func resetRteStreamCountInfo(streamUuid: String) {
        resetRteStreamCountInfo(streamUuid: streamUuid, type: .camera)
        resetRteStreamCountInfo(streamUuid: streamUuid, type: .microphone)
    }
    
    public func perLoop() {
        var streamCountInfo: [String: AgoraDeviceStateCountInfo] = [:]
        for streamUuid in rteStreamStates.keys {
            
            let streamState = rteStreamStates[streamUuid]
            let countInfo = rteStreamCountInfo[streamUuid] ?? AgoraDeviceStateCountInfo()
            
            if streamState!.camera == .frozen
                || streamState!.camera == .stopped {
                countInfo.cameraCount = (countInfo.cameraCount ?? 0) + 1
            } else {
                countInfo.cameraCount = 0
            }
            if streamState!.microphone == .frozen
                || streamState!.microphone == .stopped {
                countInfo.microCount = (countInfo.microCount ?? 0) + 1
            } else {
                countInfo.microCount = 0
            }
            streamCountInfo[streamUuid] = countInfo
        }
        rteStreamCountInfo = streamCountInfo
    }
}
