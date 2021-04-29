//
//  AgoraActionProcessManager.swift
//  AgoraActionProcess
//
//  Created by SRS on 2020/11/30.
//

import Foundation
import AgoraActionProcess.OCFile.HTTP

public typealias AgoraActionHTTPSuccess = (AgoraActionResponse?) -> Void
public typealias AgoraActionHTTPFailure = (Error) -> Void

public class AgoraActionProcessManager {

    fileprivate var config: AgoraActionConfig?
    
    fileprivate init() {
    }
    
    public convenience init(_ config: AgoraActionConfig) {
        self.init()
        self.config = config
    }
    
    // roomProperties: current room properties
    public func analyzeActionProperties(_ roomProperties: Any?) -> [AgoraActionProcessUuid: AgoraActionProperties] {
        
        guard let properties = roomProperties as? Dictionary<String, Any>, let processes = properties["processes"] as? Dictionary<String, Any> else {
            return [:]
        }
        
        let processUuids = processes.keys // e.g. "handsup"
        var infos: [AgoraActionProcessUuid: AgoraActionProperties] = [:]
        processUuids.forEach { (processUuid) in

            guard let key = AgoraActionProcessUuid(rawValue: processUuid),
                  let value = processes[processUuid],
                  JSONSerialization.isValidJSONObject(value) else {
                return
            }

            guard let data = try? JSONSerialization.data(withJSONObject: value, options: []) else {
                return
            }

            guard let model = try? JSONDecoder().decode(AgoraActionProperties.self, from: data) else {
                return
            }

            infos[key] = model
        }

        return infos
    }
    
    public func analyzeActionCause(_ cause: Any?) -> AgoraActionCause {
        
        var causeInfo = AgoraActionCause()
        
        guard let `cause` = cause as? Dictionary<String, Any>,
              JSONSerialization.isValidJSONObject(cause),
              let data = try? JSONSerialization.data(withJSONObject: cause, options: []) else {
            return causeInfo
        }

        // 开关举手
        if let state = try? JSONDecoder().decode(AgoraActionCauseProcessState.self, from: data),
           state.cmd == .processState {
            causeInfo.state = state
            return causeInfo
        }
        
        // 举手
        if let handsUp = try? JSONDecoder().decode(AgoraActionCauseHandsUp.self, from: data),
           handsUp.cmd == .actionState,
           handsUp.data.actionType == .handsUp {
            causeInfo.handsUp = handsUp
            return causeInfo
        }
        
        // 同意
        if let accepted = try? JSONDecoder().decode(AgoraActionCauseAccepted.self, from: data),
           accepted.cmd == .actionState,
           accepted.data.actionType == .accepted {
            causeInfo.accepted = accepted
            return causeInfo
        }

        // 拒绝和超时
        if let rejected = try? JSONDecoder().decode(AgoraActionCauseRejected.self, from: data),
           rejected.cmd == .actionState,
           (rejected.data.actionType == .rejected ||
                rejected.data.actionType == .applyTimeOut ) {
            causeInfo.rejected = rejected
            return causeInfo
        }
        
        // 取消举手
        if let handsDown = try? JSONDecoder().decode(AgoraActionCauseHandsDown.self, from: data),
           handsDown.cmd == .actionState,
           handsDown.data.actionType == .handsDown {
            causeInfo.handsDown = handsDown
            return causeInfo
        }
        
        // 下麦和被下麦
        if let cancel = try? JSONDecoder().decode(AgoraActionCauseCancel.self, from: data),
           cancel.cmd == .actionState,
           (cancel.data.actionType == .cancel ||
                cancel.data.actionType == .canceled) {
            causeInfo.cancel = cancel
            return causeInfo
        }
        
        return causeInfo
    }
    
    public func handleActionProcess(options: AgoraActionStartOptions,
                                        success: AgoraActionHTTPSuccess?,
                                        failure: AgoraActionHTTPFailure?) {
        
        guard let config = self.config else {
            return
        }
        
        var urlStr = ""
        var requestType: AgoraActionHttpType = .get
        var params = ["toUserUuid": options.toUserUuid]
        
        switch options.actionType {
        case .handsUp :
            urlStr = "\(config.baseURL)/edu/apps/\(config.appId)/v2/rooms/\(config.roomUuid)/processes/handsUp/progress"
            requestType = .post
            
        case .accepted :
            urlStr = "\(config.baseURL)/edu/apps/\(config.appId)/v2/rooms/\(config.roomUuid)/processes/handsUp/acceptance"
            requestType = .post
            
        case .rejected, .handsDown :
            urlStr = "\(config.baseURL)/edu/apps/\(config.appId)/v2/rooms/\(config.roomUuid)/processes/handsUp/progress"
            requestType = .delete

        case .cancel, .canceled :
            urlStr = "\(config.baseURL)/edu/apps/\(config.appId)/v2/rooms/\(config.roomUuid)/processes/handsUp/acceptance"
            requestType = .delete

        default:
            break
        }

        let headers = self.headers()

        switch requestType {
        case .get:
            AgoraActionHTTPClient.get(urlStr, params: [:], headers: headers) {[weak self] (dictionary) in
                
                guard let `self` = self else {
                    return
                }
                let response = self.handleHttpResponse(dictionary)
                success?(response)

            } failure: { (error, code) in
                failure?(error)
            }
        case .post:
            AgoraActionHTTPClient.post(urlStr, params: [:], headers: headers) {[weak self] (dictionary) in
                
                guard let `self` = self else {
                    return
                }
                let response = self.handleHttpResponse(dictionary)
                success?(response)

            } failure: { (error, code) in
                failure?(error)
            }
        case .put:
            AgoraActionHTTPClient.put(urlStr, params: [:], headers: headers) {[weak self] (dictionary) in
                
                guard let `self` = self else {
                    return
                }
                let response = self.handleHttpResponse(dictionary)
                success?(response)

            } failure: { (error, code) in
                failure?(error)
            }
        case .delete:
            AgoraActionHTTPClient.del(urlStr, params: [:], headers: headers) {[weak self] (dictionary) in
                
                guard let `self` = self else {
                    return
                }
                let response = self.handleHttpResponse(dictionary)
                success?(response)

            } failure: { (error, code) in
                failure?(error)
            }
        default:
            break
        }
    }
}

// MARK: HTTP
extension AgoraActionProcessManager {
    fileprivate func handleHttpResponse(_ dictionary: Any) -> AgoraActionResponse? {
        
        if !JSONSerialization.isValidJSONObject(dictionary) {
            return nil
        }

        guard let data = try? JSONSerialization.data(withJSONObject: dictionary, options: []) else {
            return nil
        }

        guard let model = try? JSONDecoder().decode(AgoraActionResponse.self, from: data) else {
            return nil
        }
        
        return model
    }
}

extension AgoraActionProcessManager {
    fileprivate func headers() -> [String : String] {
        return ["Content-Type":"application/json",
                "x-agora-token":self.config?.token ?? "",
                "x-agora-uid":self.config?.userUuid ?? ""];
    }
}
