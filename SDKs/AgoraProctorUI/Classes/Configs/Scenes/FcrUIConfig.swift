//
//  FcrUIConfig.swift
//  AgoraEduUI
//
//  Created by Cavan on 2022/7/11.
//

import UIKit

protocol FcrUIConfig {
    var deviceTest: FcrUIComponentDevice { get }
    var render: FcrUIComponentRender { get }
    var exam: FcrUIComponentExam { get }
    
    var alert: FcrUIComponentAlert { get }
}

var UIConfig: FcrUIConfig = FcrProctorUIConfig()
