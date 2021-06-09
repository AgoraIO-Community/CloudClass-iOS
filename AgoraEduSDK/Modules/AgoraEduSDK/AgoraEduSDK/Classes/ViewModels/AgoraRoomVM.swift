//
//  AgoraRoomVM.swift
//  AgoraEduSDK
//
//  Created by SRS on 2021/3/12.
//  Copyright © 2021 Agora. All rights reserved.
//

import EduSDK
import AgoraUIEduBaseViews
import AgoraEduContext
import AgoraEduSDK.AgoraEduSDKFiles

@objcMembers public class AgoraRoomVM: AgoraBaseVM {
    public var classOverBlock: (() -> Void)?
    private var hasSignalReconnect: Bool = false
    private var hasClassOver: Bool = false
    
    // time
    public var timerToastBlock: ((_ message: String) -> Void)?
    public var updateTimerBlock: ((_ timerString: String) -> Void)?
    private var hasStop: Bool = false
    private var timer: DispatchSourceTimer?

    public func joinClassroom(successBlock: @escaping (_ userInfo: AgoraRTELocalUser) -> Void,
                              failureBlock: @escaping (_ error: AgoraEduContextError) -> Void) {
        AgoraEduManager.share().joinClassroom(with: self.config.sceneType,
                                              userName: self.config.userName) { [weak self] in
            guard let `self` = self else {
                return
            }
            
            self.hasSignalReconnect = false
            let roomManager = AgoraEduManager.share().roomManager
            roomManager?.getLocalUser(success: { [weak self] (userInfo) in
                successBlock(userInfo)
                self?.startTimer()
                self?.updateTime()
            }, failure: { [weak self] (error) in
                if let err = self?.kitError(error) {
                    failureBlock(err)
                }
            })
        } failure: { [weak self] (error) in
            if let err = self?.kitError(error) {
                failureBlock(err)
            }
        }
    }
    
    public func getClassState(successBlock: @escaping (_ state: AgoraEduContextClassState) -> Void,
                              failureBlock: @escaping (_ error: AgoraEduContextError) -> Void) {
        // 教室关闭
        if self.hasClassOver {
            successBlock(AgoraEduContextClassState.close)
            return
        }
        
        AgoraEduManager.share().roomManager?.getClassroomInfo(success: { (classroom) in
            switch classroom.roomState.courseState {
            case .start:
                successBlock(AgoraEduContextClassState.start)
            case .stop:
                successBlock(AgoraEduContextClassState.end)
            case .default:
                successBlock(AgoraEduContextClassState.default)
            @unknown default:
                successBlock(AgoraEduContextClassState.default)
            }
        }, failure: { [weak self] (error) in
            if let err = self?.kitError(error) {
                failureBlock(err)
            }
        })
    }
    
    public func getConnectionState(_ state: AgoraRTEConnectionState) -> AgoraEduContextConnectionState {
        switch state {
        case .aborted:
            return AgoraEduContextConnectionState.aborted
        case .connected:
            return AgoraEduContextConnectionState.connected
        case .connecting:
            return AgoraEduContextConnectionState.connecting
        case .disconnected:
            return AgoraEduContextConnectionState.disconnected
        case .reconnecting:
            return AgoraEduContextConnectionState.reconnecting
        default:
            break
        }
        return AgoraEduContextConnectionState.connected
    }
    
    public func getNetworkQuality(_ state: AgoraRTENetworkQuality) -> AgoraEduContextNetworkQuality {
        switch state {
        case .high:
            return AgoraEduContextNetworkQuality.good
        case .low:
            return AgoraEduContextNetworkQuality.bad
        case .middle:
            return AgoraEduContextNetworkQuality.medium
        case .unknown:
            return AgoraEduContextNetworkQuality.unknown
        default:
            break
        }
        return AgoraEduContextNetworkQuality.good
    }

    public func isReconnected(_ state: AgoraRTEConnectionState) -> Bool {
        if (state == .aborted) {
           
        } else if(state == .connected) {
            if(self.hasSignalReconnect) {
                self.hasSignalReconnect = false
                return true
            }
        } else if(state == .reconnecting) {
            self.hasSignalReconnect = true
        }
        return false
    }
    
    public func getRoomMuteChat(successBlock: @escaping (_ muteChat: Bool) -> Void,
                                failureBlock: @escaping (_ error: AgoraEduContextError) -> Void) {
        AgoraEduManager.share().roomManager?.getClassroomInfo(success: { (room) in
            let muteChat = !room.roomState.isStudentChatAllowed
            successBlock(muteChat)
        }, failure: {[weak self] (error) in
            if let err = self?.kitError(error) {
                failureBlock(err)
            }
        })
    }

    deinit {
        self.stopTimer()
    }
}

// MARK: - Timer
private extension AgoraRoomVM {
    func updateTime(successBlock: (() -> Void)? = nil,
                    failureBlock: ((_ error: AgoraEduContextError) -> Void)? = nil) {
        AgoraEduManager.share().roomManager?.getClassroomInfo(success: {[weak self] (room) in
            guard let `self` = self,
                  let roomStateInfoModel = AgoraManagerCache.share().roomStateInfoModel as? AgoraRoomStateInfoModel else {
                return
            }
            
            roomStateInfoModel.state = room.roomState.courseState.rawValue
            let state = AgoraRTECourseState(rawValue: roomStateInfoModel.state)
            let closeDelay = roomStateInfoModel.closeDelay
            
            let interval = Date().timeIntervalSince1970 * 1000
            let currentRealTime = Int64(interval - Double(AgoraManagerCache.share().differTime))

            let startTime = Int64(roomStateInfoModel.startTime)
            
            var time: Int = 0
            if state == AgoraRTECourseState.default {
                time = Int(Double((startTime - currentRealTime)) * 0.001)
                if time < 0 {
                    time = 0
                }
            } else if state == AgoraRTECourseState.start {
                time = Int(Double((currentRealTime - startTime)) * 0.001)
                if time < 0 {
                    time = 0
                }
                
                if roomStateInfoModel.duration - time == 5 * 60 {
                    // 5分钟
                    let strStart = self.localizedString("ClassEndWarningStartText")
                    let strMidden = "5"
                    let strEnd = self.localizedString("ClassEndWarningEndText")
                    
                    // 课程还有5分钟结束
                    self.timerToastBlock?(strStart + strMidden + strEnd)
                }
            } else if state == AgoraRTECourseState.stop {
                
                time = Int(Double((currentRealTime - startTime)) * 0.001)
                if time < 0 {
                    time = 0
                }
                
                let countdown = closeDelay + roomStateInfoModel.duration - time
                
                if countdown == 60 {
                    let strStart = self.localizedString("ClassCloseWarningStart2Text")
                    let strEnd = self.localizedString("ClassCloseWarningEnd2Text")
                    let strMidden = "\(1)"
                    let str = strStart + strMidden + strEnd
                    self.timerToastBlock?(str)
                }
                
                if countdown <= 0 {
                    self.hasClassOver = true
                    self.classOverBlock?()
                    return
                }
                
                if !self.hasStop {
                    self.hasStop = true
                    
                    // 还有几分钟关闭
                    let strStart = self.localizedString("ClassCloseWarningStartText")
                    let strEnd = self.localizedString("ClassCloseWarningEndText")
                    
                    let hours: Int = closeDelay / 3600
                    let seconds: Int = closeDelay % 60
                    let minutes: Int = (closeDelay - 3600 * hours) / 60
                
                    var ranges: [NSRange] = []
                    
                    var string = strStart
                    if hours > 0 {
                        ranges.append(NSMakeRange(string.count, "\(hours)".count))
                        
                        let hoursStr = String(format:"%d", hours) + self.localizedString("ClassTimeHourText")
                        string = string + hoursStr
                    }
                    if minutes > 0 {
                        ranges.append(NSMakeRange(string.count, "\(minutes)".count))
                        
                        let minutesStr = String(format:"%d", minutes) + (seconds == 0 ? self.localizedString("ClassTimeMinute2Text") : self.localizedString("ClassTimeMinuteText"))
                        string = string + minutesStr
                    }
                    if seconds > 0 {
                        ranges.append(NSMakeRange(string.count, "\(seconds)".count))
                        
                        let secondsStr = String(format:"%d", seconds) + self.localizedString("ClassTimeSecondText")
                        string = string + secondsStr
                    }
                    
                    // 还有5分钟关闭
                    self.timerToastBlock?(string + strEnd)
                }
            }

            let hours: Int = time / 3600
            let hoursStr = String(format:"%.2d", hours) + self.localizedString("ClassTimeHourText") + ""
            let minutes: Int = (time - 3600 * hours) / 60
            let minutesStr = String(format:"%.2d", minutes) + self.localizedString("ClassTimeMinuteText") + ""
            let seconds: Int = time % 60
            let secondsStr = String(format:"%.2d", seconds) + self.localizedString("ClassTimeSecondText")
            var string  = "\(hoursStr)\(minutesStr)\(secondsStr)"
            if hours == 0 {
                string  = "\(minutesStr)\(secondsStr)"
            }
            
            var timeString = ""
            switch state {
            case .start:
                timeString = "\(self.localizedString("ClassAfterStartText"))\(string)"
            case .stop:
                timeString = "\(self.localizedString("ClassAfterStopText"))\(string)"
            default:
                timeString = "\(self.localizedString("ClassBeforeStartText"))\(string)"
            }
            
            // 距离开始或者已经开始 5分钟
            self.updateTimerBlock?(timeString)

        }, failure: {[weak self] (error) in
            if let err = self?.kitError(error) {
                failureBlock?(err)
            }
        })
    }
    
    func startTimer() {
        self.stopTimer()

        timer = DispatchSource.makeTimerSource(flags: [], queue: DispatchQueue.global())
        timer?.schedule(deadline: .now() + 1, repeating: 1)
        timer?.setEventHandler {[weak self] in
            
            DispatchQueue.main.async {
                self?.updateTime()
            }
        }
        timer?.resume()
    }
    
    func stopTimer() {
        if !(timer?.isCancelled ?? true) {
            timer?.cancel()
        }
    }
}

// HTTP
extension AgoraRoomVM {
    public func updateRoomProperties(_ properties: [String: String],
                                     cause: [String: String]?,
                                     successBlock: @escaping () -> Void,
                                     failureBlock: @escaping (_ error: AgoraEduContextError) -> Void) {

        let baseURL = AgoraHTTPManager.getBaseURL()
        var url = "\(baseURL)/edu/apps/\(config.appId)/v2/rooms/\(config.roomUuid)/properties"
        let headers = AgoraHTTPManager.headers(withUId: config.userUuid, userToken: "", token: config.token)
        var parameters = [String: Any]()
        parameters["properties"] = properties
        if let causeParameters = cause {
            parameters["cause"] = causeParameters
        }

        AgoraHTTPManager.fetchDispatch(.put,
                                       url: url,
                                       parameters: parameters,
                                       headers: headers,
                                       parseClass: AgoraBaseModel.self) { [weak self] (any) in
            guard let `self` = self else {
                return
            }

            if let model = any as? AgoraBaseModel, model.code == 0 {
                successBlock()
            } else {
//                failureBlock("network error")
            }
            
        } failure: {[weak self] (error, code) in
            if let `self` = self {
                failureBlock(self.kitError(error))
            }
        }
    }
}

