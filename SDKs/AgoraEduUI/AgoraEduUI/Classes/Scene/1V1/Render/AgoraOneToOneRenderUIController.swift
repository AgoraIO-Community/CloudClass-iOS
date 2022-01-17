//
//  AgoraOneToOneRenderUIController.swift
//  AgoraEduUI
//
//  Created by Jonathan on 2021/11/15.
//

import AgoraUIBaseViews
import FLAnimatedImage
import AgoraEduContext
import AudioToolbox
import AgoraWidget
import Masonry
import UIKit

class AgoraOneToOneRenderUIController: UIViewController {
    
    var collectionView: AgoraBaseUICollectionView!
        
    var contextPool: AgoraEduContextPool!
    
    var teacherView: AgoraRenderMemberView!
    
    var studentView: AgoraRenderMemberView!
    
    var teacherModel: AgoraRenderMemberModel? {
        didSet {
            teacherView.setModel(model: teacherModel,
                                 delegate: self)
        }
    }
    
    var studentModel: AgoraRenderMemberModel? {
        didSet {
            studentView.setModel(model: studentModel,
                                 delegate: self)
        }
    }
    /** 用来记录当前流是否被老师操作*/
    var currentStream: AgoraEduContextStreamInfo? {
        didSet {
            streamChanged(from: oldValue, to: currentStream)
        }
    }
    
    deinit {
        print("\(#function): \(self.classForCoder)")
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
        contextPool.media.registerMediaEventHandler(self)
        contextPool.stream.registerStreamEventHandler(self)
        contextPool.room.registerRoomEventHandler(self)
    }
}
// MARK: - Private
private extension AgoraOneToOneRenderUIController {
    func setup() {
        if let teacher = contextPool.user.getUserList(role: .teacher)?.first {
            teacherModel = AgoraRenderMemberModel.model(with: contextPool,
                                                        uuid: teacher.userUuid,
                                                        name: teacher.userName,
                                                        role: .teacher)
        }
        if let student = contextPool.user.getUserList(role: .student)?.first {
            studentModel = AgoraRenderMemberModel.model(with: contextPool,
                                                        uuid: student.userUuid,
                                                        name: student.userName,
                                                        role: .student)
        }
    }
    
    func streamChanged(from: AgoraEduContextStreamInfo?, to: AgoraEduContextStreamInfo?) {
        guard let fromStream = from, let toStream = to else {
            return
        }
        if fromStream.streamType.hasAudio, !toStream.streamType.hasAudio {
            AgoraToast.toast(msg: "MicrophoneMuteText".agedu_localized())
        } else if !fromStream.streamType.hasAudio, toStream.streamType.hasAudio {
            AgoraToast.toast(msg: "MicrophoneUnMuteText".agedu_localized())
        }
        if fromStream.streamType.hasVideo, !toStream.streamType.hasVideo {
            AgoraToast.toast(msg: "CameraMuteText".agedu_localized())
        } else if !fromStream.streamType.hasVideo, toStream.streamType.hasVideo {
            AgoraToast.toast(msg: "CameraUnMuteText".agedu_localized())
        }
    }
    
    func updateStream(stream: AgoraEduContextStreamInfo?) {
        guard stream?.videoSourceType != .screen else {
            return
        }
        
        if stream?.streamUuid == teacherModel?.streamID {
            teacherModel?.updateStream(stream)
        } else if stream?.streamUuid == studentModel?.streamID {
            studentModel?.updateStream(stream)
        }
        if stream?.streamUuid == currentStream?.streamUuid {
            self.currentStream = stream
        }
    }
    
    func showRewardAnimation() {
        guard let url = Bundle.agoraEduUI().url(forResource: "img_reward", withExtension: "gif"),
              let data = try? Data(contentsOf: url) else {
            return
        }
        let animatedImage = FLAnimatedImage(animatedGIFData: data)
        let imageView = FLAnimatedImageView()
        imageView.animatedImage = animatedImage
        imageView.loopCompletionBlock = {[weak imageView] (loopCountRemaining) -> Void in
            imageView?.removeFromSuperview()
        }
        if let window = UIApplication.shared.keyWindow {
            window.addSubview(imageView)
            imageView.mas_makeConstraints { make in
                make?.center.equalTo()(0)
                make?.width.equalTo()(AgoraFit.scale(238))
                make?.height.equalTo()(AgoraFit.scale(238))
            }
        }
        // sounds
        guard let rewardUrl = Bundle.agoraEduUI().url(forResource: "sound_reward", withExtension: "mp3") else {
            return
        }
        var soundId: SystemSoundID = 0;
        AudioServicesCreateSystemSoundID(rewardUrl as CFURL,
                                         &soundId);
        AudioServicesAddSystemSoundCompletion(soundId, nil, nil, {
            (soundId, clientData) -> Void in
            AudioServicesDisposeSystemSoundID(soundId)
        }, nil)
        AudioServicesPlaySystemSound(soundId)
    }
}
// MARK: - AgoraRenderMemberViewDelegate
extension AgoraOneToOneRenderUIController: AgoraRenderMemberViewDelegate {
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
extension AgoraOneToOneRenderUIController: AgoraEduUserHandler {
    
    func onRemoteUserJoined(user: AgoraEduContextUserInfo) {
        if user.userRole == .teacher {
            teacherModel = AgoraRenderMemberModel.model(with: contextPool,
                                                        uuid: user.userUuid,
                                                        name: user.userName,
                                                        role: .student)
        } else if user.userRole == .student {
            studentModel = AgoraRenderMemberModel.model(with: contextPool,
                                                        uuid: user.userUuid,
                                                        name: user.userName,
                                                        role: .teacher)
        }
    }
    
    func onRemoteUserLeft(user: AgoraEduContextUserInfo,
                          operatorUser: AgoraEduContextUserInfo?,
                          reason: AgoraEduContextUserLeaveReason) {
        if user.userRole == .teacher {
            teacherModel = nil
        } else if user.userRole == .student {
            studentModel = nil
        }
    }
    
    func onUserRewarded(user: AgoraEduContextUserInfo,
                        rewardCount: Int,
                        operatorUser: AgoraEduContextUserInfo?) {
        if studentModel?.uuid == user.userUuid {
            studentModel?.rewardCount = rewardCount
        }
        showRewardAnimation()
    }
}
// MARK: - AgoraEduUserHandler
extension AgoraOneToOneRenderUIController: AgoraEduMediaHandler {
    func onVolumeUpdated(volume: Int,
                         streamUuid: String) {
        if teacherModel?.streamID == streamUuid {
            teacherModel?.volume = volume
        } else if studentModel?.streamID == streamUuid {
            studentModel?.volume = volume
        }
    }
}
// MARK: - AgoraEduStreamHandler
extension AgoraOneToOneRenderUIController: AgoraEduStreamHandler {
    func onStreamJoined(stream: AgoraEduContextStreamInfo,
                        operatorUser: AgoraEduContextUserInfo?) {
        self.updateStream(stream: stream)
    }
    
    func onStreamUpdated(stream: AgoraEduContextStreamInfo,
                         operatorUser: AgoraEduContextUserInfo?) {
        self.updateStream(stream: stream)
    }
    
    func onStreamLeft(stream: AgoraEduContextStreamInfo,
                      operatorUser: AgoraEduContextUserInfo?) {
        let emptyStream = AgoraEduContextStreamInfo(streamUuid: stream.streamUuid,
                                                    streamName: stream.streamName,
                                                    streamType: .none,
                                                    videoSourceType: .none,
                                                    audioSourceType: .none,
                                                    videoSourceState: .error,
                                                    audioSourceState: .error,
                                                    owner: stream.owner)
        self.updateStream(stream: emptyStream)
    }
}
// MARK: - AgoraEduRoomHandler
extension AgoraOneToOneRenderUIController: AgoraEduRoomHandler {
    func onJoinRoomSuccess(roomInfo: AgoraEduContextRoomInfo) {
        self.setup()
    }
}
// MARK: - Creations
private extension AgoraOneToOneRenderUIController {
    func createViews() {
        teacherView = AgoraRenderMemberView(frame: .zero)
        view.addSubview(teacherView)
        
        studentView = AgoraRenderMemberView(frame: .zero)
        view.addSubview(studentView)
    }
    
    func createConstrains() {
        if UIDevice.current.isPad {
            teacherView.mas_remakeConstraints { make in
                make?.top.left().right().equalTo()(0)
                make?.bottom.equalTo()(view.mas_centerY)
            }
            studentView.mas_remakeConstraints { make in
                make?.bottom.left().right().equalTo()(0)
                make?.top.equalTo()(view.mas_centerY)
            }
        } else {
            teacherView.mas_remakeConstraints { make in
                make?.top.left().right().equalTo()(0)
                make?.bottom.equalTo()(self.view.mas_centerY)?.offset()(AgoraFit.scale(-1))
            }
            studentView.mas_remakeConstraints { make in
                make?.bottom.left().right().equalTo()(0)
                make?.top.equalTo()(self.view.mas_centerY)?.offset()(AgoraFit.scale(1))
            }
        }
    }
}

