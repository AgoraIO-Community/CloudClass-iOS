//
//  PaintingNameRollItemCell.swift
//  AgoraEduUI
//
//  Created by Jonathan on 2021/10/12.
//

import AgoraEduContext
import UIKit

// 花名册上的 cell
class AgoraUserListModel {
    
    enum AgoraUserListDeviceState {
        case on, off, forbidden
    }
    
    var uuid: String = ""
    
    var streamId: String?
    
    var name: String = "" {
        didSet {
            self.sortRank = getFirstLetterRankFromString(aString: name)
        }
    }
    
    var stageState: (isOn: Bool, isEnable: Bool) = (false, false)
    
    var authState: (isOn: Bool, isEnable: Bool) = (false, false)
    
    var cameraState: (streamOn: Bool, deviceOn: Bool, isEnable: Bool) = (false, false, false)
    
    var micState: (streamOn: Bool, deviceOn: Bool, isEnable: Bool) = (false, false, false)
    
    var rewards: Int = 0
    
    var rewardEnable: Bool = false
    
    var kickEnable: Bool = false
    
    /** 用作排序的首字母权重*/
    var sortRank: UInt32 = 0
    
    init(contextUser: AgoraEduContextUserInfo) {
        self.name = contextUser.userName
        self.uuid = contextUser.userUuid
    }
    
    func getFirstLetterRankFromString(aString: String) -> UInt32 {
        let string = aString.trimmingCharacters(in: .whitespaces)
        let c = string.substring(to: string.index(string.startIndex, offsetBy:1))
        let regexNum = "^[0-9]$"
        let predNum = NSPredicate.init(format: "SELF MATCHES %@", regexNum)
        let regexChar = "^[a-zA-Z]$"
        let predChar = NSPredicate.init(format: "SELF MATCHES %@", regexChar)
        if predNum.evaluate(with: c) {
            let n = string.substring(to: string.index(string.startIndex, offsetBy:1))
            let value = n.unicodeScalars.first?.value ?? 150
            return value + 400
        } else if predChar.evaluate(with: c) {
            return (c.unicodeScalars.first?.value ?? 0) + 300
        } else {
            let mutableString = NSMutableString.init(string: string)
            CFStringTransform(mutableString as CFMutableString, nil, kCFStringTransformToLatin, false)
            let pinyinString = mutableString.folding(options: String.CompareOptions.diacriticInsensitive, locale: NSLocale.current)
            let strPinYin = polyphoneStringHandle(nameString: string, pinyinString: pinyinString).lowercased()
            let firstString = strPinYin.substring(to: strPinYin.index(strPinYin.startIndex, offsetBy:1))
            let value = firstString.unicodeScalars.first?.value ?? 150
            return value + 100
        }
    }
    /// 多音字处理
    func polyphoneStringHandle(nameString:String, pinyinString:String) -> String {
        if nameString.hasPrefix("长") {return "chang"}
        if nameString.hasPrefix("沈") {return "shen"}
        if nameString.hasPrefix("厦") {return "xia"}
        if nameString.hasPrefix("地") {return "di"}
        if nameString.hasPrefix("重") {return "chong"}
        return pinyinString;
    }
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
        if let image = UIImage.agedu_named("ic_nameroll_stage")?
            .withRenderingMode(.alwaysTemplate) {
            v.setImageForAllStates(image)
        }
        v.addTarget(self,
                    action: #selector(onClickStage(_:)),
                    for: .touchUpInside)
        return v
    }()
    /** 授权*/
    private lazy var authButton: UIButton = {
        let v = UIButton(type: .custom)
        if let image = UIImage.agedu_named("ic_nameroll_auth")?
            .withRenderingMode(.alwaysTemplate) {
            v.setImageForAllStates(image)
        }
        v.addTarget(self,
                    action: #selector(onClickAuth(_:)),
                    for: .touchUpInside)
        return v
    }()
    /** 摄像头*/
    private lazy var cameraButton: UIButton = {
        let v = UIButton(type: .custom)
        if let image = UIImage.agedu_named("ic_nameroll_camera_off")?
            .withRenderingMode(.alwaysTemplate) {
            v.tintColor = UIColor(hex: 0xE2E2EE)
            v.setImageForAllStates(image)
        }
        v.addTarget(self, action: #selector(onClickCamera(_:)), for: .touchUpInside)
        return v
    }()
    /** 麦克风*/
    private lazy var micButton: UIButton = {
        let v = UIButton(type: .custom)
        if let image = UIImage.agedu_named("ic_nameroll_mic_off")?
            .withRenderingMode(.alwaysTemplate) {
            v.tintColor = UIColor(hex: 0xE2E2EE)
            v.setImageForAllStates(image)
        }
        v.addTarget(self, action: #selector(onClickMic(_:)), for: .touchUpInside)
        return v
    }()
    /** 奖励*/
    private lazy var rewardButton: UIButton = {
        let v = UIButton(type: .custom)
        if let image = UIImage.agedu_named("ic_nameroll_reward") {
            v.setImageForAllStates(image)
        }
        v.titleLabel?.font = UIFont.systemFont(ofSize: 13)
        v.setTitleColor(UIColor(hex: 0xBDBDCA),
                        for: .normal)
        v.addTarget(self,
                    action: #selector(onClickReward(_:)),
                    for: .touchUpInside)
        return v
    }()
    /** 踢人*/
    private lazy var kickButton: UIButton = {
        let v = UIButton(type: .custom)
        let img = UIImage.agedu_named("ic_nameroll_kick")
        v.setImage(img, for: .normal)
        v.addTarget(self,
                    action: #selector(onClickkick(_:)),
                    for: .touchUpInside)
        return v
    }()
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        createViews()
        createConstraint()
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
private extension AgoraUserListItemCell {
    func updateState() {
        guard let fns = supportFuncs,
              let model = itemModel else {
            return
        }
        nameLabel.text = model.name
        let onColor = UIColor(hex: 0x0073FF)
        let offColor = UIColor(hex: 0xF04C36)
        let authOffColor = UIColor(hex: 0xB3D6FF)
        let disabledColor = UIColor(hex: 0xE2E2EE)
        for fn in fns {
            switch fn {
            case .stage:
                if model.stageState.isOn {
                    stageButton.tintColor = onColor
                } else {
                    stageButton.tintColor = authOffColor
                }
                stageButton.isUserInteractionEnabled = model.stageState.isEnable
            case .auth:
                if model.authState.isOn {
                    authButton.tintColor = onColor
                } else {
                    authButton.tintColor = authOffColor
                }
                authButton.isUserInteractionEnabled = model.stageState.isEnable
            case .camera:
                if !model.stageState.isOn {
                    // 未上台
                    let image = UIImage.agedu_named("ic_nameroll_camera_on")
                    if let i = image?.withRenderingMode(.alwaysTemplate) {
                        cameraButton.setImageForAllStates(i)
                    }
                    cameraButton.tintColor = disabledColor
                } else if !model.cameraState.deviceOn {
                    // 上台+设备关闭
                    let image = UIImage.agedu_named("ic_nameroll_camera_off")
                    if let i = image?.withRenderingMode(.alwaysTemplate) {
                        cameraButton.setImageForAllStates(i)
                    }
                    cameraButton.tintColor = disabledColor
                } else if !model.cameraState.streamOn {
                    // 上台+设备开启+无流权限
                    let image = UIImage.agedu_named("ic_nameroll_camera_off")
                    if let i = image?.withRenderingMode(.alwaysTemplate) {
                        cameraButton.setImageForAllStates(i)
                    }
                    cameraButton.tintColor = offColor
                } else {
                    // 上台+设备开启+有流权限
                    let image = UIImage.agedu_named("ic_nameroll_camera_on")
                    if let i = image?.withRenderingMode(.alwaysTemplate) {
                        cameraButton.setImageForAllStates(i)
                    }
                    cameraButton.tintColor = onColor
                }
                cameraButton.isUserInteractionEnabled = model.cameraState.isEnable
            case .mic:
                if !model.stageState.isOn {
                    // 未上台
                    let image = UIImage.agedu_named("ic_nameroll_mic_on")
                    if let i = image?.withRenderingMode(.alwaysTemplate) {
                        micButton.setImageForAllStates(i)
                    }
                    micButton.tintColor = disabledColor
                } else if !model.micState.deviceOn {
                    // 上台+设备关闭
                    let image = UIImage.agedu_named("ic_nameroll_mic_off")
                    if let i = image?.withRenderingMode(.alwaysTemplate) {
                        micButton.setImageForAllStates(i)
                    }
                    micButton.tintColor = disabledColor
                } else if !model.micState.streamOn {
                    // 上台+设备开启+无流权限
                    let image = UIImage.agedu_named("ic_nameroll_mic_off")
                    if let i = image?.withRenderingMode(.alwaysTemplate) {
                        micButton.setImageForAllStates(i)
                    }
                    micButton.tintColor = offColor
                } else {
                    // 上台+设备开启+有流权限
                    let image = UIImage.agedu_named("ic_nameroll_mic_on")
                    if let i = image?.withRenderingMode(.alwaysTemplate) {
                        micButton.setImageForAllStates(i)
                    }
                    micButton.tintColor = onColor
                }
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
private extension AgoraUserListItemCell {
    func createViews() {
        self.backgroundColor = .white
        
        nameLabel = UILabel()
        nameLabel.textColor = UIColor(hex: 0x191919)
        nameLabel.font = UIFont.systemFont(ofSize: 12)
        nameLabel.textAlignment = .center
        contentView.addSubview(nameLabel)
        
        funcsView = UIStackView(frame: .zero)
        funcsView.backgroundColor = .clear
        funcsView.axis = .horizontal
        funcsView.distribution = .fillEqually
        funcsView.alignment = .fill
        contentView.addSubview(funcsView)
    }
    
    func createConstraint() {
        nameLabel.mas_makeConstraints { make in
            make?.left.equalTo()(0)
            make?.top.bottom().equalTo()(nameLabel.superview)
            make?.width.equalTo()(100)
        }
        funcsView.mas_makeConstraints { make in
            make?.top.bottom().equalTo()(funcsView.superview)
            make?.left.equalTo()(nameLabel.mas_right)
            make?.right.equalTo()(0)
        }
    }
}
