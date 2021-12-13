//
//  AgoraStudentsRenderUIController.swift
//  AgoraEduUI
//
//  Created by Jonathan on 2021/12/9.
//

import UIKit
import AudioToolbox
import AgoraEduContext
import AgoraUIBaseViews
import AgoraUIEduBaseViews

private let kItemGap: CGFloat = AgoraFit.scale(2)
private let kItemMaxCount: CGFloat = 4
class AgoraStudentsRenderUIController: UIViewController {
        
    var collectionView: UICollectionView!    
    
    var leftButton: UIButton!
    
    var rightButton: UIButton!
    
    var dataSource = [AgoraRenderMemberModel]()
    
    var contextPool: AgoraEduContextPool!
    
    init(context: AgoraEduContextPool) {
        super.init(nibName: nil, bundle: nil)
        contextPool = context
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        
        createViews()
        createConstrains()
        
        contextPool.user.registerEventHandler(self)
        contextPool.stream.registerStreamEventHandler(self)
        contextPool.room.registerRoomEventHandler(self)
        contextPool.media.registerMediaEventHandler(self)
    }
}
// MARK: - Private
private extension AgoraStudentsRenderUIController {
    func setup() {
        if let students = contextPool.user.getCoHostList()?.filter({$0.role == .student}) {
            var temp = [AgoraRenderMemberModel]()
            for student in students {
                let model = AgoraRenderMemberModel.model(with: contextPool,
                                                         uuid: student.userUuid,
                                                         name: student.userName,
                                                         role: .student)
                temp.append(model)
            }
            dataSource = temp
            self.reloadData()
        }
    }
    
    func reloadData() {
        let sigleWidth = (self.view.bounds.width + kItemGap) / kItemMaxCount - kItemGap
        let floatCount = CGFloat(self.dataSource.count)
        let count = floatCount > kItemMaxCount ? kItemMaxCount: floatCount
        let width = (sigleWidth + kItemGap) * count - kItemGap
        if collectionView.width != width {
            collectionView.mas_updateConstraints { make in
                make?.width.equalTo()(width)
            }
        }
        let pageEnable = floatCount <= kItemMaxCount
        self.leftButton.isHidden = pageEnable
        self.rightButton.isHidden = pageEnable
        collectionView.reloadData()
    }
    
    func showRewardAnimation() {
        guard let b = Bundle.ag_compentsBundleWithClass(self.classForCoder),
              let url = b.url(forResource: "reward", withExtension: "gif"),
              let data = try? Data(contentsOf: url) else {
            return
        }
        let animatedImage = AgoraFLAnimatedImage(animatedGIFData: data)
        animatedImage?.loopCount = 1
        let imageView = AgoraFLAnimatedImageView()
        imageView.animatedImage = animatedImage
        imageView.loopCompletionBlock = {[weak imageView] (loopCountRemaining) -> Void in
            imageView?.removeFromSuperview()
        }
        if let window = UIApplication.shared.keyWindow {
            window.addSubview(imageView)
            imageView.mas_makeConstraints { make in
                make?.center.equalTo()(0)
                make?.width.equalTo()(AgoraFit.scale(238))
                make?.height.equalTo()(AgoraFit.scale(238))
            }
        }
        // sounds
        guard let rewardUrl = b.url(forResource: "reward", withExtension: "mp3") else {
            return
        }
        var soundId: SystemSoundID = 0;
        AudioServicesCreateSystemSoundID(rewardUrl as CFURL,
                                         &soundId);
        AudioServicesAddSystemSoundCompletion(soundId, nil, nil, {
            (soundId, clientData) -> Void in
            AudioServicesDisposeSystemSoundID(soundId)
        }, nil)
        AudioServicesPlaySystemSound(soundId)
    }
}
// MARK: - Action
extension AgoraStudentsRenderUIController {
    @objc func onClickLeft(_ sender: UIButton) {
        let idxs = collectionView.indexPathsForVisibleItems
        if let min = idxs.min(),
           min.row > 0 {
            let previous = IndexPath(row: min.row - 1 , section: 0)
            collectionView.scrollToItem(at: previous, at: .left, animated: true)
        }
    }
    
    @objc func onClickRight(_ sender: UIButton) {
        let idxs = collectionView.indexPathsForVisibleItems
        if let max = idxs.max(),
           max.row < dataSource.count - 1 {
            let next = IndexPath(row: max.row + 1 , section: 0)
            collectionView.scrollToItem(at: next, at: .right, animated: true)
        }
    }
}
// MARK: - AgoraEduUserHandler
extension AgoraStudentsRenderUIController: AgoraEduUserHandler {
    func onCoHostUserListAdded(userList: [AgoraEduContextUserInfo],
                               operatorUser: AgoraEduContextUserInfo?) {
        for user in userList {
            if user.role == .student {
                let model = AgoraRenderMemberModel.model(with: contextPool,
                                                         uuid: user.userUuid,
                                                         name: user.userName,
                                                         role: .student)
                dataSource.append(model)
            }
        }
        reloadData()
    }
    
    func onCoHostUserListRemoved(userList: [AgoraEduContextUserInfo],
                                 operatorUser: AgoraEduContextUserInfo?) {
        for user in userList {
            if user.role == .student {
                dataSource.removeAll(where: {$0.uuid == user.userUuid})
            }
        }
        reloadData()
    }
    
    func onUserHandsWave(user: AgoraEduContextUserInfo,
                         duration: Int) {
        if let model = dataSource.first(where: {$0.uuid == user.userUuid}) {
            model.isHandsUp = true
        }
    }
    
    func onUserHandsDown(user: AgoraEduContextUserInfo) {
        if let model = dataSource.first(where: {$0.uuid == user.userUuid}) {
            model.isHandsUp = false
        }
    }
    
    func onUserRewarded(user: AgoraEduContextUserInfo,
                        rewardCount: Int,
                        operatorUser: AgoraEduContextUserInfo?) {
        if let model = dataSource.first(where: {$0.uuid == user.userUuid}) {
            model.rewardCount = rewardCount
        }
        showRewardAnimation()
    }
}
// MARK: - AgoraEduStreamHandler
extension AgoraStudentsRenderUIController: AgoraEduStreamHandler {
    func onStreamUpdated(stream: AgoraEduContextStreamInfo,
                         operator: AgoraEduContextUserInfo?) {
        for model in self.dataSource {
            if stream.owner.userUuid == model.uuid {
                model.updateStream(stream)
            }
        }
    }
}
// MARK: - AgoraEduMediaHandler
extension AgoraStudentsRenderUIController: AgoraEduMediaHandler {
    func onVolumeUpdated(volume: Int,
                         streamUuid: String) {
        for model in self.dataSource {
            if streamUuid == model.streamID {
                model.volume = volume
            }
        }
    }
}
// MARK: - AgoraEduRoomHandler
extension AgoraStudentsRenderUIController: AgoraEduRoomHandler {
    func onRoomJoinedSuccess(roomInfo: AgoraEduContextRoomInfo) {
        self.setup()
    }
}
// MARK: - AgoraRenderMemberViewDelegate
extension AgoraStudentsRenderUIController: AgoraRenderMemberViewDelegate {
    func memberViewRender(memberView: AgoraRenderMemberView,
                          in view: UIView,
                          renderID: String) {
        let renderConfig = AgoraEduContextRenderConfig()
        renderConfig.mode = .hidden
        contextPool.stream.setRemoteVideoStreamSubscribeLevel(streamUuid: renderID,
                                                              level: .low)
        contextPool.media.startRenderVideo(view: view,
                                           renderConfig: renderConfig,
                                           streamUuid: renderID)
    }

    func memberViewCancelRender(memberView: AgoraRenderMemberView, renderID: String) {
        contextPool.media.stopRenderVideo(streamUuid: renderID)
    }
}

// MARK: - UICollectionView Call Back
extension AgoraStudentsRenderUIController: UICollectionViewDelegate,
                                           UICollectionViewDataSource,
                                           UICollectionViewDelegateFlowLayout {
    public func collectionView(_ collectionView: UICollectionView,
                               numberOfItemsInSection section: Int) -> Int {
        return self.dataSource.count
    }
    
    public func collectionView(_ collectionView: UICollectionView,
                               cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withClass: AgoraRenderMemberCell.self,
                                                      for: indexPath)
        let item = self.dataSource[indexPath.row]
        cell.renderView.setModel(model: item, delegate: self)
        return cell
    }
    
    public func collectionView(_ collectionView: UICollectionView,
                               didSelectItemAt indexPath: IndexPath) {
        collectionView.deselectItem(at: indexPath, animated: false)
        let u = dataSource[indexPath.row]
//        if let cell = collectionView.cellForItem(at: indexPath),
//           let UUID = u.userUUID {
//            delegate?.onClickMemberAt(view: cell, UUID: UUID)
//        }
    }
    
    public func collectionView(_ collectionView: UICollectionView,
                               layout collectionViewLayout: UICollectionViewLayout,
                               sizeForItemAt indexPath: IndexPath) -> CGSize {
        let itemWidth = (view.bounds.width + kItemGap) / kItemMaxCount - kItemGap
        return CGSize(width: itemWidth, height: collectionView.bounds.height)
    }
    
    public func collectionView(_ collectionView: UICollectionView,
                               layout collectionViewLayout: UICollectionViewLayout,
                               minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return kItemGap
    }
    
    public func collectionView(_ collectionView: UICollectionView,
                               layout collectionViewLayout: UICollectionViewLayout,
                               insetForSectionAt section: Int) -> UIEdgeInsets {
        return .zero
    }
}
// MARK: - Creations
private extension AgoraStudentsRenderUIController {
    func createViews() {
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .horizontal
        collectionView = UICollectionView(frame: .zero,
                                          collectionViewLayout: layout)
        collectionView.showsHorizontalScrollIndicator = false
        collectionView.showsVerticalScrollIndicator = false
        collectionView.delegate = self
        collectionView.dataSource = self
        collectionView.backgroundColor = .clear
        collectionView.isScrollEnabled = false
        collectionView.register(cellWithClass: AgoraRenderMemberCell.self)
        view.addSubview(collectionView)
        
        leftButton = UIButton(type: .custom)
        leftButton.isHidden = true
        leftButton.layer.cornerRadius = 2.0
        leftButton.clipsToBounds = true
        leftButton.backgroundColor = UIColor.black.withAlphaComponent(0.3)
        leftButton.addTarget(self,
                             action: #selector(onClickLeft(_:)),
                             for: .touchUpInside)
        leftButton.setImage(UIImage.ag_imageNamed("ic_member_arrow_left", in: "AgoraEduUI"),
                            for: .normal)
        view.addSubview(leftButton)
        
        rightButton = UIButton(type: .custom)
        rightButton.isHidden = true
        rightButton.layer.cornerRadius = 2.0
        rightButton.clipsToBounds = true
        rightButton.backgroundColor = UIColor.black.withAlphaComponent(0.3)
        rightButton.addTarget(self,
                              action: #selector(onClickRight(_:)),
                              for: .touchUpInside)
        rightButton.setImage(UIImage.ag_imageNamed("ic_member_arrow_right", in: "AgoraEduUI"),
                             for: .normal)
        view.addSubview(rightButton)
    }
    
    func createConstrains() {
        collectionView.mas_makeConstraints { make in
            make?.centerX.top().bottom().equalTo()(0)
            make?.width.equalTo()(0)
        }
        leftButton.mas_makeConstraints { make in
            make?.left.top().bottom().equalTo()(collectionView)
            make?.width.equalTo()(24)
        }
        rightButton.mas_makeConstraints { make in
            make?.right.top().bottom().equalTo()(collectionView)
            make?.width.equalTo()(24)
        }
    }
}
