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
        contextPool.user.registerEventHandler(self)
        contextPool.media.registerMediaEventHandler(self)
        contextPool.stream.registerStreamEventHandler(self)
        contextPool.room.registerRoomEventHandler(self)
    }
}
// MARK: - Private
private extension AgoraOneToOneRenderUIController {
    func updateCoHosts() {
        self.currentStream = nil
        
        let user = contextPool.user
        let stream = contextPool.stream
        
        // student view
        if let studentInfo = user.getUserList(role: .student)?.first {
            let localInfo = user.getLocalUserInfo()
            
            if let stream = stream.getStreamInfo(userUuid: studentInfo.userUuid)?.first {
                if studentInfo.userUuid == localInfo.userUuid {
                    self.currentStream = stream
                }
                
                updateRenderView(studentView,
                                 with: stream)
            } else {
                updateRenderViewWithoutStream(studentView)
            }
        } else {
            studentView.item = nil
        }
        
        // teacher view
        if let teacherInfo = user.getUserList(role: .teacher)?.first {
            if let stream = stream.getStreamInfo(userUuid: teacherInfo.userUuid)?.first {
                updateRenderView(teacherView,
                                 with: stream)
            } else {
                updateRenderViewWithoutStream(teacherView)
            }
        } else {
            teacherView.item = nil
        }
    }
    
    func updateRenderView(_ view: AgoraOneToOneMemberView,
                          with stream: AgoraEduContextStreamInfo) {
        let model = AgoraRenderItemInfoModel(with: stream.owner,
                                             stream: stream)
        
        view.item = model
        
        if stream.streamType.hasVideo {
            switch stream.videoSourceState {
            case .error:
                view.cameraState = .erro
                print("view.cameraState = .erro")
            case .close:
                view.cameraState = .off
                print("view.cameraState = .off")
            case .open:
                view.cameraState = .on
                print("view.cameraState = .on")
            }
        } else {
            view.cameraState = .off
            print("view.cameraState = .off")
        }
        
        if stream.streamType.hasAudio {
            switch stream.audioSourceState {
            case .error:
                view.micState = .erro
                print("view.micState = .erro")
            case .close:
                view.micState = .off
                print("view.micState = .off")
            case .open:
                view.micState = .on
                print("view.micState = .off")
            }
        } else {
            view.micState = .off
            print("view.micState = .off")
        }
    }
    
    func updateRenderViewWithoutStream(_ view: AgoraOneToOneMemberView) {
        view.cameraState = .erro
        view.micState = .erro
    }
    
    func streamChanged(from: AgoraEduContextStreamInfo?, to: AgoraEduContextStreamInfo?) {
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
    func onMemberViewRequestRenderOnView(view: UIView,
                                         streamID: String,
                                         userUUID: String) {
        let renderConfig = AgoraEduContextRenderConfig()
        renderConfig.mode = .hidden
        contextPool.stream.setRemoteVideoStreamSubscribeLevel(streamUuid: streamID,
                                                              level: .low)
        contextPool.media.startRenderVideo(view: view,
                                           renderConfig: renderConfig,
                                           streamUuid: streamID)
    }
    
    func onMemberViewRequestCancelRender(streamID: String,
                                         userUUID: String) {
        contextPool.media.stopRenderVideo(streamUuid: streamID)
        print("cancel render")
    }
}

// MARK: - AgoraEduUserHandler
extension AgoraOneToOneRenderUIController: AgoraEduUserHandler {
    func onUserRewarded(user: AgoraEduContextUserInfo,
                        rewardCount: Int,
                        operator: AgoraEduContextUserInfo) {
        self.showRewardAnimation()
    }
}
// MARK: - AgoraEduUserHandler
extension AgoraOneToOneRenderUIController: AgoraEduMediaHandler {
    func onVolumeUpdated(volume: Int,
                         streamUuid: String) {
        if teacherView.item?.streamUUID == streamUuid {
            self.teacherView.setVolumeValue(volume)
        } else {
            self.studentView.setVolumeValue(volume)
        }
    }
}
// MARK: - AgoraEduStreamHandler
extension AgoraOneToOneRenderUIController: AgoraEduStreamHandler {
    func onStreamJoined(stream: AgoraEduContextStreamInfo,
                        operator: AgoraEduContextUserInfo?) {
        self.updateCoHosts()
    }
    
    func onStreamUpdated(stream: AgoraEduContextStreamInfo,
                         operator: AgoraEduContextUserInfo?) {
        if stream.streamUuid == currentStream?.streamUuid {
            self.currentStream = stream
        }
        self.updateCoHosts()
    }
    
    func onStreamLeft(stream: AgoraEduContextStreamInfo,
                      operator: AgoraEduContextUserInfo?) {
        self.updateCoHosts()
    }
}
// MARK: - AgoraEduRoomHandler
extension AgoraOneToOneRenderUIController: AgoraEduRoomHandler {
    func onRoomJoinedSuccess(roomInfo: AgoraEduContextRoomInfo) {
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
            make?.centerX.equalTo()(0)
            make?.width.equalTo()(view)
            make?.height.equalTo()(view.mas_width)?.multipliedBy()(190.0/340.0)
        }
        studentView.mas_remakeConstraints { make in
            make?.top.equalTo()(teacherView.mas_bottom)?.offset()(2)
            make?.centerX.equalTo()(0)
            make?.width.height().equalTo()(teacherView)
        }
    }
}

