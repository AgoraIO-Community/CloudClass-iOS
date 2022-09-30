//
//  RoomItemModel.swift
//  AgoraEducation
//
//  Created by Jonathan on 2022/9/9.
//  Copyright © 2022 Agora. All rights reserved.
//

import Foundation
#if canImport(AgoraClassroomSDK_iOS)
import AgoraClassroomSDK_iOS
#else
import AgoraClassroomSDK
#endif
import AgoraProctorSDK

class RoomInputInfoModel {
    var userName: String?
    var roomName: String?
    var roomId: String?
    /** 1. 老师， 2. 学生*/
    var roleType: Int = 2
    var roomType: Int = 0
    var appId: String?
    var token: String?
    var serviceType: AgoraEduServiceType?
    
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
                "convertedFileList": [{
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

struct RoomItemModel {
    let roomName: String
    let roomId: String
    let roomType: UInt
    let roomState: UInt
    let startTime: UInt
    let endTime: UInt
    let creatorId: String
    let roomProperties: [String: Any]?
    
    static func modelWith(dict: [String: Any]) -> RoomItemModel? {
        guard let roomName = dict["roomName"] as? String,
              let roomId = dict["roomId"] as? String,
              let roomType = dict["roomType"] as? UInt,
              let roomState = dict["roomState"] as? UInt,
              let startTime = dict["startTime"] as? UInt,
              let endTime = dict["endTime"] as? UInt,
              let creatorId = dict["creatorId"] as? String
        else {
            return nil
        }
        let roomProperties = dict["roomProperties"] as? [String: Any]
        let model = RoomItemModel(roomName: roomName,
                                  roomId: roomId,
                                  roomType: roomType,
                                  roomState: roomState,
                                  startTime: startTime,
                                  endTime: endTime,
                                  creatorId: creatorId,
                                  roomProperties: roomProperties)
        return model
    }
    
    static func arrayWithDataList(_ list: [Dictionary<String, Any>]) -> [RoomItemModel] {
        var ary = [RoomItemModel]()
        for item in list {
            guard let model = modelWith(dict: item) else {
                continue
            }
            ary.append(model)
        }
        return ary
    }
}
