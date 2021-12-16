//
//  AgoraMembersHorizeRenderUIController.swift
//  AgoraEduUI
//
//  Created by Jonathan on 2021/12/10.
//

import AgoraUIEduBaseViews
import AgoraUIBaseViews
import AgoraEduContext
import AudioToolbox
import AgoraWidget
import Foundation
import Masonry
import UIKit

private let kItemGap: CGFloat = AgoraFit.scale(4)
private let kTeacherIndex: IndexPath = IndexPath(row: -1, section: 0)
class AgoraMembersHorizeRenderUIController: UIViewController {
    
    weak var delegate: AgoraPaintingRenderUIControllerDelegate?
    
    public var themeColor: UIColor?
    
    var contentView: UIView!
        
    var teacherView: AgoraRenderMemberView!
    
    var collectionView: UICollectionView!
    
    var leftButton: UIButton!
    
    var rightButton: UIButton!
        
    var contextPool: AgoraEduContextPool!
    
    var teacherModel: AgoraRenderMemberModel? {
        didSet {
            teacherView.setModel(model: teacherModel, delegate: self)
            teacherView.isHidden = (teacherModel == nil)
            self.reloadData()
        }
    }
    
    var dataSource = [AgoraRenderMemberModel]() {
        didSet {
            collectionView.isHidden = (dataSource.count == 0)
            if dataSource.count != oldValue.count {
            }
            self.reloadData()
        }
    }
    /** 用来记录当前流是否被老师操作*/
    var currentStream: AgoraEduContextStreamInfo? {
        didSet {
            streamChanged(from: oldValue, to: currentStream)
        }
    }
    
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
        contextPool.user.registerUserEventHandler(self)
        contextPool.stream.registerStreamEventHandler(self)
        contextPool.room.registerRoomEventHandler(self)
    }
}

// MARK: - Actions
extension AgoraMembersHorizeRenderUIController {
    @objc func onDoubleClick(_ sender: UITapGestureRecognizer) {
        
    }
    
    @objc func onClickTeacher(_ sender: UITapGestureRecognizer) {
        
        
    }
    
    @objc func onDoubleClickTeacher(_ sender: UITapGestureRecognizer) {
        
    }
    
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
// MARK: - Private
private extension AgoraMembersHorizeRenderUIController {
    func setup() {
        if let teacher = contextPool.user.getUserList(role: .teacher)?.first {
            self.teacherModel = AgoraRenderMemberModel.model(with: contextPool,
                                                             uuid: teacher.userUuid,
                                                             name: teacher.userName,
                                                             role: .teacher)
        }
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
        }
        self.reloadData()
    }
    
    // 更新视图
    func reloadData() {
        let sigleWidth = (self.view.bounds.width + kItemGap) / 7 - kItemGap
        let teacherWidth = (teacherModel == nil) ? 0 : sigleWidth
        if teacherView.width != teacherWidth {
            teacherView.mas_remakeConstraints { make in
                make?.top.left().bottom().equalTo()(contentView)
                make?.width.equalTo()(teacherWidth)
            }
        }
        // 最多显示六个学生
        let f_count = CGFloat(self.dataSource.count > 6 ? 6: self.dataSource.count)
        let studentWidth = (sigleWidth + kItemGap) * f_count - kItemGap
        if collectionView.width != studentWidth {
            collectionView.mas_remakeConstraints { make in
                make?.right.top().bottom().equalTo()(contentView)
                make?.left.equalTo()(teacherView.mas_right)?.offset()(kItemGap)
                make?.width.equalTo()(studentWidth)
            }
        }
        let pageEnable = (self.dataSource.count <= 6)
        self.leftButton.isHidden = pageEnable
        self.rightButton.isHidden = pageEnable
        collectionView.reloadData()
    }
    
    func streamChanged(from: AgoraEduContextStreamInfo?, to: AgoraEduContextStreamInfo?) {
        guard let fromStream = from, let toStream = to else {
            return
        }
        if fromStream.streamType.hasAudio, !toStream.streamType.hasAudio {
            AgoraToast.toast(msg: AgoraUILocalizedString("MicrophoneMuteText", object: self))
        } else if !fromStream.streamType.hasAudio, toStream.streamType.hasAudio {
            AgoraToast.toast(msg: AgoraUILocalizedString("MicrophoneUnMuteText", object: self))
        }
        if fromStream.streamType.hasVideo, !toStream.streamType.hasVideo {
            AgoraToast.toast(msg: AgoraUILocalizedString("CameraMuteText", object: self))
        } else if !fromStream.streamType.hasVideo, toStream.streamType.hasVideo {
            AgoraToast.toast(msg: AgoraUILocalizedString("CameraUnMuteText", object: self))
        }
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
// MARK: - AgoraEduUserHandler
extension AgoraMembersHorizeRenderUIController: AgoraEduUserHandler {
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
    
    func onRemoteUserJoined(user: AgoraEduContextUserInfo) {
        if user.role == .teacher {
            self.teacherModel = AgoraRenderMemberModel.model(with: contextPool,
                                                             uuid: user.userUuid,
                                                             name: user.userName,
                                                             role: .teacher)
        }
    }
    
    func onRemoteUserLeft(user: AgoraEduContextUserInfo,
                          operatorUser: AgoraEduContextUserInfo?,
                          reason: AgoraEduContextUserLeaveReason) {
        if user.role == .teacher {
            self.teacherModel = nil
        }
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

// MARK: - AgoraEduMediaHandler
extension AgoraMembersHorizeRenderUIController: AgoraEduMediaHandler {
    func onVolumeUpdated(volume: Int,
                         streamUuid: String) {
        if teacherModel?.streamID == streamUuid {
            teacherModel?.volume = volume
        } else {
            let model = self.dataSource.first { $0.streamID == streamUuid }
            model?.volume = volume
        }
    }
}

// MARK: - AgoraEduStreamHandler
extension AgoraMembersHorizeRenderUIController: AgoraEduStreamHandler {
    func onStreamUpdated(stream: AgoraEduContextStreamInfo,
                         operatorUser: AgoraEduContextUserInfo?) {
        guard stream.videoSourceType != .screen else {
            return
        }
        
        if let model = teacherModel,
           stream.owner.userUuid == model.uuid {
            model.updateStream(stream)
        } else {
            for model in self.dataSource {
                if stream.owner.userUuid == model.uuid {
                    model.updateStream(stream)
                }
            }
        }
    }
}

// MARK: - AgoraEduRoomHandler
extension AgoraMembersHorizeRenderUIController: AgoraEduRoomHandler {
    func onRoomJoinedSuccess(roomInfo: AgoraEduContextRoomInfo) {
        self.setup()
    }
}

// MARK: - AgoraRenderMemberViewDelegate
extension AgoraMembersHorizeRenderUIController: AgoraRenderMemberViewDelegate {
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
extension AgoraMembersHorizeRenderUIController: UICollectionViewDelegate,
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
        let model = self.dataSource[indexPath.row]
        cell.renderView.setModel(model: model, delegate: self)
        return cell
    }
    
    public func collectionView(_ collectionView: UICollectionView,
                               didSelectItemAt indexPath: IndexPath) {
        collectionView.deselectItem(at: indexPath, animated: false)
        let u = dataSource[indexPath.row]
        if let cell = collectionView.cellForItem(at: indexPath),
           let uuid = u.uuid {
            delegate?.onClickMemberAt(view: cell, UUID: uuid)
        }
    }
    
    public func collectionView(_ collectionView: UICollectionView,
                               layout collectionViewLayout: UICollectionViewLayout,
                               sizeForItemAt indexPath: IndexPath) -> CGSize {
        let itemWidth = (view.bounds.width + kItemGap) / 7.0 - kItemGap
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
private extension AgoraMembersHorizeRenderUIController {
    func createViews() {
        contentView = UIView()
        view.addSubview(contentView)
        
        teacherView = AgoraRenderMemberView(frame: .zero)
        teacherView.layer.cornerRadius = AgoraFit.scale(2)
        teacherView.clipsToBounds = true
        teacherView.isHidden = true
        contentView.addSubview(teacherView)
        let doubleTapTeacher = UITapGestureRecognizer(target: self,
                                                      action: #selector(onDoubleClickTeacher(_:)))
        doubleTapTeacher.numberOfTapsRequired = 2
        doubleTapTeacher.numberOfTouchesRequired = 1
        doubleTapTeacher.delaysTouchesBegan = true
        teacherView.addGestureRecognizer(doubleTapTeacher)
        
        let tapTeacher = UITapGestureRecognizer(target: self,
                                                action: #selector(onClickTeacher(_:)))
        tapTeacher.numberOfTapsRequired = 1
        tapTeacher.numberOfTouchesRequired = 1
        tapTeacher.delaysTouchesBegan = true
        teacherView.addGestureRecognizer(tapTeacher)
        // 优先检测双击
        tapTeacher.require(toFail: doubleTapTeacher)
        
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .horizontal
        collectionView = AgoraBaseUICollectionView(frame: .zero,
                                                   collectionViewLayout: layout)
        collectionView.showsHorizontalScrollIndicator = false
        collectionView.showsVerticalScrollIndicator = false
        collectionView.delegate = self
        collectionView.dataSource = self
        collectionView.backgroundColor = .clear
        collectionView.isScrollEnabled = false
        collectionView.register(cellWithClass: AgoraRenderMemberCell.self)
        contentView.addSubview(collectionView)
        
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
        contentView.addSubview(leftButton)
        
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
        contentView.addSubview(rightButton)
        
        let tap = UITapGestureRecognizer.init(target: self, action: #selector(onDoubleClick(_:)))
        tap.numberOfTapsRequired = 2
        tap.numberOfTouchesRequired = 1
        tap.delaysTouchesBegan = true
        collectionView.addGestureRecognizer(tap)
    }
    
    func createConstrains() {
        contentView.mas_makeConstraints { make in
            make?.centerX.equalTo()(0)
            make?.top.equalTo()(0)
            make?.bottom.equalTo()(0)
        }
        collectionView.mas_makeConstraints { make in
            make?.right.top().bottom().equalTo()(0)
            make?.left.equalTo()(contentView.mas_right)
        }
        leftButton.mas_makeConstraints { make in
            make?.left.top().bottom().equalTo()(collectionView)
            make?.width.equalTo()(24)
        }
        rightButton.mas_makeConstraints { make in
            make?.right.top().bottom().equalTo()(collectionView)
            make?.width.equalTo()(24)
        }
        teacherView.mas_makeConstraints { make in
            make?.left.right().top().bottom().equalTo()(0)
        }
    }
}
