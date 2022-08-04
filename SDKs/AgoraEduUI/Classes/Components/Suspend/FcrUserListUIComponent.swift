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

class FcrUserListUIComponent: UIViewController {
    /** SDK环境*/
    private var contextPool: AgoraEduContextPool!
    
    private var subRoom: AgoraEduSubRoomContext?
    
    private var userController: AgoraEduUserContext {
        if let `subRoom` = subRoom {
            return subRoom.user
        } else {
            return contextPool.user
        }
    }
    
    private var streamController: AgoraEduStreamContext {
        if let `subRoom` = subRoom {
            return subRoom.stream
        } else {
            return contextPool.stream
        }
    }
    
    private var widgetController: AgoraEduWidgetContext {
        if let `subRoom` = subRoom {
            return subRoom.widget
        } else {
            return contextPool.widget
        }
    }
    
    public var suggestSize: CGSize {
        get {
            // 学生姓名为100，其余为80
            let contentWidth = 80 * supportFuncs.count + 100
            return CGSize(width: contentWidth,
                          height: 253)
        }
    }
    /** 容器*/
    private lazy var contentView = UIView(frame: .zero)
    /** 页面title*/
    private lazy var titleLabel = UILabel(frame: .zero)
    /** 教师信息*/
    private lazy var teacherInfoView = UIView(frame: .zero)
    /** 分割线*/
    private lazy var topSepLine = UIView(frame: .zero)
    private lazy var bottomSepLine = UIView(frame: .zero)
    /** 教师姓名 标签*/
    private lazy var teacherTitleLabel = UILabel(frame: .zero)
    /** 教师姓名 姓名*/
    private lazy var teacherNameLabel = UILabel(frame: .zero)
    /** 学生姓名*/
    private lazy var studentTitleLabel = UILabel(frame: .zero)
    /** 列表项*/
    private lazy var itemTitlesView = UIStackView(frame: .zero)
    /** 轮播 仅教师端*/
    private lazy var carouselTitle = UILabel(frame: .zero)
    private lazy var carouselSwitch = UISwitch()
    
    /** 表视图*/
    private var tableView = UITableView.init(frame: .zero,
                                             style: .plain)
    /** 数据源*/
    private var dataSource = [AgoraUserListModel]()
    /** 支持的选项列表*/
    lazy var supportFuncs: [AgoraUserListFunction] = {
        let isLecture = contextPool.room.getRoomInfo().roomType == .lecture
        let isTeacher = userController.getLocalUserInfo().userRole == .teacher
        
        var temp = [AgoraUserListFunction]()
        if isLecture {
            // 大班课老师（大班课学生端没有花名册）
            temp = [.camera, .mic, .kick]
        } else if isTeacher {
            // 小班课老师
            temp = [.stage, .auth, .camera, .mic, .reward, .kick]
        } else {
            // 小班课学生
            temp = [.stage, .auth, .camera, .mic, .reward]
        }
        
        return temp.enabledList()
    }()
    
    private var boardUsers = [String]()
    
    private var isViewShow: Bool = false
    
    deinit {
        print("\(#function): \(self.classForCoder)")
    }
    
    init(context: AgoraEduContextPool,
         subRoom: AgoraEduSubRoomContext? = nil) {
        super.init(nibName: nil,
                   bundle: nil)
        self.contextPool = context
        self.subRoom = subRoom
        
        widgetController.add(self,
                             widgetId: kBoardWidgetId)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        initViews()
        initViewFrame()
        updateViewProperties()
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
        userController.registerUserEventHandler(self)
        streamController.registerStreamEventHandler(self)
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        
        isViewShow = false
        // remove event handler
        userController.unregisterUserEventHandler(self)
        streamController.unregisterStreamEventHandler(self)
    }
}

// MARK: - AgoraUIActivity & AgoraUIContentContainer
@objc extension FcrUserListUIComponent: AgoraUIActivity, AgoraUIContentContainer {
    // AgoraUIActivity
    func viewWillActive() {
        
    }
    func viewWillInactive() {
        
    }
    // AgoraUIContentContainer
    func initViews() {
        view.addSubview(contentView)
        
        titleLabel.text = "fcr_user_list".agedu_localized()
        contentView.addSubview(titleLabel)
        contentView.addSubview(teacherInfoView)
        contentView.addSubview(topSepLine)
        contentView.addSubview(bottomSepLine)
        
        teacherTitleLabel.text = "fcr_user_list_teacher_name".agedu_localized()
        contentView.addSubview(teacherTitleLabel)
        
        contentView.addSubview(teacherNameLabel)
        
        studentTitleLabel.textAlignment = .left
        studentTitleLabel.text = "fcr_user_list_student_name".agedu_localized()
        contentView.addSubview(studentTitleLabel)
        
        itemTitlesView.axis = .horizontal
        itemTitlesView.distribution = .fillEqually
        itemTitlesView.alignment = .center
        contentView.addSubview(itemTitlesView)
        
        if userController.getLocalUserInfo().userRole == .teacher,
           contextPool.room.getRoomInfo().roomType == .small {
            carouselTitle.text = "fcr_user_list_carousel_setting".agedu_localized()
            contentView.addSubview(carouselTitle)
            
            carouselSwitch.transform = CGAffineTransform(scaleX: 0.59,
                                                         y: 0.59)
            carouselSwitch.isOn = userController.getCoHostCarouselInfo().state
            carouselSwitch.addTarget(self,
                                     action: #selector(onClickCarouselSwitch(_:)),
                                     for: .touchUpInside)
            contentView.addSubview(carouselSwitch)
        }
        
        let config = UIConfig.roster
        for fn in supportFuncs {
            let label = UILabel(frame: .zero)
            label.text = fn.title()
            label.textAlignment = .center
            
            switch fn {
            case .stage:
                label.agora_enable = config.stage.enable
                label.agora_visible = config.stage.visible
            case .auth:
                label.agora_enable = config.boardAuthorization.enable
                label.agora_visible = config.boardAuthorization.visible
            case .camera:
                label.agora_enable = config.camera.enable
                label.agora_visible = config.camera.visible
            case .mic:
                label.agora_enable = config.microphone.enable
                label.agora_visible = config.microphone.visible
            case .reward:
                label.agora_enable = config.reward.enable
                label.agora_visible = config.reward.visible
            case .kick:
                label.agora_enable = config.kickOut.enable
                label.agora_visible = config.kickOut.visible
            default:
                break
            }
            
            itemTitlesView.addArrangedSubview(label)
        }
        
        carouselSwitch.agora_enable = config.carousel.enable
        carouselSwitch.agora_visible = config.carousel.visible
        
        tableView.delegate = self
        tableView.dataSource = self
        tableView.tableFooterView = UIView.init(frame: CGRect(x: 0,
                                                              y: 0,
                                                              width: 1,
                                                              height: 0.01))
        tableView.rowHeight = 40
        tableView.allowsSelection = false
        tableView.separatorInset = .zero
        tableView.register(cellWithClass: AgoraUserListItemCell.self)
        contentView.addSubview(tableView)
    }
    
    func initViewFrame() {
        contentView.mas_makeConstraints { make in
            make?.left.right().top().bottom().equalTo()(contentView.superview)
        }
        titleLabel.mas_makeConstraints { make in
            make?.top.equalTo()(titleLabel.superview)
            make?.left.equalTo()(16)
            make?.height.equalTo()(30)
        }
        teacherInfoView.mas_makeConstraints { make in
            make?.top.equalTo()(titleLabel.mas_bottom)
            make?.left.right().equalTo()(teacherInfoView.superview)
            make?.height.equalTo()(30)
        }
        topSepLine.mas_makeConstraints { make in
            make?.top.left().right().equalTo()(teacherInfoView)
            make?.height.equalTo()(1)
        }
        bottomSepLine.mas_makeConstraints { make in
            make?.bottom.left().right().equalTo()(teacherInfoView)
            make?.height.equalTo()(1)
        }
        teacherTitleLabel.mas_makeConstraints { make in
            make?.left.equalTo()(16)
            make?.top.bottom().equalTo()(teacherInfoView)
        }
        teacherNameLabel.mas_makeConstraints { make in
            make?.left.equalTo()(teacherTitleLabel.mas_right)?.offset()(6)
            make?.top.bottom().equalTo()(teacherInfoView)
        }
        studentTitleLabel.mas_makeConstraints { make in
            make?.top.equalTo()(teacherInfoView.mas_bottom)
            make?.left.equalTo()(16)
            make?.height.equalTo()(30)
            make?.width.equalTo()(80)
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
        if userController.getLocalUserInfo().userRole == .teacher,
           contextPool.room.getRoomInfo().roomType == .small {
            carouselSwitch.mas_makeConstraints { make in
                make?.centerY.equalTo()(teacherNameLabel.mas_centerY)
                make?.right.equalTo()(-10)
                make?.height.equalTo()(30)
            }
            carouselTitle.mas_makeConstraints { make in
                make?.centerY.equalTo()(teacherNameLabel.mas_centerY)
                make?.right.equalTo()(carouselSwitch.mas_left)
                make?.height.equalTo()(30)
            }
        }
    }
    
    func updateViewProperties() {
        let config = UIConfig.roster
        
        view.layer.shadowColor = config.shadow.color
        view.layer.shadowOffset = config.shadow.offset
        view.layer.shadowOpacity = config.shadow.opacity
        view.layer.shadowRadius = config.shadow.radius
        
        contentView.backgroundColor = config.backgroundColor
        contentView.layer.cornerRadius = config.cornerRadius
        contentView.clipsToBounds = true
        contentView.layer.borderWidth = config.borderWidth
        contentView.layer.borderColor = config.borderColor
        
        titleLabel.font = config.label.font
        titleLabel.textColor = config.label.mainTitleColor
                
        topSepLine.backgroundColor = config.sepLine.backgroundColor
        bottomSepLine.backgroundColor = config.sepLine.backgroundColor
        
        teacherInfoView.backgroundColor = config.titleBackgroundColor
        teacherTitleLabel.font = config.label.font
        teacherTitleLabel.textColor = config.label.subTitleColor
        
        teacherNameLabel.font = config.label.font
        teacherNameLabel.textColor = config.label.mainTitleColor
        
        studentTitleLabel.font = config.label.font
        studentTitleLabel.textColor = config.label.subTitleColor
        
        tableView.backgroundColor = config.cellBackgroundColor
        tableView.separatorColor = config.sepLine.backgroundColor
        
        for view in itemTitlesView.arrangedSubviews {
            guard let label = view as? UILabel else {
                return
            }
            label.font = config.label.font
            label.textColor = config.label.subTitleColor
        }
        
        if userController.getLocalUserInfo().userRole == .teacher,
           contextPool.room.getRoomInfo().roomType == .small {
            carouselTitle.font = config.label.font
            carouselTitle.textColor = config.label.subTitleColor
            
            carouselSwitch.onTintColor = config.carousel.tintColor
        }
    }
    
}
// MARK: - Private
private extension FcrUserListUIComponent {
    func setUpTeacherData() {
        if let teacher = userController.getUserList(role: .teacher)?.first {
            teacherNameLabel.text = teacher.userName
        } else {
            teacherNameLabel.text = nil
        }
    }
    
    func setUpSmallData() {
        setUpTeacherData()
        
        let localUserID = userController.getLocalUserInfo().userUuid
        
        guard let students = userController.getUserList(role: .student) else {
            return
        }
        for user in students {
            if !self.dataSource.contains{ $0.uuid == user.userUuid } {
                let model = AgoraUserListModel(contextUser: user)
                self.dataSource.append(model)
            }
            self.updateModel(with: user.userUuid,
                             resort: false)
        }
        sort()
    }
    
    func setUpLectureData() {
        setUpTeacherData()
        
        userController.getUserList(roleList: [AgoraEduContextUserRole.student.rawValue],
                                   pageIndex: 1,
                                   pageSize: 20) { [weak self] list in
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
        let isTeacher = (userController.getLocalUserInfo().userRole == .teacher)
        let coHosts = userController.getCoHostList()
        let localUserID = userController.getLocalUserInfo().userUuid
        var isCoHost = false
        if let _ = coHosts?.first(where: {$0.userUuid == model.uuid}) {
            isCoHost = true
        }
        model.stageState.isOn = isCoHost
        model.rewards = userController.getUserRewardCount(userUuid: uuid)
        
        model.authState.isOn = boardUsers.contains(model.uuid)
        // enable
        model.stageState.isEnable = isTeacher
        model.authState.isEnable = isTeacher
        model.rewardEnable = isTeacher
        model.kickEnable = isTeacher
        // stream
        updateModelWithStream(model)
        if resort {
            sort()
        } else {
            tableView.reloadData()
        }
    }
    
    func updateModelWithStream(_ model: AgoraUserListModel) {
        guard let stream = streamController.getStreamList(userUuid: model.uuid)?.first else {
            model.micState = (false, false, false)
            model.cameraState = (false, false, false)
            return
        }
        
        model.streamId = stream.streamUuid
        // audio
        model.micState.streamOn = stream.streamType.hasAudio
        model.micState.deviceOn = (stream.audioSourceState == .open)

        // video
        model.cameraState.streamOn = stream.streamType.hasVideo
        model.cameraState.deviceOn = (stream.videoSourceState == .open)
        
        let isTeacher = (userController.getLocalUserInfo().userRole == .teacher)
        model.micState.isEnable = isTeacher && (stream.audioSourceState == .open)
        model.cameraState.isEnable = isTeacher && (stream.videoSourceState == .open)

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
extension FcrUserListUIComponent: AgoraWidgetMessageObserver {
    func onMessageReceived(_ message: String,
                           widgetId: String) {
        guard widgetId == kBoardWidgetId,
              let signal = message.toBoardSignal() else {
            return
        }
        switch signal {
        case .GetBoardGrantedUsers(let list):
            self.boardUsers = list
            guard isViewShow else {
                return
            }
            for model in dataSource {
                model.authState.isOn = list.contains(model.uuid)
            }
            tableView.reloadData()
        default:
            break
        }
    }
}

// MARK: - AgoraEduUserHandler
extension FcrUserListUIComponent: AgoraEduUserHandler {
    func onRemoteUserJoined(user: AgoraEduContextUserInfo) {
        if user.userRole == .student {
            let model = AgoraUserListModel(contextUser: user)
            dataSource.append(model)
            updateModel(with: user.userUuid,
                        resort: true)
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
extension FcrUserListUIComponent: AgoraEduStreamHandler {
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
extension FcrUserListUIComponent: AgoraPaintingUserListItemCellDelegate {
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
                userController.addCoHost(userUuid: user.uuid) { [weak self] in
                    user.stageState.isOn = true
                    self?.reloadTableView()
                } failure: { contextError in
                    
                }
            } else {
                userController.removeCoHost(userUuid: user.uuid) { [weak self] in
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
            var ifAdd = false
            if isOn,
               !list.contains(user.uuid) {
                ifAdd = true
            }
            let signal =  AgoraBoardWidgetSignal.UpdateGrantedUsers(ifAdd ? .add([user.uuid]) : .delete([user.uuid]))
            if let message = signal.toMessageString() {
                widgetController.sendMessage(toWidget: kBoardWidgetId,
                                             message: message)
            }
        case .camera:
            guard user.cameraState.isEnable,
                  let streamId = user.streamId else {
                return
            }
            streamController.updateStreamPublishPrivilege(streamUuids: [streamId],
                                                          videoPrivilege: isOn) { [weak self] in
                user.cameraState.streamOn = isOn
                self?.reloadTableView()
            } failure: { error in
                
            }
            break
        case .mic:
            guard user.micState.isEnable,
                  let streamId = user.streamId else {
                return
            }
            streamController.updateStreamPublishPrivilege(streamUuids: [streamId],
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
            let kickTitle = "fcr_user_kick_out".agedu_localized()
            
            let kickOnceTitle = "fcr_user_kick_out_once".agedu_localized()
            let kickOnceAction = AgoraAlertAction(title: kickOnceTitle) { [weak self] in
                guard let `self` = self else {
                    return
                }
                self.userController.kickOutUser(userUuid: user.uuid,
                                                  forever: false,
                                                  success: nil,
                                                  failure: nil)
            }
            
            let kickForeverTitle = "fcr_user_kick_out_forever".agedu_localized()
            let kickForeverAction = AgoraAlertAction(title: kickForeverTitle) { [weak self] in
                guard let `self` = self else {
                    return
                }
                self.userController.kickOutUser(userUuid: user.uuid,
                                                  forever: true,
                                                  success: nil,
                                                  failure: nil)
            }
            
            AgoraAlertModel()
                .setTitle(kickTitle)
                .setStyle(.Choice)
                .addAction(action: kickOnceAction)
                .addAction(action: kickForeverAction)
                .show(in: self)
            break
        case .reward:
            guard user.rewardEnable else {
                return
            }
            userController.rewardUsers(userUuidList: [user.uuid],
                                         rewardCount: 1,
                                         success: nil,
                                         failure: nil)
        default:
            break
        }
    }
}
// MARK: - TableView Callback
extension FcrUserListUIComponent: UITableViewDelegate,
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

// MARK: - Actions
extension FcrUserListUIComponent {
    @objc func onClickCarouselSwitch(_ sender: UISwitch) {
        if sender.isOn {
            userController.startCoHostCarousel(interval: 20,
                                                 count: 6,
                                                 type: .sequence,
                                                 condition: .none) {
                
            } failure: { error in
                sender.isOn = !sender.isOn
            }
        } else {
            userController.stopCoHostCarousel {
                
            } failure: { error in
                sender.isOn = !sender.isOn
            }
        }
    }
}

fileprivate extension Array where Element == AgoraUserListFunction {
    func enabledList() -> [AgoraUserListFunction] {
        let config = UIConfig.roster
        
        var list = [AgoraUserListFunction]()
        
        for item in self {
            switch item {
            case .stage:
                if config.stage.enable,
                   config.stage.visible {
                    list.append(item)
                }
            case .auth:
                if config.boardAuthorization.enable,
                   config.boardAuthorization.visible {
                    list.append(item)
                }
            case .camera:
                if config.camera.enable,
                   config.camera.visible {
                    list.append(item)
                }
            case .mic:
                if config.microphone.enable,
                   config.microphone.visible {
                    list.append(item)
                }
            case .reward:
                if config.reward.enable,
                   config.reward.visible {
                    list.append(item)
                }
            case .kick:
                if config.kickOut.enable,
                   config.kickOut.visible {
                    list.append(item)
                }
            default:
                break
            }
        }
        
        return list
    }
}
