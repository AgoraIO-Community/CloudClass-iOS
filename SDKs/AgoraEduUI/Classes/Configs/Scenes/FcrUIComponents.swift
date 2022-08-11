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

// MARK: - common
struct FcrUIComponentToast: FcrUIComponentProtocol {
    var visible: Bool = true
    var enable: Bool = true
    var backgroundColor: UIColor = .clear
    
    let cornerRadius: CGFloat = FcrUIFrameGroup.containerCornerRadius
    let safeBackgroundColor: UIColor = FcrUIColorGroup.systemSafeColor
    let warningBackgroundColor: UIColor = FcrUIColorGroup.systemWarningColor
    let errorBackgroundColor: UIColor = FcrUIColorGroup.systemErrorColor
    
    let noticeImage  = UIImage.agedu_named("toast_notice")
    let warningImage = UIImage.agedu_named("toast_warning")
    let errorImage = UIImage.agedu_named("toast_warning")
    
    let label = FcrUIItemToastLabel()
    let shadow = FcrUIItemShadow()
}

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

struct FcrUIComponentLoading: FcrUIComponentProtocol {
    var visible: Bool = true
    var enable: Bool = true
    var backgroundColor: UIColor = FcrUIColorGroup.systemComponentColor
    
    let gifUrl: URL? = Bundle.agoraEduUI().url(forResource: "img_loading",
                                                 withExtension: "gif")
    
    let message = FcrUIItemLoadingMessage()
}

// MARK: - state bar
struct FcrUIComponentStateBar: FcrUIComponentProtocol {
    var visible: Bool = true
    var enable: Bool = true
    var backgroundColor: UIColor = FcrUIColorGroup.systemForegroundColor
    
    /**Scene Builder Set**/
    var networkState = FcrUIItemStateBarNetworkState()
    var roomName = FcrUIItemStateBarRoomName()
    var scheduleTime = FcrUIItemStateBarScheduleTime()
    /**iOS**/
    var recordingState = FcrUIItemStateBarRecordingState()
    let sepLine = FcrUIItemSepLine()
    
    let borderWidth = FcrUIFrameGroup.borderWidth
    let borderColor = FcrUIColorGroup.systemDividerColor
}

// MARK: - TeacherVideo
struct FcrUIComponentTeacherVideo: FcrUIComponentProtocol {
    var visible: Bool = true
    var enable: Bool = true
    var backgroundColor: UIColor = FcrUIColorGroup.systemForegroundColor
    
    /**Scene Builder Set**/
    var offStage = FcrUIItemTeacherVideoOffStage()
    /**iOS**/
    let cell     = FcrUIItemVideoCell()
    let mask     = FcrUIItemVideoMask()
    let label    = FcrUIItemVideoLabel()
}

// MARK: - StudentVideo
struct FcrUIComponentStudentVideo: FcrUIComponentProtocol {
    var visible: Bool = true
    var enable: Bool = true
    var backgroundColor: UIColor = FcrUIColorGroup.systemForegroundColor
    
    /**Scene Builder Set**/
    var camera                      = FcrUIItemStudentVideoCamera()
    var microphone                  = FcrUIItemStudentVideoMicrophone()
    var boardAuthorization          = FcrUIItemStudentVideoBoardAuthorization()
    var reward                      = FcrUIItemStudentVideoReward()
    var offStage                    = FcrUIItemStudentVideoOffStage()
    
    /**iOS**/
    let moveButton                  = FcrUIItemStudentVideoMoveButton()
    let waveHands                   = FcrUIItemStudentVideoWaveHands()
    let cell                        = FcrUIItemVideoCell()
    let mask                        = FcrUIItemVideoMask()
    let label                       = FcrUIItemVideoLabel()
}

// MARK: - BreakoutRoom
struct FcrUIComponentBreakoutRoom: FcrUIComponentProtocol {
    var visible: Bool = true
    var enable: Bool = true
    var backgroundColor: UIColor = FcrUIColorGroup.systemForegroundColor
    
    var help      = FcrUIItemBreakoutRoomHelp()
}

// MARK: - RaiseHand
struct FcrUIComponentRaiseHand: FcrUIComponentProtocol {
    var visible: Bool = true
    var enable: Bool = true
    var backgroundColor: UIColor = FcrUIColorGroup.systemBrandColor
    
    var normalImage: UIImage?            = .agedu_named("toolbar_unselected_wave_hands")
    var popOverImage: UIImage?           = .agedu_named("toolbar_handsup_remind_popover")
    
    /**ui**/
    let delayView = FcrUIItemRaiseHandDelayView()
    let tipView = FcrUIItemRaiseHandTipView()
    
    let textColor: UIColor = FcrUIColorGroup.textContrastColor
    let font: UIFont = FcrUIFontGroup.font13
    let cornerRadius: CGFloat            = FcrUIFrameGroup.roundContainerCornerRadius
    let shadow: FcrUIItemShadow          = FcrUIItemShadow()
}

// MARK: - class state
struct FcrUIComponentClassState: FcrUIComponentProtocol {
    var visible: Bool = true
    var enable: Bool = true
    var backgroundColor: UIColor = .clear
    
    var startClass = FcrUIItemClassStateStartClass()
}

// MARK: - render menu
struct FcrUIComponentRenderMenu: FcrUIComponentProtocol {
    var visible: Bool = true
    var enable: Bool = true
    var backgroundColor: UIColor = FcrUIColorGroup.systemComponentColor
    
    /**ui**/
    let cornerRadius = FcrUIFrameGroup.roundContainerCornerRadius
    let shadow = FcrUIItemShadow()
}

// MARK: - setting
struct FcrUIComponentSetting: FcrUIComponentProtocol {
    var visible: Bool = true
    var enable: Bool = true
    var backgroundColor: UIColor = FcrUIColorGroup.systemComponentColor
    
    var camera       = FcrUIItemSettingCamera()
    var microphone   = FcrUIItemSettingMicrophone()
    var speaker      = FcrUIItemSettingSpeaker()
    var exit         = FcrUIItemSettingExit()
    
    /**ui**/
    let cornerRadius = FcrUIFrameGroup.containerCornerRadius
    let shadow       = FcrUIItemShadow()
}

// MARK: - tool bar
struct FcrUIComponentToolBar: FcrUIComponentProtocol {
    var visible: Bool = true
    var enable: Bool = true
    var backgroundColor: UIColor = .clear
    
    let setting   = FcrUIItemToolBarSetting()
    let message   = FcrUIItemToolBarMessage()
    let handsList = FcrUIItemToolBarHandsList()
        
    let cell = FcrUIItemToolBarCell()
    let shadow = FcrUIItemShadow()
}

// MARK: - tool collection
struct FcrUIComponentToolCollection: FcrUIComponentProtocol {
    var visible: Bool = true
    var enable: Bool  = true
    var backgroundColor: UIColor = FcrUIColorGroup.systemComponentColor
    
    let cellCornerRadius: CGFloat   = FcrUIFrameGroup.roundContainerCornerRadius
    let windowCornerRadius: CGFloat = FcrUIFrameGroup.containerCornerRadius
    let borderWidth: CGFloat        = FcrUIFrameGroup.borderWidth
    let borderColor: CGColor        = FcrUIColorGroup.systemDividerColor.cgColor
        
    let sepLine = FcrUIItemSepLine()
    let shadow = FcrUIItemShadow()
}

// MARK: - Roster
struct FcrUIComponentRoster: FcrUIComponentProtocol {
    var visible: Bool = true
    var enable: Bool = true
    var backgroundColor: UIColor = FcrUIColorGroup.iconSelectedBackgroundColor
    
    // config
    var carousel                    = FcrUIItemRosterCarousel()
    var studentName                 = FcrUIItemRosterStudentName()
    var stage                       = FcrUIItemRosterStage()
    var boardAuthorization          = FcrUIItemRosterBoardAuthorization()
    var camera                      = FcrUIItemRosterCamera()
    var microphone                  = FcrUIItemRosterMicrophone()
    var reward                      = FcrUIItemRosterReward()
    var kickOut                     = FcrUIItemRosterKickOut()
    
    // ui
    var normalImage: UIImage?   = .agedu_named("toolbar_unselected_roster")
    var selectedImage: UIImage? = .agedu_named("toolbar_selected_roster")
    
    let cellBackgroundColor: UIColor = FcrUIColorGroup.systemComponentColor
    let titleBackgroundColor: UIColor = FcrUIColorGroup.systemComponentColor
    let cornerRadius: CGFloat = FcrUIFrameGroup.containerCornerRadius
    let borderWidth: CGFloat  = FcrUIFrameGroup.borderWidth
    let borderColor: CGColor  = FcrUIColorGroup.systemDividerColor.cgColor
    
    let label: FcrUIItemRosterLabel = FcrUIItemRosterLabel()
    let shadow: FcrUIItemShadow     = FcrUIItemShadow()
    let sepLine: FcrUIItemSepLine   = FcrUIItemSepLine()
}

struct FcrUIComponentToolBox: FcrUIComponentProtocol {
    var visible: Bool = true
    var enable: Bool = true
    var backgroundColor: UIColor = .clear
    
    let cloudStorageImage: UIImage? =  .agedu_named("toolcollection_enabled_cloud")
    let recordImage: UIImage?       =  .agedu_named("ic_toolbox_record")
    let voteImage: UIImage?         =  .agedu_named("ic_toolbox_vote")
    let countDownImage: UIImage?    =  .agedu_named("ic_toolbox_clock")
    let answerSheetImage: UIImage?  =  .agedu_named("ic_toolbox_answer")
}

// MARK: - hands list
struct FcrUIComponentHandsList: FcrUIComponentProtocol {
    var visible: Bool = true
    var enable: Bool = true
    var backgroundColor: UIColor = FcrUIColorGroup.systemComponentColor
    
    let cornerRadius: CGFloat = FcrUIFrameGroup.alertCornerRadius
    
    let onImage: UIImage?     =  .agedu_named("ic_handsup_on_stage")
    let offImage: UIImage?    =  .agedu_named("ic_handsup_off_stage")
    
    let label  = FcrUIItemHandsListLabel()
    let sepLine = FcrUIItemSepLine()
    let shadow = FcrUIItemShadow()
}

// MARK: - Widgets
struct FcrUIComponentStreamWindow: FcrUIComponentProtocol {
    var visible: Bool = true
    var enable: Bool = true
    var backgroundColor: UIColor = FcrUIColorGroup.systemComponentColor
    
    let cornerRadius: CGFloat    = FcrUIFrameGroup.windowCornerRadius
    let borderWidth: CGFloat     = FcrUIFrameGroup.borderWidth
    let borderColor: CGColor     = FcrUIColorGroup.systemDividerColor.cgColor
}

struct FcrUIComponentNetlessBoard: FcrUIComponentProtocol {
    var visible: Bool = true
    var enable: Bool = true
    var backgroundColor: UIColor = FcrUIColorGroup.systemForegroundColor
    
    var borderColor: UIColor     = FcrUIColorGroup.systemDividerColor
    var borderWidth: CGFloat     = FcrUIFrameGroup.borderWidth
    
    /**Scene Builder Set**/
    var mouse       = FcrUIItemNetlessBoardMouse()
    var selector    = FcrUIItemNetlessBoardSelector()
    var pencil      = FcrUIItemNetlessBoardPencil()
    var text        = FcrUIItemNetlessBoardText()
    var eraser      = FcrUIItemNetlessBoardEraser()
    var clear       = FcrUIItemNetlessBoardClear()
    var save        = FcrUIItemNetlessBoardSave()
    /**iOS**/
    var paint       = FcrUIItemNetlessBoardPaint()
    var prev        = FcrUIItemNetlessBoardPrev()
    var next        = FcrUIItemNetlessBoardNext()
    var line        = FcrUIItemNetlessBoardLine()
    var rect        = FcrUIItemNetlessBoardRect()
    var circle      = FcrUIItemNetlessBoardCircle()
    var pentagram   = FcrUIItemNetlessBoardPentagram()
    var rhombus     = FcrUIItemNetlessBoardRhombus()
    var arrow       = FcrUIItemNetlessBoardArrow()
    var triangle    = FcrUIItemNetlessBoardTriangle()
    var pageControl = FcrUIItemNetlessBoardPageControl()
    
    // ui config
    let lineWidth   = FcrUIItemNetlessBoardLineWidth()
    let textSize    = FcrUIItemNetlessBoardTextSize()
    let colors      = FcrUIItemNetlessBoardColors()
    
}

struct FcrUIComponentWebView: FcrUIComponentProtocol {
    var visible: Bool = true
    var enable: Bool = true
    var backgroundColor: UIColor = FcrUIColorGroup.systemForegroundColor
}

struct FcrUIComponentPopupQuiz: FcrUIComponentProtocol {
    var visible: Bool = true
    var enable: Bool = true
    var backgroundColor: UIColor = FcrUIColorGroup.systemForegroundColor
}

struct FcrUIComponentCounter: FcrUIComponentProtocol {
    var visible: Bool = true
    var enable: Bool = true
    var backgroundColor: UIColor = FcrUIColorGroup.systemForegroundColor
}

struct FcrUIComponentPoll: FcrUIComponentProtocol {
    var visible: Bool = true
    var enable: Bool = true
    var backgroundColor: UIColor = FcrUIColorGroup.systemForegroundColor
}

struct FcrUIComponentCloudStorage: FcrUIComponentProtocol {
    var visible: Bool = true
    var enable: Bool = true
    var backgroundColor: UIColor = FcrUIColorGroup.systemForegroundColor
}

struct FcrUIComponentScreenShare: FcrUIComponentProtocol {
    var visible: Bool = true
    var enable: Bool = true
    var backgroundColor: UIColor = FcrUIColorGroup.systemForegroundColor
}

struct FcrUIComponentAgoraChat: FcrUIComponentProtocol {
    var visible: Bool = true
    var enable: Bool = true
    var backgroundColor: UIColor = FcrUIColorGroup.systemForegroundColor
    
    var muteAll = FcrUIItemAgoraChatMuteAll()
    var emoji = FcrUIItemAgoraChatEmoji()
    var picture = FcrUIItemAgoraChatPicture()
    
    let shadow = FcrUIItemShadow()
}
