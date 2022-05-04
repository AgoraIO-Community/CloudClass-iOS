//
//  AgoraUIController.swift
//  AgoraEduUI
//
//  Created by Cavan on 2022/4/26.
//

import Foundation

protocol AgoraUIActivity {
    func viewWillActive()
    func viewWillInactive()
}

protocol AgoraUIContentContainer {
    func initViews()
    func initViewFrame()
    func updateViewProperties()
}
