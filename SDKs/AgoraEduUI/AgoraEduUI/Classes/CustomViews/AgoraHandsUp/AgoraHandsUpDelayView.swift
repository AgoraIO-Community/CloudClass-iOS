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
    
    private var imageView: UIImageView!
    
    private var delayLabel: UILabel!
    
    private var state: ViewState = .free {
        didSet {
            guard state != oldValue else {
                return
            }
            
            delegate?.onHandsUpViewDidChangeState(state)
            
            switch state {
            case .free:
                backgroundColor = itemBackgroundUnselectedColor
                imageView?.tintColor = itemUnselectedColor
            case .hold:
                backgroundColor = itemBackgroundSelectedColor
                imageView?.tintColor = itemSelectedColor
            case .counting:
                backgroundColor = itemBackgroundSelectedColor
                imageView?.tintColor = itemSelectedColor
            default: break
            }
        }
    }
    
    private var timer: Timer?
    
    private var count = 3
        
    private var itemSelectedColor: UIColor
    private var itemUnselectedColor: UIColor
    private var itemBackgroundSelectedColor: UIColor
    private var itemBackgroundUnselectedColor: UIColor
    
    override init(frame: CGRect) {
        let group = AgoraColorGroup()
        
        itemSelectedColor = group.tool_bar_item_selected_color
        itemUnselectedColor = group.tool_bar_item_unselected_color
        itemBackgroundSelectedColor = group.tool_bar_item_background_selected_color
        itemBackgroundUnselectedColor = group.tool_bar_item_background_unselected_color
        
        super.init(frame: frame)
        
        createViews()
        createConstraint()
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        layer.cornerRadius = bounds.height * 0.5
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
        count = 3
        imageView.isHidden = false
        delayLabel.isHidden = true
        state = .free
    }
    
    private func createViews() {
        backgroundColor = itemBackgroundUnselectedColor
        
        layer.cornerRadius = 8
        AgoraUIGroup().color.borderSet(layer: layer)
        
        let image = UIImage.agedu_named("ic_func_hands_up")
        imageView = UIImageView(image: image?.withRenderingMode(.alwaysTemplate))
        imageView?.tintColor = itemUnselectedColor
        addSubview(imageView)
        
        delayLabel = UILabel()
        delayLabel.textColor = .white
        delayLabel.textAlignment = .center
        delayLabel.font = UIFont.systemFont(ofSize: 13)
        addSubview(delayLabel)
    }
    
    private func createConstraint() {
        imageView.mas_makeConstraints { make in
            make?.center.equalTo()(imageView.superview)
        }
        delayLabel.mas_makeConstraints { make in
            make?.left.right().top().bottom().equalTo()(delayLabel.superview)
        }
    }
}
