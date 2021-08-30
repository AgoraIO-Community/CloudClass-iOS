//
//  AgoraWhiteBoardController+EventHandler.swift
//  AgoraUIEduAppViews
//
//  Created by Cavan on 2021/4/19.
//

import UIKit
import WebKit
import AgoraUIEduBaseViews
import AgoraEduContext

// MARK: - AgoraEduWhiteBoardHandler
extension AgoraWhiteBoardUIController: AgoraEduWhiteBoardHandler {
    @objc public func onGetBoardContainer(_ webview: WKWebView) -> UIView {
        return boardView.getBoardContainer()
    }
    
    @objc public func onSetDrawingEnabled(_ enabled: Bool) {
        boardToolsState.hasPermission = enabled
    }
    
    @objc public func onSetLoadingVisible(_ visible: Bool) {
        boardView.setLoadingVisible(visible: visible)
        
        if !visible {
            self.contextProvider?.controllerNeedWhiteBoardContext().setWhiteGlobalState(["A":["B":"C"]])
        }
    }
    
    // progress 0-100
    @objc public func onSetDownloadProgress(_ url: String,
                                            progress: Float) {
        boardState.downloadingCourseURL = url
        boardView.setDownloadProgress(progress: progress)
    }
    
    @objc public func onSetDownloadTimeOut(_ url: String) {
        boardState.downloadingCourseURL = url
        boardView.downloadTimeOut()
    }
    
    @objc public func onSetDownloadComplete(_ url: String) {
        boardState.downloadingCourseURL = url
        boardView.downloadComplete()
    }
    
    @objc public func onDownloadError(_ url: String) {
        boardToolsState.isUserInteractionEnabled = false
        boardPageControlState.isUserInteractionEnabled = false
        
        boardView.downloadError()
    }
    
    @objc public func onCancelCurDownload() {
        boardView.removeLoadingView()
    }
    
    @objc public func onShowPermissionTips(_ granted: Bool) {
        let msg = granted ? AgoraKitLocalizedString("UnMuteBoardText") : AgoraKitLocalizedString("MuteBoardText")
        AgoraUtils.showToast(message: msg)
    }
    
    func onWhiteGlobalStateChanged(_ state: [String : Any]) {
        print("onWhiteGlobalStateChanged:\(state)")
    }
}

// MARK: - AgoraEduWhiteBoardPageControlHandler
extension AgoraWhiteBoardUIController: AgoraEduWhiteBoardPageControlHandler {
    @objc public func onSetPageIndex(_ pageIndex: NSInteger,
                                   pageCount: NSInteger) {
        boardPageControl.setPageIndex(pageIndex,
                                      pageCount: pageCount)
    }
    
    @objc public func onSetFullScreen(_ fullScreen: Bool) {
        boardState.isFullScreen = fullScreen
    }
    
    @objc public func onSetPagingEnable(_ enable: Bool) {
        boardPageControlState.pagingEnable = enable
    }
    
    @objc public func onSetZoomEnable(_ zoomOutEnable: Bool,
                                    zoomInEnable: Bool) {
        boardPageControlState.zoomEnable = zoomInEnable
    }
    
    @objc public func onSetResizeFullScreenEnable(_ enable: Bool) {
        boardPageControlState.fullScreenEnable = enable
    }
}
