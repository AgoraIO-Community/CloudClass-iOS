//
//  AgoraRenderMembersUIController.swift
//  AgoraEduUI
//
//  Created by DoubleCircle on 2022/4/24.
//

import AgoraUIBaseViews
import AgoraEduContext
import AgoraWidget

protocol AgoraRenderUIControllerDelegate: NSObjectProtocol {
    func onClickMemberAt(view: UIView,
                         userId: String)
}

class AgoraRenderMembersUIController: UIViewController {
    // context
    private(set) var contextPool: AgoraEduContextPool
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
    private(set) weak var delegate: AgoraRenderUIControllerDelegate?
    private(set) var expandFlag: Bool = false
    var maxCount: Int = 0
    var windowList = [String]()
    
    var dataSource = [AgoraRenderMemberViewModel]()
    var viewsMap = [String : AgoraRenderMemberView]()
    // streamId: bool
    var videoRenderingList = [String]()
    var audioPlayingList = [String]()
    
    // views
    private(set) var contentView = UIView()
    private(set) var layout = UICollectionViewFlowLayout()
    
    private(set) lazy var collectionView = UICollectionView(frame: .zero,
                                                            collectionViewLayout: layout)
    private(set) lazy var leftButton = UIButton(type: .custom)
    private(set) lazy var rightButton = UIButton(type: .custom)
    
    // MARK: - public
    init(context: AgoraEduContextPool,
         delegate: AgoraRenderUIControllerDelegate?,
         subRoom: AgoraEduSubRoomContext? = nil,
         expandFlag: Bool = false) {
        self.contextPool = context
        self.delegate = delegate
        self.subRoom = subRoom
        self.expandFlag = expandFlag
        
        super.init(nibName: nil,
                   bundle: nil)
    }
    
    public func setRenderEnable(with userId: String,
                                rendEnable: Bool) {
        if !rendEnable {
            windowList.append(userId)
        } else {
            windowList.removeAll(userId)
        }
        updateModel(userId: userId)
    }
    
    func updateLayout(_ layout: UICollectionViewFlowLayout) {
        self.layout = layout
        updateViewFrame()
        collectionView.setCollectionViewLayout(layout,
                                               animated: true)
    }
    
    func getRenderViewForUser(with userId: String) -> UIView? {
        return viewsMap[userId]
    }
    
    // MARK: - common
    override func viewDidLoad() {
        super.viewDidLoad()
        initViews()
        initViewFrame()
        updateViewProperties()
        updateViewFrame()
        
        if let `subRoom` = subRoom {
            subRoom.registerSubRoomEventHandler(self)
        } else {
            contextPool.room.registerRoomEventHandler(self)
        }
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - for sub class
    func addModels(userList: [String]) {
        var indexs = [IndexPath]()
        for (i, userId) in userList.enumerated() {
            guard !dataSource.contains(where: {$0.userId == userId}) else {
                continue
            }
            let model = makeModel(userId: userId,
                                  role: .student)
            dataSource.append(model)
            let newView = AgoraRenderMemberView(frame: .zero)
            viewsMap[userId] = newView
            setViewWithModel(view: newView,
                             model: model)
            let indexPath = IndexPath(item: dataSource.count - 1,
                                      section: 0)
            indexs.append(indexPath)
        }

        updateViewFrame()
        collectionView.insertItems(at: indexs)
    }
    
    func updateModel(userId: String) {
        guard dataSource.contains(where: {$0.userId == userId}) else {
            return
        }
        
        for (i, model) in dataSource.enumerated() {
            guard userId == model.userId else {
                continue
            }
            let newModel = makeModel(userId: userId,
                                  role: model.userRole)
            dataSource[i] = newModel
            
            if let view = viewsMap[userId] {
                setViewWithModel(view: view,
                                 model: newModel)
            }

            collectionView.reloadItems(at: [IndexPath(item: i,
                                                      section: 0)])
        }
    }
    
    func deleteModels(userList: [String]) {
        var indexsToDelete = [IndexPath]()
        
        let collectionViewIndexs = collectionView.indexPathsForVisibleItems
        for (i, userId) in userList.enumerated() {
            guard let model = dataSource.first(where: {$0.userId == userId}),
                  let indexPath = collectionViewIndexs.first(where: {$0.item == i}),
                  !collectionView.isHidden else {
                continue
            }

            indexsToDelete.append(indexPath)
            viewsMap.removeValue(forKey: userId)
            contextMediaHandle(videoOn: false,
                               audioOn: false,
                               view: nil,
                               streamId: model.streamId)
        }
        
        guard indexsToDelete.count > 0 else {
            return
        }
        
        collectionView.deleteItems(at: indexsToDelete)
        dataSource.removeAll(where: {userList.contains($0.userId)})
        updateViewFrame()
    }
    
    func makeModel(userId: String,
                   role: AgoraRenderUserRole = .student) -> AgoraRenderMemberViewModel {
        guard let user = userController.getUserInfo(userUuid: userId) else {
            return AgoraRenderMemberViewModel.defaultNilValue(role: role)
        }
        let streamList = streamController.getStreamList(userUuid: userId)
        let stream = streamList?.first(where: {$0.videoSourceType == .camera})
        
        let windowFlag = windowList.contains(userId)
        return AgoraRenderMemberViewModel.model(user: user,
                                                stream: stream,
                                                windowFlag: windowFlag)
    }
    
    func updateViewFrame() {
        let singleLength = (layout.scrollDirection == .horizontal) ? layout.itemSize.width : layout.itemSize.height
        let kItemGap = layout.minimumLineSpacing
        
        let f_count = CGFloat(self.dataSource.count > maxCount ? maxCount: self.dataSource.count)
        
        let studentWidth = (singleLength + kItemGap) * f_count - kItemGap
        let collectionLength = (singleLength + kItemGap) * f_count - kItemGap
        
        if collectionView.width != studentWidth {
            collectionView.mas_remakeConstraints { make in
                make?.left.right().top().bottom().equalTo()(contentView)
                make?.width.equalTo()(studentWidth)
            }
        }
        
        guard expandFlag else {
            return
        }
        
        let pageEnable = (dataSource.count <= maxCount)
        leftButton.isHidden = pageEnable
        rightButton.isHidden = pageEnable
    }
    
    // model to view
    func setViewWithModel(view: AgoraRenderMemberView,
                          model: AgoraRenderMemberViewModel) {
        model.setRenderMemberView(view: view)
        
        let videoOn = (model.userState != .window && model.videoState == .normal)
        
        contextMediaHandle(videoOn: videoOn,
                           audioOn: (model.audioState == .normal),
                           view: view.videoView,
                           streamId: model.streamId)
    }
    
    func createAllRender() {
        // 1. sub vc handle
        // 2. update frame
        updateViewFrame()
        collectionView.reloadData()
    }
    
    func releaseAllRender() {
        // 1. sub vc handle
        // 2. update common data source
        for model in dataSource {
            let userList = dataSource.map({return $0.userId})
            deleteModels(userList: userList)
        }
    }
    
    func registerHandlers() {
        contextPool.media.registerMediaEventHandler(self)
        streamController.registerStreamEventHandler(self)
    }
    
    func unregisterHandlers() {
        streamController.unregisterStreamEventHandler(self)
        contextPool.media.unregisterMediaEventHandler(self)
    }
}

// MARK: - AgoraUIActivity & AgoraUIContentContainer
@objc extension AgoraRenderMembersUIController: AgoraUIActivity, AgoraUIContentContainer {
    // AgoraUIActivity
    func viewWillActive() {
        registerHandlers()
        createAllRender()
    }
    
    func viewWillInactive() {
        unregisterHandlers()
        releaseAllRender()
    }
    
    // AgoraUIContentContainer
    func initViews() {
        view.addSubview(contentView)
        
        collectionView.showsHorizontalScrollIndicator = false
        collectionView.showsVerticalScrollIndicator = false
        collectionView.delegate = self
        collectionView.dataSource = self
        collectionView.backgroundColor = .clear
        collectionView.isScrollEnabled = false
        collectionView.register(cellWithClass: AgoraRenderMemberCell.self)
        contentView.addSubview(collectionView)
        
        guard expandFlag else {
            return
        }
        
        leftButton.isHidden = true
        leftButton.clipsToBounds = true
        leftButton.addTarget(self,
                             action: #selector(onClickLeft(_:)),
                             for: .touchUpInside)
        leftButton.setImage(UIImage.agedu_named("ic_member_arrow_left"),
                            for: .normal)
        collectionView.addSubview(leftButton)
        
        rightButton.isHidden = true
        rightButton.clipsToBounds = true
        rightButton.addTarget(self,
                              action: #selector(onClickRight(_:)),
                              for: .touchUpInside)
        rightButton.setImage(UIImage.agedu_named("ic_member_arrow_right"),
                             for: .normal)
        collectionView.addSubview(rightButton)
    }
    
    func initViewFrame() {
        contentView.mas_makeConstraints { make in
            make?.centerX.equalTo()(0)
            make?.top.equalTo()(0)
            make?.bottom.equalTo()(0)
        }
        collectionView.mas_makeConstraints { make in
            make?.left.right().top().bottom().equalTo()(0)
        }
        
        if dataSource.count > 0 {
            updateViewFrame()
            collectionView.reloadData()
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
    
    func updateViewProperties() {
        let ui = AgoraUIGroup()
        
        guard expandFlag else {
            return
        }
        
        leftButton.layer.cornerRadius = ui.frame.fcr_window_corner_radius
        leftButton.backgroundColor = UIColor.black.withAlphaComponent(0.3)
        rightButton.layer.cornerRadius = ui.frame.fcr_window_corner_radius
        rightButton.backgroundColor = UIColor.black.withAlphaComponent(0.3)
    }
}

// MARK: - UICollectionViewDataSource, UICollectionViewDelegate
extension AgoraRenderMembersUIController: UICollectionViewDataSource, UICollectionViewDelegate {
    // UICollectionViewDataSource
    func collectionView(_ collectionView: UICollectionView,
                        numberOfItemsInSection section: Int) -> Int {
        return dataSource.count
    }
    
    func collectionView(_ collectionView: UICollectionView,
                        cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withClass: AgoraRenderMemberCell.self,
                                                      for: indexPath)
        let model = dataSource[indexPath.item]
        cell.contentView.isHidden = (model.userState == .window)
        
        guard let view = viewsMap[model.userId] else {
            return cell
        }
        
        cell.contentView.removeSubviews()
        cell.contentView.addSubview(view)
        
        view.mas_makeConstraints { make in
            make?.left.right().top().bottom().equalTo()(0)
        }
        
        return cell
    }
    
    // UICollectionViewDelegate
    public func collectionView(_ collectionView: UICollectionView,
                               didSelectItemAt indexPath: IndexPath) {
        collectionView.deselectItem(at: indexPath,
                                    animated: false)
        
        let u = dataSource[indexPath.row]
        
        if let cell = collectionView.cellForItem(at: indexPath),
           u.userId != "" {
            delegate?.onClickMemberAt(view: cell,
                                      userId: u.userId)
        }
    }
}

// MARK: - AgoraEduMediaHandler
extension AgoraRenderMembersUIController: AgoraEduMediaHandler {
    func onVolumeUpdated(volume: Int,
                         streamUuid: String) {
        guard let model = self.dataSource.first { $0.streamId == streamUuid },
        let view = viewsMap[model.userId] else {
            return
        }
        view.updateVolume(volume)
    }
}

// MARK: - AgoraEduStreamHandler
extension AgoraRenderMembersUIController: AgoraEduStreamHandler {
    func onStreamJoined(stream: AgoraEduContextStreamInfo,
                        operatorUser: AgoraEduContextUserInfo?) {
        updateModel(userId: stream.owner.userUuid)
    }
    
    func onStreamUpdated(stream: AgoraEduContextStreamInfo,
                         operatorUser: AgoraEduContextUserInfo?) {
        updateModel(userId: stream.owner.userUuid)
    }
    
    func onStreamLeft(stream: AgoraEduContextStreamInfo,
                      operatorUser: AgoraEduContextUserInfo?) {
        updateModel(userId: stream.owner.userUuid)
    }
}

// MARK: - AgoraEduRoomHandler
extension AgoraRenderMembersUIController: AgoraEduRoomHandler {
    func onJoinRoomSuccess(roomInfo: AgoraEduContextRoomInfo) {
        viewWillActive()
    }
}

extension AgoraRenderMembersUIController: AgoraEduSubRoomHandler {
    func onJoinSubRoomSuccess(roomInfo: AgoraEduContextSubRoomInfo) {
        viewWillActive()
    }
}


// MARK: - actions
extension AgoraRenderMembersUIController {
    @objc func onClickLeft(_ sender: UIButton) {
        let indexs = collectionView.indexPathsForVisibleItems
        
        guard let min = indexs.min(),
              min.row > 0 else {
            return
        }
        
        let previous = IndexPath(row: min.row - 1 ,
                                 section: 0)
        collectionView.scrollToItem(at: previous,
                                    at: .left,
                                    animated: true)
    }
    
    @objc func onClickRight(_ sender: UIButton) {
        let indexs = collectionView.indexPathsForVisibleItems
        
        guard let max = indexs.max(),
              max.row < dataSource.count - 1 else {
            return
        }
        
        let next = IndexPath(row: max.row + 1 ,
                             section: 0)
        collectionView.scrollToItem(at: next,
                                    at: .right,
                                    animated: true)
    }
}

// MARK: - private
private extension AgoraRenderMembersUIController {
    // model to view
    func contextMediaHandle(videoOn: Bool,
                            audioOn: Bool,
                            view: UIView?,
                            streamId: String?) {
        guard let streamId = streamId else {
            return
        }
        
        // video on
        if videoOn,
           !videoRenderingList.contains(streamId),
           let renderView = view {
            
            if !isLocalStream(streamId) {
                streamController.setRemoteVideoStreamSubscribeLevel(streamUuid: streamId,
                                                                    level: .low)
            }
            
            let renderConfig = AgoraEduContextRenderConfig()
            renderConfig.mode = .hidden
            renderConfig.isMirror = false
            
            contextPool.media.startRenderVideo(roomUuid: roomId,
                                               view: renderView,
                                               renderConfig: renderConfig,
                                               streamUuid: streamId)
            
            videoRenderingList.append(streamId)
        }
        
        // video off
        if !videoOn,
           videoRenderingList.contains(streamId) {
            contextPool.media.stopRenderVideo(roomUuid: roomId,
                                              streamUuid: streamId)
            videoRenderingList.removeAll(streamId)
        }
        
        // audio on
        if audioOn,
           !audioPlayingList.contains(streamId) {
            contextPool.media.startPlayAudio(roomUuid: roomId,
                                             streamUuid: streamId)
        }
        
        // audio off
        if !audioOn,
           audioPlayingList.contains(streamId) {
            contextPool.media.stopPlayAudio(roomUuid: roomId,
                                            streamUuid: streamId)
        }
    }
    
    func isLocalStream(_ streamId: String) -> Bool {
        let localUid = userController.getLocalUserInfo().userUuid
        
        if let localStreamList = streamController.getStreamList(userUuid: localUid),
           localStreamList.contains(where: {$0.streamUuid == streamId}) {
            return true
        } else {
            return false
        }
    }
}
