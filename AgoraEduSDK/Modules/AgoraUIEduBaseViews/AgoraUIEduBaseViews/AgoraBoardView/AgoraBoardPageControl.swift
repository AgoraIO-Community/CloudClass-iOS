//
//  AgoraBoardPageControlView.swift
//  AgoraEduSDK
//
//  Created by SRS on 2021/1/30.
//

import UIKit
import AgoraUIBaseViews

@objc public protocol AgoraBoardPageControlDelegate: NSObjectProtocol {
    func didFullScreenEvent(isFullScreen: Bool)
    func didPrePageTouchEvent(_ prePage: Int)
    func didNextPageTouchEvent(_ nextPage: Int)
    func didIncreaseTouchEvent()
    func didDecreaseTouchEvent()
}

@objcMembers public class AgoraBoardPageControlView: AgoraBaseUIView {
    public weak var delegate: AgoraBoardPageControlDelegate?
    
    private var pageIndex = 0 {
        didSet {
            let text = "\(pageIndex + 1) / \(pageCount)"
            pageIndexLabel.text = text
        }
    }
    
    // 屏幕分享是否显示
    public var isScreenVisible = false {
        didSet {
            self.containerView.isHidden = isScreenVisible
            self.fullScreenAloneButton.isHidden = !isScreenVisible
        }
    }
    
    private var pageCount = 1 {
        didSet {
            let text = "\(pageIndex + 1) / \(pageCount)"
            pageIndexLabel.text = text
        }
    }
    
    fileprivate lazy var prePageButton: AgoraBaseUIButton = {
        let button = AgoraBaseUIButton(frame: .zero)
        button.setImage(AgoraKitImage("icon-backward"),
                        for: .normal)
        
        button.addTarget(self,
                         action: #selector(doPrePagePressed),
                         for: .touchUpInside)
        
        if !AgoraKitDeviceAssistant.OS.isPad {
            button.touchRange = TouchRange
        }
        
        return button
    }()
    
    fileprivate lazy var nextPageButton: AgoraBaseUIButton = {
        let button = AgoraBaseUIButton(frame: .zero)
        button.setImage(AgoraKitImage("icon-forward"),
                        for: .normal)
        
        button.addTarget(self,
                         action: #selector(doNextPagePressed),
                         for: .touchUpInside)
        
        if !AgoraKitDeviceAssistant.OS.isPad {
            button.touchRange = TouchRange
        }
        
        return button
    }()
    
    fileprivate lazy var increaseButton: AgoraBaseUIButton = {
        let button = AgoraBaseUIButton(frame: .zero)
        button.setImage(AgoraKitImage("icon-zoomin"),
                        for: .normal)
        
        button.addTarget(self,
                         action: #selector(doIncreaseScalePressed),
                         for: .touchUpInside)
        
        if !AgoraKitDeviceAssistant.OS.isPad {
            button.touchRange = TouchRange
        }
        
        return button
    }()
    
    fileprivate lazy var decreaseButton: AgoraBaseUIButton = {
        let button = AgoraBaseUIButton(frame: .zero)
        button.setImage(AgoraKitImage("icon-zoomout"),
                        for: .normal)
        
        button.addTarget(self,
                         action: #selector(doDecreaseScalePressed),
                         for: .touchUpInside)
        
        if !AgoraKitDeviceAssistant.OS.isPad {
            button.touchRange = TouchRange
        }
        
        return button
    }()
    
    fileprivate lazy var containerView: AgoraBaseUIView = {
        let v = AgoraBaseUIView()
        v.backgroundColor = .white
        return v
    }()
    
    fileprivate lazy var fullScreenButton: AgoraBaseUIButton = {
        let button = AgoraBaseUIButton(frame: .zero)
        button.setImage(AgoraKitImage("icon-max"),
                        for: .normal)
        button.setImage(AgoraKitImage("icon-min"),
                        for: .selected)
        
        button.addTarget(self,
                         action: #selector(doFullScreenPressed),
                         for: .touchUpInside)
        
        if !AgoraKitDeviceAssistant.OS.isPad {
            button.touchRange = TouchRange
        }
        
        return button
    }()
    
    // 单个全屏按钮，标注屏幕使用
    fileprivate lazy var fullScreenAloneButton: AgoraBaseUIButton = {
        let button = AgoraBaseUIButton(frame: .zero)
        button.setImage(AgoraKitImage("icon-alone-max"),
                        for: .normal)
        button.setImage(AgoraKitImage("icon-alone-min"),
                        for: .selected)
        
        button.addTarget(self,
                         action: #selector(doFullScreenPressed),
                         for: .touchUpInside)
        
        if !AgoraKitDeviceAssistant.OS.isPad {
            button.touchRange = TouchRange
        }
        button.isHidden = true
        return button
    }()
    
    fileprivate lazy var pageIndexLabel: AgoraBaseUILabel = {
        let label = AgoraBaseUILabel(frame: .zero)
        label.backgroundColor = UIColor(rgb: 0xF4F4F8)
        label.textAlignment = .center
        label.font = UIFont.systemFont(ofSize: 14)
        label.textColor = UIColor(rgb: 0x586376)
        return label
    }()
    
    fileprivate lazy var speratorLine: AgoraBaseUIView = {
        let view = AgoraBaseUIView(frame: .zero)
        view.backgroundColor = UIColor(rgb: 0xE5E5F0)
        return view
    }()
    
    fileprivate let TouchRange: CGFloat = 30
    
    public override init(frame: CGRect) {
        super.init(frame: frame)
        initView()
        initLayout()
    }
    
    public required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        initView()
        initLayout()
    }
    
    public override func layoutSubviews() {
        super.layoutSubviews()
        pageIndexLabel.layer.cornerRadius = pageIndexLabel.bounds.size.height * 0.5
    }
    
    func doFullScreenPressed(_ sender: AgoraBaseUIButton) {
        let fullScreen = !sender.isSelected
        delegate?.didFullScreenEvent(isFullScreen: fullScreen)
    }

    func doDecreaseScalePressed(_ sender: AgoraBaseUIButton) {
        delegate?.didDecreaseTouchEvent()
    }

    func doIncreaseScalePressed(_ sender: AgoraBaseUIButton) {
        delegate?.didIncreaseTouchEvent()
    }

    func doPrePagePressed(_ sender: AgoraBaseUIButton) {
        delegate?.didPrePageTouchEvent(pageIndex - 1)
    }

    func doNextPagePressed(_ sender: AgoraBaseUIButton) {
        delegate?.didNextPageTouchEvent(pageIndex + 1)
    }
    
    @objc public func setPageIndex(_ pageIndex: Int,
                                     pageCount: Int) {
        self.pageIndex = pageIndex
        self.pageCount = pageCount
    }
    
    // 是否切成全屏
    @objc public func setFullScreen(_ fullScreen: Bool) {

        fullScreenButton.isSelected = fullScreen
        fullScreenAloneButton.isSelected = fullScreen
    }
    
    // 切页面
    @objc public func setPagingEnable(_ enable: Bool) {

        prePageButton.isUserInteractionEnabled = enable
        nextPageButton.isUserInteractionEnabled = enable
    }
    
    // 变大、变小
    @objc public func setZoomEnable(_ zoomOutEnable: Bool,
                                    zoomInEnable: Bool) {
        increaseButton.isUserInteractionEnabled = zoomOutEnable
        decreaseButton.isUserInteractionEnabled = zoomInEnable
    }
    
    // 能否最大、最小
    @objc  public func setResizeFullScreenEnable(_ enable: Bool) {
        fullScreenButton.isUserInteractionEnabled = enable
        fullScreenAloneButton.isUserInteractionEnabled = enable
    }
}


fileprivate extension AgoraBoardPageControlView {
     func initView() {
        
        addSubview(containerView)
        addSubview(fullScreenAloneButton)
        
        containerView.addSubview(fullScreenButton)
        containerView.addSubview(increaseButton)
        containerView.addSubview(decreaseButton)
        containerView.addSubview(speratorLine)
        containerView.addSubview(prePageButton)
        containerView.addSubview(pageIndexLabel)
        containerView.addSubview(nextPageButton)
        
        pageIndex = 0
    }
    
    func initLayout() {
        
        containerView.agora_x = 0
        containerView.agora_right = 0
        containerView.agora_y = 0
        containerView.agora_bottom = 0
        
        let buttonY: CGFloat = 6
        let buttonWidth: CGFloat = 28
        let buttonHeight: CGFloat = 28
        let subViewInterSpace: CGFloat = 6
         
        fullScreenButton.agora_x = 13
        fullScreenButton.agora_y = buttonY
        fullScreenButton.agora_width = buttonWidth
        fullScreenButton.agora_height = buttonHeight
        
        fullScreenAloneButton.agora_x = 13
        fullScreenAloneButton.agora_y = 0
        fullScreenAloneButton.agora_width = 53
        fullScreenAloneButton.agora_height = 53
        
        decreaseButton.agora_x = fullScreenButton.agora_x + buttonWidth + subViewInterSpace
        decreaseButton.agora_y = buttonY
        decreaseButton.agora_width = buttonWidth
        decreaseButton.agora_height = buttonHeight
        
        increaseButton.agora_x = decreaseButton.agora_x + buttonWidth + subViewInterSpace
        increaseButton.agora_y = buttonY
        increaseButton.agora_width = buttonWidth
        increaseButton.agora_height = buttonHeight
        
        speratorLine.agora_x = increaseButton.agora_x + buttonWidth + subViewInterSpace
        speratorLine.agora_y = 12
        speratorLine.agora_width = 1
        speratorLine.agora_height = 16
        
        prePageButton.agora_x = speratorLine.agora_x + speratorLine.agora_width + subViewInterSpace
        prePageButton.agora_y = buttonY
        prePageButton.agora_width = buttonWidth
        prePageButton.agora_height = buttonHeight
        
        let pageIndexLabelY = buttonY
        let pageIndexLabelHeight = buttonHeight
        
        pageIndexLabel.agora_x = prePageButton.agora_x + buttonWidth + subViewInterSpace
        pageIndexLabel.agora_y = pageIndexLabelY
        pageIndexLabel.agora_width = 64
        pageIndexLabel.agora_height = pageIndexLabelHeight
        pageIndexLabel.layer.masksToBounds = true
        
        nextPageButton.agora_x = pageIndexLabel.agora_x + pageIndexLabel.agora_width + subViewInterSpace
        nextPageButton.agora_y = buttonY
        nextPageButton.agora_width = buttonWidth
        nextPageButton.agora_height = buttonHeight
    }
}

// MARK: - Touch events
@objc extension AgoraBoardPageControlView {

}
