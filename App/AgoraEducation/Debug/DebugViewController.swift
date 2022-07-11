//
//  DebugViewController.swift
//  AgoraEducation
//
//  Created by SRS on 2021/2/16.
//  Copyright © 2021 Agora. All rights reserved.
//

#if canImport(AgoraClassroomSDK_iOS)
import AgoraClassroomSDK_iOS
#else
import AgoraClassroomSDK
#endif
import AgoraUIBaseViews
import SwifterSwift
import AgoraWidget
import AgoraLog
import UIKit
import AgoraEduUI

@objcMembers public class DebugViewController: UIViewController {
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
    
    private lazy var titleLabel = UILabel()
    /**only ipad **/
    private lazy var subTitleLabel = UILabel()
    /** only iphone */
    private lazy var topImageView = AgoraBaseUIImageView(frame: .zero)
    /** logo*/
    private var logoImageView: AgoraBaseUIImageView!
    /** close*/
    private var closeButton: AgoraBaseUIButton!
    /** 进入房间*/
    private var enterButton: AgoraBaseUIButton!
    
    private var bottomLabel: AgoraBaseUILabel!
    
    private var dataSource: [RoomInfoItemType] = [
        .roomName, .nickName, .roomStyle, .roleType, .region, .im, .duration, .encryptKey, .encryptMode, .startTime, .delay, .mediaAuth, .env
    ]
    
    private var inputParams = RoomInfoModel()
    
    private var selectedIndex = -1
    
    private let tokenBuilder = TokenBuilder()
    
    private let minInputLength = 6
}

// MARK: - override
extension DebugViewController {
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
        createConstraint()
    }
    
    public override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        // 检查协议
        if !ServicePrivacyViewController.getPolicyPopped() {
            let vc = ServicePrivacyViewController()
            vc.modalPresentationStyle = .fullScreen
            present(vc,
                    animated: true,
                    completion: nil)
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
private extension DebugViewController {
    func updateEntranceStatus() {
        if let roomName = inputParams.roomName,
           let nickName = inputParams.nickName,
           roomName.count > 0, nickName.count > 0 {
            enterButton.backgroundColor = UIColor(hexString: "357BF6")
            enterButton.isUserInteractionEnabled = true
        } else {
            enterButton.backgroundColor = UIColor(hexString: "C0D6FF")
            enterButton.isUserInteractionEnabled = false
        }
    }
    func updateOptions() {
        if self.inputParams.roomStyle == .vocational {
            self.dataSource = [
                .roomName, .nickName, .roomStyle, .serviceType, .roleType, .region, .im, .duration, .encryptKey, .encryptMode, .startTime, .delay, .mediaAuth, .env
            ]
        } else {
            self.dataSource = [
                .roomName, .nickName, .roomStyle, .roleType, .region, .im, .duration, .encryptKey, .encryptMode, .startTime, .delay, .mediaAuth, .env
            ]
        }
        self.tableView.reloadData()
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
private extension DebugViewController {
    @objc func onTouchClose() {
        dismiss(animated: true,
                completion: nil)
    }
    
    @objc func onTouchJoinRoom() {
        guard let roomName = inputParams.roomName,
              let userName = inputParams.nickName,
              let roomStyle = inputParams.roomStyle else {
            return
        }
        
        let region = inputParams.region
        let encryptionMode = inputParams.encryptMode
        let im = inputParams.im
        
        // roomUuid = roomName + classType
        var roomUuid = "\(roomName)\(roomStyle.rawValue)"
        // 职教处理
        if roomStyle == .vocational {
            roomUuid = "\(roomName)\(AgoraEduRoomType.lecture.rawValue)"
        }
        var latencyLevel = AgoraEduLatencyLevel.ultraLow
        if self.inputParams.serviceType == .RTC {
            latencyLevel = .ultraLow
        } else if self.inputParams.serviceType == .fastRTC {
            latencyLevel = .low
        }
        
        let userRole = self.inputParams.roleType
        let userUuid = "\(userName.md5())\(userRole.rawValue)"
        
        // startTime
        let startTime = inputParams.startTime
        
        let duration = inputParams.duration
        
        var encryptionConfig: AgoraEduMediaEncryptionConfig?
        
        if let key = inputParams.encryptKey,
           encryptionMode != .none {
            let tfModeValue = encryptionMode.rawValue
            if tfModeValue > 0 && tfModeValue <= 6 {
                encryptionConfig = AgoraEduMediaEncryptionConfig(mode: encryptionMode,
                                                                 key: key)
            }
        }
        
        let videoState: AgoraEduStreamState = (inputParams.mediaAuth == .video || inputParams.mediaAuth == .both) ? .on : .off
        let audioState: AgoraEduStreamState = (inputParams.mediaAuth == .audio || inputParams.mediaAuth == .both) ? .on : .off

        let mediaOptions = AgoraEduMediaOptions(encryptionConfig: encryptionConfig,
                                                videoEncoderConfig: nil,
                                                latencyLevel: latencyLevel,
                                                videoState: videoState,
                                                audioState: audioState)
        
        AgoraLoading.loading()
        
        let failure: (Error) -> () = { (error) in
            AgoraLoading.hide()
            AgoraToast.toast(msg: error.localizedDescription,
                             type: .error)
        }
        
        let success: () -> () = {
            AgoraLoading.hide()
        }
        
        requestToken(region: region,
                     roomId: roomUuid,
                     userId: userUuid,
                     userRole: inputParams.roleType.rawValue,
                     success: { [weak self] (response) in
                        guard let `self` = self else {
                            return
                        }
                        
                        let appId = response.appId
                        let token = response.token
                        let userUuid = response.userId
                        
                        let launchConfig = AgoraEduLaunchConfig(userName: userName,
                                                                userUuid: userUuid,
                                                                userRole: userRole,
                                                                roomName: roomName,
                                                                roomUuid: roomUuid,
                                                                roomType: roomStyle,
                                                                appId: appId,
                                                                token: token,
                                                                startTime: startTime,
                                                                duration: NSNumber(value: duration),
                                                                region: region.eduType,
                                                                uiMode: .light,
                                                                mediaOptions: mediaOptions,
                                                                userProperties: nil)
                        // MARK: 若对widgets需要添加或修改时，可获取launchConfig中默认配置的widgets进行操作并重新赋值给launchConfig
                        var widgets = Dictionary<String,AgoraWidgetConfig>()
                        launchConfig.widgets.forEach { [unowned self] (k,v) in
                            if k == "AgoraCloudWidget" {
                                v.extraInfo = ["publicCoursewares": self.inputParams.publicCoursewares()]
                            }

                            if k == "netlessBoard",
                               v.extraInfo != nil {
                                var newExtra = v.extraInfo as! Dictionary<String, Any>
                                newExtra["coursewareList"] = self.inputParams.publicCoursewares()
                                v.extraInfo = newExtra
                            }

                            widgets[k] = v
                        }
                        launchConfig.widgets = widgets
                        
                        if im == .rtm {
                            launchConfig.widgets.removeValue(forKey: "easemobIM")
                        }
                        
                        AgoraClassroomSDK.setDelegate(self)
                        
                        // set environment
                        let sel = NSSelectorFromString("setEnvironment:")
                        switch self.inputParams.env {
                        case .pro:
                            AgoraClassroomSDK.perform(sel,
                                                      with: 2)
                        case .pre:
                            AgoraClassroomSDK.perform(sel,
                                                      with: 1)
                        case .dev:
                            AgoraClassroomSDK.perform(sel,
                                                      with: 0)
                        }
            if launchConfig.roomType == .vocational { // 职教入口
                AgoraClassroomSDK.vocationalLaunch(launchConfig,
                                                   service: self.inputParams.serviceType ?? .RTC,
                                                   success: success,
                                                   failure: failure)
            } else { // 灵动课堂入口
                AgoraClassroomSDK.launch(launchConfig,
                                         success: success,
                                         failure: failure)
            }
        }, failure: failure)
    }
}

private extension DebugViewController {
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
                                               token: token)
        success(response)
    }
    
    func requestToken(region: RoomRegionType,
                      roomId: String,
                      userId: String,
                      userRole: Int,
                      success: @escaping (TokenBuilder.ServerResp) -> (),
                      failure: @escaping (Error) -> ()) {
        tokenBuilder.buildByServer(environment: inputParams.env,
                                   region: region.toServer,
                                   roomId: roomId,
                                   userId: userId,
                                   userRole: userRole) { (resp) in
            success(resp)
        } failure: { (error) in
            failure(error)
        }
    }
}

// MARK: - AgoraEduClassroomDelegate
extension DebugViewController: AgoraEduClassroomSDKDelegate {
    public func classroomSDK(_ classroom: AgoraClassroomSDK,
                             didExit reason: AgoraEduExitReason) {
        switch reason {
        case .kickOut:
            AgoraToast.toast(msg: "kick out")
        default:
            break
        }
    }
}

// MARK: - UITableViewDelegate, UITableViewDataSource
extension DebugViewController: UITableViewDelegate, UITableViewDataSource {
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
        let rowType = dataSource[indexPath.row]
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
        case .serviceType:
            cell.mode = .option
            cell.titleLabel.text = NSLocalizedString("Login_class_service_type_title",
                                                     comment: "")
            cell.textField.placeholder = NSLocalizedString("Login_service_type_holder",
                                                           comment: "")
            cell.textField.text = optionDescription(option: inputParams.serviceType,
                                                    in: kVocationalServiceOptions)
        case .roleType:
            cell.mode = .option
            cell.titleLabel.text = NSLocalizedString("login_title_role",
                                                     comment: "")
            cell.textField.placeholder = optionDescription(option: inputParams.roleType,
                                                           in: kRoleOptions)
            cell.textField.text = optionDescription(option: inputParams.roleType,
                                                    in: kRoleOptions)
        case .region:
            cell.mode = .option
            cell.titleLabel.text = NSLocalizedString("Login_region_title",
                                                     comment: "")
            cell.textField.placeholder = inputParams.region.rawValue
            cell.textField.text = optionDescription(option: inputParams.region,
                                                    in: kRegionOptions)
            
        case .im:
            cell.mode = .option
            cell.titleLabel.text = "IM"
            cell.textField.placeholder = inputParams.im.rawValue
            cell.textField.text = optionDescription(option: inputParams.im,
                                                    in: kIMOptions)
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
        case .startTime:
            cell.mode = .timePick
            cell.titleLabel.text = NSLocalizedString("Login_startTime_title",
                                                     comment: "")
        case .delay:
            cell.mode = .input
            cell.titleLabel.text = NSLocalizedString("Login_delay_title",
                                                     comment: "")
            cell.textField.placeholder = NSLocalizedString("Login_delay_holder",
                                                           comment: "")
        case .mediaAuth:
            cell.mode = .option
            cell.titleLabel.text = NSLocalizedString("Login_authMedia_title",
                                                     comment: "")
            cell.textField.placeholder = NSLocalizedString("Login_authMedia_holder",
                                                           comment: "")
            cell.textField.text = optionDescription(option: inputParams.mediaAuth,
                                                    in: kMediaAuthOptions)
        case .env:
            cell.mode = .option
            cell.titleLabel.text = NSLocalizedString("Login_env_title",
                                                     comment: "")
            cell.textField.placeholder = NSLocalizedString("Login_env_holder",
                                                           comment: "")
            cell.textField.text = optionDescription(option: inputParams.env,
                                                    in: kEnvironmentOptions)
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
        let rowType = dataSource[indexPath.row]
        switch rowType {
        case .roomStyle:
            let options = optionStrings(form: kRoomOptions)
            let index = optionIndex(option: inputParams.roomStyle,
                                    in: kRoomOptions)
            optionsView.show(beside: cell,
                             options: options,
                             index: index) { [unowned self] i in
                self.hideOptions()
                let (v, str) = kRoomOptions[i]
                self.inputParams.roomStyle = v
                cell.textField.text = str
                // 更新入口状态
                self.updateEntranceStatus()
                // 更新可选项
                self.updateOptions()
            }
        case .serviceType:
            let options = optionStrings(form: kVocationalServiceOptions)
            let index = optionIndex(option: inputParams.serviceType,
                                    in: kVocationalServiceOptions)
            optionsView.show(beside: cell,
                             options: options,
                             index: index) { [unowned self] i in
                self.hideOptions()
                let (v, str) = kVocationalServiceOptions[i]
                self.inputParams.serviceType = v
                cell.textField.text = str
                // 更新入口状态
                self.updateEntranceStatus()
            }
        case .roleType:
            let options = optionStrings(form: kRoleOptions)
            let index = optionIndex(option: inputParams.roleType,
                                    in: kRoleOptions)
            optionsView.show(beside: cell,
                             options: options,
                             index: index) { [unowned self] i in
                self.hideOptions()
                let (v, str) = kRoleOptions[i]
                self.inputParams.roleType = v
                cell.textField.text = str
            }
        case .region:
            let options = optionStrings(form: kRegionOptions)
            let index = optionIndex(option: inputParams.region,
                                    in: kRegionOptions)
            optionsView.show(beside: cell,
                             options: options,
                             index: index) { [unowned self] i in
                self.hideOptions()
                let (v, str) = kRegionOptions[i]
                self.inputParams.region = v
                cell.textField.text = str
            }
        case .encryptMode:
            let options = optionStrings(form: kEncryptionOptions)
            let index = optionIndex(option: inputParams.encryptMode,
                                    in: kEncryptionOptions)
            optionsView.show(beside: cell,
                             options: options,
                             index: index) { [unowned self] i in
                let (v, str) = kEncryptionOptions[i]
                self.inputParams.encryptMode = v
                cell.textField.text = str
                self.hideOptions()
            }
        case .im:
            let options = optionStrings(form: kIMOptions)
            let index = optionIndex(option: inputParams.im,
                                    in: kIMOptions)
            optionsView.show(beside: cell,
                             options: options,
                             index: index) { [unowned self] i in
                let (v, str) = kIMOptions[i]
                self.inputParams.im = v
                cell.textField.text = str
                self.hideOptions()
            }
        case .mediaAuth:
            let options = optionStrings(form: kMediaAuthOptions)
            let index = optionIndex(option: inputParams.mediaAuth,
                                    in: kMediaAuthOptions)
            optionsView.show(beside: cell,
                             options: options,
                             index: index) { [unowned self] i in
                let (v, str) = kMediaAuthOptions[i]
                self.inputParams.mediaAuth = v
                cell.textField.text = str
                self.hideOptions()
            }
        case .env:
            let options = optionStrings(form: kEnvironmentOptions)
            let index = optionIndex(option: inputParams.env,
                                    in: kEnvironmentOptions)
            optionsView.show(beside: cell,
                             options: options,
                             index: index) { [unowned self] i in
                let (v, str) = kEnvironmentOptions[i]
                self.inputParams.env = v
                cell.textField.text = str
                self.hideOptions()
            }
        default:
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
extension DebugViewController: RoomInfoCellDelegate {
    func infoCellDidBeginEditing(cell: RoomInfoCell) {
        hideOptions()
        //moveView(move: cell.textField.getType().moveDistance)
    }
    
    func infoCellInputTextDidChange(cell: RoomInfoCell) {
        guard let text = cell.textField.text else {
            return
        }
        let itemType = RoomInfoItemType(rawValue: cell.indexPath.row)
        
        switch itemType {
        case .roomName:
            let pattern = "[a-zA-Z0-9]*$"
            let pred = NSPredicate(format: "SELF MATCHES %@", pattern)
            var isVaild = pred.evaluate(with: text)
            if text.count > 0 {
                isVaild = (isVaild && text.count >= minInputLength)
            }
            
            cell.isRoomWarning = !isVaild
            inputParams.roomName = isVaild ? text : nil
        case .nickName:
            let pattern = "[\u{4e00}-\u{9fa5}a-zA-Z0-9\\s]*$"
            let pred = NSPredicate(format: "SELF MATCHES %@", pattern)
            
            var isVaild = pred.evaluate(with: text)
            if text.count > 0 {
                isVaild = (isVaild && text.count >= minInputLength)
            }
            
            cell.isUserWarning = !isVaild
            inputParams.nickName = isVaild ? text : nil
        case .encryptKey:
            inputParams.encryptKey = text
        default:
            break
        }
        updateEntranceStatus()
    }
    
    func infoCellDidEndEditing(cell: RoomInfoCell) {
        
    }
    
    func timePickerDidEndChoosing(timeInterval: Int64) {
        inputParams.startTime = NSNumber.init(value: timeInterval)
    }
}

// MARK: - Creations
private extension DebugViewController {
    func createViews() {
        let isPad = (LoginConfig.device == .iPad)
        if !isPad {
            let image = UIImage(named: LoginConfig.device == .iPhone_Small ? "title_bg_small" : "title_bg")
            topImageView.image = image
            view.addSubview(topImageView)
            
            titleLabel.textColor = .white
        } else {
            subTitleLabel.text = NSLocalizedString("About_url",
                                           comment: "")
            subTitleLabel.textColor = UIColor(hex: 0x677386)
            subTitleLabel.font = UIFont.systemFont(ofSize: 14)
            view.addSubview(subTitleLabel)
            
            titleLabel.textColor = UIColor(hex: 0x191919)
        }
        
        titleLabel.font = .systemFont(ofSize: isPad ? 24 : 20)
        titleLabel.text = NSLocalizedString("Login_title",
                                       comment: "")
        view.addSubview(titleLabel)
        
        let iconName = (LoginConfig.device == .iPhone_Small) ? "small" : "big"
        logoImageView = AgoraBaseUIImageView(image: UIImage(named: "icon_\(iconName)"))
        view.addSubview(logoImageView)
        
        closeButton = AgoraBaseUIButton()
        closeButton.setTitle("Close",
                             for: .normal)
        closeButton.addTarget(self,
                              action: #selector(onTouchClose),
                              for: .touchUpInside)
        view.addSubview(closeButton)
        
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
        
        let appVersion = "_" + AgoraClassroomSDK.version()
        let loginVersion = NSLocalizedString("Login_version",
                                             comment: "") + appVersion
        
        bottomLabel = AgoraBaseUILabel(frame: .zero)
        bottomLabel.text = loginVersion
        bottomLabel.textColor = UIColor(hexString: "7D8798")
        bottomLabel.font = UIFont.systemFont(ofSize: 12)
        view.addSubview(bottomLabel)
        
        view.addSubview(aboutView)
        
        tableView = AgoraBaseUITableView.init(frame: .zero,
                                              style: .plain)
        tableView.delegate = self
        tableView.dataSource = self
        tableView.tableFooterView = UIView()
        tableView.rowHeight = 68
        tableView.estimatedRowHeight = 68
        tableView.estimatedSectionHeaderHeight = 0
        tableView.estimatedSectionFooterHeight = 0
        tableView.separatorInset = .zero
        tableView.separatorStyle = .none
        tableView.allowsMultipleSelection = false
        view.addSubview(tableView)
    }
    
    func createConstraint() {
        let isPad = (LoginConfig.device == .iPad)
        if  !isPad {
            topImageView.mas_makeConstraints { make in
                make?.left.top().right().equalTo()(0)
                make?.height.equalTo()(150)
            }
            
            titleLabel.mas_makeConstraints { make in
                make?.centerX.equalTo()(0)
                make?.centerY.equalTo()(topImageView.mas_centerY)?.offset()(-2)
            }
        } else {
            titleLabel.mas_makeConstraints { make in
                make?.centerX.equalTo()(0)
                make?.top.equalTo()(logoImageView.mas_bottom)?.offset()(17)
            }
            
            subTitleLabel.mas_makeConstraints { make in
                make?.centerX.equalTo()(0)
                make?.top.equalTo()(titleLabel.mas_bottom)?.offset()(2)
            }
        }
        
        logoImageView.mas_makeConstraints { make in
            make?.centerX.equalTo()(0)
            make?.top.equalTo()(LoginConfig.login_icon_y)
        }
        
        closeButton.mas_makeConstraints { make in
            make?.top.equalTo()(46)
            make?.right.equalTo()(-15)
        }
        
        tableView.mas_makeConstraints { make in
            make?.centerX.equalTo()(0)
            make?.width.equalTo()(LoginConfig.login_group_width)
            make?.height.equalTo()(68 * 5)
            make?.top.equalTo()(LoginConfig.login_first_group_y)
        }
        
        let enter_gap: CGFloat = LoginConfig.device == .iPhone_Small ? 30 : 40
        enterButton.mas_makeConstraints { make in
            make?.centerX.equalTo()(0)
            make?.height.equalTo()(44)
            make?.width.equalTo()(280)
            make?.top.equalTo()(tableView.mas_bottom)?.offset()(enter_gap)
        }

        bottomLabel.mas_makeConstraints { make in
            make?.centerX.equalTo()(0)
            make?.bottom.equalTo()(-LoginConfig.login_bottom_bottom)
        }
    }
}
