//
//  AgoraUserRenderListView.swift
//  AgoraUIEduBaseViews
//
//  Created by ZYP on 2021/3/12.
//

import UIKit
import AgoraUIBaseViews
import AgoraEduContext

@objcMembers public class AgoraUserRenderScrollView: AgoraBaseUIView {
    public static var preferenceHeight: CGFloat = AgoraKitDeviceAssistant.OS.isPad ? 168 : 87
    public static var preferenceWidth: CGFloat = preferenceHeight
    public static var preferenceVideoGapX: CGFloat = 2
    
    public weak var context: AgoraEduUserContext?
    
    public let leftButton = AgoraBaseUIButton()
    public let rightButton = AgoraBaseUIButton()

    public let scrollView = AgoraBaseUIScrollView(frame: .zero)
    
    public override init(frame: CGRect) {
        super.init(frame: frame)
        initViews()
        initLayout()
        observeUI()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        initViews()
        initLayout()
        observeUI()
    }
    
    // MARK: touch event
    @objc func buttonTap(btn: AgoraBaseUIButton) {
        let Gap: CGFloat = AgoraUserRenderScrollView.preferenceVideoGapX
        
        var x: CGFloat = 0
        
        let count = Int(scrollView.contentOffset.x / (AgoraUserRenderScrollView.preferenceWidth + Gap))
        
        if btn == leftButton {
            let pageWidth = CGFloat(count - 1) * (AgoraUserRenderScrollView.preferenceWidth + Gap)
            x = max(pageWidth, 0)
        } else {
            let pageWidth = CGFloat((count + 1)) * (AgoraUserRenderScrollView.preferenceWidth + Gap)
            x = min(pageWidth, scrollView.contentSize.width - scrollView.frame.width)
        }
        
        scrollView.setContentOffset(CGPoint(x: x, y: 0), animated: true)
    }
}

// MARK: - Private
private extension AgoraUserRenderScrollView {
    func initViews() {
        clipsToBounds = true
        layer.cornerRadius = AgoraKitDeviceAssistant.OS.isPad ? 10 : 4
        
        scrollView.backgroundColor = UIColor(rgb: 0xf8f8fc)
        scrollView.showsHorizontalScrollIndicator = false

        leftButton.setTitle(nil,
                            for: .normal)
        leftButton.setImage(AgoraKitImage("leftButtonIcon"),
                            for: .normal)
        leftButton.isHidden = true
        
        rightButton.setTitle(nil,
                             for: .normal)
        rightButton.setImage(AgoraKitImage("rightButtonIcon"),
                             for: .normal)
        rightButton.isHidden = true

        addSubview(scrollView)
        addSubview(leftButton)
        addSubview(rightButton)
    }
    
    func initLayout() {
        scrollView.agora_x = 0
        scrollView.agora_y = 0
        scrollView.agora_right = 0
        scrollView.agora_bottom = 0
        
        leftButton.agora_x = 0
        leftButton.agora_y = 0
        leftButton.agora_bottom = 0
        
        rightButton.agora_right = 0
        rightButton.agora_y = 0
        rightButton.agora_bottom = 0
    }
    
    func observeUI() {
        leftButton.addTarget(self,
                             action: #selector(buttonTap(btn:)),
                             for: .touchUpInside)
        rightButton.addTarget(self,
                              action: #selector(buttonTap(btn:)),
                              for: .touchUpInside)
    }
}
