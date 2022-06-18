//
//  FcrLectureWindowRenderUIController.swift
//  AgoraEduUI
//
//  Created by Cavan on 2022/6/12.
//

import AgoraEduContext
import UIKit

class FcrLectureWindowRenderUIController: FcrTeacherWindowRenderUIController {
    override func addItemOfTeacher(_ user: AgoraEduContextUserInfo) {
        guard let stream = streamController.firstCameraStream(of: user) else {
            return
        }
        
        let item = createItem(with: stream)
        updateItem(item,
                   index: 0)
    }
    
    override func deleteItemOfTeacher(_ user: AgoraEduContextUserInfo) {
        updateItem(.none,
                   index: 0)
    }
}
