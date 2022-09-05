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
    var backgroundColor: UIColor {get set}
}

struct FcrUIComponentDevice: FcrUIComponentProtocol {
    var visible: Bool            = true
    var enable: Bool             = true
    var backgroundColor: UIColor = .black
    
    let backgroundImage = UIImage.fcr_named("background")
    let exit            = FcrUIItemDeviceExit()
    let titleLabel      = FcrUIItemDeviceTitle()
}

struct FcrUIComponentRender: FcrUIComponentProtocol {
    var visible: Bool            = true
    var enable: Bool             = true
    var backgroundColor: UIColor = .clear
}

struct FcrUIComponentExam: FcrUIComponentProtocol {
    var visible: Bool = true
    var enable: Bool  = true
    var backgroundColor: UIColor = .black
    
    let backgroundImage = UIImage.fcr_named("background")
}
