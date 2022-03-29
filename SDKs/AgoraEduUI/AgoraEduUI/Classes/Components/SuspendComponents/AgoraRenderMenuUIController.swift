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

struct AgoraRenderMenuModel {
    enum AgoraRenderMenuDeviceState {
        case on, off, forbidden
        
        var micImage: UIImage? {
            switch self {
            case .on:
                return UIImage.agedu_named("ic_nameroll_mic_on")
            case .off:
                return UIImage.agedu_named("ic_nameroll_mic_off")
            case .forbidden:
                return UIImage.agedu_named("ic_member_menu_mic_forbidden")
            default:
                return nil
            }
        }
        
        var cameraImage: UIImage? {
            switch self {
            case .on:
                return UIImage.agedu_named("ic_nameroll_camera_on")
            case .off:
                return UIImage.agedu_named("ic_nameroll_camera_off")
            case .forbidden:
                return UIImage.agedu_named("ic_member_menu_camera_forbidden")
            default:
                return nil
            }
        }
    }

    // Data
    var micState = AgoraRenderMenuDeviceState.off
    var cameraState = AgoraRenderMenuDeviceState.off
    var authState = false
}

class AgoraRenderMenuUIController: UIViewController {
    
    var menuWidth: CGFloat = 0
    
    private enum AgoraRenderMenuItemType {
        case mic, camera, stage, allOffStage, auth, reward
    }
    
    public weak var delegate: AgoraRenderMenuUIControllerDelegate?
    
    private var contextPool: AgoraEduContextPool!
    
    private var boardUsers = [String]()
    
    // Views
    private var contentView: UIStackView!
    
    private var micButton: UIButton!
    
    private var cameraButton: UIButton!
    
    private var stageButton: UIButton!
    
    private var allStageOffButton: UIButton!
    
    private var authButton: UIButton!
    
    private var rewardButton: UIButton!
    
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
            return contextPool.stream.getStreamList(userUuid: uid)?.first?.streamUuid
        }
    }
    
    private(set) var userId: String? {
        didSet {
            if userId != nil, contentView != nil {
                updateMenu()
            }
        }
    }
    
    private var model: AgoraRenderMenuModel? {
        didSet {
            updateMenu()
        }
    }
    
    init(context: AgoraEduContextPool) {
        super.init(nibName: nil, bundle: nil)
        contextPool = context
        
        contextPool.stream.registerStreamEventHandler(self)
        contextPool.user.registerUserEventHandler(self)
        contextPool.widget.add(self,
                               widgetId: kBoardWidgetId)
    }
    
    func show(roomType: AgoraEduContextRoomType,
              userUuid: String,
              showRoleType: AgoraEduContextUserRole) {
        view.isHidden = false

        userId = userUuid

        switch roomType {
        case .oneToOne:
            if showRoleType == .teacher {
                items = [.camera, .mic]
            } else if showRoleType == .student {
                items = [.camera, .mic, .reward, .auth]
            }
        case .small:
            if showRoleType == .teacher {
                items = [.camera, .mic, .allOffStage]
            } else if showRoleType == .student {
                items = [.camera, .mic, .stage, .reward, .auth]
            }
        case .lecture:
            if showRoleType == .teacher {
                items = [.camera, .mic, .allOffStage]
            } else if showRoleType == .student {
                items = [.camera, .mic, .stage]
            }
        default:
            break
        }
        
        // show VC,主动更新model信息
        updateModelState()
        
        // 5s后自动消失
        self.perform(#selector(dismissView),
                     with: nil,
                     afterDelay: 5)
    }
    
    @objc func dismissView() {
        view.isHidden = true
        self.userId = nil
        self.model = AgoraRenderMenuModel()
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
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        view.layer.cornerRadius = self.view.bounds.height * 0.5
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
                if let coHostList = contextPool.user.getCoHostList(),
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
        
        if let stream = contextPool.stream.getStreamList(userUuid: uid)?.first {
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
            contextPool.stream.updateStreamPublishPrivilege(streamUuids: [streamId],
                                                            audioPrivilege: true) { [weak self] in
                self?.model?.micState = .on
            } failure: { error in
                
            }
        } else if model.micState == .on {
            contextPool.stream.updateStreamPublishPrivilege(streamUuids: [streamId],
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
            contextPool.stream.updateStreamPublishPrivilege(streamUuids: [streamId],
                                                            videoPrivilege: true) { [weak self] in
                self?.model?.cameraState = .on
            } failure: { error in
                
            }
        } else if model.cameraState == .on {
            contextPool.stream.updateStreamPublishPrivilege(streamUuids: [streamId],
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
        
        contextPool.user.removeCoHost(userUuid: UUID) { [weak self] in
            self?.model?.authState = false
        } failure: { error in
            
        }
    }
    
    @objc func onClickAllStageOff(_ sender: UIButton) {
        contextPool.user.removeAllCoHosts { [weak self] in
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
        if model.authState == false,
           !list.contains(UUID) {
            // 授予白板权限
            list.append(UUID)
        } else if model.authState == true,
                  list.contains(UUID){
            // 收回白板权限
            list.removeAll(UUID)
        }
        if let message = AgoraBoardWidgetSignal.BoardGrantDataChanged(list).toMessageString() {
            contextPool.widget.sendMessage(toWidget: kBoardWidgetId,
                                           message: message)
        }
    }
    
    @objc func onClickReward(_ sender: UIButton) {
        guard let UUID = self.userId else {
            return
        }
        
        contextPool.user.rewardUsers(userUuidList: [UUID],
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
        case .BoardGrantDataChanged(let list):
            self.boardUsers = list ?? [String]()
            if let uid = self.userId {
                model?.authState = self.boardUsers.contains(uid)
            }
        default:
            break
        }
    }
}
// MARK: - Creations
private extension AgoraRenderMenuUIController {
    func createViews() {
        view.backgroundColor = UIColor.white
        view.layer.cornerRadius = 8
        AgoraUIGroup().color.borderSet(layer: view.layer)
        
        // contentView
        contentView = UIStackView()
        contentView.backgroundColor = .clear
        contentView.axis = .horizontal
        contentView.spacing = 10

        contentView.distribution = .equalSpacing
        contentView.alignment = .center
        contentView.backgroundColor = .white
        view.addSubview(contentView)
        
        let buttonFrame = CGRect(x: 0,
                                 y: 0,
                                 width: 22,
                                 height: 22)

        // micButton
        micButton = UIButton(type: .custom)
        micButton.frame = buttonFrame
        micButton.addTarget(self,
                            action: #selector(onClickMic(_:)),
                            for: .touchUpInside)
        contentView.addArrangedSubview(micButton)
        // cameraButton
        cameraButton = UIButton(type: .custom)
        cameraButton.frame = buttonFrame
        cameraButton.addTarget(self,
                               action: #selector(onClickCamera(_:)),
                               for: .touchUpInside)
        contentView.addArrangedSubview(cameraButton)
        // stageButton
        stageButton = UIButton(type: .custom)
        stageButton.frame = buttonFrame
        stageButton.addTarget(self,
                              action: #selector(onClickStage(_:)),
                              for: .touchUpInside)
        contentView.addArrangedSubview(stageButton)
        // allStageOffButton
        allStageOffButton = UIButton(type: .custom)
        allStageOffButton.frame = buttonFrame
        allStageOffButton.addTarget(self,
                              action: #selector(onClickAllStageOff(_:)),
                              for: .touchUpInside)
        contentView.addArrangedSubview(allStageOffButton)
        // authButton
        authButton = UIButton(type: .custom)
        authButton.frame = buttonFrame
        authButton.addTarget(self,
                             action: #selector(onClickAuth(_:)),
                             for: .touchUpInside)
        contentView.addArrangedSubview(authButton)
        // rewardButton
        rewardButton = UIButton(type: .custom)
        rewardButton.frame = buttonFrame
        rewardButton.setImage(UIImage.agedu_named("ic_member_menu_reward"),
                              for: .normal)
        rewardButton.addTarget(self,
                               action: #selector(onClickReward(_:)),
                               for: .touchUpInside)
        contentView.addArrangedSubview(rewardButton)
    }
    
    func createConstraint() {
        contentView.mas_makeConstraints { make in
            make?.left.equalTo()(10)
            make?.right.equalTo()(10)
            make?.top.equalTo()(contentView.superview?.mas_top)?.offset()(1)
            make?.bottom.equalTo()(contentView.superview?.mas_bottom)?.offset()(-1)
        }
    }
}
