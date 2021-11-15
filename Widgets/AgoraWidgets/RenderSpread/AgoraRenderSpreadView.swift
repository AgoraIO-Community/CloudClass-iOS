//
//  PaintingRenderSpreadView.swift
//  AgoraEduUI
//
//  Created by Jonathan on 2021/10/10.
//

import AgoraUIBaseViews
import Masonry

protocol AgoraRenderSpreadViewDelegate: NSObjectProtocol {
    func onCloseSpreadView(_ view: AgoraBaseUIView)
}

class AgoraRenderSpreadView: AgoraBaseUIView {
    
    weak var delegate: AgoraRenderSpreadViewDelegate?
    /** 相机状态*/
    private lazy var cameraStateView: AgoraBaseUIImageView = {
        let cameraStateView = AgoraBaseUIImageView(image:GetWidgetImage(object: self,
                                                                        "default_offline"))
        cameraStateView.contentMode = .scaleAspectFit
        cameraStateView.isHidden = true
        return cameraStateView
    }()
    
    /** 渲染画布*/
    private var videoView: AgoraBaseUIView!
    /** 麦克风状态*/
    private var micView: AgoraBaseUIImageView!
    /** 声音大小*/
    private var volumeView: AgoraSpreadVolumeView!
    /** 名字*/
    private var nameLabel: AgoraBaseUILabel!
    
    private var renderInfo: AgoraSpreadRenderViewInfo? {
        didSet {
            // name
            guard let value = renderInfo else {
                return
            }
            
            self.nameLabel.text = value.userName
            updateMic()
            updateCamera()
        }
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        createViews()
        createConstrains()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    public func getVideoCanvas() -> AgoraBaseUIView {
        return videoView
    }
    
    public func updateVolume(volume: CGFloat) {
        volumeView.volume = volume / 200.0
    }
    
    public func updateRenderInfo(renderInfo: AgoraSpreadRenderViewInfo) {
        self.renderInfo = renderInfo
    }
    
    // MARK: - Creations
    private func createViews() {
        backgroundColor = UIColor.white
        clipsToBounds = true
        
        let doubleTap = UITapGestureRecognizer(target: self,
                                               action: #selector(onDoubleClickView(_:)))
        doubleTap.numberOfTapsRequired = 2
        doubleTap.numberOfTouchesRequired = 1
        doubleTap.delaysTouchesBegan = true
        addGestureRecognizer(doubleTap)
        
        let tap = UITapGestureRecognizer(target: self,
                                         action: #selector(onClickView(_:)))
        tap.numberOfTapsRequired = 1
        tap.numberOfTouchesRequired = 1
        tap.delaysTouchesBegan = true
        addGestureRecognizer(tap)
        // 优先检测双击
        tap.require(toFail: doubleTap)
        
        videoView = AgoraBaseUIView(frame: .zero)
        videoView.backgroundColor = .clear
        addSubview(videoView)
        
        addSubview(cameraStateView)
        
        micView = AgoraBaseUIImageView(image: GetWidgetImage(object: self,
                                                             "ic_mic_status_on"))
        addSubview(micView)
        
        nameLabel = AgoraBaseUILabel(frame: .zero)
        nameLabel.textColor = UIColor.white
        nameLabel.font = UIFont.systemFont(ofSize: 12)
        nameLabel.layer.shadowColor = UIColor(rgb: 0x0D1D3D,
                                              alpha: 0.8).cgColor
        nameLabel.layer.shadowOffset = CGSize(width: 0,
                                              height: 1)
        nameLabel.layer.shadowOpacity = 1
        nameLabel.layer.shadowRadius = 2
        addSubview(nameLabel)
        
        volumeView = AgoraSpreadVolumeView(frame: .zero)
        volumeView.volume = 0
        addSubview(volumeView)
    }
    
    // MARK: - Actions
    @objc private func onClickView(_ sender: UITapGestureRecognizer) {
        
    }
    
    @objc private func onDoubleClickView(_ sender: UITapGestureRecognizer) {
        
        delegate?.onCloseSpreadView(self)
    }
}

private extension AgoraRenderSpreadView {
    func createConstrains() {
        videoView.mas_makeConstraints { make in
            make?.left.right().top().bottom().equalTo()(self)
        }
        cameraStateView.mas_makeConstraints { make in
            make?.left.right().top().bottom().equalTo()(self)
        }
        micView.mas_makeConstraints { make in
            make?.left.equalTo()(2)
            make?.bottom.equalTo()(-2)
            make?.width.height().equalTo()(14)
        }
        volumeView.mas_makeConstraints { make in
            make?.width.equalTo()(8.4)
            make?.height.equalTo()(32)
            make?.centerX.equalTo()(micView)
            make?.bottom.equalTo()(micView.mas_top)?.offset()(-4)
        }
        nameLabel.mas_makeConstraints { make in
            make?.centerY.equalTo()(micView)
            make?.left.equalTo()(micView.mas_right)?.offset()(2)
            make?.right.lessThanOrEqualTo()(self)
        }
    }
    
    func updateMic() {
        guard let value = renderInfo else {
            return
        }
        switch value.microState {
        // 麦克风正常
        case .available:
            var imageName: String
            
            // 是否有流
            if value.hasAudio {
                imageName = "micro_enable_on"
            } else {
                imageName = "micro_enable_off"
            }
            micView.image = GetWidgetImage(object: self,
                                           imageName)
            volumeView.isHidden = !value.hasAudio
            
        // 麦克风不可用
        case .invalid, .close:
            let imageName = "micro_disable_off"
            micView.image = GetWidgetImage(object: self,
                                           imageName)
            volumeView.isHidden = true
        }
    }
    
    func updateCamera() {
        guard let value = renderInfo else {
            return
        }
        // camera
        if value.cameraState == .available,
                  value.hasVideo == false {
            cameraStateView.isHidden = false
            videoView.isHidden = true
            cameraStateView.image = GetWidgetImage(object: self,
                                                   "default_novideo")
        } else if value.cameraState == .invalid {
            cameraStateView.isHidden = false
            videoView.isHidden = true
            cameraStateView.image = GetWidgetImage(object: self,
                                                   "default_baddevice")
        } else if value.cameraState == .close {
            cameraStateView.isHidden = false
            videoView.isHidden = true
            cameraStateView.image = GetWidgetImage(object: self,
                                                   "default_close")
        } else {
            cameraStateView.isHidden = true
            videoView.isHidden = false
        }
    }
}
