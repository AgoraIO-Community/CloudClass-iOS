//
//  PaintingNameRollItemCell.swift
//  AgoraEduUI
//
//  Created by Jonathan on 2021/10/12.
//

import AgoraEduContext
import UIKit

// 花名册上的 cell
class AgoraPaintingUserListItemModel {
    var uuid: String = ""
    var name: String = ""
    var stage: AgoraUserListFuncState = AgoraUserListFuncState(enable: false,
                                                               isOn: false)
    var auth: AgoraUserListFuncState = AgoraUserListFuncState(enable: false,
                                                              isOn: false)
    var camera: AgoraUserListFuncState = AgoraUserListFuncState(enable: false,
                                                                isOn: false)
    var mic: AgoraUserListFuncState = AgoraUserListFuncState(enable: false,
                                                             isOn: false)
    var silent: AgoraUserListFuncState = AgoraUserListFuncState(enable: false,
                                                                isOn: false)
    var rewards: Int = 0
}

struct AgoraUserListFuncState {
    var enable: Bool
    var isOn: Bool
}

protocol AgoraPaintingUserListItemCellDelegate: NSObjectProtocol {
    func onDidSelectFunction(_ fn: AgoraUserListFunction,
                             at index: NSIndexPath,
                             isOn: Bool)
}

class AgoraPaintingUserListItemCell: UITableViewCell {
    
    weak var delegate: AgoraPaintingUserListItemCellDelegate?
    
    var indexPath: NSIndexPath?
    
    var supportFuncs: [AgoraUserListFunction]? {
        didSet {
            if supportFuncs != oldValue {
                updateSupportFuncs()
            }
        }
    }
    
    var itemModel: AgoraPaintingUserListItemModel? {
        didSet {
            updateState()
        }
    }
    
    private var funcsView: UIStackView!
    
    private var nameLabel: UILabel!
    /** 上下台*/
    private lazy var stageButton: UIButton = {
        let v = UIButton(type: .custom)
        let on = UIImage.ag_imageNamed("ic_nameroll_stage_on",
                                       in: "AgoraEduUI")?.withRenderingMode(.alwaysTemplate)
        let off = UIImage.ag_imageNamed("ic_nameroll_stage_off",
                                        in: "AgoraEduUI")?.withRenderingMode(.alwaysTemplate)
        v.setImage(on,
                   for: .normal)
        v.setImage(off,
                   for: .selected)
        v.tintColor = UIColor(hex: 0x7E8BA2)
        v.addTarget(self,
                    action: #selector(onClickStage(_:)),
                    for: .touchUpInside)
        return v
    }()
    /** 授权*/
    private lazy var authButton: UIButton = {
        let v = UIButton(type: .custom)
        let on = UIImage.ag_imageNamed("ic_nameroll_auth_on",
                                       in: "AgoraEduUI")?.withRenderingMode(.alwaysTemplate)
        let off = UIImage.ag_imageNamed("ic_nameroll_auth_off",
                                        in: "AgoraEduUI")?.withRenderingMode(.alwaysTemplate)
        v.setImage(on,
                   for: .normal)
        v.setImage(off,
                   for: .selected)
        v.tintColor = UIColor(hex: 0x7E8BA2)
        v.addTarget(self, action: #selector(onClickAuth(_:)), for: .touchUpInside)
        return v
    }()
    /** 摄像头*/
    private lazy var cameraButton: UIButton = {
        let v = UIButton(type: .custom)
        let on = UIImage.ag_imageNamed("ic_nameroll_camera_on", in: "AgoraEduUI")?.withRenderingMode(.alwaysTemplate)
        let off = UIImage.ag_imageNamed("ic_nameroll_camera_off", in: "AgoraEduUI")?.withRenderingMode(.alwaysTemplate)
        v.setImage(on, for: .normal)
        v.setImage(off, for: .selected)
        v.tintColor = UIColor(hex: 0x7E8BA2)
        v.addTarget(self, action: #selector(onClickCamera(_:)), for: .touchUpInside)
        return v
    }()
    /** 麦克风*/
    private lazy var micButton: UIButton = {
        let v = UIButton(type: .custom)
        let on = UIImage.ag_imageNamed("ic_nameroll_mic_on", in: "AgoraEduUI")?.withRenderingMode(.alwaysTemplate)
        let off = UIImage.ag_imageNamed("ic_nameroll_mic_off", in: "AgoraEduUI")?.withRenderingMode(.alwaysTemplate)
        v.setImage(on, for: .normal)
        v.setImage(off, for: .selected)
        v.tintColor = UIColor(hex: 0x7E8BA2)
        v.addTarget(self, action: #selector(onClickMic(_:)), for: .touchUpInside)
        return v
    }()
    /** 禁言*/
    private lazy var silentButton: UIButton = {
        let v = UIButton(type: .custom)
        let on = UIImage.ag_imageNamed("ic_nameroll_silent_on",
                                       in: "AgoraEduUI")?.withRenderingMode(.alwaysTemplate)
        let off = UIImage.ag_imageNamed("ic_nameroll_silent_off",
                                        in: "AgoraEduUI")?.withRenderingMode(.alwaysTemplate)
        v.setImage(on, for: .normal)
        v.setImage(off, for: .selected)
        v.tintColor = UIColor(hex: 0x7E8BA2)
        v.addTarget(self,
                    action: #selector(onClickSilent(_:)),
                    for: .touchUpInside)
        return v
    }()
    /** 奖励*/
    private lazy var rewardButton: UIButton = {
        let v = UIButton(type: .custom)
        let img = AgoraUIImage(object: self, name: "ic_nameroll_reward")
        v.setImage(img, for: .normal)
        v.titleLabel?.font = UIFont.systemFont(ofSize: 13)
        v.setTitleColor(UIColor(rgb: 0xBDBDCA),
                        for: .normal)
        v.addTarget(self,
                    action: #selector(onClickReward(_:)),
                    for: .touchUpInside)
        return v
    }()
    /** 踢人*/
    private lazy var kickButton: UIButton = {
        let v = UIButton(type: .custom)
        let img = AgoraUIImage(object: self,
                               name: "ic_nameroll_kick")
        v.setImage(img, for: .normal)
        v.addTarget(self,
                    action: #selector(onClickkick(_:)),
                    for: .touchUpInside)
        return v
    }()
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        createViews()
        createConstrains()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func updateSupportFuncs() {
        guard let list = self.supportFuncs else {
            return
        }
        var temp = [UIView]()
        for fn in list {
            switch fn {
            case .stage:
                temp.append(stageButton)
            case .auth:
                temp.append(authButton)
            case .camera:
                temp.append(cameraButton)
            case .mic:
                temp.append(micButton)
            case .silent:
                temp.append(silentButton)
            case .reward:
                temp.append(rewardButton)
            case .kick:
                temp.append(kickButton)
            default: break
            }
        }
        funcsView.removeArrangedSubviews()
        funcsView.addArrangedSubviews(temp)
    }
}
// MARK: - Private
private extension AgoraPaintingUserListItemCell {
    func updateState() {
        guard let fns = supportFuncs,
              let model = itemModel else {
            return
        }
        nameLabel.text = model.name
        let disable = UIColor(hex: 0x7E8BA2)
        for fn in fns {
            switch fn {
            case .stage:
                stageButton.isSelected = !model.stage.isOn
                stageButton.tintColor = model.stage.enable ? nil : disable
                stageButton.isUserInteractionEnabled = model.stage.enable
            case .auth:
                authButton.isSelected = !model.auth.isOn
                authButton.tintColor = model.auth.enable ? nil : disable
                authButton.isUserInteractionEnabled = model.auth.enable
            case .camera:
                cameraButton.isSelected = !model.camera.isOn
                cameraButton.tintColor = model.camera.enable ? nil : disable
                cameraButton.isUserInteractionEnabled = model.camera.enable
            case .mic:
                micButton.isSelected = !model.mic.isOn
                micButton.tintColor = model.mic.enable ? nil : disable
                micButton.isUserInteractionEnabled = model.mic.enable
            case .silent:
                silentButton.isSelected = !model.silent.isOn
                silentButton.tintColor = model.silent.enable ? nil : disable
                silentButton.isUserInteractionEnabled = model.silent.enable
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
private extension AgoraPaintingUserListItemCell {
    @objc func onClickStage(_ sender: UIButton) {
        guard let model = itemModel else {
            return
        }
        delegateSelectFunc(.stage,
                           state: !model.stage.isOn)
    }
    @objc func onClickAuth(_ sender: UIButton) {
        guard let model = itemModel else {
            return
        }
        delegateSelectFunc(.auth,
                           state: !model.auth.isOn)
    }
    @objc func onClickCamera(_ sender: UIButton) {
        guard let model = itemModel else {
            return
        }
        delegateSelectFunc(.camera,
                           state: !model.camera.isOn)
    }
    @objc func onClickMic(_ sender: UIButton) {
        guard let model = itemModel else {
            return
        }
        delegateSelectFunc(.mic,
                           state: !model.mic.isOn)
    }
    @objc func onClickSilent(_ sender: UIButton) {
        guard let model = itemModel else {
            return
        }
        delegateSelectFunc(.silent,
                           state: !model.silent.isOn)
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
private extension AgoraPaintingUserListItemCell {
    func createViews() {
        self.backgroundColor = .white
        
        nameLabel = UILabel()
        nameLabel.textColor = UIColor(rgb: 0x191919)
        nameLabel.font = UIFont.systemFont(ofSize: 12)
        contentView.addSubview(nameLabel)
        
        funcsView = UIStackView(frame: .zero)
        funcsView.backgroundColor = .clear
        funcsView.axis = .horizontal
        funcsView.distribution = .fillEqually
        funcsView.alignment = .fill
        contentView.addSubview(funcsView)
    }
    
    func createConstrains() {
        nameLabel.mas_makeConstraints { make in
            make?.left.equalTo()(22)
            make?.top.bottom().equalTo()(nameLabel.superview)
            make?.width.equalTo()(60)
        }
        funcsView.mas_makeConstraints { make in
            make?.top.bottom().equalTo()(funcsView.superview)
            make?.left.equalTo()(nameLabel.mas_right)
            make?.right.equalTo()(-20)
        }
    }
}
