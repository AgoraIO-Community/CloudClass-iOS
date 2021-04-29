//
//  AgoraHandsUpView.swift
//  AgoraUIEduBaseViews
//
//  Created by LYY on 2021/3/12.
//

import AgoraUIEduBaseViews
import AgoraUIBaseViews
import AgoraEduContext

fileprivate let MAXCOUNT = 3

@objcMembers public class AgoraHandsUpView : AgoraBaseUIView {
    
    public weak var context: AgoraEduHandsUpContext?
    public var isEnable: Bool = false {
        didSet {
            self.updateStateWithCoHost()
        }
    }
    public var isCoHost: Bool = false {
        didSet {
            self.updateStateWithCoHost()
        }
    }
    public var state: AgoraEduContextHandsUpState = .default {
        didSet {
            self.updateStateWithCoHost()
        }
    }

    fileprivate var timer: DispatchSourceTimer?

    //MARK: init
    public override init(frame: CGRect) {
        super.init(frame: .zero)
        self.initView()
        self.initLayout()
        self.isHidden = true
    }
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    fileprivate func initView() {
        addSubview(timeCountView)
        addSubview(handsUpBtn)
    }
    
    fileprivate func initLayout() {
        timeCountView.agora_x = 7
        timeCountView.agora_height = 47
        timeCountView.agora_y = 0
        timeCountView.agora_width = 42
        
        handsUpBtn.agora_x = 0
        handsUpBtn.agora_right = 0
        handsUpBtn.agora_y = timeCountView.agora_height + 3
        handsUpBtn.agora_width = 56
        handsUpBtn.agora_height = handsUpBtn.agora_width
        handsUpBtn.agora_bottom = 0
    }
    
    //MARK: lazy load
    fileprivate lazy var timeCountLabel: AgoraBaseUILabel = {
        let label = AgoraBaseUILabel()
        label.text = "\(MAXCOUNT)"
        label.font = .boldSystemFont(ofSize: 16)
        label.textAlignment = .center
        label.textColor = .init(red: 68/255.0, green: 162/255.0, blue: 252/255.0, alpha: 1)
    
        return label
    }()
    
    fileprivate lazy var timeCountView: AgoraBaseUIImageView = {
        let imgView = AgoraBaseUIImageView(image: AgoraKitImage("bubble"))
        imgView.addSubview(timeCountLabel)
        timeCountLabel.agora_x = 0
        timeCountLabel.agora_y = 12
        timeCountLabel.agora_width = 42
        
        imgView.isHidden = true
        return imgView
    }()
    
    fileprivate lazy var handsUpBtn: AgoraBaseUIButton = {
        let btn = AgoraBaseUIButton()
        btn.backgroundColor = .clear;
        btn.setImage(AgoraKitImage("hands_down_default"), for: .normal)
        
        btn.addTarget(self, action: #selector(onButtonClick(_:)), for: .touchDown)
        btn.addTarget(self, action: #selector(onButtonCancel(_:)), for: .touchUpInside)
        btn.addTarget(self, action: #selector(onButtonCancel(_:)), for: .touchUpOutside)
        
        return btn
    }()

    deinit {
        self.stopTimer()
    }
}

// MARK: UI action
extension AgoraHandsUpView {
    @objc func onButtonClick(_ btn: UIButton) {
        self.startTimer()
    }

    @objc func onButtonCancel(_ btn: UIButton) {
        self.stopTimer()
    }

    fileprivate func startTimer() {
 
        self.stopTimer()
        
        self.timeCountView.isHidden = false
        timer = DispatchSource.makeTimerSource(flags: [], queue: DispatchQueue.global())
        timer?.schedule(deadline: .now() + 1, repeating: 1)
        timer?.setEventHandler { [weak self] in
            DispatchQueue.main.async {
                guard let `self` = self, let count = self.timeCountLabel.text else {
                    return
                }
    
                let val = (Int(count) ?? 0) - 1
                if val <= 0 {
                    self.timeCountView.isHidden = true
                    self.timeCountLabel.text = "\(MAXCOUNT)"
                    self.timer?.cancel()
                    
                    var kitState: AgoraEduContextHandsUpState = .handsUp
                    if self.state == .handsUp {
                        kitState = .handsDown
                    }
                    self.context?.updateHandsUpState(kitState)
                } else {
                    self.timeCountLabel.text = "\(val)"
                }
            }
        }
        timer?.resume()
    }
    
    fileprivate func stopTimer() {
        self.timeCountView.isHidden = true
        self.timeCountLabel.text = "\(MAXCOUNT)"
        
        if !(timer?.isCancelled ?? true) {
            timer?.cancel()
        }
    }
    
    /// Only called when enabled,which means the view is visible
    fileprivate func updateStateWithCoHost() {
        self.isHidden = false
        if !self.isEnable {
            self.isHidden = true
            return
        }
        
        if isCoHost {
            handsUpBtn.setImage(AgoraKitImage("hands_up_cohost"), for: .normal)
            handsUpBtn.isUserInteractionEnabled = false
            return
        }
        
        let imageString = self.state == .handsUp ? "hands_up_waiting" : "hands_down_default"
        handsUpBtn.setImage(AgoraKitImage(imageString), for: .normal)
        handsUpBtn.isUserInteractionEnabled = true
    }
}

// MARK: - AgoraEduHandsUpHandler
@objc extension AgoraHandsUpView : AgoraEduHandsUpHandler {

    public func onSetHandsUpEnable(_ enable: Bool) {
        self.isEnable = enable
    }
    public func onSetHandsUpState(_ state: AgoraEduContextHandsUpState) {
        self.state = state
    }
    
    public func onUpdateHandsUpStateResult(_ error: AgoraEduContextError?) {
        if let err = error {
            AgoraUtils.showToast(message: err.message)
        }
    }

    public func onShowHandsUpTips(_ message: String) {
        AgoraUtils.showToast(message: message)
    }
}
