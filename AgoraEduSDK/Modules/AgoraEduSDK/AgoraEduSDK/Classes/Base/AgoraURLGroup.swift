//
//  AgoraURLGroup.swift
//  AgoraEduSDK
//
//  Created by Cavan on 2021/4/13.
//

import UIKit

@objc public protocol AgoraURLGroupDataSource: NSObjectProtocol {
    func needAgoraAppId() -> String
    func needAgoraRtmToken() -> String
    func needLocalUserUuid() -> String
}

@objcMembers public class AgoraURLGroup: NSObject {
    public var host = "https://api.agora.io"
    private let apps = "edu/apps"
    private let version = "v2"
    private let rooms = "rooms"
    private let extApps = "extApps"
    private let properties = "properties"
    
    public weak var dataSource: AgoraURLGroupDataSource?
    
    private var agoraAppId: String {
        if let id = dataSource?.needAgoraAppId(),
           id.count > 0 {
            return id
        } else {
            fatalError()
        }
    }
    
    private var rtmToken: String {
        if let token = dataSource?.needAgoraRtmToken(),
           token.count > 0 {
            return token
        } else {
            fatalError()
        }
    }
    
    private var localUserUuid: String {
        if let id = dataSource?.needLocalUserUuid(),
           id.count > 0 {
            return id
        } else {
            fatalError()
        }
    }
    
    func headers() -> [String: Any] {
        let dic = ["Content-Type": "application/json",
                   "x-agora-token": rtmToken,
                   "x-agora-uid": localUserUuid]
        return dic
    }
}

extension AgoraURLGroup {
    func extApp(roomUuid: String,
                appIdentifier: String) -> String {
        let array = [host, apps, agoraAppId,
                     version, rooms, roomUuid,
                     extApps, appIdentifier, properties]
        let url = array.joined(separator: "/")
        return url
    }
}
