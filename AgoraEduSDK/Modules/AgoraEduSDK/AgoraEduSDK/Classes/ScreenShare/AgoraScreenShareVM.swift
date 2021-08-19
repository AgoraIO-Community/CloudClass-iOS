//
//  AgoraScreenShareVM.swift
//  AgoraEduSDK
//
//  Created by SRS on 2021/5/7.
//  Copyright © 2021 Agora. All rights reserved.
//

import EduSDK
import AgoraEduContext

public class AgoraScreenShareVM: AgoraBaseVM {
    
    // 屏幕分享状态 用于本地记录，比较
    fileprivate var screenState: AgoraScreenShareState = .stop
    fileprivate var screenRTCState: AgoraScreenShareRTCState = .offLine
    fileprivate var scenePath: String = ""
    
    // 开启屏幕分享
    public func getUpdateScreenStreamInfos(rteStreamEvents: [AgoraRTEStreamEvent]) -> [String:String] {
        var infos: [String:String] = [:]
        for rteStreamEvent in rteStreamEvents {
            if rteStreamEvent.modifiedStream.sourceType == .screen {
                infos.updateValue(rteStreamEvent.modifiedStream.userInfo.userName, forKey: rteStreamEvent.modifiedStream.streamUuid)
            }
        }
        return infos
    }
    public func getUpdateScreenStreamInfos(rteStreams: [AgoraRTEStream]) -> [String:String] {
        var infos: [String:String] = [:]
        for rteStream in rteStreams {
            if rteStream.sourceType == .screen {
                infos.updateValue(rteStream.userInfo.userName, forKey: rteStream.streamUuid)
            }
        }
        return infos
    }
    public func getScreenTipMessage(_ userName: String, sharing: Bool) -> String {

        let subStr = sharing ? self.localizedString("ScreensharedBySb") : self.localizedString("ScreenshareStoppedBySb")
        let message = userName + subStr
       
        return message
    }
    
    // ScenePath变化
    public func updateScenePath(_ path: String, successBlock: @escaping (_ state: AgoraScreenShareState, _ screenStreamUuid: String?) -> Void, failureBlock: ((_ error: AgoraEduContextError) -> Void)?) {
        self.scenePath = path
        self.updateScreenShareState(successBlock: successBlock, failureBlock: failureBlock)
    }
        
    // RTC流变化
    public func rtcStreamChanged(_ streamUuid: String, rtcState: AgoraScreenShareRTCState, successBlock: @escaping (_ state: AgoraScreenShareState, _ screenStreamUuid: String?) -> Void, failureBlock: ((_ error: AgoraEduContextError) -> Void)?) {
        
        AgoraEduManager.share().roomManager?.getFullStreamList(success: {[weak self] (rteStreams) in
            
            guard let `self` = self else {
                return
            }
            
            // 如果是屏幕分享的RTC流变化才处理
            if let rteStream = rteStreams.first(where: {$0.streamUuid == streamUuid}), rteStream.sourceType == .screen {
                 
                self.screenRTCState = rtcState
                self.updateScreenShareState(successBlock: successBlock, failureBlock: failureBlock)
            }
        }, failure: { [weak self] (error) in
            if let err = self?.kitError(error) {
                failureBlock?(err)
            }
        })
    }

    // Property changed
    public func screenSelectChanged(cause: Any?, successBlock: @escaping (_ state: AgoraScreenShareState, _ screenStreamUuid: String?) -> Void, failureBlock: ((_ error: AgoraEduContextError) -> Void)?) {
        
        guard let `cause` = cause as? Dictionary<String, Any>,
              let cmd = cause["cmd"] as? Int,
              let causeCmd = AgoraCauseType(rawValue: cmd),
              causeCmd == .screenSelectChanged else {
            return
        }
        
        self.updateScreenShareState(successBlock: successBlock, failureBlock: failureBlock)
    }
    
    public func getScreenStreamUuid(successBlock: @escaping (_ streamUuid: String?) -> Void, failureBlock: ((_ error: AgoraEduContextError) -> Void)?) {
        
        AgoraEduManager.share().roomManager?.getFullStreamList(success: {[weak self] (rteStreams) in
            guard let `self` = self else {
                return
            }
            
            let stream = rteStreams.first(where: {$0.sourceType == .screen})
            
            // step1:没有业务流， 直接退出
            guard let rteStream = stream else {
                successBlock(nil)
                return
            }
            successBlock(rteStream.streamUuid)
        }, failure: { [weak self] (error) in
            if let err = self?.kitError(error) {
                failureBlock?(err)
            }
        })
    }
}

extension AgoraScreenShareVM {
    // init | 屏幕分享RTC变化 | selectScreenShare属性变化 | 屏幕分享业务流变化 | 白板ScenePath变化
    public func updateScreenShareState(successBlock: @escaping (_ state: AgoraScreenShareState, _ screenStreamUuid: String?) -> Void, failureBlock: ((_ error: AgoraEduContextError) -> Void)?) {
        
        self.handleScreenShareState { [weak self] (screenState, screenStreamUuid) in
            if self?.screenState != screenState {
                self?.screenState = screenState
                successBlock(screenState, screenStreamUuid)
            }
        } failureBlock: { (error) in
            failureBlock?(error)
        }
    }

    private func handleScreenShareState(successBlock: @escaping (_ state: AgoraScreenShareState, _ screenStreamUuid: String?) -> Void, failureBlock: ((_ error: AgoraEduContextError) -> Void)?) {
        
        // 判断当前是否有屏幕分享业务流
        self.getScreenStreamUuid { (streamUuid) in
            // step1:没有业务流， 直接退出
            guard let rteStreamUuid = streamUuid else {
                successBlock(AgoraScreenShareState.stop, nil)
                return
            }
            
            successBlock(AgoraScreenShareState.start, streamUuid)

        } failureBlock: { (error) in
            failureBlock?(error)
        }
    }
}
