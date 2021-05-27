//
//  SingleTimeView.swift
//  AgoraEducation
//
//  Created by LYY on 2021/5/8.
//  Copyright © 2021 Agora. All rights reserved.
//

import Foundation
import AgoraUIBaseViews

public class SingleTimeView: AgoraBaseUIView {
    private lazy var bg: AgoraBaseUIImageView = AgoraBaseUIImageView(image: UIImage(named: "bg_\(UIDevice.current.model)"))
    
    private lazy var strLabel: AgoraBaseUILabel = {
        let label = AgoraBaseUILabel()
        label.backgroundColor = .clear
        label.text = ""
        label.textAlignment = .center
        label.textColor = UIColor(hexString: "4D6277")
        label.font = UIFont.boldSystemFont(ofSize: (UIDevice.current.model == "iPad") ? 48 : 34)
        return label
    }()
    
    public func updateLabel(str: String,turnRed: Bool = false) {
        strLabel.text = str
    }
    
    public func turnColor(color: UIColor) {
        strLabel.textColor = color
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        initView()
        initLayout()

    }
    private func initView() {
        addSubview(bg)
        addSubview(strLabel)
    }
    
    private func initLayout() {
        bg.agora_x = 0
        bg.agora_y = 0
        bg.agora_right = 0
        bg.agora_bottom = 0
        
        strLabel.agora_center_x = 0
        strLabel.agora_center_y = 0
    }
    
    private func initMask() {
        
    }
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
