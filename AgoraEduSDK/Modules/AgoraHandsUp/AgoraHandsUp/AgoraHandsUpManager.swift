//
//  AgoraHandsUpManager.swift
//  AgoraHandsUp
//
//  Created by SRS on 2020/11/17.
//

import UIKit

public enum AgoraHandsUpState {
    case none   // 没有举手
    case handsUp
    case handsDown
    case disabled
}

enum AgoraHandsUpType {
    case autoPublish        //自动发流
    case applyPublish       //申请发流
}

public protocol AgoraHandsUpDelegate: class {
    func onHandsClicked(currentState: AgoraHandsUpState)
    func onHandsUpTimeOut()
}

public class AgoraHandsUpManager {
    
    var handsUpType = AgoraHandsUpType.autoPublish {
        didSet {
            self.stopHandsUpTimer()
        }
    }
    
    var handsUpState: AgoraHandsUpState = .none {
        didSet {
            self.updateHandsup()
            
            if (self.handsUpState == .handsUp) {
                self.startHandsTimeOut()
            } else {
                self.stopHandsUpTimer()
            }
        }
    }
    var handsUpTimeOut = 0

    fileprivate weak var delegate: AgoraHandsUpDelegate?
    
    fileprivate let MAXCOUNT = 3
    fileprivate var state = AgoraHandsUpState.none

    fileprivate lazy var timeCountLabel: UILabel = {
        
        let label = UILabel(frame: CGRect(x: 0, y: 0, width: 42, height: 42))
        label.textAlignment = .center
        label.textColor = UIColor(red: 68/255.0, green: 162/255.0, blue: 252/255.0, alpha: 1)
        label.font = UIFont.systemFont(ofSize: 16)
        label.text = "\(MAXCOUNT)"
    
        return label
    }()
    fileprivate lazy var timeCountView: UIView = {
        
        let view = UIView(frame: CGRect(x: 0, y: 0, width: 42, height: 46))
        view.backgroundColor = UIColor.clear
  
        let bundle = Bundle(for: type(of: self))
        let bubble = UIImage(named: "bubble", in: bundle, compatibleWith: nil)
        let bgView = UIImageView(image: bubble)
        bgView.frame = view.bounds
        view.addSubview(bgView)
        
        view.addSubview(timeCountLabel)
        
        view.isHidden = true
        return view
    }()
    fileprivate lazy var handsUpBtn: UIButton = {
        
        let btn = UIButton(type: .custom)
        btn.backgroundColor = UIColor.white;
        
        let imageString = self.handsUpState == .handsUp ? "handsdown" : (self.handsUpState == .disabled ? "handsdisable" : "handsup")
        
        let bundle = Bundle(for: type(of: self))
        let normal = UIImage(named: imageString, in: bundle, compatibleWith: nil)
        let select = UIImage(named: imageString, in: bundle, compatibleWith: nil)
        
        btn.setImage(normal, for: .normal)
        btn.setImage(select, for: .selected)
        
        btn.frame = CGRect(x: 0, y: timeCountView.frame.height + 3, width: timeCountView.frame.width, height: timeCountView.frame.width)
        btn.addTarget(self, action: #selector(onButtonClick(_:)), for: .touchDown)
        btn.addTarget(self, action: #selector(onButtonCancel(_:)), for: .touchUpInside)
        btn.addTarget(self, action: #selector(onButtonCancel(_:)), for: .touchUpOutside)

        btn.layer.cornerRadius = 5
        btn.layer.borderColor = UIColor.init(red: 219/255.0, green: 226/255.0, blue: 229/255.0, alpha: 1).cgColor
        btn.layer.borderWidth = 1
        
        return btn
    }()
    
    fileprivate lazy var handsUpView: UIView = {
        let view = UIView(frame: CGRect(x: 0, y: 0, width: timeCountView.frame.width, height: timeCountView.frame.height + handsUpBtn.frame.height + 3))
        view.backgroundColor = UIColor.clear
        
        view.addSubview(timeCountView)
        view.addSubview(handsUpBtn)
        return view
    }()
    
    fileprivate var timer: DispatchSourceTimer?
    fileprivate var handsUpTimer: DispatchSourceTimer?

    fileprivate init() {
    }
    
    public convenience init(_ delegate: AgoraHandsUpDelegate) {
        self.init()
        self.delegate = delegate
    }
    
    // generate hands view
    public func getHandsUpView() -> UIView {
        return self.handsUpView
    }
    
    deinit {
        self.stopTimer()
        self.stopHandsUpTimer()
    }
}

extension AgoraHandsUpManager {
    
    fileprivate func updateHandsup() {
        
        handsUpBtn.isUserInteractionEnabled = true
        
        var imageString = ""
        if (self.handsUpState == .disabled) {
            imageString = "handsdisable"
            handsUpBtn.isUserInteractionEnabled = false
        } else if (self.handsUpState == .handsUp) {
            imageString = "handsdown"
        } else {
            imageString = "handsup"
        }
        
        let bundle = Bundle(for: type(of: self))
        let normal = UIImage(named: imageString, in: bundle, compatibleWith: nil)
        let select = UIImage(named: imageString, in: bundle, compatibleWith: nil)
        
        handsUpBtn.setImage(normal, for: .normal)
        handsUpBtn.setImage(select, for: .selected)
    }
    
    @objc func onButtonClick(_ btn: UIButton) {
        
//        if (self.handsUpType == .autoPublish) {
//            self.delegate?.onHandsClicked(currentState: self.handsUpState)
//            return
//        }
        
        self.startTimer()
    }

    @objc func onButtonCancel(_ btn: UIButton) {
        
//        if (self.handsUpType == .autoPublish) {
//            return
//        }
        self.stopTimer()
    }

    fileprivate func startTimer() {
        
        self.stopTimer()

        self.timeCountLabel.text = "\(MAXCOUNT)"
        self.timeCountView.isHidden = false
        timer = DispatchSource.makeTimerSource(flags: [], queue: DispatchQueue.global())
        timer?.schedule(deadline: .now() + 1, repeating: 1)
        timer?.setEventHandler {
            
            DispatchQueue.main.async {
                guard let count = self.timeCountLabel.text else {
                    return
                }
    
                let val = (Int(count) ?? 0) - 1
                if val <= 0 {
                    self.timeCountView.isHidden = true
                    self.timer?.cancel()
                    
                    self.delegate?.onHandsClicked(currentState: self.handsUpState)
                } else {
                    self.timeCountLabel.text = "\(val)"
                }
            }
        }
        timer?.resume()
    }
    fileprivate func startHandsTimeOut() {
//        self.stopHandsUpTimer()
//
//        if handsUpTimeOut > 0 {
//            handsUpTimer = DispatchSource.makeTimerSource(flags: [], queue: DispatchQueue.global())
//
//            let timeOut = DispatchTime.now() + DispatchTimeInterval.seconds(handsUpTimeOut)
//            handsUpTimer?.schedule(deadline: timeOut)
//            handsUpTimer?.setEventHandler {
//                DispatchQueue.main.async {
//                    self.stopTimer()
//                    self.handsUpState = .none
//                    self.delegate?.onHandsUpTimeOut()
//                }
//            }
//            handsUpTimer?.resume()
//        }
    }
    
    fileprivate func stopTimer() {
        self.timeCountView.isHidden = true
        
        if !(timer?.isCancelled ?? true) {
            timer?.cancel()
        }
    }
    
    fileprivate func stopHandsUpTimer() {
//        if !(handsUpTimer?.isCancelled ?? true) {
//            handsUpTimer?.cancel()
//        }
    }
}
