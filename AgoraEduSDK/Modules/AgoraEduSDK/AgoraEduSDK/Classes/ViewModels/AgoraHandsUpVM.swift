//
//  AgoraHandsUpVM.swift
//  AgoraEduSDK
//
//  Created by LYY on 2021/3/15.
//

import Foundation
import AgoraUIEduBaseViews
import AgoraActionProcess
import AgoraEduContext

@objcMembers public class AgoraHandsUpVM: AgoraBaseVM {
    
    fileprivate var processManager: AgoraActionProcessManager?
    
    public var updateEnableBlock: ((_ enable: Bool) -> Void)?
    public var updateHandsUpBlock: ((_ state: AgoraEduContextHandsUpState) -> Void)?
    public var showTipsBlock: ((_ message: String) -> Void)?
    
    fileprivate var processInfo: AgoraActionProperties?

    override public init(config: AgoraVMConfig) {
        super.init(config: config)

        let actionConfig = AgoraActionConfig(inAppId: config.appId,
                                             inRoomId: config.roomUuid,
                                             inUserUuid: config.userUuid,
                                             inToken: config.token,
                                             inBaseURL: config.baseURL)
        self.processManager = AgoraActionProcessManager(actionConfig)
    }
    
    public func initHandsUpState(successBlock: @escaping () -> Void, failureBlock: @escaping (_ error: AgoraEduContextError) -> Void) {
        
        self.getHandsUpState {[weak self] in
            guard let `self` = self, let processInfo = self.processInfo else {
                return
            }
            
            let enabled = processInfo.enabled == 1
            self.updateEnableBlock?(enabled)
            
            if let _ = processInfo.progress.first(where: { $0.userUuid == self.config.userUuid }) {
                self.updateHandsUpBlock?(AgoraEduContextHandsUpState.handsUp)
            } else {
                self.updateHandsUpBlock?(AgoraEduContextHandsUpState.default)
            }
        } failureBlock: { (error) in
            failureBlock(error)
        }
    }
    
    public func updateHandsUpInfo(state: AgoraEduContextHandsUpState, successBlock: @escaping () -> Void, failureBlock: @escaping (_ error: AgoraEduContextError) -> Void) {
        
        AgoraEduManager.share().roomManager?.getFullUserList(success: { (rteUsers) in
            
            let actionStateType = (state == AgoraEduContextHandsUpState.handsUp) ? AgoraActionStateType.handsUp : AgoraActionStateType.handsDown
            let options = AgoraActionStartOptions(toUserUuid: "", actionType: actionStateType)
            self.processManager?.handleActionProcess(options: options, success: { (response) in
                
                guard let `response` = response else {
                    return
                }
                
                if response.code == AgoraActionHTTPOK {
                    successBlock()
                } else {
                    let kitError = AgoraEduContextError(code: response.code,
                                                 message: response.msg)
                    failureBlock(kitError)
                }
            }, failure: {[weak self] (error) in
                if let err = self?.kitError(error) {
                    failureBlock(err)
                }
            })
            
        }, failure: {[weak self] (error) in
            if let err = self?.kitError(error) {
                failureBlock(err)
            }
        })
    }
    
    // 上台变化
    public func getChangedCoHosts(cause: Any?, completeBlock: @escaping (_ onCoHosts: [String], _ offCoHosts: [String]) -> Void) {
        
        guard let actionCauseInfo = self.processManager?.analyzeActionCause(cause) else {
            return
        }
        
        var onCoHosts: [String] = []
        var offCoHosts: [String] = []
        
        // on
        if let accepted = actionCauseInfo.accepted,
           accepted.data.processUuid == AgoraActionProcessUuid.handsUp,
           accepted.data.actionType == AgoraActionStateType.accepted {
            
            accepted.data.addAccepted.forEach({onCoHosts.append($0.userUuid)})
        }
        
        // off
        if let canceled = actionCauseInfo.cancel,
           canceled.data.processUuid == AgoraActionProcessUuid.handsUp,
           canceled.data.actionType == AgoraActionStateType.canceled {
            
            canceled.data.removeAccepted.forEach({offCoHosts.append($0.userUuid)})
        }
        
        if (onCoHosts.count > 0 || offCoHosts.count > 0) {
            completeBlock(onCoHosts, offCoHosts)
        }
    }
    
    public func updateHandsUpInfo(cause: Any?, successBlock: @escaping () -> Void, failureBlock: @escaping (_ error: AgoraEduContextError) -> Void) {

        guard let actionCauseInfo = self.processManager?.analyzeActionCause(cause) else {
            return
        }
        
        self.getHandsUpState {[weak self] in
            guard let `self` = self else {
                return
            }
            
            let (_, _) = self.checkProcessState(actionCauseInfo)
            
            let (_, _) = self.checkHandsUp(actionCauseInfo)
            
            let (_, _) = self.checkHandsDown(actionCauseInfo)
            
            let (_, _) = self.checkAccepted(actionCauseInfo)
            
            let (_, _) = self.checkRejected(actionCauseInfo)
            
            let (_, _) = self.checkCanceled(actionCauseInfo)
            
            successBlock()
            
        } failureBlock: { (error) in
            failureBlock(error)
        }
    }
}

extension AgoraHandsUpVM {
    fileprivate func getHandsUpState(successBlock: @escaping () -> Void, failureBlock: @escaping (_ error: AgoraEduContextError) -> Void) {
        AgoraEduManager.share().roomManager?.getClassroomInfo(success: {[weak self] (room) in
            
            guard let `self` = self else {
                return
            }
            
            if let processInfos =  self.processManager?.analyzeActionProperties(room.roomProperties),
               let processInfo = processInfos[AgoraActionProcessUuid.handsUp] {
                self.processInfo = processInfo
            }
            successBlock()
            
        }, failure: {[weak self] (error) in
            if let err = self?.kitError(error) {
                failureBlock(err)
            }
        })
    }
}

// MARK: Check
extension AgoraHandsUpVM {
    fileprivate func checkCanceled(_ actionCauseInfo: AgoraActionCause) -> (AgoraActionCauseType?, AgoraActionStateType?) {
        
        guard self.processInfo != nil else {
            return (nil, nil)
        }

        if let canceled = actionCauseInfo.cancel,
           canceled.data.processUuid == AgoraActionProcessUuid.handsUp,
           canceled.data.actionType == AgoraActionStateType.canceled,
           let _ = canceled.data.removeAccepted.first(where: { $0.userUuid == self.config.userUuid }) {
            
                self.updateHandsUpBlock?(AgoraEduContextHandsUpState.default)
            if let messsage = self.getHandsUpTips(canceled.data.actionType) {
                self.showTipsBlock?(messsage)
            }
            
            return (canceled.cmd, canceled.data.actionType)
        }
        
        return (nil, nil)
    }
    
    fileprivate func checkRejected(_ actionCauseInfo: AgoraActionCause) -> (AgoraActionCauseType?, AgoraActionStateType?) {
        
        guard self.processInfo != nil else {
            return (nil, nil)
        }

        if let rejected = actionCauseInfo.rejected,
           rejected.data.processUuid == AgoraActionProcessUuid.handsUp,
           rejected.data.actionType == AgoraActionStateType.rejected || rejected.data.actionType == AgoraActionStateType.applyTimeOut,
           let _ = rejected.data.removeProgress.first(where: { $0.userUuid == self.config.userUuid }) {
            
            self.updateHandsUpBlock?(AgoraEduContextHandsUpState.default)
            if let messsage = self.getHandsUpTips(rejected.data.actionType) {
                self.showTipsBlock?(messsage)
            }
            
            return (rejected.cmd, rejected.data.actionType)
        }
        
        return (nil, nil)
    }
    
    fileprivate func checkAccepted(_ actionCauseInfo: AgoraActionCause) -> (AgoraActionCauseType?, AgoraActionStateType?) {
        
        guard self.processInfo != nil else {
            return (nil, nil)
        }

        if let accepted = actionCauseInfo.accepted,
           accepted.data.processUuid == AgoraActionProcessUuid.handsUp,
           accepted.data.actionType == AgoraActionStateType.accepted,
           let _ = accepted.data.addAccepted.first(where: { $0.userUuid == self.config.userUuid }) {

            if let messsage = self.getHandsUpTips(accepted.data.actionType) {
                self.showTipsBlock?(messsage)
            }
            
            return (accepted.cmd, accepted.data.actionType)
        }
        
        return (nil, nil)
    }
    
    fileprivate func checkHandsDown(_ actionCauseInfo: AgoraActionCause) -> (AgoraActionCauseType?, AgoraActionStateType?) {
        
        guard self.processInfo != nil else {
            return (nil, nil)
        }

        // 是不是自己放手
        if let handsDown = actionCauseInfo.handsDown,
           handsDown.data.processUuid == AgoraActionProcessUuid.handsUp,
           handsDown.data.actionType == AgoraActionStateType.handsDown,
           let _ = handsDown.data.removeProgress.first(where: { $0.userUuid == self.config.userUuid }) {
            
            self.updateHandsUpBlock?(AgoraEduContextHandsUpState.handsDown)
            
            if let messsage = self.getHandsUpTips(handsDown.data.actionType) {
                self.showTipsBlock?(messsage)
            }
            
            return (handsDown.cmd, handsDown.data.actionType)
        }
        
        return (nil, nil)
    }
    
    fileprivate func checkHandsUp(_ actionCauseInfo: AgoraActionCause) -> (AgoraActionCauseType?, AgoraActionStateType?) {
        
        guard self.processInfo != nil else {
            return (nil, nil)
        }
        
        // 是不是自己举手
        if let handsUp = actionCauseInfo.handsUp,
           handsUp.data.processUuid == AgoraActionProcessUuid.handsUp,
           handsUp.data.actionType == AgoraActionStateType.handsUp,
           let _ = handsUp.data.addProgress.first(where: { $0.userUuid == self.config.userUuid }) {
            
            self.updateHandsUpBlock?(AgoraEduContextHandsUpState.handsUp)
            
            if let messsage = self.getHandsUpTips(handsUp.data.actionType) {
                self.showTipsBlock?(messsage)
            }
            
            return (handsUp.cmd, handsUp.data.actionType)
        }
        
        return (nil, nil)
    }
    
    fileprivate func checkProcessState(_ actionCauseInfo: AgoraActionCause) -> (AgoraActionCauseType?, AgoraActionStateType?)  {
        
        guard let processInfo = self.processInfo else {
            return (nil, nil)
        }
        
        if let state = actionCauseInfo.state,
           state.data.processUuid == AgoraActionProcessUuid.handsUp {
            let enabled = processInfo.enabled == 1
            self.updateEnableBlock?(enabled)
            
            let messsage = self.getHandsUpModeTips(enabled)
            self.showTipsBlock?(messsage)
            return (state.cmd, nil)
        }
        
        return (nil, nil)
    }
}

// MARK: Message
extension AgoraHandsUpVM {
    fileprivate func getHandsUpModeTips(_ enable: Bool) -> String {
        return enable ? self.localizedString("OpenHandsUpText") : self.localizedString("CloseHandsUpText")
    }

    fileprivate func getHandsUpTips(_ type: AgoraActionStateType) -> String? {

        switch type {
        case .handsUp:
            return self.localizedString("HandsUpSuccessText")
        case .handsDown:
            return self.localizedString("HandsDownSuccessText")
        case .accepted:
            return self.localizedString("AcceptedCoHostText")
        case .rejected:
            return self.localizedString("RejectedCoHostText")
        case .applyTimeOut:
            return self.localizedString("HandsUpTimeOutText")
        case .canceled:
            return self.localizedString("RemovedCoHostText")
            
        default:
            break
        }
        
        return nil
    }
}
