//
//  AgreementView.swift
//  AgoraEducation
//
//  Created by DoubleCircle on 2022/6/11.
//  Copyright © 2022 Agora. All rights reserved.
//

import UIKit

class AgreementView: UIView {
    private(set) lazy var checkButton =  UIButton(type: .custom)
    private lazy var checkLabel =  UILabel(frame: .zero)
    private(set) lazy var agreeButton =  UIButton(type: .custom)
    private(set) lazy var disagreeButton =  UIButton(type: .custom)
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        initViews()
        initLayout()
    }
    
    private func initViews() {
        backgroundColor = UIColor(hex: 0xFFFFFFF,
                                  transparency: 0.5)
        
        addSubview(checkButton)
        checkLabel.text = "Service_check_content".ag_localized()
        checkLabel.textColor = UIColor(hex: 0x7D8798)
        checkLabel.font = .systemFont(ofSize: 10)
        addSubview(checkLabel)
        
        agreeButton.setTitle("Service_agree".ag_localized(),
                             for: .normal)
        agreeButton.setTitleColor(.white,
                                  for: .normal)
        agreeButton.backgroundColor = UIColor(hex: 0xC0D6FF)
        agreeButton.isUserInteractionEnabled = true
        agreeButton.titleLabel?.font = .systemFont(ofSize: 14)
        agreeButton.layer.cornerRadius = 22
        addSubview(agreeButton)
        
        disagreeButton.setTitle("Service_disagree".ag_localized(),
                                for: .normal)
        disagreeButton.setTitleColor(UIColor(hex: 0x8A8A9A),
                                  for: .normal)
        disagreeButton.backgroundColor = .clear
        disagreeButton.titleLabel?.font = .systemFont(ofSize: 12)
        disagreeButton.isUserInteractionEnabled = true
        addSubview(disagreeButton)
    }
    
    private func initLayout() {
        var checkLabelWidth: CGFloat = 0
        if let width = checkLabel.text?.agora_size(font: checkLabel.font).width {
            checkLabelWidth = width
        }
        let isPad = (LoginConfig.device == .iPad)
        let offset: CGFloat = 5
        let checkButtonWidth: CGFloat = isPad ? 14 : 12
        
        checkButton.mas_makeConstraints { make in
            make?.top.equalTo()(31)
            make?.height.width().equalTo()(checkButtonWidth)
            make?.centerX.equalTo()(-(checkButtonWidth + offset + checkLabelWidth) / 2)
        }
        checkLabel.mas_makeConstraints { make in
            make?.left.equalTo()(checkButton.mas_right)?.offset()(offset)
            make?.centerY.equalTo()(checkButton)
        }

        disagreeButton.mas_makeConstraints { make in
            make?.left.equalTo()(20)
            make?.right.equalTo()(-20)
            make?.height.equalTo()(34)
            make?.bottom.equalTo()(-34)
        }
        agreeButton.mas_makeConstraints { make in
            make?.left.equalTo()(20)
            make?.right.equalTo()(-20)
            make?.height.equalTo()(34)
            make?.bottom.equalTo()(disagreeButton.mas_top)?.offset()(-4)
        }
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
