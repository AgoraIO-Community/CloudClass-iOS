//
//  AgoraPrivateChatController.swift
//  AgoraEduUI
//
//  Created by SRS on 2021/4/18.
//

import AgoraUIEduBaseViews
import AgoraUIBaseViews
import AgoraEduContext

class AgoraPrivateChatController: NSObject, AgoraController {
    private(set) var viewType: AgoraEduContextRoomType
    private weak var contextProvider: AgoraControllerContextProvider?
    
    init(viewType: AgoraEduContextRoomType,
         contextProvider: AgoraControllerContextProvider) {

        self.viewType = viewType
        self.contextProvider = contextProvider
        super.init()
    }
}
