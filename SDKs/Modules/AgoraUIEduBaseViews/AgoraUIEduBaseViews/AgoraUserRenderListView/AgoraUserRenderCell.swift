//
//  AgoraUIUserCell.swift
//  AgoraUIEduBaseViews
//
//  Created by ZYP on 2021/3/12.
//

import UIKit
import AgoraUIBaseViews

public class AgoraUserRenderCell: AgoraBaseUICollectionCell {
    public var userView: AgoraUIUserView? {
        didSet {
            layoutUserView()
        }
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func layoutUserView() {
        guard let view = userView else {
            return
        }
        
        if let superView = view.superview,
           superview == contentView {
            return
        }
        
        view.removeFromSuperview()
        view.agora_clear_constraint()
        
        contentView.addSubview(view)
        view.agora_x = 0
        view.agora_y = 2
        view.agora_right = 0
        view.agora_bottom = 2
    }
}
