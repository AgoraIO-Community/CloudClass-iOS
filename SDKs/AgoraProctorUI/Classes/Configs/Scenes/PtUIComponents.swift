//
//  PtUIComponents.swift
//  AgoraEduUI
//
//  Created by Cavan on 2022/7/7.
//

import UIKit

protocol PtUIComponentProtocol {
    var visible: Bool {get set}
    var enable: Bool {get set}
    var backgroundColor: UIColor {get set}
}

struct PtUIComponentDeviceTest: PtUIComponentProtocol {
    var visible: Bool            = true
    var enable: Bool             = true
    var backgroundColor: UIColor = PtUIColorGroup.systemBackgroundColor
    
    let backgroundImage = UIImage.pt_named("pt_background")
    let exitButton      = PtUIItemDeviceTestExitButton()
    let greetLabel      = PtUIItemDeviceTestGreetLabel()
    let stateLabel      = PtUIItemDeviceTestStateLabel()
    let titleLabel      = PtUIItemDeviceTestTitleLabel()
    let enterButton     = PtUIItemDeviceTestEnterButton()
    let noAccess        = PtUIItemDeviceTestNoAccess()
    let switchCamera    = PtUIItemDeviceTestSwitchCamera()
    let bottomMask      = PtUIItemDeviceTestBottomMask()
}

struct PtUIComponentRender: PtUIComponentProtocol {
    var visible: Bool            = true
    var enable: Bool             = true
    var backgroundColor: UIColor = PtUIColorGroup.systemForegroundColor
    
    let cornerRadius: CGFloat   = PtUIFrameGroup.renderCornerRadius
    let avatar                  = PtUIItemDeviceTestAvatar()
}

struct PtUIComponentExam: PtUIComponentProtocol {
    var visible: Bool = true
    var enable: Bool  = true
    var backgroundColor: UIColor = PtUIColorGroup.systemBackgroundColor
    
    let backgroundImage     = UIImage.pt_named("pt_background")
    let exitButton          = PtUIItemExamExitButton()
    let nameLabel           = PtUIItemExamNameLabel()
    let examNameLabel       = PtUIItemExamExamNameLabel()
    let beforeExamTipLabel  = PtUIItemExamBeforeExamTip()
    let leaveButton         = PtUIItemExamLeaveButton()
    let startCountDown      = PtUIItemExamStartCountDown()
    let duringCountDown     = PtUIItemExamDuringCountDown()
    let endLabel            = PtUIItemExamEndLabel()
    let switchCamera        = PtUIItemExamSwitchCamera()
}

// MARK: - alert
struct PtUIComponentAlert: PtUIComponentProtocol {
    var visible: Bool = true
    var enable: Bool = true
    var backgroundColor: UIColor = PtUIColorGroup.componentBackgroundColor
    
    let cornerRadius: CGFloat = PtUIFrameGroup.alertCornerRadius
    let sideSpacing: CGFloat = PtUIFrameGroup.alertSideSpacing
    
    let title = PtUIItemAlertTitle()
    let message = PtUIItemAlertMessage()
    let button = PtUIItemAlertButton()
    let shadow = PtUIItemShadow()
}

// MARK: - base
struct PtUIComponentLoading: PtUIComponentProtocol {
    var visible: Bool = true
    var enable: Bool = true
    var backgroundColor: UIColor = PtUIColorGroup.systemComponentColor
    
    let gifUrl: URL? = Bundle.AgoraProctorUI().url(forResource: "img_loading",
                                                   withExtension: "gif")
    
    let message = PtUIItemLoadingMessage()
}
