//
//  MemberMenuViewController.swift
//  AgoraEduUI
//
//  Created by HeZhengQing on 2021/9/28.
//

import UIKit
import Masonry
import AgoraEduContext
import AgoraWidget

protocol AgoraRenderMenuUIControllerDelegate: NSObjectProtocol {
    /** menu指向的台上用户消失了*/
    func onMenuUserLeft()
}

class AgoraRenderMenuUIController: UIViewController {
    private var userController: AgoraEduUserContext {
        if let `subRoom` = subRoom {
            return subRoom.user
        } else {
            return contextPool.user
        }
    }
    
    private var streamController: AgoraEduStreamContext {
        if let `subRoom` = subRoom {
            return subRoom.stream
        } else {
            return contextPool.stream
        }
    }
    
    private var widgetController: AgoraEduWidgetContext {
        if let `subRoom` = subRoom {
            return subRoom.widget
        } else {
            return contextPool.widget
        }
    }
    
    private var contextPool: AgoraEduContextPool
    private var subRoom: AgoraEduSubRoomContext?
    
    var menuWidth: CGFloat = 0
    
    public weak var delegate: AgoraRenderMenuUIControllerDelegate?
    
    private var boardUsers = [String]()
    
    // Views
    private lazy var contentView = UIStackView()
    
    private lazy var micButton = UIButton(type: .custom)
    
    private lazy var cameraButton = UIButton(type: .custom)
    
    private lazy var stageButton = UIButton(type: .custom)
    
    private lazy var allStageOffButton = UIButton(type: .custom)
    
    private lazy var authButton = UIButton(type: .custom)
    
    private lazy var rewardButton = UIButton(type: .custom)
        
    // Data sources
    private var items: [AgoraRenderMenuItemType] = [] {
        didSet {
            if items != oldValue {
                self.reloadItems()
            }
        }
    }
    
    private var streamId: String? {
        get {
            guard let uid = self.userId else {
                return nil
            }
            return streamController.getStreamList(userUuid: uid)?.first?.streamUuid
        }
    }
    
    private(set) var userId: String? {
        didSet {
            guard userId != nil,
                  contentView != nil else {
                return
            }
            
            updateMenu()
        }
    }
    
    private var model: AgoraRenderMenuModel? {
        didSet {
            updateMenu()
        }
    }
    
    init(context: AgoraEduContextPool,
         subRoom: AgoraEduSubRoomContext? = nil,
         delegate: AgoraRenderMenuUIControllerDelegate? = nil) {
        self.contextPool = context
        self.subRoom = subRoom
        self.delegate = delegate
        
        super.init(nibName: nil,
                   bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        initViews()
        initViewFrame()
        updateViewProperties()
        
        streamController.registerStreamEventHandler(self)
        userController.registerUserEventHandler(self)
        widgetController.add(self,
                             widgetId: kBoardWidgetId)
    }
    
    func show(roomType: AgoraEduContextRoomType,
              userUuid: String,
              showRoleType: AgoraEduContextUserRole) {
        userId = userUuid

        switch roomType {
        case .oneToOne:
            if showRoleType == .teacher {
                items = []
            } else if showRoleType == .student {
                items = [.camera, .mic, .reward, .auth]
            }
        case .small:
            if showRoleType == .teacher {
                items = [.allOffStage]
            } else if showRoleType == .student {
                items = [.camera, .mic, .reward, .auth, .stage]
            }
        case .lecture:
            if showRoleType == .teacher {
                items = [.allOffStage]
            } else if showRoleType == .student {
                items = [.camera, .mic, .stage]
            }
        default:
            break
        }
        
        guard items.count > 0 else {
            view.isHidden = true
            return
        }
        view.isHidden = false
        // show VC,主动更新model信息
        updateModelState()
        
        // 5s后自动消失
        perform(#selector(dismissView),
                with: nil,
                afterDelay: 5)
    }
    
    @objc func dismissView() {
        view.isHidden = true
        self.userId = nil
        self.model = AgoraRenderMenuModel()
    }
}

// MARK: - AgoraUIActivity & AgoraUIContentContainer
@objc extension AgoraRenderMenuUIController: AgoraUIActivity, AgoraUIContentContainer {
    // AgoraUIActivity
    func viewWillActive() {
        
    }
    
    func viewWillInactive() {
        dismissView()
    }
    
    // AgoraUIContentContainer
    func initViews() {
        contentView.axis = .horizontal
        contentView.spacing = 10
        
        contentView.distribution = .equalSpacing
        contentView.alignment = .center
        view.addSubview(contentView)
        
        let buttonFrame = CGRect(x: 0,
                                 y: 0,
                                 width: 22,
                                 height: 22)
        
        // micButton
        micButton.frame = buttonFrame
        micButton.addTarget(self,
                            action: #selector(onClickMic(_:)),
                            for: .touchUpInside)
        contentView.addArrangedSubview(micButton)
        // cameraButton
        cameraButton.frame = buttonFrame
        cameraButton.addTarget(self,
                               action: #selector(onClickCamera(_:)),
                               for: .touchUpInside)
        contentView.addArrangedSubview(cameraButton)
        // stageButton
        stageButton.frame = buttonFrame
        stageButton.addTarget(self,
                              action: #selector(onClickStage(_:)),
                              for: .touchUpInside)
        contentView.addArrangedSubview(stageButton)
        // allStageOffButton
        allStageOffButton.frame = buttonFrame
        allStageOffButton.addTarget(self,
                                    action: #selector(onClickAllStageOff(_:)),
                                    for: .touchUpInside)
        contentView.addArrangedSubview(allStageOffButton)
        // authButton
        authButton.frame = buttonFrame
        authButton.addTarget(self,
                             action: #selector(onClickAuth(_:)),
                             for: .touchUpInside)
        contentView.addArrangedSubview(authButton)
        // rewardButton
        rewardButton.frame = buttonFrame
        rewardButton.setImage(UIImage.agedu_named("ic_member_menu_reward"),
                              for: .normal)
        rewardButton.addTarget(self,
                               action: #selector(onClickReward(_:)),
                               for: .touchUpInside)
        contentView.addArrangedSubview(rewardButton)
    }
    
    func initViewFrame() {
        contentView.mas_makeConstraints { make in
            make?.left.equalTo()(10)
            make?.right.equalTo()(10)
            make?.top.equalTo()(contentView.superview?.mas_top)?.offset()(1)
            make?.bottom.equalTo()(contentView.superview?.mas_bottom)?.offset()(-1)
        }
    }
    
    func updateViewProperties() {
        let ui = AgoraUIGroup()
        
        view.backgroundColor = FcrColorGroup.fcr_system_component_color
        view.layer.cornerRadius = ui.frame.fcr_round_container_corner_radius
        
        contentView.backgroundColor = FcrColorGroup.fcr_system_component_color
        
        FcrColorGroup.borderSet(layer: view.layer)
    }
}

// MARK: - Private
private extension AgoraRenderMenuUIController {
    func updateMenu() {
        guard let `model` = model else {
            return
        }
        // 设置按钮的状态
        for item in items {
            switch item {
            case .mic:
                if let img = model.micState.micImage {
                    micButton.setImageForAllStates(img)
                }
            case .camera:
                if let img = model.cameraState.cameraImage {
                    cameraButton.setImageForAllStates(img)
                }
            case .auth:
                // TODO: 切换图片
                guard let img = UIImage.agedu_named("ic_nameroll_auth")?.withRenderingMode(.alwaysTemplate) else {
                    return
                }
                authButton.tintColor = model.authState ? UIColor(hex: 0x0073FF) : UIColor(hex: 0xB3D6FF)
                authButton.setImageForAllStates(img)
            case .stage:
                stageButton.setImage(UIImage.agedu_named("ic_nameroll_stage"),
                                     for: .normal)
            case .allOffStage:
                allStageOffButton.setImage(UIImage.agedu_named("ic_member_menu_stage_off"),
                                           for: .normal)
                if let coHostList = userController.getCoHostList(),
                   coHostList.count > 0 {
                    allStageOffButton.isUserInteractionEnabled = true
                } else {
                    allStageOffButton.isUserInteractionEnabled = false
                }
            default:
                break
            }
        }
    }
    
    func reloadItems() {
        var views = [UIView]()
        for fn in items {
            switch fn {
            case .mic:
                views.append(self.micButton)
            case .camera:
                views.append(self.cameraButton)
            case .stage:
                views.append(self.stageButton)
            case .allOffStage:
                views.append(self.allStageOffButton)
            case .auth:
                views.append(self.authButton)
            case .reward:
                views.append(self.rewardButton)
            }
        }
        contentView.removeSubviews()
        contentView.addArrangedSubviews(views)
        
        menuWidth =  CGFloat(items.count) * 22 + CGFloat(items.count + 1) * 10
        let stackWidth = CGFloat(items.count) * 22 + CGFloat(items.count - 1) * 10
        
        self.contentView.mas_remakeConstraints { make in
            make?.width.equalTo()(stackWidth)
            make?.centerX.equalTo()(contentView.superview)
            make?.top.equalTo()(contentView.superview?.mas_top)?.offset()(1)
            make?.bottom.equalTo()(contentView.superview?.mas_bottom)?.offset()(-1)
        }
    }
    
    func updateModelState() {
        // board auth
        
        
        // Media
        guard let uid = userId else {
            return
        }
        let authState = self.boardUsers.contains(uid)
        var micState = AgoraRenderMenuModel.AgoraRenderMenuDeviceState.off
        var cameraState = AgoraRenderMenuModel.AgoraRenderMenuDeviceState.off
        
        if let stream = streamController.getStreamList(userUuid: uid)?.first {
            // audio
            if stream.audioSourceState == .close {
                micState = .forbidden
            } else if stream.streamType.hasAudio {
                micState = .on
            } else {
                micState = .off
            }
            
            // video
            if stream.videoSourceState == .close {
                cameraState = .forbidden
            } else if stream.streamType.hasVideo {
                cameraState = .on
            } else {
                cameraState = .off
            }
        }

        model = AgoraRenderMenuModel(micState: micState,
                                     cameraState: cameraState,
                                     authState: authState)
    }
}
// MARK: - Actions
extension AgoraRenderMenuUIController {
    @objc func onClickMic(_ sender: UIButton) {
        guard let UUID = self.userId,
              let `streamId` = self.streamId,
              let `model` = model else {
            return
        }
        if model.micState == .off {
            streamController.updateStreamPublishPrivilege(streamUuids: [streamId],
                                                          audioPrivilege: true) { [weak self] in
                self?.model?.micState = .on
            } failure: { error in
                
            }
        } else if model.micState == .on {
            streamController.updateStreamPublishPrivilege(streamUuids: [streamId],
                                                          audioPrivilege: false) { [weak self] in
                self?.model?.micState = .off
            } failure: { error in
                
            }
        }
    }
    
    @objc func onClickCamera(_ sender: UIButton) {
        guard let UUID = self.userId,
              let `streamId` = self.streamId,
              let `model` = model else {
            return
        }
        if model.cameraState == .off {
            streamController.updateStreamPublishPrivilege(streamUuids: [streamId],
                                                          videoPrivilege: true) { [weak self] in
                self?.model?.cameraState = .on
            } failure: { error in
                
            }
        } else if model.cameraState == .on {
            streamController.updateStreamPublishPrivilege(streamUuids: [streamId],
                                                          videoPrivilege: false) { [weak self] in
                self?.model?.cameraState = .off
            } failure: { error in
                
            }
        }
    }
    
    @objc func onClickStage(_ sender: UIButton) {
        guard let UUID = self.userId,
              let `model` = self.model else {
            return
        }
        
        userController.removeCoHost(userUuid: UUID) { [weak self] in
            self?.model?.authState = false
        } failure: { error in
            
        }
    }
    
    @objc func onClickAllStageOff(_ sender: UIButton) {
        userController.removeAllCoHosts { [weak self] in
            self?.updateMenu()
        } failure: { error in
            
        }
    }
    
    @objc func onClickAuth(_ sender: UIButton) {
        guard let UUID = self.userId,
              let `model` = self.model else {
            return
        }
        
        var list: Array<String> = self.boardUsers

        var ifAdd = false
        if model.authState == false,
           !list.contains(UUID) {
            // 授予白板权限
            ifAdd = true
        }
        let signal =  AgoraBoardWidgetSignal.UpdateGrantedUsers(ifAdd ? .add([UUID]) : .delete([UUID]))
        if let message = signal.toMessageString() {
            widgetController.sendMessage(toWidget: kBoardWidgetId,
                                         message: message)
        }
    }
    
    @objc func onClickReward(_ sender: UIButton) {
        guard let UUID = self.userId else {
            return
        }
        
        userController.rewardUsers(userUuidList: [UUID],
                                   rewardCount: 1,
                                   success: nil,
                                   failure: nil)
    }
}

// MARK: - AgoraEduUserHandler
extension AgoraRenderMenuUIController: AgoraEduUserHandler {
    func onRemoteUserLeft(user: AgoraEduContextUserInfo,
                          operatorUser: AgoraEduContextUserInfo?,
                          reason: AgoraEduContextUserLeaveReason) {
        guard let uid = self.userId,
              uid == user.userUuid else {
            return
        }
        delegate?.onMenuUserLeft()
    }
    
    func onCoHostUserListRemoved(userList: [AgoraEduContextUserInfo],
                                 operatorUser: AgoraEduContextUserInfo?) {
        guard let uid = self.userId,
              userList.contains(where: {$0.userUuid == uid}) else {
            return
        }
        delegate?.onMenuUserLeft()
    }
}

// MARK: - AgoraEduStreamHandler
extension AgoraRenderMenuUIController: AgoraEduStreamHandler {
    func onStreamJoined(stream: AgoraEduContextStreamInfo,
                        operatorUser: AgoraEduContextUserInfo?) {
        if stream.owner.userUuid == self.userId {
            updateModelState()
        }
    }
    
    func onStreamLeft(stream: AgoraEduContextStreamInfo,
                      operatorUser: AgoraEduContextUserInfo?) {
        if stream.owner.userUuid == self.userId {
            updateModelState()
        }
    }
    
    func onStreamUpdated(stream: AgoraEduContextStreamInfo,
                         operatorUser: AgoraEduContextUserInfo?) {
        if stream.owner.userUuid == self.userId {
            updateModelState()
        }
    }
}

// MARK: - AgoraWidgetMessageObserver
extension AgoraRenderMenuUIController: AgoraWidgetMessageObserver {
    func onMessageReceived(_ message: String,
                           widgetId: String) {
        guard widgetId == kBoardWidgetId,
              let signal = message.toBoardSignal() else {
                  return
              }
        switch signal {
        case .GetBoardGrantedUsers(let list):
            self.boardUsers = list
            if let uid = self.userId {
                model?.authState = self.boardUsers.contains(uid)
            }
        default:
            break
        }
    }
}
