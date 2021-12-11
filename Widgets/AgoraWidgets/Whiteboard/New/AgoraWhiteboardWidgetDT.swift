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
    func onFollowChanged(follow: Bool)
    func onGrantUsersChanged(grantUsers: [String]?)
    
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
    
    var globalState = AgoraWhiteboardGlobalState() {
        didSet {
            if globalState.follow != oldValue.follow {
                delegate?.onFollowChanged(follow: globalState.follow)
            }
            
            if globalState.grantUsers.count != oldValue.grantUsers.count {
                delegate?.onLocalGrantedChangedForBoardHandle(localGranted: localGranted)
                delegate?.onGrantUsersChanged(grantUsers: globalState.grantUsers)
            }
        }
    }
    
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
    
    init(extra: AgoraWhiteboardExtraInfo,
         localUserInfo: AgoraWidgetUserInfo) {
        self.extra = extra
        self.localUserInfo = localUserInfo
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
        config.enableIFramePlugin = true
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
