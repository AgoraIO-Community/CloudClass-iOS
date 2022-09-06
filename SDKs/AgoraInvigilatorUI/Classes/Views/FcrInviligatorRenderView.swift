//
//  FcrInviligatorRenderView.swift
//  AgoraInvigilatorUI
//
//  Created by DoubleCircle on 2022/9/4.
//

import AgoraUIBaseViews

class FcrInviligatorRenderView: UIView {
    
}

// MARK: - AgoraUIContentContainer
extension FcrInviligatorRenderView: AgoraUIContentContainer {
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
