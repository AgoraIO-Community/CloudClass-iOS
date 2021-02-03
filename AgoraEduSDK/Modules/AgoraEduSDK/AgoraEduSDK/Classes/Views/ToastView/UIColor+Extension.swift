//
//  UIColor+Extension.swift
//  AgoraSceneUI
//
//  Created by ZYP on 2021/1/13.
//

import Foundation
extension UIColor {
    convenience public init(hex: UInt) {
        let r = CGFloat((hex & 0x00FF_0000) >> 16) / 255.0
        let g = CGFloat((hex & 0x0000_FF00) >> 8) / 255.0
        let b = CGFloat((hex & 0x0000_00FF) >> 0) / 255.0
        self.init(red: r, green: g, blue: b, alpha: 1)
    }
    
    convenience public init(hex: UInt, alpha:CGFloat) {
        let r = CGFloat((hex & 0x00FF_0000) >> 16) / 255.0
        let g = CGFloat((hex & 0x0000_FF00) >> 8) / 255.0
        let b = CGFloat((hex & 0x0000_00FF) >> 0) / 255.0
        self.init(red: r, green: g, blue: b, alpha: alpha)
    }
    
    var rgbComponents: [CGFloat] {
        var r: CGFloat = 0
        var g: CGFloat = 0
        var b: CGFloat = 0
        var a: CGFloat = 0
        self.getRed(&r, green: &g, blue: &b, alpha: &a)
        
        return [r, g, b, a]
    }
    
}


