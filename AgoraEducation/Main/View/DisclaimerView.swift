//
//  PrivacyView.swift
//  AgoraEducation
//
//  Created by LYY on 2021/4/17.
//  Copyright © 2021 Agora. All rights reserved.
//

import Foundation
import AgoraUIBaseViews

public class DisclaimerView: AgoraBaseUIView {
    
    public override init(frame: CGRect) {
        super.init(frame: .zero)
        initView()
        initLayout()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
    private lazy var contentView: AgoraBaseUIView = {
        var contentView = AgoraBaseUIView()
        contentView.backgroundColor = LoginConfig.device == .iPad ? .white : UIColor(hexString: "F9F9FC")

        contentView.layer.cornerRadius = 8
        contentView.layer.backgroundColor = UIColor.white.cgColor
        contentView.layer.borderWidth = 1
        contentView.layer.borderColor = UIColor(hexString: "ECECF1").cgColor
        
        contentView.layer.shadowColor = UIColor(red: 0.18, green: 0.25, blue: 0.57, alpha: 0.15).cgColor
        contentView.layer.shadowOffset = CGSize(width: 0, height: 1.5)
        contentView.layer.shadowOpacity = 1
        contentView.layer.shadowRadius = 5
        
        return contentView
    }()
    
    private lazy var titleView: AgoraBaseUIView = {
        var titleView = AgoraBaseUIView()
        titleView.backgroundColor = .white
        titleView.layer.cornerRadius = 8
        
        var titleLabel = AgoraBaseUILabel()
        titleLabel.text = NSLocalizedString("About_disclaimer", comment: "")
        titleLabel.backgroundColor = .white
        titleLabel.textAlignment = .center
        titleLabel.font = UIFont.systemFont(ofSize: 17)
        titleLabel.textColor = UIColor(hexString: "191919")
        
        var backBtn = AgoraBaseUIButton()
        backBtn.setBackgroundImage(UIImage(named: "about_back"), for: .normal)
        backBtn.addTarget(self, action: #selector(onTouchBack), for: .touchUpInside)
        
        var line = AgoraBaseUIView()
        line.backgroundColor = UIColor(hexString: "EEEEF7")
        
        titleView.addSubview(titleLabel)
        titleView.addSubview(backBtn)
        titleView.addSubview(line)
        
        if LoginConfig.device == .iPad {
            titleLabel.agora_center_x = 0
            titleLabel.agora_center_y = 0
        } else {
            titleLabel.agora_center_x = 0
            titleLabel.agora_bottom = 9
        }
        line.agora_x = LoginConfig.dis_line_x
        line.agora_right = LoginConfig.dis_line_x
        line.agora_height = 1
        line.agora_bottom = 0
        
        backBtn.agora_x = LoginConfig.dis_back_x
        backBtn.agora_bottom = LoginConfig.dis_back_bottom
        
        return titleView
    }()
    
    private lazy var disclaLabel: AgoraBaseUILabel = {
        var label = AgoraBaseUILabel()
        label.numberOfLines = 0
        
        let attrString = NSMutableAttributedString(string: NSLocalizedString("Disclaimer_detail", comment: ""))
        let paraStyle = NSMutableParagraphStyle()
        paraStyle.paragraphSpacing = 21
        let attr: [NSAttributedString.Key : Any] = [.font: UIFont.systemFont(ofSize: 14),
                                                    .foregroundColor: UIColor(hexString: "586376"),
                                                    .paragraphStyle: paraStyle]

        attrString.addAttributes(attr, range: NSRange(location: 0, length: attrString.length))
        label.attributedText = attrString
        self.addSubview(label)
        
        return label
    }()
    
    private lazy var bottomLabel: AgoraBaseUILabel = {
        var label = AgoraBaseUILabel()
        label.text = NSLocalizedString("About_url", comment: "")
        label.font = UIFont.systemFont(ofSize: 12)
        label.textColor = UIColor(hexString: "7D8798")
        label.textAlignment = .center
        return label
    }()
    
    // MARK: touch event
    @objc private func onTouchBack() {
        if LoginConfig.device == .iPad {
            removeFromSuperview()
        } else {
            UIView.animate(withDuration: TimeInterval.agora_animation) {[weak self] in
                    self?.agora_x = self?.frame.width ?? 0

                    self?.transform = CGAffineTransform(translationX: self?.frame.width ?? 0,
                                                        y: 0)
                    self?.layoutIfNeeded()
            } completion: {[weak self] (complete) in
                guard complete else {
                    return
                }
                self?.removeFromSuperview()
            }
        }
    }
}

// MARK: UI
extension DisclaimerView {
    private func initView() {
        
        switch LoginConfig.device {
        case .iPhone_Big: fallthrough
        case .iPhone_Small:
            contentView.addSubview(bottomLabel)
        case .iPad:
            self.backgroundColor = UIColor.init(white: 1, alpha: 0.7)
        }
        self.addSubview(contentView)
        
        contentView.addSubview(titleView)
        contentView.addSubview(disclaLabel)
    }
    
    private func initLayout() {
        var width: CGFloat = 0
        var height: CGFloat = 0
        
        switch LoginConfig.device {
        case .iPhone_Big: fallthrough
        case .iPhone_Small:
            width = UIScreen.main.bounds.width
            height = UIScreen.main.bounds.height
            
            bottomLabel.agora_bottom = 31
            bottomLabel.agora_center_x = 0
        case .iPad:
            width = 420
            height = 450
        }
        
        contentView.agora_center_x = 0
        contentView.agora_center_y = 0
        contentView.agora_width = width
        contentView.agora_height = height
        
        titleView.agora_center_x = 0
        titleView.agora_width = contentView.agora_width
        titleView.agora_y = 0
        titleView.agora_height = LoginConfig.dis_title_height
        
        disclaLabel.agora_center_x = 0
        disclaLabel.agora_width = width - LoginConfig.dis_label_x * 2
        disclaLabel.agora_y = LoginConfig.dis_title_height + LoginConfig.dis_title_sep   
    }
}
