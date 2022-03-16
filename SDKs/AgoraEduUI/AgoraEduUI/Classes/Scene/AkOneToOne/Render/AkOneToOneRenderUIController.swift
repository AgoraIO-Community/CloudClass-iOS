//
//  AkOneToOneRenderUIController.swift
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

struct AkUIConfig {
    var backgroundColor = UIColor(hex: 0xF9F9FC)
    var borderColor = UIColor(hex: 0xECECF1)?.cgColor
    var borderWidth: CGFloat = 0
    var cornerRadius: CGFloat?
}

class AkOneToOneRenderUIController: UIViewController {
    
    weak var delegate: AgoraRenderUIControllerDelegate?
    
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
    
    init(context: AgoraEduContextPool,
         delegate: AgoraRenderUIControllerDelegate) {
        super.init(nibName: nil, bundle: nil)
        self.delegate = delegate
        contextPool = context
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        createViews()
        createConstraint()
        contextPool.user.registerUserEventHandler(self)
        contextPool.media.registerMediaEventHandler(self)
        contextPool.stream.registerStreamEventHandler(self)
        contextPool.room.registerRoomEventHandler(self)
    }
}
// MARK: - Private
private extension AkOneToOneRenderUIController {
    func setup() {
        if let teacher = contextPool.user.getUserList(role: .teacher)?.first {
            teacherModel = AgoraRenderMemberModel.model(with: contextPool,
                                                        uuid: teacher.userUuid,
                                                        name: teacher.userName)
        }
        if let student = contextPool.user.getUserList(role: .student)?.first {
            studentModel = AgoraRenderMemberModel.model(with: contextPool,
                                                        uuid: student.userUuid,
                                                        name: student.userName)
        }
    }
    
    func streamChanged(from: AgoraEduContextStreamInfo?, to: AgoraEduContextStreamInfo?) {
        guard let fromStream = from, let toStream = to else {
            return
        }
        if fromStream.streamType.hasAudio, !toStream.streamType.hasAudio {
            AgoraToast.toast(msg: "fcr_stream_stop_audio".agedu_localized())
        } else if !fromStream.streamType.hasAudio, toStream.streamType.hasAudio {
            AgoraToast.toast(msg: "fcr_stream_start_audio".agedu_localized())
        }
        if fromStream.streamType.hasVideo, !toStream.streamType.hasVideo {
            AgoraToast.toast(msg: "fcr_stream_stop_video".agedu_localized())
        } else if !fromStream.streamType.hasVideo, toStream.streamType.hasVideo {
            AgoraToast.toast(msg: "fcr_stream_start_video".agedu_localized())
        }
    }
    
    func updateStream(stream: AgoraEduContextStreamInfo?) {
        guard stream?.videoSourceType != .screen else {
            return
        }
        if stream?.owner.userUuid == teacherModel?.uuid {
            teacherModel?.updateStream(stream)
        } else if stream?.owner.userUuid == studentModel?.uuid {
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
extension AkOneToOneRenderUIController: AgoraRenderMemberViewDelegate {
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
extension AkOneToOneRenderUIController: AgoraEduUserHandler {
    
    func onRemoteUserJoined(user: AgoraEduContextUserInfo) {
        if user.userRole == .teacher {
            teacherModel = AgoraRenderMemberModel.model(with: contextPool,
                                                        uuid: user.userUuid,
                                                        name: user.userName)
        } else if user.userRole == .student {
            studentModel = AgoraRenderMemberModel.model(with: contextPool,
                                                        uuid: user.userUuid,
                                                        name: user.userName)
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
extension AkOneToOneRenderUIController: AgoraEduMediaHandler {
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
extension AkOneToOneRenderUIController: AgoraEduStreamHandler {
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
extension AkOneToOneRenderUIController: AgoraEduRoomHandler {
    func onJoinRoomSuccess(roomInfo: AgoraEduContextRoomInfo) {
        self.setup()
    }
}
// MARK: - Creations
private extension AkOneToOneRenderUIController {
    @objc func onClickTeacher(_ sender: UITapGestureRecognizer) {
        if let uuid = teacherModel?.uuid {
            delegate?.onClickMemberAt(view: teacherView,
                                      UUID: uuid)
        }
        
    }
    
    @objc func onClickStudent(_ sender: UITapGestureRecognizer) {
        if let uuid = studentModel?.uuid {
            delegate?.onClickMemberAt(view: studentView,
                                      UUID: uuid)
        }
    }
    
    func createViews() {
        let config = AkUIConfig(backgroundColor: UIColor(hex: 0x263487),
                                borderColor: UIColor(hex: 0x75C0FE)?.cgColor,
                                borderWidth: 2,
                                cornerRadius: 6)
        teacherView = AgoraRenderMemberView(frame: .zero,
                                            uiConfig: config)
        view.addSubview(teacherView)
        
        studentView = AgoraRenderMemberView(frame: .zero,
                                            uiConfig: config)
        view.addSubview(studentView)
        
        let tapTeacher = UITapGestureRecognizer(target: self,
                                                action: #selector(onClickTeacher(_:)))
        tapTeacher.numberOfTapsRequired = 1
        tapTeacher.numberOfTouchesRequired = 1
        tapTeacher.delaysTouchesBegan = true
        teacherView.addGestureRecognizer(tapTeacher)
        
        let tapStudent = UITapGestureRecognizer(target: self,
                                                action: #selector(onClickStudent(_:)))
        tapStudent.numberOfTapsRequired = 1
        tapStudent.numberOfTouchesRequired = 1
        tapStudent.delaysTouchesBegan = true
        studentView.addGestureRecognizer(tapStudent)
    }
    
    func createConstraint() {
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

