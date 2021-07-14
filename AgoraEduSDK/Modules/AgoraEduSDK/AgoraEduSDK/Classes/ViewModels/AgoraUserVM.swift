//
//  AgoraUserVM.swift
//  AgoraEduSDK
//
//  Created by SRS on 2021/3/12.
//  Copyright © 2021 Agora. All rights reserved.
//

import EduSDK
import AgoraUIEduBaseViews
import AgoraEduContext

@objc public enum AgoraInfoChangeType: Int {
    case add, update, remove
}

// 学生名单信息
struct AgoraStudentInfo {
    var reward: Int = 0
    var name: String = ""
}

@objcMembers public class AgoraDeviceStreamState: NSObject {
    public var camera: AgoraRTEStreamState = .frozen
    public var microphone: AgoraRTEStreamState = .frozen
}

@objcMembers public class AgoraUserVM: AgoraBaseVM {
    // only online users
    public var kitUserInfos: [AgoraEduContextUserDetailInfo] = []
    // online & offline students
    public var kitCoHostInfos: [AgoraEduContextUserDetailInfo] = []
    
    // 白板状态
    fileprivate var usersBoardGranted: [String] = []
    
    public func getContextBaseUserInfo(_ rteUser: AgoraRTEBaseUser) -> AgoraEduContextUserInfo {
        
        if let kitUserInfo = self.kitUserInfos.first(where: {$0.user.userUuid == rteUser.userUuid}) {
            return kitUserInfo.user
        }
        
        let userInfo = AgoraEduContextUserInfo()
        userInfo.role = AgoraEduContextUserRole(rawValue: rteUser.role.rawValue) ?? .student
        userInfo.userUuid = rteUser.userUuid
        userInfo.userName = rteUser.userName
        return userInfo
    }
    public func getContextDetailUserInfo(_ rteUser: AgoraRTEUser) -> AgoraEduContextUserDetailInfo {
        if let kitUserInfo = self.kitUserInfos.first(where: {$0.user.userUuid == rteUser.userUuid}) {
            return kitUserInfo
        }
        
        return self.getKitUserInfo(rteUser, nil)
    }
    
    // 获取用户设备状态block
    public var userDeviceStateBlock: ((_ deviceType: AgoraDeviceStateType,
                                       _ rteUser: AgoraRTEUser,
                                       _ rteStream: AgoraRTEStream?) -> AgoraEduContextDeviceState)?

    public var localBaseUserInfo: AgoraEduContextUserInfo {
        let userInfo = AgoraEduContextUserInfo()
        
        if let info = localUserInfo {
            userInfo.userUuid = info.userUuid
            userInfo.userName = info.userName
            
            if let userProperties = info.userProperties["flexProps"] as? [String: String] {
                userInfo.userProperties = userProperties
            }
        }
        
        return userInfo
    }
    
    public override init(config: AgoraVMConfig) {
        super.init(config: config)
    }
    
    public func updateUserMuteChat(_ userUuid: String, muteChat: Bool) {
         
        if let userInfo = self.kitUserInfos.first(where: {$0.user.userUuid == userUuid} ) {
            userInfo.enableChat = !muteChat
        }
        
        if let userInfo = self.kitCoHostInfos.first(where: {$0.user.userUuid == userUuid} ) {
            userInfo.enableChat = !muteChat
        }
    }

    public func updateUsersBoardGranted(_ userUuids: [String], completeBlock: @escaping () -> Void) {
         
        self.usersBoardGranted = userUuids
        
        self.kitUserInfos.forEach { (userDetailInfo) in
            userDetailInfo.boardGranted = false
            let userUuid = userDetailInfo.user.userUuid
            if userUuids.contains(userUuid) {
                userDetailInfo.boardGranted = true
            }
        }
        
        self.kitCoHostInfos.forEach { (userDetailInfo) in
            userDetailInfo.boardGranted = false
            let userUuid = userDetailInfo.user.userUuid
            if userUuids.contains(userUuid) {
                userDetailInfo.boardGranted = true
            }
        }
        
        completeBlock()
    }
    
    public func updateLocalAudioStream(_ muteAudio: Bool,
                                       successBlock: @escaping (_ stream: AgoraRTEStream) -> Void,
                                       failureBlock: @escaping (_ error: AgoraEduContextError) -> Void) {
        self.updateLocalStream(muteAudio,
                               muteVideo: nil,
                               successBlock: successBlock) { [weak self] (error) in
            if let err = self?.kitError(error) {
                failureBlock(err)
            }
        }
    }
    public func updateLocalVideoStream(_ muteVideo: Bool,
                                       successBlock: @escaping (_ stream: AgoraRTEStream) -> Void,
                                       failureBlock: @escaping (_ error: AgoraEduContextError) -> Void) {
        self.updateLocalStream(nil,
                               muteVideo: muteVideo,
                               successBlock: successBlock) { [weak self] (error) in
            if let err = self?.kitError(error) {
                failureBlock(err)
            }
        }
    }
    
    // MARK: Init Data
    public func initKitUserInfos(_ successBlock: @escaping () -> Void,
                                 failureBlock: @escaping (_ error: AgoraEduContextError) -> Void) {
        self.getKitUserList { [weak self] in
            guard let `self` = self else {
                return
            }
            
            successBlock()
            
        } failureBlock: { (error) in
            failureBlock(error)
        }
    }

    public func getStreamInfo(streamUuid: String,
                              successBlock: @escaping (_ stream: AgoraRTEStream) -> Void,
                              failureBlock: @escaping (_ error: AgoraEduContextError) -> Void) {
        AgoraEduManager.share().roomManager?.getFullStreamList(success: { (streamInfos) in
            
            if let stream = streamInfos.first(where: { (streamInfo) -> Bool in
                streamInfo.streamUuid == streamUuid
            }) {
                successBlock(stream)
            }
            
        }, failure: {[weak self] (error) in
            if let err = self?.kitError(error) {
                failureBlock(err)
            }
        })
    }
    
    // MARK: UserList--RoomProperty
    public func getChangedRewards(cause: Any?) -> [String: AgoraEduContextUserDetailInfo] {
        
        guard let `cause` = cause as? Dictionary<String, Any>,
              let cmd = cause["cmd"] as? Int,
              let causeCmd = AgoraCauseType(rawValue: cmd),
              let data = cause["data"] as? [String: Any],
              causeCmd == .reward else {
            return [:]
        }
        
        var userDetailInfos = [String: AgoraEduContextUserDetailInfo]()
        data.keys.forEach { (userUuid) in
            if let kitUserInfo = self.kitCoHostInfos.first(where: {userUuid == $0.user.userUuid} ) {
                userDetailInfos[userUuid] = kitUserInfo
            }
        }
        
        return userDetailInfos
    }
    
    public func updateKitUserList(onCoHosts: [String], offCoHosts: [String], successBlock: @escaping () -> Void, failureBlock: @escaping (_ error: AgoraEduContextError) -> Void) {

        // 上台数量发生变化
        AgoraEduManager.share().roomManager?.getFullUserList(success: {[weak self] (rteUsers) in
            
            var onRteHosts: [AgoraRTEUser] = []
            rteUsers.forEach { (rteUser) in
                if onCoHosts.contains(rteUser.userUuid) {
                    onRteHosts.append(rteUser)
                }
            }
            
            self?.updateKitCoHostList(downHostUserUuids: offCoHosts, upHostRteUsers: onRteHosts, successBlock: {
                successBlock()
            }, failureBlock: { (error) in
                failureBlock(error)
            })
            
        }, failure: {[weak self] (error) in
            if let err = self?.kitError(error) {
                failureBlock(err)
            }
        })
    }

    public func updateKitUserList(rewardUuids: [String], cause: Any, successBlock: @escaping () -> Void, failureBlock: @escaping (_ error: AgoraEduContextError) -> Void) {
                
        self.getAllStudentInfos { (studentInfos) in
            
            rewardUuids.forEach { (userUuid) in
                
                // 找到这个人
                let kitUserInfo = self.kitUserInfos.first { (kitUserInfo) -> Bool in
                    kitUserInfo.user.userUuid == userUuid
                }
                let kitCoHostInfo = self.kitCoHostInfos.first { (kitUserInfo) -> Bool in
                    kitUserInfo.user.userUuid == userUuid
                }
                
                if let studentInfo = studentInfos[userUuid] {
                    kitUserInfo?.rewardCount = studentInfo.reward
                    kitCoHostInfo?.rewardCount = studentInfo.reward
                }
            }
 
            successBlock()
            
        } failureBlock: { (error) in
            failureBlock(error)
        }
    }
    
    // 轮播
    public func updateCarouselUserList(successBlock: @escaping () -> Void,
                                       failureBlock: @escaping (_ error: AgoraEduContextError) -> Void) {
        // 重新初始化设置
        self.getKitUserList(successBlock: successBlock,
                            failureBlock: failureBlock)
    }

    // MARK: UserList
    public func getKitUserList(successBlock: @escaping () -> Void, failureBlock: @escaping (_ error: AgoraEduContextError) -> Void) {
 
        AgoraEduManager.share().roomManager?.getFullUserList(success: {[weak self] (rteUsers) in
            
            for rteUser in rteUsers {
                AgoraEduManager.share().logMessage("getKitUserList userUuid:\(rteUser.userUuid) userName:\(rteUser.userName) streamUuid:\(rteUser.streamUuid)", level: .warn)
            }
            
            self?.kitUserInfos.removeAll()
            self?.kitCoHostInfos.removeAll()
            self?.updateKitUserList(rteUsers: rteUsers, type: .add, successBlock: successBlock, failureBlock: failureBlock)
        }, failure: {[weak self] (error) in
            if let err = self?.kitError(error) {
                failureBlock(err)
            }
        })
    }
    public func updateKitUserList(rteUserEvents: [AgoraRTEUserEvent], type: AgoraInfoChangeType, successBlock: @escaping () -> Void, failureBlock: @escaping (_ error: AgoraEduContextError) -> Void) {
        var rteUsers: [AgoraRTEUser] = []
        for rteUserEvent in rteUserEvents {
            rteUsers.append(rteUserEvent.modifiedUser)
        }
        self.updateKitUserList(rteUsers: rteUsers, type: type, successBlock: successBlock, failureBlock: failureBlock)
    }
    public func updateKitUserList(rteUsers: [AgoraRTEUser], type: AgoraInfoChangeType, successBlock: @escaping () -> Void, failureBlock: @escaping (_ error: AgoraEduContextError) -> Void) {
        
        if type == .remove {
            
            self.kitUserInfos = self.kitUserInfos.filter { (userDetailInfo) -> Bool in
                let userUuid = userDetailInfo.user.userUuid
                
                if rteUsers.first(where: { (rteUser) -> Bool in
                    return rteUser.userUuid == userUuid
                }) != nil {
                    return false
                }
                
                return true
            }
            
            self.kitCoHostInfos.forEach { (userDetailInfo) in
                
                if rteUsers.first(where: { (rteUser) -> Bool in
                    return rteUser.userUuid == userDetailInfo.user.userUuid
                }) != nil {
                    userDetailInfo.onLine = false
                }
            }
            successBlock()
            return
        }
        
        // 所有流
        AgoraEduManager.share().roomManager?.getFullStreamList(success: {[weak self] (streamInfos) in
            guard let `self` = self else {
                return
            }
            // 所有人的奖励
            self.getAllStudentInfos {[weak self] (studentInfos) in
                guard let `self` = self else {
                    return
                }
                // 所有台上人的userUuid
                self.getAllCoHostUserUuids {[weak self] (userUuids) in
                    guard let `self` = self else {
                        return
                    }
                    
                    for rteUser in rteUsers {
                        AgoraEduManager.share().logMessage("updateKitUserList onLineRteUsers userUuid:\(rteUser.userUuid) userName:\(rteUser.userName) streamUuid:\(rteUser.streamUuid)", level: .warn)
                    }
                    for userUuid in userUuids {
                        AgoraEduManager.share().logMessage("updateKitUserList userUuids userUuid:\(userUuid)", level: .warn)
                    }
                    for rteStream in streamInfos {
                        AgoraEduManager.share().logMessage("updateKitUserList streamInfos userUuid:\(rteStream.userInfo.userUuid) userName:\(rteStream.userInfo.userName) streamUuid:\(rteStream.streamUuid)", level: .warn)
                    }
                    
                    let _ = self.updateUserListInfos(onLineRteUsers: rteUsers, coHostUserUuids: userUuids, rteStreams: streamInfos, studentInfos: studentInfos)
                    let _ = self.updateCoHostInfos(onLineRteUsers: rteUsers, coHostUserUuids: userUuids, rteStreams: streamInfos, studentInfos: studentInfos)
                    
                    successBlock()
                    
                } failureBlock: { (error) in
                    failureBlock(error)
                }
                
            } failureBlock: {(error) in
                failureBlock(error)
            }
            
        }, failure: {[weak self] (error) in
            if let err = self?.kitError(error) {
                failureBlock(err)
            }
        })
    }

    // MARK: CoHostList
    fileprivate func updateKitCoHostList(downHostUserUuids: [String], upHostRteUsers: [AgoraRTEUser], successBlock: @escaping () -> Void, failureBlock: @escaping (_ error: AgoraEduContextError) -> Void) {
    
        // userList
        downHostUserUuids.forEach {[weak self] (userUuid) in
            if let kitUserInfo = self?.kitUserInfos.first(where: { (kitUserInfo) -> Bool in
                return userUuid == kitUserInfo.user.userUuid
            }) {
                kitUserInfo.coHost = false
            }
        }

        var userUuids: [String] = []
        upHostRteUsers.forEach {[weak self] (rteUser) in
            if let kitUserInfo = self?.kitUserInfos.first(where: { (kitUserInfo) -> Bool in
                return rteUser.userUuid == kitUserInfo.user.userUuid
            }) {
                kitUserInfo.coHost = true
            }
            userUuids.append(rteUser.userUuid)
        }
        
        // userList
        self.kitCoHostInfos.removeAll { (userDetailInfo) -> Bool in
            let coUserUuid = userDetailInfo.user.userUuid
           
            if let _ = downHostUserUuids.first(where: { (userUuid) -> Bool in
                return userUuid == coUserUuid
            }) {
                return true
            }
            return false
        }
        
        // 处理上台
        // 所有流
        AgoraEduManager.share().roomManager?.getFullStreamList(success: {[weak self] (streamInfos) in
            guard let `self` = self else {
                return
            }
            // 所有人的奖励
            self.getAllStudentInfos {[weak self] (studentInfos) in
                guard let `self` = self else {
                    return
                }
                let infos = self.getCoHostInfos(onLineRteUsers: upHostRteUsers, coHostUserUuids: userUuids, rteStreams: streamInfos, studentInfos: studentInfos)
                self.kitCoHostInfos.append(contentsOf: infos)
                successBlock()
                
            } failureBlock: {(error) in
                failureBlock(error)
            }
            
        }, failure: {[weak self] (error) in
            if let err = self?.kitError(error) {
                failureBlock(err)
            }
        })
    }

    // MARK: StreamsChanged
    public func updateKitStreams(rteStreamEvents: [AgoraRTEStreamEvent], type: AgoraInfoChangeType, successBlock: @escaping () -> Void, failureBlock: @escaping (_ error: AgoraEduContextError) -> Void) {
        var rteStreams: [AgoraRTEStream] = []
        for rteStreamEvent in rteStreamEvents {
            rteStreams.append(rteStreamEvent.modifiedStream)
        }
        self.updateKitStreams(rteStreams: rteStreams, type: type, successBlock: successBlock, failureBlock: failureBlock)
    }
    public func updateKitStreams(rteStreams: [AgoraRTEStream], type: AgoraInfoChangeType, successBlock: @escaping () -> Void, failureBlock: @escaping (_ error: AgoraEduContextError) -> Void) {
        
        let `rteStreams` = rteStreams.filter{ $0.sourceType == .camera }
        if `rteStreams`.count == 0 {
            return
        }
        
        rteStreams.forEach {[weak self] (rteStream) in
            
            // 找到这个人
            let kitUserInfo = self?.kitUserInfos.first { (kitUserInfo) -> Bool in
                kitUserInfo.user.userUuid == rteStream.userInfo.userUuid
            }
            let kitCoHostInfo = self?.kitCoHostInfos.first { (kitUserInfo) -> Bool in
                kitUserInfo.user.userUuid == rteStream.userInfo.userUuid
            }
            kitUserInfo?.enableAudio = false
            kitUserInfo?.enableVideo = false
            kitCoHostInfo?.enableAudio = false
            kitCoHostInfo?.enableVideo = false
            
            if type != .remove {
                kitUserInfo?.enableAudio = rteStream.hasAudio
                kitUserInfo?.enableVideo = rteStream.hasVideo
                kitUserInfo?.streamUuid = rteStream.streamUuid
                kitCoHostInfo?.enableAudio = rteStream.hasAudio
                kitCoHostInfo?.enableVideo = rteStream.hasVideo
                
                AgoraEduManager.share().logMessage("updateKitStreams userUuid:\(kitUserInfo?.user.userUuid) userName:\(kitUserInfo?.user.userName) streamUuid:\(kitUserInfo?.streamUuid)", level: .warn)
            }
        }
        
        successBlock()
    }
    
    // MARK: DeviceChanged
    public func updateKitUserDevice(rteUser: AgoraRTEUser,
                                    cameraState: AgoraEduContextDeviceState,
                                    microState: AgoraEduContextDeviceState) {
        
        let kitUserInfo = self.kitUserInfos.first { (kitUserInfo) -> Bool in
            kitUserInfo.user.userUuid == rteUser.userUuid
        }
        let kitCoHostInfo = self.kitCoHostInfos.first { (kitUserInfo) -> Bool in
            kitUserInfo.user.userUuid == rteUser.userUuid
        }
        
        kitUserInfo?.cameraState = cameraState
        kitUserInfo?.microState = microState
        kitCoHostInfo?.cameraState = cameraState
        kitCoHostInfo?.microState = microState
    }
}

// MARK: PRIVATE
extension AgoraUserVM {
    fileprivate func updateKitUserDetailInfo(fhs: AgoraEduContextUserDetailInfo,
                                             ths: AgoraEduContextUserDetailInfo) {
        fhs.user = ths.user
        fhs.isSelf = ths.isSelf
        fhs.streamUuid = ths.streamUuid
        fhs.onLine = ths.onLine
        fhs.coHost = ths.coHost
        fhs.boardGranted = ths.boardGranted
        fhs.cameraState = ths.cameraState
        fhs.microState = ths.microState
        fhs.enableVideo = ths.enableVideo
        fhs.enableAudio = ths.enableAudio
        fhs.rewardCount = ths.rewardCount
    }
    
    fileprivate func updateCoHostInfos(onLineRteUsers: [AgoraRTEUser],
                                       coHostUserUuids: [String],
                                       rteStreams: [AgoraRTEStream],
                                       studentInfos: [String: AgoraStudentInfo]) -> [AgoraEduContextUserDetailInfo] {
        
        let coHostInfos = self.getCoHostInfos(onLineRteUsers: onLineRteUsers,
                                              coHostUserUuids: coHostUserUuids,
                                              rteStreams: rteStreams,
                                              studentInfos: studentInfos)

        coHostInfos.forEach { [weak self] (coHostInfo) in
            // 查找之前有没有了
            if let kitCoHostInfo = self?.kitCoHostInfos.first(where: { (kitCoHostInfo) -> Bool in
                return coHostInfo.user.userUuid == kitCoHostInfo.user.userUuid
            }) {
                self?.updateKitUserDetailInfo(fhs: kitCoHostInfo, ths: coHostInfo)
            } else {
                self?.kitCoHostInfos.append(coHostInfo)
            }
        }
        
        for coHostInfo in coHostInfos {
            AgoraEduManager.share().logMessage("updateCoHostInfos coHostInfos userUuid:\(coHostInfo.user.userUuid) userName:\(coHostInfo.user.userName) streamUuid:\(coHostInfo.streamUuid)", level: .warn)
        }
        
        return coHostInfos
    }
    fileprivate func getCoHostInfos(onLineRteUsers: [AgoraRTEUser],
                                    coHostUserUuids: [String],
                                    rteStreams: [AgoraRTEStream],
                                    studentInfos: [String: AgoraStudentInfo]) -> [AgoraEduContextUserDetailInfo] {
        var kitUserInfos = [AgoraEduContextUserDetailInfo]()
        for coHostUserUuid in coHostUserUuids {
            
            let rteStream = rteStreams.first(where: {$0.userInfo.userUuid == coHostUserUuid })
            
            var kitUserInfo: AgoraEduContextUserDetailInfo!
            
            if let onLineRteUser = onLineRteUsers.first(where: { (onLineRteUser) -> Bool in
                onLineRteUser.userUuid == coHostUserUuid
            }) {
                // 查看是否在线
                kitUserInfo = self.getKitUserInfo(onLineRteUser, rteStream)
                kitUserInfo.onLine = true
                
            } else if let kitCoHostInfo = self.kitCoHostInfos.first(where: { (kitCoHostInfo) -> Bool in
                kitCoHostInfo.user.userUuid == coHostUserUuid
            }) {
                continue
                
            } else {
                // 不在线， 找不到
                let rteUser = AgoraRTEUser(userUuid: coHostUserUuid, streamUuid: "")
                rteUser.userName = studentInfos[coHostUserUuid]?.name ?? ""
                kitUserInfo = self.getKitUserInfo(rteUser, rteStream)
                kitUserInfo.onLine = false
            }
            
            kitUserInfo.rewardCount = studentInfos[coHostUserUuid]?.reward ?? 0
            kitUserInfo.enableVideo = false
            kitUserInfo.enableAudio = false
            kitUserInfo.coHost = true
            if kitUserInfo.streamUuid == "" {
                // TODO： 后台获取数据
            }
            
            if let rteStream = rteStream {
                kitUserInfo.enableVideo = rteStream.hasVideo
                kitUserInfo.enableAudio = rteStream.hasAudio
            }
            
            kitUserInfos.append(kitUserInfo)
        }
        
        for kitUserInfo in kitUserInfos {
            AgoraEduManager.share().logMessage("getCoHostInfos coHostInfos userUuid:\(kitUserInfo.user.userUuid) userName:\(kitUserInfo.user.userName) streamUuid:\(kitUserInfo.streamUuid)", level: .warn)
        }
        
        return kitUserInfos
    }
    
    // 人员变化了更新
    fileprivate func updateUserListInfos(onLineRteUsers: [AgoraRTEUser],
                                         coHostUserUuids: [String],
                                         rteStreams: [AgoraRTEStream],
                                         studentInfos: [String: AgoraStudentInfo]) -> [AgoraEduContextUserDetailInfo] {
        // userList
        let onLineInfos = self.getUserListInfos(onLineRteUsers: onLineRteUsers,
                                                coHostUserUuids: coHostUserUuids,
                                                rteStreams: rteStreams,
                                                studentInfos: studentInfos)

        onLineInfos.forEach {[weak self] (onLineInfo) in
            // 查找之前有没有了
            if let kitUserInfo = self?.kitUserInfos.first(where: { (kitUserInfo) -> Bool in
                return onLineInfo.user.userUuid == kitUserInfo.user.userUuid
            }) {
                self?.updateKitUserDetailInfo(fhs: kitUserInfo,
                                              ths: onLineInfo)
            } else {
                self?.kitUserInfos.append(onLineInfo)
            }
        }
        return onLineInfos
    }
    
    fileprivate func getUserListInfos(onLineRteUsers: [AgoraRTEUser],
                                      coHostUserUuids: [String],
                                      rteStreams: [AgoraRTEStream],
                                      studentInfos: [String: AgoraStudentInfo]) -> [AgoraEduContextUserDetailInfo] {
        
        var kitUserInfos = [AgoraEduContextUserDetailInfo]()
        for onLineRteUser in onLineRteUsers {
            
            let rteStream = rteStreams.first(where: {$0.userInfo.userUuid == onLineRteUser.userUuid })
            
            let kitUserInfo = self.getKitUserInfo(onLineRteUser,
                                                  rteStream)
            kitUserInfo.onLine = true
            kitUserInfo.enableVideo = false
            kitUserInfo.enableAudio = false
            kitUserInfo.coHost = false
            kitUserInfo.rewardCount = studentInfos[onLineRteUser.userUuid]?.reward ?? 0
   
            if let rteStream = rteStream {
                kitUserInfo.enableVideo = rteStream.hasVideo
                kitUserInfo.enableAudio = rteStream.hasAudio
            }
            
            let userUuid = kitUserInfo.user.userUuid
            
            if self.config.sceneType == .type1V1 ||  coHostUserUuids.contains(userUuid) {
                kitUserInfo.coHost = true
            }

            kitUserInfos.append(kitUserInfo)
        }
        
        for kitUserInfo in kitUserInfos {
            AgoraEduManager.share().logMessage("getUserListInfos kitUserInfo userUuid:\(kitUserInfo.user.userUuid) userName:\(kitUserInfo.user.userName) streamUuid:\(kitUserInfo.streamUuid)", level: .warn)
        }
        
        return kitUserInfos
    }
    
    fileprivate func getKitUserInfo(_ rteUser: AgoraRTEUser, _ rteStream: AgoraRTEStream?) -> AgoraEduContextUserDetailInfo {
        
        let user = self.kitUserInfo(rteUser)
        let kitUserInfo = AgoraEduContextUserDetailInfo(user: user)
        kitUserInfo.isSelf = rteUser.userUuid == self.config.userUuid
        kitUserInfo.streamUuid = rteUser.streamUuid

        AgoraEduManager.share().logMessage("getKitUserInfo userUuid:\(rteUser.userUuid) userName:\(rteUser.userName) streamUuid:\(rteUser.streamUuid)", level: .warn)
        
        kitUserInfo.cameraState = self.getUserDeviceState(.camera,
                                                          rteUser: rteUser,
                                                          rteStream: rteStream)
        kitUserInfo.microState = self.getUserDeviceState(.microphone,
                                                         rteUser: rteUser,
                                                         rteStream: rteStream)
        
        kitUserInfo.enableChat = true
        if let userProperties = rteUser.userProperties as? [String: Any],
           let mute = userProperties["mute"] as? [String: Any],
           let muteChat = mute["muteChat"] as? Int {
            kitUserInfo.enableChat = muteChat == 0 ? true : false
        }
        
        if self.usersBoardGranted.contains(rteUser.userUuid) {
            kitUserInfo.boardGranted = true
        } else {
            kitUserInfo.boardGranted = false
        }
        return kitUserInfo
    }
    
    fileprivate func getAllStudentInfos(successBlock: @escaping (_ studentInfos: [String: AgoraStudentInfo]) -> Void,
                                        failureBlock: @escaping (_ error: AgoraEduContextError) -> Void) {
        AgoraEduManager.share().roomManager?.getClassroomInfo(success: { (room) in

            guard let properties = room.roomProperties as? Dictionary<String, Any>,
                  let students = properties["students"] as? Dictionary<String, Any> else {
                successBlock([:])
                return
            }

            var studentInfos: [String: AgoraStudentInfo] = [:]
            for userUuid in students.keys {
                if let info = students[userUuid] as? Dictionary<String, Any>,
                   let reward = info["reward"] as? Int,
                   let name = info["name"] as? String {
                    let studentInfo = AgoraStudentInfo(reward: reward, name: name)
                    studentInfos[userUuid] = studentInfo
                }
            }
            successBlock(studentInfos)

        }, failure: {[weak self] (error) in
            if let err = self?.kitError(error) {
                failureBlock(err)
            }
        })
    }
    
    fileprivate func getAllCoHostUserUuids(successBlock: @escaping (_ coHosts: [String]) -> Void,
                                           failureBlock: @escaping (_ error: AgoraEduContextError) -> Void) {
        AgoraEduManager.share().roomManager?.getClassroomInfo(success: { (room) in

            guard let properties = room.roomProperties as? Dictionary<String, Any>,
                  let processes = properties["processes"] as? Dictionary<String, Any>,
                  let handsUp = processes["handsUp"] as? Dictionary<String, Any>,
                  let coVideos = handsUp["accepted"] as? [Dictionary<String, String>] else {
                
                successBlock([])
                return
            }
            
            var users: [String] = []
            coVideos.forEach { (dic) in
                if let userUuid = dic["userUuid"] {
                    users.append(userUuid)
                }
            }
            successBlock(users)

        }, failure: {[weak self] (error) in
            if let err = self?.kitError(error) {
                failureBlock(err)
            }
        })
    }
    
    fileprivate func getUserDeviceState(_ type: AgoraDeviceStateType,
                                        rteUser: AgoraRTEUser,
                                        rteStream: AgoraRTEStream?) -> AgoraEduContextDeviceState {
        return self.userDeviceStateBlock?(type, rteUser, rteStream) ?? AgoraEduContextDeviceState.available
    }
    
    fileprivate func updateLocalStream(_ muteAudio: Bool?,
                                       muteVideo: Bool?,
                                       enablePublish: Bool = true,
                                       successBlock: @escaping (_ stream: AgoraRTEStream) -> Void,
                                       failureBlock: @escaping (_ error: Error) -> Void) {
        AgoraEduManager.share().roomManager?.getLocalUser(success: {[weak self] (localUser) in
            
            self?.localUserInfo = localUser
            
            var hasAudio = localUser.streams.first?.hasAudio ?? false
            if let `muteAudio` = muteAudio {
                hasAudio = !muteAudio
            }
            var hasVideo = localUser.streams.first?.hasVideo ?? false
            if let muteVideo = muteVideo {
                hasVideo = !muteVideo
            }
            
            let config = AgoraRTEStreamConfig(streamUuid: localUser.streamUuid)
            config.streamName = ""
            config.enableCamera = hasVideo
            config.enableMicrophone = hasAudio
            AgoraEduManager.share().studentService?.startOrUpdateLocalStream(config, success: { (stream) in
                
                if enablePublish {
                    AgoraEduManager.share().studentService?.publishStream(stream, success: {
                        
                        successBlock(stream)
                        
                    }, failure: { (error) in
                        failureBlock(error)
                    })
                } else {
                    successBlock(stream)
                }
            }, failure: { (error) in
                failureBlock(error)
            })
        }, failure: { (error) in
            failureBlock(error)
        })
    }
}

// MARK: TipMessage
extension AgoraUserVM {
    public func updateLocalStream(_ event: AgoraRTEStreamEvent,
                                  type: AgoraInfoChangeType) {
        if type == .add || type == .update {
            self.localUserInfo?.streams = [event.modifiedStream]
        } else {
            self.localUserInfo?.streams = []
        }
    }
    
    public func getStreamTipMessage(_ event: AgoraRTEStreamEvent) -> String? {
        if event.operatorUser?.userUuid == self.config.userUuid {
            return nil
        }

        if let originStream = self.localUserInfo?.streams.first {
            if originStream.hasAudio != event.modifiedStream.hasAudio {
                let toastMsg = event.modifiedStream.hasAudio ? self.localizedString("MicrophoneUnMuteText") : self.localizedString("MicrophoneMuteText")
                return toastMsg
            }
            if originStream.hasVideo != event.modifiedStream.hasVideo {
                let toastMsg = event.modifiedStream.hasVideo ? self.localizedString("CameraUnMuteText") : self.localizedString("CameraMuteText")
                return toastMsg
            }
        }
        return nil
    }
}

// MARK: Flex Props
extension AgoraUserVM {
    // Property changed
    public func isFlexPropsChanged(cause: Any?) -> Bool {
        
        guard let `cause` = cause as? Dictionary<String, Any>,
              let cmd = cause["cmd"] as? Int,
              let causeCmd = AgoraCauseType(rawValue: cmd),
              causeCmd == .flexPropsChanged else {
            return false
        }
        
        return true
    }
    
    public func updateUserProperties(_ userUuid: String,
                                     properties: [String: String],
                                     cause: [String: String]?,
                                     successBlock: @escaping () -> Void,
                                     failureBlock: @escaping (_ error: AgoraEduContextError) -> Void) {
        
        let baseURL = AgoraHTTPManager.getBaseURL()
        var url = "\(baseURL)/edu/apps/\(config.appId)/v2/rooms/\(config.roomUuid)/users/\(userUuid)/properties"
  
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
