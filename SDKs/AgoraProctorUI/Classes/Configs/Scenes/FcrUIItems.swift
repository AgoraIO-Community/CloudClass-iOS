//
//  FcrUIItems.swift
//  AgoraEduUI
//
//  Created by Cavan on 2022/7/7.
//

import UIKit

protocol FcrUIItemProtocol {
    var visible: Bool { get }
    var enable: Bool { get }
}

// Device
struct FcrUIItemDeviceTestExitButton: FcrUIItemProtocol {
    var visible: Bool    = true
    var enable: Bool     = true
    
    let backgroundColor: UIColor = FcrUIColorGroup.iconBackgroundColor
    let image: UIImage?          = .fcr_named("fcr_exit")
    let cornerRadius             = FcrUIFrameGroup.systemCornerRadius
}

struct FcrUIItemDeviceTestGreetLabel: FcrUIItemProtocol {
    var visible: Bool    = true
    var enable: Bool     = true
    
    let font:  UIFont = FcrUIFontGroup.font24
    let color: UIColor = FcrUIColorGroup.textLevel1Color
}

struct FcrUIItemDeviceTestStateLabel: FcrUIItemProtocol {
    var visible: Bool    = true
    var enable: Bool     = true
    
    let font:  UIFont = FcrUIFontGroup.font12
    let color: UIColor = FcrUIColorGroup.textLevel1Color
}

struct FcrUIItemDeviceTestTitleLabel: FcrUIItemProtocol {
    var visible: Bool    = true
    var enable: Bool     = true
    
    let font:  UIFont = FcrUIFontGroup.font14
    let color: UIColor = FcrUIColorGroup.textLevel1Color
}

struct FcrUIItemDeviceTestAvatar: FcrUIItemProtocol {
    var visible: Bool    = true
    var enable: Bool     = true
    
    let backgroundColor: UIColor = .clear
    let borderWidth: CGFloat     = FcrUIFrameGroup.highlightBorderWidth
    let borderColor: UIColor     = FcrUIColorGroup.componentBorderColor
    let titleFont:  UIFont       = FcrUIFontGroup.font30
    let titleColor: UIColor      = FcrUIColorGroup.textDarkContrastColor
}

struct FcrUIItemDeviceTestSwitchCamera: FcrUIItemProtocol {
    var visible: Bool    = true
    var enable: Bool     = true
    
    let normalImage: UIImage?    = .fcr_named("fcr_switch_normal")
    let selectedImage: UIImage?  = .fcr_named("fcr_switch_selected")
    let backgroundColor: UIColor = FcrUIColorGroup.iconBackgroundColor
    let labelColor: UIColor      = FcrUIColorGroup.textDarkContrastColor
    let labelFont: UIFont        = FcrUIFontGroup.font12
}

struct FcrUIItemDeviceTestEnterButton: FcrUIItemProtocol {
    var visible: Bool    = true
    var enable: Bool     = true
    
    let backgroundColor: UIColor = FcrUIColorGroup.systemBrandColor
    let titleFont:  UIFont       = FcrUIFontGroup.font16
    let titleColor: UIColor      = FcrUIColorGroup.textDarkContrastColor
}

struct FcrUIItemDeviceTestNoAccess: FcrUIItemProtocol {
    var visible: Bool    = true
    var enable: Bool     = true
    
    let backgroundColor: UIColor        = .clear
    let cardBackgroundColor: UIColor    = FcrUIColorGroup.componentBackgroundColor
    let cornerRadius                    = FcrUIFrameGroup.card1CornerRadius
    let titleFont:  UIFont              = FcrUIFontGroup.font20
    let titleColor: UIColor             = FcrUIColorGroup.textLightContrastColor
    let contentFont:  UIFont            = FcrUIFontGroup.font14
    let contentColor: UIColor           = FcrUIColorGroup.textLightContrastColor
    
    let image: UIImage?          = UIImage.fcr_named("fcr_devicetest_noaccess")
}

// Exam
struct FcrUIItemExamExitButton: FcrUIItemProtocol {
    var visible: Bool    = true
    var enable: Bool     = true
    
    let backgroundColor: UIColor = FcrUIColorGroup.iconBackgroundColor
    let image: UIImage?          = .fcr_named("fcr_exit")
    let cornerRadius: CGFloat    = FcrUIFrameGroup.systemCornerRadius
}

struct FcrUIItemExamNameLabel: FcrUIItemProtocol {
    var visible: Bool    = true
    var enable: Bool     = true
    
    let font:  UIFont   = FcrUIFontGroup.font16
    let color: UIColor  = FcrUIColorGroup.textLevel1Color
}

struct FcrUIItemExamExamNameLabel: FcrUIItemProtocol {
    var visible: Bool    = true
    var enable: Bool     = true
    
    let font:  UIFont   = FcrUIFontGroup.font16.bold
    let color: UIColor  = FcrUIColorGroup.textLevel1Color
}

struct FcrUIItemExamBeforeExamTip: FcrUIItemProtocol {
    var visible: Bool    = true
    var enable: Bool     = true
    
    let backgroundColor: UIColor = FcrUIColorGroup.systemBrandColor
    let font:  UIFont            = FcrUIFontGroup.font12
    let color: UIColor           = FcrUIColorGroup.textDarkContrastColor
}

struct FcrUIItemExamLeaveButton: FcrUIItemProtocol {
    var visible: Bool    = true
    var enable: Bool     = true
    
    let backgroundColor: UIColor = FcrUIColorGroup.systemErrorColor
    let titleFont:  UIFont       = FcrUIFontGroup.font16
    let titleColor: UIColor      = FcrUIColorGroup.textDarkContrastColor
}

struct FcrUIItemExamStartCountDown: FcrUIItemProtocol {
    var visible: Bool    = true
    var enable: Bool     = true
    
    let image:  UIImage? = .fcr_named("fcr_exam_countdown_bg")
    let textColor: UIColor   = FcrUIColorGroup.textLightContrastColor
    let textFont:  UIFont = FcrUIFontGroup.font60
}

struct FcrUIItemExamDuringCountDown: FcrUIItemProtocol {
    var visible: Bool    = true
    var enable: Bool     = true
    
    let dotColor: UIColor = FcrUIColorGroup.textLevel1Color
    let dotBorderWidth: CGFloat = FcrUIFrameGroup.dotBorderWidth
    let textFont:  UIFont = FcrUIFontGroup.font16
    let textColor: UIColor = FcrUIColorGroup.textLevel1Color
}

struct FcrUIItemExamSwitchCamera: FcrUIItemProtocol {
    var visible: Bool    = true
    var enable: Bool     = true
    
    let normalImage: UIImage?    = UIImage.fcr_named("fcr_switch_normal")
    let selectedImage: UIImage?  = UIImage.fcr_named("fcr_switch_selected")
    let backgroundColor: UIColor = FcrUIColorGroup.iconBackgroundColor
}

struct FcrUIItemExamEndLabel: FcrUIItemProtocol {
    var visible: Bool    = true
    var enable: Bool     = true
    
    let backgroundColor: UIColor = FcrUIColorGroup.cardBackgroundColor
    let cornerRadius = FcrUIFrameGroup.card2CornerRadius
    let textFont:  UIFont = FcrUIFontGroup.font14
    let textColor: UIColor = FcrUIColorGroup.textLightContrastColor
}

// Alert
struct FcrUIItemAlertTitle: FcrUIItemProtocol {
    var visible: Bool = true
    var enable: Bool  = true
    
    let color: UIColor  = FcrUIColorGroup.textLevel1Color
    let font: UIFont    = FcrUIFontGroup.font17
}

struct FcrUIItemAlertMessage: FcrUIItemProtocol {
    var visible: Bool = true
    var enable: Bool  = true
    
    let normalColor: UIColor     = FcrUIColorGroup.textLevel2Color
    let selectedColor: UIColor   = FcrUIColorGroup.textLevel1Color
    let font: UIFont             = FcrUIFontGroup.font14
}

struct FcrUIItemAlertButton: FcrUIItemProtocol {
    var visible: Bool = true
    var enable: Bool  = true
    
    let normalTitleColor: UIColor           = FcrUIColorGroup.textEnabledColor
    let normalBackgroundColor: UIColor      = FcrUIColorGroup.buttonNormalColor
    let highlightTitleColor: UIColor        = FcrUIColorGroup.textDarkContrastColor
    let highlightBackgroundColor: UIColor   = FcrUIColorGroup.systemBrandColor
    let font: UIFont                        = FcrUIFontGroup.font13
}

// MARK: - common
struct FcrUIItemShadow: FcrUIItemProtocol {
    var visible: Bool = true
    var enable: Bool  = true
    
    let color: CGColor  = FcrUIColorGroup.containerShadowColor.cgColor
    let offset: CGSize  = FcrUIColorGroup.containerShadowOffset
    let opacity: Float  = FcrUIColorGroup.shadowOpacity
    let radius: CGFloat = FcrUIColorGroup.containerShadowRadius
}

// loading
struct FcrUIItemLoadingMessage: FcrUIItemProtocol {
    var visible: Bool = true
    var enable: Bool  = true
    
    let color: UIColor = FcrUIColorGroup.textLevel1Color
    let font: UIFont   = FcrUIFontGroup.font13
}
