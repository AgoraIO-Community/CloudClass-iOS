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
        didSet {
            teacherView.isHidden = (teacherModel == nil)
            if let model = teacherModel {
                setViewWithModel(view: teacherView,
                                 model: model)
            }
            updateViewFrame()
        }
    }
    private lazy var teacherView = AgoraRenderMemberView(frame: .zero)
    
    override init(context: AgoraEduContextPool,
                  delegate: AgoraRenderUIControllerDelegate?,
                  subRoom: AgoraEduSubRoomContext? = nil,
                  expandFlag: Bool = false) {
        super.init(context: context,
                   delegate: delegate,
                   subRoom: subRoom,
                   expandFlag: expandFlag)
        self.maxCount = 6
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // viewWillActive
    override func registerHandlers() {
        super.registerHandlers()
        
        userController.registerUserEventHandler(self)
        contextPool.group.registerGroupEventHandler(self)
    }
    
    override func createAllRender() {
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
        
        if let students = userController.getCoHostList()?.filter({$0.userRole == .student}) {
            let userList = students.map({return $0.userUuid})
            addModels(userList: userList)
        }
        
        super.createAllRender()
    }
    
    // viewWillInactive
    override func unregisterHandlers() {
        super.unregisterHandlers()

        userController.unregisterUserEventHandler(self)
        contextPool.group.unregisterGroupEventHandler(self)
    }
    
    override func releaseAllRender() {
        teacherModel = nil
        super.releaseAllRender()
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
            if !rendEnable {
                windowList.append(userId)
            } else {
                windowList.removeAll(userId)
            }
            updateModel(userId: userId)
        } else {
            super.setRenderEnable(with: userId,
                                  rendEnable: rendEnable)
        }
    }
    
    override func updateModel(userId: String) {
        if let model = teacherModel,
           model.userId == userId {
            teacherModel = makeModel(userId: model.userId)
        } else {
            super.updateModel(userId: userId)
        }
    }
    
    override func updateViewFrame() {
        let sigleWidth = (layout.scrollDirection == .horizontal) ? layout.itemSize.width : layout.itemSize.height
        let kItemGap = layout.minimumLineSpacing
        
        let teacherWidth = (teacherModel == nil) ? 0 : sigleWidth
        if teacherView.width != teacherWidth {
            teacherView.mas_remakeConstraints { make in
                make?.top.left().bottom().equalTo()(teacherView.superview)
                make?.width.equalTo()(teacherWidth)
            }
        }
        // 最多显示六个学生
        let f_count = CGFloat(self.dataSource.count > maxCount ? maxCount: self.dataSource.count)
        let studentWidth = (sigleWidth + kItemGap) * f_count - kItemGap
        if collectionView.width != studentWidth {
            collectionView.mas_remakeConstraints { make in
                make?.right.top().bottom().equalTo()(contentView)
                make?.left.equalTo()(teacherView.mas_right)?.offset()(kItemGap)
                make?.width.equalTo()(studentWidth)
            }
        }
        let pageEnable = (self.dataSource.count <= maxCount)
        self.leftButton.isHidden = pageEnable
        self.rightButton.isHidden = pageEnable
    }
    
    override func initViews() {
        super.initViews()
        
        
        teacherView.layer.cornerRadius = FcrUIFrameGroup.fcr_window_corner_radius
        teacherView.clipsToBounds = true
        teacherView.isHidden = true
        contentView.addSubview(teacherView)
        
        let tapTeacher = UITapGestureRecognizer(target: self,
                                                action: #selector(onClickTeacher(_:)))
        tapTeacher.numberOfTapsRequired = 1
        tapTeacher.numberOfTouchesRequired = 1
        tapTeacher.delaysTouchesBegan = true
        teacherView.addGestureRecognizer(tapTeacher)
    }
    
    override func initViewFrame() {
        contentView.mas_makeConstraints { make in
            make?.centerX.equalTo()(0)
            make?.top.equalTo()(0)
            make?.bottom.equalTo()(0)
        }
        
        collectionView.mas_makeConstraints { make in
            make?.right.top().bottom().equalTo()(0)
            make?.left.equalTo()(contentView.mas_right)
        }

        teacherView.mas_makeConstraints { make in
            make?.left.right().top().bottom().equalTo()(0)
        }
        
        
        
        guard expandFlag else {
            return
        }
        
        leftButton.mas_makeConstraints { make in
            make?.left.top().bottom().equalTo()(collectionView)
            make?.width.equalTo()(24)
        }
        rightButton.mas_makeConstraints { make in
            make?.right.top().bottom().equalTo()(collectionView)
            make?.width.equalTo()(24)
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
extension AgoraSmallMembersUIController: AgoraEduUserHandler{
    func onRemoteUserJoined(user: AgoraEduContextUserInfo) {
        guard user.userRole == .teacher else {
            return
        }
        setTeacherModel()
    }
    
    func onRemoteUserLeft(user: AgoraEduContextUserInfo,
                          operatorUser: AgoraEduContextUserInfo?,
                          reason: AgoraEduContextUserLeaveReason) {
        guard user.userRole == .teacher else {
            return
        }
        teacherModel = nil
    }
    
    func onCoHostUserListAdded(userList: [AgoraEduContextUserInfo],
                               operatorUser: AgoraEduContextUserInfo?) {
        let list = userList.map({return $0.userUuid})
        addModels(userList: list)
    }
    
    func onCoHostUserListRemoved(userList: [AgoraEduContextUserInfo],
                                 operatorUser: AgoraEduContextUserInfo?) {
        let list = userList.map({return $0.userUuid})
        deleteModels(userList: list)
    }
    
    func onUserHandsWave(userUuid: String,
                         duration: Int,
                         payload: [String : Any]?) {
        guard let model = dataSource.first(where: {$0.userId == userUuid}),
           let view = viewsMap[model.userId] else {
            return
        }
        view.startWaving()
    }
    
    func onUserHandsDown(userUuid: String,
                         payload: [String : Any]?) {
        guard let model = dataSource.first(where: {$0.userId == userUuid}),
           let view = viewsMap[model.userId] else {
            return
        }
        view.stopWaving()
    }
}

// MARK: - AgoraEduMediaHandler
extension AgoraSmallMembersUIController {
    override func onVolumeUpdated(volume: Int,
                                  streamUuid: String) {
        if let model = teacherModel,
              model.streamId == streamUuid {
            teacherView.updateVolume(volume)
        } else {
            super.onVolumeUpdated(volume: volume,
                                  streamUuid: streamUuid)
        }
    }
}

// MARK: - private
private extension AgoraSmallMembersUIController {
    @objc func onClickTeacher(_ sender: UIView) {
        guard let model = teacherModel else {
            return
        }
        delegate?.onClickMemberAt(view: teacherView,
                                  userId: model.userId)
    }
    
    func setTeacherModel() {
        guard teacherModel == nil,
              let teacherInfo = contextPool.user.getUserList(role: .teacher)?.first else {
            return
        }
        self.teacherModel = makeModel(userId: teacherInfo.userUuid)
    }
}
