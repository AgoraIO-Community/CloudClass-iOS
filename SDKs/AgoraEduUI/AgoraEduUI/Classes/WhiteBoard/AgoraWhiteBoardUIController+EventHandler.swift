//
//  AgoraWhiteBoardController+EventHandler.swift
//  AgoraEduUI
//
//  Created by Cavan on 2021/4/19.
//

import AgoraUIEduBaseViews
import AgoraEduContext

// MARK: - AgoraEduWhiteBoardHandler
extension AgoraWhiteBoardUIController: AgoraEduWhiteBoardHandler {
    @objc func onBoardContentView(_ view: UIView) {
        boardView.addSubview(view)
        
        view.agora_x = 0
        view.agora_y = 0
        view.agora_right = 0
        view.agora_bottom = 0
        
        boardView.allTransparent(needTransparent)
    }
    
    @objc public func onDrawingEnabled(_ enabled: Bool) {
        if toastShowedStates.contains(#function) {
            let msg = enabled ? AgoraKitLocalizedString("UnMuteBoardText") : AgoraKitLocalizedString("MuteBoardText")
            AgoraToast.toast(msg: msg)
        } else {
            toastShowedStates.append(#function)
        }
        
        boardToolsState.hasPermission = enabled
    }
    
    @objc public func onLoadingVisible(_ visible: Bool) {
        boardView.setLoadingVisible(visible: visible)
    }
    
    // progress 0-100
    @objc public func onDownloadProgress(_ url: String,
                                            progress: Float) {
        boardView.setDownloadProgress(progress: progress)
    }
    
    @objc public func onDownloadTimeOut(_ url: String) {
        boardView.downloadTimeOut()
    }
    
    @objc public func onDownloadComplete(_ url: String) {
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
        if toastShowedStates.contains(#function) {
            let msg = granted ? AgoraKitLocalizedString("UnMuteBoardText") : AgoraKitLocalizedString("MuteBoardText")
            AgoraToast.toast(msg: msg)
        } else {
            toastShowedStates.append(#function)
        }
    }
}

// MARK: - AgoraEduWhiteBoardPageControlHandler
extension AgoraWhiteBoardUIController: AgoraEduWhiteBoardPageControlHandler {
    @objc public func onPageIndex(_ pageIndex: NSInteger,
                                  pageCount: NSInteger) {
        boardPageControl.setPageIndex(pageIndex,
                                      pageCount: pageCount)
    }
    
    @objc public func onFullScreen(_ fullScreen: Bool) {
        boardState.isFullScreen = fullScreen
    }
    
    @objc public func onPagingEnable(_ enable: Bool) {
        boardPageControlState.pagingEnable = enable
    }
    
    @objc public func onZoomEnable(_ zoomOutEnable: Bool,
                                   zoomInEnable: Bool) {
        boardPageControlState.zoomEnable = zoomInEnable
    }
    
    @objc public func onResizeFullScreenEnable(_ enable: Bool) {
        boardPageControlState.fullScreenEnable = enable
    }
}
