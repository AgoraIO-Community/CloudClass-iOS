//
//  AgoraSmallRenderUIController+UIEvent.swift
//  AgoraEduUI
//
//  Created by Cavan on 2021/4/22.
//

import AgoraEduContext
import AgoraUIBaseViews
import AgoraUIEduBaseViews
import AudioToolbox

extension AgoraSmallRenderUIController {
    func updateRenderView(_ isFullScreen: Bool) {
        // 全屏或者没有上台数据的时候
        self.teacherView.alpha = (isFullScreen || teacherInfo == nil ) ? 0 : 1
        self.renderListView.alpha = (isFullScreen || coHosts.count == 0) ? 0 : 1
    }
}

//
extension AgoraSmallRenderUIController {
    public func reloadScrollView() {
        // 遍历view， 如果有
        let superV = self.renderListView.scrollView
        var subVs = [AgoraUIUserView]()
        superV.subviews.forEach { (v) in
            if let `v` = v as? AgoraUIUserView {
                subVs.append(v)
            }
        }
        
        // 需要删除的view
        var removeSubViews = [AgoraUIUserView]()

        // 标记当前针对coHosts对比到哪个
        var queryIndex = 0
        for (index, subV) in subVs.enumerated() {
            if self.coHosts.count <= queryIndex {
                removeSubViews.append(subV)
                continue
            }
            
            let oldItemUid = subV.userUuid
            let newItemUid = self.coHosts[queryIndex].userInfo.userUuid
            if oldItemUid != newItemUid {
                removeSubViews.append(subV)
                continue
            } else {
                // 更新
                upsetCoHost(queryIndex, false)
                queryIndex += 1
            }
        }
        
        // 新增的
        for index in (queryIndex..<self.coHosts.count) {
            upsetCoHost(index, true)
        }

        self.layoutUpdate(removeSubViews)
    }
    
    func upsetCoHost(_ index: Int, _ isInsert: Bool) {
        let superV = self.renderListView.scrollView
        let userInfo = self.coHosts[index].userInfo

        let userV = self.getUserView(index: index)
        userV.index = index
        
        userV.userUuid = userInfo.userUuid
        if userInfo.isOnLine {
//            userV.updateCameraState(userInfo.cameraState.uiType,
//                                    hasStream: userInfo.enableVideo)
        } else {
            userV.updateDefaultDeviceState()
        }

        
//        userV.updateMicState(userInfo.microState.uiType,
//                             hasStream: userInfo.enableAudio,
//                             isLocal: userInfo.isSelf)
        
        
        userV.whiteBoardImageView.isHidden = !userInfo.boardGranted
        userV.updateUserReward(count: userInfo.rewardCount)
        userV.updateUserName(name: userInfo.userName)
        
//        if userInfo.enableVideo {
//            self.renderVideoStream(from: userInfo,
//                                   on: userV.videoCanvas)
//        } else {
//            self.unrenderVideoStream(from: userInfo,
//                                     on: userV.videoCanvas)
//        }
        
        if isInsert {
            superV.addSubview(userV)

            userV.agora_x = (AgoraUserRenderScrollView.preferenceWidth + renderViewGap) * CGFloat(index + 1)
            userV.agora_y = 0
            userV.agora_width = AgoraUserRenderScrollView.preferenceWidth
            userV.agora_height = AgoraUserRenderScrollView.preferenceHeight
        }
    }
    
    func layoutUpdate(_ removeSubViews: [AgoraUIUserView]) {
        let superV = self.renderListView.scrollView
        superV.layoutIfNeeded()
        
        let width: CGFloat = (AgoraUserRenderScrollView.preferenceWidth + renderViewGap) * CGFloat(self.coHosts.count) - renderViewGap
        superV.contentSize = CGSize(width: width, height: superV.agora_height)
        
        // 控制右边按钮
        renderListView.rightButton.isHidden = self.coHosts.count <= Int(renderMaxView)
        
        for (index, value) in self.coHosts.enumerated() {
            let userV = self.getUserView(index: index)
            if userV.superview != nil {
                userV.agora_x = (AgoraUserRenderScrollView.preferenceWidth + renderViewGap) * CGFloat(index)
            }
        }
        
        removeSubViews.forEach { (userV) in
            userV.agora_width = 0
        }
//            insertSubViews.forEach { (userV) in
//                userV.agora_width = AgoraUserRenderScrollView.preferenceWidth
//            }

        UIView.animate(withDuration: 0.6) {
            superV.layoutIfNeeded()
        } completion: { (_) in
            removeSubViews.forEach { $0.removeFromSuperview() }
        }
    }
}

// MARK: - UIScrollViewDelegate, UICollectionViewDelegate
extension AgoraSmallRenderUIController: UIScrollViewDelegate, UICollectionViewDelegate {
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        let condition1 = scrollView.contentOffset.x > 0
        let condition2 = scrollView.contentOffset.x + scrollView.frame.width < scrollView.contentSize.width
        
        let shouldShowLeftRightButton = condition1 && condition2
        renderListView.leftButton.isHidden = !shouldShowLeftRightButton
        renderListView.rightButton.isHidden = !shouldShowLeftRightButton
    }
}

// MARK: - Reward
extension AgoraSmallRenderUIController {
    func rewardAnimation() {
        // Gif
        let rewardImageView = rewardImage()
        
        guard let keyWindow = UIApplication.shared.keyWindow else {
            fatalError()
        }
        
        let isPad = AgoraKitDeviceAssistant.OS.isPad
        
        keyWindow.addSubview(rewardImageView)
        rewardImageView.translatesAutoresizingMaskIntoConstraints = false
        rewardImageView.agora_center_x = 0
        rewardImageView.agora_center_y = 0
        rewardImageView.agora_width = isPad ? 300 : 200
        rewardImageView.agora_height = isPad ? 300 : 200

        // Audio effect
        rewardAudioEffect()
    }
    
    private func rewardImage() -> AgoraFLAnimatedImageView {
        guard let data = rewardGifData else {
            fatalError()
        }
            
        let animatedImage = AgoraFLAnimatedImage(animatedGIFData: data)
        animatedImage?.loopCount = 1
        
        let imageView = AgoraFLAnimatedImageView()
        imageView.animatedImage = animatedImage
        imageView.loopCompletionBlock = {[weak imageView] (count) in
            imageView?.removeFromSuperview()
        }
        
        return imageView
    }
    
    private func rewardAudioEffect() {
        guard let bundle = Bundle.agora_bundle(object: self,
                                               resource: "AgoraEduUI"),
              let url = bundle.url(forResource: "reward",
                                   withExtension: "mp3") else {
            fatalError()
        }
        
        var soundId: SystemSoundID = 0
        AudioServicesCreateSystemSoundID(url as CFURL,
                                         &soundId);
        
        AudioServicesAddSystemSoundCompletion(soundId,
                                              nil,
                                              nil, { (soundId, clientData) -> Void in
                                                AudioServicesDisposeSystemSoundID(soundId)
                                              }, nil)
        
        AudioServicesPlaySystemSound(soundId);
    }
}
