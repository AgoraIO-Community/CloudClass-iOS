//
//  AgoraUIManager+1V1.swift
//  AgoraUIEduAppViews
//
//  Created by SRS on 2021/4/16.
//

import Foundation
import AgoraUIBaseViews
import AgoraUIEduBaseViews

// MARK: 1V1View
extension AgoraUIManager {
    func add1V1ContainerViews() {
        guard let `room` = self.room,
              let `whiteBoard` = self.whiteBoard,
              let `chat` = self.chat,
              let `shareScreen` = self.shareScreen,
              let `render1V1` = self.render1V1 else {
            return
        }
        
        appView.addSubview(room.containerView)
        appView.addSubview(render1V1.containerView)
        appView.addSubview(whiteBoard.containerView)
        whiteBoard.containerView.addSubview(shareScreen.containerView)
        whiteBoard.containerView.sendSubviewToBack(shareScreen.containerView)
        appView.addSubview(chat.containerView)
    }

    func layout1V1ContainerViews() {
        guard let `room` = self.room,
              let `whiteBoard` = self.whiteBoard,
              let `chat` = self.chat,
              let `shareScreen` = self.shareScreen,
              let `render1V1` = self.render1V1 else {
            return
        }
        
        let isPad = AgoraKitDeviceAssistant.OS.isPad
        
        room.containerView.agora_x = 0
        room.containerView.agora_right = 0
        room.containerView.agora_height = isPad ? 44 : 34
        room.containerView.agora_safe_y = 0
        
        let ViewGap: CGFloat = 2
        let top = (isPad ? 44 : 34) + ViewGap
        let size = get1V1RenderViewSize()
        
        render1V1.containerView.agora_width = size.width
        render1V1.containerView.agora_safe_y = top
        render1V1.containerView.agora_safe_right = 0
        render1V1.containerView.agora_height = size.height * 2 + ViewGap
        
        chat.containerView.agora_safe_right = size.width + 10
        chat.containerView.agora_width = 56
        chat.containerView.agora_height = 56
        chat.containerView.agora_safe_bottom = 0
        
        shareScreen.containerView.agora_x = 0
        shareScreen.containerView.agora_y = 0
        shareScreen.containerView.agora_bottom = 0
        shareScreen.containerView.agora_right = 0

        whiteBoard.containerView.agora_safe_x = 0
        whiteBoard.containerView.agora_safe_y = top
        whiteBoard.containerView.agora_safe_bottom = 0
        whiteBoard.containerView.agora_safe_right = size.width + ViewGap
    }
    
    func layout1V1FullScreen(_ isFullScreen: Bool) {
        guard let render1V1 = render1V1 else {
            return
        }
        
        render1V1.updateRenderView(fullScreen: isFullScreen)
        
        guard let chatView = chat?.containerView else {
            return
        }
        
        let render1V1RightSpcae = render1V1.containerView.agora_safe_right + render1V1.containerView.bounds.width
        let ViewGap: CGFloat = 2
        
        let chatViewSafeRight = render1V1RightSpcae + ViewGap
        chatView.agora_safe_right = isFullScreen ? 10 : chatViewSafeRight
        
        guard let whiteBoardView = whiteBoard?.containerView else {
            return
        }
        
        whiteBoardView.agora_safe_right = isFullScreen ? 0 : render1V1RightSpcae + ViewGap
        
        UIView.animate(withDuration: TimeInterval.agora_animation) {
            self.appView.layoutIfNeeded()
        }
    }
    
    private func get1V1RenderViewSize() -> CGSize {
        let isPad = AgoraKitDeviceAssistant.OS.isPad

        let kAgoraScreenWidth: CGFloat = max(UIScreen.agora_width,
                                             UIScreen.agora_height)
        let kAgoraScreenHeight: CGFloat = min(UIScreen.agora_width,
                                              UIScreen.agora_height)
            
        let top: CGFloat = renderTop + 4

        var width: CGFloat = 0
        var height: CGFloat = 0
        
        if isPad {
            height = 168
            width = 300
        } else {
            let screen_safe_bottom: CGFloat = min(UIScreen.agora_safe_area_bottom,
                                                  21)
            let videoHeight: CGFloat = (kAgoraScreenHeight - screen_safe_bottom - top) * 0.5
            height = videoHeight
            width = height
        }
   
        return CGSize(width: width,
                      height: height)
    }
}
