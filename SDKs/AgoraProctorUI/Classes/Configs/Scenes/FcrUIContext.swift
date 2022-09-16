//
//  FcrUIContext.swift
//  AgoraProctorUI
//
//  Created by LYY on 2022/9/16.
//

@objc public class FcrUIContext: NSObject {
    @objc public static func create() {
        UIConfig = FcrProctorUIConfig()
    }
    
    @objc public static func destroy() {
//        UIConfig = nil
    }
}
