//
//  AgoraTeacherRenderController.swift
//  AgoraEduUI
//
//  Created by Jonathan on 2021/12/9.
//

import UIKit
import AgoraEduContext

class AgoraTeacherRenderUIController: UIViewController {
    
    private weak var delegate: AgoraRenderUIControllerDelegate?
    
    private var renderView: AgoraRenderMemberView!

    private var contextPool: AgoraEduContextPool!
    
    private var teacherModel: AgoraRenderMemberModel? {
        didSet {
            self.renderView.setModel(model: teacherModel,
                                     delegate: self)
        }
    }
    
    init(context: AgoraEduContextPool,
         delegate: AgoraRenderUIControllerDelegate? = nil) {
        super.init(nibName: nil, bundle: nil)
        self.contextPool = context
        self.delegate = delegate
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        createViews()
        createConstraint()
        
        contextPool.user.registerUserEventHandler(self)
        contextPool.stream.registerStreamEventHandler(self)
        contextPool.room.registerRoomEventHandler(self)
        contextPool.media.registerMediaEventHandler(self)
    }
    
    public func renderViewForUser(with userId: String) -> UIView? {
        if userId == self.teacherModel?.uuid {
            return self.view
        } else {
            return nil
        }
    }
    
    public func setRenderEnable(with userId: String, rendEnable: Bool) {
        if let model = self.teacherModel,
           userId == self.teacherModel?.uuid{
            model.rendEnable = rendEnable
        }
    }
}
// MARK: - Private
private extension AgoraTeacherRenderUIController {
    func setup() {
        if let teacher = contextPool.user.getUserList(role: .teacher)?.first {
            self.teacherModel = AgoraRenderMemberModel.model(with: contextPool.user,
                                                             streamController: contextPool.stream,
                                                             uuid: teacher.userUuid,
                                                             name: teacher.userName)
        }
        
        if let streamList = contextPool.stream.getAllStreamList() {
            for stream in streamList {
                handleAudioOfStream(stream)
            }
        }
    }
    
    func handleAudioOfStream(_ stream: AgoraEduContextStreamInfo,
                             isLeft: Bool = false) {
        let roomId = contextPool.room.getRoomInfo().roomUuid
        
        guard isLeft == false else {
            contextPool.media.stopPlayAudio(roomUuid: roomId,
                                            streamUuid: stream.streamUuid)
            return
        }
 
        switch stream.audioSourceState {
        case .open:
            contextPool.media.startPlayAudio(roomUuid: roomId,
                                             streamUuid: stream.streamUuid)
        default:
            contextPool.media.stopPlayAudio(roomUuid: roomId,
                                            streamUuid: stream.streamUuid)
        }
    }
    
    func updateStream(stream: AgoraEduContextStreamInfo?) {
        guard stream?.videoSourceType != .screen else {
            return
        }
        
        if let model = teacherModel,
           stream?.owner.userUuid == model.uuid {
            model.updateStream(stream)
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
        renderConfig.isMirror = true
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
        if user.userRole == .teacher {
            self.teacherModel = AgoraRenderMemberModel.model(with: contextPool.user,
                                                             streamController: contextPool.stream,
                                                             uuid: user.userUuid,
                                                             name: user.userName)
        }
    }
    
    func onRemoteUserLeft(user: AgoraEduContextUserInfo,
                          operatorUser: AgoraEduContextUserInfo?,
                          reason: AgoraEduContextUserLeaveReason) {
        if user.userRole == .teacher {
            self.teacherModel = nil
        }
    }
}
// MARK: - AgoraEduStreamHandler
extension AgoraTeacherRenderUIController: AgoraEduStreamHandler {
    func onStreamJoined(stream: AgoraEduContextStreamInfo,
                        operatorUser: AgoraEduContextUserInfo?) {
        handleAudioOfStream(stream)
        updateStream(stream: stream)
    }
    
    func onStreamUpdated(stream: AgoraEduContextStreamInfo,
                         operatorUser: AgoraEduContextUserInfo?) {
        handleAudioOfStream(stream)
        updateStream(stream: stream)
    }
    
    func onStreamLeft(stream: AgoraEduContextStreamInfo,
                      operatorUser: AgoraEduContextUserInfo?) {
        handleAudioOfStream(stream,
                            isLeft: true)
        updateStream(stream: stream.toEmptyStream())
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
    func onJoinRoomSuccess(roomInfo: AgoraEduContextRoomInfo) {
        self.setup()
    }
}

private extension AgoraTeacherRenderUIController {
    func createViews() {
        var ui = AgoraUIGroup()
        renderView = AgoraRenderMemberView(frame: .zero)
        view.addSubview(renderView)
        
        let tapTeacher = UITapGestureRecognizer(target: self,
                                                action: #selector(onClickTeacher(_:)))
        tapTeacher.numberOfTapsRequired = 1
        tapTeacher.numberOfTouchesRequired = 1
        tapTeacher.delaysTouchesBegan = true
        renderView.addGestureRecognizer(tapTeacher)
    }
    
    func createConstraint() {
        renderView.mas_makeConstraints { make in
            make?.left.right().top().bottom().equalTo()(0)
        }
    }
    
    @objc func onClickTeacher(_ sender: UITapGestureRecognizer) {
        if let uuid = teacherModel?.uuid {
            delegate?.onClickMemberAt(view: renderView,
                                      UUID: uuid)
        }
        
    }
}
