//
//  AgoraApaasReportor.swift
//  AgoraEduSDK
//
//  Created by Cavan on 2021/2/11.
//

import AgoraReport

// MARK: - Event key
fileprivate let AgoraEventKeyEntryRoom = "joinRoom"

@objc public protocol AgoraApaasReportorEventTube: NSObjectProtocol {
    func startJoinRoomNotificate()
    func endJoinRoomNotificate(errorCode: Int)
    func endJoinRoomNotificate(errorCode: Int,
                          httpCode: Int)
    
    func startJoinRoomSubEventNotificate(subEvent: String)
    func endJoinRoomSubEventNotificate(subEvent: String,
                                       type: AgoraReportEndCategory,
                                       errorCode: Int,
                                       api: String?)
    func endJoinRoomSubEventNotificate(subEvent: String,
                                       type: AgoraReportEndCategory,
                                       errorCode: Int,
                                       httpCode: Int,
                                       api: String?)
}

@objcMembers public class AgoraApaasReportor: AgoraReportor {
    public static let apaasShared = AgoraApaasReportor()
}

public extension AgoraApaasReportor {
    func startJoinRoom() {
        let event = AgoraEventKeyEntryRoom
        start(event: event)
        
        processEventHttpRequest(event: event,
                                category: "start",
                                count: 1)
    }
    
    func endJoinRoom(errorCode: Int) {
        let event = AgoraEventKeyEntryRoom
        end(event: event,
            type: .end,
            errorCode: errorCode,
            httpCode: nil)
    }
    
    func endJoinRoom(errorCode: Int,
                     httpCode: Int) {
        let event = AgoraEventKeyEntryRoom
        end(event: event,
            type: .end,
            errorCode: errorCode,
            httpCode: httpCode)
    }
    
    func startJoinRoomSubEvent(subEvent: String) {
        let event = AgoraEventKeyEntryRoom
        start(event: event,
              subEvent: subEvent)
    }
    
    func endJoinRoomSubEvent(subEvent: String,
                             type: AgoraReportEndCategory,
                             errorCode: Int,
                             api: String? = nil) {
        let event = AgoraEventKeyEntryRoom
        end(event: event,
            subEvent: subEvent,
            type: type,
            errorCode: errorCode,
            httpCode: nil,
            api: api)
    }
    
    func endJoinRoomSubEvent(subEvent: String,
                             type: AgoraReportEndCategory,
                             errorCode: Int,
                             httpCode: Int,
                             api: String? = nil) {
        let event = AgoraEventKeyEntryRoom
        end(event: event,
            subEvent: subEvent,
            type: type,
            errorCode: errorCode,
            httpCode: httpCode,
            api: api)
    }
}

extension AgoraApaasReportor: AgoraApaasReportorEventTube {
    public func startJoinRoomNotificate() {
        startJoinRoom()
    }
    
    public func endJoinRoomNotificate(errorCode: Int) {
        endJoinRoom(errorCode: errorCode)
    }
    
    public func endJoinRoomNotificate(errorCode: Int,
                                      httpCode: Int) {
        endJoinRoom(errorCode: errorCode,
                    httpCode: httpCode)
    }
    
    public func startJoinRoomSubEventNotificate(subEvent: String) {
        startJoinRoomSubEvent(subEvent: subEvent)
    }
    
    public func endJoinRoomSubEventNotificate(subEvent: String,
                                              type: AgoraReportEndCategory,
                                              errorCode: Int,
                                              api: String?) {
        endJoinRoomSubEvent(subEvent: subEvent,
                            type: type,
                            errorCode: errorCode,
                            api: api)
    }
    
    public func endJoinRoomSubEventNotificate(subEvent: String,
                                              type: AgoraReportEndCategory,
                                              errorCode: Int,
                                              httpCode: Int,
                                              api: String?) {
        endJoinRoomSubEvent(subEvent: subEvent,
                            type: type,
                            errorCode: errorCode,
                            httpCode: httpCode,
                            api: api)
    }
}
