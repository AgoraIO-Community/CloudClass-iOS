//
//  AgoraOneToOneMemberView.swift
//  AgoraEduUI
//
//  Created by Jonathan on 2021/11/15.
//

import UIKit

protocol AgoraOneToOneMemberViewDelegate: NSObjectProtocol {
    
    func onMemberViewRequestRenderOnView(view: UIView,
                                         streamID: String,
                                         userUUID: String)
    
    func onMemberViewRequestCancelRender(streamID: String,
                                         userUUID: String)
}

fileprivate let kButtonSize: CGFloat = 25.0
class AgoraOneToOneMemberView: UIView {
    
    enum AgoraOneToOneMemberViewType {
        case admin, member
    }
    
    enum AgoraOneToOneDeviceState {
        case off, on, erro
    }
    
    weak var delegate: AgoraOneToOneMemberViewDelegate?
    
    var item: AgoraRenderItemInfoModel? = AgoraRenderItemInfoModel() {
        didSet {
            self.updateView()
        }
    }
    
    var micState: AgoraOneToOneDeviceState = .off {
        didSet {
            guard micState != oldValue else {
                return
            }
            volumeView.isHidden = (micState != .on)
            switch micState {
            case .on:
                micView.image = UIImage.ag_imageNamed("ic_mic_status_on",
                                                      in: "AgoraEduUI")
                break
            case .off:
                micView.image = UIImage.ag_imageNamed("ic_mic_status_off",
                                                      in: "AgoraEduUI")
                break
            default: break
            }
        }
    }
    
    var cameraState: AgoraOneToOneDeviceState = .off {
        didSet {
            guard cameraState != oldValue else {
                return
            }
            switch cameraState {
            case .on:
                cameraStateView.image = UIImage.ag_imageNamed("ic_member_device_offline",
                                                              in: "AgoraEduUI")
            case .off:
                cameraStateView.image = UIImage.ag_imageNamed("ic_member_device_close",
                                                              in: "AgoraEduUI")
            case .erro:
                cameraStateView.image = UIImage.ag_imageNamed("ic_member_device_bad",
                                                              in: "AgoraEduUI")
            default: break
            }
        }
    }
    public var cameraStateView: UIImageView!
    /** 画布*/
    var videoView: UIView!
    
    private var micView: UIImageView!
    private var volumeView: AgoraRenderVolumeView!
    /** 用户名称视图组*/
    private var nameLabel: UILabel!
    
    var viewType: AgoraOneToOneMemberViewType = .member
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        self.createViews()
        self.createConstrains()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func updateView() {
        guard let model = item else {
            return
        }
        nameLabel.text = model.userName
        if let s = model.streamUUID,
           let u = model.userUUID {
            delegate?.onMemberViewRequestRenderOnView(view: videoView,
                                                      streamID: s,
                                                      userUUID: u)
        }
        // 关注流变更
        model.onUpdateStream = { [weak self] from, to in
            guard let userUUID = model.userUUID else {
                return
            }
            if let streamID = from { // 关闭上一个
                self?.delegate?.onMemberViewRequestCancelRender(streamID: streamID,
                                                                userUUID: userUUID)
            }
            if let streamID = to,
               let v = self?.videoView { // 开启下一个
                self?.delegate?.onMemberViewRequestRenderOnView(view: v,
                                                                streamID: streamID,
                                                                userUUID: userUUID)
            }
        }
    }
    
    func setVolumeValue(_ v: Int) {
        self.volumeView.volume = CGFloat(v) / 255.0
    }
}
// MARK: - Creations
private extension AgoraOneToOneMemberView {
    func createViews() {
        layer.borderColor = UIColor(hex: 0xECECF1)?.cgColor
        layer.borderWidth = 1
        layer.cornerRadius = 4
        self.clipsToBounds = true
        
        cameraStateView = UIImageView(image: UIImage.ag_imageNamed("ic_member_device_offline",
                                                                   in: "AgoraEduUI"))
        addSubview(cameraStateView)
        
        videoView = UIView(frame: .zero)
        videoView.backgroundColor = .clear
        addSubview(videoView)
        
        micView = UIImageView.init(image: UIImage.ag_imageNamed("ic_mic_status_off",
                                                                in: "AgoraEduUI"))
        addSubview(micView)
        
        volumeView = AgoraRenderVolumeView(frame: .zero)
        volumeView.isHidden = true
        addSubview(volumeView)
        
        nameLabel = UILabel()
        nameLabel.textColor = UIColor.white
        nameLabel.font = UIFont.systemFont(ofSize: 12)
        nameLabel.layer.shadowColor = UIColor(rgb: 0x0D1D3D, alpha: 0.8).cgColor
        nameLabel.layer.shadowOffset = CGSize(width: 0, height: 1)
        nameLabel.layer.shadowOpacity = 1
        nameLabel.layer.shadowRadius = 2
        addSubview(nameLabel)
    }
    
    func createConstrains() {
        cameraStateView.mas_makeConstraints { make in
            make?.width.height().equalTo()(80)
            make?.center.equalTo()(0)
        }
        videoView.mas_makeConstraints { make in
            make?.left.right().top().bottom().equalTo()(videoView.superview)
        }
        micView.mas_makeConstraints { make in
            make?.left.equalTo()(5)
            make?.bottom.equalTo()(-6)
            make?.width.height().equalTo()(18)
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
    }
}

