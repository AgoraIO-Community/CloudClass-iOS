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
import AgoraProctorSDK
import Foundation

protocol DebugDataHandlerDelegate: NSObjectProtocol {
    func onDataSourceChanged(index: Int,
                             typeKey: DataSourceType.Key,
                             newCellModel: DebugInfoCellModel)
    
    func onDataSourceNeedReload()
    
    func onDataSourceValid(_ valid: Bool)
}

class DebugDataHandler {
    private weak var delegate: DebugDataHandlerDelegate?
    
    private let tokenBuilder = TokenBuilder()
    
    private var dataSourceList: [DataSourceType] = [] {
        didSet {
            checkDataSource()
        }
    }
    
    init(delegate: DebugDataHandlerDelegate?) {
        self.delegate = delegate
    }
    
    func updateDataSourceList(_ list: [DataSourceType]) {
        self.dataSourceList = list
        
        if case .region(let region) = dataSourceList.valueOfType(.region) as? DataSourceType {
            FcrEnvironment.shared.region = region.env
        }
        
        if case .uiLanguage(let uiLanguage) = dataSourceList.valueOfType(.uiLanguage) as? DataSourceType {
            FcrLocalization.shared.setupNewLanguage(uiLanguage.edu)
        }
    }
    
    func updateProctorSDKEnviroment(proctorSDK: AgoraProctorSDK) {
        guard case .environment(let environment) = dataSourceList.valueOfType(.environment) as? DataSourceType else {
            return
        }
        let sel = NSSelectorFromString("setEnvironment:")
        switch environment {
        case .pro:
            proctorSDK.perform(sel,
                               with: 2)
        case .pre:
            proctorSDK.perform(sel,
                               with: 1)
        case .dev:
            proctorSDK.perform(sel,
                               with: 0)
        }
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
    
    func getEnvironment() -> DataSourceEnvironment {
        switch FcrEnvironment.shared.environment {
        case .dev:  return .dev
        case .pre:  return .pre
        case .pro:  return .pro
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

    func checkLaunchInfoValid() -> DebugLaunchInfo? {
        var roomName: String?
        var userName: String?
        var roomType: DataSourceRoomType?
        var serviceType: DataSourceServiceType = .livePremium
        var roleType: DataSourceRoleType?
        var im: DataSourceIMType?
        // proctor
        var deviceType: DataSourceDeviceType = .main
        var duration: NSNumber?
        var encryptKey: String?
        var encryptMode: DataSourceEncryptMode?
        
        var startTime: NSNumber?
        
        var mediaAuth: DataSourceMediaAuth?
        var region: DataSourceRegion?
        var uiMode: DataSourceUIMode?
        var uiLanguage: DataSourceUILanguage?
        var environment: DataSourceEnvironment?
        
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
                roomType = (dataSourceRoomType != .unselected) ? dataSourceRoomType : nil
            case .serviceType(let dataSourceServiceType):
                serviceType = dataSourceServiceType
            case .roleType(let dataSourceRoleType):
                roleType = (dataSourceRoleType != .unselected) ? dataSourceRoleType : nil
            case .im(let dataSourceIMType):
                im = dataSourceIMType
            case .deviceType(let dataSourceDeviceType):
                deviceType = dataSourceDeviceType
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
                encryptMode = dataSourceEncryptMode
            case .mediaAuth(let dataSourceMediaAuth):
                mediaAuth = dataSourceMediaAuth
            case .uiMode(let dataSourceUIMode):
                uiMode = dataSourceUIMode
            case .uiLanguage(let dataSourceUILanguage):
                uiLanguage = dataSourceUILanguage
            case .region(let dataSourceRegion):
                region = dataSourceRegion
            case .environment(let dataSourceEnvironment):
                environment = dataSourceEnvironment
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
        let roomId = "\(roomName.md5())\(roomType.tag)"
        return DebugLaunchInfo(roomName: roomName,
                               roomId: roomId,
                               userName: userName,
                               userId: userId,
                               roomType: roomType,
                               serviceType: serviceType,
                               roleType: roleType,
                               im: im,
                               deviceType: deviceType,
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
    
    func getEduLaunchConfig(debugInfo: DebugLaunchInfo,
                            appId: String,
                            token: String,
                            userId: String) -> AgoraEduLaunchConfig? {
        guard let userRole = debugInfo.roleType.edu,
        let roomType = debugInfo.roomType.edu else {
            return nil
        }
        let mediaOptions = debugInfo.eduMediaOptions
        
        let launchConfig = AgoraEduLaunchConfig(userName: debugInfo.userName,
                                                userUuid: userId,
                                                userRole: userRole,
                                                roomName: debugInfo.roomName,
                                                roomUuid: debugInfo.roomId,
                                                roomType: roomType,
                                                appId: appId,
                                                token: token,
                                                startTime: debugInfo.startTime,
                                                duration: debugInfo.duration,
                                                region: debugInfo.region.edu,
                                                mediaOptions: mediaOptions,
                                                userProperties: nil)
        
        // MARK: 若对widgets需要添加或修改时，可获取launchConfig中默认配置的widgets进行操作并重新赋值给launchConfig
        let cloudWidgetKey = "AgoraCloudWidget"
        let netlessWidgetKey = "netlessBoard"
        let easemobWidgetKey = "easemobIM"
        
        let widgets = launchConfig.widgets
        if let config = widgets[cloudWidgetKey] {
            config.extraInfo = ["publicCoursewares": debugInfo.publicCoursewares()]
        }
        
        if let config = widgets[netlessWidgetKey],
           var extra = config.extraInfo as? [String: Any] {
            extra["coursewareList"] = debugInfo.publicCoursewares()
        }
        
        if debugInfo.region != .CN ||
            debugInfo.im == .rtm {
            launchConfig.widgets.removeValue(forKey: easemobWidgetKey)
        }
        
        return launchConfig
    }
    
    func getProctorLaunchConfig(debugInfo: DebugLaunchInfo,
                                appId: String,
                                token: String,
                                userId: String) -> AgoraProctorLaunchConfig {
        let mediaOptions = debugInfo.proctorMediaOptions

        let launchConfig = AgoraProctorLaunchConfig(userName: debugInfo.userName,
                                                    userUuid: userId,
                                                    userRole: .student,
                                                    roomName: debugInfo.roomName,
                                                    roomUuid: debugInfo.roomId,
                                                    appId: appId,
                                                    token: token,
                                                    region: debugInfo.region.proctor,
                                                    mediaOptions: mediaOptions,
                                                    userProperties: nil)
        
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
        FcrOutsideClassAPI.freeBuildToken(roomId: roomId,
                                          userRole: userRole,
                                          userId: userId) { dict in
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
        } onFailure: { code, msg in
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
                self?.updateDataSource(at: dataTypeIndex,
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
                self?.updateDataSource(at: dataTypeIndex,
                                       with: newValue)
            })
        case .startTime(let dataSourceStartTime):
            type = .time(timeInterval: dataSourceStartTime.timeInterval,
                         action: { [weak self] value in
                let startTime: DataSourceStartTime = .value(value)
                let newValue = DataSourceType.startTime(startTime)

                self?.updateDataSource(at: dataTypeIndex,
                                       with: newValue)
            })
        case .duration(let dataSourceDuration):
            type = .text(placeholder: placeholder,
                         text: dataSourceDuration.viewText,
                         action: { [weak self] value in
                let userName: DataSourceUserName = (value == nil) ? .none : .value(value!)
                let newValue = DataSourceType.userName(userName)

                self?.updateDataSource(at: dataTypeIndex,
                                       with: newValue)
            })
        case .encryptKey(let dataSourceEncryptKey):
            type = .text(placeholder: placeholder,
                         text: dataSourceEncryptKey.viewText,
                         action: { [weak self] value in
                let encryptKey: DataSourceEncryptKey = (value == nil) ? .none : .value(value!)
                let newValue = DataSourceType.encryptKey(encryptKey)
                self?.updateDataSource(at: dataTypeIndex,
                                       with: newValue)
            })
        case .roomType(let selected):
            let list = DataSourceRoomType.allCases
            let action: OptionSelectedAction = { [weak self] index in
                let roomType: DataSourceRoomType = list[index]
                let newValue = DataSourceType.roomType(roomType)
                self?.updateDataSource(at: dataTypeIndex,
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
                self?.updateDataSource(at: dataTypeIndex,
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
                self?.updateDataSource(at: dataTypeIndex,
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
                self?.updateDataSource(at: dataTypeIndex,
                                       with: newValue)
            }
            let options: [(String, OptionSelectedAction)] = list.map({return ($0.viewText, action)})
            let selectedIndex = list.firstIndex(where: {$0 == selected})
            type = .option(options: options,
                           placeholder: placeholder,
                           text: selected.viewText,
                           selectedIndex: selectedIndex ?? -1)
        case .deviceType(let selected):
            let list = DataSourceDeviceType.allCases
            let action: OptionSelectedAction = { [weak self] index in
                let deviceType: DataSourceDeviceType = list[index]
                let newValue = DataSourceType.deviceType(deviceType)
                self?.updateDataSource(at: dataTypeIndex,
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
                self?.updateDataSource(at: dataTypeIndex,
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
                self?.updateDataSource(at: dataTypeIndex,
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
                FcrUserInfoPresenter.shared.theme = uiMode.edu.rawValue
                let newValue = DataSourceType.uiMode(uiMode)
                self?.updateDataSource(at: dataTypeIndex,
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
                // special
                FcrLocalization.shared.setupNewLanguage(uiLanguage.edu)

                let newValue = DataSourceType.uiLanguage(uiLanguage)
                self?.updateDataSource(at: dataTypeIndex,
                                       with: newValue)
                // special
                self?.updateAllDataSource()
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
                
                // special
                FcrEnvironment.shared.region = region.env
                
                let newValue = DataSourceType.region(region)
                self?.updateDataSource(at: dataTypeIndex,
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
                FcrEnvironment.shared.environment = environment.edu
                
                let newValue = DataSourceType.environment(environment)
                self?.updateDataSource(at: dataTypeIndex,
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
    
    func updateDataSource(at index: Int,
                          with dataSource: DataSourceType) {
        dataSourceList[index] = dataSource
        let newModel = makeCellModel(dataSource,
                                     dataTypeIndex: index)
        delegate?.onDataSourceChanged(index: index,
                                      typeKey: dataSource.inKey,
                                      newCellModel: newModel)
    }
    
    func updateAllDataSource() {
        delegate?.onDataSourceNeedReload()
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
