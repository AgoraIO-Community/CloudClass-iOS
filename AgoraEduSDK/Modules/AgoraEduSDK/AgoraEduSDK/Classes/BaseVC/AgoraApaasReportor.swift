//
//  AgoraApaasReportor.swift
//  AgoraEduSDK
//
//  Created by Cavan on 2021/2/11.
//

import AgoraReport
import AgoraEduSDK.AgoraEduSDKFiles.AgoraProtocolBuf

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

@objcMembers public class AgoraApaasReportor: AgoraReportor,
                                              AgoraApaasReportorEventTube {
    @objc public func startJoinRoomNotificate() {
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
    
    func localUserJoin() {
        guard let context = contextV2 else {
            return
        }
        
        let eventId = 9012
        let payload = AgoraApaasUserJoin()
        
        payload.lts = Date().timestamp()
        payload.vid = context.vid
        payload.ver = context.version
        payload.scenario = context.scenario
        payload.errorCode = 0
        payload.uid = context.userUuid;
        payload.userName = context.userName;
        payload.streamUid = Int64(context.streamUuid)!
        payload.streamSuid = context.streamUuid
        payload.role = context.userRole
        payload.streamSid = context.streamSessionId
        payload.roomId = context.roomUuid
        payload.rtmSid = context.rtmSid
        payload.roomCreateTs = context.roomCreatTs
        
        guard let payloadString = payload.data()?.base64EncodedString() else {
            return
        }
        
        pointEvent(eventId: eventId,
                   payload: payloadString)
    }
    
    func localUserLeave() {
        guard let context = contextV2 else {
            return
        }
        
        let eventId = 9013
        let payload = AgoraApaasUserLeave()
        
        payload.lts = Date().timestamp()
        payload.vid = context.vid
        payload.ver = context.version
        payload.scenario = context.scenario
        payload.errorCode = 0
        payload.uid = context.userUuid;
        payload.userName = context.userName;
        payload.streamUid = Int64(context.streamUuid) ?? 0
        payload.streamSuid = context.streamUuid
        payload.role = context.userRole
        payload.streamSid = context.streamSessionId
        payload.roomId = context.roomUuid
        payload.roomCreateTs = context.roomCreatTs
        
        guard let payloadString = payload.data()?.base64EncodedString() else {
            return
        }
        
        pointEvent(eventId: eventId,
                   payload: payloadString)
    }
    
    func localUserReconnect() {
        guard let context = contextV2 else {
            return
        }
        
        let eventId = 9014
        let payload = AgoraApaasUserReconnect()
        
        payload.lts = Date().timestamp()
        payload.vid = context.vid
        payload.ver = context.version
        payload.scenario = context.scenario
        payload.errorCode = 0
        payload.uid = context.userUuid;
        payload.userName = context.userName;
        payload.streamUid = Int64(context.streamUuid)!
        payload.streamSuid = context.streamUuid
        payload.role = context.userRole
        payload.streamSid = context.streamSessionId
        payload.roomId = context.roomUuid
        payload.roomCreateTs = context.roomCreatTs
        
        guard let payloadString = payload.data()?.base64EncodedString() else {
            return
        }
        
        pointEvent(eventId: eventId,
                   payload: payloadString)
    }
}

fileprivate extension Date {
    func timestamp() -> Int64 {
        return Int64(timeIntervalSince1970 * 1000)
    }
}

@objc public class ApaasReporterWrapper: NSObject {
    public static let apaasShared = AgoraApaasReportor()
    
    @objc public class func getApaasReportor() -> AgoraReportor {
        return apaasShared
    }
    
    @objc public class func startJoinRoom() {
        apaasShared.startJoinRoom()
    }
    
    @objc public class func endJoinRoom(errorCode: Int,
                                        httpCode: Int) {
        apaasShared.endJoinRoom(errorCode: errorCode,
                                httpCode: httpCode)
    }
    
    @objc public class func startJoinRoomSubEvent(subEvent: String) {
        apaasShared.startJoinRoomSubEvent(subEvent: subEvent)
    }
    
    @objc public class func endJoinRoomSubEvent(subEvent: String,
                                                type: AgoraReportEndCategory,
                                                errorCode: Int,
                                                api: String?) {
        apaasShared.endJoinRoomSubEvent(subEvent: subEvent,
                                        type: type,
                                        errorCode: errorCode,
                                        api: api)
    }
    
    @objc public class func endJoinRoomSubEvent(subEvent: String,
                                                type: AgoraReportEndCategory,
                                                errorCode: Int,
                                                httpCode: Int,
                                                api: String?) {
        apaasShared.endJoinRoomSubEvent(subEvent: subEvent,
                                        type: type,
                                        errorCode: errorCode,
                                        httpCode: httpCode,
                                        api: api)
    }
    
    @objc public class func localUserJoin() {
        apaasShared.localUserJoin()
    }
    
    @objc public class func localUserLeave() {
        apaasShared.localUserLeave()
    }
    
    @objc public class func localUserReconnect() {
        apaasShared.localUserReconnect()
    }
}
