//
//  AgoraRenderMemberView.swift
//  AgoraEduUI
//
//  Created by DoubleCircle on 2022/4/24.
//

import AgoraUIBaseViews
import FLAnimatedImage

class AgoraRenderMaskView: UIView {
    let imageView = UIImageView(frame: .zero)
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        let ui = AgoraUIGroup()
        
        backgroundColor = ui.color.render_cell_bg_color
        imageView.image = UIImage.agedu_named("ic_member_no_user")
        layer.cornerRadius = ui.frame.small_render_cell_corner_radius
        layer.borderWidth = ui.frame.render_cell_border_width
        layer.borderColor = ui.color.render_mask_border_color
        
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
    private lazy var waveView: FLAnimatedImageView =  {
        guard let bundle = Bundle.agora_bundle(object: self,
                                               resource: "AgoraEduUI"),
              let url = bundle.url(forResource: "img_hands_wave",
                                   withExtension: "gif"),
              let data = try? Data(contentsOf: url) else {
            fatalError()
        }
        
        let animatedImage = FLAnimatedImage(animatedGIFData: data)
        let v = FLAnimatedImageView()
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
        let ui = AgoraUIGroup()
        addSubview(videoMaskView)
        
        videoView.backgroundColor = ui.color.render_cell_bg_color
        videoView.layer.borderWidth = ui.frame.render_cell_border_width
        videoView.layer.borderColor = ui.color.render_view_border_color
        videoView.layer.cornerRadius = ui.frame.small_render_cell_corner_radius
        addSubview(videoView)
        
        nameLabel.textColor = ui.color.render_label_color
        nameLabel.font = UIFont.systemFont(ofSize: 12)
        nameLabel.layer.shadowColor = ui.color.render_label_shadow_color
        nameLabel.layer.shadowOffset = CGSize(width: 0,
                                              height: 1)
        nameLabel.layer.shadowOpacity = ui.color.render_label_shadow_opacity
        nameLabel.layer.shadowRadius = ui.frame.render_label_shadow_radius
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
        videoMaskView.layer.cornerRadius = AgoraFrameGroup().small_render_cell_corner_radius
        videoMaskView.imageView.image = UIImage.agedu_named("ic_member_no_user")
        contentView.addSubview(videoMaskView)
        videoMaskView.mas_makeConstraints { make in
            make?.left.right().top().bottom().equalTo()(0)
        }
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}
