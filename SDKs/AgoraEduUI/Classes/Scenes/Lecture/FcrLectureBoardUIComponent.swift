//
//  AgoraLectureBoardUIController.swift
//  AgoraEduUI
//
//  Created by DoubleCircle on 2022/6/17.
//

import AgoraEduContext

class FcrLectureBoardUIComponent: FcrBoardUIComponent {
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
    
    override func onGrantedUsersChanged(oldList: Array<String>,
                                        newList: Array<String>) {
        var newLocalGranted = true
        
        var finalNewList: [String] = newList.map({return $0})
        
        let localUser = contextPool.user.getLocalUserInfo()
        
        if localUser.userRole != .teacher {
            if !newList.contains(localUser.userUuid) {
                newLocalGranted = false
            } else if !userController.isLocalCoHost() {
                newLocalGranted = false
                resignBoardGranted(userId: localUser.userUuid)
                finalNewList.removeAll(localUser.userUuid)
            }
        }
        
        localGranted = newLocalGranted
        
        if let insertList = oldList.insert(from: finalNewList) {
            delegate?.onBoardGrantedUserListAdded(userList: insertList)
        }
        
        if let deletedList = oldList.delete(from: newList) {
            delegate?.onBoardGrantedUserListRemoved(userList: deletedList)
        }
    }
}

extension FcrLectureBoardUIComponent: AgoraEduUserHandler {
    func onCoHostUserListRemoved(userList: [AgoraEduContextUserInfo],
                                 operatorUser: AgoraEduContextUserInfo?) {
        let localUserId = userController.getLocalUserInfo().userUuid
        guard userList.contains(where: {$0.userUuid == localUserId}),
              localGranted else {
            return
        }
        resignBoardGranted(userId: localUserId)
    }
}

private extension FcrLectureBoardUIComponent {
    func resignBoardGranted(userId: String) {
        let signal =  AgoraBoardWidgetSignal.UpdateGrantedUsers(.delete([userId]))
        if let message = signal.toMessageString() {
            widgetController.sendMessage(toWidget: kBoardWidgetId,
                                         message: message)
        }
    }
}

fileprivate extension AgoraEduUserContext {
    func isLocalCoHost() -> Bool {
        let localUserId = getLocalUserInfo().userUuid
        guard let list = getCoHostList(),
              list.contains(where: {$0.userUuid == localUserId}) else {
            return false
        }
        return true
    }
}
