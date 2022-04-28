//
//  FcrUIModels.swift
//  AgoraClassroomSDK_iOS
//
//  Created by Cavan on 2022/4/26.
//

import AgoraUIBaseViews

struct AgoraRenderMemberViewModel {
    var userId: String
    var userName: String
    var streamId: String?
    var userState: AgoraRenderUserState
    var videoState: AgoraRenderMediaState
    var audioState: AgoraRenderMediaState
    
    static func defaultNilValue() -> AgoraRenderMemberViewModel {
        return AgoraRenderMemberViewModel(userId: "",
                                          userName: "",
                                          streamId: nil,
                                          userState: .none,
                                          videoState: .deviceOff,
                                          audioState: .deviceOff)
    }
}
