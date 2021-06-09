//
//  AgoraPrivateChatVM.swift
//  AgoraEduSDK
//
//  Created by SRS on 2021/4/9.
//  Copyright © 2021 Agora. All rights reserved.
//

import Foundation
import AgoraUIEduBaseViews
import AgoraEduContext
import EduSDK
import AgoraEduSDK.AgoraEduSDKFiles

@objcMembers public class AgoraPrivateChatVM: AgoraBaseVM {
    
    public var kitPrivateChatInfo: AgoraEduContextPrivateChatInfo?
    
    private var subscribeStreams = [AgoraRTEStream]()
    private var unsubscribeStreams = [AgoraRTEStream]()
    
    // MARK:
    public func updatePrivateChat(cause: Any?, successBlock: @escaping () -> Void, failureBlock: @escaping (_ error: AgoraEduContextError) -> Void) {

        guard let `cause` = cause as? Dictionary<String, Any>,
              let data = try? JSONSerialization.data(withJSONObject: cause, options: []) else {
            return
        }

        guard let state = try? JSONDecoder().decode(AgoraPrivateChat.self, from: data),
           state.cmd == .streamGroupsAdd || state.cmd == .streamGroupsDel else {
            return
        }

        self.initPrivateChat(successBlock, failureBlock: failureBlock)
    }
    
    public func initPrivateChat(_ successBlock: @escaping () -> Void, failureBlock: @escaping (_ error: AgoraEduContextError) -> Void) {

        AgoraEduManager.share().roomManager?.getClassroomInfo(success: {(rteRoom) in

            AgoraEduManager.share().roomManager?.getFullUserList(success: { (rteUsers) in

                AgoraEduManager.share().roomManager?.getFullStreamList(success: {[weak self] (rteStreams) in

                    guard let `self` = self else {
                        return
                    }

                    self.initKitPrivateChatInfo(rteRoom, rteUsers: rteUsers, rteStreams: rteStreams)

                    successBlock()

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
        }, failure: {[weak self] (error) in
            if let err = self?.kitError(error) {
                failureBlock(err)
            }
        })
    }
}

// MARK: HTTP
extension AgoraPrivateChatVM {
    public func updatePrivateChat(toUserUuid: String?, successBlock: @escaping () -> Void, failureBlock: @escaping (_ error: AgoraEduContextError) -> Void) {
        
        let baseURL = AgoraHTTPManager.getBaseURL()
        let headers = AgoraHTTPManager.headers(withUId: config.userUuid, userToken: "", token: config.token)

        var userUuid: String = ""
        var type: HttpType = .put

        if let toUserUuid = toUserUuid {
            // 建立
            type = .put
            userUuid = toUserUuid
        } else if let toUserUuid = self.kitPrivateChatInfo?.toUser.userUuid {
            // 移除
            type = .delete
            userUuid = toUserUuid
        } else {
            let error = AgoraEduContextError(code: 99, message: "cannot find private chat")
            failureBlock(error)
            return
        }

        let url = "\(baseURL)/edu/apps/\(config.appId)/v2/rooms/\(config.roomUuid)/users/\(userUuid)/privateSpeech"

        let parameters = [String:Any]()
        AgoraHTTPManager.fetchDispatch(type, url: url, parameters: parameters, headers: headers, parseClass: AgoraBaseModel.self) {[weak self] (any) in

            guard let `self` = self else {
                return
            }

            successBlock()

        } failure: {[weak self] (error, code) in
            if let `self` = self {
                failureBlock(self.kitError(error))
            }
        }
    }
}

// MARK: Subscribe
extension AgoraPrivateChatVM {
    // 更新流订阅
    func addRemoteStream(_ rteStream: AgoraRTEStream, successBlock: (() -> Void)? = nil, failureBlock: ((_ error: AgoraEduContextError) -> Void)? = nil) {

        let localUserUuid = self.config.userUuid
        let userUuid = rteStream.userInfo.userUuid
        let fUserUuid = self.kitPrivateChatInfo?.fromUser.userUuid
        let tUserUuid = self.kitPrivateChatInfo?.toUser.userUuid

        // 如果是自己，不需要订阅
        if userUuid == localUserUuid {
            return
        }

        // 没有私聊， 需要订阅
        if fUserUuid == nil || tUserUuid == nil {
            self.subscribeStream(rteStream)
            self.subscribeStreams.append(rteStream)
            return
        }

        // 私聊里面没有我， 来的流在里面=》不订阅，否则订阅
        if fUserUuid != localUserUuid && tUserUuid != localUserUuid {

            if userUuid == fUserUuid || userUuid == tUserUuid {
                self.unsubscribeStream(rteStream)
                self.unsubscribeStreams.append(rteStream)
            } else {
                self.subscribeStream(rteStream)
                self.subscribeStreams.append(rteStream)
            }
            return
        }

        // 私聊里面有我， 来的流在里面=》订阅，否则不订阅
        if fUserUuid == localUserUuid || tUserUuid == localUserUuid {

            if userUuid == fUserUuid || userUuid == tUserUuid {
                self.subscribeStream(rteStream)
                self.subscribeStreams.append(rteStream)
            } else {
                self.unsubscribeStream(rteStream)
                self.unsubscribeStreams.append(rteStream)
            }
            return
        }

    }

    func updateAllSubscribeStreams() {
        
        let localUserUuid = self.config.userUuid
        let fUserUuid = self.kitPrivateChatInfo?.fromUser.userUuid
        let tUserUuid = self.kitPrivateChatInfo?.toUser.userUuid
        
        // 没有私聊， 全部订阅
        if fUserUuid == nil || tUserUuid == nil {
            for rteStream in self.unsubscribeStreams {
                self.subscribeStream(rteStream)
            }
            self.subscribeStreams.append(contentsOf: self.unsubscribeStreams)
            self.unsubscribeStreams.removeAll()
            return
        }
        
        // 私聊里面没有我， 只订阅非私聊的流
        if fUserUuid != localUserUuid && tUserUuid != localUserUuid {
            
            let rmvStreams = self.subscribeStreams.filter({
                $0.userInfo.userUuid == fUserUuid ||
                $0.userInfo.userUuid == tUserUuid
            })
            
            let addStreams = self.unsubscribeStreams.filter({
                $0.userInfo.userUuid != fUserUuid &&
                $0.userInfo.userUuid != tUserUuid
            })
            
            for rteStream in rmvStreams {
                self.unsubscribeStream(rteStream)
            }
            for rteStream in addStreams {
                self.subscribeStream(rteStream)
            }
            self.subscribeStreams.removeAll(where: {rmvStreams.contains($0)})
            self.unsubscribeStreams.removeAll(where: {addStreams.contains($0)})
            self.subscribeStreams.append(contentsOf: addStreams)
            self.unsubscribeStreams.append(contentsOf: rmvStreams)
            return
        }
        
        // 私聊里面有我， 只订阅私聊的流
        if fUserUuid == localUserUuid || tUserUuid == localUserUuid {
            
            let rmvStreams = self.subscribeStreams.filter({
                $0.userInfo.userUuid != fUserUuid &&
                $0.userInfo.userUuid != tUserUuid
            })
            
            let addStreams = self.unsubscribeStreams.filter({
                $0.userInfo.userUuid == fUserUuid ||
                $0.userInfo.userUuid == tUserUuid
            })
            
            for rteStream in rmvStreams {
                self.unsubscribeStream(rteStream)
            }
            for rteStream in addStreams {
                self.subscribeStream(rteStream)
            }
            self.subscribeStreams.removeAll(where: {rmvStreams.contains($0)})
            self.unsubscribeStreams.removeAll(where: {addStreams.contains($0)})
            self.subscribeStreams.append(contentsOf: addStreams)
            self.unsubscribeStreams.append(contentsOf: rmvStreams)
            return
        }
    }
    
    private func subscribeStream(_ stream: AgoraRTEStream, successBlock: (() -> Void)? = nil, failureBlock: ((_ error: AgoraEduContextError) -> Void)? = nil) {
        let options = AgoraRTESubscribeOptions()
        options.subscribeAudio = true
        options.subscribeVideo = true
        options.videoStreamType = .low
        if stream.sourceType == .screen {
            options.videoStreamType = .high
        }
        AgoraEduManager.share().studentService?.subscribeStream(stream, options: options, success: {
            successBlock?()
        }, failure: {[weak self] (error) in
            if let err = self?.kitError(error) {
                failureBlock?(err)
            }
        })
    }
    
    private func unsubscribeStream(_ stream: AgoraRTEStream, successBlock: (() -> Void)? = nil, failureBlock: ((_ error: AgoraEduContextError) -> Void)? = nil) {
        let options = AgoraRTESubscribeOptions()
        options.subscribeAudio = false
        options.subscribeVideo = true
        options.videoStreamType = .low
        if stream.sourceType == .screen {
            options.videoStreamType = .high
        }
        AgoraEduManager.share().studentService?.unsubscribeStream(stream, options: options, success: {
            successBlock?()
        }, failure: {[weak self] (error) in
            if let err = self?.kitError(error) {
                failureBlock?(err)
            }
        })
    }
}

//// MARK: Private
extension AgoraPrivateChatVM {
    private func initKitPrivateChatInfo(_ rteRoom: AgoraRTEClassroom, rteUsers: [AgoraRTEUser], rteStreams: [AgoraRTEStream]) {

        self.kitPrivateChatInfo = nil

        guard let streamGroups = rteRoom.roomProperties["streamGroups"] as? Dictionary<String, Any>,
            let key = streamGroups.keys.first,
            let value = streamGroups[key] as? Dictionary<String, Any>,
            let data = try? JSONSerialization.data(withJSONObject: value, options: []),
            let privateChatInfo = try? JSONDecoder().decode(AgoraPrivateChatInfo.self, from: data) else {

            self.updateAllSubscribeStreams()
            return
        }

        guard privateChatInfo.users.count <= 2 else {
            self.updateAllSubscribeStreams()
            return
        }

        var fromUser: AgoraEduContextUserInfo?
        var toUser: AgoraEduContextUserInfo?
        for rteUser in rteUsers {
            if rteUser.userUuid == privateChatInfo.users[0].userUuid {
                fromUser = self.kitUserInfo(rteUser)

            } else if rteUser.userUuid == privateChatInfo.users[1].userUuid {
                toUser = self.kitUserInfo(rteUser)
            }
        }

        guard let fUser = fromUser, let tUser = toUser else {
            self.updateAllSubscribeStreams()
            return
        }

        self.kitPrivateChatInfo = AgoraEduContextPrivateChatInfo(fromUser: fUser, toUser: tUser)

        self.updateAllSubscribeStreams()
    }
}
