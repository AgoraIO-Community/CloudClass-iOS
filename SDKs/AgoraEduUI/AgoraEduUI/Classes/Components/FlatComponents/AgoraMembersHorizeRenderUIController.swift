//
//  AgoraMembersHorizeRenderUIController.swift
//  AgoraEduUI
//
//  Created by Jonathan on 2021/12/10.
//

import AgoraUIBaseViews
import AgoraEduContext
import FLAnimatedImage
import AudioToolbox
import AgoraWidget
import Foundation
import Masonry
import UIKit

protocol AgoraRenderUIControllerDelegate: NSObjectProtocol {
    func onClickMemberAt(view: UIView,
                         UUID: String)
    
    func onRequestSpread(firstOpen: Bool,
                         userId: String,
                         streamId: String,
                         fromView: UIView,
                         xaxis: CGFloat,
                         yaxis: CGFloat,
                         width: CGFloat,
                         height: CGFloat)
}

private let kItemGap: CGFloat = AgoraFit.scale(4)
private let kTeacherIndex: IndexPath = IndexPath(row: -1,
                                                 section: 0)
class AgoraMembersHorizeRenderUIController: UIViewController {
    
    weak var delegate: AgoraRenderUIControllerDelegate?
    
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
        createConstraint()
        contextPool.user.registerUserEventHandler(self)
        contextPool.stream.registerStreamEventHandler(self)
        contextPool.room.registerRoomEventHandler(self)
        contextPool.media.registerMediaEventHandler(self)
    }
    
    public func renderViewForUser(with userId: String) -> UIView? {
        if teacherModel?.uuid == userId {
            return teacherView
        } else {
            var view: UIView?
            let indexes = self.collectionView.indexPathsForVisibleItems
            for (i, model) in self.dataSource.enumerated() {
                if model.uuid == userId {
                    if let indexPath = indexes.first(where: {$0.row == i}) {
                        view = self.collectionView.cellForItem(at: indexPath)
                    }
                    break
                }
            }
            return view
        }
    }
    
    public func setRenderEnable(with userId: String, rendEnable: Bool) {
        if let model = self.teacherModel,
           model.uuid == userId {
            model.rendEnable = rendEnable
        } else if let model = self.dataSource.first(where: {$0.uuid == userId}) {
            model.rendEnable = rendEnable
        }
    }
}

// MARK: - Actions
extension AgoraMembersHorizeRenderUIController {
    @objc func onDoubleClick(_ sender: UITapGestureRecognizer) {
        
    }
    
    @objc func onClickTeacher(_ sender: UITapGestureRecognizer) {
        if let uuid = teacherModel?.uuid {
            delegate?.onClickMemberAt(view: teacherView,
                                      UUID: uuid)
        }
        
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
                                                             name: teacher.userName)
        }
        if let students = contextPool.user.getCoHostList()?.filter({$0.userRole == .student}) {
            var temp = [AgoraRenderMemberModel]()
            for student in students {
                let model = AgoraRenderMemberModel.model(with: contextPool,
                                                         uuid: student.userUuid,
                                                         name: student.userName)
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
    
    func updateStream(stream: AgoraEduContextStreamInfo?) {
        guard stream?.videoSourceType != .screen else {
            return
        }
        if let model = teacherModel,
           stream?.owner.userUuid == model.uuid {
            model.updateStream(stream)
        } else {
            for model in self.dataSource {
                if stream?.owner.userUuid == model.uuid {
                    model.updateStream(stream)
                }
            }
        }
    }
    
    func streamChanged(from: AgoraEduContextStreamInfo?, to: AgoraEduContextStreamInfo?) {
        guard let fromStream = from, let toStream = to else {
            return
        }
        if fromStream.streamType.hasAudio, !toStream.streamType.hasAudio {
            AgoraToast.toast(msg: "MicrophoneMuteText".agedu_localized())
        } else if !fromStream.streamType.hasAudio, toStream.streamType.hasAudio {
            AgoraToast.toast(msg: "MicrophoneUnMuteText".agedu_localized())
        }
        if fromStream.streamType.hasVideo, !toStream.streamType.hasVideo {
            AgoraToast.toast(msg: "CameraMuteText".agedu_localized())
        } else if !fromStream.streamType.hasVideo, toStream.streamType.hasVideo {
            AgoraToast.toast(msg: "CameraUnMuteText".agedu_localized())
        }
    }
    
    func showRewardAnimation() {
        guard let url = Bundle.agoraEduUI().url(forResource: "img_reward", withExtension: "gif"),
              let data = try? Data(contentsOf: url) else {
            return
        }
        let animatedImage = FLAnimatedImage(animatedGIFData: data)
        let imageView = FLAnimatedImageView()
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
        guard let rewardUrl = Bundle.agoraEduUI().url(forResource: "sound_reward", withExtension: "mp3") else {
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
            if user.userRole == .student {
                let model = AgoraRenderMemberModel.model(with: contextPool,
                                                         uuid: user.userUuid,
                                                         name: user.userName)
                dataSource.append(model)
            }
        }
        reloadData()
    }
    
    func onCoHostUserListRemoved(userList: [AgoraEduContextUserInfo],
                                 operatorUser: AgoraEduContextUserInfo?) {
        for user in userList {
            if user.userRole == .student {
                dataSource.removeAll(where: {$0.uuid == user.userUuid})
            }
        }
        reloadData()
    }
    
    func onRemoteUserJoined(user: AgoraEduContextUserInfo) {
        if user.userRole == .teacher {
            self.teacherModel = AgoraRenderMemberModel.model(with: contextPool,
                                                             uuid: user.userUuid,
                                                             name: user.userName)
        }
    }
    
    func onRemoteUserLeft(user: AgoraEduContextUserInfo,
                          operatorUser: AgoraEduContextUserInfo?,
                          reason: AgoraEduContextUserLeaveReason) {
        if user.userRole == .teacher {
            self.teacherModel = nil
        }
    }
    
    func onUserHandsWave(userUuid: String,
                         duration: Int,
                         payload: [String : Any]?) {
        if let model = dataSource.first(where: {$0.uuid == userUuid}) {
            model.isHandsUp = true
        }
    }
    
    func onUserHandsDown(userUuid: String,
                         payload: [String : Any]?) {
        if let model = dataSource.first(where: {$0.uuid == userUuid}) {
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
    func onStreamJoined(stream: AgoraEduContextStreamInfo,
                        operatorUser: AgoraEduContextUserInfo?) {
        self.updateStream(stream: stream)
    }
    
    func onStreamUpdated(stream: AgoraEduContextStreamInfo,
                         operatorUser: AgoraEduContextUserInfo?) {
        self.updateStream(stream: stream)
    }
    
    func onStreamLeft(stream: AgoraEduContextStreamInfo,
                      operatorUser: AgoraEduContextUserInfo?) {
        let emptyStream = AgoraEduContextStreamInfo(streamUuid: stream.streamUuid,
                                                    streamName: stream.streamName,
                                                    streamType: .none,
                                                    videoSourceType: .none,
                                                    audioSourceType: .none,
                                                    videoSourceState: .error,
                                                    audioSourceState: .error,
                                                    owner: stream.owner)
        self.updateStream(stream: emptyStream)
    }
}

// MARK: - AgoraEduRoomHandler
extension AgoraMembersHorizeRenderUIController: AgoraEduRoomHandler {
    func onJoinRoomSuccess(roomInfo: AgoraEduContextRoomInfo) {
        // model setup
        self.setup()
    }
}

// MARK: - AgoraRenderMemberViewDelegate
extension AgoraMembersHorizeRenderUIController: AgoraRenderMemberViewDelegate {
    func memberViewRender(memberView: AgoraRenderMemberView,
                          in view: UIView,
                          renderID: String) {
        let localUid = contextPool.user.getLocalUserInfo().userUuid
        if let localStreamList = contextPool.stream.getStreamList(userUuid: localUid),
           !localStreamList.contains(where: {$0.streamUuid == renderID}){
            contextPool.stream.setRemoteVideoStreamSubscribeLevel(streamUuid: renderID,
                                                                  level: .low)
        }
        let renderConfig = AgoraEduContextRenderConfig()
        renderConfig.mode = .hidden
        renderConfig.isMirror = true
        
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
    
    func collectionView(_ collectionView: UICollectionView,
                        didEndDisplaying cell: UICollectionViewCell,
                        forItemAt indexPath: IndexPath) {
        if let current = cell as? AgoraRenderMemberCell {
            current.renderView.setModel(model: nil, delegate: self)
        }
    }
    
    func collectionView(_ collectionView: UICollectionView,
                        willDisplay cell: UICollectionViewCell,
                        forItemAt indexPath: IndexPath) {
        let model = self.dataSource[indexPath.row]
        if let current = cell as? AgoraRenderMemberCell {
            current.renderView.setModel(model: model, delegate: self)
        }
    }
    
    public func collectionView(_ collectionView: UICollectionView,
                               didSelectItemAt indexPath: IndexPath) {
        collectionView.deselectItem(at: indexPath, animated: false)
        let u = dataSource[indexPath.row]
        if let cell = collectionView.cellForItem(at: indexPath),
           let uuid = u.uuid {
            delegate?.onClickMemberAt(view: cell,
                                      UUID: uuid)
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
        leftButton.setImage(UIImage.agedu_named("ic_member_arrow_left"),
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
        rightButton.setImage(UIImage.agedu_named("ic_member_arrow_right"),
                             for: .normal)
        contentView.addSubview(rightButton)
        
        let tap = UITapGestureRecognizer.init(target: self, action: #selector(onDoubleClick(_:)))
        tap.numberOfTapsRequired = 2
        tap.numberOfTouchesRequired = 1
        tap.delaysTouchesBegan = true
        collectionView.addGestureRecognizer(tap)
    }
    
    func createConstraint() {
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
