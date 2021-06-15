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
    var source: String
    var clientType: String
    var platform: String
    var appId: String
    var version: String
    var token: String
    var userUuid: String
    var region: String
    
    @objc public init(source: String,
                      clientType: String,
                      platform: String,
                      appId: String,
                      version: String,
                      token: String,
                      userUuid: String,
                      region: String) {
        self.source = source
        self.clientType = clientType
        self.platform = platform
        self.appId = appId
        self.version = version
        self.token = token
        self.userUuid = userUuid
        self.region = region
    }
}

@objcMembers open class AgoraReportor: NSObject {
    
    static let Tag = "AgoraReportor"
    
    public var BASE_URL = "https://api.agora.io"
    private lazy var httpSession: AFHTTPSessionManager = {
        let session = AFHTTPSessionManager()
        session.requestSerializer = AFJSONRequestSerializer()
        session.requestSerializer.timeoutInterval = 10
        session.responseSerializer = AFJSONResponseSerializer()
        return session
    }()
    
    private var context: AgoraReportorContext?
    
    // Duration event
    private var startEvents = [String: Int64]()
    private var startSubEvents = [String: Int64]()
    
    private let startEvnetsMaxCount = 10000
    
    public func set(context: AgoraReportorContext) {
        self.context = context
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
            ls["result"] = tHttpCode == 200 ? "1" : "0"
        }
        if let tErrorCode = errorCode {
            ls["errCode"] = String(tErrorCode)
            ls["result"] = tErrorCode == 0 ? "1" : "0"
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
                                         "sign": sign.agora_md5.lowercased(),
                                         "pts": points]
        
        let url = ("\(BASE_URL)/\(context.region)/v1.0/projects/\(context.appId)/app-dev-report/v1/report")
        
        let headers = ["x-agora-token" : context.token, "x-agora-uid" : context.userUuid]

        #if AGORADEBUG
        print("\(AgoraReportor.Tag) url:\(url)")
        print("\(AgoraReportor.Tag) headers:\(headers)")
        print("\(AgoraReportor.Tag) parameters:\(try! parameters.agora_json())")
        #endif
    
        httpSession.post(url,
                         parameters: parameters,
                         headers: headers,
                         progress: nil) { (task, responseObject) in
            
            #if AGORADEBUG
            guard let _ = responseObject as? [String: Any] else {
                print("\(AgoraReportor.Tag) failure: josn parse error")
                return
            }
            print("\(AgoraReportor.Tag) success:\(responseObject.debugDescription)")
            #endif
        } failure: { (task, error) in
            #if AGORADEBUG
            print("\(AgoraReportor.Tag) failure:\(error.localizedDescription)")
            #endif
        }
    }
}

fileprivate extension Date {
    func timestamp() -> Int64 {
        return Int64(timeIntervalSince1970 * 1000)
    }
}

fileprivate extension String {
    var agora_md5: String {
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
    func agora_json() throws -> String {
        let data = try JSONSerialization.data(withJSONObject: self,
                                              options: [])
        guard let string = String(data: data,
                                  encoding: String.Encoding.utf8) else {
            fatalError()
        }
        
        return string
    }
}
