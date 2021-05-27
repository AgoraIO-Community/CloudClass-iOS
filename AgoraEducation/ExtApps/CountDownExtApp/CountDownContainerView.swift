//
//  CountDownContainerView.swift
//  AgoraEducation
//
//  Created by LYY on 2021/5/8.
//  Copyright © 2021 Agora. All rights reserved.
//

import Foundation
import AgoraUIBaseViews



@objc public class CountDownWrapper: NSObject {
    public static let countdownView = CountDownContainerView(frame: .zero)
    @objc public class func getView(delegate: CountDownDelegate) -> AgoraBaseUIView {
        countdownView.delegate = delegate
        return countdownView
    }
    
    @objc public class func getCountDwon() -> CountDownProtocol {
        return countdownView
    }
}

@objcMembers public class CountDownContainerView: AgoraBaseUIView,
                                                  CountDownProtocol {
    
    private let isPad: Bool = UIDevice.current.model == "iPad"
    
    private var timer: DispatchSourceTimer?
    
    fileprivate var delegate: CountDownDelegate?
    
    private var timeArr: Array<SingleTimeGroup> = []
    
    private var totalTime: NSInteger = 0 {
        didSet {
            timeArr.forEach { group in
                group.turnColor(color: (totalTime <= 3) ? .red : UIColor(hexString: "4D6277"))
            }
            let newTimeStrArr = secondsToTimeStrArr(seconds: totalTime)
            for i in 0..<timeArr.count {
                guard i <= newTimeStrArr.count else {
                    return
                }
                timeArr[i].updateStr(str: newTimeStrArr[i])
            }
        }
    }
    
    private lazy var titleView: AgoraBaseUIView = {
        let view = AgoraBaseUIView()
        view.backgroundColor = UIColor(hexString: "F9F9FC")
        view.layer.cornerRadius = 6
        view.clipsToBounds = true

        let titleLabel = AgoraBaseUILabel()
        titleLabel.text = NSLocalizedString("Countdown_title", comment: "")
        titleLabel.textColor = .black
        titleLabel.font = UIFont.systemFont(ofSize: 14)
        
        let line = AgoraBaseUIView()
        line.backgroundColor = UIColor(hexString: "EEEEF7")
        
        view.addSubview(titleLabel)
        view.addSubview(line)
        
        titleLabel.agora_x = isPad ? 19 : 10
        titleLabel.agora_y = isPad ? 10 : 6
        line.agora_x = 0
        line.agora_right = 0
        line.agora_bottom = 0
        line.agora_height = 1
        
        return view
    }()
    
    private lazy var colonView: AgoraBaseUILabel = {
        let colon = AgoraBaseUILabel()
        colon.text = ":"
        colon.textColor = UIColor(hexString: "4D6277")
        colon.font = UIFont.boldSystemFont(ofSize: isPad ? 48 : 34)
        colon.backgroundColor = .clear
        colon.textAlignment = .center
        return colon
    }()
    
    @objc public convenience init(delegate: CountDownDelegate) {
        self.init(frame: .zero)
        self.delegate = delegate
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        initView()
        initLayout()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: CountDownProtocol
    public func setCountDownWithTotalSeconds(_ totalSeconds: NSInteger) {
        guard timer == nil else {
            return
        }
        
        totalTime = totalSeconds
        
        timer = DispatchSource.makeTimerSource(flags: [],
                                               queue: DispatchQueue.global())
        timer?.schedule(deadline: .now(),
                       repeating: 1)
        
        timer?.setEventHandler { [weak self] in
            DispatchQueue.main.async {
                guard let `self` = self else {
                    return
                }
                guard self.totalTime > 0 else {
                    self.delegate?.countDownDidStop()
                    self.timer?.cancel()
                    return
                }
                self.totalTime -= 1
                self.delegate?.countDownUp(to: self.totalTime)
            }
        }
    }
    
    public func invokeCountDown() {
        timer?.resume()
    }
    
    public func pauseCountDown() {
        timer?.cancel()
        timer = nil
    }
    
    public func continueCountDown() {
        guard let countDownTimer = timer else {
            return
        }
        countDownTimer.activate()
    }
    
    public func cancelCountDown() {
        timer?.cancel()
        timer = nil
    }

}

// MARK: private
extension CountDownContainerView {
    private func secondsToTimeStrArr(seconds: NSInteger) -> Array<String> {
        guard seconds > 0 else {
            return ["0","0","0","0"]
        }
        
        let minsInt = seconds / 60
        let min0Str = String(minsInt / 10)
        let min1Str = String(minsInt % 10)
        
        var sec0Str = "0"
        var sec1Str = "0"
        
        if seconds % 60 != 0 {
            let remainder = seconds % 60
            sec0Str = remainder > 9 ? String(remainder / 10) : "0"
            sec1Str = remainder > 9 ? String(remainder % 10) : String(remainder)
        }
        
        return [min0Str,min1Str,sec0Str,sec1Str]
    }
}

// MARK: UI
extension CountDownContainerView {
    private func initView() {
        isUserInteractionEnabled = true
        backgroundColor = .white
        addSubview(titleView)
        addSubview(colonView)
        if timeArr.count == 0 {
            for _ in 0...3 {
                let timeView = SingleTimeGroup(frame: .zero)
                timeArr.append(timeView)
                addSubview(timeView)
            }
        }
        
        layer.shadowColor = UIColor(red: 0.18,
                                    green: 0.25,
                                    blue: 0.57,
                                    alpha: 0.15).cgColor
        layer.shadowOffset = CGSize(width: 0, height: 2)
        layer.shadowOpacity = 1
        layer.shadowRadius = 6
        layer.shadowPath    = UIBezierPath(rect: frame).cgPath
        
        layer.borderWidth = 1
        layer.borderColor = UIColor(red: 0.89,
                                    green: 0.89,
                                    blue: 0.93,
                                    alpha: 1).cgColor
        clipsToBounds = true
        layer.cornerRadius = 6
        
    }
    
    private func initLayout() {
        
        let singleWidth: CGFloat = isPad ? 50 : 36
        let gap_small: CGFloat = isPad ? 6 : 4
        let gap_big: CGFloat = isPad ? 20 : 12
        
        let xArr: [CGFloat] = [0,
                               singleWidth + gap_small,
                               singleWidth * 2 + gap_small + gap_big,
                               singleWidth * 3 + gap_small * 2 + gap_big]
        
        titleView.agora_x = 0
        titleView.agora_right = 0
        titleView.agora_y = 0
        titleView.agora_height = isPad ? 40 : 32
        
        colonView.agora_center_x = 0
        colonView.agora_center_y = titleView.agora_height / 2

        for i in 0..<timeArr.count {
            timeArr[i].agora_x = xArr[i] + (isPad ? 14 : 10)
            timeArr[i].agora_width = singleWidth
            timeArr[i].agora_y = isPad ? 57 : 44
            timeArr[i].agora_bottom = isPad ? 15 : 10
        }
    }
}
