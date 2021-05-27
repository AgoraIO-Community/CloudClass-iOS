//
//  AgoraCotrollerProtocol.swift
//  AgoraEduSDK
//
//  Created by Cavan on 2021/3/16.
//  Copyright © 2021 Agora. All rights reserved.
//

import UIKit

@objc public protocol AgoraController: NSObjectProtocol {
    func viewWillAppear()
    func viewDidLoad()
    func viewDidAppear()
    func viewWillDisappear()
    func viewDidDisappear()
}

@objc public protocol AgoraRootController: NSObjectProtocol {
    var children: NSMutableArray {set get}
    
    func addChild(child: AgoraController)
    func removeChild(child: AgoraController)
    
    func childrenViewWillAppear()
    func childrenViewDidLoad()
    func childrenViewDidAppear()
    func childrenViewWillDisappear()
    func childrenViewDidDisappear()
}
