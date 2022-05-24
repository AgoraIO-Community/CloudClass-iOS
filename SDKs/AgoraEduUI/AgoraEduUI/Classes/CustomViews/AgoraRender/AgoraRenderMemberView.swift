//
//  AgoraRenderMemberView.swift
//  AgoraEduUI
//
//  Created by Jonathan on 2021/12/9.
//

import UIKit
import AgoraUIBaseViews
import FLAnimatedImage

class AgoraRenderMemberModel: NSObject {
    enum AgoraRenderMediaState {
        // 开，关，禁用，损坏
        case on, off, forbidden, broken
    }
    // 是否开启渲染
    var rendEnable = true {
        didSet {
            if rendEnable != oldValue {
                self.onUpdateRenderEnable?(rendEnable)
            }
        }
    }
    
    var uuid: String?
    var name: String = "" {
        didSet {
            if name != oldValue {
                self.onUpdateName?(name)
            }
        }
    }
    var volume: Int = 0 {
        didSet {
            if volume != oldValue {
                self.onUpdateVolume?(volume)
            }
        }
    }
    var streamID: String? {
        didSet {
            if streamID != oldValue {
                self.onUpdateStreamID?(streamID)
            }
        }
    }
    var audioState: AgoraRenderMediaState = .on {
        didSet {
            if audioState != oldValue {
                self.onUpdateAudioState?(audioState)
            }
        }
    }
    var videoState: AgoraRenderMediaState = .on {
        didSet {
            if videoState != oldValue {
                self.onUpdateVideoState?(videoState)
            }
        }
    }
    var isHandsUp: Bool = false {
        didSet {
            if isHandsUp != oldValue {
                self.onUpdateHandsUpState?(isHandsUp)
            }
        }
    }
    var rewardCount: Int = 0 {
        didSet {
            if rewardCount != oldValue {
                self.onUpdateRewardCount?(rewardCount)
            }
        }
    }
    var boardAuth: Bool = false {
        didSet {
            if boardAuth != oldValue {
                self.onUpdateBoardAuth?(boardAuth)
            }
        }
    }
    /** 名字产生变化 注意使用weak*/
    var onUpdateName: ((String) -> Void)?
    /** 音量产生变化 注意使用weak*/
    var onUpdateVolume: ((Int) -> Void)?
    /** 渲染产生变化 注意使用weak*/
    var onUpdateStreamID: ((String?) -> Void)?
    /** 音频状态产生变化 注意使用weak*/
    var onUpdateAudioState: ((AgoraRenderMediaState) -> Void)?
    /** 视频状态产生变化 注意使用weak*/
    var onUpdateVideoState: ((AgoraRenderMediaState) -> Void)?
    /** 举手状态产生变化 注意使用weak*/
    var onUpdateHandsUpState: ((Bool) -> Void)?
    /** 奖励个数产生变化 注意使用weak*/
    var onUpdateRewardCount: ((Int) -> Void)?
    /** 是否开启渲染*/
    var onUpdateRenderEnable: ((Bool) -> Void)?
    /** 是否拥有白板授权*/
    var onUpdateBoardAuth: ((Bool) -> Void)?
}

protocol AgoraRenderMemberViewDelegate: NSObjectProtocol {
    func memberViewRender(memberView: AgoraRenderMemberView,
                          in view: UIView,
                          renderID: String)
    
    func memberViewCancelRender(memberView: AgoraRenderMemberView,
                                renderID: String)
}

fileprivate class AgoraRenderMaskView: UIView {
    
    public var image: UIImage? {
        didSet {
            imageView.image = image
        }
    }
    
    var promptText: String? {
        didSet {
            if let text = promptText {
                promptLabel.isHidden = false
                promptLabel.text = promptText
            } else {
                promptLabel.isHidden = true
            }
        }
    }
    
    var promptLabel: UILabel!
    private var imageView: UIImageView!
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        let ui = AgoraUIGroup()
        backgroundColor = ui.color.render_cell_bg_color
        layer.cornerRadius = max(ui.frame.one_one_to_render_cell_corner_radius,
                                 ui.frame.small_render_cell_corner_radius)
        imageView = UIImageView()
        addSubview(imageView)
        
        promptLabel = UILabel(text: promptText)
        promptLabel.textColor = UIColor(hex: 0x022491)
        promptLabel.font = .systemFont(ofSize: 12)
        
        addSubview(promptLabel)
        imageView.mas_makeConstraints { make in
            make?.width.height().equalTo()(self.mas_height)?.multipliedBy()(0.38)
            make?.center.equalTo()(0)
        }
        promptLabel.mas_makeConstraints { make in
            make?.centerX.equalTo()(0)
            make?.top.equalTo()(imageView.mas_bottom)?.offset()(3)
        }
        
        promptLabel.isHidden = false
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

class AgoraRenderMemberView: UIView {
    private weak var delegate: AgoraRenderMemberViewDelegate?
    /** 画布*/
    private var videoView: AgoraRenderMaskView!
    /** 状态遮罩*/
    private var videoMaskView: AgoraRenderMaskView!
    private let authView = UIImageView(image: UIImage.agedu_named("ic_member_auth"))
    /** 名字*/
    private var nameLabel: UILabel!
    /** 麦克风视图*/
    private var micView: AgoraRenderMicView!
    /** 奖励*/
    private var rewardImageView: UIImageView!
    private var rewardLabel: UILabel!
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
        v.isHidden = true
        self.addSubview(v)
        v.mas_makeConstraints { make in
            make?.width.height().equalTo()(self.mas_height)
            make?.centerX.bottom().equalTo()(0)
        }
        return v
    }()
    /** 停止渲染遮罩*/
    private var ableMaskView: AgoraRenderMaskView!
    /** 无人提示*/
    var promptText: String? {
        didSet {
            videoMaskView.promptText = promptText
        }
    }
    
    private var renderID: String? {
        didSet {
            guard renderID != oldValue else {
                return
            }
            if let rid = oldValue {
                self.delegate?.memberViewCancelRender(memberView: self,
                                                      renderID: rid)
            }
            if let rid = renderID {
                self.delegate?.memberViewRender(memberView: self,
                                                in: self.videoView,
                                                renderID: rid)
            }
        }
    }
    
    private var isWaving = false {
        didSet {
            if isWaving != oldValue {
                if isWaving {
                    waveView.startAnimating()
                    waveView.isHidden = false
                } else {
                    waveView.stopAnimating()
                    waveView.isHidden = true
                }
            }
        }
    }
    
    private var memberModel: AgoraRenderMemberModel?
        
    override init(frame: CGRect) {
        
        super.init(frame: frame)
        
        createViews()
        createConstraint()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    public func setModel(model: AgoraRenderMemberModel?,
                         delegate: AgoraRenderMemberViewDelegate) {
        guard model != memberModel else {
            return
        }
        if let oldModel = memberModel {
            self.resignOldModel(model: oldModel)
        }
        self.memberModel = model
        self.delegate = delegate
        if let newModel = self.memberModel {
            self.registerNewModel(model: newModel)
        } else {
            self.resetViewState()
        }
    }
}
// MARK: - Private
private extension AgoraRenderMemberView {
    func resetViewState() {
        self.updateRenderState()
        micView.setState(.off)
        self.nameLabel.text = ""
        self.rewardLabel.isHidden = true
        self.rewardImageView.isHidden = true
    }
    
    func resignOldModel(model: AgoraRenderMemberModel) {
        self.renderID = nil
        self.isWaving = false
        model.onUpdateVolume = nil
        model.onUpdateStreamID = nil
        model.onUpdateAudioState = nil
        model.onUpdateVideoState = nil
        model.onUpdateHandsUpState = nil
        model.onUpdateRewardCount = nil
        model.onUpdateRenderEnable = nil
        model.onUpdateBoardAuth = nil
    }
    
    func registerNewModel(model: AgoraRenderMemberModel) {
        self.micView.isHidden = false
        self.nameLabel.isHidden = false
        // 赋值
        self.updateName(name: model.name)
        self.updateVolume(volume: model.volume)
        self.updateAudioState(state: model.audioState)
        self.updateVideoState(state: model.videoState)
        self.updateHandsUpState(isHandsUp: model.isHandsUp)
        self.updateRewardCount(count: model.rewardCount)
        self.updateRenderEnable(enable: model.rendEnable)
        self.updateSteamId(model.streamID)
        
        // 注册回调
        model.onUpdateName = { [weak self] name in
            self?.updateName(name: name)
        }
        model.onUpdateVolume = { [weak self] volume in
            self?.updateVolume(volume: volume)
        }
        model.onUpdateStreamID = { [weak self] streamID in
            self?.updateSteamId(streamID)
        }
        model.onUpdateAudioState = { [weak self] state in
            self?.updateAudioState(state: state)
        }
        model.onUpdateVideoState = { [weak self] state in
            self?.updateVideoState(state: state)
        }
        model.onUpdateHandsUpState = { [weak self] isHandsUp in
            self?.updateHandsUpState(isHandsUp: isHandsUp)
        }
        model.onUpdateRewardCount = { [weak self] count in
            self?.updateRewardCount(count: count)
        }
        model.onUpdateRenderEnable = { [weak self] enable in
            self?.updateRenderEnable(enable: enable)
        }
        model.onUpdateBoardAuth = { [weak self] auth in
            self?.updateBoardAuth(auth)
        }
    }
    func updateName(name: String) {
        nameLabel.text = name
    }
    
    func updateVolume(volume: Int) {
        micView.setVolume(volume)
    }
    
    func updateAudioState(state: AgoraRenderMemberModel.AgoraRenderMediaState) {
        switch state {
        case .on:
            micView.setState(.on)
        case .off, .broken:
            micView.setState(.off)
        case .forbidden:
            micView.setState(.forbidden)
        }
    }
    
    func updateVideoState(state: AgoraRenderMemberModel.AgoraRenderMediaState) {
        self.updateRenderState()
    }
    
    func updateHandsUpState(isHandsUp: Bool) {
        self.isWaving = isHandsUp
    }
    
    func updateRewardCount(count: Int) {
        rewardLabel.isHidden = count == 0
        rewardImageView.isHidden = count == 0
        if count < 99 {
            rewardLabel.text = "x\(count)"
        } else {
            rewardLabel.text = "x99+"
        }
    }
    
    func updateBoardAuth(_ auth: Bool) {
        authView.isHidden = !auth
    }
    
    func updateRenderEnable(enable: Bool) {
        self.updateRenderState()
    }
    
    func updateSteamId(_ steamId: String?) {
        self.updateRenderState()
    }
    
    func updateRenderState() {
        videoMaskView.promptText = nil
        guard let model = self.memberModel else {
            ableMaskView.isHidden = true
            videoMaskView.isHidden = false
            videoMaskView.image = UIImage.agedu_named("ic_member_no_user")
            videoMaskView.promptLabel.isHidden = false
            videoMaskView.promptText = promptText
            self.renderID = nil
            return
        }
        videoMaskView.promptLabel.isHidden = true
        if model.rendEnable == false {
            self.renderID = nil
            self.ableMaskView.image = UIImage.agedu_named("ic_member_device_off")
            self.ableMaskView.isHidden = false
            self.videoMaskView.isHidden = true
        } else if model.rendEnable == true,
                  model.videoState == .on,
                  let streamId = model.streamID {
            self.renderID = streamId
            self.ableMaskView.isHidden = true
            self.videoMaskView.isHidden = true
        } else {
            self.renderID = nil
            self.ableMaskView.isHidden = true
            switch model.videoState {
            case .on:
                self.videoMaskView.isHidden = true
                self.videoMaskView.image = UIImage.agedu_named("ic_member_device_off")
            case .off, .broken:
                self.videoMaskView.isHidden = false
                self.videoMaskView.image = UIImage.agedu_named("ic_member_device_off")
            case .forbidden:
                self.videoMaskView.isHidden = false
                self.videoMaskView.image = UIImage.agedu_named("ic_member_device_forbidden")
            }
        }
    }
}
// MARK: - Creations
private extension AgoraRenderMemberView {
    func createViews() {
        let ui = AgoraUIGroup()
        
        backgroundColor = ui.color.render_cell_bg_color
        layer.borderWidth = ui.frame.render_cell_border_width
        layer.borderColor = ui.color.render_cell_border_color
        
        videoView = AgoraRenderMaskView(frame: .zero)
        addSubview(videoView)
        
        videoMaskView = AgoraRenderMaskView(frame: .zero)
        videoMaskView.image = UIImage.agedu_named("ic_member_no_user")
        addSubview(videoMaskView)
        
        nameLabel = UILabel()
        nameLabel.textColor = ui.color.render_label_color
        nameLabel.font = UIFont.systemFont(ofSize: 12)
        nameLabel.layer.shadowColor = ui.color.render_label_shadow_color
        nameLabel.layer.shadowOffset = CGSize(width: 0, height: 1)
        nameLabel.layer.shadowOpacity = ui.color.render_label_shadow_opacity
        nameLabel.layer.shadowRadius = ui.frame.render_label_shadow_radius
        addSubview(nameLabel)
        
        micView = AgoraRenderMicView(frame: .zero)
        addSubview(micView)
        
        rewardImageView = UIImageView(image: UIImage.agedu_named("ic_member_reward"))
        rewardImageView.isHidden = true
        addSubview(rewardImageView)
        
        rewardLabel = UILabel()
        rewardLabel.isHidden = true
        rewardLabel.textColor = ui.color.render_label_color
        rewardLabel.font = UIFont.systemFont(ofSize: 10)
        rewardLabel.layer.shadowColor = ui.color.render_label_shadow_color
        rewardLabel.layer.shadowOffset = CGSize(width: 0, height: 1)
        rewardLabel.layer.shadowOpacity = ui.color.render_label_shadow_opacity
        rewardLabel.layer.shadowRadius = ui.frame.render_label_shadow_radius
        addSubview(rewardLabel)
        
        authView.isHidden = true
        addSubview(authView)
        
        ableMaskView = AgoraRenderMaskView(frame: .zero)
        ableMaskView.isHidden = true
        addSubview(ableMaskView)
    }
    
    func createConstraint() {
        videoMaskView.mas_makeConstraints { make in
            make?.left.right().top().bottom()?.equalTo()(0)
        }
        videoView.mas_makeConstraints { make in
            make?.left.right().top().bottom()?.equalTo()(0)
        }
        micView.mas_makeConstraints { make in
            make?.right.equalTo()(-6)
            make?.bottom.equalTo()(-6)
            make?.width.height().equalTo()(16)
        }
        authView.mas_makeConstraints { make in
            make?.centerY.equalTo()(micView)
            make?.right.equalTo()(micView.mas_left)?.offset()(-6)
            make?.height.equalTo()(18)
            make?.width.equalTo()(16)
        }
        nameLabel.mas_makeConstraints { make in
            make?.centerY.equalTo()(micView)
            make?.left.equalTo()(6)
            make?.right.lessThanOrEqualTo()(0)
        }
        rewardLabel.mas_makeConstraints { make in
            make?.right.equalTo()(-2)
            make?.width.greaterThanOrEqualTo()(15)
            make?.top.equalTo()(5)
        }
        rewardImageView.mas_makeConstraints { make in
            make?.centerY.equalTo()(rewardLabel)
            make?.right.equalTo()(rewardLabel.mas_left)?.offset()(-2)
            make?.width.height().equalTo()(10)
        }
        ableMaskView.mas_makeConstraints { make in
            make?.left.right().top().bottom().equalTo()(0)
        }
    }
}
