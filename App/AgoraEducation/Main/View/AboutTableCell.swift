//
//  AboutTableCell.swift
//  AgoraEducation
//
//  Created by LYY on 2021/4/25.
//  Copyright © 2021 Agora. All rights reserved.
//

import Foundation
import AgoraUIBaseViews

class AboutTableCell: AgoraBaseUITableViewCell {
    
    private var info: Any?
    private var gesture: UITapGestureRecognizer?
    
    override init(style: UITableViewCell.CellStyle,
                  reuseIdentifier: String?) {
        super.init(style: style,
                   reuseIdentifier: reuseIdentifier)
        
        backgroundColor = .white
        selectionStyle = .none
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func setInfo(title: String,detail: Any?){
        guard info == nil,
              gesture == nil else {
            return
        }
        guard let `detail` = detail else {
            return
        }
        info = detail
        
        if detail is URL {
            renderTypePushURL(title: title)
        } else if detail is AgoraBaseUIView {
            renderTypeShowView(title: title)
        } else if detail is String {
            renderTypeShowInfo(title: title, info: detail as! String)
        }
    }
    
    private func renderTypePushURL(title: String) {
        let titleLabel = AgoraBaseUILabel()
        titleLabel.text = title
        titleLabel.textColor = UIColor(hexString: "191919")
        titleLabel.font = LoginConfig.about_label_font
        titleLabel.isUserInteractionEnabled = false
        
        let btn = AgoraBaseUIButton()
        btn.setImage(UIImage(named: "about_detail"), for: .normal)
        btn.isUserInteractionEnabled = false
        
        contentView.addSubview(titleLabel)
        contentView.addSubview(btn)
        
        titleLabel.agora_x = LoginConfig.about_cell_title_x
        titleLabel.agora_center_y = 0
        
        btn.agora_right = LoginConfig.about_enter_right
        btn.agora_center_y = 0

    }
    
    private func renderTypeShowView(title: String) {
        let titleLabel = AgoraBaseUILabel()
        titleLabel.text = title
        titleLabel.textColor = UIColor(hexString: "191919")
        titleLabel.font = LoginConfig.about_label_font
        titleLabel.isUserInteractionEnabled = false
        
        let btn = AgoraBaseUIButton()
        btn.setImage(UIImage(named: "about_detail"), for: .normal)
        btn.isUserInteractionEnabled = false
        
        contentView.addSubview(titleLabel)
        contentView.addSubview(btn)
        
        titleLabel.agora_x = LoginConfig.about_cell_title_x
        titleLabel.agora_center_y = 0
        
        btn.agora_right = LoginConfig.about_enter_right
        btn.agora_center_y = 0
    }
    
    private func renderTypeShowInfo(title: String,info: String) {
        
        let titleLabel = AgoraBaseUILabel()
        titleLabel.text = title
        titleLabel.textColor = UIColor(hexString: "191919")
        titleLabel.font = LoginConfig.about_label_font
        
        let infoLabel = AgoraBaseUILabel()
        infoLabel.textColor = UIColor(hexString: "586376")
        infoLabel.text = info
        infoLabel.font = LoginConfig.about_label_font
        
        contentView.addSubview(titleLabel)
        contentView.addSubview(infoLabel)
        
        titleLabel.agora_x = LoginConfig.about_cell_title_x
        titleLabel.agora_center_y = 0
        
        infoLabel.agora_center_y = 0
        infoLabel.agora_safe_right = LoginConfig.about_cell_info_right
    }
}
