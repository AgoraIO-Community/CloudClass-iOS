//
//  AgoraSmallRenderUIController+UIEvent.swift
//  AgoraUIEduAppViews
//
//  Created by Cavan on 2021/4/22.
//

import AgoraEduContext
import AgoraUIBaseViews
import AgoraUIEduBaseViews
import AudioToolbox

extension AgoraSmallRenderUIController {
    func updateRenderView(_ isFullScreen: Bool,
                          coHostsCount: Int) {
        UIView.animate(withDuration: TimeInterval.agora_animation) {
            self.renderListView.alpha = (isFullScreen || coHostsCount == 0) ? 0 : 1
            self.teacherView.alpha = isFullScreen ? 0 : 1
        } completion: { (_) in
            self.renderListView.isHidden = (isFullScreen || coHostsCount == 0)
            self.teacherView.isHidden = isFullScreen
        }
    }
}

// MARK: - UICollectionViewDataSource
extension AgoraSmallRenderUIController: UICollectionViewDataSource {
    public func collectionView(_ collectionView: UICollectionView,
                               numberOfItemsInSection section: Int) -> Int {
        return self.coHosts.count
    }
    
    public func collectionView(_ collectionView: UICollectionView,
                               cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "AgoraUserRenderCell",
                                                      for: indexPath) as! AgoraUserRenderCell
        let userView = getUserView(index: indexPath.item)
        let item = coHosts[indexPath.item]
        let userInfo = item.userInfo
        userView.delegate = self
        userView.index = indexPath.item
        userView.update(with: userInfo)
        
        if userInfo.enableAudio {
            userView.updateAudio(effect: item.volume)
        }
        
        cell.userView = userView
        
        if userInfo.enableVideo {
            renderVideoStream(userInfo.streamUuid,
                              on: userView.videoCanvas)
        } else {
            unrenderVideoStream(userInfo.streamUuid,
                                on: userView.videoCanvas)
        }
        
        return cell
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
    
    func collectionView(_ collectionView: UICollectionView,
                        willDisplay cell: UICollectionViewCell,
                        forItemAt indexPath: IndexPath) {
        let userInteractionEvent = (collectionView.isDragging || collectionView.isDecelerating || collectionView.isTracking)
        
        guard let tCell = cell as? AgoraUserRenderCell,
              let videoCanvas = tCell.userView?.videoCanvas,
              userInteractionEvent else {
            return
        }
        
        let item = coHosts[indexPath.item]
        let userInfo = item.userInfo

        if userInfo.enableVideo {
            renderVideoStream(userInfo.streamUuid,
                              on: videoCanvas)
        } else {
            unrenderVideoStream(userInfo.streamUuid,
                                on: videoCanvas)
        }
    }
    
    func collectionView(_ collectionView: UICollectionView,
                        didEndDisplaying cell: UICollectionViewCell,
                        forItemAt indexPath: IndexPath) {
        let userInteractionEvent = (collectionView.isDragging || collectionView.isDecelerating || collectionView.isTracking)
        
        guard let tCell = cell as? AgoraUserRenderCell,
              let videoCanvas = tCell.userView?.videoCanvas,
              userInteractionEvent else {
            return
        }
        
        let item = coHosts[indexPath.item]
        let userInfo = item.userInfo
        unrenderVideoStream(userInfo.streamUuid,
                            on: videoCanvas)
    }
}

// MARK: - AgoraUIUserViewDelegate
extension AgoraSmallRenderUIController: AgoraUIUserViewDelegate {
    func userView(_ userView: AgoraUIUserView,
                  didPressAudioButton button: AgoraBaseUIButton,
                  indexOfUserList index: Int) {
        switch index {
        case teacherIndex:
            guard let info = teacherInfo,
                  info.isSelf else {
                return
            }
            
            button.isSelected.toggle()
            let isMuted = button.isSelected
            userContext?.muteAudio(isMuted)
        default:
            let studentInfo = coHosts[index].userInfo
            guard studentInfo.isSelf else {
                return
            }

            button.isSelected.toggle()
            let isMuted = button.isSelected
            userContext?.muteAudio(isMuted)
        }
    }
    
    func userView(_ userView: AgoraUIUserView,
                  didPressVideoButton button: AgoraBaseUIButton,
                  indexOfUserList index: Int) {
        switch index {
        case teacherIndex:
            guard let info = teacherInfo,
                  info.isSelf else {
                return
            }
            
            button.isSelected.toggle()
            userContext?.muteVideo(button.isSelected)
        default:
            let studentInfo = coHosts[index].userInfo
            guard studentInfo.isSelf else {
                return
            }

            button.isSelected.toggle()
            userContext?.muteVideo(button.isSelected)
        }
    }
}

// MARK: - Reward
private extension AgoraSmallRenderUIController {
    internal func rewardAnimation() {
        // Gif
        rewardImageView = rewardImage()
        
        guard let `rewardImageView` = rewardImageView,
              let keyWindow = UIApplication.shared.keyWindow else {
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
    
    func rewardImage() -> AgoraFLAnimatedImageView {
        guard let bundle = Bundle.agora_bundle(object: self,
                                               resource: "AgoraUIEduAppViews"),
              let url = bundle.url(forResource: "reward",
                                   withExtension: "gif"),
              let data = try? Data(contentsOf: url) else {
            fatalError()
        }
            
        let animatedImage = AgoraFLAnimatedImage(animatedGIFData: data)
        animatedImage?.loopCount = 1
        
        let imageView = AgoraFLAnimatedImageView()
        imageView.animatedImage = animatedImage
        imageView.loopCompletionBlock = { (count) in
            imageView.removeFromSuperview()
        }
        
        return imageView
    }
    
    func rewardAudioEffect() {
        guard let bundle = Bundle.agora_bundle(object: self,
                                               resource: "AgoraUIEduAppViews"),
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
