//
//  VcrRoomCDNRenderUIController.swift
//  AgoraEduUI
//
//  Created by Jonathan on 2022/6/27.
//

import AgoraEduContext
import UIKit
import AVFoundation

class VcrMixStreamCDNRenderUIController: UIViewController {
    
    private let contextPool: AgoraEduContextPool
    
    let videoPlayer = AVPlayer()
    
    lazy var playerLayer: AVPlayerLayer = {
       return AVPlayerLayer(player: videoPlayer)
    }()
    
    let placeHolderView = VcrMixStreamCDNEmptyView()
        
    var playerItem: AVPlayerItem?
    
    var cdnURL: String? {
        didSet {
            guard cdnURL != oldValue else {
                return
            }
            self.updateVideoState()
        }
    }
    
    var recordingState: FcrRecordingState = .stopped {
        didSet {
            guard recordingState != oldValue else {
                return
            }
            self.updateVideoState()
        }
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
    
    private func updateVideoState() {
        videoPlayer.pause()
        if recordingState == .started,
           let url = URL.init(string: cdnURL) {
            placeHolderView.isHidden = true
            let asset = AVURLAsset(url: url)
            playerItem = AVPlayerItem(asset: asset)
            videoPlayer.replaceCurrentItem(with: playerItem)
            videoPlayer.play()
        } else {
            placeHolderView.isHidden = false
        }
    }
}
// MARK: - AgoraEduRoomHandler
extension VcrMixStreamCDNRenderUIController: AgoraEduRoomHandler {
    func onJoinRoomSuccess(roomInfo: AgoraEduContextRoomInfo) {
        if let url = contextPool.room.getRecordingStreamUrlList()["hls"] {
            cdnURL = url
        }
    }
    
    func onRecordingStreamUrlListUpdated(urlList: [String : String]) {
        cdnURL = urlList["hls"]
    }
    
    func onRecordingStateUpdated(state: FcrRecordingState) {
        recordingState = state
    }
}
// VcrMixStreamCDNEmptyView
class VcrMixStreamCDNEmptyView: UIView {
    
    let imageView = UIImageView(image: UIImage.agedu_named("window_no_user"))
    
    let label = UILabel()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        createViews()
        createConstrains()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func createViews() {
        backgroundColor = .white
        addSubview(imageView)
        
        label.text = "fcr_vocational_teacher_absent".agedu_localized()
        label.font = FcrUIFontGroup.font12
        label.textColor = FcrUIColorGroup.textLevel2Color
        addSubview(label)
    }
    
    func createConstrains() {
        imageView.mas_makeConstraints { make in
            make?.width.height().equalTo()(100)
            make?.centerX.equalTo()(0)
            make?.centerY.equalTo()(-35)
        }
        label.mas_makeConstraints { make in
            make?.top.equalTo()(imageView.mas_bottom)?.offset()(4)
            make?.centerX.equalTo()(0)
        }
    }
}
