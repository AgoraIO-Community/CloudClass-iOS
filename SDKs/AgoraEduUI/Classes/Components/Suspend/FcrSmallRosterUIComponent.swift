//
//  FcrSmallRosterUIComponent.swift
//  AgoraEduUI
//
//  Created by Jonathan on 2022/8/8.
//

import AgoraEduCore
import SwifterSwift
import AgoraWidget
import UIKit

/** 小班课花名册*/
class FcrSmallRosterUIComponent: FcrRosterUIComponent {
    
    private let userController: AgoraEduUserContext
    private let streamController: AgoraEduStreamContext
    private let widgetController: AgoraEduWidgetContext
    /** 轮播 仅教师端*/
    private lazy var carouselTitleLabel: UILabel = {
        let label = UILabel(frame: .zero)
        label.text = "fcr_user_list_carousel_setting".agedu_localized()
        return label
    }()
    private lazy var carouselSwitch: UISwitch = {
        let carouselSwitch = UISwitch()
        carouselSwitch.transform = CGAffineTransform(scaleX: 0.59,
                                                     y: 0.59)
        carouselSwitch.isOn = userController.getCoHostCarouselInfo().state
        carouselSwitch.addTarget(self,
                                 action: #selector(onClickCarouselSwitch(_:)),
                                 for: .touchUpInside)
        return carouselSwitch
    }()
    
    private var boardUsers = [String]()
    
    private var isViewShow: Bool = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if userController.getLocalUserInfo().userRole == .teacher { // 老师
            setupSupportFuncs([.stage, .auth, .camera, .mic, .reward, .kick])
        } else { // 学生
            setupSupportFuncs([.stage, .auth, .camera, .mic, .reward])
        }
    }
    
    init(userController: AgoraEduUserContext,
         streamController: AgoraEduStreamContext,
         widgetController: AgoraEduWidgetContext) {
        self.userController = userController
        self.streamController = streamController
        self.widgetController = widgetController
        
        super.init(nibName: nil,
                   bundle: nil)
        
        widgetController.add(self,
                             widgetId: kBoardWidgetId)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        isViewShow = true
        refreshData()
        // add event handler
        userController.registerUserEventHandler(self)
        streamController.registerStreamEventHandler(self)
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        
        isViewShow = false
        removeAll()
        // remove event handler
        userController.unregisterUserEventHandler(self)
        streamController.unregisterStreamEventHandler(self)
    }
    
    override func initViews() {
        super.initViews()
        
        if userController.getLocalUserInfo().userRole == .teacher {
            contentView.addSubview(carouselTitleLabel)
            contentView.addSubview(carouselSwitch)
            let config = UIConfig.roster
            carouselSwitch.agora_enable = config.carousel.enable
            carouselSwitch.agora_visible = config.carousel.visible
        }
    }
    
    override func initViewFrame() {
        super.initViewFrame()
        
        if userController.getLocalUserInfo().userRole == .teacher {
            carouselSwitch.mas_makeConstraints { make in
                make?.centerY.equalTo()(teacherNameLabel.mas_centerY)
                make?.right.equalTo()(-10)
                make?.height.equalTo()(30)
            }
            carouselTitleLabel.mas_makeConstraints { make in
                make?.centerY.equalTo()(teacherNameLabel.mas_centerY)
                make?.right.equalTo()(carouselSwitch.mas_left)
                make?.height.equalTo()(30)
            }
        }
    }
    
    override func updateViewProperties() {
        super.updateViewProperties()
        let config = UIConfig.roster
        if userController.getLocalUserInfo().userRole == .teacher {
            carouselTitleLabel.font = config.label.font
            carouselTitleLabel.textColor = config.label.subTitleColor
            
            carouselSwitch.onTintColor = config.carousel.tintColor
        }
    }
    
    override func update(model: AgoraRosterModel) {
        let isTeacher = (userController.getLocalUserInfo().userRole == .teacher)
        model.rewards = userController.getUserRewardCount(userUuid: model.uuid)
        // enable
        model.stageState.isEnable = isTeacher
        model.authState.isEnable = isTeacher
        model.rewardEnable = isTeacher
        model.kickEnable = isTeacher
        // 上下台操作
        let coHosts = userController.getCoHostList()
        var isCoHost = false
        if let _ = coHosts?.first(where: {$0.userUuid == model.uuid}) {
            isCoHost = true
        }
        if model.stageState.isOn != isCoHost {
            model.stageState.isOn = isCoHost
        }
        guard let stream = streamController.getStreamList(userUuid: model.uuid)?.first else {
            model.micState = (false, false, false)
            model.cameraState = (false, false, false)
            return
        }
        // stream
        model.streamId = stream.streamUuid
        // audio
        model.micState.streamOn = stream.streamType.hasAudio
        model.micState.deviceOn = (stream.audioSourceState == .open)
        // video
        model.cameraState.streamOn = stream.streamType.hasVideo
        model.cameraState.deviceOn = (stream.videoSourceState == .open)
        
        model.micState.isEnable = isTeacher && (stream.audioSourceState == .open)
        model.cameraState.isEnable = isTeacher && (stream.videoSourceState == .open)
    }
    
    override func onExcuteFunc(_ fn: AgoraRosterFunction,
                               to model: AgoraRosterModel) {
        switch fn {
        case .stage:
            guard model.stageState.isEnable else {
                return
            }
            if model.stageState.isOn {
                userController.addCoHost(userUuid: model.uuid) { [weak self] in
                    model.stageState.isOn = true
                    self?.reloadTableView()
                } failure: { contextError in
                    
                }
            } else {
                userController.removeCoHost(userUuid: model.uuid) { [weak self] in
                    model.stageState.isOn = false
                    self?.reloadTableView()
                } failure: { contextError in
                    
                }
            }
        case .auth:
            guard model.authState.isEnable else {
                return
            }
            var list: Array<String> = self.boardUsers
            var ifAdd = (model.authState.isOn &&
                         !list.contains(model.uuid))
            let signal =  AgoraBoardWidgetSignal.updateGrantedUsers(ifAdd ? .add([model.uuid]) : .delete([model.uuid]))
            if let message = signal.toMessageString() {
                widgetController.sendMessage(toWidget: kBoardWidgetId,
                                             message: message)
            }
        case .camera:
            guard model.cameraState.isEnable,
                  let streamId = model.streamId else {
                return
            }
            let nextState = !model.cameraState.streamOn
            streamController.updateStreamPublishPrivilege(streamUuids: [streamId],
                                                          videoPrivilege: nextState) { [weak self] in
                model.cameraState.streamOn = nextState
                self?.reloadTableView()
            } failure: { error in
                
            }
            break
        case .mic:
            guard model.micState.isEnable,
                  let streamId = model.streamId else {
                return
            }
            let nextState = !model.micState.streamOn
            streamController.updateStreamPublishPrivilege(streamUuids: [streamId],
                                                          audioPrivilege: nextState) { [weak self] in
                model.micState.streamOn = nextState
                self?.reloadTableView()
            } failure: { error in
                
            }
            break
        case .kick:
            guard model.kickEnable else {
                return
            }
            let kickTitle = "fcr_user_kick_out".agedu_localized()
            
            let kickOnceOption = "fcr_user_kick_out_once".agedu_localized()
            let kickForeverOption = "fcr_user_kick_out_forever".agedu_localized()
            
            let cancelActionTitle = "fcr_user_kick_out_cancel".agedu_localized()
            let submitActionTitle = "fcr_user_kick_out_submit".agedu_localized()
            
            let cancelAction = AgoraAlertAction(title: cancelActionTitle)
            
            let submitAction = AgoraAlertAction(title: submitActionTitle) { [weak self] optionIndex in
                guard let `self` = self else {
                    return
                }
                
                let forever = (optionIndex == 1 ? true : false)
                
                self.userController.kickOutUser(userUuid: model.uuid,
                                                  forever: forever,
                                                  success: nil,
                                                  failure: nil)
            }
            
            showAlert(title: kickTitle,
                      contentList: [kickOnceOption, kickForeverOption],
                      actions: [cancelAction, submitAction])
            break
        case .reward:
            guard model.rewardEnable else {
                return
            }
            userController.rewardUsers(userUuidList: [model.uuid],
                                       rewardCount: 1,
                                       success: nil,
                                       failure: nil)
        default:
            break
        }
    }
}
// MARK: - Private
private extension FcrSmallRosterUIComponent {
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
    
    func refreshData() {
        setupTeacherInfo(name: userController.getUserList(role: .teacher)?.first?.userName)
        let localUserID = userController.getLocalUserInfo().userUuid
        guard let students = userController.getUserList(role: .student) else {
            return
        }
        var temp = [AgoraRosterModel]()
        for user in students {
            let model = AgoraRosterModel(contextUser: user)
            model.authState.isOn = boardUsers.contains(model.uuid)
            temp.append(model)
        }
        dataSource = temp.coHostSort()
    }
    
}
// MARK: - AgoraWidgetMessageObserver
extension FcrSmallRosterUIComponent: AgoraWidgetMessageObserver {
    func onMessageReceived(_ message: String,
                           widgetId: String) {
        guard widgetId == kBoardWidgetId,
              let signal = message.toBoardSignal() else {
            return
        }
        switch signal {
        case .getBoardGrantedUsers(let list):
            self.boardUsers = list
            guard isViewShow else {
                return
            }
            setupEach { model in
                model.authState.isOn = list.contains(model.uuid)
            }
        default:
            break
        }
    }
}
// MARK: - AgoraEduUserHandler
extension FcrSmallRosterUIComponent: AgoraEduUserHandler {
    func onRemoteUserJoined(user: AgoraEduContextUserInfo) {
        if user.userRole == .student {
            let model = AgoraRosterModel(contextUser: user)
            update(model: model)
            dataSource.append(model)
            dataSource = dataSource.coHostSort()
        } else if user.userRole == .teacher {
            self.teacherNameLabel.text = user.userName
        }
    }
    
    func onRemoteUserLeft(user: AgoraEduContextUserInfo,
                          operatorUser: AgoraEduContextUserInfo?,
                          reason: AgoraEduContextUserLeaveReason) {
        if user.userRole == .student {
            remove(by: user.userUuid)
        } else if user.userRole == .teacher {
            self.teacherNameLabel.text = ""
        }
    }
    
    func onCoHostUserListAdded(userList: [AgoraEduContextUserInfo],
                               operatorUser: AgoraEduContextUserInfo?) {
        let uuids = userList.map({$0.userUuid})
        update(by: uuids)
        self.dataSource = self.dataSource.coHostSort()
    }
    
    func onCoHostUserListRemoved(userList: [AgoraEduContextUserInfo],
                                 operatorUser: AgoraEduContextUserInfo?) {
        let uuids = userList.map({$0.userUuid})
        update(by: uuids)
        self.dataSource = self.dataSource.coHostSort()
    }
    
    func onUserRewarded(user: AgoraEduContextUserInfo,
                        rewardCount: Int,
                        operatorUser: AgoraEduContextUserInfo?) {
        setup(by: user.userUuid) { model in
            model.rewards = rewardCount
        }
    }
}
// MARK: - AgoraEduStreamHandler
extension FcrSmallRosterUIComponent: AgoraEduStreamHandler {
    func onStreamJoined(stream: AgoraEduContextStreamInfo,
                        operatorUser: AgoraEduContextUserInfo?) {
        update(by: [stream.owner.userUuid])
        tableView.reloadData()
    }
    
    func onStreamUpdated(stream: AgoraEduContextStreamInfo,
                         operatorUser: AgoraEduContextUserInfo?) {
        update(by: [stream.owner.userUuid])
        tableView.reloadData()
    }
    
    func onStreamLeft(stream: AgoraEduContextStreamInfo,
                      operatorUser: AgoraEduContextUserInfo?) {
        update(by: [stream.owner.userUuid])
        tableView.reloadData()
    }
}
// MARK: - [AgoraRosterModel] ext
fileprivate extension Array where Element == AgoraRosterModel {
    /** 上台用户优先排序*/
    func coHostSort() -> [AgoraRosterModel] {
        var array = self
        array.sort {$0.sortRank < $1.sortRank}
        var coHosts = [AgoraRosterModel]()
        var rest = [AgoraRosterModel]()
        for user in array {
            if user.stageState.isOn {
                coHosts.append(user)
            } else {
                rest.append(user)
            }
        }
        coHosts.append(contentsOf: rest)
        return coHosts
    }
}
