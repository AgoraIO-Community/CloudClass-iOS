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
                backgroundColor = .white
                imageView?.tintColor = UIColor(rgb: 0x7B88A0)
            case .hold:
                backgroundColor = UIColor(rgb: 0x357BF6)
                imageView?.tintColor = .white
            case .counting:
                backgroundColor = UIColor(rgb: 0x357BF6)
                imageView?.tintColor = .white
            default: break
            }
        }
    }
    
    private var timer: Timer?
    
    private var count = 3
        
    override init(frame: CGRect) {
        super.init(frame: frame)
        layer.cornerRadius = 8
        layer.shadowColor = UIColor(rgb:0x2F4192).withAlphaComponent(0.15).cgColor
        layer.shadowOffset = CGSize(width: 0, height: 2)
        layer.shadowOpacity = 1
        layer.shadowRadius = 6
        createViews()
        createConstrains()
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
        self.transform = CGAffineTransform(scaleX: 1.1, y: 1.1)
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
            self.transform = CGAffineTransform(scaleX: 1, y: 1)
        } completion: { finish in
        }
        
        state = .counting
        imageView.isHidden = true
        delayLabel.isHidden = false
        delayLabel.text = "\(count)"
        timer = Timer.scheduledTimer(withTimeInterval: 1, repeats: true, block: { [weak self] _ in
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
        backgroundColor = .white
        
        let image = AgoraUIImage(object: self, name: "ic_func_hands_up")
        imageView = UIImageView(image: image?.withRenderingMode(.alwaysTemplate))
        imageView.tintColor = UIColor(rgb: 0x7B88A0)
        addSubview(imageView)
        
        delayLabel = UILabel()
        delayLabel.textColor = .white
        delayLabel.textAlignment = .center
        delayLabel.font = UIFont.systemFont(ofSize: 13)
        addSubview(delayLabel)
    }
    
    private func createConstrains() {
        imageView.mas_makeConstraints { make in
            make?.center.equalTo()(imageView.superview)
        }
        delayLabel.mas_makeConstraints { make in
            make?.left.right().top().bottom().equalTo()(delayLabel.superview)
        }
    }
}
