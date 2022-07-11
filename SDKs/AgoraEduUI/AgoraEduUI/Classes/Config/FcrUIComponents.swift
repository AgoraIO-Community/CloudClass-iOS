//
//  FcrUIComponents.swift
//  AgoraEduUI
//
//  Created by Cavan on 2022/7/7.
//

import UIKit

protocol FcrUIComponentProtocol {
    var visible: Bool {get set}
    var enable: Bool {get set}
    var background: UIColor {get set}
}

struct FcrUIComponentStateBar: FcrUIComponentProtocol {
    var visible: Bool = true
    var enable: Bool = true
    var background: UIColor = FcrColorGroup.fcr_system_background_color
    
    var network = FcrUIItemNetwork()
    var roomName = FcrUIItemNetwork()
}

struct FcrUIComponentBoard: FcrUIComponentProtocol {
    var visible: Bool = true
    var enable: Bool = true
    var background: UIColor = FcrColorGroup.fcr_system_background_color
    
//    var pageControl 
}
