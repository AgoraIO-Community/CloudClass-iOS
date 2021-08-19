//
//  AgoraLectureRenderUIController+UIEvent.swift
//  AgoraUIEduAppViews
//
//  Created by Cavan on 2021/4/22.
//

import AgoraEduContext
import AgoraUIBaseViews
import AgoraUIEduBaseViews
import AudioToolbox

extension AgoraLectureRenderUIController {
    func updateRenderView(_ isFullScreen: Bool,
                          coHostsCount: Int) {
        
        // 全屏的时候， 从1变成0
        self.teacherView.alpha = isFullScreen ? 1 : 0
        // 全屏或者没有上台数据的时候
        self.renderListView.isHidden = false
        self.renderListView.alpha = (isFullScreen || coHostsCount == 0) ? 1 : 0
        
        UIView.animate(withDuration: TimeInterval.agora_animation) {
            self.renderListView.alpha = (isFullScreen || coHostsCount == 0) ? 0 : 1
            self.teacherView.alpha = isFullScreen ? 0 : 1
        }
    }
}

// MARK: - UICollectionViewDataSource
extension AgoraLectureRenderUIController: UICollectionViewDataSource {
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
        
        if userInfo.enableAudio && userInfo.microState != .close {
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
extension AgoraLectureRenderUIController: UIScrollViewDelegate, UICollectionViewDelegate {
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
        
        if indexPath.item >= coHosts.count {
            return
        }
        
        if let item = coHosts[indexPath.item] as? AgoraRenderListItem {
            let userInfo = item.userInfo

            if userInfo.enableVideo {
                renderVideoStream(userInfo.streamUuid,
                                  on: videoCanvas)
            } else {
                unrenderVideoStream(userInfo.streamUuid,
                                    on: videoCanvas)
            }
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
        
        if indexPath.item >= coHosts.count {
            return
        }
        
        if let item = coHosts[indexPath.item] as? AgoraRenderListItem {
            let userInfo = item.userInfo
            unrenderVideoStream(userInfo.streamUuid,
                                on: videoCanvas)
        }
    }
}

// MARK: - AgoraUIUserViewDelegate
extension AgoraLectureRenderUIController: AgoraUIUserViewDelegate {
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
}

// MARK: - Reward
private extension AgoraLectureRenderUIController {
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
