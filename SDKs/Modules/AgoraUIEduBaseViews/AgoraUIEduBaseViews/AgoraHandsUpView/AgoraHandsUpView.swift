//
//  AgoraHandsUpView.swift
//  AgoraUIEduBaseViews
//
//  Created by LYY on 2021/3/12.
//

import AgoraUIBaseViews
import AgoraEduContext

public protocol AgoraHandsUpViewDelegate: NSObjectProtocol {
    func handsUpVieWillHandsUp(_ view: AgoraHandsUpView,
                               timeout: Int)
    
    func handsUpVieWillHandsDown(_ view: AgoraHandsUpView)
}

fileprivate let MAXCOUNT = 3

public class AgoraHandsUpView: AgoraBaseUIView {
    
    public enum HandsUpState : Int {
            // 举手状态： 默认、举手、放手
            case `default`
            case handsUp
            case handsDown
        }
    
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
    public var state: HandsUpState = .default {
        didSet {
            self.updateStateWithCoHost()
        }
    }

    private var firstInFlag = true
    fileprivate var timer: DispatchSourceTimer?
    //MARK: lazy load
    fileprivate lazy var timeCountLabel: AgoraBaseUILabel = {
        let label = AgoraBaseUILabel()
        label.text = "\(MAXCOUNT)"
        label.font = .boldSystemFont(ofSize: 13)
        label.textAlignment = .center
        label.textColor = .white
    
        return label
    }()
    
    fileprivate lazy var timeCountView: AgoraBaseUIImageView = {
        let imgView = AgoraBaseUIImageView(image: AgoraKitImage("countdown"))
        imgView.addSubview(self.timeCountLabel)
        self.timeCountLabel.agora_center_x = 0
        self.timeCountLabel.agora_center_y = 0
        self.timeCountLabel.agora_width = 34

        imgView.isHidden = true
        return imgView
    }()
    
    fileprivate lazy var handsUpBtn: AgoraBaseUIButton = {
        let btn = AgoraBaseUIButton()
        btn.backgroundColor = .clear;
        btn.setBackgroundImage(AgoraKitImage("handsup"),
                               for: .normal)
        
        btn.addTarget(self, action: #selector(onButtonClick(_:)),
                      for: .touchDown)
        // 处理手抬起来
        btn.addTarget(self, action: #selector(onButtonCancel(_:)),
                      for: .touchUpInside)
        btn.addTarget(self, action: #selector(onButtonCancel(_:)),
                      for: .touchUpOutside)
        
        return btn
    }()
    
    fileprivate lazy var popover = AgoraPopover(options: [.type(.left),
                                                     .blackOverlayColor(.clear),
                                                     .cornerRadius(10),
                                                     .arrowSize(CGSize(width: 16,
                                                                       height: 4)),
                                                     .arrowPointerOffset(CGPoint(x: -5,
                                                                                 y: 0))])
    
    

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
        addSubview(handsUpBtn)
        addSubview(timeCountView)
        addSubview(popover)
        // popover
        popover.delegate = self
        popover.strokeColor = .white
        popover.borderColor = .white
    }
    
    private func initLayout() {
        timeCountView.agora_center_x = 0
        timeCountView.agora_height = 38
        timeCountView.agora_y = 0
        timeCountView.agora_width = 34

        handsUpBtn.agora_x = 0
        handsUpBtn.agora_right = 0
        handsUpBtn.agora_y = 0
        handsUpBtn.agora_width = 56
        handsUpBtn.agora_height = handsUpBtn.agora_width
        handsUpBtn.agora_bottom = 0
    }
    public override func hitTest(_ point: CGPoint, with event: UIEvent?) -> UIView? {
        let hitView = super.hitTest(point, with: event)
        if handsUpBtn == hitView {
            return hitView
        }
        // 返回nil 那么事件就不由当前控件处理
        return nil
    }
        
    public func updateLayout(width: CGFloat, height: CGFloat) {
        timeCountView.agora_width = width
        timeCountView.agora_height = height
        
        handsUpBtn.agora_width = width
        handsUpBtn.agora_height = height
    }
    @objc func onButtonClick(_ btn: UIButton) {
        showFirstInTip()
        sendHandsUpRequest()
    }

    @objc func onButtonCancel(_ btn: UIButton) {
        startTimerCountDown()
    }
    
    public func setHandsUpEnable(_ enable: Bool) {
        isEnable = enable
    }
    
    public func updateHandsUp(_ state: HandsUpState) {
        self.state = state
    }
    
    deinit {
        
    }
}

// MARK: - UI action
private extension AgoraHandsUpView {
    fileprivate func showFirstInTip() {
        if firstInFlag {
            let font = UIFont.systemFont(ofSize: 12)
            let text = AgoraKitLocalizedString("HandsupFirstInText")
            let textSize = text.agora_size(font: font)
            
            let label = AgoraBaseUILabel(frame: CGRect(x: 0,
                                                       y: 0,
                                                       width: textSize.width + 20,
                                                       height: textSize.height + 10))
            label.text = text
            label.textAlignment = .center
            label.font = font

            popover.borderColor = UIColor(rgb: 0xE1E1EA)
            popover.layer.shadowColor = UIColor(rgb: 0x2F4192,
                                                alpha: 0.15).cgColor
            popover.layer.shadowOffset = CGSize(width: 0,
                                                height: 2)
            popover.layer.shadowOpacity = 0.15
            popover.show(label,
                         fromView: self)
            var countDownNum = 3
            Timer.scheduledTimer(withTimeInterval: 1,
                                 repeats: true) {[weak self] (timer) in
                guard let `self` = self else {
                    return
                }
                
                if countDownNum == 0 {
                    self.firstInFlag = false
                    self.popover.dismiss()
                    timer.invalidate()
                    } else {
                        countDownNum -= 1
                    }
            }
        }
    }
    
    fileprivate func sendHandsUpRequest() {
        delegate?.handsUpVieWillHandsUp(self,
                                        timeout: -1)
    }
    
    fileprivate func startTimerCountDown() {
        self.timeCountView.isHidden = false
        self.handsUpBtn.isUserInteractionEnabled = false
        delegate?.handsUpVieWillHandsUp(self,
                                        timeout: MAXCOUNT)
        timer = DispatchSource.makeTimerSource(flags: [],
                                               queue: DispatchQueue.global())
        timer?.schedule(deadline: .now() + 1, repeating: 1)
        timer?.setEventHandler { [weak self] in
            DispatchQueue.main.async {
                guard let `self` = self,
                        let count = self.timeCountLabel.text else {
                    return
                }
    
                let val = (Int(count) ?? 0) - 1
                if val <= 0 {
                    self.timeCountView.isHidden = true
                    self.timeCountLabel.text = "\(MAXCOUNT)"
                    self.timer?.cancel()
                    
                    self.handsUpBtn.isUserInteractionEnabled = true
                } else {
                    self.timeCountLabel.text = "\(val)"
                }
            }
        }
        timer?.resume()
    }
    
    /// Only called when enabled,which means the view is visible
    fileprivate func updateStateWithCoHost() {
        self.isHidden = false
        if !self.isEnable {
            self.isHidden = true
            return
        }
        
        handsUpBtn.isUserInteractionEnabled = true
    }
}

extension AgoraHandsUpView: AgoraPopoverDelegate {
    public func popoverDidDismiss(_ popover: AgoraPopover) {
        
    }
}

fileprivate extension String {
    var intValue: Int? {
        return Int(self)
    }
}
