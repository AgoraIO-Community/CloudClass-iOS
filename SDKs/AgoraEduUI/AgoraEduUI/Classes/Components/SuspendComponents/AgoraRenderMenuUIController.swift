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

struct AgoraRenderMenuModel: Equatable {
    
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
    
    // UI
    var stageImage: UIImage? {
        return UIImage.agedu_named("ic_nameroll_stage")?.withRenderingMode(.alwaysTemplate)
    }
    
    var noneStageImage: UIImage? {
        return UIImage.agedu_named("ic_member_menu_stage_off")
    }
    
    var authImage: UIImage? {
        return UIImage.agedu_named("ic_nameroll_auth")?.withRenderingMode(.alwaysTemplate)
    }
    
    var rewardImage: UIImage? {
        return UIImage.agedu_named("ic_member_menu_reward")
    }
    
    // Data
    var micState = AgoraRenderMenuDeviceState.off
    var cameraState = AgoraRenderMenuDeviceState.off
    var stageState = false
    var authState = false
    
    static func ==(left: AgoraRenderMenuModel,
                   right: AgoraRenderMenuModel) -> Bool {
        guard left.micState == right.micState,
              left.cameraState == right.cameraState,
              left.stageState == right.stageState,
              left.authState == right.authState else {
            return false
        }
        return true
    }
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
    
    private var model = AgoraRenderMenuModel() {
        didSet {
            if model != oldValue {
                updateMenu()
            }
        }
    }
    
    init(context: AgoraEduContextPool) {
        super.init(nibName: nil, bundle: nil)
        contextPool = context
        
        contextPool.widget.add(self,
                               widgetId: kBoardWidgetId)
    }
    
    func show(roomType: AgoraEduContextRoomType,
              userUuid: String,
              showRoleType: AgoraEduContextUserRole) {
        userId = userUuid
        model.authState = self.boardUsers.contains(userUuid)
        switch roomType {
        case .oneToOne:
            if showRoleType == .teacher {
                items = [.mic, .camera]
            } else if showRoleType == .student {
                items = [.mic, .camera, .reward, .auth]
            }
        case .small:
            if showRoleType == .teacher {
                items = [.mic, .camera, .allOffStage]
            } else if showRoleType == .student {
                items = [.mic, .camera, .stage, .reward, .auth]
            }
        case .lecture:
            if showRoleType == .teacher {
                items = [.mic, .camera, .allOffStage]
            } else if showRoleType == .student {
                items = [.mic, .camera, .stage]
            }
        default:
            break
        }
        
        // show VC,主动更新model信息
        updateMediaState()
    }
    
    func dismissView() {
        self.userId = nil
        self.model = AgoraRenderMenuModel()
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
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        view.layer.cornerRadius = self.view.bounds.height * 0.5
    }
}
// MARK: - Private
private extension AgoraRenderMenuUIController {
    func updateMenu() {
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
                guard let img = model.authImage else {
                    return
                }
                authButton.tintColor = model.authState ? UIColor(hex: 0x0073FF) : UIColor(hex: 0xB3D6FF)
                authButton.setImageForAllStates(img)
            case .stage:
                guard let img = model.stageImage else {
                    return
                }
                stageButton.tintColor = model.stageState ? UIColor(hex: 0x0073FF) : UIColor(hex: 0xB3D6FF)
                stageButton.setImageForAllStates(img)
            case .allOffStage:
                if let coHostList = contextPool.user.getCoHostList(),
                   coHostList.count > 0 {
                    allStageOffButton.isUserInteractionEnabled = true
                    allStageOffButton.tintColor = UIColor(hex: 0x0073FF)
                    allStageOffButton.setImage(model.stageImage,
                                               for: .normal)
                } else {
                    allStageOffButton.isUserInteractionEnabled = false
                    allStageOffButton.tintColor = UIColor(hex: 0xB3D6FF)
                    allStageOffButton.setImage(model.noneStageImage,
                                               for: .normal)
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
        
        menuWidth =  CGFloat(items.count) * AgoraFit.scale(22) + CGFloat(items.count + 1) * AgoraFit.scale(12)
        let stackWidth = CGFloat(items.count) * AgoraFit.scale(22) + CGFloat(items.count - 1) * AgoraFit.scale(12)
        
        self.contentView.mas_remakeConstraints { make in
            make?.width.equalTo()(stackWidth)
            make?.centerX.equalTo()(contentView.superview)
            make?.top.equalTo()(contentView.superview?.mas_top)?.offset()(1)
            make?.bottom.equalTo()(contentView.superview?.mas_bottom)?.offset()(-1)
        }
    }
    
    func updateMediaState() {
        guard let uid = userId,
              let stream = contextPool.stream.getStreamList(userUuid: uid)?.first else {
            return
        }
        var micState = AgoraRenderMenuModel.AgoraRenderMenuDeviceState.off
        var cameraState = AgoraRenderMenuModel.AgoraRenderMenuDeviceState.off
        
        // audio
        if stream.streamType.hasAudio,
           stream.audioSourceState == .open {
            micState = .on
        } else if stream.streamType.hasAudio,
                  stream.audioSourceState == .close {
            micState = .off
        } else if stream.streamType.hasAudio == false,
                  stream.audioSourceState == .open {
            micState = .forbidden
        }
        
        // video
        if stream.streamType.hasVideo,
           stream.videoSourceState == .open {
            cameraState = .on
        } else if stream.streamType.hasVideo,
                  stream.videoSourceState == .close {
            cameraState = .off
        } else if stream.streamType.hasVideo == false,
                  stream.videoSourceState == .open {
            cameraState = .forbidden
        }
        
        model = AgoraRenderMenuModel(micState: micState,
                                     cameraState: cameraState,
                                     stageState: model.stageState,
                                     authState: model.authState)
    }
}
// MARK: - Actions
extension AgoraRenderMenuUIController {
    @objc func onClickMic(_ sender: UIButton) {
        guard let UUID = self.userId,
              let `streamId` = self.streamId else {
            return
        }
        if model.micState == .off {
            contextPool.stream.updateStreamPublishPrivilege(streamUuids: [streamId],
                                                            audioPrivilege: true) { [weak self] in
                self?.model.micState = .on
            } failure: { error in
                
            }
        } else if model.micState == .on {
            contextPool.stream.updateStreamPublishPrivilege(streamUuids: [streamId],
                                                            audioPrivilege: false) { [weak self] in
                self?.model.micState = .off
            } failure: { error in
                
            }
        }
    }
    
    @objc func onClickCamera(_ sender: UIButton) {
        guard let UUID = self.userId,
              let `streamId` = self.streamId else {
            return
        }
        if model.cameraState == .off {
            contextPool.stream.updateStreamPublishPrivilege(streamUuids: [streamId],
                                                            videoPrivilege: true) { [weak self] in
                self?.model.cameraState = .on
            } failure: { error in
                
            }
        } else if model.micState == .on {
            contextPool.stream.updateStreamPublishPrivilege(streamUuids: [streamId],
                                                            audioPrivilege: false) { [weak self] in
                self?.model.cameraState = .off
            } failure: { error in
                
            }
        }
    }
    
    @objc func onClickStage(_ sender: UIButton) {
        guard let UUID = self.userId else {
            return
        }
        
        contextPool.user.removeCoHost(userUuid: UUID) { [weak self] in
            guard let `self` = self else {
                return
            }
            self.model.authState = false
        } failure: { error in
            
        }
    }
    
    @objc func onClickAllStageOff(_ sender: UIButton) {
        contextPool.user.removeAllCoHosts { [weak self] in
            guard let `self` = self else {
                return
            }
            self.updateMenu()
        } failure: { error in
            
        }
    }
    
    @objc func onClickAuth(_ sender: UIButton) {
        guard let UUID = self.userId else {
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
    func onStreamJoin(stream: AgoraEduContextStreamInfo,
                      operatorUser: AgoraEduContextUserInfo?) {
        if stream.owner.userUuid == self.userId {
            updateMediaState()
        }
    }
    
    func onStreamLeave(stream: AgoraEduContextStreamInfo,
                       operatorUser: AgoraEduContextUserInfo?) {
        if stream.owner.userUuid == self.userId {
            updateMediaState()
        }
    }
    
    func onStreamUpdate(stream: AgoraEduContextStreamInfo,
                        operatorUser: AgoraEduContextUserInfo?) {
        if stream.owner.userUuid == self.userId {
            updateMediaState()
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
                model.authState = self.boardUsers.contains(uid)
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
        view.layer.shadowColor = UIColor(hex: 0x2F4192,
                                         transparency: 0.15)?.cgColor
        view.layer.shadowOffset = CGSize(width: 0, height: 2)
        view.layer.shadowOpacity = 1
        view.layer.shadowRadius = 6
        
        // contentView
        contentView = UIStackView()
        contentView.backgroundColor = .clear
        contentView.axis = .horizontal
        contentView.spacing = 12
        contentView.distribution = .equalSpacing
        contentView.alignment = .center
        contentView.backgroundColor = .white
        view.addSubview(contentView)
        
        let buttonFrame = CGRect(x: 0, y: 0, width: 32, height: 32)
        // micButton
        micButton = UIButton(type: .custom)
        micButton.frame = buttonFrame
        micButton.setImage(model.micState.micImage,
                             for: .normal)
        micButton.addTarget(self,
                            action: #selector(onClickMic(_:)),
                            for: .touchUpInside)
        contentView.addArrangedSubview(micButton)
        // cameraButton
        cameraButton = UIButton(type: .custom)
        cameraButton.frame = buttonFrame
        cameraButton.setImage(model.cameraState.cameraImage,
                             for: .normal)
        cameraButton.addTarget(self,
                               action: #selector(onClickCamera(_:)),
                               for: .touchUpInside)
        contentView.addArrangedSubview(cameraButton)
        // stageButton
        stageButton = UIButton(type: .custom)
        stageButton.frame = buttonFrame
        stageButton.setImage(model.stageImage,
                             for: .normal)
        stageButton.addTarget(self,
                              action: #selector(onClickStage(_:)),
                              for: .touchUpInside)
        contentView.addArrangedSubview(stageButton)
        // allStageOffButton
        allStageOffButton = UIButton(type: .custom)
        allStageOffButton.frame = buttonFrame
        allStageOffButton.setImage(model.stageImage,
                             for: .normal)
        allStageOffButton.addTarget(self,
                              action: #selector(onClickAllStageOff(_:)),
                              for: .touchUpInside)
        contentView.addArrangedSubview(allStageOffButton)
        // authButton
        authButton = UIButton(type: .custom)
        authButton.frame = buttonFrame
        authButton.setImage(model.authImage,
                             for: .normal)
        authButton.addTarget(self,
                             action: #selector(onClickAuth(_:)),
                             for: .touchUpInside)
        contentView.addArrangedSubview(authButton)
        // rewardButton
        rewardButton = UIButton(type: .custom)
        rewardButton.frame = buttonFrame
        rewardButton.setImage(model.rewardImage,
                              for: .normal)
        rewardButton.addTarget(self,
                               action: #selector(onClickReward(_:)),
                               for: .touchUpInside)
        contentView.addArrangedSubview(rewardButton)
    }
    
    func createConstrains() {
        contentView.mas_makeConstraints { make in
            make?.left.equalTo()(14)
            make?.right.equalTo()(-14)
            make?.top.equalTo()(contentView.superview?.mas_top)?.offset()(1)
            make?.bottom.equalTo()(contentView.superview?.mas_bottom)?.offset()(-1)
        }
    }
}
