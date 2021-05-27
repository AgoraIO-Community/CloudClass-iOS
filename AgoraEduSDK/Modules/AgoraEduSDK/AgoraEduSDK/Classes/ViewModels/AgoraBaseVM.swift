//
//  AgoraBaseVM.swift
//  AgoraEduSDK
//
//  Created by SRS on 2021/3/14.
//

import Foundation
import AgoraUIEduBaseViews
import EduSDK
import AgoraEduContext

enum AgoraCauseType: Int, Decodable {
    case device = 4

    // handsUpmanager
    case handsUpEnable = 5
    case handsupProgress = 501

    // streamGroups
    case streamGroupsAdd = 600
    case streamGroupsDel = 601

    case peerChatEnable = 6

    case screenSelectChanged = 1301

    case reward = 1101
}

@objcMembers public class AgoraVMConfig: NSObject {
    public var appId: String = ""

    public var sceneType: AgoraRTESceneType = .type1V1
    public var roomUuid: String = ""
    public var className: String = ""
    
    public var userUuid: String = ""
    public var userName: String = ""
    public var token: String = ""
    public var baseURL: String = ""

}

@objcMembers public class AgoraBaseVM: NSObject {
    var config: AgoraVMConfig = AgoraVMConfig()
    var localUserInfo: AgoraRTELocalUser?
    
    public override init() {
        super.init()
    }
    public init(config: AgoraVMConfig) {
        super.init()
        self.config = config
    }
    public init(config: AgoraVMConfig, localUserInfo: AgoraRTELocalUser) {
        super.init()
        self.config = config
        self.localUserInfo = localUserInfo
    }
    public func setLocalUser(_ localUserInfo: AgoraRTELocalUser) {
        self.localUserInfo = localUserInfo
    }
}

extension AgoraBaseVM {
    // MARK - Localized
    public func localizedString(_ key: String) -> String {
        
        let bundle = Bundle(for: self.classForCoder)
        guard let url = bundle.url(forResource: "AgoraEduSDK",
                                withExtension: "bundle"), let agoraBundle = Bundle(url: url) else {
            return ""
        }
        
        return NSLocalizedString(key,
                                 bundle: agoraBundle,
                                 comment: "")
    }
}

extension AgoraBaseVM {
    func kitLocalUserInfo() -> AgoraEduContextUserInfo? {
        guard let rteUser = self.localUserInfo else {
            return nil
        }
        
        let userInfo = AgoraEduContextUserInfo()
        userInfo.role = AgoraEduContextUserRole(rawValue: rteUser.role.rawValue) ?? .student
        userInfo.userUuid = rteUser.userUuid
        userInfo.userName = rteUser.userName
        
        return userInfo
    }
    
    func kitUserInfo(_ rteUser: AgoraRTEBaseUser) -> AgoraEduContextUserInfo {
        let userInfo = AgoraEduContextUserInfo()
        userInfo.role = AgoraEduContextUserRole(rawValue: rteUser.role.rawValue) ?? .student
        userInfo.userUuid = rteUser.userUuid
        userInfo.userName = rteUser.userName
        return userInfo
    }
    
    func kitError(_ err: Error) -> AgoraEduContextError {
        let error = err as NSError
        
        let kitError = AgoraEduContextError(code: error.code,
                                            message: error.localizedDescription)
        return kitError
    }
}
