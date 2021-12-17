//
//  LoginViewController.swift
//  AgoraEducation
//
//  Created by LYY on 2021/4/15.
//  Copyright © 2021 Agora. All rights reserved.
//

#if canImport(AgoraClassroomSDK_iOS)
import AgoraClassroomSDK_iOS
#else
import AgoraClassroomSDK
#endif
import AgoraUIEduBaseViews
import AgoraUIBaseViews
import AgoraWidget
import ChatWidget
import AgoraLog
import UIKit

/** 房间信息项*/
enum RoomInfoItemType: Int, CaseIterable {
    // 房间名
    case roomName = 0
    // 昵称
    case nickName
    // 类型
    case roomStyle
    // 角色
    case roleType
    // 区域
    case region
    // 时长
    case duration
    // 密钥
    case encryptKey
    // 模式
    case encryptMode
}

/** 区域选择类型*/
enum RoomRegionType: String, CaseIterable  {
    case CN, NA, EU, AP
}

/** 房间可选项*/
fileprivate let kRoomOptions: [(AgoraEduRoomType, String)] = [
    (.oneToOne, NSLocalizedString("Login_onetoone", comment: "")),
    (.small, NSLocalizedString("Login_small", comment: "")),
    (.lecture, NSLocalizedString("Login_lecture", comment: "")),
    // 2.0.0版本去掉美术课
    //(.paintingSmall, NSLocalizedString("login_painting_small", comment: ""))
]

/** 区域可选项*/
fileprivate let kRegionOptions: [(RoomRegionType, String)] = [
    (.CN, "CN"),
    (.NA, "NA"),
    (.EU, "EU"),
    (.AP, "AP")
]

/** 角色可选项*/
fileprivate let kRoleOptions: [(AgoraEduRoleType, String)] = [
    (.teacher, NSLocalizedString("login_role_teacher", comment: "")),
    (.student, NSLocalizedString("login_role_student", comment: "")),
]

/** 加密方式可选项*/
fileprivate let kEncryptionOptions: [(AgoraEduMediaEncryptionMode, String)] = [
    (.none, "None"),
    (.SM4128ECB, "sm4-128-ecb"),
    (.AES128GCM2, "aes-128-gcm2"),
    (.AES256GCM2, "aes-256-gcm2"),
]

/** 入参模型*/
struct RoomInfoModel {
    var roomName: String?
    var nickName: String?
    var roomStyle: AgoraEduRoomType?
    var roleType: AgoraEduRoleType?
    var region: RoomRegionType?
    var duration: Int?
    var encryptKey: String?
    var encryptMode: AgoraEduMediaEncryptionMode?
    /** 入参默认值 */
    static func defaultValue() -> RoomInfoModel {
        var room = RoomInfoModel()
        room.roomName = nil
        room.nickName = nil
        room.roomStyle = nil
        room.roleType = .student
        room.region = .CN
        room.duration = 1800
        room.encryptKey = ""
        room.encryptMode = AgoraEduMediaEncryptionMode.none
        return room
    }
}

// MARK: - Login View Controller
@objcMembers public class LoginViewController: UIViewController {
    /** 房间信息列表*/
    private var tableView: AgoraBaseUITableView!
    /** 选项列表*/
    private lazy var optionsView: RoomInfoOptionsView = {
        let optionsView = RoomInfoOptionsView(frame: .zero)
        view.addSubview(optionsView)
        return optionsView
    }()
    // ..
    private lazy var aboutView: AboutView = {
        let about = AboutView(frame: .zero)
        about.alpha = 0
        return about
    }()
    private var topImageView: AgoraBaseUIImageView!
    /** logo*/
    private var logoImageView: AgoraBaseUIImageView!
    /** 关于*/
    private var aboutButton: AgoraBaseUIButton!
    /** 进入房间*/
    private var enterButton: AgoraBaseUIButton!
    
    private var bottomButton: AgoraBaseUIButton!
    
    private var dataSource = RoomInfoItemType.allCases
    
    private var inputParams = RoomInfoModel()
    
    private let defaultParams = RoomInfoModel.defaultValue()
    
    private var selectedIndex = -1
    
    private let tokenBuilder = TokenBuilder()
    
    private let minInputLength = 6
}

// MARK: - override
extension LoginViewController {
    public override var shouldAutorotate: Bool {
        return true
    }
    
    public override var preferredInterfaceOrientationForPresentation: UIInterfaceOrientation {
        return LoginConfig.device == .iPad ? .landscapeRight : .portrait
    }
    
    public override var supportedInterfaceOrientations: UIInterfaceOrientationMask {
        return LoginConfig.device == .iPad ? .landscapeRight : .portrait
    }
    
    public override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        
        createViews()
        createConstrains()
        // 检查协议
        if !TermsAndPolicyViewController.getPolicyPopped() {
            if let termsVC = TermsAndPolicyViewController.loadFromStoryboard("privacy", "terms") {
                present(termsVC,
                             animated: true,
                             completion: nil)
            }
        }
    }
    
    public override func touchesBegan(_ touches: Set<UITouch>,
                                      with event: UIEvent?) {
        super.touchesBegan(touches, with: event)
        
        hideOptions()
        UIApplication.shared.keyWindow?.endEditing(true)
    }
}

// MARK: - Private
private extension LoginViewController {
    func updateEntranceStatus() {
        if let roomName = inputParams.roomName ?? defaultParams.roomName,
           let nickName = inputParams.nickName ?? defaultParams.nickName,
           let _ = inputParams.roomStyle ?? defaultParams.roomStyle,
           roomName.count > 0, nickName.count > 0 {
            enterButton.backgroundColor = UIColor(hexString: "357BF6")
            enterButton.isUserInteractionEnabled = true
        } else {
            enterButton.backgroundColor = UIColor(hexString: "C0D6FF")
            enterButton.isUserInteractionEnabled = false
        }
    }
    
    func registerExtApps() {
        let countDown = AgoraExtAppConfiguration(appIdentifier: "io.agora.countdown",
                                                 extAppClass: CountDownExtApp.self,
                                                 frame: .zero,
                                                 language: "zh")
        countDown.image = UIImage(named: "countdown")
        
        let answerExt = AgoraExtAppConfiguration(appIdentifier: "io.agora.answer",
                                                 extAppClass: AnswerSheetExtApp.self,
                                                 frame: UIEdgeInsets(top: 0,
                                                                     left: 0,
                                                                     bottom: 0,
                                                                     right: 0),
                                                 language: "zh")
        answerExt.image = UIImage(named: "countdown")
        let apps = [countDown, answerExt]
        AgoraClassroomSDK.registerExtApps(apps)
    }
    /** 获取选项列表*/
    func optionStrings(form options: [(Any, String)]) -> [String] {
        return options.map {$1}
    }
    /** 获取选项的文本*/
    func optionDescription<T: Equatable>(option: T?,
                                         in options: [(T, String)]) -> String {
        for (_, (element, desc)) in options.enumerated() {
            if option == element {
                return desc
            }
        }
        return ""
    }
    /** 获取选项的下标*/
    func optionIndex<T: Equatable>(option: T?,
                                   in options: [(T, String)]) -> Int {
        var index = -1
        guard let option = option else {
            return index
        }
        for (i, (element, _)) in options.enumerated() {
            if option == element {
                index = i
                break
            }
        }
        return index
    }
    
    func hideOptions() {
        optionsView.hide()
        if selectedIndex != -1 {
            selectedIndex = -1
            tableView.reloadData()
        }
    }
}

// MARK: - Actions
private extension LoginViewController {
    @objc func onTouchAbout() {
        view.addSubview(aboutView)
        aboutView.agora_x = 0
        aboutView.agora_y = 0
        aboutView.agora_right = 0
        aboutView.agora_bottom = 0
        
        switch LoginConfig.device {
        case .iPhone_Big: fallthrough
        case .iPhone_Small:
            aboutView.alpha = 1
            aboutView.layoutIfNeeded()
            aboutView.transform = CGAffineTransform(translationX: view.frame.width, y: 0)
            UIView.animate(withDuration: TimeInterval.agora_animation,
                           delay: 0,
                           options: .transitionFlipFromLeft,
                           animations: { [weak self] in
                            guard let strongSelf = self else {
                                return
                            }
                            strongSelf.aboutView.agora_x = 0
                            strongSelf.aboutView.agora_y = 0
                            strongSelf.aboutView.agora_right = 0
                            strongSelf.aboutView.agora_bottom = 0
                            strongSelf.aboutView.transform = CGAffineTransform(translationX: 0,
                                                                               y: 0)
                            strongSelf.aboutView.layoutIfNeeded()
                           }, completion: nil)
        case .iPad:
            aboutView.alpha = 0
            aboutView.transform = CGAffineTransform(scaleX: 0.3,
                                                    y: 0.3)
            UIView.animate(withDuration: TimeInterval.agora_animation,
                           delay: 0,
                           usingSpringWithDamping: 0.5,
                           initialSpringVelocity: 0,
                           options: .curveEaseInOut,
                           animations: { [weak self] in
                            guard let strongSelf = self else {
                                return
                            }
                            
                            strongSelf.aboutView.agora_x = 0
                            strongSelf.aboutView.agora_y = 0
                            strongSelf.aboutView.agora_right = 0
                            strongSelf.aboutView.agora_bottom = 0
                            strongSelf.aboutView.alpha = 1
                            strongSelf.aboutView.transform = CGAffineTransform(scaleX: 1.0,
                                                                               y: 1.0)
                            strongSelf.aboutView.layoutIfNeeded()
                           }, completion: nil)
        }
    }
    
    @objc func onTouchJoinRoom() {
        guard let room = inputParams.roomName ?? defaultParams.roomName,
              let user = inputParams.nickName ?? defaultParams.nickName,
              let roomStyle = inputParams.roomStyle ?? defaultParams.roomStyle,
              let region = inputParams.region ?? defaultParams.region,
              let encryptionMode = inputParams.encryptMode ?? defaultParams.encryptMode,
              let roleType = inputParams.roleType ?? defaultParams.roleType else {
            return
        }
        registerExtApps()
        
        // roomUuid = roomName + classType
        let roomUuid = "\(room)\(roomStyle.rawValue)"
        
        // userUuid = userName + roleType
        let userUuid = "\(user)\(roleType.rawValue)"

        let startTime = Int64(NSDate().timeIntervalSince1970 * 1000)
        let duration = self.defaultParams.duration!
        
        var encryptionConfig: AgoraEduMediaEncryptionConfig?
        if let key = self.inputParams.encryptKey ?? self.defaultParams.encryptKey,
           encryptionMode != .none {
            let tfModeValue = encryptionMode.rawValue
            if tfModeValue > 0 && tfModeValue <= 6 {
                encryptionConfig = AgoraEduMediaEncryptionConfig(mode: encryptionMode, key: key)
            }
        }
        let mediaOptions = AgoraEduMediaOptions(encryptionConfig: encryptionConfig,
                                                cameraEncoderConfiguration: nil,
                                                latencyLevel: .ultraLow,
                                                videoState: .on,
                                                audioState: .on)
        
        AgoraLoading.loading()

        let failure: (Error) -> () = { (error) in
            AgoraLoading.hide()
            AgoraToast.toast(msg: error.localizedDescription,
                             type: .erro)
        }
        
        let success: () -> () = {
            AgoraLoading.hide()
        }
        
        requestToken(region: region.rawValue,
                     userUuid: userUuid,
                     success: { [weak self] (response) in
            guard let `self` = self else {
                return
            }
            
            let appId = response.appId
            let rtmToken = response.rtmToken
            let userUuid = response.userId
            let sdkConfig = AgoraClassroomSDKConfig(appId: appId)
            
            let launchConfig = AgoraEduLaunchConfig(userName: user,
                                                    userUuid: userUuid,
                                                    roleType: roleType,
                                                    roomName: room,
                                                    roomUuid: roomUuid,
                                                    roomType: roomStyle,
                                                    token: rtmToken,
                                                    startTime: NSNumber(value: startTime),
                                                    duration: NSNumber(value: duration),
                                                    region: region.eduType,
                                                    mediaOptions: mediaOptions,
                                                    userProperties: nil,
                                                    boardFitMode: .retain)
            
            AgoraClassroomSDK.setConfig(sdkConfig)
            
            AgoraClassroomSDK.launch(launchConfig,
                                     delegate: self,
                                     success: success,
                                     failure: failure)
        }, failure: failure)
    }
    
    @objc func onPushDebugVC() {
        navigationController?.pushViewController(DebugViewController(),
                                                 animated: true)
    }
}

private extension LoginViewController {
    func buildToken(appId: String,
                    appCertificate: String,
                    userUuid: String,
                    success: @escaping (TokenBuilder.ServerResp) -> (),
                    failure: @escaping (Error) -> ()) {
        let token = tokenBuilder.buildByAppId(appId,
                                              appCertificate: appCertificate,
                                              userUuid: userUuid)
        
        let response = TokenBuilder.ServerResp(appId: appId,
                                               userId: userUuid,
                                               rtmToken: token)
        success(response)
    }
    
    func requestToken(region: String,
                      userUuid: String,
                      success: @escaping (TokenBuilder.ServerResp) -> (),
                      failure: @escaping (Error) -> ()) {
        tokenBuilder.buildByServer(region: region,
                                   userUuid: userUuid,
                                   environment: .pro,
                                   success: { (resp) in
                                    success(resp)
                                   }, failure: { (error) in
                                    failure(error)
                                   })
    }
}

// MARK: - AgoraEduClassroomDelegate

extension LoginViewController: AgoraEduClassroomSDKDelegate {
    public func classroomSDK(_ classroom: AgoraClassroomSDK,
                             didExited reason: AgoraEduExitReason) {
        switch reason {
        case .kickOut:
            AgoraToast.toast(msg: "kick out")
        default:
            break
        }
    }
}

// MARK: - UITableViewDelegate, UITableViewDataSource
extension LoginViewController: UITableViewDelegate, UITableViewDataSource {
    public func tableView(_ tableView: UITableView,
                          numberOfRowsInSection section: Int) -> Int {
        return dataSource.count
    }
    
    public func tableView(_ tableView: UITableView,
                          cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let reuseId = "RoomInfoCellAt\(indexPath.row)"
        var cell: RoomInfoCell!
        cell = tableView.dequeueReusableCell(withIdentifier: reuseId) as? RoomInfoCell
        if cell == nil {
            cell = RoomInfoCell(style: .default,
                                reuseIdentifier: reuseId)
        }
        cell.delegate = self
        cell.indexPath = indexPath
        cell.setFocused(indexPath.row == selectedIndex)
        let rowType = RoomInfoItemType(rawValue: indexPath.row)
        switch rowType {
        case .roomName:
            cell.mode = .input
            cell.titleLabel.text = NSLocalizedString("Login_room_title",
                                                     comment: "")
            cell.textField.placeholder = NSLocalizedString("Login_room_holder",
                                                           comment: "")
        case .nickName:
            cell.mode = .input
            cell.titleLabel.text = NSLocalizedString("Login_user_title",
                                                     comment: "")
            cell.textField.placeholder = NSLocalizedString("Login_user_holder",
                                                           comment: "")
        case .roomStyle:
            cell.mode = .option
            cell.titleLabel.text = NSLocalizedString("Login_class_type_title",
                                                     comment: "")
            cell.textField.placeholder = NSLocalizedString("Login_type_holder",
                                                           comment: "")
            cell.textField.text = optionDescription(option: inputParams.roomStyle,
                                                    in: kRoomOptions)
        case .roleType:
            // 美术小班课可选角色，其他不可选
            cell.mode = (inputParams.roomStyle == .paintingSmall) ? .option : .unable
            cell.titleLabel.text = NSLocalizedString("login_title_role",
                                                     comment: "")
            cell.textField.placeholder = optionDescription(option: defaultParams.roleType,
                                                           in: kRoleOptions)
            cell.textField.text = optionDescription(option: inputParams.roleType,
                                                    in: kRoleOptions)
        case .region:
            cell.mode = .option
            cell.titleLabel.text = NSLocalizedString("Login_region_title",
                                                     comment: "")
            cell.textField.placeholder = defaultParams.region?.rawValue
            cell.textField.text = optionDescription(option: inputParams.region,
                                                    in: kRegionOptions)
        case .duration:
            cell.mode = .unable
            cell.titleLabel.text = NSLocalizedString("Login_duration_title",
                                                     comment: "")
            cell.textField.placeholder = NSLocalizedString("Login_duration_holder",
                                                           comment: "")
        case .encryptKey:
            cell.mode = .input
            cell.titleLabel.text = NSLocalizedString("Login_encryptKey_title",
                                                     comment: "")
            cell.textField.placeholder = NSLocalizedString("Login_encryptKey_holder",
                                                           comment: "")
        case .encryptMode:
            cell.mode = .option
            cell.titleLabel.text = NSLocalizedString("Login_encryption_mode_title",
                                                     comment: "")
            cell.textField.placeholder = NSLocalizedString("Login_encryption_mode_holder",
                                                           comment: "")
            cell.textField.text = optionDescription(option: inputParams.encryptMode,
                                                         in: kEncryptionOptions)
        default:
            break
        }
        return cell
    }
    
    public func tableView(_ tableView: UITableView,
                          didSelectRowAt indexPath: IndexPath) {
        guard let cell = tableView.cellForRow(at: indexPath) as? RoomInfoCell else {
            return
        }
        if (selectedIndex != indexPath.row) {
            selectedIndex = indexPath.row
            tableView.reloadData()
        } else {
            hideOptions()
            return
        }
        
        let rowType = RoomInfoItemType(rawValue: indexPath.row)
        if rowType == .roomStyle {
            let options = optionStrings(form: kRoomOptions)
            let index = optionIndex(option: inputParams.roomStyle ?? defaultParams.roomStyle,
                                    in: kRoomOptions)
            optionsView.show(beside: cell,
                             options: options,
                             index: index) { [unowned self] i in
                self.hideOptions()
                let (v, str) = kRoomOptions[i]
                self.inputParams.roomStyle = v
                cell.textField.text = str
                // 不是美术小班课时将角色设置为学生
                if v != .paintingSmall {
                    self.inputParams.roleType = .student
                    tableView.reloadData()
                }
                // 更新入口状态
                self.updateEntranceStatus()
            }
        } else if rowType == .roleType,
                  inputParams.roomStyle == .paintingSmall {
            // 美术小班课可以选择角色，其他不可以
            let options = optionStrings(form: kRoleOptions)
            let index = optionIndex(option: inputParams.roleType ?? defaultParams.roleType, in: kRoleOptions)
            optionsView.show(beside: cell,
                             options: options,
                             index: index) { [unowned self] i in
                self.hideOptions()
                let (v, str) = kRoleOptions[i]
                self.inputParams.roleType = v
                cell.textField.text = str
            }
        }  else if rowType == .region {
            let options = optionStrings(form: kRegionOptions)
            let index = optionIndex(option: inputParams.region ?? defaultParams.region, in: kRegionOptions)
            optionsView.show(beside: cell,
                             options: options,
                             index: index) { [unowned self] i in
                self.hideOptions()
                let (v, str) = kRegionOptions[i]
                self.inputParams.region = v
                cell.textField.text = str
            }
        }  else if rowType == .encryptMode {
            let options = optionStrings(form: kEncryptionOptions)
            let index = optionIndex(option: inputParams.encryptMode ?? defaultParams.encryptMode, in: kEncryptionOptions)
            optionsView.show(beside: cell,
                             options: options,
                             index: index) { [unowned self] i in
                let (v, str) = kEncryptionOptions[i]
                self.inputParams.encryptMode = v
                cell.textField.text = str
                self.hideOptions()
            }
        } else {
            hideOptions()
        }
    }
    
    public func tableView(_ tableView: UITableView,
                          didDeselectRowAt indexPath: IndexPath) {
        hideOptions()
    }
    
    public func scrollViewWillBeginDragging(_ scrollView: UIScrollView) {
        hideOptions()
        UIApplication.shared.keyWindow?.endEditing(true)
    }
}

// MARK: - RoomInfoCellDelegate
extension LoginViewController: RoomInfoCellDelegate {
    func infoCellDidBeginEditing(cell: RoomInfoCell) {
        hideOptions()
        //moveView(move: cell.textField.getType().moveDistance)
    }
    
    func infoCellInputTextDidChange(cell: RoomInfoCell) {
        guard let text = cell.textField.text else {
            return
        }
        let itemType = RoomInfoItemType(rawValue: cell.indexPath.row)
        let pattern = "[a-zA-Z0-9]*$"
        let pred = NSPredicate(format: "SELF MATCHES %@", pattern)
        
        switch itemType {
        case .roomName:
            var isVaild = pred.evaluate(with: text)
            if text.count > 0 {
                isVaild = (isVaild && text.count >= minInputLength)
            }
            
            cell.isTextWaring = !isVaild
            inputParams.roomName = isVaild ? text : nil
        case .nickName:
            var isVaild = pred.evaluate(with: text)
            if text.count > 0 {
                isVaild = (isVaild && text.count >= minInputLength)
            }
            
            cell.isTextWaring = !isVaild
            inputParams.nickName = isVaild ? text : nil
        default:
            break
        }
        updateEntranceStatus()
    }
    
    func infoCellDidEndEditing(cell: RoomInfoCell) {
        
    }
}

// MARK: - Creations
private extension LoginViewController {
    func createViews() {
        if LoginConfig.device != .iPad{
            let image = UIImage(named: LoginConfig.device == .iPhone_Small ? "title_bg_small" : "title_bg")
            topImageView = AgoraBaseUIImageView(image: image)
            let label = AgoraBaseUILabel()
            label.text = NSLocalizedString("Login_title",
                                           comment: "")
            label.textColor = .white
            label.font = UIFont.systemFont(ofSize: 20)
            topImageView.addSubview(label)
            label.agora_center_x = 0
            label.agora_center_y = -2
            view.addSubview(topImageView)
        }
        
        logoImageView = AgoraBaseUIImageView(image: UIImage(named: "icon_\(LoginConfig.device.rawValue)"))
        view.addSubview(logoImageView)
        
        aboutButton = AgoraBaseUIButton()
        let image = UIImage(named: "about_tag_\(UIDevice.current.model)")
        aboutButton.setBackgroundImage(image,
                                       for: .normal)
        aboutButton.alpha = 0.7
        aboutButton.addTarget(self,
                              action: #selector(onTouchAbout),
                              for: .touchUpInside)
        view.addSubview(aboutButton)
        
        enterButton = AgoraBaseUIButton()
        enterButton.setTitle(NSLocalizedString("Login_enter",
                                               comment: ""),
                             for: .normal)
        enterButton.setTitleColor(.white,
                                  for: .normal)
        enterButton.backgroundColor = UIColor(hexString: "C0D6FF")
        enterButton.isUserInteractionEnabled = true
        enterButton.layer.cornerRadius = 22
        enterButton.addTarget(self,
                              action: #selector(onTouchJoinRoom),
                              for: .touchUpInside)
        view.addSubview(enterButton)
        
        bottomButton = AgoraBaseUIButton()
        
        let appVersion = "_" + Bundle.main.version
        let loginVersion = NSLocalizedString("Login_version",
                                             comment: "") + appVersion
        bottomButton.setTitle(loginVersion,
                              for: .normal)
        bottomButton.setTitleColor(UIColor(hexString: "7D8798"),
                                   for: .normal)
        bottomButton.titleLabel?.font = UIFont.systemFont(ofSize: 12)
        bottomButton.addTarget(self,
                               action: #selector(onPushDebugVC),
                               for: .touchUpInside)
        view.addSubview(bottomButton)
        
        view.addSubview(aboutView)
        
        tableView = AgoraBaseUITableView.init(frame: .zero,
                                              style: .plain)
        tableView.delegate = self
        tableView.dataSource = self
        tableView.tableFooterView = UIView()
        tableView.rowHeight = 60
        tableView.estimatedRowHeight = 60
        tableView.estimatedSectionHeaderHeight = 0
        tableView.estimatedSectionFooterHeight = 0
        tableView.separatorInset = .zero
        tableView.separatorStyle = .none
        tableView.allowsMultipleSelection = false
        view.addSubview(tableView)
    }
    
    func createConstrains() {
        if LoginConfig.device != .iPad {
            topImageView.agora_x = 0
            topImageView.agora_right = 0
            topImageView.agora_y = 0
        }
        
        logoImageView.agora_center_x = 0
        logoImageView.agora_y = LoginConfig.login_icon_y
        
        aboutButton.agora_width = 20
        aboutButton.agora_height = 20
        aboutButton.agora_y = 46
        aboutButton.agora_right = 15
        
        tableView.agora_center_x = 0
        tableView.agora_width = LoginConfig.login_group_width
        tableView.agora_height = LoginConfig.login_group_height * 5 + 20 * 4
        tableView.agora_y = LoginConfig.login_first_group_y
        
        let enter_gap: CGFloat = LoginConfig.device == .iPhone_Small ? 30 : 40
        enterButton.agora_center_x = 0
        enterButton.agora_height = 44
        enterButton.agora_width = 280
        enterButton.agora_y = tableView.agora_y + tableView.agora_height + enter_gap

        bottomButton.agora_center_x = 0
        if LoginConfig.device == .iPad {
            bottomButton.agora_bottom = LoginConfig.login_bottom_bottom
        } else {
            let height: CGFloat = max(UIScreen.main.bounds.width,
                                      UIScreen.main.bounds.height)
            if enterButton.agora_y > height - LoginConfig.login_bottom_bottom - 30 - enterButton.agora_height {
                bottomButton.agora_y = enterButton.agora_y + enterButton.agora_height + 30
            } else {
                bottomButton.agora_bottom = LoginConfig.login_bottom_bottom
            }
        }
    }
}

fileprivate extension RoomRegionType {
    var eduType: AgoraEduRegion {
        switch self {
        case .CN: return .CN
        case .NA: return .NA
        case .EU: return .EU
        case .AP: return .AP
        }
    }
}
