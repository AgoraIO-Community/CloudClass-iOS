//
//  FcrOneToOneUIConfig.swift
//  AgoraEduUI
//
//  Created by Cavan on 2022/7/7.
//

import UIKit

var uiConfig: FcrUIConfig = FcrOneToOneUIConfig()

protocol FcrUIConfig {
    
}

struct FcrOneToOneUIConfig: FcrUIConfig {
    // State Bar
    var stateBar = FcrUIComponentStateBar()
    var board = FcrUIComponentBoard()
}
