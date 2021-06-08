//
//  AgoraDownloadManager.swift
//  AgoraEduSDK
//
//  Created by SRS on 2021/2/9.
//

import Foundation
import AFNetworking
import AgoraLog
import EduSDK

@objc public protocol AgoraDownloadProtocol: NSObjectProtocol {
    func onProcessChanged(_ key: String?,
                          url: URL,
                          process: Float)
    
    func onDownloadCompleted(_ key: String?,
                             urls: [URL],
                             error: Error?,
                             errorCode: Int)
}

@objcMembers public class AgoraDownloadManager: NSObject {
    
    public typealias DownloadSuccessBlock = () -> Void
    public typealias DowningProgress = (_ progress: Float) -> Void
    public typealias DownloadFailBlock = (_ error: Error, _ statusCode: Int) -> Void
    
    public static let shared = AgoraDownloadManager()
    
    fileprivate var downLoadHistory: NSMutableDictionary = NSMutableDictionary()
    fileprivate var agoraFileDirectory: String = ""
    fileprivate var agoraFilePath: String = ""
    
    fileprivate var urls: [URL]?
    fileprivate var fileDirectory: String = ""
    fileprivate var delegates: NSHashTable = NSHashTable<AgoraDownloadProtocol>(options: .weakMemory)
    
    fileprivate var manager: AFURLSessionManager!

    fileprivate override init() {
        super.init()
        self.initDownLoadManager()
        self.initDownLoadHistory()
    }
    
    func reDownload(delegate: AgoraDownloadProtocol?) {
        guard let urls = self.urls else {
            return
        }
        
        self.download(urls: urls,
                      fileDirectory: self.fileDirectory,
                      delegate: delegate)
    }
    
    func reDownload(urls: [URL],
                    delegate: AgoraDownloadProtocol?) {
        self.urls = urls
        
        self.download(urls: urls,
                      fileDirectory: self.fileDirectory,
                      delegate: delegate)
    }
    
    func configProtocol(_ delegate: AgoraDownloadProtocol) {
        if !delegates.contains(delegate) {
            self.delegates.add(delegate)
        }
    }
    
    public func download(urls: [URL],
                         fileDirectory: String,
                         key: String? = nil,
                         delegate: AgoraDownloadProtocol? = nil) {

        if let `delegate` = delegate {
            self.configProtocol(delegate)
        }
        
        self.urls = urls
        self.fileDirectory = fileDirectory

        let group = DispatchGroup()
       
        var error: Error?
        var errorCode: Int = 0
        var progressDictionary: [Int: Float] = [Int: Float]()
        var totalProgress: Float = 0
        
        for url in urls {
            group.enter()
            
            let progress: DowningProgress = { [weak self] (downloadProgress) in
                guard let `self` = self else {
                    return
                }
                
                let hashValue = url.absoluteString.hashValue
                progressDictionary[hashValue] = downloadProgress
                
                var sum: Float = 0
                for url in urls {
                    let hashValue = url.absoluteString.hashValue
                    sum += (progressDictionary[hashValue] ?? 0.0)
                }
                
                AgoraRTELogService.logMessage("progressDictionary==>\(progressDictionary)",
                                              level: .info)
                
                if (totalProgress > sum / Float(urls.count)) {
                    assert(false, "self.totleProgress < sum / Float(urls.count)")
                }
                
                totalProgress = sum / Float(urls.count)
                self.callbackOnProcessChanged(key: key,
                                              url: url,
                                              process: totalProgress)
                
            }
            
            self.download(url: url,
                          fileDirectory: fileDirectory,
                          progress: progress) {
                group.leave()
            } failure: { (err, code) in
                error = err
                errorCode = code
                group.leave()
            }
        }

        group.notify(queue: DispatchQueue.main) { [unowned self] in
            self.callbackOnDownloadCompleted(key: key,
                                             urls: urls,
                                             error: error,
                                             errorCode: errorCode)
        }
    }
    
    @discardableResult fileprivate func download(url: URL,
                                                 fileDirectory: String,
                                                 progress: @escaping DowningProgress,
                                                 success: @escaping DownloadSuccessBlock,
                                                 failure: @escaping DownloadFailBlock) -> URLSessionDownloadTask? {
        
        var `fileDirectory` = fileDirectory
        let path = url.path.replacingOccurrences(of: url.lastPathComponent, with: "")
        if (path != "/") {
            if fileDirectory.last == "/" {
                fileDirectory.removeLast()
            }
            fileDirectory = fileDirectory + path
        }
         
        let isExist = FileManager.default.fileExists(atPath: fileDirectory)
        
        if !isExist {
            try? FileManager.default.createDirectory(atPath: fileDirectory,
                                                    withIntermediateDirectories: true,
                                                    attributes: nil)
        }
        
        var fileLocalPath = fileDirectory + url.lastPathComponent
        if fileDirectory.last != "/" {
            fileLocalPath = fileDirectory + "/" +  url.lastPathComponent
        }
        
//        // 拼接文件名路径， 现在解压后， 直接是解压内容到这个文件夹中
//        if let fileName = url.lastPathComponent.components(separatedBy: ".").first {
//            if fileDirectory.last != "/" {
//                fileDirectory = fileDirectory + "/"
//            }
//            fileDirectory = fileDirectory + fileName
//        }
        
        if let _ = self.fileExists(fileLocalPath) {
            success()
            return nil
        }
        
        let request = URLRequest(url: url)
        var downloadTask: URLSessionDownloadTask?
        let downLoadHistoryData: Data = (self.downLoadHistory[url.absoluteString] ?? Data()) as! Data
        if downLoadHistoryData.count == 0 {
            downloadTask = self.manager!.downloadTask(with: request, progress: { (downloadProgress) in
                progress(1.0 * Float(downloadProgress.completedUnitCount) / Float(downloadProgress.totalUnitCount))
                
            }, destination: { (targetURL, response) -> URL in
                return URL(fileURLWithPath: fileLocalPath)
                
            }, completionHandler: {[weak self] (response, fileURL, error) in
                if let httpResponse = response as? HTTPURLResponse {
                    if httpResponse.statusCode == 404 && fileURL != nil {
                        try? FileManager.default.removeItem(at: fileURL!)
                    }
                    
                    if error != nil {
                        failure(error!, httpResponse.statusCode)
                    } else {
                        self?.unZip(fileDirectory, fileLocalPath)
                        success()
                    }
                }
            })
            
        } else {
            downloadTask = self.manager?.downloadTask(withResumeData: downLoadHistoryData, progress: { (downloadProgress) in
                progress(1.0 * Float(downloadProgress.completedUnitCount) / Float(downloadProgress.totalUnitCount))
                
            }, destination: { (targetURL, response) -> URL in
                return URL(fileURLWithPath: fileLocalPath)
                
            }, completionHandler: {[weak self] (response, fileURL, error) in
                if let httpResponse = response as? HTTPURLResponse {
                    if httpResponse.statusCode == 404 && fileURL != nil {
                        try? FileManager.default.removeItem(at: fileURL!)
                    }
                    
                    if error != nil {
                        failure(error!, httpResponse.statusCode)
                    } else {
                        self?.unZip(fileDirectory, fileLocalPath)
                        success()
                    }
                }
            })
        }
        downloadTask?.resume()
        return downloadTask!
    }
    
    public func stopTask(url: String) {
        guard let tasks = self.manager?.downloadTasks,
              tasks.count > 0 else {
            return
        }
        
        for task in tasks where task.state == .running {
            // TODO: 之后要检查这里，是 currentRequest 里的 url 还是 originalRequest 里的 url
            guard let tURL = task.currentRequest?.url?.absoluteString else {
                return
            }
            
            if tURL == url {
                task.cancel()
                break
            }
        }
    }
    
    public func stopAllTasks() {
        guard let tasks = self.manager?.downloadTasks,
              tasks.count > 0 else {
            return
        }
        
        for task in tasks where task.state == .running {
            task.cancel()
        }
    }
}

fileprivate extension AgoraDownloadManager {
    func callbackOnProcessChanged(key: String?,
                                  url: URL,
                                  process: Float) {
        let list: [AgoraDownloadProtocol] = self.delegates.allObjects
        DispatchQueue.main.async {
            for delegate in list {
                delegate.onProcessChanged(key,
                                          url: url,
                                          process: process)
            }
        }
    }
    
    func callbackOnDownloadCompleted(key: String?,
                                     urls: [URL],
                                     error: Error?,
                                     errorCode: Int) {
        let list: [AgoraDownloadProtocol] = self.delegates.allObjects
        DispatchQueue.main.async {
            for delegate in list {
                delegate.onDownloadCompleted(key,
                                             urls: urls,
                                             error: error,
                                             errorCode: errorCode)
            }
        }
    }
}

fileprivate extension AgoraDownloadManager {
    func fileExists(_ fileLocalPath: String) -> URL? {
        
        var unZipPath = fileLocalPath
        if fileLocalPath.hasSuffix(".zip") {
            unZipPath = fileLocalPath.replacingOccurrences(of: ".zip",
                                                           with: "")
        }
        
        if (FileManager.default.fileExists(atPath: unZipPath)) {
            return URL(fileURLWithPath: unZipPath)
        }
        
        return nil
    }
    
    func unZip(_ fileDirectory: String,
               _ fileLocalPath: String) {
        SSZipArchive.unzipFile(atPath: fileLocalPath,
                               toDestination: fileDirectory)
        let url = URL(fileURLWithPath: fileLocalPath)
        try? FileManager.default.removeItem(at: url)
    }
    
    func saveHistory(key: String,
                     data: Data?) {
        if let `data` = data {
            self.downLoadHistory[key] = data
        } else {
            self.downLoadHistory[key] = Data()
        }
    
        self.saveToFile()
    }
    
    func clearHistory(key: String) {
        if (self.downLoadHistory.object(forKey: key) != nil) {
            self.downLoadHistory.removeObject(forKey: key)
            self.saveToFile(true)
        }
    }
    
    func saveToFile(_ atomically: Bool = false) {
        self.downLoadHistory.write(toFile: self.agoraFilePath,
                                   atomically: atomically)
    }
    
    func initDownLoadManager() {
        let configuration = URLSessionConfiguration.background(withIdentifier: "io.agora.edu")
        configuration.httpMaximumConnectionsPerHost = 5
        configuration.timeoutIntervalForRequest = 30
        configuration.allowsCellularAccess = true
        
        self.manager = AFURLSessionManager(sessionConfiguration: configuration)
        
        self.manager?.setTaskDidComplete {[weak self] (session, task, error) in
            guard let strongSelf = self else {
                return
            }
            
            guard let urlString = task.currentRequest?.url?.absoluteString else {
                return
            }
            
            if let tError = error  {
                let nsError = tError as NSError
                let resumeData = nsError.userInfo["NSURLSessionDownloadTaskResumeData"] as? Data
                strongSelf.saveHistory(key: urlString,
                                  data: resumeData)
            } else {
                strongSelf.clearHistory(key: urlString)
            }
        }
    }
    
    func initDownLoadHistory() {
        let basePath = NSSearchPathForDirectoriesInDomains(.cachesDirectory,
                                                           .userDomainMask, true)[0]
        
        self.agoraFileDirectory = "\(basePath)/AgoraDownload/"
        
        var isExist = FileManager.default.fileExists(atPath: self.agoraFileDirectory)
        
        if !isExist {
            try? FileManager.default.createDirectory(atPath: self.agoraFileDirectory,
                                                    withIntermediateDirectories: true,
                                                    attributes: nil)
        }
        
        self.agoraFilePath = "\(fileDirectory)/downLoadHistory.plist"
        
        isExist = FileManager.default.fileExists(atPath: self.agoraFilePath)
        
        if !isExist {
            self.downLoadHistory = NSMutableDictionary()
            self.saveToFile()
        } else {
            self.downLoadHistory = NSMutableDictionary(contentsOfFile: self.agoraFilePath) ?? NSMutableDictionary()
        }
    }
}
