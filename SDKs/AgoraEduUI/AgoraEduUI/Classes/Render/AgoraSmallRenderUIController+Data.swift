//
//  AgoraSmallRenderUIController+Data.swift
//  AgoraEduUI
//
//  Created by Cavan on 2021/4/21.
//

import AgoraEduContext
import AgoraUIBaseViews
import AgoraUIEduBaseViews

extension AgoraSmallRenderUIController {
    func updateCoHosts(with infos: [AgoraEduContextUserDetailInfo]) {
        if let _ = infos.first(where: {$0.isLocal}) {
            isCoHost = true
        } else {
            isCoHost = false
        }
        
        let newData = [AgoraRenderListItem](list: infos)
        coHosts = newData
        
        var views = [String : AgoraUIUserView]()
        coHosts.forEach { (item) in
            let userUuid = item.userInfo.userUuid
            if let v = userViews[userUuid] {
                views[userUuid] = v
            }
        }
        userViews = views
        
        reloadScrollView()
        
        delegate?.renderSmallController(self,
                                        didUpdateCoHosts: infos)
    }
    
    func getUserView(index: Int) -> AgoraUIUserView {
        let userUuid = coHosts[index].userInfo.userUuid
        if let v = userViews[userUuid] {
            return v
        }
        
        let view = AgoraUIUserView(frame: .zero)
        userViews[userUuid] = view
        return view
    }
    
    func updateCoHostVolumeIndication(_ value: Int,
                                      streamUuid: String) {
//        let index = coHosts.firstIndex { (item) -> Bool in
//            return item.userInfo.streamUuid == streamUuid
//        }
//
//        guard let tIndex = index else {
//            return
//        }
//
//        let userUuid = coHosts[tIndex].userInfo.userUuid
//        if let v = self.userViews[userUuid] {
//            v.updateAudio(effect: value)
//        }
    }
    
//     private func updateListItem(fhs: AgoraRenderListItem,
//                                    ths: AgoraRenderListItem) {
//        fhs.userInfo.user = ths.userInfo.user
//        fhs.userInfo.isSelf = ths.userInfo.isSelf
//        fhs.userInfo.streamUuid = ths.userInfo.streamUuid
//        fhs.userInfo.onLine = ths.userInfo.onLine
//        fhs.userInfo.coHost = ths.userInfo.coHost
//        fhs.userInfo.boardGranted = ths.userInfo.boardGranted
//        fhs.userInfo.cameraState = ths.userInfo.cameraState
//        fhs.userInfo.microState = ths.userInfo.microState
//        fhs.userInfo.enableVideo = ths.userInfo.enableVideo
//        fhs.userInfo.enableAudio = ths.userInfo.enableAudio
//        fhs.userInfo.rewardCount = ths.userInfo.rewardCount
//    }
}

//fileprivate extension AgoraEduContextUserDetailInfo {
//    static func ==(lhs: AgoraEduContextUserDetailInfo,
//            rhs: AgoraEduContextUserDetailInfo) -> Bool {
//        let lhsUser = lhs.user
//        let rhsUser = rhs.user
//
//        guard lhsUser === rhsUser
//              && lhsUser.userUuid == rhsUser.userUuid else {
//            return false
//        }
//
//        guard lhs.onLine == rhs.onLine
//                && lhs.coHost == rhs.coHost
//                && lhs.boardGranted == rhs.boardGranted
//                && lhs.cameraState == rhs.cameraState
//                && lhs.microState == rhs.microState
//                && lhs.enableVideo == rhs.enableVideo
//                && lhs.enableAudio == rhs.enableAudio
//                && lhs.rewardCount == rhs.rewardCount else {
//                return false
//        }
//
//        return true
//    }
//}

fileprivate extension Array where Element == AgoraRenderListItem {
    init(list: [AgoraEduContextUserDetailInfo]) {
        var temp = [AgoraRenderListItem]()
        
        for user in list {
            guard user.isLocal else {
                continue
            }
            
            let item = AgoraRenderListItem(userInfo: user,
                                           volume: 0)
            temp.append(item)
        }
        
        self = temp
    }
}
