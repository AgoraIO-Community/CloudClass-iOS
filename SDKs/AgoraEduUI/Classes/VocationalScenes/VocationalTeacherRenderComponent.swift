//
//  VocationalTeacherRenderController.swift
//  AgoraEduUI
//
//  Created by DoubleCircle on 2022/5/7.
//

import AgoraUIBaseViews
import AgoraEduContext

class VocationalTeacherRenderComponent: VocationalRenderMembersUIComponent {
    private let teacherIndex = 0
    
    override init(context: AgoraEduContextPool,
                  delegate: AgoraRenderUIComponentDelegate?,
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
        contextPool.media.registerMediaEventHandler(self)
    }
    
    override func createAllRender() {
        guard dataSource.count == 1 else {
            return
        }
        
        let teacherInfo = userController.getUserList(role: .teacher)?.first
        
        let teacherModel = makeModel(userId: teacherInfo?.userUuid ?? "",
                                     role: .teacher)
        let newView = AgoraRenderMemberView(frame: .zero)
        dataSource[teacherIndex] = teacherModel
        viewsMap[teacherModel.userId] = newView
        setViewWithModel(view: newView,
                         model: teacherModel)
        
        super.createAllRender()
    }
    
    // viewWillInactive
    override func unregisterHandlers() {
        super.unregisterHandlers()

        userController.unregisterUserEventHandler(self)
    }
}

// MARK: - AgoraEduUserHandler
extension VocationalTeacherRenderComponent: AgoraEduUserHandler {
    func onRemoteUserJoined(user: AgoraEduContextUserInfo) {
        guard user.userRole == .teacher else {
            return
        }
        // remake model
        dataSource[teacherIndex].userId = user.userUuid
        viewsMap[user.userUuid] = AgoraRenderMemberView(frame: .zero)
        
        updateModel(userId: user.userUuid)
    }
    
    func onRemoteUserLeft(user: AgoraEduContextUserInfo,
                          operatorUser: AgoraEduContextUserInfo?,
                          reason: AgoraEduContextUserLeaveReason) {
        guard user.userRole == .teacher,
              let model = dataSource.first(where: {$0.userId == user.userUuid}) else {
            return
        }
        dataSource[teacherIndex].userId = ""
        
        viewsMap.removeValue(forKey: user.userUuid)
        updateModel(userId: "")
    }
}

// MARK: - private
private extension VocationalTeacherRenderComponent {
    func setBaseDataSource() {
        maxCount = 1
        
        var models = [AgoraRenderMemberViewModel]()
        let localInfo = contextPool.user.getLocalUserInfo()
        let localStream = contextPool.stream.getStreamList(userUuid: localInfo.userUuid)?.first(where: {$0.videoSourceType == .camera})

        switch localInfo.userRole {
        case .teacher:
            models.append(AgoraRenderMemberViewModel.model(user: localInfo,
                                                           stream: localStream))
        default:
            models.append(AgoraRenderMemberViewModel.defaultNilValue(role: .teacher))
        }

        self.dataSource = models
    }
}
