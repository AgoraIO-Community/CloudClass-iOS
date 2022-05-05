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
    private(set) weak var delegate: AgoraRenderUIControllerDelegate?
    private var containRoles: [AgoraEduContextUserRole]
    private(set) var expandFlag: Bool = false
    private(set) var maxCount: Int = 6
    var windowList = [String]()
    
    var dataSource = [AgoraRenderMemberViewModel]()
    var viewsMap = [String : AgoraRenderMemberView]()
    // streamId: bool
    var videoRenderingList = [String]()
    var audioPlayingList = [String]()
    
    // views
    private(set) var contentView: UIView!
    private(set) var layout: UICollectionViewFlowLayout
    
    private(set) var collectionView: UICollectionView!
    private(set) lazy var leftButton = UIButton(type: .custom)
    private(set) lazy var rightButton = UIButton(type: .custom)
    
    // MARK: - public
    init(context: AgoraEduContextPool,
         delegate: AgoraRenderUIControllerDelegate?,
         containRoles: [AgoraEduContextUserRole] = [.student],
         max: Int,
         dataSource: [AgoraRenderMemberViewModel]? = nil,
         subRoom: AgoraEduSubRoomContext? = nil,
         expandFlag: Bool = false) {
        self.contextPool = context
        self.delegate = delegate
        self.containRoles = containRoles
        self.subRoom = subRoom
        self.maxCount = max
        
        let defaultLayout = UICollectionViewFlowLayout()
        defaultLayout.scrollDirection = .horizontal
        self.layout = defaultLayout
        
        super.init(nibName: nil,
                   bundle: nil)
        
        if let data = dataSource,
           data.count > 0 {
            self.dataSource = data
            for model in data {
                let newView = AgoraRenderMemberView(frame: .zero)
                viewsMap[model.userId] = newView
                setViewWithModel(view: newView,
                                 model: model)
            }
        }
    }
    
    public func setRenderEnable(with userId: String,
                                rendEnable: Bool) {
        guard var model = dataSource.first(where: {$0.userId == userId}) else {
            return
        }
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
        var view: UIView?
        for (i, model) in dataSource.enumerated() {
            guard model.userId == userId else {
                continue
            }
            let indexPath = IndexPath(item: i,
                                      section: 0)
            view = collectionView.cellForItem(at: indexPath)
            break
        }
        return view
    }
    
    // MARK: - common
    override func viewDidLoad() {
        super.viewDidLoad()
        initViews()
        updateViewProperties()
        initViewFrame()
        
        if let `subRoom` = subRoom {
            subRoom.registerSubRoomEventHandler(self)
        } else {
            contextPool.room.registerRoomEventHandler(self)
        }
        updateViewFrame()
        collectionView.setCollectionViewLayout(layout,
                                               animated: true)
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
              let view = viewsMap[userId] else {
            return
        }
        
        for (i, model) in dataSource.enumerated() {
            guard userId == model.userId else {
                continue
            }
            let model = makeModel(userId: userId,
                                  role: model.userRole)
            dataSource[i] = model
            setViewWithModel(view: view,
                             model: model)
            collectionView.reloadItems(at: [IndexPath(item: i,
                                                      section: 0)])
        }
    }
    
    func deleteModels(userList: [String]) {
        var indexs = [IndexPath]()
        for (i, userId) in userList.enumerated() {
            guard let model = dataSource.first(where: {$0.userId == userId}) else {
                continue
            }
            let indexPath = IndexPath(item: dataSource.count - 1,
                                      section: 0)
            indexs.append(indexPath)
            
            dataSource.removeAll(where: {$0.userId == userId})
            viewsMap.removeValue(forKey: userId)
            contextMediaHandle(videoOn: false,
                               audioOn: false,
                               view: nil,
                               streamId: model.streamId)
        }
        updateViewFrame()
        collectionView.deleteItems(at: indexs)
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
        let pageEnable = (self.dataSource.count <= maxCount)
        self.leftButton.isHidden = pageEnable
        self.rightButton.isHidden = pageEnable
    }
    
    // model to view
    func setViewWithModel(view: AgoraRenderMemberView,
                          model: AgoraRenderMemberViewModel) {
        model.setRenderMemberView(view: view)
        
        guard let streamId = model.streamId else {
            return
        }
        contextMediaHandle(videoOn: (model.videoState == .normal),
                           audioOn: (model.audioState == .normal),
                           view: view.videoView,
                           streamId: streamId)
    }
}

// MARK: - AgoraUIActivity & AgoraUIContentContainer
@objc extension AgoraRenderMembersUIController: AgoraUIActivity, AgoraUIContentContainer {
    // AgoraUIActivity
    func viewWillActive() {
        widgetController.add(self)
        userController.registerUserEventHandler(self)
        streamController.registerStreamEventHandler(self)
        contextPool.media.registerMediaEventHandler(self)
        
        createAllRender()
    }
    
    func viewWillInactive() {
        widgetController.remove(self)
        userController.unregisterUserEventHandler(self)
        streamController.unregisterStreamEventHandler(self)
        contextPool.media.unregisterMediaEventHandler(self)
        
        releaseAllRender()
    }
    
    // AgoraUIContentContainer
    func initViews() {
        contentView = UIView()
        view.addSubview(contentView)
        
        collectionView = UICollectionView(frame: .zero,
                                          collectionViewLayout: layout)
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
        leftButton.layer.cornerRadius = ui.frame.render_left_right_button_radius
        leftButton.backgroundColor = ui.color.render_left_right_button_color
        rightButton.layer.cornerRadius = ui.frame.render_left_right_button_radius
        rightButton.backgroundColor = ui.color.render_left_right_button_color
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
        let cell = collectionView.dequeueReusableCell(withClass: UICollectionViewCell.self,
                                                      for: indexPath)
        let model = dataSource[indexPath.item]
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
        collectionView.deselectItem(at: indexPath, animated: false)
        let u = dataSource[indexPath.row]
        if let cell = collectionView.cellForItem(at: indexPath),
           u.userId != "" {
            delegate?.onClickMemberAt(view: cell,
                                      userId: u.userId)
        }
    }
}

// MARK: - AgoraWidgetActivityObserver
extension AgoraRenderMembersUIController: AgoraWidgetActivityObserver {
    public func onWidgetActive(_ widgetId: String) {
        
    }
    
    public func onWidgetInactive(_ widgetId: String) {
        windowList = [String]()
    }
}

// MARK: - AgoraEduUserHandler
extension AgoraRenderMembersUIController: AgoraEduUserHandler {
    func onCoHostUserListAdded(userList: [AgoraEduContextUserInfo],
                               operatorUser: AgoraEduContextUserInfo?) {
        guard containRoles.contains(.student) else {
            return
        }
        let addList = userList.map({return $0.userUuid})
        addModels(userList: addList)
    }
    
    func onCoHostUserListRemoved(userList: [AgoraEduContextUserInfo],
                                 operatorUser: AgoraEduContextUserInfo?) {
        guard containRoles.contains(.student) else {
            return
        }
        let userList = userList.map({return $0.userUuid})
        deleteModels(userList: userList)
    }
    
    func onRemoteUserJoined(user: AgoraEduContextUserInfo) {
        guard containRoles.contains(.teacher),
              let model = dataSource.first(where: {$0.userId == user.userUuid}) else {
            return
        }
        updateModel(userId: model.userId)
    }
    
    func onRemoteUserLeft(user: AgoraEduContextUserInfo,
                          operatorUser: AgoraEduContextUserInfo?,
                          reason: AgoraEduContextUserLeaveReason) {
        guard containRoles.contains([.teacher]),
              let model = dataSource.first(where: {$0.userId == user.userUuid}) else {
            return
        }
        let roomType = contextPool.room.getRoomInfo().roomType
        switch roomType {
        case .oneToOne:
            updateModel(userId: user.userUuid)
        case .lecture:
            guard user.userRole == .teacher else {
                return
            }
            updateModel(userId: user.userUuid)
        default:
            break
        }
    }
    
    func onUserHandsWave(userUuid: String,
                         duration: Int,
                         payload: [String : Any]?) {
        guard let model = dataSource.first(where: {$0.userId == userUuid}),
           let view = viewsMap[model.userId] else {
            return
        }
        view.startWaving()
    }
    
    func onUserHandsDown(userUuid: String,
                         payload: [String : Any]?) {
        guard let model = dataSource.first(where: {$0.userId == userUuid}),
           let view = viewsMap[model.userId] else {
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
    func onJoinSubRoomSuccess(roomInfo: AgoraEduContextRoomInfo) {
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
        // 此处仅处理dataSource预设值情况
        guard containRoles.contains(.teacher),
              dataSource.contains(where: {$0.userRole == .teacher}) else {
            return
        }
        
        let teacherInfo = userController.getUserList(role: .teacher)?.first
        let studentFlag = (containRoles.contains(.teacher) && dataSource.contains(where: {$0.userRole == .student}))
        
        for (i, model) in dataSource.enumerated() {
            if model.userRole == .teacher,
               let `teacherInfo` = teacherInfo {
                let model = makeModel(userId: teacherInfo.userUuid,
                                      role: .teacher)
                let newView = AgoraRenderMemberView(frame: .zero)
                dataSource[i] = model
                viewsMap[teacherInfo.userUuid] = newView
                setViewWithModel(view: newView,
                                 model: model)
            }
            
            if studentFlag,
               model.userRole == .student,
               let studentInfo = userController.getUserList(role: .student)?.first {
                let model = makeModel(userId: studentInfo.userUuid,
                                      role: .teacher)
                let newView = AgoraRenderMemberView(frame: .zero)
                dataSource[i] = model
                viewsMap[studentInfo.userUuid] = newView
                setViewWithModel(view: newView,
                                 model: model)
            }
        }
        
        updateViewFrame()
        collectionView.reloadData()
    }
    
    func releaseAllRender() {
        for model in dataSource {
            let userList = dataSource.map({return $0.userId})
            deleteModels(userList: userList)
        }
        
        updateViewFrame()
        collectionView.reloadData()
    }
    
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
            let localUid = userController.getLocalUserInfo().userUuid
            if let localStreamList = streamController.getStreamList(userUuid: localUid),
               !localStreamList.contains(where: {$0.streamUuid == streamId}){
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
}
