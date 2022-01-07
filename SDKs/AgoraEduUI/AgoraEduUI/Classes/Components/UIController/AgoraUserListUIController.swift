//
//  PaintingNameRollViewController.swift
//  AgoraEduUI
//
//  Created by Jonathan on 2021/10/9.
//

import AgoraUIEduBaseViews
import AgoraEduContext
import SwifterSwift
import AgoraWidget
import UIKit

enum AgoraUserListFunction: Int {
    case stage = 0, auth, camera, mic, reward, kick
    
    func title() -> String {
        switch self {
        case .stage:
            return AgoraKitLocalizedString("UserListCoVideo")
        case .auth:
            return AgoraKitLocalizedString("UserListBoard")
        case .camera:
            return AgoraKitLocalizedString("UserListCamera")
        case .mic:
            return AgoraKitLocalizedString("UserListMicro")
        case .reward:
            return AgoraKitLocalizedString("UserListReward")
        case .kick:
            return AgoraKitLocalizedString("nameroll_kick_out")
        default: return ""
        }
    }
}

extension AgoraUserListModel {
    func updateWithStream(_ stream: AgoraEduContextStreamInfo?) {
        if let `stream` = stream {
            // audio
            self.micState.hasStream = stream.streamType.hasAudio
            self.micState.isOn = (stream.audioSourceState == .open)
            // video
            self.cameraState.hasStream = stream.streamType.hasVideo
            self.cameraState.isOn = (stream.videoSourceState == .open)
            
        } else {
            self.micState.hasStream = false
            self.micState.isOn = false
            self.cameraState.hasStream = false
            self.cameraState.isOn = false
        }
        self.cameraState.isEnable = false
        self.micState.isEnable = false
    }
}

class AgoraUserListUIController: UIViewController {
    
    public var suggestSize = CGSize(width: 300, height: 260)
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
    /** 表视图*/
    private var tableView: UITableView!
    /** 数据源*/
    private var dataSource = [AgoraUserListModel]()
    /** 支持的选项列表*/
    lazy var supportFuncs: [AgoraUserListFunction] = {
        if contextPool.user.getLocalUserInfo().userRole == .teacher {
            return [.stage, .auth, .camera, .mic, .reward, .kick]
        } else {
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
                               widgetId: "netlessBoard")
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        createViews()
        createConstrains()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        isViewShow = true
        setup()
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
    func setup() {
        let isTeacher = contextPool.user.getLocalUserInfo().userRole == .teacher
        let localUserID = contextPool.user.getLocalUserInfo().userUuid
        if let teacher = contextPool.user.getUserList(role: .teacher)?.first {
            teacherNameLabel.text = teacher.userName
        } else {
            teacherNameLabel.text = nil
        }
        guard let students = contextPool.user.getUserList(role: .student) else {
            return
        }
        var tmp = [AgoraUserListModel]()
        let coHosts = contextPool.user.getCoHostList()
        for student in students {
            let model = AgoraUserListModel()
            model.uuid = student.userUuid
            model.name = student.userName
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
            // stream
            let s = contextPool.stream.getStreamList(userUuid: student.userUuid)?.first
            model.updateWithStream(s)
            tmp.append(model)
        }
        dataSource = tmp
        sort()
    }
    // 针对某个模型进行更新
    func updateModel(with uuid: String, resort: Bool) {
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
        guard widgetId == "netlessBoard",
              let signal = message.toSignal() else {
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
            let model = AgoraUserListModel()
            dataSource.append(model)
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
            if isOn {
                // TODO: v2.1.0
//                contextPool.user.addCoHost(userUuid: user.uuid) { [weak self] in
//                    user.stageState.isOn = true
//                    self?.reloadTableView()
//                } failure: { contextError in
//
//                }
            } else {
                // TODO: v2.1.0
//                contextPool.user.removeCoHost(userUuid: user.uuid) {[weak self] in
//                    user.stageState.isOn = false
//                    self?.reloadTableView()
//                } failure: { contextError in
//
//                }
            }
        case .auth:
            // TODO: 白板权限
//            contextPool.user.updateBoardGranted(userUuids: [user.uuid],
//                                                granted: isOn)
            user.authState.isOn = isOn
//            reloadTableView()
        case .camera:
//            if contextPool.user.getLocalUserInfo().userUuid == user.uuid {
//                // TODO:
////                self.contextPool.device.setCameraDeviceEnable(enable: isOn)
//                user.camera.isOn = isOn
//                reloadTableView()
//            } else {
                // TODO:
//                contextPool.stream.muteStream(streamUuids: [user.uuid],
//                                              streamType: .video,
//                                              success: { [weak self] () -> (Void) in
//                                                user.camera.isOn = isOn
//                                                self?.reloadTableView()
//                }, failure: nil)
                
//                contextPool.stream.publishStream(streamUuids: <#T##[String]#>, streamType: <#T##AgoraEduContextMediaStreamType#>, success: <#T##AgoraEduContextSuccess?##AgoraEduContextSuccess?##() -> (Void)#>, failure: <#T##AgoraEduContextFail?##AgoraEduContextFail?##(AgoraEduContextError) -> (Void)#>)
                
               
//            }
        break
        case .mic:
//            if contextPool.user.getLocalUserInfo().userUuid == user.uuid {
                // TODO:
//                self.contextPool.device.setMicDeviceEnable(enable: isOn)
//                user.mic.isOn = isOn
//                reloadTableView()
//            } else {
                // TODO:
                
//                contextPool.stream.muteRemoteAudio(streamUuids: [user.uuid], mute: !isOn, success: { [weak self] in
//                    user.mic.isOn = isOn
//                    self?.reloadTableView()
//                }, failure: nil)
//            }
        break
        case .reward:
            // 奖励： 花名册只展示，不操作
            break
        case .kick:
            // TODO: v2.1.0
//            AgoraKickOutAlertController.present(by: self, onComplete: { forever in
//                self.contextPool.user.kickOutUser(userUuid: user.uuid,
//                                                  forever: forever,
//                                                  success: nil,
//                                                  failure: nil)
//            }, onCancel: nil)
            break
        default:  break
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
        titleLabel.text = AgoraKitLocalizedString("UserListMainTitle")
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
        teacherTitleLabel.text = AgoraKitLocalizedString("UserListTeacherName")
        teacherTitleLabel.font = UIFont.systemFont(ofSize: 12)
        teacherTitleLabel.textColor = UIColor(hex: 0x7B88A0)
        contentView.addSubview(teacherTitleLabel)
        
        teacherNameLabel = UILabel(frame: .zero)
        teacherNameLabel.font = UIFont.systemFont(ofSize: 12)
        teacherNameLabel.textColor = UIColor(hex: 0x191919)
        contentView.addSubview(teacherNameLabel)
        
        studentTitleLabel = UILabel(frame: .zero)
        studentTitleLabel.text = AgoraKitLocalizedString("UserListName")
        studentTitleLabel.textAlignment = .left
        studentTitleLabel.font = UIFont.systemFont(ofSize: 12)
        studentTitleLabel.textColor = UIColor(hex: 0x7B88A0)
        contentView.addSubview(studentTitleLabel)
        
        itemTitlesView = UIStackView(frame: .zero)
        itemTitlesView.backgroundColor = .clear
        itemTitlesView.axis = .horizontal
        itemTitlesView.distribution = .fillEqually
        itemTitlesView.alignment = .fill
        itemTitlesView.backgroundColor = UIColor(hex: 0xF9F9FC)
        contentView.addSubview(itemTitlesView)
        
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
    
    func createConstrains() {
        let contentWidth = 68 * supportFuncs.count
        self.suggestSize = CGSize(width: contentWidth, height: 260)
        contentView.mas_makeConstraints { make in
            make?.width.equalTo()(contentWidth)
            make?.height.equalTo()(260)
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
            make?.left.equalTo()(16)
            make?.height.equalTo()(40)
            make?.width.equalTo()(60)
        }
        itemTitlesView.mas_makeConstraints { make in
            make?.top.equalTo()(studentTitleLabel)
            make?.left.equalTo()(studentTitleLabel.mas_right)
            make?.right.equalTo()(-16)
            make?.height.equalTo()(studentTitleLabel)
        }
        tableView.mas_makeConstraints { make in
            make?.left.right().bottom().equalTo()(tableView.superview)
            make?.top.equalTo()(studentTitleLabel.mas_bottom)
        }
    }
}
