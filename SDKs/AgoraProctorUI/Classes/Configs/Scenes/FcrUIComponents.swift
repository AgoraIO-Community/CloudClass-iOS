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
    var backgroundColor: UIColor = FcrUIColorGroup.systemBackgroundColor
    
    let backgroundImage = UIImage.fcr_named("background")
    let exitButton      = FcrUIItemDeviceExitButton()
    let greetLabel      = FcrUIItemDeviceGreetLabel()
    let stateLabel      = FcrUIItemDeviceStateLabel()
    let titleLabel      = FcrUIItemDeviceTitleLabel()
    let enterButton     = FcrUIItemDeviceEnterButton()
    let avatar          = FcrUIItemDeviceAvatar()
    let noAccess        = FcrUIItemDeviceNoAccess()
}

struct FcrUIComponentRender: FcrUIComponentProtocol {
    var visible: Bool            = true
    var enable: Bool             = true
    var backgroundColor: UIColor = FcrUIColorGroup.systemBackgroundColor
    
    let cornerRadius = FcrUIFrameGroup.buttonCornerRadius
}

struct FcrUIComponentExam: FcrUIComponentProtocol {
    var visible: Bool = true
    var enable: Bool  = true
    var backgroundColor: UIColor = .black
    
    let backgroundImage = UIImage.fcr_named("background")
}

// MARK: - alert
struct FcrUIComponentAlert: FcrUIComponentProtocol {
    var visible: Bool = true
    var enable: Bool = true
    var backgroundColor: UIColor = FcrUIColorGroup.systemComponentColor
    
    let cornerRadius: CGFloat = FcrUIFrameGroup.alertCornerRadius
    let sideSpacing: CGFloat = FcrUIFrameGroup.alertSideSpacing
    
    let title = FcrUIItemAlertTitle()
    let message = FcrUIItemAlertMessage()
    let button = FcrUIItemAlertButton()
    let shadow = FcrUIItemShadow()
    let sepLine = FcrUIItemSepLine()
}
