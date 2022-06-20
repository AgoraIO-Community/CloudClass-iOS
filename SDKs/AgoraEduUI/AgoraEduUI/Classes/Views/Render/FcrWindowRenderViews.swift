//
//  FcrWindowRenderViews.swift
//  AgoraEduUI
//
//  Created by Cavan on 2022/6/2.
//

import AgoraUIBaseViews
import FLAnimatedImage

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
        let ui = AgoraUIGroup()
        
        label.textColor = UIColor.white
        label.font = UIFont.systemFont(ofSize: 12)
        
        label.layer.shadowColor = ui.color.render_label_shadow_color
        label.layer.shadowOffset = CGSize(width: 0,
                                          height: 1)
        
        label.layer.shadowOpacity = ui.color.render_label_shadow_opacity
        label.layer.shadowRadius = ui.frame.render_label_shadow_radius
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
        imageView.image = UIImage.agedu_named("ic_member_no_user")
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
        animaView.image = UIImage.agedu_named("ic_mic_status_volume")
        progressLayer.strokeColor = UIColor.white.cgColor
    }
}

class FcrWindowRenderVideoView: UIView {
    var renderingStream: String?
}

class FcrWindowRenderView: UIView {
    private let waveView = FLAnimatedImageView()
    
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
        addSubview(waveView)
        addSubview(rewardView)
        addSubview(boardPrivilegeView)
        
        waveView.isHidden = true
        
        guard let bundle = Bundle.agora_bundle(object: self,
                                               resource: "AgoraEduUI"),
              let url = bundle.url(forResource: "img_hands_wave",
                                   withExtension: "gif"),
              let data = try? Data(contentsOf: url) else {
            fatalError()
        }
        
        let animatedImage = FLAnimatedImage(animatedGIFData: data)
        
        waveView.animatedImage = animatedImage
    }
    
    func initViewFrame() {
        videoView.mas_makeConstraints { make in
            make?.left.right().top().bottom()?.equalTo()(0)
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
        let ui = AgoraUIGroup()
        
        nameLabel.textColor = ui.color.render_label_color
        nameLabel.font = UIFont.systemFont(ofSize: 12)
        nameLabel.layer.shadowColor = ui.color.render_label_shadow_color
        nameLabel.layer.shadowOffset = CGSize(width: 0,
                                              height: 1)
        nameLabel.layer.shadowOpacity = ui.color.render_label_shadow_opacity
        nameLabel.layer.shadowRadius = ui.frame.render_label_shadow_radius
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
        let ui = AgoraUIGroup()
        
        renderView.backgroundColor = ui.color.render_cell_bg_color
        renderView.layer.cornerRadius = ui.frame.render_cell_corner_radius
        renderView.layer.borderWidth = ui.frame.render_cell_border_width
        renderView.layer.borderColor = ui.color.render_mask_border_color
        
        noneView.backgroundColor = ui.color.render_cell_bg_color
        noneView.layer.cornerRadius = ui.frame.render_cell_corner_radius
        noneView.layer.borderWidth = ui.frame.render_cell_border_width
        noneView.layer.borderColor = ui.color.render_mask_border_color
    }
    
    func addRenderView() {
        contentView.addSubview(renderView)
    }
    
    func removeRenderView() {
        renderView.removeFromSuperview()
    }
}
