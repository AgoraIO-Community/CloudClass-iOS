//
//  FcrWaveHandsDelayView.swift
//  AgoraEduUI
//
//  Created by LYY on 2022/6/29.
//

import AgoraUIBaseViews
import UIKit

protocol FcrWaveHandsDelayViewDelegate: NSObjectProtocol {
    func onHandsUpViewDidChangeState(_ state: FcrWaveHandsDelayView.ViewState)
}

class FcrWaveHandsDelayView: UIView {
    enum ViewState {
        case free, hold, counting
    }
    
    weak var delegate: FcrWaveHandsDelayViewDelegate?
    
    public var duration = 3 {
        didSet {
            self.count = duration
        }
    }
    
    private lazy var bgView: UIImageView = {
        let name = "toolbar_selected_bg"
        let image = UIImage.agedu_named(name)
        return UIImageView(image: image)
    }()
    
    private lazy var delayLabel = UILabel()
    
    private var state: ViewState = .free {
        didSet {
            guard state != oldValue else {
                return
            }
            
            delegate?.onHandsUpViewDidChangeState(state)
        }
    }
    
    private var timer: Timer?
    
    private var count = 3
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        initViews()
        initViewFrame()
        updateViewProperties()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func startTimer() {
        guard timer == nil else {
            return
        }
        self.transform = CGAffineTransform(scaleX: 1.1,
                                           y: 1.1)
        state = .hold
        delayLabel.text = "\(count)"
        timer = Timer.scheduledTimer(withTimeInterval: 1,
                                     repeats: true,
                                     block: { [weak self] _ in
            self?.state = .counting
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
        state = .free
    }
}

// MARK: - AgoraUIContentContainer
extension FcrWaveHandsDelayView: AgoraUIContentContainer {
    func initViews() {
        addSubview(bgView)
        
        delayLabel.textAlignment = .center
        addSubview(delayLabel)
    }
    
    func initViewFrame() {
        bgView.mas_makeConstraints { make in
            make?.center.equalTo()(0)
        }
        delayLabel.mas_makeConstraints { make in
            make?.left.right().top().bottom().equalTo()(self)
        }
    }
    
    func updateViewProperties() {
        let config = UIConfig.raiseHand
        
        layer.shadowColor = config.shadow.color
        layer.shadowOffset = config.shadow.offset
        layer.shadowOpacity = config.shadow.opacity
        layer.shadowRadius = config.shadow.radius
        
        delayLabel.textColor = config.delayView.textColor
        delayLabel.font = config.delayView.font
    }
}

