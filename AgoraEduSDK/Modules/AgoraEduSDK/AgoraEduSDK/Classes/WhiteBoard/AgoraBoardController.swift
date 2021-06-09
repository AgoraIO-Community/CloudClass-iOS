//
//  WhiteBoardViewController.swift
//  WhiteBoardTest
//
//  Created by Cavan on 2021/3/12.
//

import UIKit
import AgoraWhiteBoard
import AgoraReport
import AgoraUIBaseViews
import AgoraUIEduBaseViews
import AgoraEduContext
import EduSDK

@objc public protocol AgoraBoardControllerDelegate: NSObjectProtocol {
    func boardController(_ controller: AgoraBoardController,
                         didUpdateUsers userId: [String])
    
    func boardController(_ controller: AgoraBoardController,
                         didScenePathChanged path: String)

    func boardController(_ controller: AgoraBoardController,
                         didOccurError error: Error)
}

@objcMembers public class AgoraBoardController: NSObject, AgoraController {
    private let coursewareDirectory = NSSearchPathForDirectoriesInDomains(FileManager.SearchPathDirectory.cachesDirectory,
                                                                          FileManager.SearchPathDomainMask.userDomainMask,
                                                                          true)[0] + "/AgoraDownload/"
    
    private lazy var afterWork = AgoraAfterWorker()
    private var boardContentView: UIView?

    public var boardVM: AgoraBoardVM
    
    private weak var delegate: AgoraBoardControllerDelegate?
    private var download: AgoraDownloadManager
    private var cache: AgoraManagerCache
    private var eventDispatcher: AgoraUIEventDispatcher
    
    private var boardAppId: String
    private var boardId: String
    private var boardToken: String
    private var userId: String
    
    public init(boardAppId: String,
                boardId: String,
                boardToken: String,
                userUuid: String,
                download: AgoraDownloadManager,
                reportor: AgoraApaasReportorEventTube,
                cache: AgoraManagerCache,
                delegate: AgoraBoardControllerDelegate?) {
        self.boardAppId = boardAppId
        self.boardId = boardId
        self.boardToken = boardToken
        self.userId = userUuid
        self.delegate = delegate
        
        let config = AgoraWhiteBoardConfiguration()
        config.appId = boardAppId
        let manager = AgoraWhiteBoardManager(coursewareDirectory: coursewareDirectory,
                                             config: config)
        boardContentView = manager.contentView
        boardVM = AgoraBoardVM(boardAppId: boardAppId,
                               userUuid: userUuid,
                               manager: manager,
                               reportor: reportor,
                               cache: cache,
                               delegate: nil)
        
        self.download = download
        self.cache = cache
        self.eventDispatcher = AgoraUIEventDispatcher()
        
        super.init()
        
        boardVM.delegate = self
    }
}

// MARK: - Life cycle
extension AgoraBoardController {
    public func viewWillAppear() {
        
    }
    
    public func viewDidLoad() {
        
    }
    
    public func viewDidAppear() {
        initBoardView()
        join()
    }
    
    public func viewWillDisappear() {
        leave()
    }
    
    public func viewDidDisappear() {
        
    }
}

extension AgoraBoardController {
    func join() {
        eventDispatcher.onSetLoadingVisible(true)
        
        boardVM.join(boardId: boardId,
                     boardToken: boardToken) { [unowned self] in
            self.eventDispatcher.onSetLoadingVisible(false)
        } failure: { [unowned self] (error) in
            self.eventDispatcher.onSetLoadingVisible(false)
            self.delegate?.boardController(self,
                                           didOccurError: error)
        }
    }
    
    func leave() {
        boardVM.leave()
    }
}

private extension AgoraBoardController {
    func initBoardView() {
        guard let `boardView` = eventDispatcher.onGetBoardContainer(),
              let `contentView` = boardContentView else {
            return
        }
        
        boardView.addSubview(contentView)
        contentView.translatesAutoresizingMaskIntoConstraints = false
        contentView.agora_equal_to_superView(attribute: .left)
        contentView.agora_equal_to_superView(attribute: .right)
        contentView.agora_equal_to_superView(attribute: .top)
        contentView.agora_equal_to_superView(attribute: .bottom)
        
        viewsEnable(false)
    }
}

// MARK: - AgoraKitWhiteBoardListener
extension AgoraBoardController: AgoraEduWhiteBoardContext {
    public func onBoardResetSize() {
        boardVM.resetViewSize()
    }
    
    public func boardRefreshSize() {
        boardVM.refreshViewSize()
    }
    
    public func boardInputEnable(_ enable: Bool) {
        boardVM.lockViewTransform(!enable)
    }
    
    public func skipDownload(_ url: String) {
        download.stopTask(url: url)
    }
    
    public func cancelDownload(_ url: String) {
        download.stopTask(url: url)
    }
    
    public func retryDownload(_ url: String) {
        download.reDownload(delegate: self)
    }
    
    public func registerBoardEventHandler(_ handler: AgoraEduWhiteBoardHandler) {
        eventDispatcher.register(event: .whiteBoard(object: handler))
    }
}

// MARK: - AgoraKitWhiteBoardToolListener
extension AgoraBoardController: AgoraEduWhiteBoardToolContext {
    public func applianceSelected(_ mode: AgoraEduContextApplianceType) {
        boardVM.applianceSelected(mode.boardToolType)
    }
    
    public func colorSelected(_ color: UIColor) {
        boardVM.colorSelected(color)
    }
    
    public func fontSizeSelected(_ size: Int) {
        boardVM.fontSizeSelected(size)
    }
    
    public func thicknessSelected(_ thick: Int) {
        boardVM.thicknessSelected(thick)
    }
}

// MARK: - AgoraKitWhiteBoardToolListener
extension AgoraBoardController: AgoraEduWhiteBoardPageControlContext {
    public func zoomIn() {
        boardVM.zoomIn()
    }
    
    public func zoomOut() {
        boardVM.zoomOut()
    }
    
    public func prevPage() {
        boardVM.prevPage()
    }
    
    public func nextPage() {
        boardVM.nextPage()
    }
    
    public func registerPageControlEventHandler(_ handler: AgoraEduWhiteBoardPageControlHandler) {
        eventDispatcher.register(event: .whiteBoardPageControl(object: handler))
    }
}

// MARK: - AgoraBoardVMDelegate
extension AgoraBoardController: AgoraBoardVMDelegate {
    func didBoardFullScreenMode(_ fullScreen: Bool) {
        eventDispatcher.onSetResizeFullScreenEnable(!fullScreen)
        eventDispatcher.onSetFullScreen(fullScreen)
    }
    
    func didBoardLocalPermissionGranted(_ grantUsers: [String]) {
        boardVM.operationPermission(true) {[weak self] in
            guard let `self` = self else {
                return
            }
            self.viewsEnable(true)
            self.boardVM.lockViewTransform(false)
            self.boardVM.setFollow(false)
            self.eventDispatcher.onShowPermissionTips(true)
            self.eventDispatcher.onSetDrawingEnabled(true)
        } fail: {[weak self] (error) in
            guard let `self` = self else {
                return
            }
            self.delegate?.boardController(self, didOccurError: error)
        }
    }
    
    func didBoardLocalPermissionRevoked(_ grantUsers: [String]?) {
        boardVM.operationPermission(false) {[weak self] in
            guard let `self` = self else {
                return
            }
            self.viewsEnable(false)
            self.boardVM.lockViewTransform(true)
            self.boardVM.setFollow(true)
            self.eventDispatcher.onShowPermissionTips(false)
            self.eventDispatcher.onSetDrawingEnabled(false)
        } fail: {[weak self] (error) in
            guard let `self` = self else {
                return
            }
            self.delegate?.boardController(self, didOccurError: error)
        }
    }
    
    func didBoardPermissionUpdated(_ grantUsers: [String]) {
        delegate?.boardController(self,
                                  didUpdateUsers: grantUsers)
    }
    
    func didBoardPageChange(pageIndex: Int,
                            pageCount: Int) {
        eventDispatcher.onSetPageIndex(pageIndex,
                                     pageCount: pageCount)
    }
    
    func didSceneChange(urls: [URL]) {
        guard let url = urls.first else {
            return
        }
        
        download.stopAllTasks()
        download.download(urls: urls,
                          fileDirectory: coursewareDirectory,
                          delegate: self)
        afterWork.cancel()
        afterWork.perform(after: 15,
                          on: .main) { [weak self] in
            self?.eventDispatcher.onSetDownloadTimeOut(url.absoluteString)
        }
    }
    
    func didScenePathChanged(path: String) {
        delegate?.boardController(self, didScenePathChanged: path)
    }
}

// MARK: - AgoraDownloadProtocol
extension AgoraBoardController: AgoraDownloadProtocol {
    public func onDownloadCompleted(_ key: String?,
                             urls: [URL],
                             error: Error?,
                             errorCode: Int) {
        guard let urlString = urls.first?.absoluteString else {
            return
        }
        
        if let tError = error {
            let nsError = tError as NSError
            
            guard nsError.code != -999 else {
                eventDispatcher.onCancelCurDownload()
                return
            }
        
            eventDispatcher.onDownloadError(urlString)
            afterWork.cancel()
//            viewsEnable(false)
        } else {
            eventDispatcher.onSetDownloadComplete(urlString)
            afterWork.cancel()
//            viewsEnable(true)
        }
    }
    
    public func onProcessChanged(_ key: String?,
                          url: URL,
                          process: Float) {
        eventDispatcher.onSetDownloadProgress(url.absoluteString,
                                             progress: process)
    }
}

extension AgoraBoardController {
    func viewsEnable(_ enable: Bool) {
        eventDispatcher.onSetPagingEnable(enable)
        eventDispatcher.onSetZoomEnable(enable,
                                      zoomInEnable: enable)
        eventDispatcher.onSetDrawingEnabled(enable)
    }
}

extension AgoraEduContextApplianceType {
    var boardToolType: AgoraWhiteBoardToolType {
        switch self {
        case .circle:  return .WhiteBoardToolTypeEllipse
        case .eraser:  return .WhiteBoardToolTypeEraser
        case .line:    return .WhiteBoardToolTypeStraight
        case .pen:     return .WhiteBoardToolTypePencil
        case .rect:    return .WhiteBoardToolTypeRectangle
        case .select:  return .WhiteBoardToolTypeSelector
        case .clicker: return .WhiteBoardToolTypeClicker
        }
    }
}
