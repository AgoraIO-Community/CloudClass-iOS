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
    private let tokenBuilder = TokenBuilder()
    
    private var dataSourceList: [DataSourceType] = []
    
    init(dataSourceList: [DataSourceType]) {
        self.dataSourceList = dataSourceList
    }
}

extension DebugDataHandler {
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
    
    func getLaunchInfo() -> DebugLaunchInfo? {
        var roomName: String?
        var userName: String?
        var roomType: AgoraEduRoomType?
        var serviceType: AgoraEduServiceType?
        var roleType: AgoraEduUserRole?
        var im: IMType?
        var duration: NSNumber?
        var delay: NSNumber?
        var encryptKey: String?
        var encryptMode: AgoraEduMediaEncryptionMode?
        
        var startTime: NSNumber?
        
        var mediaAuth: AgoraEduMediaAuthOption?
        var region: AgoraEduRegion?
        var uiMode: AgoraUIMode?
        var uiLanguage: FcrSurpportLanguage?
        var environment: FcrEnvironment.Environment?

        for item in dataSourceList {
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
                duration = NSNumber(value: value)
            case .delay(let dataSourceDelay):
                guard case .value(let value) = dataSourceDelay else {
                    return nil
                }
                delay = NSNumber(value: value)
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

        let userId = "\(userName.md5())\(roleType.rawValue)"
        let roomId = "\(roomName.md5())\(roomType.rawValue)"
        return DebugLaunchInfo(roomName: roomName,
                               roomId: roomId,
                               userName: userName,
                               userId: userId,
                               roomType: roomType,
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
    
    func getLaunchConfig(debugInfo: DebugLaunchInfo,
                         appId: String,
                         token: String,
                         userId: String) -> AgoraEduLaunchConfig {
        var encryptionConfig: AgoraEduMediaEncryptionConfig?
        if let key = debugInfo.encryptKey,
           debugInfo.encryptMode != .none {
            let tfModeValue = debugInfo.encryptMode.rawValue
            if tfModeValue > 0 && tfModeValue <= 6 {
                encryptionConfig = AgoraEduMediaEncryptionConfig(mode: debugInfo.encryptMode,
                                                                 key: key)
            }
        }
        
        var latencyLevel = AgoraEduLatencyLevel.ultraLow
        if debugInfo.serviceType == .livePremium {
            latencyLevel = .ultraLow
        } else if debugInfo.serviceType == .liveStandard {
            latencyLevel = .low
        }
        
        let videoState: AgoraEduStreamState = (debugInfo.mediaAuth == .video || debugInfo.mediaAuth == .both) ? .on : .off
        let audioState: AgoraEduStreamState = (debugInfo.mediaAuth == .audio || debugInfo.mediaAuth == .both) ? .on : .off
        let mediaOptions = AgoraEduMediaOptions(encryptionConfig: encryptionConfig,
                                                videoEncoderConfig: nil,
                                                latencyLevel: latencyLevel,
                                                videoState: videoState,
                                                audioState: audioState)
        
        let launchConfig = AgoraEduLaunchConfig(userName: debugInfo.userName,
                                                userUuid: userId,
                                                userRole:debugInfo.roleType,
                                                roomName: debugInfo.roomName,
                                                roomUuid: debugInfo.roomId,
                                                roomType: debugInfo.roomType,
                                                appId: appId,
                                                token: token,
                                                startTime: debugInfo.startTime,
                                                duration: debugInfo.duration,
                                                region: debugInfo.region,
                                                mediaOptions: mediaOptions,
                                                userProperties: nil)
        
        // MARK: 若对widgets需要添加或修改时，可获取launchConfig中默认配置的widgets进行操作并重新赋值给launchConfig
        var widgets = Dictionary<String,AgoraWidgetConfig>()
        launchConfig.widgets.forEach { [unowned self] (k,v) in
            if k == "AgoraCloudWidget" {
                v.extraInfo = ["publicCoursewares": debugInfo.publicCoursewares()]
            }
            if k == "netlessBoard",
               v.extraInfo != nil {
                var newExtra = v.extraInfo as! Dictionary<String, Any>
                newExtra["coursewareList"] = debugInfo.publicCoursewares()
                v.extraInfo = newExtra
            }
            widgets[k] = v
        }
        launchConfig.widgets = widgets
        
        if debugInfo.region != .CN ||
            debugInfo.im == .rtm {
            launchConfig.widgets.removeValue(forKey: "easemobIM")
        }
        
        return launchConfig
    }
    
    func buildToken(appId: String,
                    appCertificate: String,
                    userUuid: String,
                    success: @escaping (TokenBuilder.ServerResp) -> (),
                    failure: @escaping (NSError) -> ()) {
        let token = tokenBuilder.buildByAppId(appId,
                                              appCertificate: appCertificate,
                                              userUuid: userUuid)
        
        let response = TokenBuilder.ServerResp(appId: appId,
                                               userId: userUuid,
                                               token: token)
        success(response)
    }
    
    func requestToken(roomId: String,
                      userId: String,
                      userRole: Int,
                      success: @escaping (TokenBuilder.ServerResp) -> (),
                      failure: @escaping (NSError) -> ()) {
        FcrOutsideClassAPI.freeBuildToken(roomId: roomId, userRole: userRole, userId: userId) { dict in
            guard let data = dict["data"] as? [String : Any] else {
                fatalError("TokenBuilder buildByServer can not find data, dict: \(dict)")
            }
            guard let token = data["token"] as? String,
                  let appId = data["appId"] as? String,
                  let userId = data["userUuid"] as? String else {
                fatalError("TokenBuilder buildByServer can not find value, dict: \(dict)")
            }
            let resp = TokenBuilder.ServerResp(appId: appId,
                                               userId: userId,
                                               token: token)
            success(resp)
        } onFailure: { msg in
            let error = NSError.init(domain: msg, code: -1)
            failure(error)
        }
    }
    
    func makeViewModels() -> [DebugInfoCellModel] {
        var list = [DebugInfoCellModel]()
        for (index,item) in dataSourceList.enumerated() {
            let model = makeCellModel(item,
                                      dataTypeIndex: index)
            list.append(model)
        }
        return list
    }
}

// MARK: - private
private extension DebugDataHandler {
    private func makeCellModel(_ dataType: DataSourceType,
                               dataTypeIndex: Int) -> DebugInfoCellModel {
        var type: DebugInfoCellType
        
        let title = dataType.title
        let placeholder = dataType.placeholder
        
        switch dataType {
        case .roomName(let dataSourceRoomName):
            type = .text(placeholder: placeholder,
                         text: dataSourceRoomName.viewText,
                         action: { [weak self] value in
                let roomName: DataSourceRoomName = (value == nil) ? .none : .value(value!)
                self?.dataSourceList[dataTypeIndex] = .roomName(roomName)
            })
        case .userName(let dataSourceUserName):
            type = .text(placeholder: placeholder,
                         text: dataSourceUserName.viewText,
                         action: { [weak self] value in
                let userName: DataSourceUserName = (value == nil) ? .none : .value(value!)
                self?.dataSourceList[dataTypeIndex] = .userName(userName)
            })
        case .startTime(_):
            type = .time(action: { [weak self] value in
                let startTime: DataSourceStartTime = .value(value)
                self?.dataSourceList[dataTypeIndex] = .startTime(startTime)
            })
        case .duration(let dataSourceDuration):
            type = .text(placeholder: placeholder,
                         text: dataSourceDuration.viewText,
                         action: { [weak self] value in
                let userName: DataSourceUserName = (value == nil) ? .none : .value(value!)
                self?.dataSourceList[dataTypeIndex] = .userName(userName)
            })
        case .delay(let dataSourceDelay):
            type = .text(placeholder: placeholder,
                         text: dataSourceDelay.viewText,
                         action: { [weak self] value in
                var delay = DataSourceDelay.none
                if let string = value,
                   let delayInt = Int64(string) {
                    delay = .value(delayInt)
                }
                self?.dataSourceList[dataTypeIndex] = .delay(delay)
            })
        case .encryptKey(let dataSourceEncryptKey):
            type = .text(placeholder: placeholder,
                         text: dataSourceEncryptKey.viewText,
                         action: { [weak self] value in
                let encryptKey: DataSourceEncryptKey = (value == nil) ? .none : .value(value!)
                self?.dataSourceList[dataTypeIndex] = .encryptKey(encryptKey)
            })
            
        case .roomType(let selected, let list):
            let action: OptionSelectedAction = { [weak self] index in
                let roomType: DataSourceRoomType = list[index]
                self?.dataSourceList[index] = .roomType(selected: roomType,
                                                        list: list)
            }
            let finalList = list.filter({$0.viewText != nil})
            let options: [(String, OptionSelectedAction)] = finalList.map({return ($0.viewText!, action)})
            let selectedIndex = list.firstIndex(where: {$0 == selected})
            type = .option(options: options,
                           placeholder: placeholder,
                           text: selected.viewText,
                           selectedIndex: selectedIndex ?? -1)
        case .serviceType(let selected):
            let list = DataSourceServiceType.allCases
            let action: OptionSelectedAction = { [weak self] index in
                let serviceType: DataSourceServiceType = list[index]
                self?.dataSourceList[index] = .serviceType(serviceType)
            }
            let options: [(String, OptionSelectedAction)] = list.map({return ($0.viewText, action)})
            let selectedIndex = list.firstIndex(where: {$0 == selected})
            type = .option(options: options,
                           placeholder: placeholder,
                           text: selected.viewText,
                           selectedIndex: selectedIndex ?? -1)
        case .roleType(let selected, let list):
            let action: OptionSelectedAction = { [weak self] index in
                let roleType: DataSourceRoleType = list[index]
                self?.dataSourceList[index] = .roleType(selected: roleType,
                                                        list: list)
            }
            let finalList = list.filter({$0.viewText != nil})
            let options: [(String, OptionSelectedAction)] = finalList.map({return ($0.viewText!, action)})
            let selectedIndex = list.firstIndex(where: {$0 == selected})
            type = .option(options: options,
                           placeholder: placeholder,
                           text: selected.viewText,
                           selectedIndex: selectedIndex ?? -1)
        case .im(let selected):
            let list = DataSourceIMType.allCases
            let action: OptionSelectedAction = { [weak self] index in
                let im: DataSourceIMType = list[index]
                self?.dataSourceList[index] = .im(im)
            }
            let options: [(String, OptionSelectedAction)] = list.map({return ($0.viewText, action)})
            let selectedIndex = list.firstIndex(where: {$0 == selected})
            type = .option(options: options,
                           placeholder: placeholder,
                           text: selected.viewText,
                           selectedIndex: selectedIndex ?? -1)
        case .encryptMode(let selected):
            <#code#>
        case .mediaAuth(let selected):
            <#code#>
        case .uiMode(let selected):
            <#code#>
        case .uiLanguage(let selected):
            <#code#>
        case .region(let selected):
            <#code#>
        case .environment(let selected):
            <#code#>
        }
        
        let model = DebugInfoCellModel(title: title,
                                       type: type)
        return model
    }
}
