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
    private(set) weak var delegate: AgoraRenderUIControllerDelegate?
    private var containRoles: [AgoraEduContextUserRole]
    private var isActive: Bool = true
    private(set) var expandFlag: Bool = false
    private(set) var maxCount: Int = 6
    var windowArr = [String]()
    
    var dataSource: [AgoraRenderMemberViewModel] = []
    var viewsDic: [String : AgoraRenderMemberView] = [:]
    // streamId
    var renderingList = [String]()
    
    // views
    private(set) var contentView: UIView!
    private(set) var layout: UICollectionViewFlowLayout
    
    private(set) var collectionView: UICollectionView!
    private(set) var leftButton: UIButton?
    private(set) var rightButton: UIButton?
    
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
                viewsDic[model.userId] = AgoraRenderMemberView(frame: .zero)
            }
        }
    }
    
    public func setRenderEnable(with userId: String,
                                rendEnable: Bool) {
        guard var model = dataSource.first(where: {$0.userId == userId}) else {
            return
        }
        if !rendEnable {
            windowArr.append(userId)
        } else {
            windowArr.removeAll(userId)
        }
        updateModel(userId: userId)
    }
    
    // MARK: - common
    override func viewDidLoad() {
        super.viewDidLoad()
        createViews()
        createConstraint()
        
        if let `subRoom` = subRoom {
            subRoom.registerSubRoomEventHandler(self)
        } else {
            contextPool.room.registerRoomEventHandler(self)
        }
        updateConstraint()
        collectionView.setCollectionViewLayout(layout,
                                               animated: true)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func viewWillActive() {
        isActive = true
        
        widgetController.add(self)
        userController.registerUserEventHandler(self)
        streamController.registerStreamEventHandler(self)
        contextPool.media.registerMediaEventHandler(self)
        
        createAllRender()
    }
    
    func viewWillInactive() {
        isActive = false
        
        widgetController.remove(self)
        userController.unregisterUserEventHandler(self)
        streamController.unregisterStreamEventHandler(self)
        contextPool.media.unregisterMediaEventHandler(self)
        
        releaseAllRender()
    }
    
    func updateLayout(_ layout: UICollectionViewFlowLayout) {
        self.layout = layout
        guard isActive else {
            return
        }
        updateConstraint()
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
    
    // MARK: - for sub class
    func addModels(userList: [String]) {
        var indexs = [IndexPath]()
        for (i,userId) in userList.enumerated() {
            guard !dataSource.contains(where: {$0.userId == userId}) else {
                continue
            }
            let model = makeModel(userId: userId)
            dataSource.append(model)
            let newView = AgoraRenderMemberView(frame: .zero)
            viewsDic[userId] = newView
            setViewWithModel(view: newView,
                             model: model)
            let indexPath = IndexPath(item: dataSource.count - 1,
                                      section: 0)
            indexs.append(indexPath)
        }

        updateConstraint()
        collectionView.insertItems(at: indexs)
    }
    
    func updateModel(userId: String) {
        guard dataSource.contains(where: {$0.userId == userId}),
              let view = viewsDic[userId] else {
            return
        }
        
        for (i,model) in dataSource.enumerated() {
            guard userId == model.userId else {
                continue
            }
            let model = makeModel(userId: userId)
            dataSource[i] = model
            setViewWithModel(view: view,
                             model: model)
            collectionView.reloadItems(at: [IndexPath(item: i,
                                                      section: 0)])
        }
    }
    
    func deleteModels(userList: [String]) {
        var indexs = [IndexPath]()
        for (i,userId) in userList.enumerated() {
            guard let model = dataSource.first(where: {$0.userId == userId}) else {
                continue
            }
            let indexPath = IndexPath(item: dataSource.count - 1,
                                      section: 0)
            indexs.append(indexPath)
            
            dataSource.removeAll(where: {$0.userId == userId})
            viewsDic.removeValue(forKey: userId)
            contextMediaHandle(videoOn: false,
                               audioOn: false,
                               view: nil,
                               streamId: model.streamId)
        }
        updateConstraint()
        collectionView.deleteItems(at: indexs)
    }
    
    func makeModel(userId: String) -> AgoraRenderMemberViewModel {
        guard let user = userController.getUserInfo(userUuid: userId) else {
            return AgoraRenderMemberViewModel.defaultNilValue()
        }
        let streamList = streamController.getStreamList(userUuid: userId)
        let stream = streamList?.first(where: {$0.videoSourceType == .camera})
        
        let windowFlag = windowArr.contains(userId)
        return AgoraRenderMemberViewModel.model(user: user,
                                                stream: stream,
                                                windowFlag: windowFlag)
    }
    
    func updateConstraint() {
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
        if expandFlag {
            let pageEnable = (self.dataSource.count <= maxCount)
            self.leftButton?.isHidden = pageEnable
            self.rightButton?.isHidden = pageEnable
        }
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
    
    // ui
    func createViews() {
        let ui = AgoraUIGroup()
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
        let l_button = UIButton(type: .custom)
        
        l_button.isHidden = true
        l_button.layer.cornerRadius = ui.frame.render_left_right_button_radius
        l_button.clipsToBounds = true
        l_button.backgroundColor = ui.color.render_left_right_button_color
        l_button.addTarget(self,
                             action: #selector(onClickLeft(_:)),
                             for: .touchUpInside)
        l_button.setImage(UIImage.agedu_named("ic_member_arrow_left"),
                            for: .normal)
        leftButton = l_button
        collectionView.addSubview(l_button)
        
        let r_button = UIButton(type: .custom)
        r_button.isHidden = true
        r_button.layer.cornerRadius = ui.frame.render_left_right_button_radius
        r_button.clipsToBounds = true
        r_button.backgroundColor = ui.color.render_left_right_button_color
        r_button.addTarget(self,
                              action: #selector(onClickRight(_:)),
                              for: .touchUpInside)
        r_button.setImage(UIImage.agedu_named("ic_member_arrow_right"),
                             for: .normal)
        rightButton = r_button
        collectionView.addSubview(r_button)
    }
    
    func createConstraint() {
        contentView.mas_makeConstraints { make in
            make?.centerX.equalTo()(0)
            make?.top.equalTo()(0)
            make?.bottom.equalTo()(0)
        }
        collectionView.mas_makeConstraints { make in
            make?.left.right().top().bottom().equalTo()(0)
        }
        
        guard expandFlag else {
            return
        }
        
        leftButton?.mas_makeConstraints { make in
            make?.left.top().bottom().equalTo()(collectionView)
            make?.width.equalTo()(24)
        }
        rightButton?.mas_makeConstraints { make in
            make?.right.top().bottom().equalTo()(collectionView)
            make?.width.equalTo()(24)
        }
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
        guard let view = viewsDic[model.userId] else {
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
                                      UUID: u.userId)
        }
    }
}

// MARK: - AgoraWidgetActivityObserver
extension AgoraRenderMembersUIController: AgoraWidgetActivityObserver {
    public func onWidgetActive(_ widgetId: String) {
        
    }
    
    public func onWidgetInactive(_ widgetId: String) {
        windowArr = [String]()
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
        let localUserRole = userController.getLocalUserInfo().userRole
        guard let model = dataSource.first(where: {$0.userId == user.userUuid}) else {
            return
        }
        updateModel(userId: model.userId)
    }
    
    func onRemoteUserLeft(user: AgoraEduContextUserInfo,
                          operatorUser: AgoraEduContextUserInfo?,
                          reason: AgoraEduContextUserLeaveReason) {
        // TODO: - 1V1，小班课老师，大班课老师
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
        // TODO: remake userlist
        if containRoles.contains(.student),
           let students = userController.getCoHostList()?.filter({$0.userRole == .student}) {
            let userList = students.map({return $0.userUuid})
            addModels(userList: userList)
        }
        updateConstraint()
        collectionView.reloadData()
    }
    
    func releaseAllRender() {
        for model in dataSource {
            let userList = dataSource.map({return $0.userId})
            deleteModels(userList: userList)
        }
        
        updateConstraint()
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
        if videoOn,
           !renderingList.contains(streamId),
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
            
            renderingList.append(streamId)
        } else if !videoOn {
            contextPool.media.stopRenderVideo(roomUuid: roomId,
                                              streamUuid: streamId)
            renderingList.removeAll(streamId)
        }
        
        if audioOn {
            contextPool.media.startPlayAudio(roomUuid: roomId,
                                             streamUuid: streamId)
        } else {
            contextPool.media.stopPlayAudio(roomUuid: roomId,
                                            streamUuid: streamId)
        }
    }
}


// new model -> view -> handle media -> cell
// update -> get origin model -> handle media -> cell(reload index of)
// delete -> delete cell
