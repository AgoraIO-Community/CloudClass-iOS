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

@objcMembers public class LoginViewController: UIViewController {
    private var alertView: AgoraAlertView?
    
    private var roomWarn: AgoraBaseUILabel?
    private var userWarn: AgoraBaseUILabel?
    private var roomName: String? {
        didSet{
            checkConfig()
        }
    }
    
    private var userName: String? {
        didSet{
            checkConfig()
        }
    }
    
    private var classType: AgoraEduRoomType? {
        didSet{
            checkConfig()
        }
    }
    
    private var duration: NSNumber = NSNumber(value: 1800)
    
    private var region: String = Region_Type.CN.rawValue
    
    private var encryptionMode: AgoraEduMediaEncryptionMode = .none
    
    private var contentView: AgoraBaseUIScrollView = {
        let view = AgoraBaseUIScrollView()
        view.contentSize = CGSize(width: LoginConfig.login_group_width,
                                  height: LoginConfig.login_group_height * 7 + 20 * 6)
        view.backgroundColor = .white
        view.isScrollEnabled = true
        view.isUserInteractionEnabled = true
        return view
    }()
    
    private lazy var titleBg: AgoraBaseUIImageView = {
        let image = UIImage(named: LoginConfig.device == .iPhone_Small ? "title_bg_small" : "title_bg")
        
        let titleBg = AgoraBaseUIImageView(image: image)
        
        let label = AgoraBaseUILabel()
        label.text = NSLocalizedString("Login_title",
                                       comment: "")
        label.textColor = .white
        label.font = UIFont.systemFont(ofSize: 20)
        
        titleBg.addSubview(label)
        
        label.agora_center_x = 0
        label.agora_center_y = -2
        
        return titleBg
    }()
    
    private lazy var iconImgView = AgoraBaseUIImageView(image: UIImage(named: "icon_\(LoginConfig.device.rawValue)"))
    
    private lazy var aboutBtn: AgoraBaseUIButton = {
        let aboutBtn = AgoraBaseUIButton()
        let image = UIImage(named: "about_tag_\(UIDevice.current.model)")
        aboutBtn.setBackgroundImage(image,
                                    for: .normal)
        aboutBtn.alpha = 0.7
        aboutBtn.addTarget(self,
                           action: #selector(onTouchAbout),
                           for: .touchUpInside)
        return aboutBtn
    }()

    // encrypt
    private lazy var encryptionKeyFieldGroup = createFieldGroup(fieldType: .encryptKey)
    private lazy var encryptionModeGroup = createChooseGroup(title: NSLocalizedString("Login_encryption_mode_title",comment: ""),
                                                            defaultLabel: modeHolderLabel,
                                                            action: #selector(onTouchShowModes))
    
    private lazy var roomGroup = createFieldGroup(fieldType: .room)
    private lazy var userGroup = createFieldGroup(fieldType: .user)
    private lazy var durationGroup = createFieldGroup(fieldType: .duration)

    private lazy var roomLine = createGroupLine()
    private lazy var userLine = createGroupLine()
    private lazy var durationLine = createGroupLine()
     
    private lazy var classTypeHolderLabel = createHolderLabel(str: NSLocalizedString("Login_type_holder",
                                                                                     comment: ""))
    private lazy var regionHolderLabel = createHolderLabel(str: LoginConfig.RegionList.first ?? "")
    
    private lazy var modeHolderLabel = createHolderLabel(str: NSLocalizedString("Login_encryption_mode_holder",
                                                                                comment: ""))
    
    private lazy var classTypeGroup = createChooseGroup(title: NSLocalizedString("Login_class_type_title",
                                                                                 comment: ""),
                                                        defaultLabel: classTypeHolderLabel,
                                                        action: #selector(onTouchShowClassTypes))
    
    private lazy var regionTypeGroup = createChooseGroup(title: NSLocalizedString("Login_region_title",
                                                                                  comment: ""),
                                                        defaultLabel: regionHolderLabel,
                                                        action: #selector(onTouchShowRegions))
    
    private lazy var classTypesView: ChooseTableView = {
        var arr: Array<String> = []
        LoginConfig.ClassTypes.forEach { (type, str) in
            arr.append(str)
        }
        let classTypeView = ChooseTableView(cell_id: LoginConfig.class_cell_id,
                                            list: arr) { [weak self] (row) in
            guard let strongSelf = self else {
                return
            }
            
            strongSelf.classType = LoginConfig.ClassTypes[row].0
            strongSelf.classTypesView.isHidden = true
            guard let (type, str) = LoginConfig.ClassTypes.first(where: { $0.0 == LoginConfig.ClassTypes[row].0 }) else {
                return
            }
            strongSelf.classTypeHolderLabel.text = str
            strongSelf.classTypeHolderLabel.textColor = UIColor(hexString: "191919")
        }
        classTypeView.isHidden = true
        return classTypeView
    }()
    
    private lazy var regionTypesView: ChooseTableView = {
        let regionTypeView = ChooseTableView(cell_id: LoginConfig.region_cell_id,
                                             list: LoginConfig.RegionList) { [weak self] (row) in
            let region = LoginConfig.RegionList[row]
            
            guard let strongSelf = self,
                  let regionString = Region_Type(rawValue: region) else {
                return
            }
            
            strongSelf.region = region
            strongSelf.regionTypesView.isHidden = true
            strongSelf.regionHolderLabel.text = LoginConfig.RegionList[row]
            strongSelf.regionHolderLabel.textColor = UIColor(hexString: "191919")
        }
        regionTypeView.isHidden = true
        return regionTypeView
    }()
    
    private lazy var encryptionModesView: ChooseTableView = {
        var arr: Array<String> = []
        LoginConfig.EncryptionTypes.forEach { (type, str) in
            arr.append(str)
        }
        let encryptionModeView = ChooseTableView(cell_id: LoginConfig.encryption_cell_id,
                                            list: arr) { [weak self] (row) in
            guard let strongSelf = self else {
                return
            }
            
            strongSelf.encryptionMode = LoginConfig.EncryptionTypes[row].0
            strongSelf.encryptionModesView.isHidden = true
            guard let (type, str) = LoginConfig.EncryptionTypes.first(where: { $0.0 == LoginConfig.EncryptionTypes[row].0 }) else {
                return
            }
            strongSelf.modeHolderLabel.text = str
            strongSelf.modeHolderLabel.textColor = UIColor(hexString: "191919")
        }
        encryptionModeView.isHidden = true
        encryptionModeView.setScrollEnabled(enabled: true)
        return encryptionModeView
    }()
    
    private lazy var aboutView: AboutView = {
        let about = AboutView(frame: .zero)
        about.alpha = 0
        return about
    }()

    private lazy var enterBtn: AgoraBaseUIButton = {
        let enterBtn = AgoraBaseUIButton()
        enterBtn.setTitle(NSLocalizedString("Login_enter",
                                            comment: ""),
                          for: .normal)
        enterBtn.setTitleColor(.white,
                               for: .normal)
        enterBtn.backgroundColor = UIColor(hexString: "C0D6FF")
        enterBtn.isUserInteractionEnabled = true
        enterBtn.layer.cornerRadius = 22
        enterBtn.addTarget(self,
                           action: #selector(onTouchJoinRoom),
                           for: .touchUpInside)
        return enterBtn
    }()
    
    private lazy var bottomLabel: AgoraBaseUIButton = {
        let bottom = AgoraBaseUIButton()
        
        let infoDictionary = Bundle.main.infoDictionary
        var appVersion = infoDictionary?["CFBundleShortVersionString"] as? String ?? ""
        if appVersion.count > 0 {
            appVersion = "_" + appVersion
        }

        let loginVersion = NSLocalizedString("Login_version",
                                             comment: "") + appVersion
        bottom.setTitle(loginVersion,
                        for: .normal)
        bottom.setTitleColor(UIColor(hexString: "7D8798"),
                             for: .normal)
        bottom.titleLabel?.font = UIFont.systemFont(ofSize: 12)
        bottom.addTarget(self,
                         action: #selector(onPushDebugVC),
                         for: .touchUpInside)
        return bottom
    }()
    
    private var classroom: AgoraEduClassroom?
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
        initView()
        initLayout()

        checkPrivacyPolicy()
    }
    
    public override func touchesBegan(_ touches: Set<UITouch>,
                                      with event: UIEvent?) {
        super.touchesBegan(touches,
                           with: event)
        touchesBegan()
    }
}

// MARK: private
private extension LoginViewController {
    func checkConfig(){
        guard roomName != nil,
              userName != nil,
              classType != nil else {
            enterBtn.backgroundColor = UIColor(hexString: "C0D6FF")
            enterBtn.isUserInteractionEnabled = false
            return
        }
        enterBtn.backgroundColor = UIColor(hexString: "357BF6")
        enterBtn.isUserInteractionEnabled = true
    }
    
    func checkInputLegality(text: String) -> Bool {
        let pattern = "[a-zA-Z0-9]*$"
        let pred = NSPredicate(format: "SELF MATCHES %@", pattern)
        return pred.evaluate(with: text)
    }
    
    func handleWithTextfield(field: AgoraBaseUITextField,
                             ifLegal: Bool) {
        guard ifLegal else {
            
            enterBtn.backgroundColor = UIColor(hexString: "C0D6FF")
            enterBtn.isUserInteractionEnabled = false
            
            switch field.getType() {
            case .room:
                roomLine.backgroundColor =  UIColor(hexString: "F04C36")
                if roomWarn == nil {
                    roomWarn = addWarnLabel(group: roomGroup)
                }
                roomWarn?.isHidden = false
            case .user:
                userLine.backgroundColor =  UIColor(hexString: "F04C36")
                if userWarn == nil {
                    userWarn = addWarnLabel(group: userGroup)
                }
                userWarn?.isHidden = false
            default:
                return
            }
            return
        }
        
        switch field.getType() {
        case .room:
            roomWarn?.isHidden = true
            roomLine.backgroundColor = UIColor(rgb: 0xE3E3EC)
            roomName = field.text
        case .user:
            userWarn?.isHidden = true
            userLine.backgroundColor = UIColor(rgb: 0xE3E3EC)
            userName = field.text
        default:
            return
        }
    }
    
    private func checkPrivacyPolicy() {
        if !TermsAndPolicyViewController.getPolicyPopped() {
            showPrivacyPolicy()
        }
    }

    private func showPrivacyPolicy() {
        if let termsVC = TermsAndPolicyViewController.loadFromStoryboard("privacy", "terms") {
            present(termsVC, animated: true, completion: nil)
        }
    }
    
    func registerExtApps() {
        let countDown = AgoraExtAppConfiguration(appIdentifier: "io.agora.countdown",
                                                 extAppClass: CountDownExtApp.self,
                                                 frame: UIEdgeInsets(top: 0,
                                                                     left: 0,
                                                                     bottom: 0,
                                                                     right: 0),
                                                 language: "zh")
        countDown.image = UIImage(named: "countdown")
        let apps = [countDown]
        AgoraClassroomSDK.registerExtApps(apps)
    }
}

// MARK: UI
private extension LoginViewController {
     func addWarnLabel(group: AgoraBaseUIView) -> AgoraBaseUILabel {
        let warn = AgoraBaseUILabel()
        warn.text = NSLocalizedString("Login_warn",
                                      comment: "")
        warn.font = UIFont.systemFont(ofSize: 10)
        warn.textColor = UIColor(hexString: "F04C36")
        warn.isHidden = true
        
        contentView.addSubview(warn)
        
        warn.agora_center_x = 0
        warn.agora_y = group.frame.origin.y + group.frame.size.height + 3
        
        return warn
    }
    
    func createFieldGroup(fieldType: FIELD_TYPE,
                          tag: String? = nil) -> AgoraBaseUIView {
        let group = AgoraBaseUIView()
        
        let titleLabel = AgoraBaseUILabel()

        if let `tag` = tag {
             titleLabel.text = tag
         } else {
             titleLabel.text = NSLocalizedString("Login_\(fieldType.rawValue)_title",comment: "")
         }
        titleLabel.textColor = UIColor(hexString: "8A8A9A")
        titleLabel.font = UIFont.systemFont(ofSize: 14)
        
        let field = AgoraBaseUITextField(id: fieldType.rawValue)
        field.font = UIFont.systemFont(ofSize: 14)
        field.placeholder = NSLocalizedString("Login_\(fieldType.rawValue)_holder",comment: "")
        field.tag = 99
        field.delegate = self
        
        group.addSubview(titleLabel)
        group.addSubview(field)

        titleLabel.agora_x = 0
        titleLabel.agora_center_y = 0
        titleLabel.agora_width = LoginConfig.login_group_title_width
        titleLabel.agora_height = LoginConfig.login_group_height - 1
        
        field.agora_x = titleLabel.agora_width
        field.agora_center_y = 0
        field.agora_right = 0
        field.agora_height = LoginConfig.login_group_height - 1
        
        switch fieldType {
        case .room:
            group.addSubview(roomLine)
            setLineLayout(line: roomLine)
        case .user:
            group.addSubview(userLine)
            setLineLayout(line: userLine)
        case .duration:
            group.addSubview(durationLine)
            setLineLayout(line: durationLine)
        case .encryptKey:
            let line = createGroupLine()
            group.addSubview(line)
            setLineLayout(line: line)
        case .encryptMode:
            let line = createGroupLine()
            group.addSubview(line)
            setLineLayout(line: line)
        default:
            print("")
        }

        return group
    }
    
    func createGroupLine() -> AgoraBaseUIView {
        let line = AgoraBaseUIView()
        line.backgroundColor = UIColor(rgb: 0xE3E3EC)
        return line
    }
    
    func setLineLayout(line: AgoraBaseUIView) {
        line.agora_safe_x = 0
        line.agora_width = LoginConfig.login_group_width
        line.agora_height = 1
        line.agora_bottom = 0
    }
    
    func createChooseGroup(title: String,
                           defaultLabel: AgoraBaseUILabel,
                           action: Selector?) -> AgoraBaseUIView {
        let group = AgoraBaseUIView()
        
        let titleLabel = AgoraBaseUILabel()
        titleLabel.text = title
        titleLabel.textColor = UIColor(hexString: "8A8A9A")
        titleLabel.font = UIFont.systemFont(ofSize: 14)
        
        let chooseBtn = AgoraBaseUIButton()
        chooseBtn.setBackgroundImage(UIImage(named: "show_types"), for: .normal)
        chooseBtn.isUserInteractionEnabled = false
        
        let line = createGroupLine()
        
        group.addSubview(line)
        group.addSubview(titleLabel)
        group.addSubview(defaultLabel)
        group.addSubview(chooseBtn)
        
        group.addGestureRecognizer(UITapGestureRecognizer(target: self,
                                                          action: action))
        
        titleLabel.agora_x = 0
        titleLabel.agora_center_y = 0
        titleLabel.agora_width = LoginConfig.login_group_title_width
        titleLabel.agora_height = LoginConfig.login_group_height - 1
        
        defaultLabel.agora_x = titleLabel.agora_width
        defaultLabel.agora_center_y = 0
        defaultLabel.agora_right = 0
        defaultLabel.agora_height = LoginConfig.login_group_height - 1
        
        line.agora_safe_x = 0
        line.agora_width = LoginConfig.login_group_width
        line.agora_height = 1
        line.agora_bottom = 0
        
        chooseBtn.agora_right = 0
        chooseBtn.agora_y = 11
        
        return group
    }
    
    func createHolderLabel(str: String) -> AgoraBaseUILabel {
        let label = AgoraBaseUILabel()
        label.text = str
        label.font = UIFont.systemFont(ofSize: 14)
        label.textColor = UIColor(hexString: "BDBDCA")
        label.isUserInteractionEnabled = false
        return label
    }
    
    func moveView(move: CGFloat) {
        UIView.animate(withDuration: TimeInterval.agora_animation) { [weak self] in
            self?.view.frame.origin.y -= move
        }
    }
    
    func initView() {
        view.backgroundColor = .white
        
        view.addSubview(contentView)
        
        if LoginConfig.device != .iPad{
            view.addSubview(titleBg)
        }
        
        view.addSubview(iconImgView)
        view.addSubview(aboutBtn)
        // encrypt
        contentView.addSubview(encryptionKeyFieldGroup)
        contentView.addSubview(encryptionModeGroup)
        
        contentView.addSubview(roomGroup)
        contentView.addSubview(userGroup)
        contentView.addSubview(classTypeGroup)
        contentView.addSubview(regionTypeGroup)
        view.addSubview(classTypesView)
        view.addSubview(regionTypesView)
        view.addSubview(encryptionModesView)
        
        contentView.addSubview(durationGroup)
        durationGroup.isUserInteractionEnabled = false
        
        view.addSubview(enterBtn)
        view.addSubview(bottomLabel)
        view.addSubview(aboutView)
    }
    
    func initLayout() {
        if LoginConfig.device != .iPad {
            titleBg.agora_x = 0
            titleBg.agora_right = 0
            titleBg.agora_y = 0
        }
        
        iconImgView.agora_center_x = 0
        iconImgView.agora_y = LoginConfig.login_icon_y
        
        aboutBtn.agora_width = 20
        aboutBtn.agora_height = 20
        aboutBtn.agora_y = 46
        aboutBtn.agora_right = 15
        
        contentView.agora_center_x = 0
        contentView.agora_width = LoginConfig.login_group_width
        contentView.agora_height = LoginConfig.login_group_height * 5 + 20 * 4
        contentView.agora_y = LoginConfig.login_first_group_y
        
        roomGroup.agora_center_x = 0
        roomGroup.agora_width = LoginConfig.login_group_width
        roomGroup.agora_height = LoginConfig.login_group_height
        roomGroup.agora_y = 0
        
        userGroup.agora_center_x = 0
        userGroup.agora_width = roomGroup.agora_width
        userGroup.agora_height = roomGroup.agora_height
        userGroup.agora_y = roomGroup.agora_y + roomGroup.agora_height + 20
        
        classTypeGroup.agora_center_x = 0
        classTypeGroup.agora_width = roomGroup.agora_width
        classTypeGroup.agora_height = roomGroup.agora_height
        classTypeGroup.agora_y = userGroup.agora_y + userGroup.agora_height + 20
        
        regionTypeGroup.agora_center_x = 0
        regionTypeGroup.agora_width = roomGroup.agora_width
        regionTypeGroup.agora_height = roomGroup.agora_height
        regionTypeGroup.agora_y = classTypeGroup.agora_y + classTypeGroup.agora_height + 20
        
        durationGroup.agora_center_x = 0
        durationGroup.agora_width = roomGroup.agora_width
        durationGroup.agora_height = roomGroup.agora_height
        durationGroup.agora_y = regionTypeGroup.agora_y + regionTypeGroup.agora_height + 20
        
        encryptionKeyFieldGroup.agora_center_x = 0
        encryptionKeyFieldGroup.agora_width = roomGroup.agora_width
        encryptionKeyFieldGroup.agora_height = roomGroup.agora_height
        encryptionKeyFieldGroup.agora_y = durationGroup.agora_y + durationGroup.agora_height + 20

        encryptionModeGroup.agora_center_x = 0
        encryptionModeGroup.agora_width = roomGroup.agora_width
        encryptionModeGroup.agora_height = roomGroup.agora_height
        encryptionModeGroup.agora_y = encryptionKeyFieldGroup.agora_y + encryptionKeyFieldGroup.agora_height + 20
        
        classTypesView.agora_center_x = 0
        classTypesView.agora_width = LoginConfig.login_class_types_width
        classTypesView.agora_y = contentView.agora_y + classTypeGroup.agora_y + classTypeGroup.agora_height + 1
        classTypesView.agora_height = classTypesView.getTotalHeight()

        regionTypesView.agora_center_x = 0
        regionTypesView.agora_y = contentView.agora_y + regionTypeGroup.agora_y + regionTypeGroup.agora_height + 1
        regionTypesView.agora_width = classTypesView.agora_width
        regionTypesView.agora_height = regionTypesView.getTotalHeight()
        
        encryptionModesView.agora_center_x = 0
        encryptionModesView.agora_y = contentView.agora_y + contentView.agora_height + 1
        encryptionModesView.agora_width = classTypesView.agora_width
        encryptionModesView.agora_height = encryptionModesView.getTotalHeight(count: 3)
        
        let enter_gap: CGFloat = LoginConfig.device == .iPhone_Small ? 30 : 40
        enterBtn.agora_center_x = 0
        enterBtn.agora_height = 44
        enterBtn.agora_width = 280
        enterBtn.agora_y = contentView.agora_y + contentView.agora_height + enter_gap

        bottomLabel.agora_center_x = 0
        
        if LoginConfig.device == .iPad {
            bottomLabel.agora_bottom = LoginConfig.login_bottom_bottom
        } else {
            let height: CGFloat = max(UIScreen.main.bounds.width,
                                      UIScreen.main.bounds.height)

            if enterBtn.agora_y > height - LoginConfig.login_bottom_bottom - 30 - enterBtn.agora_height {
                bottomLabel.agora_y = enterBtn.agora_y + enterBtn.agora_height + 30
            } else {
                bottomLabel.agora_bottom = LoginConfig.login_bottom_bottom
            }
        }
    }
}

// MARK: action
private extension LoginViewController{
    func touchesBegan() {
        classTypesView.isHidden = true
        regionTypesView.isHidden = true
        UIApplication.shared.keyWindow?.endEditing(true)
    }
    
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
            aboutView.transform = CGAffineTransform(translationX: view.frame.width,
                                                    y: 0)
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
    
    @objc func onTouchShowClassTypes() {
        regionTypesView.isHidden = true
        classTypesView.isHidden = false
        encryptionModesView.isHidden = true
        view.bringSubviewToFront(classTypesView)
    }
    
    @objc func onTouchShowRegions() {
        classTypesView.isHidden = true
        regionTypesView.isHidden = false
        encryptionModesView.isHidden = true
        view.bringSubviewToFront(regionTypesView)
    }
    
    @objc func onTouchShowModes() {
        classTypesView.isHidden = true
        regionTypesView.isHidden = true
        encryptionModesView.isHidden = false
        view.bringSubviewToFront(encryptionModesView)
    }
    
    @objc func onTouchJoinRoom() {
        guard let room = roomName,
              let user = userName,
              let type = classType else {
            return
        }
        registerExtApps()
        
        let sel = NSSelectorFromString("setBaseURL:");
        let url = KeyCenter.hostURL()
        AgoraClassroomSDK.perform(sel,
                                  with: url)
        
        // roomUuid = roomName + classType
        let roomUuid = "\(room)\(type.rawValue)"
        
        // userUuid = userName + roleType
        let userUuid = "\(user)\(AgoraEduRoleType.student.rawValue)"
        
        // class time
        let startTime = Int64(NSDate().timeIntervalSince1970 * 1000)
        
        // encrypt
        var mediaOptions: AgoraEduMediaOptions?
        
        if region.contains("CN") {
            let chat = AgoraWidgetConfiguration(with: ChatWidget.self,
                                                widgetId: "HyChatWidget")
            AgoraClassroomSDK.registerWidgets([chat])
        }
        
        if alertView == nil {
            alertView = AgoraUtils.showLoading(message: "")
        } else {
            alertView?.show(in: self.view)
        }
        
        TokenBuilder.serverInfo(region, userUuid: userUuid) { [weak self] (appid, userId, rtmToken) in
            guard let `self` = self else {
                return
            }
            
            if let key = (self.encryptionKeyFieldGroup.viewWithTag(99) as? AgoraBaseUITextField)?.text,
               self.encryptionMode != .none {

                let tfModeValue = self.encryptionMode.rawValue
                if tfModeValue > 0 && tfModeValue <= 6 {
                    let mode = AgoraEduMediaEncryptionMode(rawValue: tfModeValue)
                    let config = AgoraEduMediaEncryptionConfig(mode: mode!,
                                                               key: key)
                    mediaOptions = AgoraEduMediaOptions(config: config)
                }
            }
            
            let sdkConfig = AgoraClassroomSDKConfig(appId: appid)
            AgoraClassroomSDK.setConfig(sdkConfig)
            
            let config = AgoraEduLaunchConfig(userName: user,
                                              userUuid: userUuid,
                                              roleType: .student,
                                              roomName: room,
                                              roomUuid: roomUuid,
                                              roomType: type,
                                              token: rtmToken,
                                              startTime: NSNumber.init(value: startTime),
                                              duration: self.duration,
                                              region: self.region,
                                              mediaOptions: mediaOptions,
                                              userProperties: nil,
                                              videoState: .on,
                                              audioState: .on,
                                              latencyLevel: .ultraLow,
                                              boardFitMode: .retain)
            
            self.classroom = AgoraClassroomSDK.launch(config,
                                                      delegate: self)
        } failure: { [weak self] error in
            guard let `self` = self else {
                return
            }
            
            self.alertView?.removeFromSuperview()
            AgoraUtils.showToast(message: error.localizedDescription)
        }
    }
    
    @objc func onPushDebugVC() {
        navigationController?.pushViewController(DebugViewController(),
                                                 animated: true)
    }
}

// MARK: AgoraEduClassroomDelegate
extension LoginViewController: AgoraEduClassroomDelegate {
    public func classroom(_ classroom: AgoraEduClassroom,
                          didReceivedEvent event: AgoraEduEvent) {
        if alertView != nil {
            alertView?.removeFromSuperview()
        }
        
        switch event {
        case .failed:
            AgoraUtils.showToast(message: "Launch fail")
        case .forbidden:
            AgoraUtils.showToast(message: "Launch fail")
            AgoraUtils.showForbiddenAlert()
        default:
            break
        }
    }
}

// MARK: UITextFieldDelegate
extension LoginViewController: UITextFieldDelegate {
    public func textFieldDidBeginEditing(_ textField: UITextField) {
        classTypesView.isHidden = true
        regionTypesView.isHidden = true
        encryptionModesView.isHidden = true
        guard let field = textField as? AgoraBaseUITextField else {
            return
        }
        
        moveView(move: field.getType().moveDistance)
    }
    
    public func textFieldDidEndEditing(_ textField: UITextField) {
        guard let field = textField as? AgoraBaseUITextField else {
            return
        }
        
        moveView(move: field.getType().moveDistance * -1 )
        
        guard let str = field.text,
              str != "" else {
            switch field.getType() {
            case .room:
                roomName = nil
            case .user:
                userName = nil
            default:
                return
            }
            return
        }
        let legal = checkInputLegality(text: str)
        
        handleWithTextfield(field: field,
                            ifLegal: legal)
        
        guard legal else{
            return
        }
        
        switch field.getType() {
        case .room:
            roomName = str
        case .user:
            userName = str
        default:
            return
        }
    }
    
    public func textField(_ textField: UITextField,
                          shouldChangeCharactersIn range: NSRange,
                          replacementString string: String) -> Bool {
        guard let field = textField as? AgoraBaseUITextField,
              field.id != FIELD_TYPE.encryptKey.rawValue,
              field.id != FIELD_TYPE.encryptMode.rawValue else {
            return true
        }
         
        // delete
        if (string == "" || string == "\n") {
            // 若为删除操作，获取到删除后的字符串，进行合法性判断
            guard let str = field.text else {
                return true
            }
            // 判断删除位置 获取删除后字符串
            let strAfterDelete = str.getSubString(nsRange: range)
            let newLegality = checkInputLegality(text: String(strAfterDelete ?? ""))
            handleWithTextfield(field: field, ifLegal: newLegality)
            return true
        }
        
        // add
        let oriLegality = checkInputLegality(text: field.text ?? "")
        let newCharLegality = checkInputLegality(text: string)
        
        // length check & handle
        guard let str = field.text,
              str.count <= field.getLengthLimit() else {
            field.text = String(field.text!.prefix(field.getLengthLimit()))
            return false
        }
        
        guard string.count != 1 else {
            handleWithTextfield(field: field,
                                ifLegal: oriLegality && newCharLegality)
            return true
        }
        
        // legality check & handle
        if let markedRange = field.markedTextRange,
           let wholeRange = field.textRange(from: field.beginningOfDocument,
                                            to: field.endOfDocument) {
            // 输入法联想
            if wholeRange.start == markedRange.start,
               wholeRange.end == markedRange.end {
                handleWithTextfield(field: field,
                                    ifLegal: newCharLegality)
            } else {
                handleWithTextfield(field: field,
                                    ifLegal: oriLegality)
            }
        }
        return true
    }
}

fileprivate extension AgoraBaseUITextField {
    func getType() -> FIELD_TYPE {
        return FIELD_TYPE(rawValue: self.id) ?? .default
    }
    
    func getLengthLimit() -> Int  {
        return 20
    }
}

fileprivate extension String {
    /// NSRange转化为range
    func getSubString(nsRange: NSRange) -> String? {
        var strRange: Range<String.Index>
        
        guard let from16 = utf16.index(utf16.startIndex,
                                       offsetBy: nsRange.location,
                                       limitedBy: utf16.endIndex),
            let to16 = utf16.index(from16,
                                   offsetBy: nsRange.length,
                                   limitedBy: utf16.endIndex),
            let from = String.Index(from16,
                                    within: self),
            let to = String.Index(to16,
                                  within: self) else {
            return nil
        }
        
        strRange = from ..< to
        var newStr = String(self)
        newStr.removeSubrange(strRange)
        return newStr
    }
}
