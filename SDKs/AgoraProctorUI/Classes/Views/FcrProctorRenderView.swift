//
//  FcrProctorRenderView.swift
//  AgoraProctorUI
//
//  Created by DoubleCircle on 2022/9/4.
//

import AgoraUIBaseViews

class FcrProctorRenderView: UIView {
    
}

// MARK: - AgoraUIContentContainer
extension FcrProctorRenderView: AgoraUIContentContainer {
    func initViews() {
        
    }
    
    func initViewFrame() {
        
    }
    
    func updateViewProperties() {
        let config = UIConfig.render
        
        backgroundColor = config.backgroundColor
        layer.cornerRadius = config.cornerRadius
    }
}
