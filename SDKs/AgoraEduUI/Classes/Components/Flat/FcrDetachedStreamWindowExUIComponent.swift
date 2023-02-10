//
//  FcrDetachedStreamWindowExUIComponent.swift
//  AgoraEduUI
//
//  Created by Cavan on 2023/2/6.
//

import AgoraUIBaseViews
import AgoraEduCore
import AgoraWidget

class FcrDetachedStreamWindowExUIComponent: FcrDetachedStreamWindowUIComponent {
    private var isStartPreview = false
    
    private var localPreviewObjectId: String? {
        guard let stream = getLocalCameraStream() else {
            return nil
        }
        
        let widgetObjectId = WindowWidgetId + "-" + stream.streamUuid
        
        return widgetObjectId
    }
    
    private var localPreviewWidgetIsActive: Bool {
        guard let objectId = localPreviewObjectId else {
            return false
        }
        
        return widgetController.getWidgetActivity(objectId)
    }
    
    func startPreviewLocalVideo() {
        isStartPreview = true
        
        addLocalPreviewItem()
    }
    
    func stopPreviewLocalVideo() {
        isStartPreview = false
        
        removeLocalPreviewItem()
    }
    
    private func addLocalPreviewItem() {
        guard localPreviewWidgetIsActive == false else {
            return
        }
        
        guard let objectId = localPreviewObjectId else {
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
        
        addItem(item,
                syncFrame: frame)
    }
    
    private func removeLocalPreviewItem() {
        guard localPreviewWidgetIsActive == false else {
            return
        }
        
        guard let objectId = localPreviewObjectId else {
            return
        }
        
        removeItem(objectId)
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
    
    override func onWidgetInactive(_ widgetId: String) {
        if widgetId == localPreviewObjectId,
           localPreviewWidgetIsActive == false,
           isStartPreview {
            
            let frame = getLocalPreviewFrame()
            
            updateFrame(widgetObjectId: widgetId,
                        syncFrame: frame,
                        animation: true)
        } else {
            super.onWidgetInactive(widgetId)
        }
    }
    
    func onStreamJoined(stream: AgoraEduContextStreamInfo,
                        operatorUser: AgoraEduContextUserInfo?) {
        let localUserId = userController.getLocalUserInfo().userUuid
        
        guard stream.owner.userUuid == localUserId,
              localPreviewWidgetIsActive == false,
              isStartPreview
        else {
            return
        }
        
        addLocalPreviewItem()
    }
}
