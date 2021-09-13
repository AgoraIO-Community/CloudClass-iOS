//
//  AgoraHandsUpView.swift
//  AgoraUIEduBaseViews
//
//  Created by LYY on 2021/3/12.
//

import AgoraUIBaseViews
import UIKit

public protocol AgoraHandsUpViewDelegate: NSObjectProtocol {
    func handsUpVieWillHandsUp(_ view: AgoraHandsUpView)
    func handsUpVieWillHandsDown(_ view: AgoraHandsUpView)
}

public class AgoraHandsUpView: AgoraBaseUIView {
    public enum HandsUpState : Int {
        // 举手状态： 默认、举手、放手
        case `default`
        case handsUp
        case handsDown
    }
    
    //MARK: lazy load
    private lazy var timeCountLabel: AgoraBaseUILabel = {
        let label = AgoraBaseUILabel()
        label.text = "\(MAXCOUNT)"
        label.font = .boldSystemFont(ofSize: 16)
        label.textAlignment = .center
        label.textColor = .init(red: 68 / 255.0,
                                green: 162 / 255.0,
                                blue: 252 / 255.0,
                                alpha: 1)
        return label
    }()
    
    private lazy var timeCountView: AgoraBaseUIImageView = {
        let imgView = AgoraBaseUIImageView(image: AgoraKitImage("bubble"))
        imgView.addSubview(timeCountLabel)
        timeCountLabel.agora_x = 0
        timeCountLabel.agora_y = 12
        timeCountLabel.agora_width = 42
        
        imgView.isHidden = true
        return imgView
    }()
    
    private lazy var handsUpBtn: AgoraBaseUIButton = {
        let btn = AgoraBaseUIButton()
        btn.backgroundColor = .clear;
        btn.setImage(AgoraKitImage("hands_down_default"),
                     for: .normal)
        
        btn.addTarget(self,
                      action: #selector(onButtonClick(_:)),
                      for: .touchDown)
        btn.addTarget(self,
                      action: #selector(onButtonCancel(_:)),
                      for: .touchUpInside)
        btn.addTarget(self,
                      action: #selector(onButtonCancel(_:)),
                      for: .touchUpOutside)
        
        return btn
    }()
    
    private var state: HandsUpState = .default {
        didSet {
            var imageName: String
            
            switch state {
            case .default:
                imageName = "hands_down_default"
                handsUpBtn.isUserInteractionEnabled = true
            case .handsUp:
                imageName = "hands_up_waiting"
                handsUpBtn.isUserInteractionEnabled = true
            case .handsDown:
                imageName = "hands_down_default"
                handsUpBtn.isUserInteractionEnabled = true
            }
            
            handsUpBtn.setImage(AgoraKitImage(imageName),
                                for: .normal)
        }
    }
    
    private var isEnable: Bool = false {
        didSet {
            isHidden = !isEnable
        }
    }
    
    private let MAXCOUNT = 3
    private var timer: DispatchSourceTimer?
    
    public var isCoHost: Bool = false {
        didSet {
            let imageName = (isCoHost ? "hands_up_cohost" : "hands_down_default")
            
            handsUpBtn.setImage(AgoraKitImage(imageName),
                                for: .normal)
            handsUpBtn.isUserInteractionEnabled = !isCoHost
        }
    }
    
    public weak var delegate: AgoraHandsUpViewDelegate?

    //MARK: init
    public override init(frame: CGRect) {
        super.init(frame: .zero)
        self.initView()
        self.initLayout()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func initView() {
        addSubview(timeCountView)
        addSubview(handsUpBtn)
    }
    
    private func initLayout() {
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
    
    @objc func onButtonClick(_ btn: UIButton) {
        startTimer()
    }

    @objc func onButtonCancel(_ btn: UIButton) {
        stopTimer()
    }
    
    public func setHandsUpEnable(_ enable: Bool) {
        isEnable = enable
    }
    
    public func updateHandsUp(_ state: HandsUpState) {
        self.state = state
    }
    
    deinit {
        self.stopTimer()
    }
}

// MARK: - UI action
private extension AgoraHandsUpView {
     func startTimer() {
        stopTimer()
        
        timeCountView.isHidden = false
        timer = DispatchSource.makeTimerSource(flags: [],
                                               queue: DispatchQueue.global())
        timer?.schedule(deadline: .now() + 1,
                        repeating: 1)
        
        timer?.setEventHandler { [weak self] in
            DispatchQueue.main.async {
                guard let `self` = self,
                      let count = self.timeCountLabel.text?.intValue else {
                    return
                }
                
                if count <= 0 {
                    self.timeCountView.isHidden = true
                    self.timeCountLabel.text = "\(self.MAXCOUNT)"
                    self.timer?.cancel()
                    if self.state == .handsUp {
                        self.delegate?.handsUpVieWillHandsDown(self)
                    } else {
                        self.delegate?.handsUpVieWillHandsUp(self)
                    }
                } else {
                    self.timeCountLabel.text = "\(count - 1)"
                }
            }
        }
        timer?.resume()
    }
    
    func stopTimer() {
        timeCountView.isHidden = true
        timeCountLabel.text = "\(MAXCOUNT)"
        
        guard let `timer` = timer else {
            return
        }
        
        timer.cancel()
        self.timer = nil
    }
}

fileprivate extension String {
    var intValue: Int? {
        return Int(self)
    }
}
