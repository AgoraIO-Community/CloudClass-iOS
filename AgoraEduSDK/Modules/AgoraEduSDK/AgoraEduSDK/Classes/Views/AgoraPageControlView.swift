//
//  AgoraPageControlView.swift
//  AgoraEduSDK
//
//  Created by SRS on 2021/1/30.
//

import UIKit

@objc public protocol AgoraPageControlProtocol : NSObjectProtocol {
    func onPageLeftEvent()
    func onPageRightEvent()
    func onPageIncreaseEvent()
    func onPageDecreaseEvent()
    func onPageZoomEvent()
}

@objcMembers public class AgoraPageControlView: AgoraBaseView {
    
    public var pageIndex = 1 {
        didSet {
            let label = self.labelView.viewWithTag(PageIndexLabelTag) as! AgoraBaseUILabel
            label.text = String(pageIndex)
            
            if (pageIndex <= 1) {
//                label.backgroundColor = UIColor(red: 112/255.0, green: 125/255.0, blue: 188/255.0, alpha: 1)
                self.leftBtn.isSelected = true
                self.leftBtn.isUserInteractionEnabled = false
            } else {
//                label.backgroundColor = UIColor.clear
                self.leftBtn.isSelected = false
                self.leftBtn.isUserInteractionEnabled = true
            }
            
            if (pageIndex >= pageCount) {
                self.rightBtn.isSelected = true
                self.rightBtn.isUserInteractionEnabled = false
            } else {
                self.rightBtn.isSelected = true
                self.rightBtn.isUserInteractionEnabled = false
            }
        }
    }
    public var pageCount = 1 {
        didSet {
            let label = self.labelView.viewWithTag(PageCountLabelTag) as! AgoraBaseUILabel
            label.text = String(pageCount)
        }
    }
    
    fileprivate var delegate: AgoraPageControlProtocol?
    
    fileprivate lazy var leftBtn: AgoraBaseUIButton = {
        let btn = AgoraBaseUIButton(type: .custom)
        btn.addTarget(self, action: #selector(onLeftTouchEvent), for: .touchUpInside)
        if !AgoraDeviceAssistant.OS.isPad {
            btn.touchRange = TouchRange
        }
        btn.setImage(AgoraImageWithName("board_left", self.classForCoder), for: .normal)
        btn.setImage(AgoraImageWithName("board_left_forbid", self.classForCoder), for: .selected)
        btn.isSelected = true
        btn.isUserInteractionEnabled = false
        return btn
    }()
    fileprivate lazy var rightBtn: AgoraBaseUIButton = {
        let btn = AgoraBaseUIButton(type: .custom)
        btn.addTarget(self, action: #selector(onRightTouchEvent), for: .touchUpInside)
        if !AgoraDeviceAssistant.OS.isPad {
            btn.touchRange = TouchRange
        }
        btn.setImage(AgoraImageWithName("board_right", self.classForCoder), for: .normal)
        btn.setImage(AgoraImageWithName("board_right_forbid", self.classForCoder), for: .selected)
        btn.isSelected = true
        btn.isUserInteractionEnabled = false
        return btn
    }()
    fileprivate lazy var increaseBtn: AgoraBaseUIButton = {
        let btn = AgoraBaseUIButton(type: .custom)
        btn.addTarget(self, action: #selector(onIncreaseTouchEvent), for: .touchUpInside)
        if !AgoraDeviceAssistant.OS.isPad {
            btn.touchRange = TouchRange
        }
        btn.setImage(AgoraImageWithName("board_increase", self.classForCoder), for: .normal)
        return btn
    }()
    fileprivate lazy var decreaseBtn: AgoraBaseUIButton = {
        
        let btn = AgoraBaseUIButton(type: .custom)
        btn.addTarget(self, action: #selector(onDecreaseTouchEvent), for: .touchUpInside)
        if !AgoraDeviceAssistant.OS.isPad {
            btn.touchRange = TouchRange
        }
        btn.setImage(AgoraImageWithName("board_decrease", self.classForCoder), for: .normal)
        return btn
    }()
    fileprivate lazy var zoomBtn: AgoraBaseUIButton = {
        let btn = AgoraBaseUIButton(type: .custom)
        btn.addTarget(self, action: #selector(onZoomTouchEvent), for: .touchUpInside)
        if !AgoraDeviceAssistant.OS.isPad {
            btn.touchRange = TouchRange
        }
        btn.setImage(AgoraImageWithName("board_scale", self.classForCoder), for: .normal)
        return btn
    }()
    fileprivate lazy var labelView: AgoraBaseView = {
        let view = AgoraBaseView()
        view.backgroundColor = UIColor.clear
        
        let indexLabel = AgoraBaseUILabel()
        indexLabel.font = UIFont.systemFont(ofSize: AgoraDeviceAssistant.OS.isPad ? 13 : 9)
        indexLabel.backgroundColor = UIColor(red: 112/255.0, green: 125/255.0, blue: 188/255.0, alpha: 1)
        indexLabel.textColor = UIColor.white
        indexLabel.textAlignment = .center
        indexLabel.text = String(self.pageIndex)
        indexLabel.tag = PageIndexLabelTag
        indexLabel.clipsToBounds = true
        indexLabel.layer.cornerRadius =  AgoraDeviceAssistant.OS.isPad ? 8 : 5
        view.addSubview(indexLabel)
        indexLabel.agora_x = 0
        indexLabel.agora_center_y = 0
        indexLabel.agora_height = AgoraDeviceAssistant.OS.isPad ? 20 : 11
        indexLabel.agora_width = AgoraDeviceAssistant.OS.isPad ? 25 : 14
        
        let gapLabel = AgoraBaseUILabel()
        gapLabel.font = UIFont.systemFont(ofSize: AgoraDeviceAssistant.OS.isPad ? 13 : 9)
        gapLabel.text = "/"
        gapLabel.backgroundColor = UIColor.clear
        gapLabel.textColor = UIColor.white
        gapLabel.textAlignment = .center
        view.addSubview(gapLabel)
        gapLabel.agora_x = indexLabel.agora_x + indexLabel.agora_width
        gapLabel.agora_y = 0
        gapLabel.agora_bottom = 0
        gapLabel.agora_width = AgoraDeviceAssistant.OS.isPad ? 30 : 18
        
        let countLabel = AgoraBaseUILabel()
        countLabel.font = UIFont.systemFont(ofSize: AgoraDeviceAssistant.OS.isPad ? 13 : 9)
        countLabel.backgroundColor = UIColor.clear
        countLabel.textColor = UIColor.white
        countLabel.textAlignment = .center
        countLabel.tag = PageCountLabelTag
        countLabel.text = String(self.pageCount)
        countLabel.clipsToBounds = true
        countLabel.layer.cornerRadius =  AgoraDeviceAssistant.OS.isPad ? 5 : 5
        view.addSubview(countLabel)
        countLabel.agora_x = gapLabel.agora_x + gapLabel.agora_width
        countLabel.agora_y = 0
        countLabel.agora_bottom = 0
        countLabel.agora_width = AgoraDeviceAssistant.OS.isPad ? 25 : 14
    
        return view
    }()
    
    fileprivate let PageIndexLabelTag = 99
    fileprivate let PageCountLabelTag = 100
    fileprivate let TouchRange: CGFloat = 30
    
    convenience public init(delegate: AgoraPageControlProtocol?) {
        self.init(frame: CGRect.zero)
        self.delegate = delegate
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.initView()
        self.initLayout()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

// MARK: Rect
extension AgoraPageControlView {
    fileprivate func initView() {
        self.backgroundColor = UIColor(red: 143/255.0, green: 154/255.0, blue: 208/255.0, alpha: 1)
        self.clipsToBounds = true
        self.layer.cornerRadius = AgoraDeviceAssistant.OS.isPad ? 21 : 11
        
        self.addSubview(self.leftBtn)
        self.addSubview(self.labelView)
        self.addSubview(self.rightBtn)
        self.addSubview(self.increaseBtn)
        self.addSubview(self.decreaseBtn)
        self.addSubview(self.zoomBtn)
    }
    
    fileprivate func initLayout() {
        
        let sideGap: CGFloat = AgoraDeviceAssistant.OS.isPad ? 22 : 13
        let arrowSize: CGSize = AgoraDeviceAssistant.OS.isPad ? CGSize(width: 11, height: 20) : CGSize(width: 7, height: 11)
        let lableViewWidth: CGFloat = AgoraDeviceAssistant.OS.isPad ? 85 : 48
        let arrowGap: CGFloat = AgoraDeviceAssistant.OS.isPad ? 15 : 8
        let buttonGap: CGFloat = AgoraDeviceAssistant.OS.isPad ? 24 : 13
        let buttonSize: CGSize = AgoraDeviceAssistant.OS.isPad ? CGSize(width: 20, height: 20) : CGSize(width: 11, height: 11)
        
        self.leftBtn.agora_x = sideGap
        self.leftBtn.agora_center_y = 0
        self.leftBtn.agora_resize(arrowSize.width, arrowSize.height)
        
        self.labelView.agora_x = self.leftBtn.agora_x + self.leftBtn.agora_width + arrowGap
        self.labelView.agora_y = 0
        self.labelView.agora_bottom = 0
        self.labelView.agora_width = lableViewWidth
        
        self.rightBtn.agora_x = self.labelView.agora_x + self.labelView.agora_width + arrowGap
        self.rightBtn.agora_center_y = 0
        self.rightBtn.agora_resize(arrowSize.width, arrowSize.height)
        
        self.increaseBtn.agora_x = self.rightBtn.agora_x + self.rightBtn.agora_width + buttonGap
        self.increaseBtn.agora_center_y = 0
        self.increaseBtn.agora_resize(buttonSize.width, buttonSize.height)
        
        self.decreaseBtn.agora_x = self.increaseBtn.agora_x + self.increaseBtn.agora_width + buttonGap
        self.decreaseBtn.agora_center_y = 0
        self.decreaseBtn.agora_resize(buttonSize.width, buttonSize.height)
        
        self.zoomBtn.agora_x = self.decreaseBtn.agora_x + self.decreaseBtn.agora_width + buttonGap
        self.zoomBtn.agora_center_y = 0
        self.zoomBtn.agora_resize(buttonSize.width, buttonSize.height)
        self.zoomBtn.agora_right = sideGap
    }
}

// MARK: TouchEvent
extension AgoraPageControlView {
    @objc fileprivate func onLeftTouchEvent() {
        self.pageIndex -= 1
        self.delegate?.onPageLeftEvent()
    }
    @objc fileprivate func onRightTouchEvent() {
        self.pageIndex += 1
        self.delegate?.onPageRightEvent()
    }
    @objc fileprivate func onIncreaseTouchEvent() {
        self.delegate?.onPageIncreaseEvent()
    }
    @objc fileprivate func onDecreaseTouchEvent() {
        self.delegate?.onPageDecreaseEvent()
    }
    @objc fileprivate func onZoomTouchEvent() {
        self.delegate?.onPageZoomEvent()
    }
}
