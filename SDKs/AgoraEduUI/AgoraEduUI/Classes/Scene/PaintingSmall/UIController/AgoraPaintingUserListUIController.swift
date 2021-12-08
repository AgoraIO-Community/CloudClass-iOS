//
//  PaintingNameRollViewController.swift
//  AgoraEduUI
//
//  Created by Jonathan on 2021/10/9.
//

import AgoraUIEduBaseViews
import AgoraEduContext
import SwifterSwift
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

class AgoraPaintingUserListUIController: UIViewController {
    /** 容器*/
    var contentView: UIView!
    /** 页面title*/
    var titleLabel: UILabel!
    /** 教师信息*/
    var infoView: UIView!
    /** 分割线*/
    var topSepLine: UIView!
    var bottomSepLine: UIView!
    /** 教师姓名 标签*/
    var teacherTitleLabel: UILabel!
    /** 教师姓名 姓名*/
    var teacherNameLabel: UILabel!
    /** 学生姓名*/
    var studentTitleLabel: UILabel!
    /** 列表项*/
    var itemTitlesView: UIStackView!
    /** 表视图*/
    var tableView: UITableView!
    /** 数据源*/
    var dataSource = [AgoraPaintingUserListItemModel]()
    /** 支持的选项列表*/
    lazy var supportFuncs: [AgoraUserListFunction] = {
        if contextPool.user.getLocalUserInfo().role == .teacher {
            return [.stage, .auth, .camera, .mic, .reward, .kick]
        } else {
            return [.stage, .auth, .camera, .mic, .reward]
        }
    }()
    /** SDK环境*/
    var contextPool: AgoraEduContextPool!
    
    deinit {
        print("\(#function): \(self.classForCoder)")
    }
    
    init(context: AgoraEduContextPool) {
        super.init(nibName: nil, bundle: nil)
        contextPool = context
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        createViews()
        createConstrains()
        contextPool.user.registerEventHandler(self)
        contextPool.stream.registerStreamEventHandler(self)
    }
}
// MARK: - Private
private extension AgoraPaintingUserListUIController {
    func reloadUsers() {
        let isAdmin = contextPool.user.getLocalUserInfo().role == .teacher
        let list = contextPool.user.getAllUserList()
        var tmp = [AgoraPaintingUserListItemModel]()
        var teacher: AgoraEduContextUserInfo?
        for user in list {
            if user.role == .teacher {
                teacher = user
            } else if user.role == .student {
                let model = AgoraPaintingUserListItemModel()
                model.uuid = user.userUuid
                model.name = user.userName
                model.rewards = user.rewardCount
                // TODO:
//                model.stage.isOn = user.isCoHost
                // TODO: 白板权限
//                model.auth.isOn = user.boardGranted
                // enable
                model.stage.enable = isAdmin
                model.auth.enable = isAdmin
                // stream
                let s = contextPool.stream.getStreamInfo(userUuid: user.userUuid)?.first
                
                // TODO:
//                model.camera.isOn = (s?.streamType == .audioAndVideo || s?.streamType == .video)
//                model.mic.isOn = (s?.streamType == .audioAndVideo || s?.streamType == .audio)
//                model.camera.enable = (user.isLocal && user.isCoHost) || (isAdmin && user.isOnLine && user.isCoHost && s?.videoSourceType != .invalid)
//                model.mic.enable = (user.isLocal && user.isCoHost) || (isAdmin && user.isOnLine && user.isCoHost && s?.videoSourceType != .invalid)
                
                tmp.append(model)
            }
        }
        if let model = teacher {
            self.teacherNameLabel.text = model.userName
        } else {
            self.teacherNameLabel.text = nil
        }
        self.dataSource = tmp
        reloadTableView()
    }
    
    func updateStreamWithUUID(_ uuid: String) {
        let isAdmin = contextPool.user.getLocalUserInfo().role == .teacher
        if let model = dataSource.first{ $0.uuid == uuid},
           let user = contextPool.user.getAllUserList().first {$0.userUuid == uuid} {
            let s = contextPool.stream.getStreamInfo(userUuid: user.userUuid)?.first
            
            // TODO:
//            model.camera.isOn = (s?.streamType == .audioAndVideo || s?.streamType == .video)
//            model.mic.isOn = (s?.streamType == .audioAndVideo || s?.streamType == .audio)
//            model.camera.enable = user.isLocal || (isAdmin && user.isOnLine && user.isCoHost && s?.videoSourceType != .invalid)
//            model.mic.enable = user.isLocal || (isAdmin && user.isOnLine && user.isCoHost && s?.videoSourceType != .invalid)
            reloadTableView()
        }
    }
    
    func reloadTableView() {
        DispatchQueue.main.async {
            self.tableView.reloadData()
        }
    }
}

// MARK: - AgoraEduUserHandler
extension AgoraPaintingUserListUIController: AgoraEduUserHandler {
    func onRemoteUserJoined(user: AgoraEduContextUserInfo) {
        reloadUsers()
    }
    func onRemoteUserLeft(user: AgoraEduContextUserInfo, operator: AgoraEduContextUserInfo?, reason: AgoraEduContextUserLeaveReason) {
        reloadUsers()
    }
    func onUserUpdated(user: AgoraEduContextUserInfo, operator: AgoraEduContextUserInfo?) {
        reloadUsers()
    }
}

// MARK: - AgoraEduStreamHandler
extension AgoraPaintingUserListUIController: AgoraEduStreamHandler {
    func onStreamJoin(stream: AgoraEduContextStream,
                      operator: AgoraEduContextUserInfo?) {
        self.updateStreamWithUUID(stream.owner.userUuid)
    }
    
    func onStreamLeave(stream: AgoraEduContextStream,
                       operator: AgoraEduContextUserInfo?) {
        self.updateStreamWithUUID(stream.owner.userUuid)
    }
    
    func onStreamUpdate(stream: AgoraEduContextStream,
                        operator: AgoraEduContextUserInfo?) {
        self.updateStreamWithUUID(stream.owner.userUuid)
    }
}

// MARK: - PaintingNameRollItemCellDelegate
extension AgoraPaintingUserListUIController: AgoraPaintingUserListItemCellDelegate {
    func onDidSelectFunction(_ fn: AgoraUserListFunction,
                             at index: NSIndexPath,
                             isOn: Bool) {
        let user = dataSource[index.row]
        switch fn {
        case .stage:
            if isOn {
                contextPool.user.addCoHost(userUuid: user.uuid) { [weak self] in
                    user.stage.isOn = true
                    self?.reloadTableView()
                } failure: { contextError in
                    
                }
            } else {
                contextPool.user.removeCoHost(userUuid: user.uuid) {[weak self] in
                    user.stage.isOn = false
                    self?.reloadTableView()
                } failure: { contextError in
                    
                }
            }
        case .auth:
            // TODO: 白板权限
//            contextPool.user.updateBoardGranted(userUuids: [user.uuid],
//                                                granted: isOn)
            user.auth.isOn = isOn
//            reloadTableView()
        case .camera:
            if contextPool.user.getLocalUserInfo().userUuid == user.uuid {
                // TODO:
//                self.contextPool.device.setCameraDeviceEnable(enable: isOn)
                user.camera.isOn = isOn
                reloadTableView()
            } else {
                // TODO:
                contextPool.stream.muteStream(streamUuids: [user.uuid],
                                              streamType: .video,
                                              success: { [weak self] () -> (Void) in
                                                user.camera.isOn = isOn
                                                self?.reloadTableView()
                }, failure: nil)
                
//                contextPool.stream.publishStream(streamUuids: <#T##[String]#>, streamType: <#T##AgoraEduContextMediaStreamType#>, success: <#T##AgoraEduContextSuccess?##AgoraEduContextSuccess?##() -> (Void)#>, failure: <#T##AgoraEduContextFail?##AgoraEduContextFail?##(AgoraEduContextError) -> (Void)#>)
                
               
            }
        case .mic:
            if contextPool.user.getLocalUserInfo().userUuid == user.uuid {
                // TODO:
//                self.contextPool.device.setMicDeviceEnable(enable: isOn)
                user.mic.isOn = isOn
                reloadTableView()
            } else {
                // TODO:
                
//                contextPool.stream.muteRemoteAudio(streamUuids: [user.uuid], mute: !isOn, success: { [weak self] in
//                    user.mic.isOn = isOn
//                    self?.reloadTableView()
//                }, failure: nil)
            }
        case .reward:
            // 奖励： 花名册只展示，不操作
            break
        case .kick:
            AgoraKickOutAlertController.present(by: self, onComplete: { forever in
                self.contextPool.user.kickOutUser(userUuid: user.uuid,
                                                  forever: forever,
                                                  success: nil,
                                                  failure: nil)
            }, onCancel: nil)
        default:  break
        }
    }
}
// MARK: - TableView Callback
extension AgoraPaintingUserListUIController: UITableViewDelegate,
                                             UITableViewDataSource {
    func tableView(_ tableView: UITableView,
                   numberOfRowsInSection section: Int) -> Int {
        return dataSource.count
    }
    
    func tableView(_ tableView: UITableView,
                   cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withClass: AgoraPaintingUserListItemCell.self)
        cell.supportFuncs = self.supportFuncs
        cell.itemModel = self.dataSource[indexPath.row]
        cell.indexPath = NSIndexPath(row: indexPath.row,
                                     section: indexPath.section)
        cell.delegate = self
        return cell
    }
}

// MARK: - Creations
extension AgoraPaintingUserListUIController {
    func createViews() {
        view.layer.shadowColor = UIColor(rgb: 0x2F4192,
                                         alpha: 0.15).cgColor
        view.layer.shadowOffset = CGSize(width: 0,
                                         height: 2)
        view.layer.shadowOpacity = 1
        view.layer.shadowRadius = 6
        
        contentView = UIView()
        contentView.backgroundColor = UIColor(rgb: 0xF9F9FC)
        contentView.layer.cornerRadius = 10.0
        contentView.clipsToBounds = true
        view.addSubview(contentView)
        
        titleLabel = UILabel(frame: .zero)
        titleLabel.text = AgoraKitLocalizedString("UserListMainTitle")
        titleLabel.font = UIFont.systemFont(ofSize: 12)
        titleLabel.textColor = UIColor(rgb: 0x191919)
        contentView.addSubview(titleLabel)
        
        infoView = UIView(frame: .zero)
        infoView.backgroundColor = .white
        contentView.addSubview(infoView)
        
        topSepLine = UIView()
        topSepLine.backgroundColor = UIColor(rgb: 0xEEEEF7)
        contentView.addSubview(topSepLine)
        
        bottomSepLine = UIView()
        bottomSepLine.backgroundColor = UIColor(rgb: 0xEEEEF7)
        contentView.addSubview(bottomSepLine)
        
        teacherTitleLabel = UILabel(frame: .zero)
        teacherTitleLabel.text = AgoraKitLocalizedString("UserListTeacherName")
        teacherTitleLabel.font = UIFont.systemFont(ofSize: 12)
        teacherTitleLabel.textColor = UIColor(rgb: 0x7B88A0)
        contentView.addSubview(teacherTitleLabel)
        
        teacherNameLabel = UILabel(frame: .zero)
        teacherNameLabel.font = UIFont.systemFont(ofSize: 12)
        teacherNameLabel.textColor = UIColor(rgb: 0x191919)
        contentView.addSubview(teacherNameLabel)
        
        studentTitleLabel = UILabel(frame: .zero)
        studentTitleLabel.text = AgoraKitLocalizedString("UserListName")
        studentTitleLabel.textAlignment = .left
        studentTitleLabel.font = UIFont.systemFont(ofSize: 12)
        studentTitleLabel.textColor = UIColor(rgb: 0x7B88A0)
        contentView.addSubview(studentTitleLabel)
        
        itemTitlesView = UIStackView(frame: .zero)
        itemTitlesView.backgroundColor = .clear
        itemTitlesView.axis = .horizontal
        itemTitlesView.distribution = .fillEqually
        itemTitlesView.alignment = .fill
        itemTitlesView.backgroundColor = UIColor(rgb: 0xF9F9FC)
        contentView.addSubview(itemTitlesView)
        
        for fn in supportFuncs {
            let label = UILabel(frame: .zero)
            label.text = fn.title()
            label.textAlignment = .center
            label.font = UIFont.systemFont(ofSize: 12)
            label.textColor = UIColor(rgb: 0x7B88A0)
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
        tableView.separatorColor = UIColor(rgb: 0xEEEEF7)
        tableView.register(cellWithClass: AgoraPaintingUserListItemCell.self)
        contentView.addSubview(tableView)
    }
    
    func createConstrains() {
        let contentWidth = 68 * supportFuncs.count
        contentView.mas_makeConstraints { make in
            make?.width.equalTo()(contentWidth)
            make?.height.equalTo()(260)
            make?.left.right().top().bottom().equalTo()(contentView.superview)
        }
        titleLabel.mas_makeConstraints { make in
            make?.top.equalTo()(titleLabel.superview)
            make?.left.equalTo()(22)
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
            make?.left.equalTo()(22)
            make?.height.equalTo()(40)
            make?.width.equalTo()(60)
        }
        itemTitlesView.mas_makeConstraints { make in
            make?.top.equalTo()(studentTitleLabel)
            make?.left.equalTo()(studentTitleLabel.mas_right)
            make?.right.equalTo()(-20)
            make?.height.equalTo()(studentTitleLabel)
        }
        tableView.mas_makeConstraints { make in
            make?.left.right().bottom().equalTo()(tableView.superview)
            make?.top.equalTo()(studentTitleLabel.mas_bottom)
        }
    }
}
