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
    private lazy var contentView = FcrProctorExamComponentView()
    
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
        
        checkExamState()
        localSubRonomCheck()
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
        // TODO: 分组名规则
        guard let userIdPrefix = contextPool.user.getLocalUserInfo().userUuid.getUserIdPrefix(),
              let info = subRoomList.first(where: {$0.subRoomName == userIdPrefix}) else {
            // TODO: ui,失败
            return
        }
        
        joinSubRoom(subRoomId: info.subRoomUuid)
    }
    
    // TODO: temp
    public func onUserListInvitedToSubRoom(userList: Array<String>,
                                    subRoomUuid: String,
                                    operatorUser: AgoraEduContextUserInfo?) {
        let localUserId = contextPool.user.getLocalUserInfo().userUuid
        
        guard userList.contains(localUserId),
              let subRoomList = contextPool.group.getSubRoomList(),
              let subRoomInfo = subRoomList.first(where: {$0.subRoomUuid == subRoomUuid}) else {
            return
        }
        
        contextPool.group.userListAcceptInvitationToSubRoom(userList: [localUserId],
                                                            subRoomUuid: subRoomUuid,
                                                            success: nil,
                                                            failure: nil)
    }
    
    // TODO: temp
    public func onUserListAddedToSubRoom(userList: [String],
                                         subRoomUuid: String,
                                         operatorUser: AgoraEduContextUserInfo?) {
        let localUserId = contextPool.user.getLocalUserInfo().userUuid
        
        guard userList.contains(localUserId) else {
            return
        }

        joinSubRoom(subRoomId: subRoomUuid)
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
        
        let title = "fcr_exam_leave_title".fcr_invigilator_localized()
        let message = "fcr_exam_leave_warning".fcr_invigilator_localized()
        
        let cancelTitle = "fcr_exam_leave_cancel".fcr_invigilator_localized()
        let cancelAction = FcrAlertModelAction(title: cancelTitle)
        
        let leaveTitle = "fcr_exam_leave_sure".fcr_invigilator_localized()
        let leaveAction = FcrAlertModelAction(title: leaveTitle) { [weak self] in
            self?.delegate?.onExamExit()
        }
        
        FcrAlertModel()
            .setTitle(title)
            .setMessage(message)
            .addAction(action: cancelAction)
            .addAction(action: leaveAction)
            .show(in: self)
    }
    
    func localSubRonomCheck() {
        // TODO: 检查自己是否有小房间
        let localUserId = contextPool.user.getLocalUserInfo().userUuid
        guard let userIdPrefix = localUserId.getUserIdPrefix() else {
            return
        }
        
        var localSubRoomId = getUserSubroomId(userIdPrefix: userIdPrefix)
        
        if let `localSubRoomId` = localSubRoomId {
            joinSubRoom(subRoomId: localSubRoomId)
        } else {
            // TODO: 当前context不满足直接添加
            // TODO: 分组name规则
            let config = AgoraEduContextSubRoomCreateConfig(subRoomName: userIdPrefix,
                                                            invitationUserList: [localUserId],
                                                            subRoomProperties: nil)
            // TODO: 重试机制
            contextPool.group.addSubRoomList(configs: [config]) {
                
            } failure: { error in
                // TODO: ui,添加失败
            }
        }
    }
    
    func joinSubRoom(subRoomId: String) {
        guard subRoom == nil,
              let localSubRoom = contextPool.group.createSubRoomObject(subRoomUuid: subRoomId) else {
            // TODO: ui 失败
            return
        }
        
        subRoom = localSubRoom
        localSubRoom.joinSubRoom(success: {
            AgoraLoading.hide()
        }, failure: { error in
            AgoraLoading.hide()
            // TODO: ui,失败
        })
    }
    
    func getUserSubroomId(userIdPrefix: String) -> String? {
        var subRoomId: String?
        if let subRoomList = contextPool.group.getSubRoomList() {
            for subRoom in subRoomList {
                guard let userList = contextPool.group.getUserListFromSubRoom(subRoomUuid: subRoom.subRoomUuid),
                      userList.contains(where: {$0.contains(userIdPrefix)}) else {
                    continue
                }
                subRoomId = subRoom.subRoomName
                break
            }
        }
        return subRoomId
    }
}
