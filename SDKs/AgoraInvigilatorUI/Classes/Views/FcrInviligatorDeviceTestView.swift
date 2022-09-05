//
//  FcrInviligatorDevice.swift
//  AgoraInvigilatorUI
//
//  Created by DoubleCircle on 2022/9/4.
//

import AgoraUIBaseViews

class FcrInviligatorDeviceTestView: UIView {
    /**views**/
    private lazy var backgroundImageView = UIImageView()
    private(set) lazy var exitButton = UIButton()
    private lazy var titleLabel = UILabel()
    private(set) lazy var greetLabel = UILabel()
    private(set) lazy var stateLabel = UILabel()
    private(set) lazy var enterButton = UIButton()
    
    /**data**/
    var userName: String = "" {
        didSet {
            guard userName != oldValue else {
                return
            }
            updateUserName()
        }
    }
    
    var roomName: String = ""  {
        didSet {
            guard roomName != oldValue else {
                return
            }
            updateRoomInfo()
        }
    }
    
    var roomState: FcrUIRoomState = .before  {
        didSet {
            guard roomState != oldValue else {
                return
            }
            updateRoomInfo()
        }
    }
    
    convenience init(renderView: FcrInviligatorRenderView) {
        self.init(frame: .zero)
        
        initViews()
        initViewFrame()
        updateViewProperties()
    }
    
    func updateInfo(userName: String,
                    roomName: String) {
        
    }
    
    func updateRoomState(roomState: FcrUIRoomState) {
        
    }
    
    private override init(frame: CGRect) {
        super.init(frame: frame)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

// MARK: - AgoraUIContentContainer
extension FcrInviligatorDeviceTestView: AgoraUIContentContainer {
    func initViews() {
        titleLabel.text = "fcr_device_device".fcr_invigilator_localized()
        
        let greet = "fcr_device_greet".fcr_invigilator_localized()
        let finalGreet = greet.replacingOccurrences(of: String.agedu_localized_replacing_x(),
                                                 with: userName)
        greetLabel.text = finalGreet
        
        let state = "fcr_device_state_will_start".fcr_invigilator_localized()
        let finalState = state.replacingOccurrences(of: String.agedu_localized_replacing_x(),
                                                 with: roomName)
        stateLabel.text = finalState
        
        addSubviews([backgroundImageView,
                     exitButton,
                     titleLabel,
                     greetLabel,
                     stateLabel,
                     enterButton])
    }
    
    func initViewFrame() {
        backgroundImageView.mas_makeConstraints { make in
            make?.left.right().top().equalTo()(0)
        }
        
        exitButton.mas_makeConstraints { make in
            make?.top.equalTo()(42)
            make?.left.equalTo()(16)
            make?.width.height().equalTo()(40)
        }
        
        titleLabel.mas_makeConstraints { make in
            make?.centerX.equalTo()(0)
            make?.centerY.equalTo()(exitButton.mas_centerY)
            make?.width.mas_greaterThanOrEqualTo()(122)
        }
        
        greetLabel.mas_makeConstraints { make in
            make?.top.equalTo()(exitButton.mas_bottom)?.offset()(30)
            make?.left.equalTo()(30)
            make?.width.height().equalTo()(40)
        }
        
        stateLabel.mas_makeConstraints { make in
            make?.top.equalTo()(greetLabel.mas_bottom)?.offset()(11)
            make?.left.equalTo()(greetLabel.mas_left)
            make?.right.equalTo()(0)
        }
    }
    
    func updateViewProperties() {
        let config = UIConfig.deviceTest
        
        backgroundImageView.image = config.backgroundImage
        exitButton.setImage(config.exit.image,
                            for: .normal)
        exitButton.backgroundColor = config.exit.backgroundColor
        exitButton.layer.cornerRadius = config.exit.cornerRadius
        
        titleLabel.font = config.titleLabel.font
        titleLabel.textColor = config.titleLabel.color
    }
}

// MARK: - private
private extension FcrInviligatorDeviceTestView {
    func updateRoomInfo() {
        var state = ""
        switch roomState {
        case .before:
            state = "fcr_device_state_will_start".fcr_invigilator_localized()
        case .during:
            state = "fcr_device_state_already_start".fcr_invigilator_localized()
        default:
            return
        }
        let finalState = state.replacingOccurrences(of: String.agedu_localized_replacing_x(),
                                                    with: roomName)
        stateLabel.text = finalState
    }
    
    func updateUserName() {
        let greet = "fcr_device_greet".fcr_invigilator_localized()
        let finalGreet = greet.replacingOccurrences(of: String.agedu_localized_replacing_x(),
                                                 with: userName)
        greetLabel.text = finalGreet
    }
}
