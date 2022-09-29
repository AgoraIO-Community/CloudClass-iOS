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
    /**views**/
    private let kSectionTitle = 0
    private let kSectionNotice = 1
    private let kSectionRooms = 2
    private let kSectionEmpty = 3
    
    let backGroundView = UIImageView(image: UIImage(named: "fcr_room_list_bg"))
    
    let tableView = UITableView(frame: .zero, style: .plain)
    
    let titleView = RoomListTitleView(frame: .zero)
    /**data**/
    var dataSource = [RoomItemModel]()
    
    private let kTitleMax: CGFloat = 198
    
    private let kTitleMin: CGFloat = 110
    
    private var noticeShow = false

    private lazy var refreshAction = UIRefreshControl() // 下拉刷新
    private var roomNextId: String?
    private var isRefreshing = false // 下拉刷新
    
    private var isLoading = false // 上拉加载

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
            LoginStartViewController.showLoginIfNot {
                self.fetchData()
            }
        }
    }
    
    override func observeValue(forKeyPath keyPath: String?,
                               of object: Any?,
                               change: [NSKeyValueChangeKey : Any]?,
                               context: UnsafeMutableRawPointer?) {
        let offset = tableView.contentSize.height - tableView.frame.size.height + 150

        guard offset > 0,
              let changeNew = change?[.newKey] as? CGPoint,
              let changeOld = change?[.oldKey] as? CGPoint,
              changeOld != changeNew,
              keyPath == "contentOffset",
              tableView.contentOffset.y > offset else {
            return
        }

        onPullLoadUp()
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
    
    func fetchData(nextId: String? = nil,
                   onComplete: (() -> Void)? = nil) {
        FcrOutsideClassAPI.fetchRoomList(nextId: nextId,
                                         count: 10) { [weak self] dict in
            guard let `self` = self,
                  let data = dict["data"] as? [String: Any],
                  let list = data["list"] as? [Dictionary<String, Any>]
            else {
                return
            }
            
            if let nextIdFromData = data["nextId"] as? String {
                self.roomNextId = nextIdFromData
            }
            
            if let _ = nextId {
                self.dataSource = self.dataSource + RoomItemModel.arrayWithDataList(list)
            } else {
                self.dataSource = RoomItemModel.arrayWithDataList(list)
            }
            
            self.tableView.reloadData()
            onComplete?()
        } onFailure: { code, msg in
            onComplete?()
            AgoraToast.toast(message: msg,
                             type: .warning)
        }
    }
    // 课程业务信息组装
    func fillupInputModel(_ model: RoomInputInfoModel) {
        RoomListJoinAlertController.show(in: self,
                                         inputModel: model) { model in
            self.fillupClassInfo(model: model) { model in
                if model.roomType == 6 {
                    self.startLaunchProctorRoom(with: model)
                } else {
                    self.startLaunchClassRoom(with: model)
                }
            }
        }
    }
    
    func fillupClassInfo(model: RoomInputInfoModel,
                         complete: @escaping (RoomInputInfoModel) -> Void) {
        guard let roomId = model.roomId else {
            return
        }
        
        let userId = FcrUserInfoPresenter.shared.companyId
        var cid = userId
        
        if model.roomType == 6 {
            cid = "\(cid)-sub"
        }
        AgoraLoading.loading()
        FcrOutsideClassAPI.fetchRoomDetail(roomId: roomId,
                                           companyId: cid,
                                           userId: userId,
                                           role: model.roleType) { [weak self] rsp in
            AgoraLoading.hide()
            guard let data = rsp["data"] as? [String: Any],
                  let token = data["token"] as? String,
                  let appId = data["appId"] as? String,
                  let roomDetail = data["roomDetail"] as? [String: Any],
                  let item = RoomItemModel.modelWith(dict: roomDetail)
            else {
                return
            }
            let now = Date()
            let endDate = Date(timeIntervalSince1970: Double(item.endTime) * 0.001)
            model.roomType = Int(item.roomType)
            model.roomName = item.roomName
            model.token = token
            model.appId = appId
            if let roomProperties = item.roomProperties,
               let service = roomProperties["serviceType"] as? Int,
               let serviceType = AgoraEduServiceType(rawValue: service) {
                model.serviceType = serviceType
            }
            if now.compare(endDate) == .orderedDescending { // 课程过期
                self?.fetchData()
            } else {
                complete(model)
            }
        } onFailure: { code, msg in
            AgoraLoading.hide()
            let str = (code == 404) ? "fcr_joinroom_tips_emptyid".ag_localized() : msg
            AgoraToast.toast(message: str,
                             type: .warning)
        }
    }
    // 组装Launch参数并拉起教室
    func startLaunchClassRoom(with model: RoomInputInfoModel) {
        guard let userName = model.userName,
              let roomName = model.roomName,
              let roomUuid = model.roomId,
              let appId = model.appId,
              let token = model.token
        else {
            return
        }
        let role = model.roleType
        let region = getLaunchRegion()
        var latencyLevel = AgoraEduLatencyLevel.ultraLow
        if model.serviceType == .livePremium {
            latencyLevel = .ultraLow
            model.serviceType = nil
        } else if model.serviceType == .liveStandard {
            latencyLevel = .low
            model.serviceType = nil
        }
        var roomType: AgoraEduRoomType
        switch model.roomType {
        case 0:   roomType = .oneToOne
        case 2:   roomType = .lecture
        case 4:   roomType = .small
        default:  roomType = .small
        }
        let mediaOptions = AgoraEduMediaOptions(encryptionConfig: nil,
                                                videoEncoderConfig: nil,
                                                latencyLevel: latencyLevel,
                                                videoState: .on,
                                                audioState: .on)
        let launchConfig = AgoraEduLaunchConfig(userName: userName,
                                                userUuid: FcrUserInfoPresenter.shared.companyId,
                                                userRole: AgoraEduUserRole(rawValue: role) ?? .student,
                                                roomName: roomName,
                                                roomUuid: roomUuid,
                                                roomType: roomType,
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
    func startLaunchProctorRoom(with model: RoomInputInfoModel) {
        guard let userName = model.userName,
              let roomName = model.roomName,
              let roomUuid = model.roomId,
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
                                                    userUuid: FcrUserInfoPresenter.shared.companyId,
                                                    userRole: .student,
                                                    roomName: roomName,
                                                    roomUuid: roomUuid,
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
    
    // MARK: actions
    @objc func onPullRefreshDown() {
        guard !isRefreshing else {
            return
        }
        isRefreshing = true
        
        fetchData { [weak self] in
            self?.isRefreshing = false
            self?.refreshAction.endRefreshing()
        }
    }
    
    @objc func onPullLoadUp() {
        guard !isLoading else {
            return
        }
        isLoading = true
        
        fetchData(nextId: roomNextId) { [weak self] in
            self?.isLoading = false
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
    func onEnterDebugMode() {
        FcrUserInfoPresenter.shared.qaMode = true
        let debugVC = DebugViewController()
        debugVC.modalPresentationStyle = .fullScreen
        self.present(debugVC,
                     animated: true,
                     completion: nil)
    }
    
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
    
    func onClickSetting() {
        let vc = FcrSettingsViewController()
        self.navigationController?.pushViewController(vc,
                                                      animated: true)
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
        // 下拉刷新
        refreshAction.addTarget(self,
                                action: #selector(onPullRefreshDown),
                                for: .valueChanged)
        tableView.addSubview(refreshAction)
        // 下拉加载
        tableView.addObserver(self,
                              forKeyPath: "contentOffset",
                              options: [.new,
                                        .old],
                              context: nil)
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
