//
//  AgoraApaasLogTube.swift
//  AgoraEduSDK
//
//  Created by Cavan on 2021/3/20.
//

import Foundation

@objc public protocol AgoraApaasLogTube {
    func log(content: String,
             extra: String?,
             type: AgoraApaasLogType,
             from: AnyClass)
}

@objc public enum AgoraApaasLogType: Int {
    case info, warning, error
}

@objcMembers public class AgoraApaasLogCollection: NSObject {
    
}

extension AgoraApaasLogCollection: AgoraApaasLogTube {
    public func log(content: String,
                    extra: String? = nil,
                    type: AgoraApaasLogType,
                    from: AnyClass) {
        
    }
}
