//
//  PaintingNameRollViewController.swift
//  AgoraEduUI
//
//  Created by Jonathan on 2021/10/9.
//

import AgoraEduContext
import SwifterSwift
import AgoraWidget
import UIKit

enum AgoraUserListFunction: Int {
    case stage = 0, auth, camera, mic, reward, kick
    
    func title() -> String {
        switch self {
        case .stage:
            return "UserListCoVideo".agedu_localized()
        case .auth:
            return "UserListBoard".agedu_localized()
        case .camera:
            return "UserListCamera".agedu_localized()
        case .mic:
            return "UserListMicro".agedu_localized()
        case .reward:
            return "UserListReward".agedu_localized()
        case .kick:
            return "nameroll_kick_out".agedu_localized()
        default: return ""
        }
    }
}

extension AgoraUserListModel {
    func updateWithStream(_ stream: AgoraEduContextStreamInfo?) {
        if let `stream` = stream {
            self.streamId = stream.streamUuid
            // audio
            self.micState.streamOn = stream.streamType.hasAudio
            self.micState.deviceOn = (stream.audioSourceState == .open)
            // video
            self.cameraState.streamOn = stream.streamType.hasVideo
            self.cameraState.deviceOn = (stream.videoSourceState == .open)
            
        } else {
            self.micState.streamOn = false
            self.micState.deviceOn = false
            self.cameraState.streamOn = false
            self.cameraState.deviceOn = false
        }
    }
}

class AgoraUserListUIController: UIViewController {
    
    public var suggestSize: CGSize {
        get {
            // 学生姓名为100，其余为60
            let contentWidth = 60 * (supportFuncs.count - 1) + 100
            return CGSize(width: contentWidth, height: 260)
        }
    }
    /** 容器*/
    private var contentView: UIView!
    /** 页面title*/
    private var titleLabel: UILabel!
    /** 教师信息*/
    private var infoView: UIView!
    /** 分割线*/
    private var topSepLine: UIView!
    private var bottomSepLine: UIView!
    /** 教师姓名 标签*/
    private var teacherTitleLabel: UILabel!
    /** 教师姓名 姓名*/
    private var teacherNameLabel: UILabel!
    /** 学生姓名*/
    private var studentTitleLabel: UILabel!
    /** 列表项*/
    private var itemTitlesView: UIStackView!
    /** 轮播 仅教师端*/
    private lazy var carouselTitle: UILabel = {
        let carouselTitle = UILabel(frame: .zero)
        carouselTitle.text = "UserListCarouselTitle".agedu_localized()
        carouselTitle.font = UIFont.systemFont(ofSize: 12)
        carouselTitle.textColor = UIColor(hex: 0x7B88A0)
        return carouselTitle
    }()
    private lazy var carouselSwitch: UISwitch = {
        let carouselSwitch = UISwitch()
        carouselSwitch.onTintColor = UIColor(hex: 0x357BF6)
        carouselSwitch.transform = CGAffineTransform(scaleX: 0.75,
                                                     y: 0.75)
        carouselSwitch.isOn = contextPool.user.getCoHostCarouselInfo().state
        carouselSwitch.addTarget(self,
                                 action: #selector(onClickCarouselSwitch(_:)),
                                 for: .touchUpInside)
        return carouselSwitch
    }()
    /** 表视图*/
    private var tableView: UITableView!
    /** 数据源*/
    private var dataSource = [AgoraUserListModel]()
    /** 支持的选项列表*/
    lazy var supportFuncs: [AgoraUserListFunction] = {
        let isLecture = contextPool.room.getRoomInfo().roomType == .lecture
        let isTeacher = contextPool.user.getLocalUserInfo().userRole == .teacher
        if isLecture {
            // 大班课老师（大班课学生端没有花名册）
            return [.camera, .mic, .kick]
        } else if isTeacher {
            // 小班课老师
            return [.stage, .auth, .camera, .mic, .reward, .kick]
        } else {
            // 小班课学生
            return [.stage, .auth, .camera, .mic, .reward]
        }
    }()
    
    private var boardUsers = [String]()
    
    private var isViewShow: Bool = false
    /** SDK环境*/
    private var contextPool: AgoraEduContextPool!
    
    deinit {
        print("\(#function): \(self.classForCoder)")
    }
    
    init(context: AgoraEduContextPool) {
        super.init(nibName: nil, bundle: nil)
        contextPool = context
        contextPool.widget.add(self,
                               widgetId: kBoardWidgetId)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        createViews()
        createConstraint()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        isViewShow = true
        let roomType = contextPool.room.getRoomInfo().roomType
        if roomType == .small {
            setUpSmallData()
        } else if roomType == .lecture {
            setUpLectureData()
        }

        // add event handler
        contextPool.user.registerUserEventHandler(self)
        contextPool.stream.registerStreamEventHandler(self)
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        
        isViewShow = false
        // remove event handler
        contextPool.user.unregisterUserEventHandler(self)
        contextPool.stream.unregisterStreamEventHandler(self)
    }
}
// MARK: - Private
private extension AgoraUserListUIController {
    func setUpTeacherData() {
        if let teacher = contextPool.user.getUserList(role: .teacher)?.first {
            teacherNameLabel.text = teacher.userName
        } else {
            teacherNameLabel.text = nil
        }
    }
    
    func setUpSmallData() {
        setUpTeacherData()
        
        let isTeacher = contextPool.user.getLocalUserInfo().userRole == .teacher
        let localUserID = contextPool.user.getLocalUserInfo().userUuid

        guard let students = contextPool.user.getUserList(role: .student) else {
            return
        }
        var tmp = [AgoraUserListModel]()
        let coHosts = contextPool.user.getCoHostList()
        for student in students {
            let model = AgoraUserListModel(contextUser: student)
            model.rewards = contextPool.user.getUserRewardCount(userUuid: student.userUuid)
            var isCoHost = false
            if let _ = coHosts?.first(where: {$0.userUuid == student.userUuid}) {
                isCoHost = true
            }
            model.stageState.isOn = isCoHost
            // 白板权限
            model.authState.isOn = self.boardUsers.contains(model.uuid)
            // enable
            model.stageState.isEnable = isTeacher
            model.authState.isEnable = isTeacher
            
            // TODO: 除了isTeacher 之外 判断设备状态
            model.micState.isEnable = isTeacher
            model.cameraState.isEnable = isTeacher
            // stream
            let s = contextPool.stream.getStreamList(userUuid: student.userUuid)?.first
            model.updateWithStream(s)
            tmp.append(model)
        }
        dataSource = tmp
        sort()
    }
    
    func setUpLectureData() {
        setUpTeacherData()
        
        contextPool.user.getUserList(roleList: [AgoraEduContextUserRole.student.rawValue],
                                     pageIndex: 1,
                                     pageSize: 20) {[weak self] list in
            guard let `self` = self else {
                return
            }
            
            for user in list {
                if !self.dataSource.contains{ $0.uuid == user.userUuid } {
                    let model = AgoraUserListModel(contextUser: user)
                    self.dataSource.append(model)
                }
                self.updateModel(with: user.userUuid,
                                 resort: true)
            }
        } failure: { error in
            print(error)
        }
    }
    // 针对某个模型进行更新
    func updateModel(with uuid: String,
                     resort: Bool) {
        guard let model = dataSource.first(where: {$0.uuid == uuid}) else {
            return
        }
        let isTeacher = contextPool.user.getLocalUserInfo().userRole == .teacher
        let coHosts = contextPool.user.getCoHostList()
        let localUserID = contextPool.user.getLocalUserInfo().userUuid
        var isCoHost = false
        if let _ = coHosts?.first(where: {$0.userUuid == model.uuid}) {
            isCoHost = true
        }
        model.stageState.isOn = isCoHost

        model.authState.isOn = boardUsers.contains(model.uuid)
        // enable
        model.stageState.isEnable = isTeacher
        model.authState.isEnable = isTeacher
        model.rewardEnable = isTeacher
        model.kickEnable = isTeacher
        // stream
        let s = contextPool.stream.getStreamList(userUuid: model.uuid)?.first
        model.updateWithStream(s)
        if resort {
            sort()
        } else {
            tableView.reloadData()
        }
    }
    
    func sort() {
        self.dataSource.sort {$0.sortRank < $1.sortRank}
        var coHosts = [AgoraUserListModel]()
        var rest = [AgoraUserListModel]()
        for user in self.dataSource {
            if user.stageState.isOn {
                coHosts.append(user)
            } else {
                rest.append(user)
            }
        }
        coHosts.append(contentsOf: rest)
        self.dataSource = coHosts
        self.tableView.reloadData()
    }
    
    func reloadTableView() {
        DispatchQueue.main.async {
            self.tableView.reloadData()
        }
    }
}
// MARK: - AgoraWidgetMessageObserver
extension AgoraUserListUIController: AgoraWidgetMessageObserver {
    func onMessageReceived(_ message: String,
                           widgetId: String) {
        guard widgetId == kBoardWidgetId,
              let signal = message.toBoardSignal() else {
            return
        }
        switch signal {
        case .BoardGrantDataChanged(let list):
            if let userIDs = list {
                self.boardUsers = userIDs
                guard isViewShow else {
                    return
                }
                for model in dataSource {
                    model.authState.isOn = userIDs.contains(model.uuid)
                }
                tableView.reloadData()
            }
        default:
            break
        }
    }
}

// MARK: - AgoraEduUserHandler
extension AgoraUserListUIController: AgoraEduUserHandler {
    func onRemoteUserJoined(user: AgoraEduContextUserInfo) {
        if user.userRole == .student {
            dataSource.append(AgoraUserListModel(contextUser: user))
            sort()
        } else if user.userRole == .teacher {
            self.teacherNameLabel.text = user.userName
        }
    }
        
    func onRemoteUserLeft(user: AgoraEduContextUserInfo,
                          operatorUser: AgoraEduContextUserInfo?,
                          reason: AgoraEduContextUserLeaveReason) {
        if user.userRole == .student {
            self.dataSource.removeAll(where: {$0.uuid == user.userUuid})
            tableView.reloadData()
        } else if user.userRole == .teacher {
            self.teacherNameLabel.text = ""
        }
    }
    
    func onCoHostUserListAdded(userList: [AgoraEduContextUserInfo],
                               operatorUser: AgoraEduContextUserInfo?) {
        for user in userList {
            self.updateModel(with: user.userUuid,
                             resort: true)
        }
    }
    
    func onCoHostUserListRemoved(userList: [AgoraEduContextUserInfo],
                                 operatorUser: AgoraEduContextUserInfo?) {
        for user in userList {
            self.updateModel(with: user.userUuid,
                             resort: false)
        }
    }
    
    func onUserRewarded(user: AgoraEduContextUserInfo,
                        rewardCount: Int,
                        operatorUser: AgoraEduContextUserInfo?) {
        if let model = dataSource.first(where: {$0.uuid == user.userUuid}) {
            model.rewards = rewardCount
            tableView.reloadData()
        }
    }
}

// MARK: - AgoraEduStreamHandler
extension AgoraUserListUIController: AgoraEduStreamHandler {
    func onStreamJoined(stream: AgoraEduContextStreamInfo,
                        operatorUser: AgoraEduContextUserInfo?) {
        self.updateModel(with: stream.owner.userUuid,
                         resort: false)
    }
    
    func onStreamUpdated(stream: AgoraEduContextStreamInfo,
                         operatorUser: AgoraEduContextUserInfo?) {
        self.updateModel(with: stream.owner.userUuid,
                         resort: false)
    }
    
    func onStreamLeft(stream: AgoraEduContextStreamInfo,
                      operatorUser: AgoraEduContextUserInfo?) {
        self.updateModel(with: stream.owner.userUuid,
                         resort: false)
    }
}

// MARK: - PaintingNameRollItemCellDelegate
extension AgoraUserListUIController: AgoraPaintingUserListItemCellDelegate {
    func onDidSelectFunction(_ fn: AgoraUserListFunction,
                             at index: NSIndexPath,
                             isOn: Bool) {
        let user = dataSource[index.row]
        switch fn {
        case .stage:
            guard user.stageState.isEnable else {
                return
            }
            if isOn {
                contextPool.user.addCoHost(userUuid: user.uuid) { [weak self] in
                    user.stageState.isOn = true
                    self?.reloadTableView()
                } failure: { contextError in

                }
            } else {
                contextPool.user.removeCoHost(userUuid: user.uuid) { [weak self] in
                    user.stageState.isOn = false
                    self?.reloadTableView()
                } failure: { contextError in

                }
            }
        case .auth:
            guard user.authState.isEnable else {
                return
            }
            var list: Array<String> = self.boardUsers
            if isOn,
               !list.contains(user.uuid) {
                // 授予白板权限
                list.append(user.uuid)
            } else if !isOn,
                      list.contains(user.uuid){
                // 收回白板权限
                list.removeAll(user.uuid)
            }
            if let message = AgoraBoardWidgetSignal.BoardGrantDataChanged(list).toMessageString() {
                contextPool.widget.sendMessage(toWidget: kBoardWidgetId,
                                               message: message)
            }
        case .camera:
            guard user.cameraState.isEnable,
                  let streamId = user.streamId else {
                return
            }
            contextPool.stream.updateStreamPublishPrivilege(streamUuids: [streamId],
                                                            videoPrivilege: isOn) { [weak self] in
                user.cameraState.streamOn = isOn
                self?.reloadTableView()
            } failure: { error in
                
            }
            break
        case .mic:
            guard user.cameraState.isEnable,
                  let streamId = user.streamId else {
                return
            }
            contextPool.stream.updateStreamPublishPrivilege(streamUuids: [streamId],
                                                            audioPrivilege: isOn) { [weak self] in
                user.micState.streamOn = isOn
                self?.reloadTableView()
            } failure: { error in
                
            }
            break
        case .kick:
            guard user.kickEnable else {
                return
            }
            AgoraKickOutAlertController.present(by: self,
                                                onComplete: {[weak self] forever in
                guard let `self` = self else {
                    return
                }
                self.contextPool.user.kickOutUser(userUuid: user.uuid,
                                                  forever: forever,
                                                  success: nil,
                                                  failure: nil)
            },
                                                onCancel: nil)
            break
        case .reward:
            guard user.rewardEnable else {
                return
            }
            contextPool.user.rewardUsers(userUuidList: [user.uuid],
                                         rewardCount: 1,
                                         success: nil,
                                         failure: nil)
        default:
            break
        }
    }
}
// MARK: - TableView Callback
extension AgoraUserListUIController: UITableViewDelegate,
                                     UITableViewDataSource {
    func tableView(_ tableView: UITableView,
                   numberOfRowsInSection section: Int) -> Int {
        return dataSource.count
    }
    
    func tableView(_ tableView: UITableView,
                   cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withClass: AgoraUserListItemCell.self)
        cell.supportFuncs = self.supportFuncs
        cell.itemModel = self.dataSource[indexPath.row]
        cell.indexPath = NSIndexPath(row: indexPath.row,
                                     section: indexPath.section)
        cell.delegate = self
        return cell
    }
}

// MARK: - Creations
extension AgoraUserListUIController {
    func createViews() {
        view.layer.shadowColor = UIColor(hex: 0x2F4192,
                                         transparency: 0.15)?.cgColor
        view.layer.shadowOffset = CGSize(width: 0,
                                         height: 2)
        view.layer.shadowOpacity = 1
        view.layer.shadowRadius = 6
        
        contentView = UIView()
        contentView.backgroundColor = UIColor(hex: 0xF9F9FC)
        contentView.layer.cornerRadius = 10.0
        contentView.clipsToBounds = true
        contentView.borderWidth = 1
        contentView.borderColor = UIColor(hex: 0xE3E3EC)
        view.addSubview(contentView)
        
        titleLabel = UILabel(frame: .zero)
        titleLabel.text = "UserListMainTitle".agedu_localized()
        titleLabel.font = UIFont.systemFont(ofSize: 12)
        titleLabel.textColor = UIColor(hex: 0x191919)
        contentView.addSubview(titleLabel)
        
        infoView = UIView(frame: .zero)
        infoView.backgroundColor = .white
        contentView.addSubview(infoView)
        
        topSepLine = UIView()
        topSepLine.backgroundColor = UIColor(hex: 0xEEEEF7)
        contentView.addSubview(topSepLine)
        
        bottomSepLine = UIView()
        bottomSepLine.backgroundColor = UIColor(hex: 0xEEEEF7)
        contentView.addSubview(bottomSepLine)
        
        teacherTitleLabel = UILabel(frame: .zero)
        teacherTitleLabel.text = "UserListTeacherName".agedu_localized()
        teacherTitleLabel.font = UIFont.systemFont(ofSize: 12)
        teacherTitleLabel.textColor = UIColor(hex: 0x7B88A0)
        contentView.addSubview(teacherTitleLabel)
        
        teacherNameLabel = UILabel(frame: .zero)
        teacherNameLabel.font = UIFont.systemFont(ofSize: 12)
        teacherNameLabel.textColor = UIColor(hex: 0x191919)
        contentView.addSubview(teacherNameLabel)
        
        studentTitleLabel = UILabel(frame: .zero)
        studentTitleLabel.text = "UserListName".agedu_localized()
        studentTitleLabel.textAlignment = .center
        studentTitleLabel.font = UIFont.systemFont(ofSize: 12)
        studentTitleLabel.textColor = UIColor(hex: 0x7B88A0)
        contentView.addSubview(studentTitleLabel)
        
        itemTitlesView = UIStackView(frame: .zero)
        itemTitlesView.backgroundColor = .clear
        itemTitlesView.axis = .horizontal
        itemTitlesView.distribution = .fillEqually
        itemTitlesView.alignment = .center
        itemTitlesView.backgroundColor = UIColor(hex: 0xF9F9FC)
        contentView.addSubview(itemTitlesView)
        
        if contextPool.user.getLocalUserInfo().userRole == .teacher,
           contextPool.room.getRoomInfo().roomType == .small {
            contentView.addSubview(carouselTitle)
            contentView.addSubview(carouselSwitch)
        }

        for fn in supportFuncs {
            let label = UILabel(frame: .zero)
            label.text = fn.title()
            label.textAlignment = .center
            label.font = UIFont.systemFont(ofSize: 12)
            label.textColor = UIColor(hex: 0x7B88A0)
            itemTitlesView.addArrangedSubview(label)
        }
        
        tableView = UITableView.init(frame: .zero,
                                     style: .plain)
        tableView.delegate = self
        tableView.dataSource = self
        tableView.tableFooterView = UIView.init(frame: CGRect(x: 0,
                                                              y: 0,
                                                              width: 1,
                                                              height: 0.01))
        tableView.rowHeight = 40
        tableView.allowsSelection = false
        tableView.separatorInset = .zero
        tableView.separatorColor = UIColor(hex: 0xEEEEF7)
        tableView.register(cellWithClass: AgoraUserListItemCell.self)
        contentView.addSubview(tableView)
    }
    
    func createConstraint() {
        contentView.mas_makeConstraints { make in
            make?.left.right().top().bottom().equalTo()(contentView.superview)
        }
        titleLabel.mas_makeConstraints { make in
            make?.top.equalTo()(titleLabel.superview)
            make?.left.equalTo()(16)
            make?.height.equalTo()(40)
        }
        infoView.mas_makeConstraints { make in
            make?.top.equalTo()(titleLabel.mas_bottom)
            make?.left.right().equalTo()(infoView.superview)
            make?.height.equalTo()(40)
        }
        topSepLine.mas_makeConstraints { make in
            make?.top.left().right().equalTo()(infoView)
            make?.height.equalTo()(1)
        }
        bottomSepLine.mas_makeConstraints { make in
            make?.bottom.left().right().equalTo()(infoView)
            make?.height.equalTo()(1)
        }
        teacherTitleLabel.mas_makeConstraints { make in
            make?.left.equalTo()(titleLabel)
            make?.top.bottom().equalTo()(infoView)
        }
        teacherNameLabel.mas_makeConstraints { make in
            make?.left.equalTo()(teacherTitleLabel.mas_right)?.offset()(6)
            make?.top.bottom().equalTo()(infoView)
        }
        studentTitleLabel.mas_makeConstraints { make in
            make?.top.equalTo()(infoView.mas_bottom)
            make?.left.equalTo()(0)
            make?.height.equalTo()(40)
            make?.width.equalTo()(100)
        }
        itemTitlesView.mas_makeConstraints { make in
            make?.top.equalTo()(studentTitleLabel)
            make?.left.equalTo()(studentTitleLabel.mas_right)
            make?.right.equalTo()(0)
            make?.height.equalTo()(studentTitleLabel)
        }
        tableView.mas_makeConstraints { make in
            make?.left.right().bottom().equalTo()(tableView.superview)
            make?.top.equalTo()(studentTitleLabel.mas_bottom)
        }
        if contextPool.user.getLocalUserInfo().userRole == .teacher,
           contextPool.room.getRoomInfo().roomType == .small {
            carouselSwitch.mas_makeConstraints { make in
                make?.centerY.equalTo()(titleLabel.mas_centerY)
                make?.right.equalTo()(-16)
                make?.height.equalTo()(40)
            }
            carouselTitle.mas_makeConstraints { make in
                make?.centerY.equalTo()(titleLabel.mas_centerY)
                make?.right.equalTo()(carouselSwitch.mas_left)?.offset()(-12)
                make?.height.equalTo()(40)
            }
        }
    }
    
    @objc func onClickCarouselSwitch(_ sender: UISwitch) {
        if sender.isOn {
            contextPool.user.startCoHostCarousel(interval: 20,
                                                 count: 6,
                                                 type: .sequence,
                                                 condition: .none) {
                
            } failure: { error in
                sender.isOn = !sender.isOn
            }
        } else {
            contextPool.user.stopCoHostCarousel {
                
            } failure: { error in
                sender.isOn = !sender.isOn
            }

        }
    }
}
