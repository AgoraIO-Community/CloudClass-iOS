//
//  FcrLectureRosterUIComponent.swift
//  AgoraEduUI
//
//  Created by Jonathan on 2022/8/8.
//

import AgoraEduCore
import AgoraWidget
import UIKit

/** 大班课花名册*/
class FcrLectureRosterUIComponent: FcrRosterUIComponent {
    
    private let userController: AgoraEduUserContext
    private let streamController: AgoraEduStreamContext
    
    init(userController: AgoraEduUserContext,
         streamController: AgoraEduStreamContext) {
        self.userController = userController
        self.streamController = streamController
        
        super.init(nibName: nil,
                   bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupSupportFuncs([.camera, .mic, .kick])
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        refreshData()
        // add event handler
        userController.registerUserEventHandler(self)
        streamController.registerStreamEventHandler(self)
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        removeAll()
        // remove event handler
        userController.unregisterUserEventHandler(self)
        streamController.unregisterStreamEventHandler(self)
    }
    
    override func update(model: AgoraRosterModel) {
        let isTeacher = (userController.getLocalUserInfo().userRole == .teacher)
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
            
            let kickTitle = "fcr_user_kick_out".edu_ui_localized()
            
            let kickOnceOption = "fcr_user_kick_out_once".edu_ui_localized()
            let kickForeverOption = "fcr_user_kick_out_forever".edu_ui_localized()
            
            let cancelActionTitle = "fcr_user_kick_out_cancel".edu_ui_localized()
            let submitActionTitle = "fcr_user_kick_out_submit".edu_ui_localized()
            
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
        default:
            break
        }
    }
    
}
// MARK: - Private
private extension FcrLectureRosterUIComponent {
    
    func refreshData() {
        setupTeacherInfo(name: userController.getUserList(role: .teacher)?.first?.userName)
        userController.getUserList(roleList: [AgoraEduContextUserRole.student.rawValue],
                                   pageIndex: 1,
                                   pageSize: 20) { [weak self] students in
            guard let `self` = self else {
                return
            }
            var temp = [AgoraRosterModel]()
            for user in students {
                let model = AgoraRosterModel(contextUser: user)
                temp.append(model)
            }
            self.dataSource = temp
        } failure: { error in
            print(error)
        }
    }
}
// MARK: - AgoraEduUserHandler
extension FcrLectureRosterUIComponent: AgoraEduUserHandler {
    
    func onCoHostUserListAdded(userList: [AgoraEduContextUserInfo],
                               operatorUser: AgoraEduContextUserInfo?) {
        let uuids = userList.map({$0.userUuid})
        update(by: uuids)
        tableView.reloadData()
    }
    
    func onCoHostUserListRemoved(userList: [AgoraEduContextUserInfo],
                                 operatorUser: AgoraEduContextUserInfo?) {
        let uuids = userList.map({$0.userUuid})
        update(by: uuids)
        tableView.reloadData()
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
extension FcrLectureRosterUIComponent: AgoraEduStreamHandler {
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
