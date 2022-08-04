//
//  VcrHostingPlayerUIController.swift
//  AgoraEduUI
//
//  Created by Jonathan on 2022/6/27.
//

import AgoraUIBaseViews
import AgoraEduContext
import AudioToolbox
import AVFoundation

/** 托管课堂播放业务的控制器*/
class VcrHostingPlayerUIComponent: UIViewController {
    
    private var contextPool: AgoraEduContextPool
    
    public weak var roomDelegate: FcrUISceneExit?
    
    private var sceneInfo: HostingSceneInfo? {
        didSet {
            guard sceneInfo != oldValue else {
                return
            }
            if let info = sceneInfo,
               let url = URL(string: info.videoURL) {
                videoPlayer.pause()
                guard let asset = getAssetFromLessonInfo(info: info) else {
                    // 媒体资源不可用
                    return
                }
                playerItem = AVPlayerItem(asset: asset)
                videoPlayer.replaceCurrentItem(with: playerItem)
                updateVideoProgress()
            } else {
                placeHolderView.isHidden = false
                videoPlayer.pause()
            }
        }
    }
    
    let videoPlayer = AVPlayer()
    
    lazy var playerLayer: AVPlayerLayer = {
       return AVPlayerLayer(player: videoPlayer)
    }()
    
    var playerItem: AVPlayerItem? {
        didSet {
            guard playerItem != oldValue else {
                return
            }
            oldValue?.removeObserver(self,
                                     forKeyPath: "status")
            playerItem?.addObserver(self,
                                    forKeyPath: "status",
                                    options: .new,
                                    context: nil)
        }
    }
    
    let placeHolderView = VcrMixStreamCDNEmptyView()
    
    deinit {
        playerItem = nil
        NotificationCenter.default.removeObserver(self)
    }
    
    init(context: AgoraEduContextPool) {
        contextPool = context
        
        super.init(nibName: nil,
                   bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.layer.addSublayer(playerLayer)
        view.addSubview(placeHolderView)
        updateViewProperties()
        placeHolderView.mas_makeConstraints { make in
            make?.left.right().top().bottom().equalTo()(0)
        }
        setupNotifications()
        contextPool.room.registerRoomEventHandler(self)
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        playerLayer.frame = view.bounds
    }
    
    func updateViewProperties() {
        let config = UIConfig.streamWindow
        
        view.backgroundColor = config.backgroundColor
        placeHolderView.backgroundColor = config.backgroundColor
        placeHolderView.layer.cornerRadius = config.cornerRadius
        placeHolderView.layer.borderWidth = config.borderWidth
        placeHolderView.layer.borderColor = config.borderColor
    }
}
// MARK: - Private
private extension VcrHostingPlayerUIComponent {
    func setupNotifications() {
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(playBackFinished(_:)),
                                               name: .AVPlayerItemDidPlayToEndTime,
                                               object: nil)
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(appDidBecomeActive(_:)),
                                               name: UIApplication.didBecomeActiveNotification,
                                               object: nil)
    }
    
    func getAssetFromLessonInfo(info: HostingSceneInfo) -> AVAsset? {
        if let url = URL(string: info.videoURL) {
            let asset = AVURLAsset(url: url)
            if asset.isPlayable {
                // 主播放资源可用
                return asset
            }
        }
        if let url = URL(string: info.reserveVideoURL) {
            let asset = AVURLAsset(url: url)
            if asset.isPlayable {
                // 备用播放资源可用
                return asset
            }
        }
        return nil
    }
    
    func fetchHostingLesson() {
        guard let roomProperties = contextPool.room.getRoomProperties(),
              let hostingLesson = roomProperties["hostingScene"] as? [String: Any],
              let videoURL = hostingLesson["videoURL"] as? String
        else {
            // 未接收到伪直播数据
            return
        }
        let reserveVideoURL = hostingLesson["reserveVideoURL"] as? String
        sceneInfo = HostingSceneInfo(videoURL: videoURL,
                                     reserveVideoURL: reserveVideoURL)
    }
    
    func updateVideoProgress() {
        let classInfo = contextPool.room.getClassInfo()
        switch classInfo.state {
        case .before:
            placeHolderView.isHidden = false
            break
        case .during:
            placeHolderView.isHidden = true
            seekVideoByLessonProgress()
        case .after:
            placeHolderView.isHidden = true
            notiClassIsOver()
        default: break
        }
    }
    // 将视频seek到开课时间
    // 1. 视频在时长之内，可以正常播放
    // 2. 超出视频时长，课程结束
    func seekVideoByLessonProgress() {
        let classInfo = contextPool.room.getClassInfo()
        let serverNow = contextPool.monitor.getSyncTimestamp()
        // 获取已经开课的时间
        let time = serverNow - classInfo.startTime
        let mediaTime = CMTime(value: time, timescale: 1000)
        videoPlayer.seek(to: mediaTime,
                         toleranceBefore: .zero,
                         toleranceAfter: .zero) { finish in
            self.videoPlayer.play()
        }
    }
    // 课程已结束，提示用户离开教室
    func notiClassIsOver() {
        AgoraAlertModel()
            .setTitle("fcr_room_class_over_notice".agedu_localized())
            .setMessage("fcr_room_class_over".agedu_localized())
            .addAction(action: AgoraAlertAction(title: "fcr_room_class_leave_sure".agedu_localized(), action: {
                self.roomDelegate?.exitScene(reason: .normal,
                                                 type: .main)
            }))
            .show(in: self)
    }
    
    func setupAudioSession() {
        do {
            try AVAudioSession.sharedInstance().setCategory(.playback,
                                                            options: [.defaultToSpeaker])
            try AVAudioSession.sharedInstance().setActive(true)
        } catch {
            print("mix stream: audio session set \(error)")
        }
    }
}
// MARK: - Player
extension VcrHostingPlayerUIComponent {
    @objc func appDidBecomeActive(_ noti: Notification) {
        seekVideoByLessonProgress()
    }
    
    @objc func playBackFinished(_ noti: Notification) {
        videoPlayer.seek(to: .zero)
        notiClassIsOver()
    }
    
    override func observeValue(forKeyPath keyPath: String?,
                               of object: Any?,
                               change: [NSKeyValueChangeKey : Any]?,
                               context: UnsafeMutableRawPointer?) {
        guard let playerItem = object as? AVPlayerItem,
              keyPath == "status"
        else {
            return
        }
        switch playerItem.status {
        case .unknown:
            break
        case .readyToPlay:
            break
        case .failed:
            break
        }
    }
}
// MARK: - AgoraEduRoomHandler
extension VcrHostingPlayerUIComponent: AgoraEduRoomHandler {
    func onJoinRoomSuccess(roomInfo: AgoraEduContextRoomInfo) {
        DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
            // 因为有服务抢音频通道，所以延时1秒进行扬声器通道播放
            self.setupAudioSession()
        }
        fetchHostingLesson()
    }
    
    func onClassStateUpdated(state: AgoraEduContextClassState) {
        updateVideoProgress()
    }
}
// 伪直播视频的播放信息
struct HostingSceneInfo: Equatable {
    // 主地址视频的URL
    let videoURL: String
    // 备用地址视频的URL
    let reserveVideoURL: String?
}
