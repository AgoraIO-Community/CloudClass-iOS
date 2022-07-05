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

class AgoraUserListUIController: UIViewController {
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
    private lazy var infoView = UIView(frame: .zero)
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
@objc extension AgoraUserListUIController: AgoraUIActivity, AgoraUIContentContainer {
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
        contentView.addSubview(infoView)
        contentView.addSubview(topSepLine)
        contentView.addSubview(bottomSepLine)
        
        teacherTitleLabel.text = "fcr_user_list_teacher_name".agedu_localized()
        contentView.addSubview(teacherTitleLabel)
        
        contentView.addSubview(teacherNameLabel)
        
        studentTitleLabel.textAlignment = .center
        studentTitleLabel.text = "fcr_user_list_student_name".agedu_localized()
        contentView.addSubview(studentTitleLabel)
        
        itemTitlesView.backgroundColor = .clear
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
        
        for fn in supportFuncs {
            let label = UILabel(frame: .zero)
            label.text = fn.title()
            label.textAlignment = .center
            itemTitlesView.addArrangedSubview(label)
        }
        
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
        infoView.mas_makeConstraints { make in
            make?.top.equalTo()(titleLabel.mas_bottom)
            make?.left.right().equalTo()(infoView.superview)
            make?.height.equalTo()(30)
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
            make?.height.equalTo()(30)
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
        let ui = AgoraUIGroup()
        let contentLabelColor = ui.color.user_list_content_label_color
        let titleLabelColor = ui.color.user_list_title_label_color
        let labelFont = ui.frame.user_list_font_size
        
        ui.color.borderSet(layer: view.layer)
        
        contentView.backgroundColor = ui.color.user_list_bg_color
        contentView.layer.cornerRadius = ui.frame.user_list_content_corner_radius
        contentView.clipsToBounds = true
        contentView.borderWidth = ui.frame.user_list_content_border_width
        contentView.borderColor = ui.color.user_list_border_color
        
        
        titleLabel.font = labelFont
        titleLabel.textColor = titleLabelColor
        
        infoView.backgroundColor = ui.color.user_list_info_bg_color
        
        let sepColor = ui.color.user_list_sep_color
        topSepLine.backgroundColor = sepColor
        bottomSepLine.backgroundColor = sepColor
        
        teacherTitleLabel.font = labelFont
        teacherTitleLabel.textColor = contentLabelColor
        
        teacherNameLabel.font = labelFont
        teacherNameLabel.textColor = titleLabelColor
        
        studentTitleLabel.font = labelFont
        studentTitleLabel.textColor = contentLabelColor
        itemTitlesView.backgroundColor = ui.color.user_list_item_title_bg_color
        
        tableView.separatorColor = ui.color.user_list_table_sep_color
        
        for view in itemTitlesView.arrangedSubviews {
            guard let label = view as? UILabel else {
                return
            }
            label.font = labelFont
            label.textColor = contentLabelColor
        }
        
        if userController.getLocalUserInfo().userRole == .teacher,
           contextPool.room.getRoomInfo().roomType == .small {
            carouselTitle.font = labelFont
            carouselTitle.textColor = contentLabelColor
            
            carouselSwitch.onTintColor = ui.color.user_list_carousel_switch_tint_color
        }
    }
    
}
// MARK: - Private
private extension AgoraUserListUIController {
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
        for student in students {
            let model = AgoraUserListModel(contextUser: student)
            dataSource.append(model)
            updateModel(with: student.userUuid,
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
//        model.micState.isEnable = (stream.audioSourceState == .open)
        // video
        model.cameraState.streamOn = stream.streamType.hasVideo
        model.cameraState.deviceOn = (stream.videoSourceState == .open)
//        model.cameraState.isEnable = (stream.audioSourceState == .open)
        
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
extension AgoraUserListUIController: AgoraWidgetMessageObserver {
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
extension AgoraUserListUIController: AgoraEduUserHandler {
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
                // 授予白板权限
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
            AgoraKickOutAlertController.present(by: self,
                                                onComplete: {[weak self] forever in
                                                    guard let `self` = self else {
                                                        return
                                                    }
                                                    self.userController.kickOutUser(userUuid: user.uuid,
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

// MARK: - Actions
extension AgoraUserListUIController {
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
