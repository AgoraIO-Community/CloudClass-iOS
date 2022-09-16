//
//  FcrProctorRenderView.swift
//  AgoraProctorUI
//
//  Created by DoubleCircle on 2022/9/4.
//

import AgoraUIBaseViews

class FcrProctorRenderView: UIView {
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        initViews()
        initViewFrame()
        updateViewProperties()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

// MARK: - AgoraUIContentContainer
extension FcrProctorRenderView: AgoraUIContentContainer {
    func initViews() {
        clipsToBounds = true
    }
    
    func initViewFrame() {
        
    }
    
    func updateViewProperties() {
        let config = UIConfig.render
        
        backgroundColor = config.backgroundColor
        layer.cornerRadius = config.cornerRadius
        
        // TODO: subviews拿不到
        for subView in subviews {
            subView.layer.cornerRadius = config.cornerRadius
        }
    }
}
