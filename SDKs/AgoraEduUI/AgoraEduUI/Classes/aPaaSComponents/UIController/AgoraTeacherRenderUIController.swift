//
//  AgoraTeacherRenderController.swift
//  AgoraEduUI
//
//  Created by Jonathan on 2021/12/9.
//

import UIKit
import AgoraEduContext

class AgoraTeacherRenderUIController: UIViewController {
    
    private var renderView: AgoraRenderMemberView!

    private var contextPool: AgoraEduContextPool!
    
    private var teacherModel: AgoraRenderMemberModel? {
        didSet {
            self.renderView.setModel(model: teacherModel, delegate: self)
        }
    }
    
    init(context: AgoraEduContextPool) {
        super.init(nibName: nil, bundle: nil)
        contextPool = context
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        createViews()
        createConstrains()
        
        contextPool.user.registerUserEventHandler(self)
        contextPool.stream.registerStreamEventHandler(self)
        contextPool.room.registerRoomEventHandler(self)
        contextPool.media.registerMediaEventHandler(self)
    }
}

extension AgoraTeacherRenderUIController {
    func setup() {
        if let teacher = contextPool.user.getUserList(role: .teacher)?.first {
            self.teacherModel = AgoraRenderMemberModel.model(with: contextPool,
                                                             uuid: teacher.userUuid,
                                                             name: teacher.userName,
                                                             role: .teacher)
        }
    }
}
// MARK: - AgoraRenderMemberViewDelegate
extension AgoraTeacherRenderUIController: AgoraRenderMemberViewDelegate {
    func memberViewRender(memberView: AgoraRenderMemberView,
                          in view: UIView,
                          renderID: String) {
        let renderConfig = AgoraEduContextRenderConfig()
        renderConfig.mode = .hidden
        contextPool.stream.setRemoteVideoStreamSubscribeLevel(streamUuid: renderID,
                                                              level: .low)
        contextPool.media.startRenderVideo(view: view,
                                           renderConfig: renderConfig,
                                           streamUuid: renderID)
    }

    func memberViewCancelRender(memberView: AgoraRenderMemberView, renderID: String) {
        contextPool.media.stopRenderVideo(streamUuid: renderID)
    }
}

// MARK: - AgoraEduUserHandler
extension AgoraTeacherRenderUIController: AgoraEduUserHandler {
    func onRemoteUserJoined(user: AgoraEduContextUserInfo) {
        if user.role == .teacher {
            self.teacherModel = AgoraRenderMemberModel.model(with: contextPool,
                                                             uuid: user.userUuid,
                                                             name: user.userName,
                                                             role: .teacher)
        }
    }
    
    func onRemoteUserLeft(user: AgoraEduContextUserInfo,
                          operatorUser: AgoraEduContextUserInfo?,
                          reason: AgoraEduContextUserLeaveReason) {
        if user.role == .teacher {
            self.teacherModel = nil
        }
    }
}
// MARK: - AgoraEduStreamHandler
extension AgoraTeacherRenderUIController: AgoraEduStreamHandler {
    func onStreamUpdated(stream: AgoraEduContextStreamInfo,
                         operatorUser: AgoraEduContextUserInfo?) {
        guard stream.videoSourceType != .screen else {
            return
        }
        
        if let model = teacherModel,
           stream.owner.userUuid == model.uuid {
            model.updateStream(stream)
        }
    }
}
// MARK: - AgoraEduMediaHandler
extension AgoraTeacherRenderUIController: AgoraEduMediaHandler {
    func onVolumeUpdated(volume: Int,
                         streamUuid: String) {
        if let model = teacherModel,
           streamUuid == model.streamID {
            model.volume = volume
        }
    }
}
// MARK: - AgoraEduRoomHandler
extension AgoraTeacherRenderUIController: AgoraEduRoomHandler {
    func onRoomJoinedSuccess(roomInfo: AgoraEduContextRoomInfo) {
        self.setup()
    }
}

private extension AgoraTeacherRenderUIController {
    func createViews() {
        renderView = AgoraRenderMemberView(frame: .zero)
        view.addSubview(renderView)
    }
    
    func createConstrains() {
        renderView.mas_makeConstraints { make in
            make?.left.right().top().bottom().equalTo()(0)
        }
    }
}
