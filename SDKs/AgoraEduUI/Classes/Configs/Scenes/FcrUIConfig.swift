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

@objc public class FcrUIConfigOC: NSObject {
    @objc public static func setUIConfig(value: Int) {
        set_ui_config(value: value)
    }

    @objc public static func relaseUIConfig() {
        relase_ui_config()
    }
}

public func set_ui_config(value: Int) {
    switch value {
    // One to one
    case 0:
        UIConfig = FcrOneToOneUIConfig()
    // Small
    case 1:
        UIConfig = FcrSmallUIConfig()
    // Lecture
    case 3:
        UIConfig = FcrLectureUIConfig()
    default:
        fatalError("invalid value: \(value)")
    }
}

public func relase_ui_config() {
    UIConfig = nil
}
