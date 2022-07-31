//
//  FcrWindowRenderViews.swift
//  AgoraEduUI
//
//  Created by Cavan on 2022/6/2.
//

import AgoraUIBaseViews

class FcrWindowRenderRewardView: UIView, AgoraUIContentContainer {
    let imageView = UIImageView(frame: .zero)
    let label = UILabel(frame: .zero)
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        initViews()
        initViewFrame()
        updateViewProperties()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func initViews() {
        addSubview(imageView)
        addSubview(label)
        
        label.textAlignment = .right
    }
    
    func initViewFrame() {
        imageView.mas_makeConstraints { make in
            make?.left.top().bottom().equalTo()(0)
            make?.width.equalTo()(self.mas_width)?.multipliedBy()(0.5)
        }
        
        label.mas_makeConstraints { make in
            make?.top.bottom().equalTo()(0)
            make?.right.equalTo()(-2)
            make?.width.equalTo()(self.mas_width)?.multipliedBy()(0.5)
        }
    }
    
    func updateViewProperties() {
        let config = UIConfig.studentVideo.label
        
        label.textColor = config.color
        label.font = config.font
        
        label.layer.shadowColor = config.shadowColor
        label.layer.shadowOffset = config.shadowOffset
        label.layer.shadowOpacity = config.shadowOpacity
        label.layer.shadowRadius = config.shadowRadius
    }
}

class FcrWindowRenderNoneView: UIView, AgoraUIContentContainer {
    let imageView = UIImageView()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        initViews()
        initViewFrame()
        updateViewProperties()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func initViews() {
        addSubview(imageView)
    }
    
    func initViewFrame() {
        imageView.mas_makeConstraints { make in
            make?.width.height().equalTo()(self.mas_height)?.multipliedBy()(0.53)
            make?.center.equalTo()(0)
        }
    }
    
    func updateViewProperties() {
        imageView.image = UIConfig.studentVideo.mask.noUserImage
    }
}

class FcrWindowRenderMicView: UIView, AgoraUIContentContainer {
    private let progressLayer = CAShapeLayer()
    
    let animaView = UIImageView()
    let imageView = UIImageView()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        initViews()
        initViewFrame()
        updateViewProperties()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        progressLayer.frame = bounds
        let path = UIBezierPath()

        path.move(to: CGPoint(x: bounds.midX,
                              y: bounds.maxY))

        path.addLine(to: CGPoint(x: bounds.midX,
                                 y: bounds.minY))

        progressLayer.lineWidth = bounds.width
        progressLayer.path = path.cgPath
    }
        
    public func updateVolume(_ value: Int) {
        animaView.isHidden = (value == 0)
        
        let floatValue = CGFloat(value)
        progressLayer.strokeEnd = CGFloat(floatValue - 55.0) / (255.0 - 55.0)
    }
    
    func initViews() {
        addSubview(imageView)
        addSubview(animaView)
        
        animaView.isHidden = true

        progressLayer.lineCap = .square
        progressLayer.strokeStart = 0
        progressLayer.strokeEnd = 0
        animaView.layer.mask = progressLayer
    }
    
    func initViewFrame() {
        imageView.mas_makeConstraints { make in
            make?.left.right().top().bottom().equalTo()(0)
        }
        
        animaView.mas_makeConstraints { make in
            make?.left.right().top().bottom().equalTo()(0)
        }
    }
    
    func updateViewProperties() {
        animaView.image = UIConfig.studentVideo.mask.micVolumeImage
        progressLayer.strokeColor = UIColor.white.cgColor
    }
}

class FcrWindowRenderVideoView: UIView {
    var renderingStream: String?
}

class FcrWindowRenderView: UIView {
    private let waveView = AGAnimatedImageView()
    
    let videoView = FcrWindowRenderVideoView()
    let videoMaskView = UIImageView(frame: .zero)
    let nameLabel = UILabel()
    let micView = FcrWindowRenderMicView()
    let rewardView = FcrWindowRenderRewardView()
    let boardPrivilegeView = UIImageView()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        initViews()
        initViewFrame()
        updateViewProperties()
    }
    
    func updateVolume(_ volume: Int) {
        micView.updateVolume(volume)
    }
    
    func startWaving() {
        guard !waveView.isAnimating else {
            return
        }
        waveView.startAnimating()
        waveView.isHidden = false
    }
    
    func stopWaving() {
        guard waveView.isAnimating else {
            return
        }
        waveView.isHidden = true
        waveView.stopAnimating()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

// MARK: - private
extension FcrWindowRenderView: AgoraUIContentContainer {
    func initViews() {
        addSubview(videoView)
        addSubview(videoMaskView)
        addSubview(nameLabel)
        addSubview(micView)
        
        let config = UIConfig.studentVideo.waveHands
        waveView.agora_enable = config.enable
        waveView.agora_visible = config.visible
        addSubview(waveView)
        addSubview(rewardView)
        addSubview(boardPrivilegeView)
        
        waveView.isHidden = true
    }
    
    func initViewFrame() {
        let borderWidth = UIConfig.studentVideo.cell.borderWidth
        videoView.mas_makeConstraints { make in
            make?.center.equalTo()(0)
            make?.width.height().equalTo()(self)?.offset()(-borderWidth)
        }
        
        videoMaskView.mas_makeConstraints { make in
            make?.width.height().equalTo()(self.mas_height)?.multipliedBy()(0.53)
            make?.center.equalTo()(0)
        }
        
        micView.mas_makeConstraints { make in
            make?.left.equalTo()(2)
            make?.bottom.equalTo()(-2)
            make?.width.height().equalTo()(16)
        }
        
        nameLabel.mas_makeConstraints { make in
            make?.centerY.equalTo()(micView)
            make?.left.equalTo()(micView.mas_right)?.offset()(2)
            make?.right.lessThanOrEqualTo()(0)
        }
        
        waveView.mas_makeConstraints { make in
            make?.width.height().equalTo()(self.mas_height)
            make?.centerX.bottom().equalTo()(0)
        }
        
        rewardView.mas_makeConstraints { make in
            make?.right.equalTo()(-2)
            make?.top.equalTo()(5)
            make?.width.equalTo()(32)
            make?.height.equalTo()(16)
        }
        
        boardPrivilegeView.mas_makeConstraints { make in
            make?.right.bottom().equalTo()(-2)
            make?.width.equalTo()(16)
            make?.height.equalTo()(18)
        }
    }
    
    func updateViewProperties() {
        // 目前studentVideo.nameLabel同teacherVideo.nameLabel
        let config = UIConfig.studentVideo
        
        nameLabel.textColor = config.label.color
        nameLabel.font = config.label.font
        
        nameLabel.layer.shadowColor = config.label.shadowColor
        nameLabel.layer.shadowOffset = config.label.shadowOffset
        nameLabel.layer.shadowOpacity = config.label.shadowOpacity
        nameLabel.layer.shadowRadius = config.label.shadowRadius
        
        guard let url = config.waveHands.gifUrl,
              let data = try? Data(contentsOf: url) else {
            return
        }
        
        let animatedImage = AGAnimatedImage(animatedGIFData: data)
        
        waveView.animatedImage = animatedImage
    }
}

class FcrWindowRenderCell: UICollectionViewCell, AgoraUIContentContainer {
    static let cellId: String = "FcrWindowRenderCell"
    
    let renderView = FcrWindowRenderView()
    
    let noneView = FcrWindowRenderNoneView(frame: .zero)
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        initViews()
        initViewFrame()
        updateViewProperties()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func initViews() {
        contentView.addSubview(noneView)
        contentView.addSubview(renderView)
    }
    
    func initViewFrame() {
        noneView.mas_makeConstraints { make in
            make?.right.left().top().bottom().equalTo()(0)
        }
        
        renderView.mas_makeConstraints { make in
            make?.right.left().top().bottom().equalTo()(0)
        }
    }
    
    func updateViewProperties() {
        // 目前studentVideo.cell同teacherVideo.cell
        let config = UIConfig.studentVideo
        
        renderView.backgroundColor = config.cell.backgroundColor
        renderView.layer.cornerRadius = config.cell.cornerRadius
        renderView.layer.borderWidth = config.cell.borderWidth
        renderView.layer.borderColor = config.cell.borderColor
        
        noneView.backgroundColor = config.mask.backgroundColor
        noneView.layer.cornerRadius = config.cell.cornerRadius
        noneView.layer.borderWidth = config.cell.borderWidth
        noneView.layer.borderColor = config.cell.borderColor
    }
    
    func addRenderView() {
        contentView.addSubview(renderView)
    }
    
    func removeRenderView() {
        renderView.removeFromSuperview()
    }
}
