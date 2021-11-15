//
//  CloudServerApi.swift
//  AgoraWidgets
//
//  Created by ZYP on 2021/10/21.
//

import Armin

class CloudServerApi: NSObject {
    typealias FailBlock = (Error) -> ()
    typealias SuccessBlock<T: Decodable> = (Resp<T>) -> ()
    
    private var config: Config!
    private var armin: Armin!
    
    init(config: Config) {
        super.init()
        self.config = config
        self.armin = Armin(delegate: self,
                           logTube: self)
    }
    
    func requestResourceInUser(pageNo: Int,
                               pageSize: Int,
                               success: @escaping SuccessBlock<SourceDataInUserPage>,
                               fail: @escaping FailBlock) {
        let path = "/edu/apps/\(config.appId)/v2/users/\(config.uid)/resources/page"
        let urlString = config.hostUrlString + path
        
        let event = ArRequestEvent(name: "CloudServerApi")
        let type = ArRequestType.http(.get,
                                      url: urlString)
        let header = ["x-agora-token" : config.token,
                      "x-agora-uid" : config.uid]
        let parameters: [String : Any] = ["pageNo" : pageNo,
                                          "pageSize" : pageSize,
                                          "orderBy" : "updateTime"]
        let task = ArRequestTask(event: event,
                                 type: type,
                                 header: header,
                                 parameters: parameters)
        
        armin.request(task: task,
                      responseOnMainQueue: true,
                      success: .data({ data in
            let decoder = JSONDecoder()
            do {
                let resp = try decoder.decode(Resp<SourceDataInUserPage>.self, from: data)
                success(resp)
            } catch let e {
                print(e)
                fail(e)
            }
            
        }), failRetry: { error in
            fail(error)
            return .resign
        })
    }
}

extension CloudServerApi: ArminDelegate {
    func armin(_ client: Armin,
               requestSuccess event: ArRequestEvent,
               startTime: TimeInterval,
               url: String) {
        
    }
    
    func armin(_ client: Armin,
               requestFail error: ArError,
               event: ArRequestEvent,
               url: String) {
        
    }
}

extension CloudServerApi: ArLogTube {
    func log(info: String,
             extra: String?) {
        print("[CloudServerApi] \(extra) - \(info)")
    }
    
    func log(warning: String,
             extra: String?) {
        print("[CloudServerApi] \(extra) - \(warning)")
    }
    
    func log(error: ArError,
             extra: String?) {
        print("[CloudServerApi] \(extra) - \(error.localizedDescription)")
    }
}

extension CloudServerApi {
    struct Resp<T: Decodable>: Decodable {
        let msg: String
        let code: Int
        let ts: Double
        let data: T
    }
    
    struct SourceData: Decodable {
        let total: Int
        let list: [FileItem]
        let nextId: Int?
        let count: Int
    }
    
    struct SourceDataInUserPage: Decodable {
        let total: Int
        let list: [FileItem]
        let pageNo: Int
        let pageSize: Int
        let pages: Int
    }
    
    struct FileItem: Decodable {
        let resourceUuid: String
        let resourceName: String
        let ext: String
        let size: Double
        let url: String
        let tags: [String]?
        let updateTime: TimeInterval
        /// 是否转换
        let convert: Bool?
        let taskUuid: String
        let taskToken: String
        let taskProgress: TaskProgress
    }
    
    struct TaskProgress: Decodable {
        let totalPageSize: Int
        let convertedPageSize: Int
        let convertedPercentage: Int
        let convertedFileList: [ConvertedFile]
        let currentStep: String?
    }
    
    struct ConvertedFile: Decodable {
        let name: String
        let ppt: PowerPoint
    }
    
    struct PowerPoint: Decodable {
        let width: Float
        let height: Float
        let src: String
        let preview: String?
    }
}

extension CloudServerApi {
    struct Config {
        let token: String
        let uid: String
        let appId: String
        let hostUrlString: String
    }
}
