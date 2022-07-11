//
//  FcrUIItems.swift
//  AgoraEduUI
//
//  Created by Cavan on 2022/7/7.
//

import UIKit

protocol FcrUIItemProtocol {
    var visible: Bool {get set}
    var enable: Bool {get set}
}

struct FcrUIItemNetwork: FcrUIItemProtocol {
    var visible: Bool = true
    var enable: Bool = true
    var image = UIImage(named: "")
}

struct FcrUIItemRoomName: FcrUIItemProtocol {
    var visible: Bool = true
    var enable: Bool = true
    var background: UIColor = .clear
}

struct FcrUIItemClassTime: FcrUIItemProtocol {
    var visible: Bool = true
    var enable: Bool = true
}

struct FcrUIItemPageControl: FcrUIItemProtocol {
    var visible: Bool = true
    var enable: Bool = true
    var background: UIColor = .white
    
    var prevButtonVisible: Bool = true
    
    
    
    
    
    var nextButtonVisible: Bool = true
}
