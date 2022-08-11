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

// MARK: - common
struct FcrUIItemSepLine: FcrUIItemProtocol {
    var visible: Bool = true
    var enable: Bool  = true
    
    let backgroundColor: UIColor = FcrUIColorGroup.systemDividerColor
}

struct FcrUIItemShadow: FcrUIItemProtocol {
    var visible: Bool = true
    var enable: Bool  = true
    
    let color: CGColor  = FcrUIColorGroup.containerShadowColor.cgColor
    let offset: CGSize  = FcrUIColorGroup.containerShadowOffset
    let opacity: Float  = FcrUIColorGroup.shadowOpacity
    let radius: CGFloat = FcrUIColorGroup.containerShadowRadius
}

// toast
struct FcrUIItemToastLabel: FcrUIItemProtocol {
    var visible: Bool = true
    var enable: Bool  = true
    
    let color: UIColor  = FcrUIColorGroup.textContrastColor
    let font: UIFont    = FcrUIFontGroup.font14
}

// alert
struct FcrUIItemAlertTitle: FcrUIItemProtocol {
    var visible: Bool = true
    var enable: Bool  = true
    
    let color: UIColor  = FcrUIColorGroup.textLevel1Color
    let font: UIFont    = FcrUIFontGroup.font17
}

// loading
struct FcrUIItemLoadingMessage: FcrUIItemProtocol {
    var visible: Bool = true
    var enable: Bool  = true
    
    let color: UIColor = FcrUIColorGroup.textLevel1Color
    let font: UIFont   = FcrUIFontGroup.font13
}

struct FcrUIItemAlertMessage: FcrUIItemProtocol {
    var visible: Bool = true
    var enable: Bool  = true
    
    let normalColor: UIColor  = FcrUIColorGroup.textLevel2Color
    let selectedColor: UIColor  = FcrUIColorGroup.textLevel1Color
    let font: UIFont    = FcrUIFontGroup.font13
    
    let checkedImage: UIImage?   = .agedu_named("ic_alert_checked")
    let uncheckedImage: UIImage? = .agedu_named("ic_alert_unchecked")
}

struct FcrUIItemAlertButton: FcrUIItemProtocol {
    var visible: Bool = true
    var enable: Bool  = true
    
    let normalTitleColor: UIColor = FcrUIColorGroup.textEnabledColor
    let font: UIFont              = FcrUIFontGroup.font17
}


// MARK: - state bar
struct FcrUIItemStateBarNetworkState: FcrUIItemProtocol {
    var visible: Bool = true
    var enable: Bool  = true
    
    let goodImage: UIImage?         = .agedu_named("ic_network_good")
    let unknownImage: UIImage?      = .agedu_named("ic_network_unknown")
    let badImage: UIImage?          = .agedu_named("ic_network_bad")
    let disconnectedImage: UIImage? = .agedu_named("ic_network_down")
}

struct FcrUIItemStateBarRoomName: FcrUIItemProtocol {
    var visible: Bool = true
    var enable: Bool = true
    
    let textColor: UIColor = FcrUIColorGroup.textLevel1Color
    let textFont: UIFont = FcrUIFontGroup.font9
}

struct FcrUIItemStateBarScheduleTime: FcrUIItemProtocol {
    var visible: Bool = true
    var enable: Bool = true
    
    let textColor: UIColor = FcrUIColorGroup.textLevel1Color
    let textFont: UIFont = FcrUIFontGroup.font9
}

struct FcrUIItemStateBarRecordingState: FcrUIItemProtocol {
    var visible: Bool = true
    var enable: Bool = true
    
    let backgroundColor: UIColor = FcrUIColorGroup.systemErrorColor
    let cornerRadius: CGFloat = FcrUIFrameGroup.containerCornerRadius
    let textColor: UIColor = FcrUIColorGroup.textLevel1Color
    let textFont: UIFont = FcrUIFontGroup.font9
}

// MARK: - board
struct FcrUIItemNetlessBoardPageControl: FcrUIItemProtocol {
    var visible: Bool = true
    var enable: Bool  = true
    
    let backgroundColor: UIColor = FcrUIColorGroup.systemComponentColor
    let cornerRadius: CGFloat    = FcrUIFrameGroup.roundContainerCornerRadius
    
    let addPageImage: UIImage?  = .agedu_named("ic_board_page_add")
    let prevPageImage: UIImage? = .agedu_named("ic_board_page_pre")
    let nextPageImage: UIImage? = .agedu_named("ic_board_page_next")
    let disabledPrevPageImage: UIImage? = .agedu_named("ic_board_page_disabled_pre")
    let disabledNextPageImage: UIImage? = .agedu_named("ic_board_page_disabled_next")
    
    let sepLine        = FcrUIItemSepLine()
    let pageLabel      = FcrUIItemNetlessBoardPageLabel()
    let shadow         = FcrUIItemShadow()
}

struct FcrUIItemNetlessBoardPageLabel: FcrUIItemProtocol {
    var visible: Bool   = true
    var enable: Bool    = true
    
    let color: UIColor  = FcrUIColorGroup.textLevel2Color
    let font: UIFont    = FcrUIFontGroup.font14
}

struct FcrUIItemNetlessBoardMouse: FcrUIItemProtocol {
    var visible: Bool = true
    var enable: Bool  = true
    
    let unselectedImage: UIImage? = .agedu_named("toolcollection_unselecetd_clicker")
    let selectedImage: UIImage?   = .agedu_named("toolcollection_selected_clicker")
}

struct FcrUIItemNetlessBoardSelector: FcrUIItemProtocol {
    var visible: Bool = true
    var enable: Bool  = true
    
    let unselectedImage: UIImage? = .agedu_named("toolcollection_unselecetd_area")
    let selectedImage: UIImage?   = .agedu_named("toolcollection_selected_area")
}

struct FcrUIItemNetlessBoardPaint: FcrUIItemProtocol {
    var visible: Bool = true
    var enable: Bool  = true
    
    let unselectedImage: UIImage? = .agedu_named("toolcollection_unselecetd_paint")
    let selectedImage: UIImage?   = .agedu_named("toolcollection_selected_paint")
}

struct FcrUIItemNetlessBoardText: FcrUIItemProtocol {
    var visible: Bool = true
    var enable: Bool  = true
    
    let image: UIImage? = .agedu_named("toolcollection_text")
}

struct FcrUIItemNetlessBoardEraser: FcrUIItemProtocol {
    var visible: Bool = true
    var enable: Bool  = true
    
    let unselectedImage: UIImage? = .agedu_named("toolcollection_unselecetd_rubber")
    let selectedImage: UIImage?   = .agedu_named("toolcollection_selected_rubber")
}

struct FcrUIItemNetlessBoardClear: FcrUIItemProtocol {
    var visible: Bool = true
    var enable: Bool  = true
    
    let enabledImage: UIImage? = .agedu_named("toolcollection_enabled_clear")
}

struct FcrUIItemNetlessBoardSave: FcrUIItemProtocol {
    var visible: Bool = true
    var enable: Bool  = true
    
    let image: UIImage?    =  .agedu_named("toolcollection_enabled_save")
}

struct FcrUIItemNetlessBoardPrev: FcrUIItemProtocol {
    var visible: Bool = true
    var enable: Bool  = true
    
    let enabledImage: UIImage?  = .agedu_named("toolcollection_enabled_pre")
    let disabledImage: UIImage? = .agedu_named("toolcollection_disabled_pre")
}

struct FcrUIItemNetlessBoardNext: FcrUIItemProtocol {
    var visible: Bool = true
    var enable: Bool  = true
    
    let enabledImage: UIImage?  = .agedu_named("toolcollection_enabled_next")
    let disabledImage: UIImage? = .agedu_named("toolcollection_disabled_next")
}

// sub for paint
struct FcrUIItemNetlessBoardPencil: FcrUIItemProtocol {
    var visible: Bool = true
    var enable: Bool  = true
    
    let image: UIImage? = .agedu_named("toolcollection_pencil")
}

struct FcrUIItemNetlessBoardLine: FcrUIItemProtocol {
    var visible: Bool = true
    var enable: Bool  = true
    
    let image: UIImage? = .agedu_named("toolcollection_line")
}

struct FcrUIItemNetlessBoardRect: FcrUIItemProtocol {
    var visible: Bool = true
    var enable: Bool  = true
    
    let image: UIImage? = .agedu_named("toolcollection_rect")
}

struct FcrUIItemNetlessBoardCircle: FcrUIItemProtocol {
    var visible: Bool = true
    var enable: Bool  = true
    
    let image: UIImage? = .agedu_named("toolcollection_circle")
}

struct FcrUIItemNetlessBoardPentagram: FcrUIItemProtocol {
    var visible: Bool = true
    var enable: Bool  = true
    
    let image: UIImage? = .agedu_named("toolcollection_pentagram")
}

struct FcrUIItemNetlessBoardRhombus: FcrUIItemProtocol {
    var visible: Bool = true
    var enable: Bool  = true
    
    let image: UIImage? = .agedu_named("toolcollection_rhombus")
}

struct FcrUIItemNetlessBoardArrow: FcrUIItemProtocol {
    var visible: Bool = true
    var enable: Bool  = true
    
    let image: UIImage?   = .agedu_named("toolcollection_arrow")
}

struct FcrUIItemNetlessBoardTriangle: FcrUIItemProtocol {
    var visible: Bool = true
    var enable: Bool  = true
    
    let image: UIImage? = .agedu_named("toolcollection_triangle")
}

struct FcrUIItemNetlessBoardLineWidth: FcrUIItemProtocol {
    var visible: Bool = true
    var enable: Bool  = true
    
    let image: UIImage? = .agedu_named("toolcollection_width")
}

struct FcrUIItemNetlessBoardTextSize: FcrUIItemProtocol {
    var visible: Bool = true
    var enable: Bool  = true
}

struct FcrUIItemNetlessBoardColors: FcrUIItemProtocol {
    var visible: Bool = true
    var enable: Bool  = true
    
    let backgroundColor: UIColor = FcrUIColorGroup.systemComponentColor
    let borderWidth: CGFloat     = FcrUIFrameGroup.borderWidth
    let cornerRadius: CGFloat    = FcrUIFrameGroup.containerCornerRadius
}

// MARK: - class state
struct FcrUIItemClassStateStartClass: FcrUIItemProtocol {
    var visible: Bool   = true
    var enable: Bool    = true
    
    let normalTitleColor: UIColor      = FcrUIColorGroup.textContrastColor
    let font: UIFont                   = FcrUIFontGroup.font13
    let normalBackgroundColor: UIColor = FcrUIColorGroup.systemBrandColor
    let cornerRadius: CGFloat          = FcrUIFrameGroup.roundContainerCornerRadius
    
    let shadow: FcrUIItemShadow        = FcrUIItemShadow()
}

// MARK: - setting
struct FcrUIItemSettingCamera: FcrUIItemProtocol {
    var visible: Bool   = true
    var enable: Bool    = true
    
    let tintColor: UIColor      = FcrUIColorGroup.systemBrandColor
    let title                   = FcrUIItemSettingTitle()
    let direction               = FcrUIItemSettingCameraDirection()
}

struct FcrUIItemSettingMicrophone: FcrUIItemProtocol {
    var visible: Bool   = true
    var enable: Bool    = true
    
    let tintColor: UIColor      = FcrUIColorGroup.systemBrandColor
    let title                   = FcrUIItemSettingTitle()
}

struct FcrUIItemSettingSpeaker: FcrUIItemProtocol {
    var visible: Bool   = true
    var enable: Bool    = true
    
    let tintColor: UIColor      = FcrUIColorGroup.systemBrandColor
    let title                   = FcrUIItemSettingTitle()
}

struct FcrUIItemSettingExit: FcrUIItemProtocol {
    var visible: Bool   = true
    var enable: Bool    = true
    
    let backgroundColor: UIColor  = FcrUIColorGroup.systemBrandColor
    let cornerRadius: CGFloat     = FcrUIFrameGroup.containerCornerRadius
    let titleColor: UIColor       = FcrUIColorGroup.textContrastColor
    let titleFont: UIFont         = FcrUIFontGroup.font12
}

struct FcrUIItemSettingTitle: FcrUIItemProtocol {
    var visible: Bool   = true
    var enable: Bool    = true
    
    let color: UIColor      = FcrUIColorGroup.textLevel1Color
    let font: UIFont        = FcrUIFontGroup.font12
}

struct FcrUIItemSettingCameraDirection: FcrUIItemProtocol {
    var visible: Bool   = true
    var enable: Bool    = true
    
    let titleColor: UIColor                = FcrUIColorGroup.textLevel3Color
    let normalBackgroundColor: UIColor     = FcrUIColorGroup.iconNormalBackgroundColor.withAlphaComponent(0.1)
    let selectedBackgroundColor: UIColor   = FcrUIColorGroup.systemBrandColor
    let normalLabelColor: UIColor          = FcrUIColorGroup.textLevel2Color
    let selectedLabelColor: UIColor        = FcrUIColorGroup.textContrastColor
    let font: UIFont                       = FcrUIFontGroup.font12
    let cornerRadius: CGFloat              = FcrUIFrameGroup.containerCornerRadius
}

// MARK: - Tool bar
struct FcrUIItemToolBarCell: FcrUIItemProtocol {
    var visible: Bool   = true
    var enable: Bool    = true
    
    let cornerRadius: CGFloat   = FcrUIFrameGroup.roundContainerCornerRadius
    let normalImage: UIImage?   = .agedu_named("toolbar_unselected_bg")
    let selectedColor: UIColor  = FcrUIColorGroup.systemBrandColor
    
    let shadow: FcrUIItemShadow = FcrUIItemShadow()
}
// types
struct FcrUIItemToolBarSetting: FcrUIItemProtocol {
    var visible: Bool   = true
    var enable: Bool    = true
    
    let normalImage: UIImage? = .agedu_named("toolbar_unselected_setting")
    let selectedImage: UIImage? = .agedu_named("toolbar_selected_setting")
}

struct FcrUIItemToolBarMessage: FcrUIItemProtocol {
    var visible: Bool   = true
    var enable: Bool    = true
    
    let normalImage: UIImage?   = .agedu_named("toolbar_unselected_message")
    let selectedImage: UIImage? = .agedu_named("toolbar_selected_message")
    
    let dotColor: UIColor = FcrUIColorGroup.systemErrorColor
}

struct FcrUIItemToolBarHandsList: FcrUIItemProtocol {
    var visible: Bool   = true
    var enable: Bool    = true
    
    let normalImage: UIImage?   = .agedu_named("toolbar_unselected_hands_list")
    let selectedImage: UIImage? = .agedu_named("toolbar_selected_hands_list")
    
    let label: FcrUIItemToolBarHandsListLabel = FcrUIItemToolBarHandsListLabel()
}

struct FcrUIItemToolBarHandsListLabel: FcrUIItemProtocol {
    var visible: Bool = true
    var enable: Bool  = true
    
    let backgroundColor: UIColor = FcrUIColorGroup.systemErrorColor
    let color: UIColor           = FcrUIColorGroup.textContrastColor
    let font: UIFont             = FcrUIFontGroup.font10
}

// MARK: - BreakoutRoom
struct FcrUIItemBreakoutRoomHelp: FcrUIItemProtocol {
    var visible: Bool   = true
    var enable: Bool    = true
    
    let enabledImage: UIImage?  = .agedu_named("toolbar_enabled_help")
    let disabledImage: UIImage? = .agedu_named("toolbar_disabled_help")
}

// MARK: - video
struct FcrUIItemRenderButton: FcrUIItemProtocol {
    var visible: Bool = true
    var enable: Bool  = true
    
    let color: UIColor = FcrUIColorGroup.systemErrorColor
}

struct FcrUIItemTeacherVideoOffStage: FcrUIItemProtocol {
    var visible: Bool = true
    var enable: Bool  = true
    
    let image: UIImage? = .agedu_named("member_stage_off")
}

struct FcrUIItemStudentVideoOffStage: FcrUIItemProtocol {
    var visible: Bool = true
    var enable: Bool  = true
    
    let image: UIImage? = .agedu_named("member_stage_on")
}

struct FcrUIItemStudentVideoCamera: FcrUIItemProtocol {
    var visible: Bool = true
    var enable: Bool  = true
    
    let onImage: UIImage?        = .agedu_named("member_camera_on")
    let offImage: UIImage?       = .agedu_named("member_camera_off")
    let forbiddenImage: UIImage? = .agedu_named("member_camera_forbidden")
}

struct FcrUIItemStudentVideoMicrophone: FcrUIItemProtocol {
    var visible: Bool = true
    var enable: Bool = true
    
    let onImage: UIImage?        = .agedu_named("member_mic_on")
    let offImage: UIImage?       = .agedu_named("member_mic_off")
    let forbiddenImage: UIImage? = .agedu_named("member_mic_forbidden")
}

struct FcrUIItemStudentVideoBoardAuthorization: FcrUIItemProtocol {
    var visible: Bool = true
    var enable: Bool  = true
    
    let onImage: UIImage?     = .agedu_named("member_boardauth_on")
    let offImage: UIImage?    = .agedu_named("member_boardauth_off")
}

struct FcrUIItemStudentVideoReward: FcrUIItemProtocol {
    var visible: Bool = true
    var enable: Bool  = true
    
    let image: UIImage?       = .agedu_named("member_reward")
}

struct FcrUIItemStudentVideoMoveButton: FcrUIItemProtocol {
    var visible: Bool = true
    var enable: Bool  = true
    
    let cornerRadius: CGFloat    = FcrUIFrameGroup.windowCornerRadius
    let backgroundColor: UIColor = .black.withAlphaComponent(0.3)
    let prevImage: UIImage?      = .agedu_named("window_arrow_prev")
    let nextImage: UIImage?      = .agedu_named("window_arrow_next")
}

struct FcrUIItemStudentVideoWaveHands: FcrUIItemProtocol {
    var visible: Bool = true
    var enable: Bool  = true
    
    let gifUrl: URL?    = Bundle.agoraEduUI().url(forResource: "img_hands_wave",
                                                  withExtension: "gif")
}

struct FcrUIItemVideoCell: FcrUIItemProtocol {
    var visible: Bool = true
    var enable: Bool  = true
    
    let backgroundColor: UIColor = FcrUIColorGroup.systemBackgroundColor
    let cornerRadius: CGFloat    = FcrUIFrameGroup.windowCornerRadius
    let borderWidth: CGFloat     = FcrUIFrameGroup.borderWidth
    let borderColor: CGColor     = FcrUIColorGroup.systemDividerColor.cgColor
}

struct FcrUIItemVideoMask: FcrUIItemProtocol {
    var visible: Bool = true
    var enable: Bool  = true
    
    let backgroundColor: UIColor        = FcrUIColorGroup.systemBackgroundColor
    let noUserImage: UIImage?           = .agedu_named("window_no_user")
    let cameraOffImage: UIImage?        = .agedu_named("window_device_off")
    let cameraForbiddenImage: UIImage?  = .agedu_named("window_device_forbidden")
    
    let micOnImage: UIImage?            = .agedu_named("window_mic_on")
    let micForbiddenImage: UIImage?     = .agedu_named("window_mic_forbidden")
    let micOffImage: UIImage?           = .agedu_named("window_mic_off")
    let micVolumeImage: UIImage?        = .agedu_named("window_mic_volume")
    
    let boardAuthWindowImage: UIImage?  = .agedu_named("window_board_auth")
    let rewardImage: UIImage?           = .agedu_named("window_reward")
}

struct FcrUIItemVideoLabel: FcrUIItemProtocol {
    var visible: Bool = true
    var enable: Bool  = true
    
    let color: UIColor        = FcrUIColorGroup.textContrastColor
    let font: UIFont          = FcrUIFontGroup.font12
    let shadowColor: CGColor  = FcrUIColorGroup.textShadowColor.cgColor
    let shadowOffset: CGSize  = FcrUIColorGroup.labelShadowOffset
    let shadowOpacity: Float  = FcrUIColorGroup.shadowOpacity
    let shadowRadius: CGFloat = FcrUIColorGroup.labelShadowRadius
}

// MARK: - Roster
struct FcrUIItemRosterLabel: FcrUIItemProtocol {
    var visible: Bool = true
    var enable: Bool  = true
    
    let mainTitleColor: UIColor        = FcrUIColorGroup.textLevel1Color
    let subTitleColor: UIColor        = FcrUIColorGroup.textLevel2Color
    let font: UIFont          = FcrUIFontGroup.font12
}

struct FcrUIItemRosterCarousel: FcrUIItemProtocol {
    var visible: Bool = true
    var enable: Bool  = true
    
    let tintColor: UIColor    = FcrUIColorGroup.systemBrandColor
}

struct FcrUIItemRosterStudentName: FcrUIItemProtocol {
    var visible: Bool = true
    var enable: Bool  = true
    
    let color: UIColor    = FcrUIColorGroup.textLevel2Color
}

struct FcrUIItemRosterStage: FcrUIItemProtocol {
    var visible: Bool = true
    var enable: Bool  = true
    
    let onImage: UIImage?   = .agedu_named("member_stage_on")
    let offImage: UIImage?  = .agedu_named("member_stage_off")
}

struct FcrUIItemRosterBoardAuthorization: FcrUIItemProtocol {
    var visible: Bool = true
    var enable: Bool  = true
    
    let onImage: UIImage?   = .agedu_named("member_boardauth_on")
    let offImage: UIImage?  = .agedu_named("member_boardauth_off")
}

struct FcrUIItemRosterCamera: FcrUIItemProtocol {
    var visible: Bool = true
    var enable: Bool  = true
    
    let onImage: UIImage?        = .agedu_named("member_camera_on")
    let offImage: UIImage?       = .agedu_named("member_camera_off")
    let forbiddenImage: UIImage? = .agedu_named("member_camera_forbidden")
}

struct FcrUIItemRosterMicrophone: FcrUIItemProtocol {
    var visible: Bool = true
    var enable: Bool  = true
    
    let onImage: UIImage?        = .agedu_named("member_mic_on")
    let offImage: UIImage?       = .agedu_named("member_mic_off")
    let forbiddenImage: UIImage? = .agedu_named("member_mic_forbidden")
}

struct FcrUIItemRosterReward: FcrUIItemProtocol {
    var visible: Bool = true
    var enable: Bool  = true
    
    let image: UIImage?    = .agedu_named("member_reward")
    let font: UIFont = FcrUIFontGroup.font13
    let textColor: UIColor = FcrUIColorGroup.textDisabledColor
}

struct FcrUIItemRosterKickOut: FcrUIItemProtocol {
    var visible: Bool = true
    var enable: Bool  = true
    
    let image: UIImage?    = .agedu_named("ic_nameroll_kick")
}

// MARK: - hands list
struct FcrUIItemHandsListLabel: FcrUIItemProtocol {
    var visible: Bool = true
    var enable: Bool  = true
    
    let color: UIColor        = FcrUIColorGroup.textLevel1Color
    let font: UIFont          = FcrUIFontGroup.font12
}

// MARK: - raise hand
struct FcrUIItemRaiseHandDelayView: FcrUIItemProtocol {
    var visible: Bool = true
    var enable: Bool  = true
    
    let textColor = FcrUIColorGroup.textContrastColor
    let font = FcrUIFontGroup.font13
}

struct FcrUIItemRaiseHandTipView: FcrUIItemProtocol {
    var visible: Bool = true
    var enable: Bool  = true
    
    let textColor = FcrUIColorGroup.textLevel1Color
    let font = FcrUIFontGroup.font12
}

// MARK: - AgoraChat
struct FcrUIItemAgoraChatMuteAll: FcrUIItemProtocol {
    var visible: Bool = true
    var enable: Bool  = true
}

struct FcrUIItemAgoraChatEmoji: FcrUIItemProtocol {
    var visible: Bool = true
    var enable: Bool  = true
    
    let textColor = FcrUIColorGroup.textContrastColor
    let font = FcrUIFontGroup.font13
}

struct FcrUIItemAgoraChatPicture: FcrUIItemProtocol {
    var visible: Bool = true
    var enable: Bool  = true
    
    let textColor = FcrUIColorGroup.textContrastColor
    let font = FcrUIFontGroup.font13
}
