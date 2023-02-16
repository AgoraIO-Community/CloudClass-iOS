//
//  FcrDetachedStreamWindowExUIComponent.swift
//  AgoraEduUI
//
//  Created by Cavan on 2023/2/6.
//

import AgoraUIBaseViews
import AgoraEduCore
import AgoraWidget

fileprivate enum DetachedLocalStreamWindowState {
    case none, localPreview, active
}

class FcrDetachedStreamWindowExUIComponent: FcrDetachedStreamWindowUIComponent {
    private var isStartPreview = false {
        didSet {
            updateLocalStreamWindowState()
        }
    }
    
    private var localStreamWidgetIsActive: Bool {
        guard let objectId = localWidgetObjectId else {
            return false
        }
        
        return widgetController.getWidgetActivity(objectId)
    }
    
    private var localWidgetObjectId: String?
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        guard let widgetId = localWidgetObjectId else {
            return
        }
        
        let syncFrame = getLocalPreviewFrame()
        
        updateFrame(widgetObjectId: widgetId,
                    syncFrame: syncFrame,
                    animation: false)
    }
    
    func startPreviewLocalVideo() {
        isStartPreview = true
    }
    
    func stopPreviewLocalVideo() {
        isStartPreview = false
    }
    
    private func addLocalItem() {
        localWidgetObjectId = getLocalWidgetObjectId()
        
        guard let objectId = localWidgetObjectId else {
            return
        }
        
        guard let stream = getLocalCameraStream() else {
            return
        }
        
        guard let item = createItem(widgetObjectId: objectId,
                                    stream: stream)
        else {
            return
        }
        
        let frame = getLocalPreviewFrame()
        
        let message = "fcr_expansion_screen_tips_teacher_watching".agedu_localized()
        
        AgoraToast.toast(message: message)
        
        addItem(item,
                syncFrame: frame)
    }
    
    private func removeLocalItem() {
        guard let objectId = localWidgetObjectId else {
            return
        }
        
        removeItem(objectId)
        
        localWidgetObjectId = nil
    }
    
    private func getLocalCameraStream() -> AgoraEduContextStreamInfo? {
        let localUserId = userController.getLocalUserInfo().userUuid
        
        guard let streams = streamController.getStreamList(userUuid: localUserId),
              let stream = streams.first(where: {$0.videoSourceType == .camera})
        else {
            return nil
        }
        
        return stream
    }
    
    private func coHostListContainLocalUser() -> Bool {
        let localUserId = userController.getLocalUserInfo().userUuid
        
        guard let list = userController.getCoHostList() else {
            return false
        }
        
        return list.contains(where: {$0.userUuid == localUserId})
    }
    
    private func getLocalPreviewFrame() -> AgoraWidgetFrame {
        let width: CGFloat = 124
        let height: CGFloat = 70
        
        let rightSpace: CGFloat = 64
        let bottomSpace: CGFloat = 16
        
        let x = view.bounds.size.width - width - rightSpace
        let y = view.bounds.size.height - height - bottomSpace
        
        let frame = CGRect(x: x,
                           y: y,
                           width: width,
                           height: height)
        
        let syncFrame = frame.syncFrameInView(view)
        
        return syncFrame
    }
    
    private func getLocalWidgetObjectId() -> String? {
        guard let stream = getLocalCameraStream() else {
            return nil
        }
        
        let widgetObjectId = WindowWidgetId + "-" + stream.streamUuid
        
        return widgetObjectId
    }
    
    private var localStreamWindowState: DetachedLocalStreamWindowState = .none {
        didSet {
            switch localStreamWindowState {
            case .none:
                removeLocalItem()
            case .localPreview:
                addLocalItem()
            case .active:
                // super class handle this case
                guard let widgetId = localWidgetObjectId else {
                    return
                }
            
                super.onWidgetActive(widgetId)
            }
        }
    }
    
    func updateLocalStreamWindowState() {
        // Active stream window widget
        if localStreamWidgetIsActive {
            localStreamWindowState = .active
            return
        }
        
        if localStreamWidgetIsActive == false {
            
            //
            if coHostListContainLocalUser() {
                localStreamWindowState = .none
                return
            }
            
            if isStartPreview {
                localStreamWindowState = .localPreview
            } else {
                localStreamWindowState = .none
            }
        }
    }
    
    // MARK: - Edu core callback
    override func onWidgetActive(_ widgetId: String) {
        if widgetId == localWidgetObjectId {
            updateLocalStreamWindowState()
        } else {
            super.onWidgetActive(widgetId)
        }
    }
    
    override func onWidgetInactive(_ widgetId: String) {
        if widgetId == localWidgetObjectId {
            updateLocalStreamWindowState()
        } else {
            super.onWidgetInactive(widgetId)
        }
    }
    
    func onStreamJoined(stream: AgoraEduContextStreamInfo,
                        operatorUser: AgoraEduContextUserInfo?) {
        let localUserId = userController.getLocalUserInfo().userUuid
        
        guard stream.owner.userUuid == localUserId else {
            return
        }
        
        updateLocalStreamWindowState()
    }
    
    func onCoHostUserListRemoved(userList: [AgoraEduContextUserInfo],
                                 operatorUser: AgoraEduContextUserInfo?) {
        updateLocalStreamWindowState()
    }
    
    func onCoHostUserListAdded(userList: [AgoraEduContextUserInfo],
                                        operatorUser: AgoraEduContextUserInfo?) {
        updateLocalStreamWindowState()
    }
}
