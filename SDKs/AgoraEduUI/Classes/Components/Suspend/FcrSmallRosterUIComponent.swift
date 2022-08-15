//
//  FcrSmallRosterUIComponent.swift
//  AgoraEduUI
//
//  Created by Jonathan on 2022/8/8.
//

import AgoraEduContext
import SwifterSwift
import AgoraWidget
import UIKit

/** 小班课花名册*/
class FcrSmallRosterUIComponent: FcrRosterUIComponent {
    
    override var carouselEnable: Bool {
        return contextPool.user.getLocalUserInfo().userRole == .teacher
    }
    
    private var boardUsers = [String]()
    
    private var isViewShow: Bool = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if contextPool.user.getLocalUserInfo().userRole == .teacher { // 老师
            setupSupportFuncs([.stage, .auth, .camera, .mic, .reward, .kick])
        } else { // 学生
            setupSupportFuncs([.stage, .auth, .camera, .mic, .reward])
        }
    }
    
    override init(context: AgoraEduContextPool) {
        super.init(context: context)
        
        contextPool.widget.add(self,
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
        contextPool.user.registerUserEventHandler(self)
        contextPool.stream.registerStreamEventHandler(self)
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        
        isViewShow = false
        removeAll()
        // remove event handler
        contextPool.user.unregisterUserEventHandler(self)
        contextPool.stream.unregisterStreamEventHandler(self)
    }
    
    override func onExcuteFunc(_ fn: AgoraRosterFunction,
                               to model: AgoraRosterModel) {
        switch fn {
        case .stage:
            guard model.stageState.isEnable else {
                return
            }
            if model.stageState.isOn {
                contextPool.user.addCoHost(userUuid: model.uuid) { [weak self] in
                    model.stageState.isOn = true
                    self?.reloadTableView()
                } failure: { contextError in
                    
                }
            } else {
                contextPool.user.removeCoHost(userUuid: model.uuid) { [weak self] in
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
            let signal =  AgoraBoardWidgetSignal.UpdateGrantedUsers(ifAdd ? .add([model.uuid]) : .delete([model.uuid]))
            if let message = signal.toMessageString() {
                contextPool.widget.sendMessage(toWidget: kBoardWidgetId,
                                               message: message)
            }
        case .camera:
            guard model.cameraState.isEnable,
                  let streamId = model.streamId else {
                return
            }
            let nextState = !model.cameraState.streamOn
            contextPool.stream.updateStreamPublishPrivilege(streamUuids: [streamId],
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
            contextPool.stream.updateStreamPublishPrivilege(streamUuids: [streamId],
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
            
            let kickOnceTitle = "fcr_user_kick_out_once".agedu_localized()
            let kickOnceAction = AgoraAlertAction(title: kickOnceTitle) { [weak self] in
                guard let `self` = self else {
                    return
                }
                self.contextPool.user.kickOutUser(userUuid: model.uuid,
                                                  forever: false,
                                                  success: nil,
                                                  failure: nil)
            }
            
            let kickForeverTitle = "fcr_user_kick_out_forever".agedu_localized()
            let kickForeverAction = AgoraAlertAction(title: kickForeverTitle) { [weak self] in
                guard let `self` = self else {
                    return
                }
                self.contextPool.user.kickOutUser(userUuid: model.uuid,
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
            guard model.rewardEnable else {
                return
            }
            contextPool.user.rewardUsers(userUuidList: [model.uuid],
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
    
    func refreshData() {
        setUpTeacherData()
        let localUserID = contextPool.user.getLocalUserInfo().userUuid
        guard let students = contextPool.user.getUserList(role: .student) else {
            return
        }
        var temp = [AgoraRosterModel]()
        for user in students {
            let model = AgoraRosterModel(contextUser: user)
            model.authState.isOn = boardUsers.contains(model.uuid)
            temp.append(model)
        }
        add(temp,
            resort: true)
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
        case .GetBoardGrantedUsers(let list):
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
            add([model],
                resort: true)
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
        update(by: uuids,
               resort: true)
    }
    
    func onCoHostUserListRemoved(userList: [AgoraEduContextUserInfo],
                                 operatorUser: AgoraEduContextUserInfo?) {
        let uuids = userList.map({$0.userUuid})
        update(by: uuids,
               resort: true)
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
        update(by: [stream.owner.userUuid],
               resort: false)
    }
    
    func onStreamUpdated(stream: AgoraEduContextStreamInfo,
                         operatorUser: AgoraEduContextUserInfo?) {
        update(by: [stream.owner.userUuid],
               resort: false)
    }
    
    func onStreamLeft(stream: AgoraEduContextStreamInfo,
                      operatorUser: AgoraEduContextUserInfo?) {
        update(by: [stream.owner.userUuid],
               resort: false)
    }
}
