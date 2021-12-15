//
//  AgoraWhiteboardWidgetDT.swift
//  AgoraWidgets
//
//  Created by LYY on 2021/12/8.
//

import Foundation
import AgoraWidget
import Whiteboard

protocol AGBoardWidgetDTDelegate: NSObjectProtocol {
    func onLocalGrantedChangedForBoardHandle(localGranted: Bool)
    
    func onScenePathChanged(path: String)
    func onGrantUsersChanged(grantUsers: [String])
    
    func onConfigComplete()
}


class AgoraWhiteboardWidgetDT {
    weak var delegate: AGBoardWidgetDTDelegate?
    private let scheme = "agoranetless"
    // from whiteboard
    var regionDomain = "convertcdn"
    
    @available(iOS 11.0, *)
    lazy var schemeHandler: AgoraWhiteURLSchemeHandler? = {
        return AgoraWhiteURLSchemeHandler(scheme: scheme,
                                                       directory: extra.coursewareDirectory)
    }()

    var scenePath = "" {
        didSet {
            delegate?.onScenePathChanged(path: scenePath)
        }
    }
    
    private var globalState = AgoraWhiteboardGlobalState() {
        didSet {
            if globalState.grantUsers.count != oldValue.grantUsers.count {
                if globalState.grantUsers.contains(localUserInfo.userUuid) {
                    localGranted = true
                    delegate?.onLocalGrantedChangedForBoardHandle(localGranted: true)
                } else {
                    localGranted = false
                    delegate?.onLocalGrantedChangedForBoardHandle(localGranted: false)
                }
                
                delegate?.onGrantUsersChanged(grantUsers: globalState.grantUsers)
            }
        }
    }
    
    var currentMemberState: WhiteMemberState?
    
    var reconnectTime: Int = 0
    
    // from properties
    var localCameraConfigs = [String: AgoraWhiteBoardCameraConfig]()

    var localGranted: Bool = false
    
    // config
    var properties: AgoraWhiteboardProperties? {
        didSet {
            if let props = properties {
                if props.extra.boardAppId != "",
                   props.extra.boardRegion != "",
                   props.extra.boardId != "",
                   props.extra.boardToken != "" {
                    delegate?.onConfigComplete()
                }
            }
        }
    }
    var extra: AgoraWhiteboardExtraInfo
    var localUserInfo: AgoraWidgetUserInfo
    
    lazy var logFolder: String = {
        let cachesFolder = NSSearchPathForDirectoriesInDomains(.cachesDirectory,
                                                               .userDomainMask,
                                                               true)[0]
        let folder = cachesFolder.appending("/AgoraLog")
        let manager = FileManager.default
        
        if !manager.fileExists(atPath: folder,
                               isDirectory: nil) {
            try? manager.createDirectory(atPath: folder,
                                         withIntermediateDirectories: true,
                                         attributes: nil)
        }
        return folder
    }()
    
    init(extra: AgoraWhiteboardExtraInfo,
         localUserInfo: AgoraWidgetUserInfo) {
        self.extra = extra
        self.localUserInfo = localUserInfo
    }
    
    func updateGlobalState(state: AgoraWhiteboardGlobalState) {
        globalState = state
    }
    
    func updateMemberState(state: AgoraBoardMemberState) {
        if let tool = state.activeApplianceType {
            currentMemberState?.currentApplianceName = tool.toWhiteboard()
        }
        
        if let colors = state.strokeColor {
            var stateColors = [NSNumber]()
            colors.forEach { color in
                stateColors.append(NSNumber(value: color))
            }
            currentMemberState?.strokeColor = stateColors
        }
        
        if let strokeWidth = state.strokeWidth {
            currentMemberState?.strokeWidth = NSNumber(value: strokeWidth)
        }
        
        if let textSize = state.textSize {
            currentMemberState?.textSize = NSNumber(value: textSize)
        }
    }
    
    func getWKConfig() -> WKWebViewConfiguration {
        let blueColor = "#75C0FF"
        let whiteColor = "#fff"
        let testColor = "#CC00FF"
        
        // tab style
        let tabBGStyle = """
                         var style = document.createElement('style');
                         style.innerHTML = '.telebox-titlebar { background: \(blueColor); }';
                         document.head.appendChild(style);
                         """
        
        let tabTitleStyle = """
                            var style = document.createElement('style');
                            style.innerHTML = '.telebox-title { color: \(whiteColor); }';
                            document.head.appendChild(style);
                            """
        
        let footViewBGStyle = """
                              var style = document.createElement('style');
                              style.innerHTML = '.netless-app-docs-viewer-footer { background: \(blueColor); }';
                              document.head.appendChild(style);
                              """
        
        let footViewPageLabelStyle = """
                                     var style = document.createElement('style');
                                     style.innerHTML = '.netless-app-docs-viewer-page-number { color: \(whiteColor); }';
                                     document.head.appendChild(style);
                                     """
        
        let footViewPageButtonStyle = """
                                      var style = document.createElement('style');
                                      style.innerHTML = '.netless-window-manager-wrapper .telebox-title, .netless-window-manager-wrapper .netless-app-docs-viewer-footer { color: \(whiteColor); }';
                                      document.head.appendChild(style);
                                      """
        let boardStyles = [tabBGStyle,
                           tabTitleStyle,
                           footViewBGStyle,
                           footViewPageLabelStyle,
                           footViewPageButtonStyle]
        
        let wkConfig = WKWebViewConfiguration()
#if arch(arm64)
        wkConfig.setValue("TRUE", forKey: "allowUniversalAccessFromFileURLs")
#else
        wkConfig.setValue("\(1)", forKey: "allowUniversalAccessFromFileURLs")
#endif
        if #available(iOS 11.0, *),
           let handler = self.schemeHandler {
//            let schemeHandler = AgoraWhiteURLSchemeHandler(scheme: scheme,
//                                                           directory: extra.coursewareDirectory)
            wkConfig.setURLSchemeHandler(handler,
                                         forURLScheme: scheme)
        }
        
        let ucc = WKUserContentController()
        for boardStyle in boardStyles {
            let userScript = WKUserScript(source: boardStyle,
                                          injectionTime: .atDocumentEnd,
                                          forMainFrameOnly: true)
            ucc.addUserScript(userScript)
        }
        wkConfig.userContentController = ucc
        return wkConfig
    }
    
    func getWhiteSDKConfigToInit() -> WhiteSdkConfiguration? {
        guard let props = properties else {
            return nil
        }
        let config = WhiteSdkConfiguration(app: props.extra.boardAppId)
        config.enableIFramePlugin = false
        if #available(iOS 11.0, *) {
            let pptParams = WhitePptParams()
            pptParams.scheme = scheme
            config.pptParams = pptParams
        }
        config.fonts = extra.fonts
        config.userCursor = true
        config.region = WhiteRegionKey(rawValue: props.extra.boardRegion)
        config.useMultiViews = extra.useMultiViews ?? true
        
        return config
    }
    
    func getWhiteRoomConfigToJoin() -> WhiteRoomConfig? {
        guard let props = properties else {
            return nil
        }
        let config = WhiteRoomConfig(uuid: props.extra.boardId,
                                     roomToken: props.extra.boardToken,
                                     uid: localUserInfo.userUuid,
                                     userPayload: ["cursorName": localUserInfo.userName])
        config.isWritable = false
        config.disableNewPencil = false
        
        let windowParams = WhiteWindowParams()
        windowParams.chessboard = false
        windowParams.collectorStyles = extra.collectorStyles
        
        config.windowParams = windowParams
        
        return config
    }
    
    func netlessLinkURL(regionDomain: String,
                        taskUuid: String) -> String {
        return "https://\(regionDomain).netless.link/dynamicConvert/\(taskUuid).zip"
    }
    
    func netlessPublicCourseware() -> String {
        return "https://convertcdn.netless.link/publicFiles.zip"
    }
}
