//
//  PaintingRenderViewController.swift
//  AgoraEduUI
//
//  Created by HeZhengQing on 2021/9/9.
//

import AgoraUIBaseViews
import FLAnimatedImage
import AgoraEduContext
import AudioToolbox
import AgoraWidget
import Foundation
import Masonry
import UIKit

/** extension: 用于在feature层将SDK数据模型转换成cell model的数据模型*/
extension AgoraRenderItemInfoModel {
    convenience init(with user: AgoraEduContextUserInfo,
                     stream: AgoraEduContextStreamInfo?) {
        self.init()
        self.userUUID = user.userUuid
        self.userName = user.userName
        // TODO:
//        self.rewardCount = user.rewardCount
        // TODO: waving hands
//        self.isWaving = user.wavingArms
        update(stream: stream)
    }
    
    func update(stream: AgoraEduContextStreamInfo?) {
        guard let s = stream else {
            self.streamUUID = nil
            self.cameraDeviceState = .close
            self.micDeviceState = .close
            return
        }
        self.streamUUID = s.streamUuid
        if s.streamType == .video ||
            s.streamType == .both {
            switch s.videoSourceState {
            case .error:
                self.cameraDeviceState = .invalid
            case .close:
                self.cameraDeviceState = .close
            case .open:
                self.cameraDeviceState = .available
            }
        } else {
            self.cameraDeviceState = .close
        }
        if s.streamType == .audio ||
            s.streamType == .both {
            switch s.audioSourceState {
            case .error:
                self.micDeviceState = .invalid
            case .close:
                self.micDeviceState = .close
            case .open:
                self.micDeviceState = .available
            }
        } else {
            self.micDeviceState = .close
        }
    }
}

protocol AgoraPaintingRenderUIControllerDelegate: class {
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

private let kItemGap: CGFloat = 5.0
private let kTeacherIndex: IndexPath = IndexPath(row: -1, section: 0)
class AgoraHorizListRenderUIController: UIViewController {
    
    weak var delegate: AgoraPaintingRenderUIControllerDelegate?
    
    public var themeColor: UIColor?
    
    var contentView: UIView!
    
    var teacherContentView: UIView!
    
    var teacherView: AgoraRenderItemCell!
        
    var collectionView: AgoraBaseUICollectionView!
    
    var leftButton: UIButton!
    
    var rightButton: UIButton!
    
    private var spreadIndex: IndexPath? {
        didSet {
            if spreadIndex != oldValue {
                self.reloadData()
            }
        }
    }
        
    var contextPool: AgoraEduContextPool!
    
    var teacherItem: AgoraRenderItemInfoModel? {
        didSet {
            teacherView.isHidden = (teacherItem == nil)
            if teacherItem != oldValue {
                self.reloadLayout()
            }
            self.reloadData()
        }
    }
    
    var dataSource = [AgoraRenderItemInfoModel]() {
        didSet {
            collectionView.isHidden = (dataSource.count == 0)
            if dataSource.count != oldValue.count {
                self.reloadLayout()
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
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        self.reloadLayout()
    }
    
    func getSpreadCell(userId: String) -> UIView? {
        let (cell,index) = getCell(userId: userId)
        return cell
    }
    
    func updateSpreadIndex(spreadFlag: Bool,
                           userId: String,
                           streamId:String) {
        let (cell,index) = getCell(userId: userId)
        
        guard let spreadCell = cell,
        let indexPath = index else {
            return
        }

        if let `teacher` = teacherItem,
           indexPath == kTeacherIndex,
           let teacherStreamId = teacher.streamUUID {
            let renderDisabled = spreadFlag && (teacherStreamId == streamId)
            teacher.renderEnable = !renderDisabled
            spreadIndex = spreadFlag ? indexPath : nil
            return
        }
        
        let itemInfo = dataSource[indexPath.item]
        if let uid = itemInfo.userUUID,
           let userStreamId = itemInfo.streamUUID,
           let cell = collectionView.cellForItem(at: indexPath) {
            
            let renderDisabled = spreadFlag && (userStreamId == streamId)
            itemInfo.renderEnable = !renderDisabled
            spreadIndex = spreadFlag ? indexPath : nil
        }
    }
    
    func getCell(userId: String) -> (UIView?,IndexPath?) {
        if let `teacher` = teacherItem,
           teacher.userUUID == userId {
            return (teacherView,kTeacherIndex)
        }
        
        for item in dataSource.enumerated() {
            if item.element.userUUID == userId {
                let index = IndexPath(item: item.offset,
                                      section: 0)
                if let cell = collectionView.cellForItem(at: index) {
                    
                    return (cell,IndexPath(item: item.offset,
                                           section: 0))
                }
            }
        }
        return (nil,nil)
    }
}


// MARK: - Actions
extension AgoraHorizListRenderUIController {
    @objc func onDoubleClick(_ sender: UITapGestureRecognizer) {
        let user = contextPool.user.getLocalUserInfo()
        let point = sender.location(in: collectionView)
        
        guard user.userRole == .teacher,
              sender.state == .ended,
              let indexPath = collectionView.indexPathForItem(at: point),
              let cell = collectionView.cellForItem(at: indexPath),
              let userId = dataSource[indexPath.row].userUUID,
              let streamId = dataSource[indexPath.row].streamUUID else {
                  return
              }
        
        // 教师角色双击后，发送restFul消息并delegate通知roomVC大窗展示
        delegate?.onRequestSpread(firstOpen: self.spreadIndex == nil,
                                  userId: userId,
                                  streamId: streamId,
                                  fromView: cell,
                                  xaxis: 0.5,
                                  yaxis: 0.5,
                                  width: 0.5,
                                  height: 0.5)
        self.spreadIndex = indexPath
    }
    
    @objc func onClickTeacher(_ sender: UITapGestureRecognizer) {
        let user = contextPool.user.getLocalUserInfo()
        guard let UUID = teacherItem?.userUUID else {
            return
        }
        delegate?.onClickMemberAt(view: teacherView, UUID: UUID)
    }
    
    @objc func onDoubleClickTeacher(_ sender: UITapGestureRecognizer) {
        let user = contextPool.user.getLocalUserInfo()
        guard user.userRole == .teacher,
              sender.state == .ended,
              let uid = teacherItem?.userUUID,
              let streamId = teacherItem?.streamUUID else {
                  return
              }
        
        // 教师角色双击后，发送restFul消息并delegate通知roomVC大窗展示
        delegate?.onRequestSpread(firstOpen: self.spreadIndex == nil,
                                  userId: uid,
                                  streamId: streamId,
                                  fromView: teacherView,
                                  xaxis: 0.5,
                                  yaxis: 0.5,
                                  width: 0.5,
                                  height: 0.5)
        self.spreadIndex = kTeacherIndex
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
private extension AgoraHorizListRenderUIController {
    // 更新约束
    func reloadLayout() {
        let sigleWidth = (self.view.bounds.width + kItemGap) / 7 - kItemGap
        let teacherWidth = (teacherItem == nil) ? 0 : sigleWidth
        if teacherContentView.width != teacherWidth {
            teacherContentView.mas_remakeConstraints { make in
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
                make?.left.equalTo()(teacherContentView.mas_right)?.offset()(kItemGap)
                make?.width.equalTo()(studentWidth)
            }
        }
        let pageEnable = (self.dataSource.count <= 6)
        self.leftButton.isHidden = pageEnable
        self.rightButton.isHidden = pageEnable
    }
    // 更新视图
    func reloadData() {
        teacherView.itemInfo = teacherItem
        collectionView.reloadData()
    }

    func updateCoHosts() {
        let list = self.contextPool.user.getAllUserList()
        var tempStudents = [AgoraRenderItemInfoModel]()
        var tempTeacher: AgoraRenderItemInfoModel?
        let localInfo = contextPool.user.getLocalUserInfo()
        for user in list {
            if user.userRole == .teacher {
                let stream = contextPool.stream.getStreamList(userUuid: user.userUuid)?.first(where: {
                    $0.streamName != "secondary"
                })
                tempTeacher = AgoraRenderItemInfoModel(with: user,
                                                       stream: stream)
            } else if user.userRole == .student  { // TODO: && user.isCoHost
                let stream = contextPool.stream.getStreamList(userUuid: user.userUuid)?.first
                if stream?.owner.userUuid == localInfo.userUuid {
                    self.currentStream = stream
                }
                let model = AgoraRenderItemInfoModel(with: user,
                                                     stream: stream)
                tempStudents.append(model)
            }
        }
        self.dataSource = tempStudents
        teacherItem = tempTeacher
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
extension AgoraHorizListRenderUIController: AgoraEduUserHandler {
    func onRemoteUserJoined(user: AgoraEduContextUserInfo) {
        // TODO:
//        if user.isCoHost {
//            updateCoHosts()
//        }
    }
    
    func onRemoteUserLeft(user: AgoraEduContextUserInfo, operatorUser: AgoraEduContextUserInfo?, reason: AgoraEduContextUserLeaveReason) {
        // TODO:
//        if user.isCoHost {
//            updateCoHosts()
//        }
    }
    
    func onUserUpdated(user: AgoraEduContextUserInfo, operator: AgoraEduContextUserInfo?) {
        // TODO:
//        if user.isCoHost {
//            updateCoHosts()
//        }
    }
    
    func onUserUpdated(userInfo: AgoraEduContextUserInfo,
                       operatorUser: AgoraEduContextUserInfo?) {
        showRewardAnimation()
    }
}

// MARK: - AgoraEduMediaHandler
extension AgoraHorizListRenderUIController: AgoraEduMediaHandler {
    func onVolumeUpdated(volume: Int,
                         streamUuid: String) {
        if teacherItem?.streamUUID == streamUuid {
            teacherItem?.volume = volume
        } else {
            let item = self.dataSource.first { $0.streamUUID == streamUuid }
            item?.volume = volume
        }
    }
}

// MARK: - AgoraEduStreamHandler
extension AgoraHorizListRenderUIController: AgoraEduStreamHandler {
    func onStreamJoin(stream: AgoraEduContextStreamInfo,
                      operatorUser: AgoraEduContextUserInfo?) {
        self.updateCoHosts()
    }
    
    func onStreamLeave(stream: AgoraEduContextStreamInfo,
                       operatorUser: AgoraEduContextUserInfo?) {
        self.updateCoHosts()
    }
    
    func onStreamUpdate(stream: AgoraEduContextStreamInfo,
                        operatorUser: AgoraEduContextUserInfo?) {
        if stream.streamUuid == currentStream?.streamUuid {
            self.currentStream = stream
        }
        self.updateCoHosts()
    }
}

// MARK: - AgoraEduRoomHandler
extension AgoraHorizListRenderUIController: AgoraEduRoomHandler {
    func onJoinRoomSuccess(roomInfo: AgoraEduContextRoomInfo) {
        self.updateCoHosts()
    }
}

// MARK: - AgoraRenderItemCellDelegate
extension AgoraHorizListRenderUIController: AgoraRenderItemCellDelegate  {
    func onCellRequestRenderOnView(view: UIView,
                                   streamID: String,
                                   userUUID: String) {
        let renderConfig = AgoraEduContextRenderConfig()
        renderConfig.mode = .hidden
        renderConfig.isMirror = true
        contextPool.stream.setRemoteVideoStreamSubscribeLevel(streamUuid: streamID,
                                                              level: .low)
        contextPool.media.startRenderVideo(view: view,
                                           renderConfig: renderConfig,
                                           streamUuid: streamID)

    }
    
    func onCellRequestCancelRender(streamID: String,
                                   userUUID: String) {
        contextPool.media.stopRenderVideo(streamUuid: streamID)
    }
}
// MARK: - UICollectionView Call Back
extension AgoraHorizListRenderUIController: UICollectionViewDelegate,
                                           UICollectionViewDataSource,
                                           UICollectionViewDelegateFlowLayout {
    public func collectionView(_ collectionView: UICollectionView,
                               numberOfItemsInSection section: Int) -> Int {
        return self.dataSource.count
    }
    
    public func collectionView(_ collectionView: UICollectionView,
                               cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withClass: AgoraRenderItemCell.self,
                                                      for: indexPath)
        let item = self.dataSource[indexPath.row]
        cell.delegate = self
        cell.itemInfo = item
        cell.themeColor = themeColor
        return cell
    }
    
    public func collectionView(_ collectionView: UICollectionView,
                               didSelectItemAt indexPath: IndexPath) {
        collectionView.deselectItem(at: indexPath, animated: false)
        let u = dataSource[indexPath.row]
        if let cell = collectionView.cellForItem(at: indexPath),
           let UUID = u.userUUID {
            delegate?.onClickMemberAt(view: cell, UUID: UUID)
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
private extension AgoraHorizListRenderUIController {
    func createViews() {
        self.view.backgroundColor = .white
        
        contentView = UIView()
        view.addSubview(contentView)
        
        teacherContentView = UIView()
        contentView.addSubview(teacherContentView)
        
        teacherView = AgoraRenderItemCell(frame: .zero)
        teacherView.themeColor = themeColor
        teacherView.delegate = self
        teacherContentView.addSubview(teacherView)
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
        collectionView.register(cellWithClass: AgoraRenderItemCell.self)
        contentView.addSubview(collectionView)
        
        leftButton = UIButton(type: .custom)
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
    
    func createConstrains() {
        contentView.mas_makeConstraints { make in
            make?.centerX.equalTo()(0)
            make?.top.equalTo()(0)
            make?.bottom.equalTo()(0)
        }
        teacherContentView.mas_makeConstraints { make in
            make?.top.left().bottom().equalTo()(0)
            make?.width.equalTo()(0)
        }
        collectionView.mas_makeConstraints { make in
            make?.right.top().bottom().equalTo()(0)
            make?.left.equalTo()(teacherContentView.mas_right)
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
