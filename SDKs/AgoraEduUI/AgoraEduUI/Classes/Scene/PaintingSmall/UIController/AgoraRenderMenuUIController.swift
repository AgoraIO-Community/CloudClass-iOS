//
//  MemberMenuViewController.swift
//  AgoraEduUI
//
//  Created by HeZhengQing on 2021/9/28.
//

import UIKit
import Masonry
import AgoraEduContext

protocol AgoraRenderMenuUIControllerDelegate: NSObjectProtocol {
    /** menu指向的台上用户消失了*/
    func onMenuResignedUser()
}

class AgoraRenderMenuUIController: UIViewController {
    
    private enum AgoraRenderMenuItem {
        case mic, camera, stage, auth, reward
    }
    
    public weak var delegate: AgoraRenderMenuUIControllerDelegate?
    
    private var contentView: UIStackView!
    
    private var micButton: UIButton!
    
    private var cameraButton: UIButton!
    
    private var stageButton: UIButton!
    
    private var authButton: UIButton!
    
    private var rewardButton: UIButton!
    
    private var items: [AgoraRenderMenuItem] = [
        .mic, .camera, .stage, .auth] {
        didSet {
            if items != oldValue {
                self.reloadItems()
            }
        }
    }
    
    private var contextPool: AgoraEduContextPool!
    
    var userUUID: String? {
        didSet {
            if userUUID != nil, contentView != nil {
                updateView()
            }
        }
    }
    
    init(context: AgoraEduContextPool) {
        super.init(nibName: nil, bundle: nil)
        contextPool = context
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        createViews()
        createConstrains()
        contextPool.user.registerEventHandler(self)
        contextPool.stream.registerStreamEventHandler(self)
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        view.layer.cornerRadius = self.view.bounds.height * 0.5
    }
}
// MARK: - Private
private extension AgoraRenderMenuUIController {
    func updateView() {
        let user = contextPool.user.getLocalUserInfo()

        if user.role == .teacher {
            items = [.mic, .camera, .stage]
        } else if user.role == .student {
            items = [.mic, .camera, .stage, .auth, .reward]
        }
        let s = contextPool.stream.getStreamInfo(userUuid: user.userUuid)?.first
        // 设置按钮的状态
        
        // TODO:
//        for fn in items {
//            switch fn {
//            case .mic:
//                micButton.isSelected = (s?.streamType == .audioAndVideo || s?.streamType == .audio)
//            case .camera:
//                cameraButton.isSelected = (s?.streamType == .audioAndVideo || s?.streamType == .video)
//            case .auth:
//                authButton.isSelected = user.boardGranted
//            default: break
//            }
//        }
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
            case .auth:
                views.append(self.authButton)
            case .reward:
                views.append(self.rewardButton)
            }
        }
        contentView.removeSubviews()
        contentView.addArrangedSubviews(views)
        let width = 28 * views.count
        self.contentView.mas_remakeConstraints { make in
            make?.width.equalTo()(width)
            make?.height.equalTo()(36)
            make?.left.equalTo()(14)
            make?.right.equalTo()(-14)
            make?.top.bottom().equalTo()(0)
        }
    }
}
// MARK: - Actions
extension AgoraRenderMenuUIController {
    @objc func onClickMic(_ sender: UIButton) {
        guard let UUID = self.userUUID else {
            return
        }
        if contextPool.user.getLocalUserInfo().userUuid == UUID {
            // TODO:
//            self.contextPool.device.setMicDeviceEnable(enable: !sender.isSelected)
            sender.isSelected = !sender.isSelected
        } else {
            
            
//            contextPool.stream.muteRemoteAudio(streamUuids: [UUID], mute: sender.isSelected, success: {
//                sender.isSelected = !sender.isSelected
//            }, failure: nil)
        }
    }
    
    @objc func onClickCamera(_ sender: UIButton) {
        guard let UUID = self.userUUID else {
            return
        }
        if contextPool.user.getLocalUserInfo().userUuid == UUID {
            // TODO:
//            self.contextPool.device.setCameraDeviceEnable(enable: !sender.isSelected)
            sender.isSelected = !sender.isSelected
        } else {
//            contextPool.stream.muteRemoteVideo(streamUuids: [UUID], mute: sender.isSelected, success: {
//                sender.isSelected = !sender.isSelected
//            }, failure: nil)
        }
    }
    
    @objc func onClickStage(_ sender: UIButton) {
        guard let UUID = self.userUUID else {
            return
        }

        contextPool.user.removeCoHost(userUuid: UUID,
                                       success: nil,
                                       failure: nil)
    }
    
    @objc func onClickAuth(_ sender: UIButton) {
        guard let UUID = self.userUUID else {
            return
        }
        // TODO: 白板权限
//        contextPool.user.updateBoardGranted(userUuids: [UUID],
//                                            granted: false)
//        sender.isSelected = true
    }
    
    @objc func onClickReward(_ sender: UIButton) {
        guard let UUID = self.userUUID else {
            return
        }
        contextPool.user.rewardUsers(userUuids: [UUID],
                                     rewardCount: 1,
                                     success: nil, failure: nil)
    }
}
// MARK: - AgoraEduUserHandler
extension AgoraRenderMenuUIController: AgoraEduUserHandler {
    func onUserUpdated(user: AgoraEduContextUserInfo,
                       operator: AgoraEduContextUserInfo?) {
        if let UUID = self.userUUID,
           user.userUuid == UUID {
            // TODO: 没看懂
//            updateView()
//            self.userUUID = nil
//            delegate?.onMenuResignedUser()
        }
    }
}

// MARK: - AgoraEduStreamHandler
extension AgoraRenderMenuUIController: AgoraEduStreamHandler {
    func onStreamJoin(stream: AgoraEduContextStream,
                      operator: AgoraEduContextUserInfo?) {
        if stream.owner.userUuid == self.userUUID {
            updateView()
        }
    }
    
    func onStreamLeave(stream: AgoraEduContextStream,
                       operator: AgoraEduContextUserInfo?) {
        if stream.owner.userUuid == self.userUUID {
            updateView()
        }
    }
    
    func onStreamUpdate(stream: AgoraEduContextStream,
                        operator: AgoraEduContextUserInfo?) {
        if stream.owner.userUuid == self.userUUID {
            updateView()
        }
    }
}
// MARK: - Creations
private extension AgoraRenderMenuUIController {
    func createViews() {
        view.backgroundColor = UIColor.white
        view.layer.cornerRadius = 8
        view.layer.shadowColor = UIColor(rgb:0x2F4192).withAlphaComponent(0.15).cgColor
        view.layer.shadowOffset = CGSize(width: 0, height: 2)
        view.layer.shadowOpacity = 1
        view.layer.shadowRadius = 6
        // contentView
        contentView = UIStackView()
        contentView.backgroundColor = .clear
        contentView.axis = .horizontal
        contentView.spacing = 2
        contentView.distribution = .equalSpacing
        contentView.alignment = .center
        contentView.backgroundColor = .white
        view.addSubview(contentView)
        
        let buttonFrame = CGRect(x: 0, y: 0, width: 32, height: 32)
        // micButton
        micButton = UIButton(type: .custom)
        micButton.frame = buttonFrame
        micButton.setImage(AgoraUIImage(object: self,
                                        name: "ic_member_menu_mic_off"),
                           for: .normal)
        micButton.setImage(AgoraUIImage(object: self,
                                        name: "ic_member_menu_mic_on"),
                           for: .selected)
        micButton.addTarget(self,
                            action: #selector(onClickMic(_:)),
                            for: .touchUpInside)
        contentView.addArrangedSubview(micButton)
        // cameraButton
        cameraButton = UIButton(type: .custom)
        cameraButton.frame = buttonFrame
        cameraButton.setImage(AgoraUIImage(object: self,
                                           name: "ic_member_menu_camera_off"),
                              for: .normal)
        cameraButton.setImage(AgoraUIImage(object: self,
                                           name: "ic_member_menu_camera_on"),
                              for: .selected)
        cameraButton.addTarget(self,
                               action: #selector(onClickCamera(_:)),
                               for: .touchUpInside)
        contentView.addArrangedSubview(cameraButton)
        // stageButton
        stageButton = UIButton(type: .custom)
        stageButton.frame = buttonFrame
        stageButton.setImage(AgoraUIImage(object: self,
                                          name: "ic_member_menu_stage"),
                             for: .normal)
        stageButton.addTarget(self,
                              action: #selector(onClickStage(_:)),
                              for: .touchUpInside)
        contentView.addArrangedSubview(stageButton)
        // authButton
        authButton = UIButton(type: .custom)
        authButton.frame = buttonFrame
        authButton.setImage(AgoraUIImage(object: self,
                                         name: "ic_member_menu_auth"),
                            for: .normal)
        authButton.addTarget(self,
                             action: #selector(onClickAuth(_:)),
                             for: .touchUpInside)
        contentView.addArrangedSubview(authButton)
        // rewardButton
        rewardButton = UIButton(type: .custom)
        rewardButton.frame = buttonFrame
        rewardButton.setImage(AgoraUIImage(object: self,
                                           name: "ic_member_menu_star"),
                              for: .normal)
        rewardButton.addTarget(self,
                               action: #selector(onClickReward(_:)),
                               for: .touchUpInside)
        contentView.addArrangedSubview(rewardButton)
    }
    
    func createConstrains() {
        contentView.mas_makeConstraints { make in
            make?.left.equalTo()(12)
            make?.right.equalTo()(-12)
            make?.top.bottom().equalTo()(contentView.superview)
        }
    }
}
