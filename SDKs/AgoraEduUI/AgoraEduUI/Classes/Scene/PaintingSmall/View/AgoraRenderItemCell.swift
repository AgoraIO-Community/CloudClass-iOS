//
//  RoomInfoOptionCell.swift
//  AgoraEducation
//
//  Created by HeZhengQing on 2021/9/10.
//  Copyright © 2021 Agora. All rights reserved.
//

import AgoraUIBaseViews
import FLAnimatedImage
import Masonry

class AgoraRenderItemInfoModel: NSObject {
    enum DeviceState {
        case available, invalid, close
    }
    
    var userUUID: String?
    var userName: String?
    var isOnline: Bool = false
    var rewardCount: Int = 0
    var streamUUID: String? {
        didSet {
            if streamUUID != oldValue {
                self.onUpdateStream?(oldValue, streamUUID)
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
    var cameraDeviceState: DeviceState = .close
    var micDeviceState: DeviceState = .close
    
    var isWaving: Bool = false
    
    var renderEnable: Bool = true {
        didSet {
            if renderEnable != oldValue {
                self.onRenderEnableChanged?(renderEnable)
            }
        }
    }
    
    var onRenderEnableChanged: ((Bool) -> Void)?
    /** 音量产生变化 注意使用weak*/
    var onUpdateVolume: ((Int) -> Void)?
    /** 渲染产生变化 注意使用weak*/
    var onUpdateStream: ((_ from: String?, _ to: String?) -> Void)?
}

protocol AgoraRenderItemCellDelegate: NSObjectProtocol {
    /** cell需要渲染流*/
    func onCellRequestRenderOnView(view: UIView,
                                   streamID: String,
                                   userUUID: String)
    /** cell需要取消渲染流*/
    func onCellRequestCancelRender(streamID: String, userUUID: String)
}

// MARK: - AgoraRenderItemCell
public class AgoraRenderItemCell: UICollectionViewCell {
    
    weak var delegate: AgoraRenderItemCellDelegate?
    
    public var themeColor: UIColor? {
        didSet {
            if themeColor != nil {
                contentView.layer.borderColor = themeColor?.cgColor
                contentView.layer.borderWidth = 2
            } else {
                contentView.layer.borderColor = UIColor.clear.cgColor
                contentView.layer.borderWidth = 0
            }
        }
    }
    /** 相机状态*/
    private var cameraStateView: AgoraBaseUIImageView!
    /** 画布*/
    var videoView: UIView!
    /** 麦克风状态*/
    private var micView: AgoraBaseUIImageView!
    /** 声音大小*/
    private var volumeView: AgoraRenderVolumeView!
    /** 名字*/
    private var nameLabel: AgoraBaseUILabel!
    /** 举手*/
    private var handsupView: AgoraBaseUIImageView!
    /** 奖励*/
    private var rewardImageView: UIImageView!
    private var rewardLabel: UILabel!
    
    private lazy var waveView: FLAnimatedImageView =  {
        guard let bundle = Bundle.agora_bundle(object: self,
                                               resource: "AgoraEduUI"),
              let url = bundle.url(forResource: "img_hands_wave",
                                   withExtension: "gif"),
              let data = try? Data(contentsOf: url) else {
            fatalError()
        }
            
        let animatedImage = FLAnimatedImage(animatedGIFData: data)
        let imageView = FLAnimatedImageView()
        imageView.animatedImage = animatedImage
        imageView.isHidden = true
        
        return imageView
    }()
        
    var indexPath: IndexPath = IndexPath(row: 0, section: 0)
    
    var itemInfo: AgoraRenderItemInfoModel? {
        didSet {
            self.updateViewState()
            if itemInfo != oldValue {
                self.setupByItemInfo()
            }
        }
    }
    
    public override init(frame: CGRect) {
        super.init(frame: frame)
        createViews()
        createConstrains()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    /** 设置数据: 无变动数据赋值*/
    func setupByItemInfo() {
        guard let itemInfo = self.itemInfo else {
            return
        }
        self.updateRenderEnable(itemInfo.renderEnable)
        itemInfo.onRenderEnableChanged = { [weak self] enable in
            self?.updateRenderEnable(enable)
        }
        // 关注流变更
        self.itemInfo?.onUpdateStream = { [weak self] from, to in
            guard self?.itemInfo?.renderEnable == true,
                  let userUUID = self?.itemInfo?.userUUID else {
                return
            }
            if let streamID = from { // 关闭上一个
                self?.delegate?.onCellRequestCancelRender(streamID: streamID,
                                                          userUUID: userUUID)
            }
            if let streamID = to,
               let v = self?.videoView { // 开启下一个
                self?.delegate?.onCellRequestRenderOnView(view: v,
                                                          streamID: streamID,
                                                          userUUID: userUUID)
            }
        }
        // name
        if let name = self.itemInfo?.userName,
           name.count > 0{
            self.nameLabel.isHidden = false
            self.nameLabel.text = name
        } else {
            self.nameLabel.isHidden = true
            self.nameLabel.text = ""
        }
        
    }
    
    func updateViewState() {
        guard let itemInfo = self.itemInfo else {
            return
        }
        
        // camera
        if !itemInfo.isOnline {
            videoView.isHidden = true
            cameraStateView.image = UIImage.agedu_named("ic_member_device_offline")
        } else if itemInfo.cameraDeviceState == .invalid {
            videoView.isHidden = true
            cameraStateView.image = UIImage.agedu_named("ic_member_device_bad")
        } else if itemInfo.cameraDeviceState == .close {
            videoView.isHidden = true
            cameraStateView.image = UIImage.agedu_named("ic_member_device_off")
        } else {
            videoView.isHidden = false
        }
        // mic
        if itemInfo.micDeviceState == .available {
            micView.image = UIImage.agedu_named("ic_mic_status_on")
            volumeView.isHidden = !itemInfo.renderEnable
        } else {
            micView.image = UIImage.agedu_named("ic_mic_status_off")
            volumeView.isHidden = !itemInfo.renderEnable
        }
        // reward
        rewardLabel.isHidden = itemInfo.rewardCount == 0
        rewardImageView.isHidden = itemInfo.rewardCount == 0
        if itemInfo.rewardCount < 99 {
            rewardLabel.text = "x\(itemInfo.rewardCount)"
        } else {
            rewardLabel.text = "x99+"
        }
        
        // waving
        waveView.isHidden = !itemInfo.isWaving
    }
    
    func updateRenderEnable(_ isEnable: Bool) {
        guard let itemInfo = self.itemInfo else {
            return
        }
        if isEnable {
            self.micView.isHidden = false
            self.nameLabel.isHidden = false
            self.videoView.isHidden = false
            // 开启音量监听，开启渲染
            itemInfo.onUpdateVolume = { [weak self] value in
                self?.volumeView.volume = CGFloat(value) / 255.0
            }
            if let s = itemInfo.streamUUID,
               let u = itemInfo.userUUID {
                delegate?.onCellRequestRenderOnView(view: videoView,
                                                    streamID: s,
                                                    userUUID: u)
            }
        } else {
            self.micView.isHidden = true
            self.nameLabel.isHidden = true
            self.videoView.isHidden = true
            // 关闭音量监听，关闭渲染
            itemInfo.onUpdateVolume = nil
            self.volumeView.volume = 0
            if let s = itemInfo.streamUUID,
               let u = itemInfo.userUUID {
                delegate?.onCellRequestCancelRender(streamID: s,
                                                    userUUID: u)
            }
        }
    }
    
}
// MARK: - Creations
private extension AgoraRenderItemCell {
    
    func createViews() {
        contentView.backgroundColor = UIColor.white
        contentView.clipsToBounds = true
        contentView.layer.cornerRadius = UIDevice.current.isPad ? 10 : 4
        
        cameraStateView = AgoraBaseUIImageView(image: UIImage.agedu_named("default_offline"))
        contentView.addSubview(cameraStateView)
        
        videoView = UIView(frame: .zero)
        videoView.backgroundColor = .clear
        contentView.addSubview(videoView)
        
        micView = AgoraBaseUIImageView.init(image: UIImage.agedu_named("ic_mic_status_on"))
        contentView.addSubview(micView)
        
        volumeView = AgoraRenderVolumeView(frame: .zero)
        volumeView.volume = 0
        contentView.addSubview(volumeView)
        
        rewardImageView = UIImageView(image: UIImage.agedu_named("ic_member_reward"))
        contentView.addSubview(rewardImageView)
        
        rewardLabel = UILabel()
        rewardLabel.textColor = .white
        rewardLabel.font = UIFont.systemFont(ofSize: 10)
        contentView.addSubview(rewardLabel)
        
        nameLabel = AgoraBaseUILabel()
        nameLabel.textColor = UIColor.white
        nameLabel.font = UIFont.systemFont(ofSize: 12)
        nameLabel.layer.shadowColor = UIColor(hex: 0x0D1D3D, transparency: 0.8)?.cgColor
        nameLabel.layer.shadowOffset = CGSize(width: 0, height: 1)
        nameLabel.layer.shadowOpacity = 1
        nameLabel.layer.shadowRadius = 2
        contentView.addSubview(nameLabel)
        
        handsupView = AgoraBaseUIImageView(image: UIImage.agedu_named("ic_member_handsup"))
        contentView.addSubview(handsupView)
        
        contentView.addSubview(waveView)
    }
    
    func createConstrains() {
        cameraStateView.mas_makeConstraints { make in
            if UIDevice.current.isPad {
                make?.size.equalTo()(CGSize(width: 70, height: 70))
            } else {
                make?.size.equalTo()(CGSize(width: 45, height: 45))
            }
            make?.center.equalTo()(cameraStateView.superview)
        }
        videoView.mas_makeConstraints { make in
            make?.left.right().top().bottom().equalTo()(videoView.superview)
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
            make?.bottom.equalTo()(micView.mas_top)?.offset()(-2)
        }
        nameLabel.mas_makeConstraints { make in
            make?.centerY.equalTo()(micView)
            make?.left.equalTo()(micView.mas_right)?.offset()(2)
            make?.right.lessThanOrEqualTo()(nameLabel.superview)
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
        handsupView.mas_makeConstraints { make in
            make?.right.equalTo()(-2)
            make?.bottom.equalTo()(-2)
            make?.width.height().equalTo()(24)
        }
        waveView.mas_makeConstraints { make in
            make?.top.bottom().centerX().equalTo()(waveView.superview)
            make?.height.equalTo()(contentView.mas_height)
        }
    }
    
}
