//
//  DebugDataSource.swift
//  AgoraEducation
//
//  Created by LYY on 2022/8/5.
//  Copyright © 2022 Agora. All rights reserved.
//

#if canImport(AgoraClassroomSDK_iOS)
import AgoraClassroomSDK_iOS
#else
import AgoraClassroomSDK
#endif
import Foundation

class DebugDataHandler {
    func getRegion() -> DataSourceRegion {
        switch FcrEnvironment.shared.region {
        case .CN: return .CN
        case .NA: return .NA
        case .EU: return .EU
        case .AP: return .AP
        }
    }
    
    func getLaunchLanguage() -> DataSourceUILanguage {
        switch FcrLocalization.shared.language {
        case .zh_cn: return .zh_cn
        case .en:    return .en
        default:     return .zh_cn
        }
    }
    
    func getUIMode() -> DataSourceUIMode {
        return DataSourceUIMode(rawValue: FcrUserInfoPresenter.shared.theme) ?? .light
    }
    
    func getLaunchInfo(_ list: [DataSourceType]) -> LaunchInfoModel? {
        var roomName: String?
        var userName: String?
        var roomType: AgoraEduRoomType?
        var serviceType: AgoraEduServiceType?
        var roleType: AgoraEduUserRole?
        var im: IMType?
        var duration: Int?
        var delay: Int?
        var encryptKey: String?
        var encryptMode: AgoraEduMediaEncryptionMode?
        
        var startTime: NSNumber?
        
        var mediaAuth: AgoraEduMediaAuthOption?
        var region: AgoraEduRegion?
        var uiMode: AgoraUIMode?
        var uiLanguage: FcrSurpportLanguage?
        var environment: FcrEnvironment.Environment?

        for item in list {
            switch item {
            case .roomName(let dataSourceRoomName):
                guard case .value(let value) = dataSourceRoomName else {
                    return nil
                }
                roomName = value
            case .userName(let dataSourceUserName):
                guard case .value(let value) = dataSourceUserName else {
                    return nil
                }
                userName = value
            case .roomType(let selected, _):
                roomType = selected.edu
            case .serviceType(let dataSourceServiceType):
                serviceType = dataSourceServiceType.edu
            case .roleType(let selected, _):
                roleType = selected.edu
            case .im(let dataSourceIMType):
                im = dataSourceIMType.edu
            case .startTime(let dataSourceStartTime):
                guard case .value(let value) = dataSourceStartTime else {
                    return nil
                }
                startTime = NSNumber(value: value)
            case .duration(let dataSourceDuration):
                guard case .value(let value) = dataSourceDuration else {
                    return nil
                }
                duration = Int(value)
            case .delay(let dataSourceDelay):
                guard case .value(let value) = dataSourceDelay else {
                    return nil
                }
                delay = Int(value)
            case .encryptKey(let dataSourceEncryptKey):
                guard case .value(let value) = dataSourceEncryptKey else {
                    return nil
                }
                encryptKey = value
            case .encryptMode(let dataSourceEncryptMode):
                encryptMode = dataSourceEncryptMode.edu
            case .mediaAuth(let dataSourceMediaAuth):
                mediaAuth = dataSourceMediaAuth.edu
            case .uiMode(let dataSourceUIMode):
                uiMode = dataSourceUIMode.edu
            case .uiLanguage(let dataSourceUILanguage):
                uiLanguage = dataSourceUILanguage.edu
            case .region(let dataSourceRegion):
                region = dataSourceRegion.edu
            case .environment(let dataSourceEnvironment):
                environment = dataSourceEnvironment.edu
            }
        }
        
        guard let roomName = roomName,
              let userName = userName,
              let roomType = roomType,
              let serviceType = serviceType,
              let roleType = roleType,
              let im = im,
              let encryptMode = encryptMode,
              let mediaAuth = mediaAuth,
              let region = region,
              let uiMode = uiMode,
              let uiLanguage = uiLanguage,
              let environment = environment else {
            return nil
        }
        
        if encryptMode != .none,
           encryptKey == nil {
            return nil
        }
        return LaunchInfoModel(roomName: roomName,
                               userName: userName,
                               roomStyle: roomType,
                               serviceType: serviceType,
                               roleType: roleType,
                               im: im,
                               duration: duration,
                               delay: delay,
                               encryptKey: encryptKey,
                               encryptMode: encryptMode,
                               startTime: startTime,
                               mediaAuth: mediaAuth,
                               region: region,
                               uiMode: uiMode,
                               uiLanguage: uiLanguage,
                               environment: environment)
    }
}
