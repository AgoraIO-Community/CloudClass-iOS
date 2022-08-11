//
//  FcrLectureWindowRenderUIController.swift
//  AgoraEduUI
//
//  Created by Cavan on 2022/6/12.
//

import AgoraEduContext
import UIKit

class FcrLectureWindowRenderUIComponent: FcrTeacherWindowRenderUIComponent {
    override func initViews() {
        super.initViews()
        
        let teacherIndexPath = IndexPath(item: 0,
                                         section: 0)
        
        let teacherView = collectionView.cellForItem(at: teacherIndexPath)
        
        teacherView?.agora_enable = UIConfig.teacherVideo.enable
        teacherView?.agora_visible = UIConfig.teacherVideo.visible
    }
    
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
