//
//  FcrProctorScene.swift
//  AgoraEduUI
//
//  Created by LYY on 2022/8/31.
//

import AgoraUIBaseViews
import AgoraEduContext

/* userName
 userUuid
 roomName
 roomUuid
*/

class FcrProctorUIScene: UIViewController {
    
    let contextPool: AgoraEduContextPool
    
    @objc public init(contextPool: AgoraEduContextPool) {
        self.contextPool = contextPool
      
        super.init(nibName: nil,
                   bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
