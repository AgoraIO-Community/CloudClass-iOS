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
        .roomName,
        .nickName,
        .roomStyle,
        .roleType,
        .im,
        .duration,
        .encryptKey,
        .encryptMode,
        .startTime,
        .delay,
        .mediaAuth,
        .uiMode,
        .uiLanguage,
        .region,
        .env
    ]
    
    private var inputParams = RoomInfoModel()
    
    private var selectedIndex = -1
    
    private let tokenBuilder = TokenBuilder()
    
    private let minInputLength = 6
    
    /** 房间可选项*/
    var kRoomOptions: [(AgoraEduRoomType, String)] {
        var array = [(AgoraEduRoomType, String)]()
        
        let list = AgoraEduRoomType.getList()
        
        for item in list {
            switch item {
            case .oneToOne: array.append((.oneToOne, "Login_onetoone".ag_localized()))
            case .small:    array.append((.small, "Login_small".ag_localized()))
            case .lecture:  array.append((.lecture, "Login_lecture".ag_localized()))
            case .vocation: array.append((.vocation, "Login_vocational_lecture".ag_localized()))
            @unknown default: break
            }
        }
        
        return array
    }
    
    /** 角色可选项*/
    let kRoleOptions: [(AgoraEduUserRole, String)] = [
        (.student, "login_role_student".ag_localized()),
        (.teacher, "login_role_teacher".ag_localized()),
        (.observer, "login_role_observer".ag_localized()),
    ]

    let kIMOptions: [(IMType, String)] = [
        (.rtm, "rtm"),
        (.easemob, "easemon")
    ]

    /** 加密方式可选项*/
    let kEncryptionOptions: [(AgoraEduMediaEncryptionMode, String)] = [
        (.none, "None"),
        (.SM4128ECB, "sm4-128-ecb"),
        (.AES128GCM2, "aes-128-gcm2"),
        (.AES256GCM2, "aes-256-gcm2"),
    ]

    /** 环境可选项*/
    let kEnvironmentOptions: [(FcrEnvironment.Environment, String)] = [
        (.dev, "login_env_test".ag_localized()),
        (.pre, "login_pre_test".ag_localized()),
        (.pro, "login_pro_test".ag_localized())
    ]

    /** 上台后音视频是否自动发流权限*/
    let kMediaAuthOptions: [(AgoraEduMediaAuthOption, String)] = [
        (.none, "login_auth_none".ag_localized()),
        (.audio, "login_auth_audio".ag_localized()),
        (.video, "login_auth_video".ag_localized()),
        (.both, "login_auth_both".ag_localized())
    ]
    
    /** 主题模式*/
    let kUIModeOptions: [(AgoraUIMode, String)] = [
        (.agoraLight, "settings_theme_light".ag_localized()),
        (.agoraDark, "settings_theme_dark".ag_localized()),
    ]
    
    /** 语言*/
    let kUILanguageOptions: [(FcrSurpportLanguage, String)] = [
        (.zh_cn, "Login_uiLanguage_zh_cn".ag_localized()),
        (.en, "Login_uiLanguage_en".ag_localized()),
    ]
    /** 区域可选项*/
    let kRegionOptions: [(FcrEnvironment.Region, String)] = [
        (.CN, FcrEnvironment.Region.CN.rawValue),
        (.NA, FcrEnvironment.Region.NA.rawValue),
        (.EU, FcrEnvironment.Region.EU.rawValue),
        (.AP, FcrEnvironment.Region.AP.rawValue),
    ]
    /** 服务类型可选项*/
    let kVocationalServiceOptions: [(AgoraEduServiceType, String)] = [
        (.livePremium, "Login_service_rtc".ag_localized()),
        (.liveStandard, "Login_service_fast_rtc".ag_localized()),
        (.CDN, "Login_service_only_cdn".ag_localized()),
        (.fusion, "Login_service_mixed_cdn".ag_localized()),
        (.mixStreamCDN, "合流转推"),
        (.hostingScene, "伪直播"),
    ]
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
        
        // setup agora loading
        if let bundle = Bundle.agora_bundle("AgoraEduUI"),
           let url = bundle.url(forResource: "img_loading",
                                withExtension: "gif"),
           let data = try? Data(contentsOf: url) {
            AgoraLoading.setImageData(data)
        }
        
        let noticeImage = UIImage(named: "toast_notice")!
        let warningImage = UIImage(named: "toast_warning")!
        let errorImage = UIImage(named: "toast_warning")!
        
        AgoraToast.setImages(noticeImage: noticeImage,
                             warningImage: warningImage,
                             errorImage: errorImage)
        
        createViews()
        createConstraint()
    }
    
    public override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        
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
        if self.inputParams.roomStyle == .vocation {
            self.dataSource = [
                .roomName, .nickName, .roomStyle, .serviceType, .roleType, .im, .duration, .encryptKey, .encryptMode, .startTime, .delay, .mediaAuth, .uiMode, .uiLanguage, .region, .env
            ]
        } else {
            self.dataSource = [
                .roomName, .nickName, .roomStyle, .roleType, .im, .duration, .encryptKey, .encryptMode, .startTime, .delay, .mediaAuth, .uiMode, .uiLanguage, .region, .env
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
        FcrUserInfoPresenter.shared.qaMode = false
        dismiss(animated: true,
                completion: nil)
    }
    
    @objc func onTouchJoinRoom() {
        guard let roomName = inputParams.roomName,
              let userName = inputParams.nickName,
              let roomStyle = inputParams.roomStyle else {
            return
        }
        
        let region = self.getLaunchRegion()
        let encryptionMode = inputParams.encryptMode
        let im = inputParams.im
        
        var roomTag: Int
        
        switch roomStyle {
        case .oneToOne:   roomTag = 0
        case .small:      roomTag = 4
        case .lecture:    roomTag = 2
        case .vocation:   roomTag = 2
        @unknown default: fatalError()
        }
        
        let roomUuid = "\(roomName.md5())\(roomTag)"
        
        var latencyLevel = AgoraEduLatencyLevel.ultraLow
        
        if self.inputParams.serviceType == .livePremium {
            latencyLevel = .ultraLow
        } else if self.inputParams.serviceType == .liveStandard {
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
            AgoraToast.toast(message: error.localizedDescription,
                             type: .error)
        }
        
        let success: () -> () = {
            AgoraLoading.hide()
        }
        
        requestToken(roomId: roomUuid,
                     userId: userUuid,
                     userRole: inputParams.roleType.rawValue,
                     success: { [weak self] (response) in
            guard let `self` = self else {
                return
            }
            
            // UI Mode & Language
            agora_ui_mode = self.getLaunchUIMode()
            agora_ui_language = self.getLaunchLanguage()
            
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
                                                    region: region,
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
            if launchConfig.roomType == .vocation { // 职教入口
                AgoraClassroomSDK.vocationalLaunch(launchConfig,
                                                   service: self.inputParams.serviceType ?? .livePremium,
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
    
    func requestToken(roomId: String,
                      userId: String,
                      userRole: Int,
                      success: @escaping (TokenBuilder.ServerResp) -> (),
                      failure: @escaping (Error) -> ()) {
        FcrOutsideClassAPI.freeBuildToken(roomId: roomId, userRole: userRole, userId: userId) { dict in
            guard let data = dict["data"] as? [String : Any] else {
                fatalError("TokenBuilder buildByServer can not find data, dict: \(dict)")
            }
            guard let token = data["token"] as? String,
                  let appId = data["appId"] as? String,
                  let userId = data["userUuid"] as? String else {
                fatalError("TokenBuilder buildByServer can not find value, dict: \(dict)")
            }
            let resp = TokenBuilder.ServerResp(appId: appId,
                                               userId: userId,
                                               token: token)
            success(resp)
        } onFailure: { msg in
            let error = NSError.init(domain: msg, code: -1)
            failure(error)
        }
    }
    
    func getLaunchRegion() -> AgoraEduRegion {
        switch FcrEnvironment.shared.region {
        case .CN: return .CN
        case .NA: return .NA
        case .EU: return .EU
        case .AP: return .AP
        }
    }
    
    func getLaunchLanguage() -> String? {
        switch FcrLocalization.shared.language {
        case .zh_cn: return "zh-Hans"
        case .en:    return "en"
        case .zh_tw: return nil
        case .none:  return nil
        }
    }
    
    func getLaunchUIMode() -> AgoraUIMode {
        if let mode = AgoraUIMode(rawValue: FcrUserInfoPresenter.shared.theme) {
            return mode
        } else {
            return .agoraLight
        }
    }
    
    func getUILanguage() -> FcrSurpportLanguage {
        if let language = FcrLocalization.shared.language {
            return language
        }
        return .zh_cn
    }
}

// MARK: - AgoraEduClassroomDelegate
extension DebugViewController: AgoraEduClassroomSDKDelegate {
    public func classroomSDK(_ classroom: AgoraClassroomSDK,
                             didExit reason: AgoraEduExitReason) {
        switch reason {
        case .kickOut:
            AgoraToast.toast(message: "kick out")
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
            cell.titleLabel.text = "Login_room_title".ag_localized()
            cell.textField.placeholder = "Login_room_holder".ag_localized()
        case .nickName:
            cell.mode = .input
            cell.titleLabel.text = "Login_user_title".ag_localized()
            cell.textField.placeholder = "Login_user_holder".ag_localized()
        case .roomStyle:
            cell.mode = .option
            cell.titleLabel.text = "Login_class_type_title".ag_localized()
            cell.textField.placeholder = "Login_type_holder".ag_localized()
            cell.textField.text = optionDescription(option: inputParams.roomStyle,
                                                    in: kRoomOptions)
        case .serviceType:
            cell.mode = .option
            cell.titleLabel.text = "Login_class_service_type_title".ag_localized()
            cell.textField.placeholder = "Login_service_type_holder".ag_localized()
            cell.textField.text = optionDescription(option: inputParams.serviceType,
                                                    in: kVocationalServiceOptions)
        case .roleType:
            cell.mode = .option
            cell.titleLabel.text = "login_title_role".ag_localized()
            cell.textField.placeholder = optionDescription(option: inputParams.roleType,
                                                           in: kRoleOptions)
            cell.textField.text = optionDescription(option: inputParams.roleType,
                                                    in: kRoleOptions)
        case .im:
            cell.mode = .option
            cell.titleLabel.text = "IM"
            cell.textField.placeholder = inputParams.im.rawValue
            cell.textField.text = optionDescription(option: inputParams.im,
                                                    in: kIMOptions)
        case .duration:
            cell.mode = .unable
            cell.titleLabel.text = "Login_duration_title".ag_localized()
            cell.textField.placeholder = "Login_duration_holder".ag_localized()
        case .encryptKey:
            cell.mode = .input
            cell.titleLabel.text = "Login_encryptKey_title".ag_localized()
            cell.textField.placeholder = "Login_encryptKey_holder".ag_localized()
        case .encryptMode:
            cell.mode = .option
            cell.titleLabel.text = "Login_encryption_mode_title".ag_localized()
            cell.textField.placeholder = "Login_encryption_mode_holder".ag_localized()
            cell.textField.text = optionDescription(option: inputParams.encryptMode,
                                                    in: kEncryptionOptions)
        case .startTime:
            cell.mode = .timePick
            cell.titleLabel.text = "Login_startTime_title".ag_localized()
        case .delay:
            cell.mode = .input
            cell.titleLabel.text = "Login_delay_title".ag_localized()
            cell.textField.placeholder = "Login_delay_holder".ag_localized()
        case .mediaAuth:
            cell.mode = .option
            cell.titleLabel.text = "Login_authMedia_title".ag_localized()
            cell.textField.placeholder = "Login_authMedia_holder".ag_localized()
            cell.textField.text = optionDescription(option: inputParams.mediaAuth,
                                                    in: kMediaAuthOptions)
        case .uiMode:
            cell.mode = .option
            cell.titleLabel.text = "Login_uiMode_title".ag_localized()
            cell.textField.placeholder = "Login_uiMode_holder".ag_localized()
            cell.textField.text = optionDescription(option: getLaunchUIMode(),
                                                    in: kUIModeOptions)
        case .uiLanguage:
            cell.mode = .option
            cell.titleLabel.text = "Login_uiLanguage_title".ag_localized()
            cell.textField.placeholder = "Login_uiLanguage_holder".ag_localized()
            cell.textField.text = optionDescription(option: getUILanguage(),
                                                    in: kUILanguageOptions)
        case .region:
            cell.mode = .option
            cell.titleLabel.text = "Login_region_title".ag_localized()
            cell.textField.placeholder = ""
            cell.textField.text = optionDescription(option: FcrEnvironment.shared.region,
                                                    in: kRegionOptions)
        case .env:
            cell.mode = .option
            cell.titleLabel.text = "Login_env_title".ag_localized()
            cell.textField.placeholder = "Login_env_holder".ag_localized()
            cell.textField.text = optionDescription(option: FcrEnvironment.shared.environment,
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
        case .uiMode:
            let options = optionStrings(form: kUIModeOptions)
            let index = optionIndex(option: getLaunchUIMode(),
                                    in: kUIModeOptions)
            optionsView.show(beside: cell,
                             options: options,
                             index: index) { [unowned self] i in
                let (v, str) = kUIModeOptions[i]
                FcrUserInfoPresenter.shared.theme = v.rawValue
                cell.textField.text = str
                self.hideOptions()
            }
        case .uiLanguage:
            let options = optionStrings(form: kUILanguageOptions)
            let index = optionIndex(option: getUILanguage(),
                                    in: kUILanguageOptions)
            optionsView.show(beside: cell,
                             options: options,
                             index: index) { [unowned self] i in
                let (v, str) = kUILanguageOptions[i]
                FcrLocalization.shared.setupNewLanguage(v)
                cell.textField.text = str
                self.hideOptions()
            }
        case .region:
            let options = optionStrings(form: kRegionOptions)
            let index = optionIndex(option: FcrEnvironment.shared.region,
                                    in: kRegionOptions)
            optionsView.show(beside: cell,
                             options: options,
                             index: index) { [unowned self] i in
                let (v, str) = kRegionOptions[i]
                FcrEnvironment.shared.region = v
                cell.textField.text = str
                self.hideOptions()
            }
        case .env:
            let options = optionStrings(form: kEnvironmentOptions)
            let index = optionIndex(option: FcrEnvironment.shared.environment,
                                    in: kEnvironmentOptions)
            optionsView.show(beside: cell,
                             options: options,
                             index: index) { [unowned self] i in
                let (v, str) = kEnvironmentOptions[i]
                FcrEnvironment.shared.environment = v
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
            subTitleLabel.text = "settings_powerd_by".ag_localized()
            subTitleLabel.textColor = UIColor(hex: 0x677386)
            subTitleLabel.font = UIFont.systemFont(ofSize: 14)
            view.addSubview(subTitleLabel)
            
            titleLabel.textColor = UIColor(hex: 0x191919)
        }
        
        titleLabel.font = .systemFont(ofSize: isPad ? 24 : 20)
        titleLabel.text = "Login_title".ag_localized()
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
        enterButton.setTitle("Login_enter".ag_localized(),
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
        let loginVersion = "Login_version".ag_localized() + appVersion
        
        bottomLabel = AgoraBaseUILabel(frame: .zero)
        bottomLabel.text = loginVersion
        bottomLabel.textColor = UIColor(hexString: "7D8798")
        bottomLabel.font = UIFont.systemFont(ofSize: 12)
        view.addSubview(bottomLabel)
                
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
