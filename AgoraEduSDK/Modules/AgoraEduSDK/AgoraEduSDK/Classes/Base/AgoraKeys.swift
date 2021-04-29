//
//  AgoraKeyGroup.swift
//  AgoraEduSDK
//
//  Created by Cavan on 2021/4/13.
//

import UIKit

@objcMembers public class AgoraKeyGroup: NSObject {
    public var agoraAppId: String = ""
    public var agoraBoardId: String = ""
    public var userToken: String = ""
    public var rtcToken: String = ""
    public var rtmToken: String = ""
    public var localUserUuid: String = ""
    
    deinit {
        print("")
    }
}
