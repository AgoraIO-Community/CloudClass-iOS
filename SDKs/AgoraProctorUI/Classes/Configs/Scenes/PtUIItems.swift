//
//  PtUIItems.swift
//  AgoraEduUI
//
//  Created by Cavan on 2022/7/7.
//

import UIKit

protocol PtUIItemProtocol {
    var visible: Bool { get }
    var enable: Bool { get }
}

// Device
struct PtUIItemDeviceTestExitButton: PtUIItemProtocol {
    var visible: Bool    = true
    var enable: Bool     = true
    
    let backgroundColor: UIColor = PtUIColorGroup.iconBackgroundColor
    let image: UIImage?          = .pt_named("pt_exit")
    let cornerRadius             = PtUIFrameGroup.systemCornerRadius
}

struct PtUIItemDeviceTestGreetLabel: PtUIItemProtocol {
    var visible: Bool    = true
    var enable: Bool     = true
    
    let font:  UIFont = PtUIFontGroup.font24
    let color: UIColor = PtUIColorGroup.textLevel1Color
}

struct PtUIItemDeviceTestStateLabel: PtUIItemProtocol {
    var visible: Bool    = true
    var enable: Bool     = true
    
    let font:  UIFont = PtUIFontGroup.font12
    let color: UIColor = PtUIColorGroup.textLevel1Color
}

struct PtUIItemDeviceTestTitleLabel: PtUIItemProtocol {
    var visible: Bool    = true
    var enable: Bool     = true
    
    let font:  UIFont = PtUIFontGroup.font14
    let color: UIColor = PtUIColorGroup.textLevel1Color
}

struct PtUIItemDeviceTestAvatar: PtUIItemProtocol {
    var visible: Bool    = true
    var enable: Bool     = true
    
    let backgroundColor: UIColor = .clear
    let borderWidth: CGFloat     = PtUIFrameGroup.highlightBorderWidth
    let borderColor: UIColor     = PtUIColorGroup.componentBorderColor
    let titleFont:  UIFont       = PtUIFontGroup.font30
    let titleColor: UIColor      = PtUIColorGroup.textDarkContrastColor
}

struct PtUIItemDeviceTestSwitchCamera: PtUIItemProtocol {
    var visible: Bool    = true
    var enable: Bool     = true
    
    let normalImage: UIImage?    = .pt_named("pt_switch_normal")
    let selectedImage: UIImage?  = .pt_named("pt_switch_selected")
    let backgroundColor: UIColor = PtUIColorGroup.iconAlphaBackgroundColor
    let labelColor: UIColor      = PtUIColorGroup.textDarkContrastColor
    let labelFont: UIFont        = PtUIFontGroup.font12
}

struct PtUIItemDeviceTestBottomMask: PtUIItemProtocol {
    var visible: Bool    = true
    var enable: Bool     = true
    
    let startColor: UIColor    = .clear
    let endColor: UIColor      = PtUIColorGroup.systemBackgroundColor.withAlphaComponent(0.5)
}

struct PtUIItemDeviceTestEnterButton: PtUIItemProtocol {
    var visible: Bool    = true
    var enable: Bool     = true
    
    let backgroundColor: UIColor = PtUIColorGroup.systemBrandColor
    let titleFont:  UIFont       = PtUIFontGroup.font16
    let titleColor: UIColor      = PtUIColorGroup.textDarkContrastColor
}

struct PtUIItemDeviceTestNoAccess: PtUIItemProtocol {
    var visible: Bool    = true
    var enable: Bool     = true
    
    let backgroundColor: UIColor        = .clear
    let cardBackgroundColor: UIColor    = PtUIColorGroup.componentBackgroundColor
    let cornerRadius                    = PtUIFrameGroup.card1CornerRadius
    let titleFont:  UIFont              = PtUIFontGroup.font20
    let titleColor: UIColor             = PtUIColorGroup.textLightContrastColor
    let contentFont:  UIFont            = PtUIFontGroup.font14
    let contentColor: UIColor           = PtUIColorGroup.textLightContrastColor
    
    let image: UIImage?          = UIImage.pt_named("pt_devicetest_noaccess")
}

// Exam
struct PtUIItemExamExitButton: PtUIItemProtocol {
    var visible: Bool    = true
    var enable: Bool     = true
    
    let backgroundColor: UIColor = PtUIColorGroup.iconBackgroundColor
    let image: UIImage?          = .pt_named("pt_exit")
    let cornerRadius: CGFloat    = PtUIFrameGroup.systemCornerRadius
}

struct PtUIItemExamNameLabel: PtUIItemProtocol {
    var visible: Bool    = true
    var enable: Bool     = true
    
    let font:  UIFont   = PtUIFontGroup.font16
    let color: UIColor  = PtUIColorGroup.textLevel1Color
}

struct PtUIItemExamExamNameLabel: PtUIItemProtocol {
    var visible: Bool    = true
    var enable: Bool     = true
    
    let font:  UIFont   = PtUIFontGroup.font16.bold
    let color: UIColor  = PtUIColorGroup.textLevel1Color
}

struct PtUIItemExamBeforeExamTip: PtUIItemProtocol {
    var visible: Bool    = true
    var enable: Bool     = true
    
    let backgroundColor: UIColor = PtUIColorGroup.systemBrandColor
    let font:  UIFont            = PtUIFontGroup.font12
    let color: UIColor           = PtUIColorGroup.textDarkContrastColor
}

struct PtUIItemExamLeaveButton: PtUIItemProtocol {
    var visible: Bool    = true
    var enable: Bool     = true
    
    let backgroundColor: UIColor = PtUIColorGroup.systemErrorColor
    let titleFont:  UIFont       = PtUIFontGroup.font16
    let titleColor: UIColor      = PtUIColorGroup.textDarkContrastColor
}

struct PtUIItemExamStartCountDown: PtUIItemProtocol {
    var visible: Bool    = true
    var enable: Bool     = true
    
    let image:  UIImage? = .pt_named("pt_exam_countdown_bg")
    let textColor: UIColor   = PtUIColorGroup.textLightContrastColor
    let textFont:  UIFont = PtUIFontGroup.font60
}

struct PtUIItemExamDuringCountDown: PtUIItemProtocol {
    var visible: Bool    = true
    var enable: Bool     = true
    
    let dotColor: UIColor = PtUIColorGroup.textLevel1Color
    let dotBorderWidth: CGFloat = PtUIFrameGroup.dotBorderWidth
    let textFont:  UIFont = PtUIFontGroup.font16
    let textColor: UIColor = PtUIColorGroup.textLevel1Color
}

struct PtUIItemExamSwitchCamera: PtUIItemProtocol {
    var visible: Bool    = true
    var enable: Bool     = true
    
    let normalImage: UIImage?    = UIImage.pt_named("pt_switch_normal")
    let selectedImage: UIImage?  = UIImage.pt_named("pt_switch_selected")
    let backgroundColor: UIColor = PtUIColorGroup.iconAlphaBackgroundColor
}

struct PtUIItemExamEndLabel: PtUIItemProtocol {
    var visible: Bool    = true
    var enable: Bool     = true
    
    let backgroundColor: UIColor = PtUIColorGroup.cardBackgroundColor
    let cornerRadius = PtUIFrameGroup.card2CornerRadius
    let textFont:  UIFont = PtUIFontGroup.font14
    let textColor: UIColor = PtUIColorGroup.textLightContrastColor
}

// Alert
struct PtUIItemAlertTitle: PtUIItemProtocol {
    var visible: Bool = true
    var enable: Bool  = true
    
    let color: UIColor  = PtUIColorGroup.textLightContrastColor
    let font: UIFont    = PtUIFontGroup.font17
}

struct PtUIItemAlertMessage: PtUIItemProtocol {
    var visible: Bool = true
    var enable: Bool  = true
    
    let color: UIColor     = PtUIColorGroup.textLightContrastColor
    let font: UIFont       = PtUIFontGroup.font14
}

struct PtUIItemAlertButton: PtUIItemProtocol {
    var visible: Bool = true
    var enable: Bool  = true
    
    let normalTitleColor: UIColor           = PtUIColorGroup.textLightContrastColor
    let normalBackgroundColor: UIColor      = PtUIColorGroup.buttonNormalColor
    let highlightTitleColor: UIColor        = PtUIColorGroup.textDarkContrastColor
    let highlightBackgroundColor: UIColor   = PtUIColorGroup.systemBrandColor
    let font: UIFont                        = PtUIFontGroup.font13
}

// MARK: - common
struct PtUIItemShadow: PtUIItemProtocol {
    var visible: Bool = true
    var enable: Bool  = true
    
    let color: CGColor  = PtUIColorGroup.containerShadowColor.cgColor
    let offset: CGSize  = PtUIColorGroup.containerShadowOffset
    let opacity: Float  = PtUIColorGroup.shadowOpacity
    let radius: CGFloat = PtUIColorGroup.containerShadowRadius
}

// loading
struct PtUIItemLoadingMessage: PtUIItemProtocol {
    var visible: Bool = true
    var enable: Bool  = true
    
    let color: UIColor = PtUIColorGroup.textLevel1Color
    let font: UIFont   = PtUIFontGroup.font13
}
