//
//  VocationalRenderMembersUIController.swift
//  AgoraEduUI
//
//  Created by DoubleCircle on 2022/4/24.
//

import AgoraUIBaseViews
import AgoraEduContext
import AgoraWidget

protocol AgoraRenderUIComponentDelegate: NSObjectProtocol {
    func onClickMemberAt(view: UIView,
                         userId: String)
}

class VocationalRenderMembersUIComponent: UIViewController {
    
    public var isRenderByRTC = true {
        didSet {
            if isRenderByRTC != oldValue {
                // update all models
                for model in self.dataSource {
                    self.updateModel(userId: model.userId)
                }
            }
        }
    }
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
    private(set) weak var delegate: AgoraRenderUIComponentDelegate?
    private(set) var expandFlag: Bool = false
    var maxCount: Int = 0
    var windowList = [String]()
    
    var dataSource = [AgoraRenderMemberViewModel]()
    var viewsMap = [String : AgoraRenderMemberView]()
    // streamId: bool
    var rtcVideoRenderingList = [String]()
    var rtcAudioPlayingList = [String]()
    var cdnRendingList = [String]()
    
    // views
    private(set) var contentView = UIView()
    private(set) var layout = UICollectionViewFlowLayout()
    
    private(set) lazy var collectionView = UICollectionView(frame: .zero,
                                                            collectionViewLayout: layout)
    private(set) lazy var leftButton = UIButton(type: .custom)
    private(set) lazy var rightButton = UIButton(type: .custom)
    
    deinit {
        print("\(#function): \(self.classForCoder)")
    }
    
    // MARK: - public
    init(context: AgoraEduContextPool,
         delegate: AgoraRenderUIComponentDelegate?,
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
        guard dataSource.contains(where: {$0.userId == userId}),
              userId.isEmpty == false
        else {
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
            contextMediaHandle(rendEnable: false,
                               videoOn: false,
                               audioOn: false,
                               view: nil,
                               cdnURL: nil,
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
        
        contextMediaHandle(rendEnable: (model.userState == .normal),
                           videoOn: videoOn,
                           audioOn: (model.audioState == .normal),
                           view: view.videoView,
                           cdnURL: model.cdnURL,
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
        widgetController.add(self)
        contextPool.media.registerMediaEventHandler(self)
        streamController.registerStreamEventHandler(self)
    }
    
    func unregisterHandlers() {
        widgetController.remove(self)
        streamController.unregisterStreamEventHandler(self)
        contextPool.media.unregisterMediaEventHandler(self)
    }
}

// MARK: - AgoraUIActivity & AgoraUIContentContainer
@objc extension VocationalRenderMembersUIComponent: AgoraUIActivity, AgoraUIContentContainer {
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
        let config = UIConfig.studentVideo.moveButton
        leftButton.setImage(config.prevImage,
                            for: .normal)
        collectionView.addSubview(leftButton)
        
        rightButton.isHidden = true
        rightButton.clipsToBounds = true
        rightButton.addTarget(self,
                              action: #selector(onClickRight(_:)),
                              for: .touchUpInside)
        rightButton.setImage(config.nextImage,
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
        
        
        guard expandFlag else {
            return
        }
        
        leftButton.layer.cornerRadius = FcrUIFrameGroup.windowCornerRadius
        leftButton.backgroundColor = UIColor.black.withAlphaComponent(0.3)
        rightButton.layer.cornerRadius = FcrUIFrameGroup.windowCornerRadius
        rightButton.backgroundColor = UIColor.black.withAlphaComponent(0.3)
    }
}

// MARK: - UICollectionViewDataSource, UICollectionViewDelegate
extension VocationalRenderMembersUIComponent: UICollectionViewDataSource, UICollectionViewDelegate {
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

// MARK: - AgoraWidgetActivityObserver
extension VocationalRenderMembersUIComponent: AgoraWidgetActivityObserver {
    public func onWidgetActive(_ widgetId: String) {
        
    }
    
    public func onWidgetInactive(_ widgetId: String) {

    }
}

// MARK: - AgoraEduMediaHandler
extension VocationalRenderMembersUIComponent: AgoraEduMediaHandler {
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
extension VocationalRenderMembersUIComponent: AgoraEduStreamHandler {
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
extension VocationalRenderMembersUIComponent: AgoraEduRoomHandler {
    func onJoinRoomSuccess(roomInfo: AgoraEduContextRoomInfo) {
        viewWillActive()
    }
}

extension VocationalRenderMembersUIComponent: AgoraEduSubRoomHandler {
    func onJoinSubRoomSuccess(roomInfo: AgoraEduContextSubRoomInfo) {
        viewWillActive()
    }
}


// MARK: - actions
extension VocationalRenderMembersUIComponent {
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
private extension VocationalRenderMembersUIComponent {
    // model to view
    func contextMediaHandle(rendEnable: Bool,
                            videoOn: Bool,
                            audioOn: Bool,
                            view: UIView?,
                            cdnURL: String?,
                            streamId: String?) {
        guard let streamId = streamId else {
            return
        }
        if self.isRenderByRTC {
            // 如果cdn正在渲染，关闭cdn的渲染
            if self.cdnRendingList.contains(streamId),
               let url = cdnURL {
                self.contextPool.media.stopRenderVideoFromCdn(streamUrl: url)
                self.contextPool.media.stopPlayAudioFromCdn(streamUrl: url)
                self.cdnRendingList.removeAll(streamId)
            }
            // 再处理RTC的渲染
            if videoOn {
                guard let renderView = view else {
                    return
                }
                if !self.rtcVideoRenderingList.contains(streamId) {
                    if !isLocalStream(streamId) {
                        streamController.setRemoteVideoStreamSubscribeLevel(streamUuid: streamId,
                                                                            level: .low)
                    }
                    let renderConfig = AgoraEduContextRenderConfig()
                    renderConfig.mode = .hidden
                    renderConfig.isMirror = false
                    // 开启rtc 渲染
                    self.contextPool.media.startRenderVideo(roomUuid: roomId,
                                                            view: renderView,
                                                            renderConfig: renderConfig,
                                                            streamUuid: streamId)
                    self.rtcVideoRenderingList.append(streamId)
                }
            } else {
                if self.rtcVideoRenderingList.contains(streamId) {
                    self.contextPool.media.stopRenderVideo(roomUuid: roomId,
                                                      streamUuid: streamId)
                    self.rtcVideoRenderingList.removeAll(streamId)
                }
            }
            // audio on
            if audioOn {
                if !rtcAudioPlayingList.contains(streamId) {
                    self.contextPool.media.startPlayAudio(roomUuid: roomId,
                                                          streamUuid: streamId)
                    self.rtcAudioPlayingList.append(streamId)
                }
            } else {
                if self.rtcAudioPlayingList.contains(streamId) {
                    self.contextPool.media.stopPlayAudio(roomUuid: roomId,
                                                         streamUuid: streamId)
                    self.rtcAudioPlayingList.removeAll(streamId)
                }
            }
        } else {// 处理CDN渲染逻辑
            guard let url = cdnURL, let renderView = view else {
                return
            }
            // 如果RTC正在渲染，先关闭RTC的渲染
            if self.rtcVideoRenderingList.contains(streamId) {
                self.contextPool.media.stopRenderVideo(roomUuid: roomId,
                                                       streamUuid: streamId)
                self.rtcVideoRenderingList.removeAll(streamId)
            }
            // 如果RTC正在播放，先关闭RTC的播放
            if self.rtcAudioPlayingList.contains(streamId) {
                self.contextPool.media.stopPlayAudio(roomUuid: roomId,
                                                     streamUuid: streamId)
                self.rtcAudioPlayingList.removeAll(streamId)
            }
            if rendEnable {
                if !self.cdnRendingList.contains(streamId) {
                    // 先调用一遍stop用以处理拖拉拽时不显示的问题
                    self.contextPool.media.stopRenderVideoFromCdn(streamUrl: url)
                    self.contextPool.media.stopPlayAudioFromCdn(streamUrl: url)
                    // 再打开CDN的播放
                    self.contextPool.media.startRenderVideoFromCdn(view: renderView,
                                                                   mode: .hidden,
                                                                   streamUrl: url)
                    self.contextPool.media.startPlayAudioFromCdn(streamUrl: url)
                    // 添加进播放记录
                    self.cdnRendingList.append(streamId)
                }
            } else {
                if self.cdnRendingList.contains(streamId) {
                    self.contextPool.media.stopRenderVideoFromCdn(streamUrl: url)
                    self.contextPool.media.stopPlayAudioFromCdn(streamUrl: url)
                    self.cdnRendingList.removeAll(streamId)
                }
            }
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
