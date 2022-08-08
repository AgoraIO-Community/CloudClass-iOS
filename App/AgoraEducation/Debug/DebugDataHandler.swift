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

protocol DebugDataHandlerDelegate: NSObjectProtocol {
    func onDataSourceChanged(index: Int,
                             typeKey: DataSourceType.Key,
                             newCellModel: DebugInfoCellModel)
    
    func onDataSourceValid(_ valid: Bool)
}

class DebugDataHandler {
    private weak var delegate: DebugDataHandlerDelegate?
    
    private let tokenBuilder = TokenBuilder()
    
    private var dataSourceList: [DataSourceType] = []
    
    init(delegate: DebugDataHandlerDelegate?) {
        self.delegate = delegate
    }
    
    func updateDataSourceList(_ list: [DataSourceType]) {
        self.dataSourceList = list
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
        var serviceType: AgoraEduServiceType = .livePremium
        var roleType: AgoraEduUserRole?
        var im: IMType?
        var duration: NSNumber?
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
            case .roomType(let dataSourceRoomType):
                roomType = dataSourceRoomType.edu
            case .serviceType(let dataSourceServiceType):
                if let service = dataSourceServiceType.edu {
                    serviceType = service
                }
            case .roleType(let dataSourceRoleType):
                roleType = dataSourceRoleType.edu
            case .im(let dataSourceIMType):
                im = dataSourceIMType.edu
            case .startTime(let dataSourceStartTime):
                if case .value(let value) = dataSourceStartTime {
                    startTime = NSNumber(value: value)
                }
            case .duration(let dataSourceDuration):
                if case .value(let value) = dataSourceDuration {
                    duration = NSNumber(value: value)
                }
            case .encryptKey(let dataSourceEncryptKey):
                if case .value(let value) = dataSourceEncryptKey {
                    encryptKey = value
                }
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
        launchConfig.widgets.forEach { (k,v) in
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
    
    func cellModelList() -> [DebugInfoCellModel] {
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
    func makeCellModel(_ dataType: DataSourceType,
                       dataTypeIndex: Int) -> DebugInfoCellModel {
        var type: DebugInfoCellType
        
        let title = dataType.title
        let placeholder = dataType.placeholder
        
        switch dataType {
        case .roomName(let dataSourceRoomName):
            var textWarning = false
            let text = dataSourceRoomName.viewText
            if !checkTextInputValid(text) {
                textWarning = true
            }
            type = .text(placeholder: placeholder,
                         text: dataSourceRoomName.viewText,
                         textWarning: textWarning,
                         action: { [weak self] value in
                let roomName: DataSourceRoomName = (value == nil) ? .none : .value(value!)
                let newValue = DataSourceType.roomName(roomName)
                self?.dataSourceList[dataTypeIndex] = newValue
                self?.didDataSourceChanged(at: dataTypeIndex,
                                           with: newValue)
            })
        case .userName(let dataSourceUserName):
            var textWarning = false
            let text = dataSourceUserName.viewText
            if !checkTextInputValid(text) {
                textWarning = true
            }
            type = .text(placeholder: placeholder,
                         text: dataSourceUserName.viewText,
                         textWarning: textWarning,
                         action: { [weak self] value in
                let userName: DataSourceUserName = (value == nil) ? .none : .value(value!)
                let newValue = DataSourceType.userName(userName)
                self?.dataSourceList[dataTypeIndex] = newValue
                self?.didDataSourceChanged(at: dataTypeIndex,
                                           with: newValue)
            })
        case .startTime(_):
            type = .time(action: { [weak self] value in
                let startTime: DataSourceStartTime = .value(value)
                let newValue = DataSourceType.startTime(startTime)
                self?.dataSourceList[dataTypeIndex] = newValue
                
                self?.didDataSourceChanged(at: dataTypeIndex,
                                           with: newValue)
            })
        case .duration(let dataSourceDuration):
            type = .text(placeholder: placeholder,
                         text: dataSourceDuration.viewText,
                         action: { [weak self] value in
                let userName: DataSourceUserName = (value == nil) ? .none : .value(value!)
                let newValue = DataSourceType.userName(userName)
                self?.dataSourceList[dataTypeIndex] = newValue
                
                self?.didDataSourceChanged(at: dataTypeIndex,
                                           with: newValue)
            })
        case .encryptKey(let dataSourceEncryptKey):
            type = .text(placeholder: placeholder,
                         text: dataSourceEncryptKey.viewText,
                         action: { [weak self] value in
                let encryptKey: DataSourceEncryptKey = (value == nil) ? .none : .value(value!)
                let newValue = DataSourceType.encryptKey(encryptKey)
                self?.dataSourceList[dataTypeIndex] = newValue
                self?.didDataSourceChanged(at: dataTypeIndex,
                                           with: newValue)
            })
            
        case .roomType(let selected):
            let list = DataSourceRoomType.allCases
            let action: OptionSelectedAction = { [weak self] index in
                let roomType: DataSourceRoomType = list[index]
                let newValue = DataSourceType.roomType(roomType)
                self?.dataSourceList[dataTypeIndex] = newValue
                self?.didDataSourceChanged(at: dataTypeIndex,
                                           with: newValue)
            }
            
            let options: [(String, OptionSelectedAction)] = list.map({return ($0.viewText, action)})
            let selectedIndex = list.firstIndex(where: {$0 == selected})
            type = .option(options: options,
                           placeholder: placeholder,
                           text: selected.viewText,
                           selectedIndex: selectedIndex ?? -1)
        case .serviceType(let selected):
            let list = DataSourceServiceType.allCases
            let action: OptionSelectedAction = { [weak self] index in
                let serviceType: DataSourceServiceType = list[index]
                let newValue = DataSourceType.serviceType(serviceType)
                self?.dataSourceList[dataTypeIndex] = newValue
                self?.didDataSourceChanged(at: dataTypeIndex,
                                           with: newValue)
            }
            let options: [(String, OptionSelectedAction)] = list.map({return ($0.viewText, action)})
            let selectedIndex = list.firstIndex(where: {$0 == selected})
            type = .option(options: options,
                           placeholder: placeholder,
                           text: selected.viewText,
                           selectedIndex: selectedIndex ?? -1)
        case .roleType(let selected):
            let list = DataSourceRoleType.allCases
            let action: OptionSelectedAction = { [weak self] index in
                let roleType: DataSourceRoleType = list[index]
                let newValue = DataSourceType.roleType(roleType)
                self?.dataSourceList[dataTypeIndex] = newValue
                self?.didDataSourceChanged(at: dataTypeIndex,
                                           with: newValue)
            }
            let options: [(String, OptionSelectedAction)] = list.map({return ($0.viewText, action)})
            let selectedIndex = list.firstIndex(where: {$0 == selected})
            type = .option(options: options,
                           placeholder: placeholder,
                           text: selected.viewText,
                           selectedIndex: selectedIndex ?? -1)
        case .im(let selected):
            let list = DataSourceIMType.allCases
            let action: OptionSelectedAction = { [weak self] index in
                let im: DataSourceIMType = list[index]
                let newValue = DataSourceType.im(im)
                self?.dataSourceList[dataTypeIndex] = newValue
                self?.didDataSourceChanged(at: dataTypeIndex,
                                           with: newValue)
            }
            let options: [(String, OptionSelectedAction)] = list.map({return ($0.viewText, action)})
            let selectedIndex = list.firstIndex(where: {$0 == selected})
            type = .option(options: options,
                           placeholder: placeholder,
                           text: selected.viewText,
                           selectedIndex: selectedIndex ?? -1)
        case .encryptMode(let selected):
            let list = DataSourceEncryptMode.allCases
            let action: OptionSelectedAction = { [weak self] index in
                let encryptMode: DataSourceEncryptMode = list[index]
                let newValue = DataSourceType.encryptMode(encryptMode)
                self?.dataSourceList[dataTypeIndex] = newValue
                self?.didDataSourceChanged(at: dataTypeIndex,
                                           with: newValue)
            }
            let options: [(String, OptionSelectedAction)] = list.map({return ($0.viewText, action)})
            let selectedIndex = list.firstIndex(where: {$0 == selected})
            type = .option(options: options,
                           placeholder: placeholder,
                           text: selected.viewText,
                           selectedIndex: selectedIndex ?? -1)
        case .mediaAuth(let selected):
            let list = DataSourceMediaAuth.allCases
            let action: OptionSelectedAction = { [weak self] index in
                let mediaAuth: DataSourceMediaAuth = list[index]
                let newValue = DataSourceType.mediaAuth(mediaAuth)
                self?.dataSourceList[dataTypeIndex] = newValue
                self?.didDataSourceChanged(at: dataTypeIndex,
                                           with: newValue)
            }
            let options: [(String, OptionSelectedAction)] = list.map({return ($0.viewText, action)})
            let selectedIndex = list.firstIndex(where: {$0 == selected})
            type = .option(options: options,
                           placeholder: placeholder,
                           text: selected.viewText,
                           selectedIndex: selectedIndex ?? -1)
        case .uiMode(let selected):
            let list = DataSourceUIMode.allCases
            let action: OptionSelectedAction = { [weak self] index in
                let uiMode: DataSourceUIMode = list[index]
                let newValue = DataSourceType.uiMode(uiMode)
                self?.dataSourceList[dataTypeIndex] = newValue
                self?.didDataSourceChanged(at: dataTypeIndex,
                                           with: newValue)
            }
            let options: [(String, OptionSelectedAction)] = list.map({return ($0.viewText, action)})
            let selectedIndex = list.firstIndex(where: {$0 == selected})
            type = .option(options: options,
                           placeholder: placeholder,
                           text: selected.viewText,
                           selectedIndex: selectedIndex ?? -1)
        case .uiLanguage(let selected):
            let list = DataSourceUILanguage.allCases
            let action: OptionSelectedAction = { [weak self] index in
                let uiLanguage: DataSourceUILanguage = list[index]
                let newValue = DataSourceType.uiLanguage(uiLanguage)
                self?.dataSourceList[dataTypeIndex] = newValue
                self?.didDataSourceChanged(at: dataTypeIndex,
                                           with: newValue)
            }
            let options: [(String, OptionSelectedAction)] = list.map({return ($0.viewText, action)})
            let selectedIndex = list.firstIndex(where: {$0 == selected})
            type = .option(options: options,
                           placeholder: placeholder,
                           text: selected.viewText,
                           selectedIndex: selectedIndex ?? -1)
        case .region(let selected):
            let list = DataSourceRegion.allCases
            let action: OptionSelectedAction = { [weak self] index in
                let region: DataSourceRegion = list[index]
                let newValue = DataSourceType.region(region)
                self?.dataSourceList[dataTypeIndex] = newValue
                self?.didDataSourceChanged(at: dataTypeIndex,
                                           with: newValue)
            }
            let options: [(String, OptionSelectedAction)] = list.map({return ($0.viewText, action)})
            let selectedIndex = list.firstIndex(where: {$0 == selected})
            type = .option(options: options,
                           placeholder: placeholder,
                           text: selected.viewText,
                           selectedIndex: selectedIndex ?? -1)
        case .environment(let selected):
            let list = DataSourceEnvironment.allCases
            let action: OptionSelectedAction = { [weak self] index in
                let environment: DataSourceEnvironment = list[index]
                let newValue = DataSourceType.environment(environment)
                self?.dataSourceList[dataTypeIndex] = newValue
                self?.didDataSourceChanged(at: dataTypeIndex,
                                           with: newValue)
            }
            let options: [(String, OptionSelectedAction)] = list.map({return ($0.viewText, action)})
            let selectedIndex = list.firstIndex(where: {$0 == selected})
            type = .option(options: options,
                           placeholder: placeholder,
                           text: selected.viewText,
                           selectedIndex: selectedIndex ?? -1)
        }
        
        let model = DebugInfoCellModel(title: title,
                                       type: type)
        return model
    }
    
    func didDataSourceChanged(at index: Int,
                              with dataSource: DataSourceType) {
        let newModel = makeCellModel(dataSource,
                                     dataTypeIndex: index)
        delegate?.onDataSourceChanged(index: index,
                                      typeKey: dataSource.inKey,
                                      newCellModel: newModel)
        
        checkDataSource()
    }
    
    func checkDataSource() {
        var dataCompleted = false
        if case .roomType(let roomType) = dataSourceList.valueOfType(.roomType) as? DataSourceType,
           case .roleType(let roleType) = dataSourceList.valueOfType(.roleType) as? DataSourceType,
           case .roomName(let roomName) = dataSourceList.valueOfType(.roomName) as? DataSourceType,
           case .userName(let userName) = dataSourceList.valueOfType(.userName) as? DataSourceType,
           roomType != .unselected,
           roleType != .unselected,
           case .value(let roomNameText) = roomName,
           case .value(let userNameText) = userName,
           checkTextInputValid(roomNameText),
           checkTextInputValid(userNameText) {
            dataCompleted = true
        }
        delegate?.onDataSourceValid(dataCompleted)
    }
    
    func checkTextInputValid(_ text: String) -> Bool {
        let minInputLength = 6
        
        let pattern = "[\u{4e00}-\u{9fa5}a-zA-Z0-9\\s]*$"
        let pred = NSPredicate(format: "SELF MATCHES %@", pattern)
        var isVaild = pred.evaluate(with: text)
        
        if text.count > 0 {
            isVaild = (isVaild && text.count >= minInputLength)
        }
        return isVaild
    }
}
