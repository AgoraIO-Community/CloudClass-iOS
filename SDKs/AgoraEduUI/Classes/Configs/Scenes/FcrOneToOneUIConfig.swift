//
//  FcrOneToOneUIConfig.swift
//  AgoraEduUI
//
//  Created by Cavan on 2022/7/7.
//

struct FcrOneToOneUIConfig: FcrUIConfig {
    let stateBar        = FcrUIComponentStateBar()
    let networkStats    = FcrUIComponentNetworkStats()
    let teacherVideo    = FcrUIComponentTeacherVideo()
    let studentVideo    = FcrUIComponentStudentVideo()
    let breakoutRoom    = FcrUIComponentBreakoutRoom()
    let raiseHand       = FcrUIComponentRaiseHand()
    let roster          = FcrUIComponentRoster()
    
    // widgets
    let streamWindow    = FcrUIComponentStreamWindow()
    let webView         = FcrUIComponentWebView()
    let popupQuiz       = FcrUIComponentPopupQuiz()
    let counter         = FcrUIComponentCounter()
    var poll            = FcrUIComponentPoll()
    let cloudStorage    = FcrUIComponentCloudStorage()
    let screenShare     = FcrUIComponentScreenShare()
    let netlessBoard    = FcrUIComponentNetlessBoard()
    let agoraChat       = FcrUIComponentAgoraChat()
    
    /**iOS**/
    let classState      = FcrUIComponentClassState()
    let setting         = FcrUIComponentSetting()
    let toolBar         = FcrUIComponentToolBar()
    let toolCollection  = FcrUIComponentToolCollection()
    let renderMenu      = FcrUIComponentRenderMenu()
    let record          = FcrUIComponentRecord()
    let handsList       = FcrUIComponentHandsList()
    
    // base
    let toast   = FcrUIComponentToast()
    let alert   = FcrUIComponentAlert()
    let loading = FcrUIComponentLoading()
}
