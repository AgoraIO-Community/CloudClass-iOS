//
//  AgoraRenderMemberView.swift
//  AgoraEduUI
//
//  Created by DoubleCircle on 2022/4/24.
//

import AgoraUIBaseViews

class AgoraRenderMaskView: UIView {
    let imageView = UIImageView(frame: .zero)
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        backgroundColor = FcrUIColorGroup.systemBackgroundColor
        imageView.image = UIImage.agedu_named("window_no_user")
        layer.cornerRadius = FcrUIFrameGroup.windowCornerRadius
        layer.borderWidth = FcrUIFrameGroup.borderWidth
        layer.borderColor = FcrUIColorGroup.systemDividerColor.cgColor
        
        addSubview(imageView)
        imageView.mas_makeConstraints { make in
            make?.width.height().equalTo()(self.mas_height)?.multipliedBy()(0.38)
            make?.center.equalTo()(0)
        }
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

class AgoraRenderMemberView: UIView {
    // views 视图层级递增
    let videoView = UIView()
    let videoMaskView = AgoraRenderMaskView(frame: .zero)
    let nameLabel = UILabel()
    let micView = AgoraRenderMemberMicView()
    /** 举手动画视图*/
    private lazy var waveView: AGAnimatedImageView =  {
        guard let bundle = Bundle.agora_bundle(object: self,
                                               resource: "AgoraEduUI"),
              let url = bundle.url(forResource: "img_hands_wave",
                                   withExtension: "gif"),
              let data = try? Data(contentsOf: url) else {
            fatalError()
        }
        
        let animatedImage = AGAnimatedImage(animatedGIFData: data)
        let v = AGAnimatedImageView()
        v.animatedImage = animatedImage
        
        self.addSubview(v)
        v.mas_makeConstraints { make in
            make?.width.height().equalTo()(self.mas_height)
            make?.centerX.bottom().equalTo()(0)
        }
        return v
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        createViews()
        createConstraint()
    }
    
    func updateVolume(_ volume: Int) {
        micView.setVolume(volume)
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
private extension AgoraRenderMemberView {
    func createViews() {
        backgroundColor = .clear
        
        addSubview(videoMaskView)
        
        videoView.backgroundColor = FcrUIColorGroup.systemBackgroundColor
        videoView.layer.borderWidth = FcrUIFrameGroup.borderWidth
        videoView.layer.cornerRadius = FcrUIFrameGroup.windowCornerRadius
        addSubview(videoView)
        
        nameLabel.textColor = FcrUIColorGroup.textContrastColor
        nameLabel.font = FcrUIFontGroup.font12
        nameLabel.layer.shadowColor = FcrUIColorGroup.textShadowColor.cgColor
        nameLabel.layer.shadowOffset = FcrUIColorGroup.labelShadowOffset
        nameLabel.layer.shadowOpacity = FcrUIColorGroup.shadowOpacity
        nameLabel.layer.shadowRadius = FcrUIColorGroup.labelShadowRadius
        addSubview(nameLabel)
        
        addSubview(micView)
    }
    
    func createConstraint() {
        videoView.mas_makeConstraints { make in
            make?.left.right().top().bottom()?.equalTo()(0)
        }
        videoMaskView.mas_makeConstraints { make in
            make?.left.right().top().bottom()?.equalTo()(0)
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
    }
}


class AgoraRenderMemberCell: UICollectionViewCell {
    
    private let videoMaskView = AgoraRenderMaskView(frame: .zero)
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        contentView.backgroundColor = .clear
        videoMaskView.layer.cornerRadius = FcrUIFrameGroup.windowCornerRadius
        videoMaskView.clipsToBounds = true
        videoMaskView.imageView.image = UIImage.agedu_named("window_no_user")
        contentView.addSubview(videoMaskView)
        videoMaskView.mas_makeConstraints { make in
            make?.left.right().top().bottom().equalTo()(0)
        }
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}
