//
//  AgoraRenderMembersUIController.swift
//  AgoraEduUI
//
//  Created by DoubleCircle on 2022/4/24.
//

import AgoraUIBaseViews
import AgoraEduContext

protocol AgoraRenderUIControllerDelegate: NSObjectProtocol {
    func onClickMemberAt(view: UIView,
                         UUID: String)
}

class AgoraRenderMembersUIController: UIViewController {
    // context
    private(set) var contextPool: AgoraEduContextPool!
    private(set) var subRoom: AgoraEduSubRoomContext?
    
    var userController: AgoraEduUserContext {
        if let `subRoom` = subRoom {
            return subRoom.user
        } else {
            return contextPool.user
        }
    }
    
    var streamController: AgoraEduStreamContext {
        if let `subRoom` = subRoom {
            return subRoom.stream
        } else {
            return contextPool.stream
        }
    }
    
    var widgetController: AgoraEduWidgetContext {
        if let `subRoom` = subRoom {
            return subRoom.widget
        } else {
            return contextPool.widget
        }
    }
    
    var roomId: String {
        if let `subRoom` = subRoom {
            return subRoom.getSubRoomInfo().subRoomUuid
        } else {
            return contextPool.room.getRoomInfo().roomUuid
        }
    }
    
    // data
    private weak var delegate: AgoraRenderUIControllerDelegate?
    private var containRoles: [AgoraEduContextUserRole]
    private var isActive: Bool = true
    private var expandFlag: Bool = false
    private var maxCount: Int = 6
    var windowArr = [String]()
    
    var dataSource: [AgoraRenderMemberViewModel] = []
    var viewsDic: [String : AgoraRenderMemberView] = [:]
    // streamId
    var renderingList = [String]()
    
    // views
    private var contentView: UIView!
    
    private var collectionView: UICollectionView!
    private var leftButton: UIButton!
    private var rightButton: UIButton!
    
    init(context: AgoraEduContextPool,
         delegate: AgoraRenderUIControllerDelegate?,
         containRoles: [AgoraEduContextUserRole] = [.student],
         dataSource: [AgoraRenderMemberViewModel]? = nil,
         subRoom: AgoraEduSubRoomContext? = nil) {
        self.delegate = delegate
        self.containRoles = containRoles
        self.subRoom = subRoom
        
        super.init(nibName: nil,
                   bundle: nil)
        
        if let data = dataSource {
            self.dataSource = data
        }
    }
    
    func setExpandMaxCount(expandFlag: Bool,
                           max: Int?) {
        self.expandFlag = expandFlag
        guard expandFlag,
              let count = max else {
            return
        }
        self.maxCount = count
    }
    
    public func setRenderEnable(with userId: String,
                                rendEnable: Bool) {
        if rendEnable {
            windowArr.append(userId)
        } else {
            windowArr.removeAll(userId)
        }
        guard var model = dataSource.first(where: {$0.userId == userId}) else {
            return
        }
        model.userState = rendEnable ? .normal : .window
    }
    
    func handleMedia(model: AgoraRenderMemberViewModel) {
        guard let memberView = viewsDic[model.userId],
        let streamId = model.streamId else {
            return
        }
        if model.videoState == .normal {
            let localUid = userController.getLocalUserInfo().userUuid
            if let localStreamList = streamController.getStreamList(userUuid: localUid),
               !localStreamList.contains(where: {$0.streamUuid == model.streamId}){
                streamController.setRemoteVideoStreamSubscribeLevel(streamUuid: streamId,
                                                                    level: .low)
            }
            
            if memberView.width < 1 || memberView.height < 1 {
                memberView.layoutIfNeeded()
            }
            
            let renderConfig = AgoraEduContextRenderConfig()
            renderConfig.mode = .hidden
            renderConfig.isMirror = false
            
            contextPool.media.startRenderVideo(roomUuid: roomId,
                                               view: memberView,
                                               renderConfig: renderConfig,
                                               streamUuid: streamId)
            
            renderingList.append(streamId)
        } else {
            guard let streamId = model.streamId else {
                return
            }
            contextPool.media.stopRenderVideo(roomUuid: roomId,
                                              streamUuid: streamId)
            renderingList.removeAll(streamId)
        }
        
        if model.audioState == .normal {
            contextPool.media.startPlayAudio(roomUuid: roomId,
                                             streamUuid: streamId)
        } else {
            contextPool.media.stopPlayAudio(roomUuid: roomId,
                                            streamUuid: streamId)
        }
    }
    
    // common
    func viewWillActive() {
        isActive = true
        
        userController.registerUserEventHandler(self)
        streamController.registerStreamEventHandler(self)
        contextPool.media.registerMediaEventHandler(self)
        
        createAllRender()
    }
    
    func viewWillInactive() {
        isActive = false
        
        userController.unregisterUserEventHandler(self)
        streamController.unregisterStreamEventHandler(self)
        contextPool.media.unregisterMediaEventHandler(self)
        
        releaseAllRender()
    }
    
    func updateLayout(_ layout: UICollectionViewLayout) {
        collectionView.setCollectionViewLayout(layout,
                                               animated: true)
    }
    
    func getRenderViewForUser(with userId: String) -> UIView? {
        var view: UIView?
        let indexes = self.collectionView.indexPathsForVisibleItems
        for (i, model) in self.dataSource.enumerated() {
            if model.userId == userId {
                if let indexPath = indexes.first(where: {$0.row == i}) {
                    view = self.collectionView.cellForItem(at: indexPath)
                }
                break
            }
        }
        return view
    }
    
    func updateStream(stream: AgoraEduContextStreamInfo?) {
        guard stream?.videoSourceType != .screen else {
            return
        }
        for (i,model) in dataSource.enumerated() {
            if stream?.owner.userUuid == model.userId {
                let model = makeModel(userId: model.userId,
                                      windowFlag: (model.userState == .window))
                dataSource[i] = model
                collectionView.reloadItems(at: [IndexPath(item: i,
                                                          section: 0)])
            }
        }
    }
    
    func makeModel(userId: String,
                   windowFlag: Bool) -> AgoraRenderMemberViewModel {
        guard let user = userController.getUserInfo(userUuid: userId) else {
            return AgoraRenderMemberViewModel.defaultNilValue()
        }
        let stream = streamController.getStreamList(userUuid: userId)?.first(where: {$0.videoSourceType == .camera})
        return AgoraRenderMemberViewModel.model(user: user,
                                                stream: stream,
                                                windowFlag: windowFlag)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        createViews()
        createConstraint()
        
        if let `subRoom` = subRoom {
            subRoom.registerSubRoomEventHandler(self)
        } else {
            contextPool.room.registerRoomEventHandler(self)
        }
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}

// MARK: - UICollectionViewDataSource, UICollectionViewDelegate
extension AgoraRenderMembersUIController: UICollectionViewDataSource, UICollectionViewDelegate {
    // UICollectionViewDataSource
    func collectionView(_ collectionView: UICollectionView,
                        numberOfItemsInSection section: Int) -> Int {
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView,
                        cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withClass: UICollectionViewCell.self,
                                                      for: indexPath)
        let model = dataSource[indexPath.item]
        guard let view = viewsDic[model.userId] else {
            return cell
        }
        
        cell.contentView.removeSubviews()
        cell.contentView.addSubview(view)
        view.mas_makeConstraints { make in
            make?.left.right().top().bottom().equalTo()(0)
        }
        handleMedia(model: model)
        return cell
    }
    
    // UICollectionViewDelegate
    public func collectionView(_ collectionView: UICollectionView,
                               didSelectItemAt indexPath: IndexPath) {
        collectionView.deselectItem(at: indexPath, animated: false)
        let u = dataSource[indexPath.row]
        if let cell = collectionView.cellForItem(at: indexPath),
           u.userId != "" {
            delegate?.onClickMemberAt(view: cell,
                                      UUID: u.userId)
        }
    }
}


// MARK: - AgoraEduUserHandler
extension AgoraRenderMembersUIController: AgoraEduUserHandler {
    func onCoHostUserListAdded(userList: [AgoraEduContextUserInfo],
                               operatorUser: AgoraEduContextUserInfo?) {
        guard containRoles.contains(.student) else {
            return
        }

        for user in userList {
            if !dataSource.contains(where: {$0.userId == user.userUuid}),
               user.userRole == .student {
                let stream = streamController.getStreamList(userUuid: user.userUuid)?.first(where: {$0.videoSourceType == .camera})
                let model = AgoraRenderMemberViewModel.model(user: user,
                                                             stream: stream)
                dataSource.append(model)
                viewsDic[model.userId] = AgoraRenderMemberView(frame: .zero)
            }
        }
        collectionView.reloadData()
    }
    
    func onCoHostUserListRemoved(userList: [AgoraEduContextUserInfo],
                                 operatorUser: AgoraEduContextUserInfo?) {
        guard containRoles.contains(.student) else {
            return
        }
        for (i,user) in userList.enumerated() {
            if user.userRole == .student {
                dataSource.removeAll(where: {$0.userId == user.userUuid})
            }
        }
        collectionView.reloadData()
    }
    
    func onRemoteUserJoined(user: AgoraEduContextUserInfo) {
        let localUserRole = userController.getLocalUserInfo().userRole
        guard containRoles.contains([.student,.teacher]),
        var model = dataSource.first(where: {$0.userId == user.userUuid}) else {
            return
        }
        let stream = contextPool.stream.getStreamList(userUuid: user.userUuid)?.first(where: {$0.videoSourceType == .camera})
        model = AgoraRenderMemberViewModel.model(user: user,
                                                 stream: stream,
                                                 windowFlag: false)
    }
    
    func onRemoteUserLeft(user: AgoraEduContextUserInfo,
                          operatorUser: AgoraEduContextUserInfo?,
                          reason: AgoraEduContextUserLeaveReason) {
        let localUserRole = userController.getLocalUserInfo().userRole
        guard containRoles.contains([.student,.teacher]) else {
            return
        }
        if localUserRole == .student,
           user.userRole == .teacher {
            
        } else if localUserRole == .student,
                  user.userRole == .teacher {
            
        }
    }
    
    func onUserHandsWave(userUuid: String,
                         duration: Int,
                         payload: [String : Any]?) {
        guard let model = dataSource.first(where: {$0.userId == userUuid}),
           let view = viewsDic[model.userId] else {
            return
        }
        view.startWaving()
    }
    
    func onUserHandsDown(userUuid: String,
                         payload: [String : Any]?) {
        guard let model = dataSource.first(where: {$0.userId == userUuid}),
           let view = viewsDic[model.userId] else {
            return
        }
        view.stopWaving()
    }
}

// MARK: - AgoraEduMediaHandler
extension AgoraRenderMembersUIController: AgoraEduMediaHandler {
    func onVolumeUpdated(volume: Int,
                         streamUuid: String) {
        guard let model = self.dataSource.first { $0.streamId == streamUuid },
        let view = viewsDic[model.userId] else {
            return
        }
        view.updateVolume(volume)
    }
}

// MARK: - AgoraEduStreamHandler
extension AgoraRenderMembersUIController: AgoraEduStreamHandler {
    func onStreamJoined(stream: AgoraEduContextStreamInfo,
                        operatorUser: AgoraEduContextUserInfo?) {
        updateStream(stream: stream)
    }
    
    func onStreamUpdated(stream: AgoraEduContextStreamInfo,
                         operatorUser: AgoraEduContextUserInfo?) {
        updateStream(stream: stream)
    }
    
    func onStreamLeft(stream: AgoraEduContextStreamInfo,
                      operatorUser: AgoraEduContextUserInfo?) {
        updateStream(stream: stream.toEmptyStream())
    }
}

// MARK: - AgoraEduRoomHandler
extension AgoraRenderMembersUIController: AgoraEduRoomHandler {
    func onJoinRoomSuccess(roomInfo: AgoraEduContextRoomInfo) {
        guard isActive == true else {
            return
        }
        
        viewWillActive()
    }
}

extension AgoraRenderMembersUIController: AgoraEduSubRoomHandler {
    func onJoinSubRoomSuccess(roomInfo: AgoraEduContextRoomInfo) {
        guard isActive == true else {
            return
        }
        
        viewWillActive()
    }
}


// MARK: - actions
extension AgoraRenderMembersUIController {
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

// MARK: - private
private extension AgoraRenderMembersUIController {
    func createAllRender() {
        if let students = userController.getCoHostList()?.filter({$0.userRole == .student}) {
            var temp = [AgoraRenderMemberViewModel]()
            for student in students {
                let stream = streamController.getStreamList(userUuid: student.userUuid)?.first(where: {$0.videoSourceType == .camera})
                let model = AgoraRenderMemberViewModel.model(user: student,
                                                             stream: stream)
                temp.append(model)
            }
            dataSource = temp
        }
        
//        if let streamList = streamController.getAllStreamList() {
//            for stream in streamList {
//                handleAudioOfStream(stream)
//            }
//        }
        
        collectionView.reloadData()
    }
    
    func releaseAllRender() {
        dataSource = []
        collectionView.reloadData()
        
        guard let streamList = streamController.getAllStreamList() else {
            return
        }
        
        for stream in streamList {
            contextPool.media.stopRenderVideo(roomUuid: roomId,
                                              streamUuid: stream.streamUuid)
            contextPool.media.stopPlayAudio(roomUuid: roomId,
                                            streamUuid: stream.streamUuid)
        }
    }
//
//    func handleAudioOfStream(_ stream: AgoraEduContextStreamInfo,
//                             isLeft: Bool = false) {
//        guard isLeft == false else {
//            contextPool.media.stopPlayAudio(roomUuid: roomId,
//                                            streamUuid: stream.streamUuid)
//            return
//        }
//
//        switch stream.audioSourceState {
//        case .open:
//            contextPool.media.startPlayAudio(roomUuid: roomId,
//                                             streamUuid: stream.streamUuid)
//        default:
//            contextPool.media.stopPlayAudio(roomUuid: roomId,
//                                            streamUuid: stream.streamUuid)
//        }
//    }
    
    func createViews() {
        let ui = AgoraUIGroup()
        contentView = UIView()
        view.addSubview(contentView)
        
        collectionView = UICollectionView(frame: .zero)
        collectionView.showsHorizontalScrollIndicator = false
        collectionView.showsVerticalScrollIndicator = false
        collectionView.delegate = self
        collectionView.dataSource = self
        collectionView.backgroundColor = .clear
        collectionView.isScrollEnabled = false
        collectionView.register(cellWithClass: UICollectionViewCell.self)
        contentView.addSubview(collectionView)
        
        guard expandFlag else {
            return
        }
        leftButton = UIButton(type: .custom)
        leftButton.isHidden = true
        leftButton.layer.cornerRadius = ui.frame.render_left_right_button_radius
        leftButton.clipsToBounds = true
        leftButton.backgroundColor = ui.color.render_left_right_button_color
        leftButton.addTarget(self,
                             action: #selector(onClickLeft(_:)),
                             for: .touchUpInside)
        leftButton.setImage(UIImage.agedu_named("ic_member_arrow_left"),
                            for: .normal)
        contentView.addSubview(leftButton)
        
        rightButton = UIButton(type: .custom)
        rightButton.isHidden = true
        rightButton.layer.cornerRadius = ui.frame.render_left_right_button_radius
        rightButton.clipsToBounds = true
        rightButton.backgroundColor = ui.color.render_left_right_button_color
        rightButton.addTarget(self,
                              action: #selector(onClickRight(_:)),
                              for: .touchUpInside)
        rightButton.setImage(UIImage.agedu_named("ic_member_arrow_right"),
                             for: .normal)
        contentView.addSubview(rightButton)
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
        
        guard expandFlag else {
            return
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
