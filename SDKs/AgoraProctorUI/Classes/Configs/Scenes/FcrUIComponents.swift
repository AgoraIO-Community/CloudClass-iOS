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

struct FcrUIComponentDeviceTest: FcrUIComponentProtocol {
    var visible: Bool            = true
    var enable: Bool             = true
    var backgroundColor: UIColor = FcrUIColorGroup.systemBackgroundColor
    
    let backgroundImage = UIImage.fcr_named("background")
    let exitButton      = FcrUIItemDeviceTestExitButton()
    let greetLabel      = FcrUIItemDeviceTestGreetLabel()
    let stateLabel      = FcrUIItemDeviceTestStateLabel()
    let titleLabel      = FcrUIItemDeviceTestTitleLabel()
    let enterButton     = FcrUIItemDeviceTestEnterButton()
    let avatar          = FcrUIItemDeviceTestAvatar()
    let noAccess        = FcrUIItemDeviceTestNoAccess()
    let switchCamera    = FcrUIItemDeviceTestSwitchCamera()
}

struct FcrUIComponentRender: FcrUIComponentProtocol {
    var visible: Bool            = true
    var enable: Bool             = true
    var backgroundColor: UIColor = FcrUIColorGroup.systemBackgroundColor
    
    let cornerRadius = FcrUIFrameGroup.renderCornerRadius
}

struct FcrUIComponentExam: FcrUIComponentProtocol {
    var visible: Bool = true
    var enable: Bool  = true
    var backgroundColor: UIColor = FcrUIColorGroup.systemBackgroundColor
    
    let backgroundImage     = UIImage.fcr_named("background")
    let exitButton          = FcrUIItemExamExitButton()
    let nameLabel           = FcrUIItemExamNameLabel()
    let leaveButton         = FcrUIItemExamLeaveButton()
    let startCountDown      = FcrUIItemExamStartCountDown()
    let duringCountDown     = FcrUIItemExamDuringCountDown()
    let endLabel            = FcrUIItemExamEndLabel()
    let switchCamera        = FcrUIItemExamSwitchCamera()
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

// MARK: - base
struct FcrUIComponentLoading: FcrUIComponentProtocol {
    var visible: Bool = true
    var enable: Bool = true
    var backgroundColor: UIColor = FcrUIColorGroup.systemComponentColor
    
    let gifUrl: URL? = Bundle.AgoraProctorUI().url(forResource: "img_loading",
                                                   withExtension: "gif")
    
    let message = FcrUIItemLoadingMessage()
}
