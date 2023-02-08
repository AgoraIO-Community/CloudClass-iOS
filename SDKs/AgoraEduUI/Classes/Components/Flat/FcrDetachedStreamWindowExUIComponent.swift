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
    
    private var localPreviewObjectId: String?
    
    func startPreviewLocalVideo() {
        isStartPreview = true
        
        addLocalPreviewItem()
    }
    
    func stopPreviewLocalVideo() {
        isStartPreview = false
        
        removeLocalPreviewItem()
    }
    
    private func addLocalPreviewItem() {
        let localUserId = userController.getLocalUserInfo().userUuid
        
        guard let streams = streamController.getStreamList(userUuid: localUserId),
              let stream = streams.first(where: {$0.videoSourceType == .camera})
        else {
            return
        }
        
        let widgetObjectId = WindowWidgetId + stream.streamUuid
        
        localPreviewObjectId = widgetObjectId
        
        guard let item = createItem(widgetObjectId: widgetObjectId,
                                    stream: stream) else {
            return
        }
        
        let frame = AgoraWidgetFrame(x: 100,
                                     y: 100,
                                     z: 0,
                                     width: 100,
                                     height: 100)
        
        addItem(item,
                syncFrame: frame)
    }
    
    private func removeLocalPreviewItem() {
        guard let objectId = localPreviewObjectId else {
            return
        }
        
        removeItem(objectId)
    }
    
    func onStreamJoined(stream: AgoraEduContextStreamInfo,
                        operatorUser: AgoraEduContextUserInfo?) {
        let localUserId = userController.getLocalUserInfo().userUuid
        
        guard stream.owner.userUuid == localUserId,
              isStartPreview
        else {
            return
        }
        
        addLocalPreviewItem()
    }
}
