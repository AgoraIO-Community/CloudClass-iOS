//
//  AgoraExtAppInternalObjects.swift
//  AgoraExtApp
//
//  Created by Cavan on 2021/4/25.
//

import UIKit
import AgoraUIBaseViews

@objc public class AgroaExtAppWrapper: NSObject {
    @objc public class func getView() -> AgoraBaseUIView {
        return AgoraBaseUIContainer()
    }
}

@objcMembers public class AgoraExtAppPositionItem: NSObject {
    public var x: CGFloat
    public var y: CGFloat

    @objc public init(x: CGFloat,
                      y: CGFloat) {
        self.x = x
        self.y = y
        super.init()
    }
}

@objcMembers public class AgoraExtAppItem: NSObject {
    // 设置 ExtAppView 的位置
    public var layout: UIEdgeInsets
    // AgoraBaseExtApp 的类
    public var extAppClass: AnyClass
    // ExtApp 所使用的语言
    public var language: String
    // 记录extAppClass实例
    public var instance: AgoraBaseExtApp?
    
    @objc public init(layout: UIEdgeInsets,
         extAppClass: AnyClass,
         language: String) {
        self.layout = layout
        self.extAppClass = extAppClass
        self.language = language
        super.init()
    }
}

@objcMembers public class AgoraExtAppDirtyTag: NSObject {
    public var localUserInfo: AgoraExtAppUserInfo?
    public var properties: [String: Any]?
    public var roomInfo: AgoraExtAppRoomInfo?
    
    // 用于判断是否3个数据都获取到了
    public var isPass: Bool {
        if let _ = localUserInfo,
           let _ = properties,
           let _ = roomInfo {
            return true
        } else {
            return false
        }
    }
}

