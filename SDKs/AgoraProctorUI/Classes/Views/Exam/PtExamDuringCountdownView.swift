//
//  FcrExamEndCountdownView.swift
//  AgoraProctorUI
//
//  Created by DoubleCircle on 2022/9/8.
//

import AgoraUIBaseViews

class PtExamDuringCountdownView: UIView {
    private lazy var frontView = UIView(frame: .zero)
    private lazy var backView = UIView(frame: .zero)
    private(set) lazy var label = UILabel()
    
    /**data**/
    private var timer: Timer?
    var timeInfo: FcrProctorExamTimeInfo?
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        initViews()
        initViewFrame()
        updateViewProperties()
    }
    
    func startTimer() {
        guard timer == nil,
              let _ = timeInfo else {
            return
        }
        timer = Timer.scheduledTimer(withTimeInterval: 1.0,
                                     repeats: true,
                                     block: { [weak self] t in
            self?.updateCountdownLabel()
        })
    }
    
    func stopTimer() {
        guard timer != nil else {
            return
        }
        timer?.invalidate()
        timer = nil
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        frontView.layer.cornerRadius = frontView.width / 2
        backView.layer.cornerRadius = backView.width / 2
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

// MARK: - AgoraUIContentContainer
extension PtExamDuringCountdownView: AgoraUIContentContainer {
    func initViews() {
        label.sizeToFit()
        
        addSubviews([backView,
                     frontView,
                     label])
    }
    
    func initViewFrame() {
        backView.mas_makeConstraints { make in
            make?.left.centerY().equalTo()(self)
            make?.width.height().equalTo()(21)
        }
        
        frontView.mas_makeConstraints { make in
            make?.centerY.equalTo()(self)
            make?.center.equalTo()(backView)
            make?.width.height().equalTo()(13.5)
        }
        
        label.mas_makeConstraints { make in
            make?.left.equalTo()(backView.mas_right)?.offset()(7.5)
            make?.top.bottom().equalTo()(self)
        }
    }
    
    func updateViewProperties() {
        let config = UIConfig.exam.duringCountDown
        
        backView.layer.borderWidth = config.dotBorderWidth
        backView.layer.borderColor = config.dotColor.cgColor
        
        frontView.backgroundColor = config.dotColor
        frontView.clipsToBounds = true
        
        label.textColor = config.textColor
        label.font = config.textFont
    }
}

private extension PtExamDuringCountdownView {
    func updateCountdownLabel() {
        guard let info = timeInfo,
              info.valid else {
            label.text = timeString(from: 0)
            stopTimer()
            return
        }
        
        let realTime = Int64(Date().timeIntervalSince1970 * 1000)
        let countDown = info.startTime + info.duration * 1000 - realTime
        label.text = timeString(from: countDown)
    }
    
    func timeString(from interval: Int64) -> String {
        let time = interval > 0 ? (interval / 1000) : 0
        let minuteInt = time / 60
        let secondInt = time % 60
        
        let minuteString = NSString(format: "%02d", minuteInt) as String
        let secondString = NSString(format: "%02d", secondInt) as String
        
        return "\(minuteString):\(secondString)"
    }
}
