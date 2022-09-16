//
//  FcrProctorExamComponent.swift
//  AgoraProctorUI
//
//  Created by LYY on 2022/9/1.
//

import AgoraUIBaseViews
import AgoraEduContext

@objc public protocol FcrProctorExamComponentDelegate: NSObjectProtocol {
    func onExamExit()
}

@objc public class FcrProctorExamComponent: UIViewController {
    /**view**/
    private lazy var contentView = FcrProctorExamComponentView(frame: .zero)
    
    /**context**/
    private weak var delegate: FcrProctorExamComponentDelegate?
    private let contextPool: AgoraEduContextPool
    private var subRoom: AgoraEduSubRoomContext?
    
    /**data**/
    private var currentFront: Bool = true
    
    @objc public init(contextPool: AgoraEduContextPool,
                      delegate: FcrProctorExamComponentDelegate?) {
        self.contextPool = contextPool
        self.delegate = delegate
        
        super.init(nibName: nil,
                   bundle: nil)
    }
    
    public override func viewDidLoad() {
        super.viewDidLoad()
        
        initViews()
        initViewFrame()
        updateViewProperties()
        
        contextPool.room.registerRoomEventHandler(self)
        contextPool.group.registerGroupEventHandler(self)
        
        checkExamState()
        localSubRoomCheck()
        startRender()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

// MARK: - AgoraEduRoomHandler
extension FcrProctorExamComponent: AgoraEduRoomHandler {
    public func onClassStateUpdated(state: AgoraEduContextClassState) {
        checkExamState()
    }
}

// MARK: - AgoraEduGroupHandler
extension FcrProctorExamComponent: AgoraEduGroupHandler {
    public func onSubRoomListAdded(subRoomList: [AgoraEduContextSubRoomInfo]) {
        guard let userIdPrefix = contextPool.user.getLocalUserInfo().userUuid.getUserIdPrefix(),
              let info = subRoomList.first(where: {$0.subRoomName == userIdPrefix}) else {
            return
        }
        
        joinSubRoom(info.subRoomUuid)
    }
}

// MARK: - AgoraUIContentContainer
extension FcrProctorExamComponent: AgoraUIContentContainer {
    public func initViews() {
        view.addSubview(contentView)
        
        contentView.exitButton.addTarget(self,
                                         action: #selector(onClickExitRoom),
                                         for: .touchUpInside)
        contentView.leaveButton.addTarget(self,
                                          action: #selector(onClickExitRoom),
                                          for: .touchUpInside)
        
        let userName = contextPool.user.getLocalUserInfo().userName
        contentView.nameLabel.text = userName
        let roomName = contextPool.room.getRoomInfo().roomName
        contentView.examNameLabel.text = roomName
        
        contentView.switchCameraButton.addTarget(self,
                                                 action: #selector(onClickSwitchCamera),
                                                 for: .touchUpInside)
    }
    
    public func initViewFrame() {
        contentView.mas_makeConstraints { make in
            make?.left.right().top().bottom().equalTo()(0)
        }
    }
    
    public func updateViewProperties() {
        let config = UIConfig.exam
        
        view.backgroundColor = config.backgroundColor
    }
}

// MARK: - private
private extension FcrProctorExamComponent {
    func checkExamState() {
        let info = contextPool.room.getClassInfo()
        contentView.updateViewWithState(info.ui)
    }
    
    @objc func onClickSwitchCamera() {
        let deviceType: AgoraEduContextSystemDevice = currentFront ? .backCamera : .frontCamera
        guard contextPool.media.openLocalDevice(systemDevice: deviceType) == nil else {
            return
        }
        currentFront = !currentFront
    }
    
    @objc func onClickExitRoom() {
        let roomState = contextPool.room.getClassInfo().state
        
        guard roomState != .after else {
            delegate?.onExamExit()
            return
        }
        
        let message = "fcr_exam_prep_label_leave_exam".fcr_proctor_localized()
        
        let cancelTitle = "fcr_sub_room_button_stay".fcr_proctor_localized()
        let cancelAction = FcrAlertModelAction(title: cancelTitle)
        
        let leaveTitle = "fcr_sub_room_button_leave".fcr_proctor_localized()
        let leaveAction = FcrAlertModelAction(title: leaveTitle) { [weak self] in
            self?.subRoom?.leaveSubRoom()
            self?.delegate?.onExamExit()
        }
        
        FcrAlertModel()
            .setMessage(message)
            .addAction(action: cancelAction)
            .addAction(action: leaveAction)
            .show(in: self)
    }
    
    func localSubRoomCheck() {
        let localUserId = contextPool.user.getLocalUserInfo().userUuid
        guard let userIdPrefix = localUserId.getUserIdPrefix() else {
            return
        }
        
        var localSubRoomId = getUserSubroomId(userIdPrefix: userIdPrefix)
        
        if let `localSubRoomId` = localSubRoomId {
            joinSubRoom(localSubRoomId)
        } else {
            let config = AgoraEduContextSubRoomCreateConfig(subRoomName: userIdPrefix,
                                                            userList: [localUserId],
                                                            subRoomProperties: nil)
            contextPool.group.addSubRoomList(configs: [config],
                                             isInvited: false,
                                             success: nil) { [weak self] error in
                self?.localSubRoomCheck()
            }
        }
    }
    
    func joinSubRoom(_ subRoomId: String) {
        guard subRoom == nil,
              let localSubRoom = contextPool.group.createSubRoomObject(subRoomUuid: subRoomId) else {
            return
        }
        
        subRoom = localSubRoom
        AgoraLoading.loading()
        localSubRoom.joinSubRoom(success: { [weak self] in
            AgoraLoading.hide()
            self?.checkExamState()
        }, failure: { [weak self] error in
            AgoraLoading.hide()
            AgoraToast.toast(message: "fcr_room_tips_join_failed".fcr_proctor_localized())
        })
    }
    
    func startRender() {
        let userId = self.contextPool.user.getLocalUserInfo().userUuid
        
        let renderConfig = AgoraEduContextRenderConfig()
        renderConfig.mode = .hidden
        let streamId = "0"
        
        contextPool.media.startRenderVideo(view: self.contentView.renderView,
                                           renderConfig: renderConfig,
                                           streamUuid: streamId)
    }
    
    func getUserSubroomId(userIdPrefix: String) -> String? {
        var subRoomId: String?
        if let subRoomList = contextPool.group.getSubRoomList() {
            for subRoom in subRoomList {
                guard let userList = contextPool.group.getUserListFromSubRoom(subRoomUuid: subRoom.subRoomUuid),
                      userList.contains(where: {$0.contains(userIdPrefix)}) else {
                    continue
                }
                subRoomId = subRoom.subRoomUuid
                break
            }
        }
        return subRoomId
    }
}
