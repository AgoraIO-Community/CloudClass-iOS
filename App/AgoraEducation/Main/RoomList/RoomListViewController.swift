//
//  RoomListViewController.swift
//  AgoraEducation
//
//  Created by Jonathan on 2022/9/2.
//  Copyright © 2022 Agora. All rights reserved.
//

import UIKit
#if canImport(AgoraClassroomSDK_iOS)
import AgoraClassroomSDK_iOS
#else
import AgoraClassroomSDK
#endif
import AgoraUIBaseViews
import AgoraProctorSDK

class RoomListViewController: UIViewController {
    
    private let kSectionTitle = 0
    private let kSectionNotice = 1
    private let kSectionRooms = 2
    private let kSectionEmpty = 3
    
    let backGroundView = UIImageView(image: UIImage(named: "fcr_room_list_bg"))
    
    let tableView = UITableView(frame: .zero, style: .plain)
    
    let titleView = RoomListTitleView(frame: .zero)
    
    let settingButton = UIButton(type: .custom)
    
    var dataSource = [RoomItemModel]()
    
    private let kTitleMax: CGFloat = 198
    
    private let kTitleMin: CGFloat = 110
    
    private var noticeShow = false
    
    /**sdk**/
    private var proctorSDK: AgoraProctorSDK?

    override func viewDidLoad() {
        super.viewDidLoad()
        
        setup()
        createViews()
        createConstrains()
    }
    
    public override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        navigationController?.setNavigationBarHidden(true,
                                                     animated: true)
    }
    
    public override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        guard FcrUserInfoPresenter.shared.qaMode == false else {
            let debugVC = DebugViewController()
            debugVC.modalPresentationStyle = .fullScreen
            self.present(debugVC,
                         animated: true,
                         completion: nil)
            return
        }
        // 检查协议，检查登录
        FcrPrivacyTermsViewController.checkPrivacyTerms {
            LoginWebViewController.showLoginIfNot(complete: nil)
        }
        fetchData()
    }
    
    @objc func onClickSetting(_ sender: UIButton) {
        let vc = FcrSettingsViewController()
        self.navigationController?.pushViewController(vc, animated: true)
    }
    
    public override var shouldAutorotate: Bool {
        return true
    }
    
    public override var preferredInterfaceOrientationForPresentation: UIInterfaceOrientation {
        return UIDevice.current.agora_is_pad ? .landscapeRight : .portrait
    }

    public override var supportedInterfaceOrientations: UIInterfaceOrientationMask {
        return UIDevice.current.agora_is_pad ? .landscapeRight : .portrait
    }
    
}
// MARK: - Private
private extension RoomListViewController {
    func setup() {
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
    }
    
    func fetchData() {
        FcrOutsideClassAPI.fetchRoomList(nextId: nil,
                                         count: 10) { dict in
            guard let data = dict["data"] as? [String: Any],
                  let list = data["list"] as? [Dictionary<String, Any>]
            else {
                return
            }
            self.dataSource = RoomItemModel.arrayWithDataList(list)
            self.tableView.reloadData()
        } onFailure: { str in
            AgoraToast.toast(message: str,
                             type: .warning)
        }
    }
    // 课程业务信息组装
    func fillupInputModel(_ model: RoomInputInfoModel) {
        RoomListJoinAlertController.show(in: self,
                                         inputModel: model) { model in
            self.fillupClassInfo(model: model) { model in
                self.fillupTokenInfo(model: model) { model in
                    if model.roomType == 6 {
                        self.startLaunchProctorRoom(witn: model)
                    } else {
                        self.startLaunchClassRoom(witn: model)
                    }
                }
            }
        }
    }
    
    func fillupClassInfo(model: RoomInputInfoModel,
                         complete: @escaping (RoomInputInfoModel) -> Void) {
        guard let roomId = model.roomId else {
            return
        }
        AgoraLoading.loading()
        FcrOutsideClassAPI.fetchRoomDetail(roomUuid: roomId) { rsp in
            AgoraLoading.hide()
            guard let data = rsp["data"] as? [String: Any],
                  let item = RoomItemModel.modelWith(dict: data)
            else {
                return
            }
            let now = Date()
            let endDate = Date(timeIntervalSince1970: Double(item.endTime) * 0.001)
            model.roomType = Int(item.roomType)
            model.roomName = item.roomName
            if let roomProperties = item.roomProperties,
               let service = roomProperties["serviceType"] as? Int,
               let serviceType = AgoraEduServiceType(rawValue: service) {
                model.serviceType = serviceType
            }
            if now.compare(endDate) == .orderedDescending { // 课程过期
                self.fetchData()
            } else {
                complete(model)
            }
        } onFailure: { str in
            AgoraLoading.hide()
            AgoraToast.toast(message: str,
                             type: .warning)
        }
    }
    
    func fillupTokenInfo(model: RoomInputInfoModel,
                         complete: @escaping (RoomInputInfoModel) -> Void) {
        guard let roomUuid = model.roomUuid,
              let userUuid = model.userUuid
        else {
            return
        }
        AgoraLoading.loading()
        var finalUserId = userUuid
        if model.roomType == 6 {
            finalUserId = "\(userUuid)-sub"
        }
        FcrOutsideClassAPI.buildToken(roomUuid: roomUuid,
                                      userRole: model.roleType,
                                      userId: finalUserId) { dict in
            AgoraLoading.hide()
            guard let data = dict["data"] as? [String : Any] else {
                fatalError("TokenBuilder buildByServer can not find data, dict: \(dict)")
            }
            guard let token = data["token"] as? String,
                  let appId = data["appId"] as? String
            else {
                fatalError("TokenBuilder buildByServer can not find value, dict: \(dict)")
            }
            model.token = token
            model.appId = appId
            complete(model)
        } onFailure: { str in
            AgoraLoading.hide()
            AgoraToast.toast(message: str,
                             type: .warning)
        }
    }
    // 组装Launch参数并拉起教室
    func startLaunchClassRoom(witn model: RoomInputInfoModel) {
        guard let userName = model.userName,
              let userUuid = model.userUuid,
              let roomName = model.roomName,
              let roomUuid = model.roomUuid,
              let appId = model.appId,
              let token = model.token
        else {
            return
        }
        let role = model.roleType
        let roomType = model.roomType
        let region = getLaunchRegion()
        var latencyLevel = AgoraEduLatencyLevel.ultraLow
        if model.serviceType == .livePremium {
            latencyLevel = .ultraLow
        } else if model.serviceType == .liveStandard {
            latencyLevel = .low
        }
        let mediaOptions = AgoraEduMediaOptions(encryptionConfig: nil,
                                                videoEncoderConfig: nil,
                                                latencyLevel: latencyLevel,
                                                videoState: .on,
                                                audioState: .on)
        let launchConfig = AgoraEduLaunchConfig(userName: userName,
                                                userUuid: userUuid,
                                                userRole: AgoraEduUserRole(rawValue: role) ?? .student,
                                                roomName: roomName,
                                                roomUuid: roomUuid,
                                                roomType: AgoraEduRoomType(rawValue: roomType) ?? .oneToOne,
                                                appId: appId,
                                                token: token,
                                                startTime: nil,
                                                duration: NSNumber(value: 60 * 30),
                                                region: region,
                                                mediaOptions: mediaOptions,
                                                userProperties: nil)
        // MARK: 若对widgets需要添加或修改时，可获取launchConfig中默认配置的widgets进行操作并重新赋值给launchConfig
        var widgets = Dictionary<String,AgoraWidgetConfig>()
        launchConfig.widgets.forEach { (k,v) in
            if k == "AgoraCloudWidget" {
                v.extraInfo = ["publicCoursewares": model.publicCoursewares()]
            }
            if k == "netlessBoard",
               v.extraInfo != nil {
                var newExtra = v.extraInfo as! Dictionary<String, Any>
                newExtra["coursewareList"] = model.publicCoursewares()
                v.extraInfo = newExtra
            }
            widgets[k] = v
        }
        launchConfig.widgets = widgets
        
        if region != .CN {
            launchConfig.widgets.removeValue(forKey: "easemobIM")
        }
        
        if let service = model.serviceType { // 职教入口
            AgoraLoading.loading()
            AgoraClassroomSDK.vocationalLaunch(launchConfig,
                                               service: service) {
                AgoraLoading.hide()
            } failure: { error in
                AgoraLoading.hide()
                AgoraToast.toast(message: error.localizedDescription,
                                 type: .error)
            }
        } else { // 灵动课堂入口
            AgoraLoading.loading()
            AgoraClassroomSDK.launch(launchConfig) {
                AgoraLoading.hide()
            } failure: { error in
                AgoraLoading.hide()
                AgoraToast.toast(message: error.localizedDescription,
                                 type: .error)
            }
        }
    }
    
    // 组装Launch参数并拉起监考房间
    func startLaunchProctorRoom(witn model: RoomInputInfoModel) {
        guard let userName = model.userName,
              let userUuid = model.userUuid,
              let roomName = model.roomName,
              let roomUuid = model.roomUuid,
              let appId = model.appId,
              let token = model.token
        else {
            return
        }
        var latencyLevel = AgoraProctorLatencyLevel.ultraLow
        if model.serviceType == .livePremium {
            latencyLevel = .ultraLow
        } else if model.serviceType == .liveStandard {
            latencyLevel = .low
        }
        let mediaOptions = AgoraProctorMediaOptions(encryptionConfig: nil,
                                                videoEncoderConfig: nil,
                                                latencyLevel: latencyLevel,
                                                videoState: .on,
                                                audioState: .on)
        let launchConfig = AgoraProctorLaunchConfig(userName: userName,
                                                    userUuid: userUuid,
                                                    userRole: .student,
                                                    roomName: roomName,
                                                    roomUuid: roomUuid,
                                                    deviceType: .sub,
                                                    appId: appId,
                                                    token: token,
                                                    region: FcrEnvironment.shared.region.proctor,
                                                    mediaOptions: mediaOptions,
                                                    userProperties: nil)
        
        let proSDK = AgoraProctorSDK(launchConfig,
                                     delegate: self)
        self.proctorSDK = proSDK
        
        let sel = NSSelectorFromString("setEnvironment:")
        switch FcrEnvironment.shared.environment {
        case .pro:
            proSDK.perform(sel,
                           with: 2)
        case .pre:
            proSDK.perform(sel,
                           with: 1)
        case .dev:
            proSDK.perform(sel,
                           with: 0)
        }
        
        proSDK.launch {
            AgoraLoading.hide()
        } failure: { [weak self] (error) in
            AgoraLoading.hide()
            
            self?.proctorSDK = nil
            
            let `error` = error as NSError
            
            if error.code == 30403100 {
                AgoraToast.toast(message: "login_kicked".ag_localized(),
                                 type: .error)
            } else {
                AgoraToast.toast(message: error.localizedDescription,
                                 type: .error)
            }
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
}
// MARK: - RoomListItemCell Call Back
extension RoomListViewController: RoomListItemCellDelegate {
    func onClickShare(at indexPath: IndexPath) {
        let item = dataSource[indexPath.row]
        RoomListShareAlertController.show(in: self,
                                          roomId: item.roomId,
                                          complete: nil)
    }
    
    func onClickEnter(at indexPath: IndexPath) {
        let item = dataSource[indexPath.row]
        let inputModel = RoomInputInfoModel()
        inputModel.roomId = item.roomId
        inputModel.roomName = item.roomName
        fillupInputModel(inputModel)
    }
    
    func onClickCopy(at indexPath: IndexPath) {
        let item = dataSource[indexPath.row]
        UIPasteboard.general.string = item.roomId
        AgoraToast.toast(message: "fcr_sharelink_tips_roomid".ag_localized(),
                         type: .notice)
    }
}
// MARK: - Table View Call Back
extension RoomListViewController: UITableViewDelegate, UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int {
        return 4
    }
    
    func tableView(_ tableView: UITableView,
                   numberOfRowsInSection section: Int) -> Int {
        if section == kSectionTitle {
            return 1
        } else if section == kSectionNotice {
            return noticeShow ? 1 : 0
        } else if section == kSectionRooms {
            return dataSource.count
        } else if section == kSectionEmpty {
            return dataSource.count > 0 ? 0 : 1
        } else {
            return 0
        }
    }
    
    func tableView(_ tableView: UITableView,
                   cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if indexPath.section == kSectionTitle {
            let cell = tableView.dequeueReusableCell(withClass: RoomListTitleCell.self)
            return cell
        } else if indexPath.section == kSectionNotice {
            let cell = tableView.dequeueReusableCell(withClass: RoomListNotiCell.self)
            return cell
        } else if indexPath.section == kSectionRooms {
            let cell = tableView.dequeueReusableCell(withClass: RoomListItemCell.self)
            cell.delegate = self
            cell.indexPath = indexPath
            cell.model = dataSource[indexPath.row]
            return cell
        } else if indexPath.section == kSectionEmpty {
            let cell = tableView.dequeueReusableCell(withClass: RoomListEmptyCell.self)
            return cell
        } else {
            let cell = tableView.dequeueReusableCell(withClass: RoomListEmptyCell.self)
            return cell
        }
    }
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        var height = kTitleMax - scrollView.contentOffset.y
        height = height < kTitleMin ? kTitleMin : height
        titleView.setSoildPercent(scrollView.contentOffset.y/(kTitleMax - kTitleMin))
        titleView.mas_updateConstraints { make in
            make?.height.equalTo()(height)
        }
    }
    
    func tableView(_ tableView: UITableView,
                   heightForRowAt indexPath: IndexPath) -> CGFloat {
        if indexPath.section == kSectionTitle {
            return 66
        } else if indexPath.section == kSectionNotice {
            return 74
        } else if indexPath.section == kSectionRooms {
            return 152
        } else if indexPath.section == kSectionEmpty {
            return 500
        } else {
            return 0
        }
    }
    
}
// MARK: - RoomListTitleViewDelegate
extension RoomListViewController: RoomListTitleViewDelegate {
    
    func onClickJoin() {
        let inputModel = RoomInputInfoModel()
        fillupInputModel(inputModel)
    }
    
    func onClickCreate() {
        RoomCreateViewController.showCreateRoom {
            self.noticeShow = true
            self.tableView.reloadData()
            DispatchQueue.main.asyncAfter(deadline: .now() + 2.5) {
                self.noticeShow = false
                self.tableView.reloadData()
            }
        }
    }
}
// MARK: - Creations
private extension RoomListViewController {
    
    func createViews() {
        view.addSubview(backGroundView)
        
        tableView.delegate = self
        tableView.dataSource = self
        tableView.allowsSelection = false
        tableView.backgroundColor = .clear
        tableView.separatorStyle = .none
        tableView.register(cellWithClass: RoomListTitleCell.self)
        tableView.register(cellWithClass: RoomListNotiCell.self)
        tableView.register(cellWithClass: RoomListItemCell.self)
        tableView.register(cellWithClass: RoomListEmptyCell.self)
        let headerFrame = CGRect(x: 0,
                                 y: 0,
                                 width: 200,
                                 height: kTitleMax)
        let headerView = UIView(frame: headerFrame)
        tableView.tableHeaderView = headerView
        tableView.rowHeight = 152
        view.addSubview(tableView)
        
        titleView.delegate = self
        titleView.clipsToBounds = true
        view.addSubview(titleView)
        
        settingButton.setImage(UIImage(named: "fcr_room_list_setting"),
                               for: .normal)
        settingButton.addTarget(self,
                                action: #selector(onClickSetting(_:)),
                                for: .touchUpInside)
        view.addSubview(settingButton)
    }
    
    func createConstrains() {
        backGroundView.mas_makeConstraints { make in
            make?.left.top().right().equalTo()(0)
        }
        tableView.mas_makeConstraints { make in
            make?.left.right().top().bottom().equalTo()(0)
        }
        titleView.mas_makeConstraints { make in
            make?.left.top().right().equalTo()(0)
            make?.height.equalTo()(kTitleMax)
        }
        settingButton.mas_makeConstraints { make in
            make?.top.equalTo()(68)
            make?.right.equalTo()(-14)
        }
    }
}

// MARK: - SDK delegate
extension RoomListViewController: AgoraProctorSDKDelegate {
    func proctorSDK(_ classroom: AgoraProctorSDK,
                    didExit reason: AgoraProctorExitReason) {
        switch reason {
        case .kickOut:
            AgoraToast.toast(message: "kick out")
        default:
            break
        }
        
        self.proctorSDK = nil
    }
}
