//
//  FcrLectureRosterUIComponent.swift
//  AgoraEduUI
//
//  Created by Jonathan on 2022/8/8.
//

import AgoraEduContext
import SwifterSwift
import AgoraWidget
import UIKit

/** 大班课花名册*/
class FcrLectureRosterUIComponent: FcrRosterUIComponent {
    
    override var carouselEnable: Bool {
        return true
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
            let kickTitle = "fcr_user_kick_out".agedu_localized()
            
            let kickOnceTitle = "fcr_user_kick_out_once".agedu_localized()
            let kickOnceAction = AgoraAlertAction(title: kickOnceTitle) { [weak self] in
                guard let `self` = self else {
                    return
                }
                self.userController.kickOutUser(userUuid: model.uuid,
                                                  forever: false,
                                                  success: nil,
                                                  failure: nil)
            }
            
            let kickForeverTitle = "fcr_user_kick_out_forever".agedu_localized()
            let kickForeverAction = AgoraAlertAction(title: kickForeverTitle) { [weak self] in
                guard let `self` = self else {
                    return
                }
                self.userController.kickOutUser(userUuid: model.uuid,
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
        default:
            break
        }
    }
    
}
// MARK: - Private
private extension FcrLectureRosterUIComponent {
    
    func refreshData() {
        setUpTeacherData()
        
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
            self.add(temp,
                     resort: false)
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
        update(by: uuids,
               resort: false)
    }
    
    func onCoHostUserListRemoved(userList: [AgoraEduContextUserInfo],
                                 operatorUser: AgoraEduContextUserInfo?) {
        let uuids = userList.map({$0.userUuid})
        update(by: uuids,
               resort: false)
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
