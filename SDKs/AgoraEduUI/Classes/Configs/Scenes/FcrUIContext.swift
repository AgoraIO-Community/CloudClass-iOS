//
//  FcrUIContext.swift
//  AgoraEduUI
//
//  Created by LYY on 2022/9/1.
//

import Foundation

@objc public class FcrUIContext: NSObject {
    @objc public static func create(with type: FcrUISceneType) {
        switch type {
        case .oneToOne: UIConfig = FcrOneToOneUIConfig()
        case .small:    UIConfig = FcrSmallUIConfig()
        case .lecture:  UIConfig = FcrLectureUIConfig()
        case .vocation: UIConfig = FcrLectureUIConfig()
        }
    }
    
    @objc public static func destroy() {
//        UIConfig = nil
    }
}

