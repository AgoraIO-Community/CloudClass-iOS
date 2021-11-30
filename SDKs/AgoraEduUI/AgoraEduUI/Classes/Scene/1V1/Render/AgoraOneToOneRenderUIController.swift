//
//  AgoraOneToOneRenderUIController.swift
//  AgoraEduUI
//
//  Created by Jonathan on 2021/11/15.
//

import AgoraUIEduBaseViews
import AgoraUIBaseViews
import AgoraEduContext
import AudioToolbox
import AgoraWidget
import Masonry
import UIKit

class AgoraOneToOneRenderUIController: UIViewController {
    
    var collectionView: AgoraBaseUICollectionView!
        
    var contextPool: AgoraEduContextPool!
    
    var teacherView: AgoraOneToOneMemberView!
    
    var studentView: AgoraOneToOneMemberView!
    /** 用来记录当前流是否被老师操作*/
    var currentStream: AgoraEduContextStream? {
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
        contextPool.user.registerEventHandler(self)
        contextPool.stream.registerStreamEventHandler(self)
    }
}
// MARK: - Private
private extension AgoraOneToOneRenderUIController {
    func updateCoHosts() {
        let list = self.contextPool.user.getAllUserList()
        self.currentStream = nil
        if let studentInfo = list.first(where: { $0.role == .student }) {
            let stream = contextPool.stream.getStreamInfo(userUuid: studentInfo.userUuid)?.first
            let localInfo = contextPool.user.getLocalUserInfo()
            if stream?.owner.userUuid == localInfo.userUuid {
                self.currentStream = stream
            }
            let model = AgoraRenderItemInfoModel(with: studentInfo,
                                                 stream: stream)
            studentView.item = model
            
            if let s = stream {
                if s.streamType == .video ||
                    s.streamType == .both {
                    switch s.videoSourceState {
                    case .error:
                        studentView.cameraState = .erro
                    case .close:
                        studentView.cameraState = .off
                    case .open:
                        studentView.cameraState = .on
                    }
                } else {
                    studentView.cameraState = .off
                }
                if s.streamType == .audio ||
                    s.streamType == .both {
                    switch s.audioSourceState {
                    case .error:
                        studentView.micState = .erro
                    case .close:
                        studentView.micState = .off
                    case .open:
                        studentView.micState = .on
                    }
                } else {
                    studentView.micState = .off
                }
            } else {
                studentView.cameraState = .erro
                studentView.micState = .erro
            }
        } else {
            studentView.item = nil
            studentView.cameraState = .on
        }
        // teacher view
        if let teacherInfo = list.first(where: { $0.role == .teacher }) {
            let stream = contextPool.stream.getStreamInfo(userUuid: teacherInfo.userUuid)?.first
            let model = AgoraRenderItemInfoModel(with: teacherInfo,
                                                 stream: stream)
            teacherView.item = model

            if let s = stream {
                if s.streamType == .video ||
                    s.streamType == .both {
                    switch s.videoSourceState {
                    case .error:
                        teacherView.cameraState = .erro
                    case .close:
                        teacherView.cameraState = .off
                    case .open:
                        teacherView.cameraState = .on
                    }
                } else {
                    studentView.cameraState = .off
                }
                if s.streamType == .audio ||
                    s.streamType == .both {
                    switch s.audioSourceState {
                    case .error:
                        teacherView.micState = .erro
                    case .close:
                        teacherView.micState = .off
                    case .open:
                        teacherView.micState = .on
                    }
                } else {
                    teacherView.micState = .off
                }
            } else {
                teacherView.cameraState = .erro
                teacherView.micState = .erro
            }
        } else {
            teacherView.item = nil
        }
    }
    
    func streamChanged(from: AgoraEduContextStream?, to: AgoraEduContextStream?) {
        guard let fromStream = from, let toStream = to else {
            return
        }
        if fromStream.streamType.hasAudio, !toStream.streamType.hasAudio {
            AgoraToast.toast(msg: "MicrophoneMuteText".ag_localizedIn("AgoraEduUI"))
        } else if !fromStream.streamType.hasAudio, toStream.streamType.hasAudio {
            AgoraToast.toast(msg: "MicrophoneUnMuteText".ag_localizedIn("AgoraEduUI"))
        }
        if fromStream.streamType.hasVideo, !toStream.streamType.hasVideo {
            AgoraToast.toast(msg: "CameraMuteText".ag_localizedIn("AgoraEduUI"))
        } else if !fromStream.streamType.hasVideo, toStream.streamType.hasVideo {
            AgoraToast.toast(msg: "CameraUnMuteText".ag_localizedIn("AgoraEduUI"))
        }
    }
    
    func showRewardAnimation() {
        guard let url = Bundle.ag_compentsBundleNamed("AgoraEduUI")?
                .url(forResource: "ak_reward_cup",
                     withExtension: "gif"),
              let data = try? Data(contentsOf: url) else {
            return
        }
        let image = AgoraFLAnimatedImage(animatedGIFData: data)
        image?.loopCount = 1
        let imageView = AgoraFLAnimatedImageView()
        imageView.animatedImage = image
        imageView.loopCompletionBlock = {[weak imageView] (loopCountRemaining) -> Void in
            guard let targetView = self.studentView else {
                return
            }
            imageView?.mas_remakeConstraints { make in
                make?.left.top().equalTo()(targetView)
                make?.width.height().equalTo()(40)
            }
            UIView.animate(withDuration: 0.5) {
                imageView?.superview?.layoutIfNeeded()
            } completion: { finish in
                imageView?.removeFromSuperview()
            }
        }
        if let window = UIApplication.shared.keyWindow {
            window.addSubview(imageView)
            imageView.mas_makeConstraints { make in
                make?.center.equalTo()(0)
            }
        }
        guard let rewardUrl = Bundle.ag_compentsBundleNamed("AgoraEduUI")?
                .url(forResource: "ring_ak_reward",
                     withExtension: "wav") else {
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
// MARK: - AkOneToOneItemCellDelegate
extension AgoraOneToOneRenderUIController: AgoraOneToOneMemberViewDelegate {
    func onMemberViewRequestRenderOnView(view: UIView, streamID: String, userUUID: String) {
        let renderConfig = AgoraEduContextRenderConfig()
        renderConfig.mode = .hidden
        
        contextPool.stream.setRemoteVideoStreamSubscribeLevel(streamUuid: streamID,
                                                              level: .low)
        
        let u = contextPool.user.getLocalUserInfo()
        
        
        contextPool.media.startRenderVideo(view: view,
                                           renderConfig: renderConfig,
                                           streamUuid: streamID)
    }
    
    func onMemberViewRequestCancelRender(streamID: String, userUUID: String) {
        let u = contextPool.user.getLocalUserInfo()
        contextPool.media.stopRenderVideo(streamUuid: streamID)
    }
}

// MARK: - AgoraEduUserHandler
extension AgoraOneToOneRenderUIController: AgoraEduUserHandler {
    func onUpdateUserList(_ list: [AgoraEduContextUserInfo]) {
        self.updateCoHosts()
    }
    
    func onUpdateCoHostList(_ list: [AgoraEduContextUserInfo]) {
        self.updateCoHosts()
    }
    
    func onUpdateAudioVolumeIndication(_ value: Int, streamUuid: String) {
        if teacherView.item?.streamUUID == streamUuid {
            self.teacherView.setVolumeValue(value)
        } else {
            self.studentView.setVolumeValue(value)
        }
    }
    
    func onShowUserReward(_ user: AgoraEduContextUserInfo) {
        self.showRewardAnimation()
    }
    
    func onFlexUserPropertiesChanged(_ changedProperties: [String : Any],
                                     properties: [String: Any],
                                     cause: [String : Any]?,
                                     fromUser: AgoraEduContextUserInfo,
                                     operator: AgoraEduContextUserInfo?) {
        print(#function)
    }
}
// MARK: - AgoraEduStreamHandler
extension AgoraOneToOneRenderUIController: AgoraEduStreamHandler {
    func onStreamJoin(stream: AgoraEduContextStream,
                      operator: AgoraEduContextUserInfo?) {
        self.updateCoHosts()
    }
    
    func onStreamLeave(stream: AgoraEduContextStream,
                       operator: AgoraEduContextUserInfo?) {
        self.updateCoHosts()
    }
    
    func onStreamUpdate(stream: AgoraEduContextStream,
                        operator: AgoraEduContextUserInfo?) {
        if stream.streamUuid == currentStream?.streamUuid {
            self.currentStream = stream
        }
        self.updateCoHosts()
    }
}
// MARK: - Creations
private extension AgoraOneToOneRenderUIController {
    func createViews() {
        teacherView = AgoraOneToOneMemberView(frame: .zero)
        teacherView.delegate = self
        teacherView.viewType = .admin
        view.addSubview(teacherView)
        
        studentView = AgoraOneToOneMemberView(frame: .zero)
        studentView.delegate = self
        studentView.viewType = .member
        view.addSubview(studentView)
    }
    
    func createConstrains() {
        teacherView.mas_remakeConstraints { make in
            make?.top.equalTo()(0)
            make?.left.equalTo()(0)
            make?.width.equalTo()(view)
            make?.height.equalTo()(view.mas_width)
        }
        studentView.mas_remakeConstraints { make in
            make?.top.equalTo()(teacherView.mas_bottom)?.offset()(2)
            make?.left.equalTo()(0)
            make?.width.height().equalTo()(teacherView)
        }
    }
}

