//
//  HandsupDelayView.swift
//  AgoraEduUI
//
//  Created by Jonathan on 2021/10/22.
//

import UIKit

protocol AgoraHandsUpDelayViewDelegate: NSObjectProtocol {
    func onHandsUpViewDidChangeState(_ state: AgoraHandsUpDelayView.ViewState)
}

class AgoraHandsUpDelayView: UIView {
    enum ViewState {
        case free, hold, counting
    }
    
    weak var delegate: AgoraHandsUpDelayViewDelegate?
    
    public var duration = 3 {
        didSet {
            self.count = duration
        }
    }
    
    private lazy var imageView: UIImageView = {
        let image = UIImage.agedu_named("toolbar_hands_up")
        return UIImageView(image: image?.withRenderingMode(.alwaysTemplate))
    }()
    
    private lazy var delayLabel = UILabel()
    
    private var state: ViewState = .free {
        didSet {
            guard state != oldValue else {
                return
            }
            
            delegate?.onHandsUpViewDidChangeState(state)
            
            switch state {
            case .free:
                backgroundColor = itemBackgroundUnselectedColor
            case .hold:
                backgroundColor = itemBackgroundSelectedColor
            case .counting:
                backgroundColor = itemBackgroundSelectedColor
            default: break
            }
        }
    }
    
    private var timer: Timer?
    
    private var count = 3
        
    private var itemSelectedColor: UIColor!
    private var itemUnselectedColor: UIColor!
    private var itemBackgroundSelectedColor: UIColor!
    private var itemBackgroundUnselectedColor: UIColor!
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        initViews()
        initViewFrame()
        updateViewProperties()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesBegan(touches, with: event)
        guard state == .free else {
            return
        }
        self.transform = CGAffineTransform(scaleX: 1.1,
                                           y: 1.1)
        stopTimer()
        state = .hold
    }
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesEnded(touches, with: event)
        guard state == .hold else {
            return
        }
        UIView.animate(withDuration: 0.1,
                       delay: 0,
                       options: .curveLinear) {
            self.transform = CGAffineTransform(scaleX: 1,
                                               y: 1)
        }
        
        state = .counting
        imageView.isHidden = true
        delayLabel.isHidden = false
        delayLabel.text = "\(count)"
        timer = Timer.scheduledTimer(withTimeInterval: 1,
                                     repeats: true,
                                     block: { [weak self] _ in
            self?.countDown()
        })
    }
    
    private func countDown() {
        if count > 1 {
            count -= 1
            delayLabel.text = "\(count)"
        } else {
            stopTimer()
        }
    }
    
    private func stopTimer() {
        guard timer != nil else {
            return
        }
        timer?.invalidate()
        timer = nil
        count = self.duration
        imageView.isHidden = false
        delayLabel.isHidden = true
        state = .free
    }
}

// MARK: - AgoraUIContentContainer
extension AgoraHandsUpDelayView: AgoraUIContentContainer {
    func initViews() {
        addSubview(imageView)
        
        delayLabel.textAlignment = .center
        addSubview(delayLabel)
    }
    
    func initViewFrame() {
        imageView.mas_makeConstraints { make in
            make?.center.equalTo()(imageView.superview)
        }
        delayLabel.mas_makeConstraints { make in
            make?.left.right().top().bottom().equalTo()(delayLabel.superview)
        }
    }
    
    func updateViewProperties() {
        let ui = AgoraUIGroup()
        
        itemSelectedColor = FcrColorGroup.fcr_system_component_color
        itemUnselectedColor = FcrColorGroup.fcr_icon_normal_color
        itemBackgroundSelectedColor = FcrColorGroup.fcr_icon_fill_color
        itemBackgroundUnselectedColor = FcrColorGroup.fcr_system_component_color
        
        backgroundColor = itemBackgroundUnselectedColor
        layer.cornerRadius = ui.frame.fcr_round_container_corner_radius
        
        FcrColorGroup.borderSet(layer: layer)
        
        imageView.tintColor = itemUnselectedColor
        
        delayLabel.textColor = .white
        delayLabel.font = ui.font.fcr_font13
    }
}
