//
//  PaintingNameRollItemCell.swift
//  AgoraEduUI
//
//  Created by Jonathan on 2021/10/12.
//

import AgoraUIBaseViews
import AgoraEduContext
import UIKit

// 花名册上的 cell
protocol AgoraPaintingUserListItemCellDelegate: NSObjectProtocol {
    func onDidSelectFunction(_ fn: AgoraUserListFunction,
                             at index: NSIndexPath,
                             isOn: Bool)
}

class AgoraUserListItemCell: UITableViewCell {
    
    weak var delegate: AgoraPaintingUserListItemCellDelegate?
    
    var indexPath: NSIndexPath?
    
    var supportFuncs: [AgoraUserListFunction]? {
        didSet {
            if supportFuncs != oldValue {
                updateSupportFuncs()
            }
        }
    }
    
    var itemModel: AgoraUserListModel? {
        didSet {
            updateState()
        }
    }
    
    private var funcsView: UIStackView!
    
    private var nameLabel: UILabel!
    /** 上下台*/
    private lazy var stageButton: UIButton = {
        let v = UIButton(type: .custom)
        v.addTarget(self,
                    action: #selector(onClickStage(_:)),
                    for: .touchUpInside)
        return v
    }()
    /** 授权*/
    private lazy var authButton: UIButton = {
        let v = UIButton(type: .custom)
        v.addTarget(self,
                    action: #selector(onClickAuth(_:)),
                    for: .touchUpInside)
        return v
    }()
    /** 摄像头*/
    private lazy var cameraButton: UIButton = {
        let v = UIButton(type: .custom)
        v.addTarget(self, action: #selector(onClickCamera(_:)),
                    for: .touchUpInside)
        return v
    }()
    /** 麦克风*/
    private lazy var micButton: UIButton = {
        let v = UIButton(type: .custom)
        v.addTarget(self, action: #selector(onClickMic(_:)),
                    for: .touchUpInside)
        return v
    }()
    /** 奖励*/
    private lazy var rewardButton: UIButton = {
        let v = UIButton(type: .custom)
        v.setImage(UIConfig.roster.reward.image,
                   for: .normal)
        v.addTarget(self,
                    action: #selector(onClickReward(_:)),
                    for: .touchUpInside)
        return v
    }()
    /** 踢人*/
    private lazy var kickButton: UIButton = {
        let v = UIButton(type: .custom)
        v.setImage(UIConfig.roster.kickOut.image,
                   for: .normal)
        v.addTarget(self,
                    action: #selector(onClickkick(_:)),
                    for: .touchUpInside)
        return v
    }()
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        initViews()
        initViewFrame()
        updateViewProperties()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func updateSupportFuncs() {
        guard let list = self.supportFuncs else {
            return
        }
        
        let config = UIConfig.roster
        var temp = [UIView]()
        for fn in list {
            switch fn {
            case .stage:
                stageButton.agora_enable = config.stage.enable
                stageButton.agora_visible = config.stage.visible
                temp.append(stageButton)
            case .auth:
                authButton.agora_enable = config.boardAuthorization.enable
                authButton.agora_visible = config.boardAuthorization.visible
                temp.append(authButton)
            case .camera:
                cameraButton.agora_enable = config.camera.enable
                cameraButton.agora_visible = config.camera.visible
                temp.append(cameraButton)
            case .mic:
                micButton.agora_enable = config.microphone.enable
                micButton.agora_visible = config.microphone.visible
                temp.append(micButton)
            case .reward:
                rewardButton.agora_enable = config.reward.enable
                rewardButton.agora_visible = config.reward.visible
                
                rewardButton.titleLabel?.font = config.reward.font
                rewardButton.setTitleColor(config.reward.textColor,
                                           for: .normal)
                
                temp.append(rewardButton)
            case .kick:
                kickButton.agora_enable = config.kickOut.enable
                kickButton.agora_visible = config.kickOut.visible
                temp.append(kickButton)
            default:
                break
            }
        }
        funcsView.removeArrangedSubviews()
        funcsView.addArrangedSubviews(temp)
    }
}
// MARK: - Private
private extension AgoraUserListItemCell {
    func updateState() {
        guard let fns = supportFuncs,
              let model = itemModel else {
            return
        }
        nameLabel.text = model.name
        
        let config = UIConfig.roster
        for fn in fns {
            switch fn {
            case .stage:
                let image = model.stageState.isOn ? config.stage.onImage : config.stage.offImage
                stageButton.setImage(image,
                                     for: .normal)
                stageButton.isUserInteractionEnabled = model.stageState.isEnable
            case .auth:
                let image = model.authState.isOn ? config.boardAuthorization.onImage : config.boardAuthorization.offImage
                authButton.setImage(image,
                                     for: .normal)
                authButton.isUserInteractionEnabled = model.stageState.isEnable
            case .camera:
                var image: UIImage?
                if !model.stageState.isOn {
                    // 未上台
                    image = config.camera.offImage
                } else if !model.cameraState.deviceOn {
                    // 上台+设备关闭
                    image = config.camera.offImage
                } else if !model.cameraState.streamOn {
                    // 上台+设备开启+无流权限
                    image = config.camera.forbiddenImage
                } else {
                    // 上台+设备开启+有流权限
                    image = config.camera.onImage
                }
                cameraButton.setImage(image,
                                     for: .normal)
                cameraButton.isUserInteractionEnabled = model.cameraState.isEnable
            case .mic:
                var image: UIImage?
                if !model.stageState.isOn {
                    // 未上台
                    image = config.microphone.offImage
                } else if !model.micState.deviceOn {
                    // 上台+设备关闭
                    image = config.microphone.offImage
                } else if !model.micState.streamOn {
                    // 上台+设备开启+无流权限
                    image = config.microphone.forbiddenImage
                } else {
                    // 上台+设备开启+有流权限
                    image = config.microphone.onImage
                }
                micButton.setImage(image,
                                     for: .normal)
                micButton.isUserInteractionEnabled = model.micState.isEnable
            case .reward:
                rewardButton.setTitle("x\(model.rewards)", for: .normal)
            case .kick:
                break
            default: break
            }
        }
    }
}

// MARK: - Actions
private extension AgoraUserListItemCell {
    @objc func onClickStage(_ sender: UIButton) {
        guard let model = itemModel else {
            return
        }
        delegateSelectFunc(.stage,
                           state: !model.stageState.isOn)
    }
    @objc func onClickAuth(_ sender: UIButton) {
        guard let model = itemModel else {
            return
        }
        delegateSelectFunc(.auth,
                           state: !model.authState.isOn)
    }
    @objc func onClickCamera(_ sender: UIButton) {
        guard let model = itemModel else {
            return
        }
        delegateSelectFunc(.camera,
                           state: !model.cameraState.streamOn)
    }
    @objc func onClickMic(_ sender: UIButton) {
        guard let model = itemModel else {
            return
        }
        delegateSelectFunc(.mic,
                           state: !model.micState.streamOn)
    }

    @objc func onClickReward(_ sender: UIButton) {
        guard let model = itemModel else {
            return
        }
        delegateSelectFunc(.reward,
                           state: true)
    }
    @objc func onClickkick(_ sender: UIButton) {
        guard let model = itemModel else {
            return
        }
        delegateSelectFunc(.kick,
                           state: true)
    }
    
    func delegateSelectFunc(_ fn: AgoraUserListFunction,
                            state: Bool) {
        guard let i = indexPath else {
            return
        }
        delegate?.onDidSelectFunction(fn,
                                      at: i,
                                      isOn: state)
    }
}
// MARK: - Creations
extension AgoraUserListItemCell: AgoraUIContentContainer {
    func initViews() {
        nameLabel = UILabel()
        nameLabel.textAlignment = .left
        let config = UIConfig.roster.studentName
        nameLabel.agora_enable = config.enable
        nameLabel.agora_visible = config.visible
        contentView.addSubview(nameLabel)
        
        funcsView = UIStackView(frame: .zero)
        funcsView.backgroundColor = .clear
        funcsView.axis = .horizontal
        funcsView.distribution = .fillEqually
        funcsView.alignment = .fill
        contentView.addSubview(funcsView)
    }
    
    func initViewFrame() {
        nameLabel.mas_makeConstraints { make in
            make?.left.equalTo()(16)
            make?.top.bottom().equalTo()(nameLabel.superview)
            make?.width.equalTo()(80)
        }
        funcsView.mas_makeConstraints { make in
            make?.top.bottom().equalTo()(funcsView.superview)
            make?.left.equalTo()(nameLabel.mas_right)
            make?.right.equalTo()(0)
        }
    }
    
    func updateViewProperties() {
        let config = UIConfig.roster

        backgroundColor = config.cellBackgroundColor
        nameLabel.textColor = FcrUIColorGroup.textLevel1Color
        nameLabel.font = FcrUIFontGroup.font12
    }
}
