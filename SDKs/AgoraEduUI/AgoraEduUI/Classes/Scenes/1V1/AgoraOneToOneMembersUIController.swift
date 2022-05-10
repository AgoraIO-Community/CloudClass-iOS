//
//  AgoraOneToOneMembersUIController.swift
//  AgoraEduUI
//
//  Created by DoubleCircle on 2022/5/7.
//

import AgoraUIBaseViews
import AgoraEduContext

class AgoraOneToOneMembersUIController: AgoraRenderMembersUIController {
    private let teacherIndex = 0
    private let studentIndex = 0
    
    override init(context: AgoraEduContextPool,
                  delegate: AgoraRenderUIControllerDelegate?,
                  subRoom: AgoraEduSubRoomContext? = nil,
                  expandFlag: Bool = false) {
        super.init(context: context,
                   delegate: delegate,
                   subRoom: subRoom,
                   expandFlag: expandFlag)
        setBaseDataSource()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // viewWillActive
    override func registerHandlers() {
        super.registerHandlers()
        
        userController.registerUserEventHandler(self)
    }
    
    override func createAllRender() {
        guard dataSource.count == 2,
              dataSource.contains(where: {$0.userRole == .teacher}),
              dataSource.contains(where: {$0.userRole == .student}) else {
            return
        }
        
        let teacherInfo = userController.getUserList(role: .teacher)?.first
        let studentInfo = userController.getUserList(role: .student)?.first
        
        for (i, model) in dataSource.enumerated() {
            if model.userRole == .teacher {
                let model = makeModel(userId: teacherInfo?.userUuid ?? "",
                                      role: .teacher)
                let newView = AgoraRenderMemberView(frame: .zero)
                dataSource[i] = model
                viewsMap[model.userId] = newView
                setViewWithModel(view: newView,
                                 model: model)
            }
            
            if model.userRole == .student {
                let model = makeModel(userId: studentInfo?.userUuid ?? "",
                                      role: .student)
                let newView = AgoraRenderMemberView(frame: .zero)
                dataSource[i] = model
                viewsMap[model.userId] = newView
                setViewWithModel(view: newView,
                                 model: model)
            }
        }
        
        super.createAllRender()
    }
    
    // viewWillInactive
    override func unregisterHandlers() {
        super.unregisterHandlers()
        widgetController.remove(self)
        userController.unregisterUserEventHandler(self)
        streamController.unregisterStreamEventHandler(self)
        contextPool.media.unregisterMediaEventHandler(self)
    }
}

extension AgoraOneToOneMembersUIController {
    
}
// MARK: - AgoraEduUserHandler
extension AgoraOneToOneMembersUIController: AgoraEduUserHandler {
    func onRemoteUserJoined(user: AgoraEduContextUserInfo) {
        switch user.userRole {
        case .teacher:
            dataSource[teacherIndex].userId = user.userUuid
        case .student:
            dataSource[studentIndex].userId = user.userUuid
        default:
            return
        }

        viewsMap[user.userUuid] = AgoraRenderMemberView(frame: .zero)
        
        updateModel(userId: user.userUuid)
    }
    
    func onRemoteUserLeft(user: AgoraEduContextUserInfo,
                          operatorUser: AgoraEduContextUserInfo?,
                          reason: AgoraEduContextUserLeaveReason) {
        switch user.userRole {
        case .teacher:
            dataSource[teacherIndex].userId = ""
        case .student:
            dataSource[studentIndex].userId = ""
        default:
            return
        }
        
        viewsMap.removeValue(forKey: user.userUuid)
        updateModel(userId: "")
    }
}

// MARK: - private
private extension AgoraOneToOneMembersUIController {
    func setBaseDataSource() {
        maxCount = 2
        
        var models = [AgoraRenderMemberViewModel]()
        let localInfo = contextPool.user.getLocalUserInfo()
        let localStream = contextPool.stream.getStreamList(userUuid: localInfo.userUuid)?.first(where: {$0.videoSourceType == .camera})
        if localInfo.userRole == .student {
            models.append(AgoraRenderMemberViewModel.defaultNilValue(role: .teacher))
            models.append(AgoraRenderMemberViewModel.model(user: localInfo,
                                                           stream: localStream))
        } else {
            models.append(AgoraRenderMemberViewModel.model(user: localInfo,
                                                           stream: localStream))
            models.append(AgoraRenderMemberViewModel.defaultNilValue(role: .student))
        }
        self.dataSource = models
    }
}
