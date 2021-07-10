//
//  AgoraLectureRenderUIController+Data.swift
//  AgoraUIEduAppViews
//
//  Created by Cavan on 2021/4/21.
//

import AgoraEduContext
import AgoraUIBaseViews
import AgoraUIEduBaseViews

extension AgoraLectureRenderUIController {
    func updateCoHosts(with infos: [AgoraEduContextUserDetailInfo]) {
        let newData = [AgoraRenderListItem](list: infos)
        
        coHosts = newData
        renderListView.collectionView.reloadData()
        
        delegate?.renderLectureController(self,
                                          didUpdateCoHosts: infos)
    }
    
    func getUserView(index: Int) -> AgoraUIUserView {
        if (userViews.count - 1) < index {
            let view = AgoraUIUserView(frame: .zero)
            userViews.append(view)
            return view
        } else {
            return userViews[index]
        }
    }
    
    func updateCoHostVolumeIndication(_ value: Int,
                                      streamUuid: String) {
        let index = coHosts.firstIndex { (item) -> Bool in
            return item.userInfo.streamUuid == streamUuid
        }
        
        guard let tIndex = index else {
            return
        }
        
        let item = coHosts[tIndex]
        item.volume = value
        let indexPath = IndexPath(item: tIndex,
                                  section: 0)
        
        guard let cell = renderListView.collectionView.cellForItem(at: indexPath) as? AgoraUserRenderCell else {
            return
        }

        cell.userView?.updateAudio(effect: value)
    }
    
     private func updateListItem(fhs: AgoraRenderListItem,
                                    ths: AgoraRenderListItem) {
        fhs.userInfo.user = ths.userInfo.user
        fhs.userInfo.isSelf = ths.userInfo.isSelf
        fhs.userInfo.streamUuid = ths.userInfo.streamUuid
        fhs.userInfo.onLine = ths.userInfo.onLine
        fhs.userInfo.coHost = ths.userInfo.coHost
        fhs.userInfo.boardGranted = ths.userInfo.boardGranted
        fhs.userInfo.cameraState = ths.userInfo.cameraState
        fhs.userInfo.microState = ths.userInfo.microState
        fhs.userInfo.enableVideo = ths.userInfo.enableVideo
        fhs.userInfo.enableAudio = ths.userInfo.enableAudio
        fhs.userInfo.rewardCount = ths.userInfo.rewardCount
    }
}

fileprivate extension Array where Element == AgoraRenderListItem {
    init(list: [AgoraEduContextUserDetailInfo]) {
        var temp = [AgoraRenderListItem]()
        
        for user in list {
            guard user.coHost else {
                continue
            }
            
            let item = AgoraRenderListItem(userInfo: user,
                                           volume: 0)
            temp.append(item)
        }
        
        self = temp
    }
}
