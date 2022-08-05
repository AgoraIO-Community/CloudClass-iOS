//
//  DebugModels.swift
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

protocol DataSourceOptionProtocol {
    var viewText: String {get}
}

enum DataSourceRoomName {
    case none
    case value(String)
}

enum DataSourceUserName {
    case none
    case value(String)
}

enum DataSourceRoomType: DataSourceOptionProtocol, CaseIterable {
    case oneToOne
    case small
    case lecture
    case vocational
    
    var viewText: String {
        switch self {
        case .oneToOne:     return "debug_onetoone".ag_localized()
        case .small:        return "debug_small".ag_localized()
        case .lecture:      return "debug_lecture".ag_localized()
        case .vocational:   return "debug_vocational_lecture".ag_localized()
        }
    }
    
    var edu: AgoraEduRoomType {
        switch self {
        case .oneToOne:     return .oneToOne
        case .small:        return .small
        case .lecture:      return .lecture
        case .vocational:   return .vocational
        }
    }
}

enum DataSourceServiceType: DataSourceOptionProtocol, CaseIterable {
    case livePremium
    case liveStandard
    case cdn
    case fusion
    case mixStreamCDN
    case hostingScene
    
    var viewText: String {
        switch self {
        case .livePremium:  return "debug_service_rtc".ag_localized()
        case .liveStandard: return "debug_service_fast_rtc".ag_localized()
        case .cdn:          return "debug_service_only_cdn".ag_localized()
        case .fusion:       return "debug_service_mixed_cdn".ag_localized()
        case .mixStreamCDN: return "合流转推"
        case .hostingScene: return "伪直播"
        }
    }
    
    var edu: AgoraEduServiceType {
        switch self {
        case .livePremium:  return .livePremium
        case .liveStandard: return .liveStandard
        case .cdn:          return .CDN
        case .fusion:       return .fusion
        case .mixStreamCDN: return .mixStreamCDN
        case .hostingScene: return .hostingScene
        }
    }
}

enum DataSourceRoleType: DataSourceOptionProtocol, CaseIterable {
    case teacher
    case student
    case observer
    
    var viewText: String {
        switch self {
        case .teacher:      return "debug_role_teacher".ag_localized()
        case .student:      return "debug_role_student".ag_localized()
        case .observer:     return "debug_role_observer".ag_localized()
        }
    }
    
    var edu: AgoraEduUserRole {
        switch self {
        case .teacher:      return .teacher
        case .student:      return .student
        case .observer:     return .observer
        }
    }
}

enum DataSourceIMType: DataSourceOptionProtocol {
    case rtm
    case easemob
    
    var viewText: String {
        switch self {
        case .rtm:      return "rtm"
        case .easemob:  return "easemob"
        }
    }
    
    var edu: IMType {
        switch self {
        case .rtm:      return .rtm
        case .easemob:  return .easemob
        }
    }
}

enum DataSourceStartTime {
    case none
    case value(Int64)
}

enum DataSourceDuration {
    case none
    case value(Int64)
}

enum DataSourceDelay {
    case none
    case value(Int64)
}

enum DataSourceEncryptKey {
    case none
    case value(String)
}

enum DataSourceEncryptMode: DataSourceOptionProtocol {
    case none
    case SM4128ECB
    case AES128GCM2
    case AES256GCM2
    
    var viewText: String {
        switch self {
        case .none:         return "None"
        case .SM4128ECB:    return "sm4-128-ecb"
        case .AES128GCM2:   return "aes-128-gcm2"
        case .AES256GCM2:   return "aes-256-gcm2"
        }
    }
    
    var edu: AgoraEduMediaEncryptionMode {
        switch self {
        case .none:         return .none
        case .SM4128ECB:    return .SM4128ECB
        case .AES128GCM2:   return .AES128GCM2
        case .AES256GCM2:   return .AES256GCM2
        }
    }
}

enum DataSourceMediaAuth: DataSourceOptionProtocol {
    case none
    case audio
    case video
    case both
    
    var viewText: String {
        switch self {
        case .none:     return "debug_auth_none".ag_localized()
        case .audio:    return "debug_auth_audio".ag_localized()
        case .video:    return "debug_auth_video".ag_localized()
        case .both:     return "debug_auth_both".ag_localized()
        }
    }
    
    var edu: AgoraEduMediaAuthOption {
        switch self {
        case .none:     return .none
        case .audio:    return .audio
        case .video:    return .video
        case .both:     return .both
        }
    }
}

enum DataSourceUIMode: Int, DataSourceOptionProtocol {
    case light = 0
    case dark = 1
    
    var viewText: String {
        switch self {
        case .light: return "settings_theme_light".ag_localized()
        case .dark:  return "settings_theme_dark".ag_localized()
        }
    }
    
    var edu: AgoraUIMode {
        switch self {
        case .light: return .agoraLight
        case .dark:  return .agoraDark
        }
    }
}

enum DataSourceUILanguage: DataSourceOptionProtocol {
    case zh_cn
    case en
    case zh_tw
    
    var viewText: String {
        switch self {
        case .zh_cn:    return "debug_uiLanguage_zh_cn".ag_localized()
        case .en:       return "debug_uiLanguage_en".ag_localized()
        case .zh_tw:    return "debug_uiLanguage_zh_tw".ag_localized()
        }
    }
    
    var edu: FcrSurpportLanguage {
        switch self {
        case .zh_cn:    return .zh_cn
        case .en:       return .en
        case .zh_tw:    return .zh_tw
        }
    }
}

enum DataSourceRegion:String, DataSourceOptionProtocol {
    case CN
    case NA
    case EU
    case AP
    
    var viewText: String {
        return rawValue
    }
    
    var edu: AgoraEduRegion {
        switch self {
        case .CN:   return .CN
        case .NA:   return .NA
        case .EU:   return .EU
        case .AP:   return .AP
        }
    }
}

enum DataSourceEnvironment: DataSourceOptionProtocol {
    case dev
    case pre
    case pro
    
    var viewText: String {
        switch self {
        case .dev:      return "debug_env_test".ag_localized()
        case .pre:      return "debug_pre_test".ag_localized()
        case .pro:      return "debug_pro_test".ag_localized()
        }
    }
    
    var edu: FcrEnvironment.Environment {
        switch self {
        case .dev:   return .dev
        case .pre:   return .pre
        case .pro:   return .pro
        }
    }
}

// MARK: - main
enum DataSourceType {
    case roomName(DataSourceRoomName)
    case userName(DataSourceUserName)
    case roomType(selected: DataSourceRoomType, list:[DataSourceRoomType])
    case serviceType(DataSourceServiceType)
    case roleType(selected: DataSourceRoleType, list:[DataSourceRoleType])
    case im(DataSourceIMType)
    case startTime(DataSourceStartTime)
    case duration(DataSourceDuration)
    case delay(DataSourceDelay)
    case encryptKey(DataSourceEncryptKey)
    case encryptMode(DataSourceEncryptMode)
    case mediaAuth(DataSourceMediaAuth)
    case uiMode(DataSourceUIMode)
    case uiLanguage(DataSourceUILanguage)
    case region(DataSourceRegion)
    case environment(DataSourceEnvironment)
    
    // TODO: language text
    var title: String {
        switch self {
        case .roomName:      return "debug_room_title".ag_localized()
        case .userName:      return "debug_user_title".ag_localized()
        case .roomType:      return "debug_class_type_title".ag_localized()
        case .serviceType:   return "debug_class_service_type_title".ag_localized()
        case .roleType:      return "debug_title_role".ag_localized()
        case .im:            return "IM"
        case .startTime:     return "debug_startTime_title".ag_localized()
        case .duration:      return "debug_duration_title".ag_localized()
        case .delay:         return "debug_delay_title".ag_localized()
        case .encryptKey:    return "debug_encryptKey_title".ag_localized()
        case .encryptMode:   return "debug_encryption_mode_title".ag_localized()
        case .mediaAuth:     return "debug_authMedia_title".ag_localized()
        case .uiMode:        return "debug_uiMode_title".ag_localized()
        case .uiLanguage:    return "debug_uiLanguage_title".ag_localized()
        case .region:        return "debug_region_title".ag_localized()
        case .environment:   return "debug_env_title".ag_localized()
        }
    }
    
    var placeholder: String {
        switch self {
        case .roomName:      return "debug_room_holder".ag_localized()
        case .userName:      return "debug_user_holder".ag_localized()
        case .roomType:      return "debug_type_holder".ag_localized()
        case .serviceType:   return "debug_service_type_holder".ag_localized()
        case .roleType:      return "debug_role_holder".ag_localized()
        case .im:            return "debug_service_type_holder".ag_localized()
        case .startTime:     return ""
        case .duration:      return "debug_duration_holder".ag_localized()
        case .delay:         return "debug_delay_holder".ag_localized()
        case .encryptKey:    return "debug_encryptKey_holder".ag_localized()
        case .encryptMode:   return "debug_encryption_mode_holder".ag_localized()
        case .mediaAuth:     return "debug_authMedia_holder".ag_localized()
        case .uiMode:        return "debug_uiMode_holder".ag_localized()
        case .uiLanguage:    return "debug_region_holder".ag_localized()
        case .region:        return "debug_region_title".ag_localized()
        case .environment:   return "debug_env_holder".ag_localized()
        }
    }
}

// MARK: - view models
enum DebugInfoCellType {
    case text(placeholder: String,
              text: String?)
    case option(options: [String],
                placeholder: String,
                text: String?)
    case time
    case show(placeholder: String?)
}

struct DebugInfoCellModel {
    var title: String
    var type: DebugInfoCellType
}

// MARK: - launch
/** 入参模型*/
struct LaunchInfoModel {
    var roomName: String
    var userName: String
    var roomStyle: AgoraEduRoomType
    var serviceType: AgoraEduServiceType
    var roleType: AgoraEduUserRole
    var im: IMType
    var duration: Int?
    var delay: Int?
    var encryptKey: String?
    var encryptMode: AgoraEduMediaEncryptionMode
    
    var startTime: NSNumber?
    
    var mediaAuth: AgoraEduMediaAuthOption
    var region: AgoraEduRegion
    var uiMode: AgoraUIMode
    var uiLanguage: FcrSurpportLanguage
    var environment: FcrEnvironment.Environment
    
    func publicCoursewares() -> Array<String> {
        let publicJson1 = """
        {
            "resourceUuid": "9196d03d87ab1e56933f911eafe760c3",
            "resourceName": "AgoraFlexibleClassroomE.pptx",
            "ext": "pptx",
            "size": 10914841,
            "url": "https://agora-adc-artifacts.oss-cn-beijing.aliyuncs.com/cloud-disk/f488493d1886435f963dfb3d95984fd4/jasoncai4/9196d03d87ab1e56933f911eafe760c3.pptx",
            "updateTime": 1641805816941,
            "taskUuid": "203197d071f511ecb84859b705e54fae",
            "conversion": {
                "type": "dynamic",
                "preview": true,
                "scale": 2,
                "outputFormat": "png"
            },
            "taskProgress": {
                "status": "Finished",
                "totalPageSize": 24,
                "convertedPageSize": 24,
                "convertedPercentage": 100,
                "currentStep": "Packaging",
                "convertedFileList": [({
                    "ppt": {
                        "width": 1280,
                        "height": 720,
                        "preview": "https://convertcdn.netless.link/dynamicConvert/203197d071f511ecb84859b705e54fae/preview/1.png",
                        "src": "pptx://convertcdn.netless.link/dynamicConvert/203197d071f511ecb84859b705e54fae/1.slide"
                    },
                    "name": "1"
                }, {
                    "ppt": {
                        "width": 1280,
                        "height": 720,
                        "preview": "https://convertcdn.netless.link/dynamicConvert/203197d071f511ecb84859b705e54fae/preview/2.png",
                        "src": "pptx://convertcdn.netless.link/dynamicConvert/203197d071f511ecb84859b705e54fae/2.slide"
                    },
                    "name": "2"
                }, {
                    "ppt": {
                        "width": 1280,
                        "height": 720,
                        "preview": "https://convertcdn.netless.link/dynamicConvert/203197d071f511ecb84859b705e54fae/preview/3.png",
                        "src": "pptx://convertcdn.netless.link/dynamicConvert/203197d071f511ecb84859b705e54fae/3.slide"
                    },
                    "name": "3"
                }, {
                    "ppt": {
                        "width": 1280,
                        "height": 720,
                        "preview": "https://convertcdn.netless.link/dynamicConvert/203197d071f511ecb84859b705e54fae/preview/4.png",
                        "src": "pptx://convertcdn.netless.link/dynamicConvert/203197d071f511ecb84859b705e54fae/4.slide"
                    },
                    "name": "4"
                }, {
                    "ppt": {
                        "width": 1280,
                        "height": 720,
                        "preview": "https://convertcdn.netless.link/dynamicConvert/203197d071f511ecb84859b705e54fae/preview/5.png",
                        "src": "pptx://convertcdn.netless.link/dynamicConvert/203197d071f511ecb84859b705e54fae/5.slide"
                    },
                    "name": "5"
                }, {
                    "ppt": {
                        "width": 1280,
                        "height": 720,
                        "preview": "https://convertcdn.netless.link/dynamicConvert/203197d071f511ecb84859b705e54fae/preview/6.png",
                        "src": "pptx://convertcdn.netless.link/dynamicConvert/203197d071f511ecb84859b705e54fae/6.slide"
                    },
                    "name": "6"
                }, {
                    "ppt": {
                        "width": 1280,
                        "height": 720,
                        "preview": "https://convertcdn.netless.link/dynamicConvert/203197d071f511ecb84859b705e54fae/preview/7.png",
                        "src": "pptx://convertcdn.netless.link/dynamicConvert/203197d071f511ecb84859b705e54fae/7.slide"
                    },
                    "name": "7"
                }, {
                    "ppt": {
                        "width": 1280,
                        "height": 720,
                        "preview": "https://convertcdn.netless.link/dynamicConvert/203197d071f511ecb84859b705e54fae/preview/8.png",
                        "src": "pptx://convertcdn.netless.link/dynamicConvert/203197d071f511ecb84859b705e54fae/8.slide"
                    },
                    "name": "8"
                }, {
                    "ppt": {
                        "width": 1280,
                        "height": 720,
                        "preview": "https://convertcdn.netless.link/dynamicConvert/203197d071f511ecb84859b705e54fae/preview/9.png",
                        "src": "pptx://convertcdn.netless.link/dynamicConvert/203197d071f511ecb84859b705e54fae/9.slide"
                    },
                    "name": "9"
                }, {
                    "ppt": {
                        "width": 1280,
                        "height": 720,
                        "preview": "https://convertcdn.netless.link/dynamicConvert/203197d071f511ecb84859b705e54fae/preview/10.png",
                        "src": "pptx://convertcdn.netless.link/dynamicConvert/203197d071f511ecb84859b705e54fae/10.slide"
                    },
                    "name": "10"
                }, {
                    "ppt": {
                        "width": 1280,
                        "height": 720,
                        "preview": "https://convertcdn.netless.link/dynamicConvert/203197d071f511ecb84859b705e54fae/preview/11.png",
                        "src": "pptx://convertcdn.netless.link/dynamicConvert/203197d071f511ecb84859b705e54fae/11.slide"
                    },
                    "name": "11"
                }, {
                    "ppt": {
                        "width": 1280,
                        "height": 720,
                        "preview": "https://convertcdn.netless.link/dynamicConvert/203197d071f511ecb84859b705e54fae/preview/12.png",
                        "src": "pptx://convertcdn.netless.link/dynamicConvert/203197d071f511ecb84859b705e54fae/12.slide"
                    },
                    "name": "12"
                }, {
                    "ppt": {
                        "width": 1280,
                        "height": 720,
                        "preview": "https://convertcdn.netless.link/dynamicConvert/203197d071f511ecb84859b705e54fae/preview/13.png",
                        "src": "pptx://convertcdn.netless.link/dynamicConvert/203197d071f511ecb84859b705e54fae/13.slide"
                    },
                    "name": "13"
                }, {
                    "ppt": {
                        "width": 1280,
                        "height": 720,
                        "preview": "https://convertcdn.netless.link/dynamicConvert/203197d071f511ecb84859b705e54fae/preview/14.png",
                        "src": "pptx://convertcdn.netless.link/dynamicConvert/203197d071f511ecb84859b705e54fae/14.slide"
                    },
                    "name": "14"
                }, {
                    "ppt": {
                        "width": 1280,
                        "height": 720,
                        "preview": "https://convertcdn.netless.link/dynamicConvert/203197d071f511ecb84859b705e54fae/preview/15.png",
                        "src": "pptx://convertcdn.netless.link/dynamicConvert/203197d071f511ecb84859b705e54fae/15.slide"
                    },
                    "name": "15"
                }, {
                    "ppt": {
                        "width": 1280,
                        "height": 720,
                        "preview": "https://convertcdn.netless.link/dynamicConvert/203197d071f511ecb84859b705e54fae/preview/16.png",
                        "src": "pptx://convertcdn.netless.link/dynamicConvert/203197d071f511ecb84859b705e54fae/16.slide"
                    },
                    "name": "16"
                }, {
                    "ppt": {
                        "width": 1280,
                        "height": 720,
                        "preview": "https://convertcdn.netless.link/dynamicConvert/203197d071f511ecb84859b705e54fae/preview/17.png",
                        "src": "pptx://convertcdn.netless.link/dynamicConvert/203197d071f511ecb84859b705e54fae/17.slide"
                    },
                    "name": "17"
                }, {
                    "ppt": {
                        "width": 1280,
                        "height": 720,
                        "preview": "https://convertcdn.netless.link/dynamicConvert/203197d071f511ecb84859b705e54fae/preview/18.png",
                        "src": "pptx://convertcdn.netless.link/dynamicConvert/203197d071f511ecb84859b705e54fae/18.slide"
                    },
                    "name": "18"
                }, {
                    "ppt": {
                        "width": 1280,
                        "height": 720,
                        "preview": "https://convertcdn.netless.link/dynamicConvert/203197d071f511ecb84859b705e54fae/preview/19.png",
                        "src": "pptx://convertcdn.netless.link/dynamicConvert/203197d071f511ecb84859b705e54fae/19.slide"
                    },
                    "name": "19"
                }, {
                    "ppt": {
                        "width": 1280,
                        "height": 720,
                        "preview": "https://convertcdn.netless.link/dynamicConvert/203197d071f511ecb84859b705e54fae/preview/20.png",
                        "src": "pptx://convertcdn.netless.link/dynamicConvert/203197d071f511ecb84859b705e54fae/20.slide"
                    },
                    "name": "20"
                }, {
                    "ppt": {
                        "width": 1280,
                        "height": 720,
                        "preview": "https://convertcdn.netless.link/dynamicConvert/203197d071f511ecb84859b705e54fae/preview/21.png",
                        "src": "pptx://convertcdn.netless.link/dynamicConvert/203197d071f511ecb84859b705e54fae/21.slide"
                    },
                    "name": "21"
                }, {
                    "ppt": {
                        "width": 1280,
                        "height": 720,
                        "preview": "https://convertcdn.netless.link/dynamicConvert/203197d071f511ecb84859b705e54fae/preview/22.png",
                        "src": "pptx://convertcdn.netless.link/dynamicConvert/203197d071f511ecb84859b705e54fae/22.slide"
                    },
                    "name": "22"
                }, {
                    "ppt": {
                        "width": 1280,
                        "height": 720,
                        "preview": "https://convertcdn.netless.link/dynamicConvert/203197d071f511ecb84859b705e54fae/preview/23.png",
                        "src": "pptx://convertcdn.netless.link/dynamicConvert/203197d071f511ecb84859b705e54fae/23.slide"
                    },
                    "name": "23"
                }, {
                    "ppt": {
                        "width": 1280,
                        "height": 720,
                        "preview": "https://convertcdn.netless.link/dynamicConvert/203197d071f511ecb84859b705e54fae/preview/24.png",
                        "src": "pptx://convertcdn.netless.link/dynamicConvert/203197d071f511ecb84859b705e54fae/24.slide"
                    },
                    "name": "24"
                }]
            }
        }
        """
        let publicJson2 = """
            {
                "resourceUuid":"20c2281deddefa96a97fe16b3628b456",
                "resourceName":"Agora Flexible Classroom v2.1 Demo Instructions.pptx",
                "ext":"pptx",
                "size":8478024,
                "url":"https://agora-adc-artifacts.oss-accelerate.aliyuncs.com/scenario/cloud-disk/47b7535dcb9a4bb4aa592115266eae98/jasoncai4/20c2281deddefa96a97fe16b3628b456.pptx",
                "updateTime":1645759841545,
                "taskUuid":"36b372508efe11ecb24daf1de36fc2eb",
                "taskToken":"NETLESSTASK_YWs9MU53eWgwbDFvWWs4WkVjbmRtZGloMHJiY1VlbEJxNVJKTzFTJm5vbmNlPTE2NDQ5OTgzMDMzOTgwMCZyb2xlPTAmc2lnPTFiZDUzZjc4MGZkOGJlMjkyMDcwMDE2MzZkZWE0YmU4NGVlMDZmZTRhMmQ1ODRkMGJmNGQyZTdmZDMzOWNiNGUmdXVpZD0zNmIzNzI1MDhlZmUxMWVjYjI0ZGFmMWRlMzZmYzJlYg",
                "conversion":{
                    "type":"dynamic",
                    "preview":true,
                    "scale":1.2,
                    "outputFormat":"png",
                    "canvasVersion":true
                },
                "taskProgress":{
                    "status":"Finished",
                    "totalPageSize":14,
                    "convertedPageSize":14,
                    "convertedPercentage":100,
                    "convertedFileList":[
                                         {
                        "ppt":{
                            "width":1280,
                            "height":720,
                            "preview":"https://convertcdn.netless.link/dynamicConvert/36b372508efe11ecb24daf1de36fc2eb/preview/1.png",
                            "src":"pptx://convertcdn.netless.link/dynamicConvert/36b372508efe11ecb24daf1de36fc2eb/1.slide"
                        },
                        "name":"1"
                    },
                                         {
                        "ppt":{
                            "width":1280,
                            "height":720,
                            "preview":"https://convertcdn.netless.link/dynamicConvert/36b372508efe11ecb24daf1de36fc2eb/preview/2.png",
                            "src":"pptx://convertcdn.netless.link/dynamicConvert/36b372508efe11ecb24daf1de36fc2eb/2.slide"
                        },
                        "name":"2"
                    },
                                         {
                        "ppt":{
                            "width":1280,
                            "height":720,
                            "preview":"https://convertcdn.netless.link/dynamicConvert/36b372508efe11ecb24daf1de36fc2eb/preview/3.png",
                            "src":"pptx://convertcdn.netless.link/dynamicConvert/36b372508efe11ecb24daf1de36fc2eb/3.slide"
                        },
                        "name":"3"
                    },
                                         {
                        "ppt":{
                            "width":1280,
                            "height":720,
                            "preview":"https://convertcdn.netless.link/dynamicConvert/36b372508efe11ecb24daf1de36fc2eb/preview/4.png",
                            "src":"pptx://convertcdn.netless.link/dynamicConvert/36b372508efe11ecb24daf1de36fc2eb/4.slide"
                        },
                        "name":"4"
                    },
                                         {
                        "ppt":{
                            "width":1280,
                            "height":720,
                            "preview":"https://convertcdn.netless.link/dynamicConvert/36b372508efe11ecb24daf1de36fc2eb/preview/5.png",
                            "src":"pptx://convertcdn.netless.link/dynamicConvert/36b372508efe11ecb24daf1de36fc2eb/5.slide"
                        },
                        "name":"5"
                    },
                                         {
                        "ppt":{
                            "width":1280,
                            "height":720,
                            "preview":"https://convertcdn.netless.link/dynamicConvert/36b372508efe11ecb24daf1de36fc2eb/preview/6.png",
                            "src":"pptx://convertcdn.netless.link/dynamicConvert/36b372508efe11ecb24daf1de36fc2eb/6.slide"
                        },
                        "name":"6"
                    },
                                         {
                        "ppt":{
                            "width":1280,
                            "height":720,
                            "preview":"https://convertcdn.netless.link/dynamicConvert/36b372508efe11ecb24daf1de36fc2eb/preview/7.png",
                            "src":"pptx://convertcdn.netless.link/dynamicConvert/36b372508efe11ecb24daf1de36fc2eb/7.slide"
                        },
                        "name":"7"
                    },
                                         {
                        "ppt":{
                            "width":1280,
                            "height":720,
                            "preview":"https://convertcdn.netless.link/dynamicConvert/36b372508efe11ecb24daf1de36fc2eb/preview/8.png",
                            "src":"pptx://convertcdn.netless.link/dynamicConvert/36b372508efe11ecb24daf1de36fc2eb/8.slide"
                        },
                        "name":"8"
                    },
                                         {
                        "ppt":{
                            "width":1280,
                            "height":720,
                            "preview":"https://convertcdn.netless.link/dynamicConvert/36b372508efe11ecb24daf1de36fc2eb/preview/9.png",
                            "src":"pptx://convertcdn.netless.link/dynamicConvert/36b372508efe11ecb24daf1de36fc2eb/9.slide"
                        },
                        "name":"9"
                    },
                                         {
                        "ppt":{
                            "width":1280,
                            "height":720,
                            "preview":"https://convertcdn.netless.link/dynamicConvert/36b372508efe11ecb24daf1de36fc2eb/preview/10.png",
                            "src":"pptx://convertcdn.netless.link/dynamicConvert/36b372508efe11ecb24daf1de36fc2eb/10.slide"
                        },
                        "name":"10"
                    },
                                         {
                        "ppt":{
                            "width":1280,
                            "height":720,
                            "preview":"https://convertcdn.netless.link/dynamicConvert/36b372508efe11ecb24daf1de36fc2eb/preview/11.png",
                            "src":"pptx://convertcdn.netless.link/dynamicConvert/36b372508efe11ecb24daf1de36fc2eb/11.slide"
                        },
                        "name":"11"
                    },
                                         {
                        "ppt":{
                            "width":1280,
                            "height":720,
                            "preview":"https://convertcdn.netless.link/dynamicConvert/36b372508efe11ecb24daf1de36fc2eb/preview/12.png",
                            "src":"pptx://convertcdn.netless.link/dynamicConvert/36b372508efe11ecb24daf1de36fc2eb/12.slide"
                        },
                        "name":"12"
                    },
                                         {
                        "ppt":{
                            "width":1280,
                            "height":720,
                            "preview":"https://convertcdn.netless.link/dynamicConvert/36b372508efe11ecb24daf1de36fc2eb/preview/13.png",
                            "src":"pptx://convertcdn.netless.link/dynamicConvert/36b372508efe11ecb24daf1de36fc2eb/13.slide"
                        },
                        "name":"13"
                    },
                                         {
                        "ppt":{
                            "width":1280,
                            "height":720,
                            "preview":"https://convertcdn.netless.link/dynamicConvert/36b372508efe11ecb24daf1de36fc2eb/preview/14.png",
                            "src":"pptx://convertcdn.netless.link/dynamicConvert/36b372508efe11ecb24daf1de36fc2eb/14.slide"
                        },
                        "name":"14"
                    }
                                         ],
                    "currentStep":"Packaging",
                    "prefix":"https://convertcdn.netless.link/dynamicConvert"
                }
            }
            """
        return [publicJson1, publicJson2]
    }
}
