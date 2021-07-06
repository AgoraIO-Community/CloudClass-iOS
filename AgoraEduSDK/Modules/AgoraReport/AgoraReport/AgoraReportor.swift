//
//  AgoraReportor.swift
//  AgoraEduSDK
//
//  Created by Cavan on 2021/2/8.
//

import UIKit
import CommonCrypto
import AFNetworking

@objc public enum AgoraReportEndCategory: Int {
    case rtc, rtm, board, device, http, end
    
    public var key: String {
        switch self {
        case .rtc:     return "rtc"
        case .rtm:     return "rtm"
        case .board:   return "board"
        case .device:  return "device"
        case .http:    return "http"
        case .end:     return "end"
        }
    }
}

@objcMembers public class AgoraReportorContext: NSObject {
    public let source: String
    public let clientType: String
    public let platform: String
    public let appId: String
    public let version: String
    public let token: String
    public let userUuid: String
    public let host: String
    
    @objc public init(source: String,
                      clientType: String,
                      platform: String,
                      appId: String,
                      version: String,
                      token: String,
                      userUuid: String,
                      host: String) {
        self.source = source
        self.clientType = clientType
        self.platform = platform
        self.appId = appId
        self.version = version
        self.token = token
        self.userUuid = userUuid
        self.host = host
    }
}

@objcMembers public class AgoraReportorContextV2: NSObject {
    public var source: String
    public var host: String
    public var vid: Int32
    public var version: String
    public var scenario: String
    public var userUuid: String
    public var userName: String
    public var userRole: String
    public var streamUuid: String
    public var streamSessionId: String
    public var roomUuid: String
    public var rtmSid: String
    public var roomCreatTs: Int64
    
    @objc public init(source: String,
                      host: String,
                      vid: Int32,
                      version: String,
                      scenario: String,
                      userUuid: String,
                      userName: String,
                      userRole: String,
                      streamUuid: String,
                      streamSessionId: String,
                      roomUuid: String,
                      rtmSid: String,
                      roomCreatTs: Int64) {
        self.source = source
        self.host = host
        self.vid = vid
        self.version = version
        self.scenario = scenario
        self.userUuid = userUuid
        self.userName = userName
        self.userRole = userRole
        self.streamUuid = streamUuid
        self.streamSessionId = streamSessionId
        self.roomUuid = roomUuid
        self.rtmSid = rtmSid
        self.roomCreatTs = roomCreatTs
    }
}

@objc public protocol AgoraReportorLogTube: NSObjectProtocol {
    func reportor(_ reportor: AgoraReportor,
                  didOutputInfo log: String)
    func reportor(_ reportor: AgoraReportor,
                  didOutputError log: String)
}

@objcMembers open class AgoraReportor: NSObject {
    public weak var logTube: AgoraReportorLogTube?
    
    public private(set) var context: AgoraReportorContext?
    public private(set) var contextV2: AgoraReportorContextV2?
    
    private lazy var httpSession: AFHTTPSessionManager = {
        let session = AFHTTPSessionManager()
        session.requestSerializer = AFJSONRequestSerializer()
        session.requestSerializer.timeoutInterval = 10
        session.responseSerializer = AFJSONResponseSerializer()
        return session
    }()
    
    // Duration event
    private var startEvents = [String: Int64]()
    private var startSubEvents = [String: Int64]()
    
    private let startEvnetsMaxCount = 10000
    
    public func set(context: AgoraReportorContext) {
        self.context = context
    }
    
    public func setV2(context: AgoraReportorContextV2) {
        self.contextV2 = context
    }
}

// MARK: - Process event
public extension AgoraReportor {
    @discardableResult func start(event: String) -> Bool {
        guard startEvents.count < startEvnetsMaxCount else {
            return false
        }
        
        let timestamp = Date().timestamp()
        startEvents[event] = timestamp
        return true
    }
    
    func end(event: String,
             type: AgoraReportEndCategory,
             errorCode: Int?,
             httpCode: Int?) {
        
        guard let startTime = startEvents[event] else {
            return
        }
        
        let elapse = Date().timestamp() - startTime
        startEvents.removeValue(forKey: event)
        
        processEventHttpRequest(event: event,
                                category: type.key,
                                errorCode: errorCode,
                                httpCode: httpCode,
                                elapse: elapse,
                                count: nil)
    }
    
    @discardableResult func start(event: String,
                                  subEvent: String) -> Bool {
        guard startSubEvents.count < startEvnetsMaxCount else {
            return false
        }
        
        let key = event + "-" + subEvent
        let timestamp = Date().timestamp()
        startSubEvents[key] = timestamp
        return true
    }
    
    func end(event: String,
             subEvent: String,
             type: AgoraReportEndCategory,
             errorCode: Int?,
             httpCode: Int?,
             api: String? = nil) {
        let key = event + "-" + subEvent
        guard let startTime = startSubEvents[key] else {
            return
        }
        
        let elapse = Date().timestamp() - startTime
        startSubEvents.removeValue(forKey: key)
        
        processEventHttpRequest(event: event,
                                category: type.key,
                                api: api,
                                errorCode: errorCode,
                                httpCode: httpCode,
                                elapse: elapse,
                                count: nil)
    }
}

// MARK: - Timer event
public extension AgoraReportor {
    func timerEvent(event: String,
                    count: Int? = nil) {
        timerEventHttpRequest(event: event,
                              count: count)
    }
}

// MARK: - Point event
public extension AgoraReportor {
    func pointEvent(eventId: Int,
                    payload: String) {
        htttpRequestV2(eventId: eventId,
                       payload: payload)
    }
}

public extension AgoraReportor {
    func timerEventHttpRequest(event: String,
                               count: Int? = nil) {
        let m = event
        httpRequest(m: m,
                    count: count)
    }
    
    func processEventHttpRequest(event: String,
                                 category: String,
                                 api: String? = nil,
                                 errorCode: Int? = nil,
                                 httpCode: Int? = nil,
                                 elapse: Int64? = nil,
                                 count: Int? = nil) {
        httpRequest(event: event,
                    category: category,
                    m: "event",
                    api: api,
                    errorCode: errorCode,
                    httpCode: httpCode,
                    elapse: elapse,
                    count: count)
    }
}

private extension AgoraReportor {
    func httpRequest(event: String? = nil,
                     category: String? = nil,
                     m: String,
                     api: String? = nil,
                     errorCode: Int? = nil,
                     httpCode: Int? = nil,
                     elapse: Int64? = nil,
                     count: Int? = nil) {
        guard let context = self.context else {
            fatalError("call ‘set(context: AgoraReportorContext)’ before")
        }
        
        let timestamp = Date().timestamp()
        
        let sign = "src=\(context.source)&ts=\(timestamp)"
        
        // ls
        var ls: [String: Any] = ["ctype": context.clientType,
                                 "platform": context.platform,
                                 "version": context.version,
                                 "appId": context.appId]
        
        if let tEvent = event {
            ls["event"] = tEvent
        }
        
        if let tCategory = category {
            ls["category"] = tCategory
        }

        if let tApi = api {
            ls["api"] = tApi
        }
        
        ls["result"] = "1"
        
        if let tHttpCode = httpCode {
            ls["httpCode"] = String(tHttpCode)
            ls["result"] = (tHttpCode == 200 ? "1" : "0")
        }
        
        if let tErrorCode = errorCode {
            ls["errCode"] = String(tErrorCode)
            ls["result"] = (tErrorCode == 0 ? "1" : "0")
        }
        
        // vs
        var vs = [String: Any]()
            
        if let tCount = count {
            vs["count"] = tCount
        }
        
        if let tElapse = elapse {
            vs["elapse"] = tElapse
        }
        
        let point: [String: Any] = ["m": m,
                                    "ls": ls,
                                    "vs": vs]
        
        let points = [point]
        
        let parameters: [String: Any] = ["ts": timestamp,
                                         "src": context.source,
                                         "sign": sign.md5.lowercased(),
                                         "pts": points]
        
        let url = ("\(context.host)/cn/v1.0/projects/\(context.appId)/app-dev-report/v1/report")
        
        let headers = ["x-agora-token": context.token,
                       "x-agora-uid": context.userUuid]

        log(info: "url: \(url)")
        log(info: "headers: \(headers)")
        log(info: "parameters: \(try! parameters.json())")
    
        httpSession.post(url,
                         parameters: parameters,
                         headers: headers,
                         progress: nil) { [weak self] (task, responseObject) in
            guard let strongSelf = self else {
                return
            }
            
            guard let _ = responseObject as? [String: Any] else {
                strongSelf.log(error: "josn parse error")
                return
            }
            
            strongSelf.log(info: "request success: \(responseObject.debugDescription)")
        } failure: { [weak self] (task, error) in
            guard let strongSelf = self else {
                return
            }
            
            strongSelf.log(error: "request fail: \(error.localizedDescription)")
        }
    }
    
    func htttpRequestV2(eventId: Int,
                        payload: String) {
        guard let context = self.contextV2 else {
            fatalError("call ‘setV2(context: AgoraReportorContext)’ before")
        }
        
        let timestamp = Date().timestamp()
        let signString = "payload=\(payload)&src=\(context.source)&ts=\(timestamp)"
        let sign = signString.md5.lowercased()
        
        let parameters: [String: Any] = ["id": eventId,
                                         "payload": payload,
                                         "qos": 1,
                                         "sign": sign,
                                         "src": context.source,
                                         "ts": timestamp]
        let url = context.host
        
        httpSession.post(url,
                         parameters: parameters,
                         headers: nil,
                         progress: nil) { [weak self] (task, responseObject) in
            guard let strongSelf = self else {
                return
            }
            
            strongSelf.log(info: "success: \(responseObject.debugDescription)")
        } failure: { [weak self] (task, error) in
            guard let strongSelf = self else {
                return
            }
            
            strongSelf.log(error: "fail: \(error.localizedDescription)")
        }
    }
}

private extension AgoraReportor {
    func log(info: String) {
        logTube?.reportor(self,
                          didOutputInfo: info)
    }
    
    func log(error: String) {
        logTube?.reportor(self,
                          didOutputError: error)
    }
}

fileprivate extension Date {
    func timestamp() -> Int64 {
        return Int64(timeIntervalSince1970 * 1000)
    }
}

fileprivate extension String {
    var md5: String {
        let utf8 = cString(using: .utf8)
        var digest = [UInt8](repeating: 0,
                             count: Int(CC_MD5_DIGEST_LENGTH))
        CC_MD5(utf8,
               CC_LONG(utf8!.count - 1),
               &digest)
        return digest.reduce("") { $0 + String(format:"%02X", $1) }
    }
}

fileprivate extension Dictionary {
    func json() throws -> String {
        let data = try JSONSerialization.data(withJSONObject: self,
                                              options: [])
        guard let string = String(data: data,
                                  encoding: String.Encoding.utf8) else {
            fatalError()
        }
        
        return string
    }
}
