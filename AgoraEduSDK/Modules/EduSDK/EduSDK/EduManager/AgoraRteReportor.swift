//
//  AgoraRteReportor.swift
//  EduSDK
//
//  Created by Cavan on 2021/2/11.
//  Copyright © 2021 agora. All rights reserved.
//

import AgoraReport

// MARK: - Event key
fileprivate let AgoraRTEEventKeyJoinScene = "joinRoom"
fileprivate let AgoraRTEEventKeyLogin = "init"
fileprivate let AgoraRTEEventKeyTimerOnline = "online_user"

fileprivate struct AgoraRTETimerEventItem {
    var event: String
    var initTimestamp: Int
    var timeInterval: Int
}

public class AgoraRteReportor: AgoraReportor {
    public static let rteShared = AgoraRteReportor()
    
    private lazy var timer = AgoraSubThreadTimer(threadName: "io.agora.timer.event",
                                                 timeInterval: 1.0)
    
    private var timerEvents = [String: AgoraRTETimerEventItem]() { // event, AgoraRTETimerEventItem
        didSet {
            if timerEvents.keys.count > 0 {
                timer.start()
            } else {
                timer.stop()
            }
        }
    }
}



public extension AgoraRteReportor {
    func startLogin() {
        let event = AgoraRTEEventKeyLogin
        start(event: event)
    }
    
    func endLogin(errorCode: Int) {
        let event = AgoraRTEEventKeyLogin
        end(event: event,
            type: .rtm,
            errorCode: errorCode,
            httpCode: nil)
    }
}

public extension AgoraRteReportor {
    func startJoinRoom() {
        let event = AgoraRTEEventKeyJoinScene
        start(event: event)

        processEventHttpRequest(event: event,
                                category: "start",
                                count: 1)
    }
    
    func endJoinRoom(errorCode: Int, httpCode: Int) {
        let event = AgoraRTEEventKeyJoinScene
        end(event: event,
            type: .end,
            errorCode: errorCode,
            httpCode: httpCode)
    }
    
    func startJoinRoomSubEvent(subEvent: String) {
        let event = AgoraRTEEventKeyJoinScene
        start(event: event,
              subEvent: subEvent)
    }
    
    func endJoinRoomSubEvent(subEvent: String,
                             type: AgoraReportEndCategory,
                             errorCode: Int,
                             api: String?) {
        let event = AgoraRTEEventKeyJoinScene
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
                             api: String?) {
        let event = AgoraRTEEventKeyJoinScene
        end(event: event,
            subEvent: subEvent,
            type: type,
            errorCode: errorCode,
            httpCode: httpCode,
            api: api)
    }
}

public extension AgoraRteReportor {
    func startTimerOnline() {
        let event = AgoraRTEEventKeyTimerOnline
        let item = AgoraRTETimerEventItem(event: event,
                                       initTimestamp: Date().agora_rte_timestamp(),
                                       timeInterval: 10 * 1000)
        timerEvents[event] = item
        timer.delegate = self
    }
    
    func stopTimerOnline() {
        let event = AgoraRTEEventKeyTimerOnline
        timerEvents.removeValue(forKey: event)
    }
}

extension AgoraRteReportor: AgoraSubThreadTimerDelegate {
    
    public func perLoop() {
        let current = Date().agora_rte_timestamp()
        for (event, item) in timerEvents {
            let interval = current - item.initTimestamp
            let value = Int(interval % item.timeInterval)
            
            // 1000 ms
            guard value <= 1000 else {
                continue
            }
            timerEventHttpRequest(event: event,
                                  count: 1)
        }
    }
}

fileprivate extension Date {
    func agora_rte_timestamp() -> Int {
        return Int(timeIntervalSince1970 * 1000)
    }
}
