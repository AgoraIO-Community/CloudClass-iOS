//
//  PtUIConfig.swift
//  AgoraEduUI
//
//  Created by Cavan on 2022/7/11.
//

import UIKit

protocol PtUIConfig {
    var deviceTest: PtUIComponentDeviceTest { get }
    var render: PtUIComponentRender { get }
    var exam: PtUIComponentExam { get }
    
    var alert: PtUIComponentAlert { get }
    
    var loading: PtUIComponentLoading { get }
}

var UIConfig: PtUIConfig = PtSubUIConfig()
