//
//  UIColor+Utils.swift
//  AgoraUIBaseViews
//
//  Created by Srs on 15/10/8.
//  Copyright © 2015年 agora. All rights reserved.
//

import Foundation
import UIKit

extension UIColor {
    // MARK: - Integer/Hex Conversions
    
    /// Initialize with a 32-bit unsigned integer holding 0xAARRGGBB values.
    ///
    /// :param: argb Integer holding values in alpha, red, green, blue order
    public convenience init(rgb: UInt32) {
        self.init(rgb: rgb, alpha: 1)
    }
    
    public convenience init(r: CGFloat, g: CGFloat, b: CGFloat, alpha: CGFloat) {
        self.init(red: r / 255.0, green:g / 255.0, blue:b / 255.0, alpha: alpha)
    }
    
    public convenience init(r: CGFloat, g: CGFloat, b: CGFloat) {
        self.init(r:r, g:g, b:b, alpha: 1)
    }
    
    public convenience init(rgb: UInt32, alpha: CGFloat) {
        if rgb == 0 {
            self.init(white: 0.0, alpha: alpha)
            return
        }
        
        let red = CGFloat((rgb & 0xFF0000) >> 16)
        let green = CGFloat((rgb & 0xFF00) >> 8)
        let blue = CGFloat(rgb & 0xFF)
        
        self.init(red: red / 255.0, green: green / 255.0, blue: blue / 255.0, alpha: alpha)
    }
    
    /// Returns the color as a 32-bit unsigned integer holding 0xAARRGGBB
    /// values.
    ///
    /// :returns: ARGB integer
    public var argb: UInt32 {
        var red: CGFloat = 0.0, green: CGFloat = 0.0, blue: CGFloat = 0.0, alpha: CGFloat = 0.0
        self.getRed(&red, green: &green, blue: &blue, alpha: &alpha)
        
        let alphaByte = UInt32(alpha * 0xFF) & 0xFF
        let redByte = UInt32(red * 0xFF) & 0xFF
        let greenByte = UInt32(green * 0xFF) & 0xFF
        let blueByte = UInt32(blue * 0xFF) & 0xFF
        
        return (alphaByte << 24) | (redByte << 16) | (greenByte << 8) | blueByte
    }
    
    /// Returns the color as an "RRGGBB" hexadecimal string.
    ///
    /// :returns: RGB hex string
    public var hexString: String {
        var red: CGFloat = 0.0, green: CGFloat = 0.0, blue: CGFloat = 0.0
        self.getRed(&red, green: &green, blue: &blue, alpha: nil)
        
        let redByte = UInt8(red * 0xFF) & 0xFF
        let greenByte = UInt8(green * 0xFF) & 0xFF
        let blueByte = UInt8(blue * 0xFF) & 0xFF
        
        return String(format: "%02x%02x%02x", redByte, greenByte, blueByte)
    }
}
