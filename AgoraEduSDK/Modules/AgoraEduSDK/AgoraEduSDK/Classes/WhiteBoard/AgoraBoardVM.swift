//
//  AgoraBoardVM.swift
//  AgoraEduSDK
//
//  Created by SRS on 2021/2/15.
//

import Foundation
import AgoraWhiteBoard
import AgoraReport
import AgoraUIEduBaseViews
import AgoraEduContext

let AgoraWhitePublicZip = "https://convertcdn.netless.link/publicFiles.zip"

protocol AgoraBoardVMDelegate: NSObjectProtocol {
    func didBoardFullScreenMode(_ fullScreen: Bool)
    
    func didBoardLocalPermissionGranted(_ grantUsers: [String])
    func didBoardLocalPermissionRevoked(_ grantUsers: [String]?)
    func didBoardPermissionUpdated(_ grantUsers: [String])
    
    func didBoardPageChange(pageIndex: Int, pageCount: Int)
    func didSceneChange(urls: [URL])
    func didScenePathChanged(path: String)
}

public class AgoraBoardVM: AgoraBaseVM {
    struct BoardPage {
        var index: Int
        var count: Int
    }
    
    fileprivate var boardAppId: String
    fileprivate var userUuid: String
    fileprivate var manager: AgoraWhiteBoardManager
    fileprivate var reportor: AgoraApaasReportorEventTube
    fileprivate var cache: AgoraManagerCache
    
    var boardPage = BoardPage(index: 0,
                              count: 0)
    
    weak var delegate: AgoraBoardVMDelegate?
    
    var boardState = AgoraWhiteBoardStateModel()
    
    @objc public static let WhitePublicZip = AgoraWhitePublicZip

    init(boardAppId: String,
         userUuid: String,
         manager: AgoraWhiteBoardManager,
         reportor: AgoraApaasReportorEventTube,
         cache: AgoraManagerCache,
         delegate: AgoraBoardVMDelegate?) {
        self.boardAppId = boardAppId
        self.userUuid = userUuid
        self.manager = manager
        self.reportor = reportor
        self.cache = cache
        self.delegate = delegate
        
        super.init()
        self.manager.delegate = self
    }
    
    func join(boardId: String,
              boardToken: String,
              success: @escaping () -> Void,
              failure: @escaping (_ error: Error) -> Void) {
        // Report
        let subEvent = "board-join"
        let httpApi = "join"
        reportor.startJoinRoomSubEventNotificate(subEvent: subEvent)
        
        let options = AgoraWhiteBoardJoinOptions()
        options.boardId = boardId
        options.boardToken = boardToken
        
        manager.join(with: options) {[weak self] in
            guard let `self` = self else {
                return
            }
            
            // Report
            self.reportor.endJoinRoomSubEventNotificate(subEvent: subEvent,
                                                        type: .board,
                                                        errorCode: 0,
                                                        httpCode: 200,
                                                        api: httpApi)
            
            self.reportor.endJoinRoomNotificate(errorCode: 0,
                                                httpCode: 200)
            
            let currentBoardState = self.manager.getWhiteBoardStateModel()
            let teacherFirstLogin = currentBoardState.teacherFirstLogin

            // 预加载第一个课件
//            if let courseware = self.cache.coursewares.first,
//               !teacherFirstLogin {
//                self.manager.putScenes(courseware.resourceUuid,
//                                  scenes: courseware.scenes,
//                                  index: 0)
//                self.manager.setScenePath(courseware.scenePath)
//            }
            
            
            let usreGranted = currentBoardState.grantUsers?.contains(self.userUuid) ?? false
            if !usreGranted {
                self.operationPermission(false)
                self.lockViewTransform(true)
            }
            self.onWhiteBoardStateChanged(currentBoardState)

            DispatchQueue.main.async {
                success()
            }
        } failure: { [unowned self] (error) in
            let errorCode = (error as NSError).code
            
            // Report
            self.reportor.endJoinRoomSubEventNotificate(subEvent: subEvent,
                                                   type: .board,
                                                   errorCode: errorCode,
                                                   api: httpApi)

            self.reportor.endJoinRoomNotificate(errorCode: errorCode)
            
            DispatchQueue.main.async {
                failure(error)
            }
        }
    }
    
    func leave() {
        manager.leave(success: nil,
                      failure: nil)
    }
}

// MARK: - Board tools
extension AgoraBoardVM {
    public func applianceSelected(_ mode: AgoraWhiteBoardToolType) {
        manager.setTool(mode)
    }
    
    public func colorSelected(_ color: UIColor) {
        manager.setColor(color)
    }
    
    public func fontSizeSelected(_ size: Int) {
        manager.setTool(.WhiteBoardToolTypeText)
        manager.setTextSize(size)
    }
    
    public func thicknessSelected(_ thick: Int) {
        manager.setStrokeWidth(thick)
    }
}

// MARK: - Page / Zoom
extension AgoraBoardVM {
    public func zoomIn() {
        manager.increaseScale()
    }
    
    public func zoomOut() {
        manager.decreaseScale()
    }
    
    public func prevPage() {
        let prev = boardPage.index - 1
        guard prev >= 0 else {
            return
        }
        
        manager.onSetPageIndex(UInt(prev))
    }
    
    public func nextPage() {
        let next = boardPage.index + 1
        guard next > 0 else {
            return
        }
        
        manager.onSetPageIndex(UInt(next))
    }
}

// MARK: - WhiteBoard manager
extension AgoraBoardVM {
    func setFollow(_ follow: Bool) {
        manager.setFollowMode(follow)
    }
    
    func lockViewTransform(_ lock: Bool) {
        manager.lockViewTransform(lock)
    }
    
    func operationPermission(_ grant: Bool,
                             success: (() -> Void)? = nil,
                             fail: ((Error) -> Void)? = nil) {
        manager.allowTeachingaids(grant) {
            if let success = success {
                success()
            }
        } failure: { (error) in
            if let fail = fail {
                fail(error)
            }
        }
    }
    
    func onSetPageIndex(_ index: UInt) {
        manager.onSetPageIndex(index)
    }
    
    func setIncreaseScale() {
        manager.increaseScale()
    }
    
    func setDecreaseScale() {
        manager.decreaseScale()
    }
    
    func refreshViewSize() {
        manager.refreshViewSize()
    }
    
    func resetViewSize() {
        manager.resetViewSize()
    }
}

// MARK: - AgoraWhiteManagerDelegate
extension AgoraBoardVM: AgoraWhiteManagerDelegate {
    public func onWhiteBoardStateChanged(_ state: AgoraWhiteBoardStateModel) {
        let originalState = boardState
        boardState = state

        let originalLocalIsGranted = originalState.grantUsers?.contains(self.userUuid) ?? false
        let currentlLocalIsGranted = state.grantUsers?.contains(self.userUuid) ?? false

        let currentGrantedUsers = state.grantUsers
        
        // full screen mode
        if originalState.isFullScreen != state.isFullScreen &&
            !originalLocalIsGranted &&
            !currentlLocalIsGranted {
            delegate?.didBoardFullScreenMode(state.isFullScreen)
        }
        
        // local premission was revoked
        if (originalLocalIsGranted && !currentlLocalIsGranted) {
            delegate?.didBoardLocalPermissionRevoked(currentGrantedUsers)
        }
        
        // local premission was granted
        if (!originalLocalIsGranted && currentlLocalIsGranted) {
            if let users = currentGrantedUsers {
                delegate?.didBoardLocalPermissionGranted(users)
            }
        }
        
        let originalGrantUsers = originalState.grantUsers ?? []
        let currentGrantUsers = state.grantUsers ?? []
        if originalGrantUsers.count != currentGrantUsers.count ||
            originalGrantUsers.sorted() != currentGrantUsers.sorted() {
            
            delegate?.didBoardPermissionUpdated(currentGrantUsers)
        }
    }
    
    public func onWhiteBoardPageChanged(_ pageIndex: Int,
                                        pageCount: Int) {
        boardPage = BoardPage(index: pageIndex,
                              count: pageCount)
        
        delegate?.didBoardPageChange(pageIndex: pageIndex,
                                     pageCount: pageCount)
    }

    // 老师切换场景，根据课件
    public func onWhiteBoardSceneChanged(_ scenePath: String) {
        
        delegate?.didScenePathChanged(path: scenePath)
        
        var taskUuid: String? = nil
        
        // 任务列表
        if let tasks = self.boardState.materialList {

            for task in tasks where (task.ext == "pptx" && scenePath.contains(task.resourceUuid as String)) {
                taskUuid = task.taskUuid as String
                break
            }
        }
        
        // 如果任务列表里存在这个任务，就去下载
        if let uuid = taskUuid, uuid.count > 0 {
            let urlString = getNetlessLinkURL(taskUuid: uuid)
            
            if let url = URL(string: urlString) {
                delegate?.didSceneChange(urls: [url])
            }
            
        // 判断之前下载列表中是否有 scenePath，如果有也需要下载，
        } else {
            for courseware in cache.coursewares where scenePath.contains(courseware.resourceUuid) {
                if let url = URL(string: courseware.resourceUrl) {
                    delegate?.didSceneChange(urls: [url])
                }
                break
            }
        }
    }
}

private extension AgoraBoardVM {
    func getNetlessLinkURL(taskUuid: String) -> String {
        return "https://convertcdn.netless.link/dynamicConvert/\(taskUuid).zip"
    }
}
