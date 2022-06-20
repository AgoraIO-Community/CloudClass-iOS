//
//  AgoraLectureBoardUIController.swift
//  AgoraEduUI
//
//  Created by DoubleCircle on 2022/6/17.
//

import AgoraEduContext

class AgoraLectureBoardUIController: AgoraBoardUIController {
    private var userController: AgoraEduUserContext {
        if let `subRoom` = subRoom {
            return subRoom.user
        } else {
            return contextPool.user
        }
    }
    
    override func onViewWillActive() {
        super.onViewWillActive()
        userController.registerUserEventHandler(self)
    }
    
    override func onViewWillInactive() {
        super.onViewWillInactive()
        userController.unregisterUserEventHandler(self)
    }
}

extension AgoraLectureBoardUIController: AgoraEduUserHandler {
    func onCoHostUserListRemoved(userList: [AgoraEduContextUserInfo],
                                 operatorUser: AgoraEduContextUserInfo?) {
        let localUserId = userController.getLocalUserInfo().userUuid
        guard userList.contains(where: {$0.userUuid == localUserId}),
              localGranted else {
            return
        }
        
        let signal =  AgoraBoardWidgetSignal.UpdateGrantedUsers(.delete([localUserId]))
        if let message = signal.toMessageString() {
            widgetController.sendMessage(toWidget: kBoardWidgetId,
                                         message: message)
        }
    }
}

