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
    enum AgoraRenderRole {
        case student, teacher
    }
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
}

protocol AgoraRenderMemberViewDelegate: NSObjectProtocol {
    func memberViewRender(memberView: AgoraRenderMemberView,
                          in view: UIView,
                          renderID: String)
    
    func memberViewCancelRender(memberView: AgoraRenderMemberView,
                                renderID: String)
}

fileprivate class AgoraRenderMaskView: UIView {
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        backgroundColor = UIColor(hex: 0xF9F9FC)
        let imageView = UIImageView(image: UIImage.agedu_named("ic_member_device_offline"))
        addSubview(imageView)
        imageView.mas_makeConstraints { make in
            make?.width.height().equalTo()(self.mas_height)?.multipliedBy()(0.38)
            make?.centerX.equalTo()(0)
            make?.centerY.equalTo()
        }
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

class AgoraRenderMemberView: UIView {
    
    private weak var delegate: AgoraRenderMemberViewDelegate?
    
    private var stateImageView: UIImageView!
    /** 画布*/
    private var videoView: UIView!
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
    
    private var ableMaskView: AgoraRenderMaskView!
    
    private var renderID: String? {
        didSet {
            guard renderID != oldValue else {
                return
            }
            if let rid = oldValue {
                self.delegate?.memberViewCancelRender(memberView: self,
                                                      renderID: rid)
                self.videoView.isHidden = true
            }
            if let rid = renderID {
                self.delegate?.memberViewRender(memberView: self,
                                                in: self.videoView,
                                                renderID: rid)
                self.videoView.isHidden = false
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
        createConstrains()
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
        stateImageView.image = UIImage.agedu_named("ic_member_no_user")
        micView.setState(.off)
        self.nameLabel.text = ""
        self.videoView.isHidden = true
        self.rewardLabel.isHidden = true
        self.rewardImageView.isHidden = true
        self.ableMaskView.isHidden = true
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
        
        stateImageView.image = UIImage.agedu_named("ic_member_no_user")
        micView.setState(.off)
        self.nameLabel.text = ""
        self.videoView.isHidden = true
        self.rewardLabel.isHidden = true
        self.rewardImageView.isHidden = true
        self.ableMaskView.isHidden = true
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
        switch state {
        case .on:
            stateImageView.image = UIImage.agedu_named("ic_member_device_off")
        case .off, .broken:
            stateImageView.image = UIImage.agedu_named("ic_member_device_off")
        case .forbidden:
            stateImageView.image = UIImage.agedu_named("ic_member_device_forbidden")
        }
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
    
    func updateRenderEnable(enable: Bool) {
        self.ableMaskView.isHidden = enable
        self.updateRenderState()
    }
    
    func updateSteamId(_ steamId: String?) {
        self.updateRenderState()
    }
    
    func updateRenderState() {
        if self.memberModel?.rendEnable == true,
           self.memberModel?.videoState == .on,
           let streamID = self.memberModel?.streamID {
            self.renderID = streamID
        } else {
            self.renderID = nil
        }
    }
}
// MARK: - Creations
private extension AgoraRenderMemberView {
    func createViews() {
        backgroundColor = UIColor(hex: 0xF9F9FC)
        layer.borderWidth = 1
        layer.borderColor = UIColor(hex: 0xECECF1)?.cgColor
        
        stateImageView = UIImageView(image: UIImage.agedu_named("ic_member_no_user"))
        addSubview(stateImageView)
        
        videoView = UIView(frame: .zero)
        videoView.backgroundColor = .clear
        videoView.isHidden = true
        addSubview(videoView)
        
        nameLabel = UILabel()
        nameLabel.textColor = UIColor.white
        nameLabel.font = UIFont.systemFont(ofSize: 12)
        nameLabel.layer.shadowColor = UIColor(hex: 0x0D1D3D,
                                              transparency: 0.8)?.cgColor
        nameLabel.layer.shadowOffset = CGSize(width: 0, height: 1)
        nameLabel.layer.shadowOpacity = 1
        nameLabel.layer.shadowRadius = 2
        addSubview(nameLabel)
        
        micView = AgoraRenderMicView(frame: .zero)
        addSubview(micView)
        
        rewardImageView = UIImageView(image: UIImage.agedu_named("ic_member_reward"))
        rewardImageView.isHidden = true
        addSubview(rewardImageView)
        
        rewardLabel = UILabel()
        rewardLabel.isHidden = true
        rewardLabel.textColor = .white
        rewardLabel.font = UIFont.systemFont(ofSize: 10)
        rewardLabel.layer.shadowColor = UIColor(hex: 0x0D1D3D,
                                              transparency: 0.8)?.cgColor
        rewardLabel.layer.shadowOffset = CGSize(width: 0, height: 1)
        rewardLabel.layer.shadowOpacity = 1
        rewardLabel.layer.shadowRadius = 2
        addSubview(rewardLabel)
        
        ableMaskView = AgoraRenderMaskView(frame: .zero)
        ableMaskView.isHidden = true
        addSubview(ableMaskView)
    }
    
    func createConstrains() {
        stateImageView.mas_makeConstraints { make in
            make?.width.height().equalTo()(self.mas_height)?.multipliedBy()(0.38)
            make?.centerX.equalTo()(0)
            make?.centerY.equalTo()
        }
        videoView.mas_makeConstraints { make in
            make?.left.right().top().bottom().equalTo()(0)
        }
        micView.mas_makeConstraints { make in
            make?.left.equalTo()(AgoraFit.scale(2))
            make?.bottom.equalTo()(AgoraFit.scale(-2))
            make?.width.height().equalTo()(AgoraFit.scale(16))
        }
        nameLabel.mas_makeConstraints { make in
            make?.centerY.equalTo()(micView)
            make?.left.equalTo()(micView.mas_right)?.offset()(AgoraFit.scale(2))
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
