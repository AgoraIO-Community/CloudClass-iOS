//
//  FcrUIConfig.swift
//  AgoraEduUI
//
//  Created by Cavan on 2022/7/11.
//

import UIKit

protocol FcrUIConfig {
    /**Scene Builder Set**/
    // main
    var stateBar: FcrUIComponentStateBar { get }
    var teacherVideo: FcrUIComponentTeacherVideo { get }
    var studentVideo: FcrUIComponentStudentVideo { get }
    var breakoutRoom: FcrUIComponentBreakoutRoom { get }
    var raiseHand: FcrUIComponentRaiseHand { get }
    var roster: FcrUIComponentRoster { get }
    
    // widgets
    var streamWindow: FcrUIComponentStreamWindow { get }
    var webView: FcrUIComponentWebView { get }
    var popupQuiz: FcrUIComponentPopupQuiz { get }
    var counter: FcrUIComponentCounter { get }
    var poll: FcrUIComponentPoll { get }
    var cloudStorage: FcrUIComponentCloudStorage { get }
    var screenShare: FcrUIComponentScreenShare { get }
    var netlessBoard: FcrUIComponentNetlessBoard { get }
    var agoraChat: FcrUIComponentAgoraChat { get }
    
    /**iOS**/
    var classState: FcrUIComponentClassState { get }
    var setting: FcrUIComponentSetting { get }
    var toolBar: FcrUIComponentToolBar { get }
    var toolCollection: FcrUIComponentToolCollection { get }
    var renderMenu: FcrUIComponentRenderMenu { get }
    var toolBox: FcrUIComponentToolBox { get }
    var handsList: FcrUIComponentHandsList { get }
    
    // base
    var toast: FcrUIComponentToast { get }
    var alert: FcrUIComponentAlert { get }
    var loading: FcrUIComponentLoading { get }
}

var UIConfig: FcrUIConfig!
