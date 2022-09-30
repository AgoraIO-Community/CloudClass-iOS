//
//  PtUIContext.swift
//  AgoraProctorUI
//
//  Created by LYY on 2022/9/16.
//

@objc public class PtUIContext: NSObject {
    @objc public static func create() {
        UIConfig = PtSubUIConfig()
    }
    
    @objc public static func destroy() {
//        UIConfig = nil
    }
}
