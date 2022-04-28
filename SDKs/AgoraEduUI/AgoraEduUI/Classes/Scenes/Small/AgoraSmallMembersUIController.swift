//
//  AgoraSmallMembersUIController.swift
//  AgoraEduUI
//
//  Created by DoubleCircle on 2022/4/26.
//

import AgoraEduContext
import AgoraUIBaseViews
import Foundation

class AgoraSmallMembersUIController: AgoraRenderMembersUIController {
    private var teacherModel: AgoraRenderMemberViewModel? {
        willSet {
            if let new = newValue {
                handleMedia(model: new)
            } else if let streamId = teacherModel?.streamId {
                contextPool.media.stopRenderVideo(roomUuid: roomId,
                                                  streamUuid: streamId)
                contextPool.media.stopPlayAudio(roomUuid: roomId,
                                                streamUuid: streamId)
            }
        }
    }
    private var teacherView: AgoraRenderMemberView?
    
    override func viewWillActive() {
        contextPool.group.registerGroupEventHandler(self)
        super.viewWillActive()
        let localUserId = userController.getLocalUserInfo().userUuid
        if let teacher = userController.getUserList(role: .teacher)?.first,
           let subRoomList = contextPool.group.getSubRoomList() {
            var renderTeacher = false
            if let list = streamController.getStreamList(userUuid: teacher.userUuid),
               list.count > 0 {
                renderTeacher = true
            }
            
            if renderTeacher {
                // 老师在小组内
                let stream = streamController.getStreamList(userUuid: teacher.userUuid)?.first(where: {$0.videoSourceType == .camera})
                teacherModel = AgoraRenderMemberViewModel.model(user: teacher,
                                                                stream: stream)
            }
        }
    }
    
    override func viewWillInactive() {
        contextPool.group.unregisterGroupEventHandler(self)
        super.viewWillInactive()
    }
    
    override func getRenderViewForUser(with userId: String) -> UIView? {
        if teacherModel?.userId == userId {
            return teacherView
        } else {
            return super.getRenderViewForUser(with: userId)
        }
    }
    
    override func setRenderEnable(with userId: String,
                                  rendEnable: Bool) {
        if let model = self.teacherModel,
           model.userId == userId {
            self.teacherModel?.userState = .window
        } else {
            super.setRenderEnable(with: userId,
                                  rendEnable: rendEnable)
        }
    }
    
    override func updateStream(stream: AgoraEduContextStreamInfo?) {
        if let model = teacherModel,
           stream?.owner.userUuid == model.userId {
            teacherModel = makeModel(userId: model.userId,
                                     windowFlag: (model.userState == .window))
        } else {
            super.updateStream(stream: stream)
        }
    }
}

// MARK: - AgoraEduGroupHandler
extension AgoraSmallMembersUIController: AgoraEduGroupHandler {
    func onUserListAddedToSubRoom(userList: Array<String>,
                                  subRoomUuid: String,
                                  operatorUser: AgoraEduContextUserInfo?) {
        // 学生加入子房间会走coHost
        guard subRoom == nil,
              let teacherId = userController.getUserList(role: .teacher)?.first?.userUuid,
              userList.contains(teacherId) else {
            return
        }
        // 老师未开启大窗
        teacherModel = nil
    }
    
    func onUserListRemovedFromSubRoom(userList: Array<AgoraEduContextSubRoomRemovedUserEvent>,
                                      subRoomUuid: String) {
        guard subRoom == nil,
              let teacherId = contextPool.user.getUserList(role: .teacher)?.first?.userUuid,
              userList.contains(where: {$0.userUuid == teacherId}) else {
            return
        }
        setTeacherModel()
    }
    
    func onGroupInfoUpdated(groupInfo: AgoraEduContextGroupInfo) {
        guard !groupInfo.state else {
            return
        }
        setTeacherModel()
    }
}

// MARK: - AgoraEduUserHandler
extension AgoraSmallMembersUIController {
    override func onRemoteUserJoined(user: AgoraEduContextUserInfo) {
        guard user.userRole == .teacher else {
            return
        }
        let stream = contextPool.stream.getStreamList(userUuid: user.userUuid)?.first(where: {$0.videoSourceType == .camera})
        self.teacherModel = AgoraRenderMemberViewModel.model(user: user,
                                                             stream: stream,
                                                             windowFlag: false)
    }
    
    override func onRemoteUserLeft(user: AgoraEduContextUserInfo,
                          operatorUser: AgoraEduContextUserInfo?,
                          reason: AgoraEduContextUserLeaveReason) {
        if user.userRole == .teacher {
            self.teacherModel = nil
        }
    }
}

// MARK: - AgoraEduMediaHandler
extension AgoraSmallMembersUIController {
    override func onVolumeUpdated(volume: Int,
                                  streamUuid: String) {
        super.onVolumeUpdated(volume: volume,
                              streamUuid: streamUuid)
        
        guard let model = teacherModel,
              model.streamId == streamUuid,
              let view = teacherView else {
            return
        }
        view.updateVolume(volume)
    }
}

// MARK: - private
private extension AgoraSmallMembersUIController {
    func setTeacherModel() {
        guard teacherModel == nil,
              let teacherInfo = contextPool.user.getUserList(role: .teacher)?.first else {
            return
        }
        let windowActive = !widgetController.getAllWidgetActivity().keys.contains(where: {$0.contains(kWindowWidgetId)})
        let windowContains = windowArr.contains(teacherInfo.userUuid)
        let stream = contextPool.stream.getStreamList(userUuid: teacherInfo.userUuid)?.first(where: {$0.videoSourceType == .camera})
        self.teacherModel = AgoraRenderMemberViewModel.model(user: teacherInfo,
                                                             stream: stream,
                                                             windowFlag: (windowActive && windowContains))
    }
}
