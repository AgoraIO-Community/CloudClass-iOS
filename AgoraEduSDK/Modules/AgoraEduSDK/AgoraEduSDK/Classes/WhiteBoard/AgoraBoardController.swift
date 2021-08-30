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
                         didUpdateFlexState state: [String: Any])
    
    func boardController(_ controller: AgoraBoardController,
                         didScenePathChanged path: String)
    
    func boardController(_ controller: AgoraBoardController,
                         didPositionUpdated appIdentifier: String,
                         diffPoint: CGPoint)
    
    func boardController(_ controller: AgoraBoardController,
                         didOccurError error: Error)
}

@objcMembers public class AgoraBoardController: NSObject, AgoraController {
    private let coursewareDirectory = NSSearchPathForDirectoriesInDomains(FileManager.SearchPathDirectory.cachesDirectory,
                                                                          FileManager.SearchPathDomainMask.userDomainMask,
                                                                          true)[0] + "/AgoraDownload/"
    
    private lazy var afterWork = AgoraAfterWorker()
    private var boardContentView: WKWebView?

    public var boardVM: AgoraBoardVM
    
    private weak var delegate: AgoraBoardControllerDelegate?
    private var download: AgoraDownloadManager
    private var cache: AgoraManagerCache
    private var eventDispatcher: AgoraUIEventDispatcher
    
    private var boardAppId: String
    private var boardId: String
    private var boardToken: String
    private var userId: String
    
    private var boardAutoMode: Bool
    private var localGranted = false
    
    private var currentScenePath: String = ""
    private var localCameraConfigs = [String: AgoraWhiteBoardCameraConfig]()
    
    private var manager: AgoraWhiteBoardManager?
    
    private var bInit = false

    public init(boardAppId: String,
                boardId: String,
                boardToken: String,
                userUuid: String,
                collectionStyle: [String: Any]?,
                boardStyles: [String]?,
                download: AgoraDownloadManager,
                reportor: AgoraApaasReportorEventTube,
                cache: AgoraManagerCache,
                boardAutoMode: Bool,
                delegate: AgoraBoardControllerDelegate?) {
        self.boardAppId = boardAppId
        self.boardId = boardId
        self.boardToken = boardToken
        self.boardAutoMode = boardAutoMode
        
        self.userId = userUuid
        self.delegate = delegate
        
        let config = AgoraWhiteBoardConfiguration()
        config.appId = boardAppId
        config.collectionStyle = collectionStyle
        config.boardStyles = boardStyles
        let boardManager = AgoraWhiteBoardManager(coursewareDirectory: coursewareDirectory,
                                             config: config)
        self.manager = boardManager
        
        boardContentView = boardManager.contentView
        boardVM = AgoraBoardVM(boardAppId: boardAppId,
                               userUuid: userUuid,
                               manager: boardManager,
                               reportor: reportor,
                               cache: cache,
                               delegate: nil)
        
        self.download = download
        self.cache = cache
        self.eventDispatcher = AgoraUIEventDispatcher()
        
        super.init()
        
        boardVM.delegate = self
    }
    
    public func syncAppPosition(appIdentifier: String,
                                diffPoint: CGPoint) {
        
        guard let stateModel = self.manager?.getWhiteBoardStateModel() else {
            return
        }
        var extAppMoveTracks = stateModel.extAppMoveTracks as? [String: Any] ?? [String: Any]()
        extAppMoveTracks[appIdentifier] = ["userId": self.userId,
                                           "x": diffPoint.x,
                                           "y": diffPoint.y]
        stateModel.extAppMoveTracks = extAppMoveTracks

        self.manager?.setWhiteBoardStateModel(stateModel)
    }
    
    
    deinit {
        self.leave()
    }
}

// MARK: - Life cycle
extension AgoraBoardController {
    public func viewWillAppear() {
        
    }
    
    public func viewDidLoad() {

    }
    
    public func viewDidAppear() {
        if !bInit {
            initBoardView()
            join()
        }
        bInit = true
    }
    
    public func viewWillDisappear() {
        //leave()
    }
    
    public func viewDidDisappear() {
        
    }
}

extension AgoraBoardController {
    func join() {
        eventDispatcher.onSetLoadingVisible(true)
        
        boardVM.join(boardId: boardId,
                     boardToken: boardToken) { [weak self] in
            self?.eventDispatcher.onSetLoadingVisible(false)
        } failure: { [weak self] (error) in
            guard let `self` = self else {
                return
            }

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
        guard let `contentView` = boardContentView,
              let `boardView` = eventDispatcher.onGetBoardContainer(contentView) else {
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
    
    @discardableResult func ifUseLocalCameraConfig() -> Bool {
        guard !boardAutoMode,
              localGranted,
              let camera = getLocalCameraConfig() else {
            return false
        }
        
        boardVM.setCameraConfig(camera)
        return true
    }
    
    func getLocalCameraConfig() -> AgoraWhiteBoardCameraConfig? {
        return localCameraConfigs[currentScenePath]
    }
    
    func updateLocalCameraConfig(_ camera: AgoraWhiteBoardCameraConfig) {
        guard localGranted else {
            return
        }
        
        localCameraConfigs[currentScenePath] = camera
    }
}

// MARK: - AgoraKitWhiteBoardListener
extension AgoraBoardController: AgoraEduWhiteBoardContext {
    public func whiteGlobalState() -> [String: Any] {
        if let stateModel = self.manager?.getWhiteBoardStateModel(),
           let state = stateModel.flexBoardState as? [String: Any] {
            return state ?? [String: Any]()
        }
        return [String: Any]()
    }

    public func setWhiteGlobalState(_ state: [String: Any]) {
        if let stateModel = self.manager?.getWhiteBoardStateModel() {
            stateModel.flexBoardState = state
            self.manager?.setWhiteBoardStateModel(stateModel)
        }
    }
    
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
    func didBoardDisConnectedUnexpected() {
        join()
    }
    func didBoardFullScreenMode(_ fullScreen: Bool) {
        eventDispatcher.onSetResizeFullScreenEnable(!fullScreen)
        eventDispatcher.onSetFullScreen(fullScreen)
    }
    
    func didBoardLocalPermissionGranted(_ grantUsers: [String]) {
        localGranted = true
        
        boardVM.lockViewTransform(false)
        
        boardVM.setFollow(true)
        boardVM.setFollow(false)
        
        ifUseLocalCameraConfig()
        
        boardVM.operationPermission(true) { [weak self] in
            guard let `self` = self else {
                return
            }
            
            self.viewsEnable(true)
           
            self.eventDispatcher.onShowPermissionTips(true)
            self.eventDispatcher.onSetDrawingEnabled(true)
        } fail: { [weak self] (error) in
            guard let `self` = self else {
                return
            }
            self.delegate?.boardController(self,
                                           didOccurError: error)
        }
    }
    
    func didBoardLocalPermissionRevoked(_ grantUsers: [String]?) {
        localGranted = false
        
        boardVM.lockViewTransform(true)
        boardVM.setFollow(true)
        
        boardVM.operationPermission(false) { [weak self] in
            guard let `self` = self else {
                return
            }
            
            self.viewsEnable(false)
            
            self.eventDispatcher.onShowPermissionTips(false)
            self.eventDispatcher.onSetDrawingEnabled(false)
        } fail: { [weak self] (error) in
            guard let `self` = self else {
                return
            }
            self.delegate?.boardController(self,
                                           didOccurError: error)
        }
    }
    
    func didCameraConfigChanged(camera: AgoraWhiteBoardCameraConfig) {
        updateLocalCameraConfig(camera)
    }
    
    func didBoardPermissionUpdated(_ grantUsers: [String]) {
        delegate?.boardController(self,
                                  didUpdateUsers: grantUsers)
    }
    
    func didBoardPageChange(pageIndex: Int,
                            pageCount: Int) {
        ifUseLocalCameraConfig()
        
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
        if path.isBoardPath() {
            currentScenePath = "/init"
        } else {
            currentScenePath = path
        }
        
        ifUseLocalCameraConfig()
        
        delegate?.boardController(self,
                                  didScenePathChanged: path)
    }
    
    func didFlexStateUpdated(state: [String : Any]?) {
        eventDispatcher.onWhiteGlobalStateChanged(state ?? [String : Any]())
    }
    
    func didPositionUpdated(appIdentifier: String,
                            diffPoint: CGPoint) {
        delegate?.boardController(self,
                                  didPositionUpdated: appIdentifier,
                                  diffPoint: diffPoint)
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
        } else {
            eventDispatcher.onSetDownloadComplete(urlString)
            afterWork.cancel()
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

fileprivate extension String {
    func isBoardPath() -> Bool {
        return (count < 32)
    }
}
