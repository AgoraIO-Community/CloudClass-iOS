//
//  AgoraHandsUpView.swift
//  AgoraUIEduBaseViews
//
//  Created by LYY on 2021/3/12.
//

import AgoraUIBaseViews
import AgoraEduContext

fileprivate let MAXCOUNT = 3

@objcMembers public class AgoraHandsUpView : AgoraBaseUIView,AgoraEduHandsUpHandler {
    
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
        label.font = .boldSystemFont(ofSize: 17)
        label.textAlignment = .center
        label.textColor = UIColor.white
        label.backgroundColor = UIColor(red: 53/255.0, green:123/255.0, blue: 246/255.0, alpha: 1)
        
        label.layer.shadowColor = UIColor(red: 0.18, green: 0.25, blue: 0.57, alpha: 0.15).cgColor
        label.layer.shadowOffset = CGSize(width: 0, height: 2)
        label.layer.shadowOpacity = 1
        label.layer.shadowRadius = 8
        
        return label
    }()
    
    fileprivate lazy var timeCountView: AgoraBaseUIImageView = {
        let imgView = AgoraBaseUIImageView(image: AgoraKitImage("bubble"))
        imgView.isHidden = true
        return imgView
    }()
    
    fileprivate lazy var handsUpBtn: AgoraBaseUIButton = {
        let btn = AgoraBaseUIButton()
        btn.backgroundColor = .clear;
        btn.setImage(AgoraKitImage("hands_down_default"), for: .normal)
        
        btn.addSubview(timeCountLabel)
        timeCountLabel.agora_width = 40
        timeCountLabel.agora_height = 40
        timeCountLabel.agora_center_x = btn.agora_center_x
        timeCountLabel.agora_center_y = btn.agora_center_y
        timeCountLabel.clipsToBounds = true
        timeCountLabel.layer.cornerRadius = 20
        self.timeCountLabel.isHidden = true
        
        btn.addTarget(self, action: #selector(onBtnDown(_:)), for: .touchDown)
        btn.addTarget(self, action: #selector(onBtnUp(_:)), for: .touchUpInside)
        
        return btn
    }()

    deinit {
        self.stopTimer()
    }
    
    @objc func onBtnDown(_ btn: UIButton) {
        self.stopTimer()
        self.timeCountLabel.isHidden = false
        self.timeCountLabel.text = "\(MAXCOUNT)"
        var kitState: AgoraEduContextHandsUpState = .handsUp
        if self.state != .handsUp {
            self.context?.updateHandsUpState(kitState)
        }
    }

    @objc func onBtnUp(_ btn: UIButton) {
        self.startTimer()
    }
    
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

// MARK: UI action
extension AgoraHandsUpView {

    fileprivate func startTimer() {
 
        self.stopTimer()
        
        self.timeCountLabel.isHidden = false
        timer = DispatchSource.makeTimerSource(flags: [], queue: DispatchQueue.global())
        timer?.schedule(deadline: .now() + 1, repeating: 1)
        timer?.setEventHandler { [weak self] in
            DispatchQueue.main.async {
                guard let `self` = self, let count = self.timeCountLabel.text else {
                    return
                }
    
                let val = (Int(count) ?? 0) - 1
                if val <= 0 {
                    self.timeCountLabel.text = "\(MAXCOUNT)"
                    self.timeCountLabel.isHidden = true
                    self.timer?.cancel()
                    
                    self.context?.updateHandsUpState(.handsDown)
                } else {
                    self.timeCountLabel.text = "\(val)"
                }
            }
        }
        timer?.resume()
    }
    
    fileprivate func stopTimer() {
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
    }
}
