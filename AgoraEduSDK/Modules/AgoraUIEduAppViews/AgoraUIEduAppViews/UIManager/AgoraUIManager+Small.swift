//
//  AgoraUIManager+Small.swift
//  AgoraUIEduAppViews
//
//  Created by SRS on 2021/4/16.
//

import Foundation
import AgoraUIBaseViews
import AgoraUIEduBaseViews

extension AgoraUIManager {
    func addSmallContainerViews() {
        guard let `room` = self.room,
              let `whiteBoard` = self.whiteBoard,
              let `chat` = self.chat,
              let `shareScreen` = self.shareScreen,
              let `renderSmall` = self.renderSmall,
              let `handsUp` = self.handsUp,
              let `userList` = self.userList else  {
            return
        }
        
        appView.addSubview(room.containerView)
        appView.addSubview(renderSmall.containerView)
        appView.addSubview(whiteBoard.containerView)
        whiteBoard.containerView.addSubview(shareScreen.containerView)
        whiteBoard.containerView.sendSubviewToBack(shareScreen.containerView)
        appView.addSubview(chat.containerView)
        appView.addSubview(handsUp.containerView)
        appView.addSubview(userList.containerView)
    }

    func layoutSmallContainerViews() {
        guard let `room` = self.room,
              let `whiteBoard` = self.whiteBoard,
              let `chat` = self.chat,
              let `shareScreen` = self.shareScreen,
              let `renderSmall` = self.renderSmall,
              let `handsUp` = self.handsUp,
              let `userList` = self.userList else  {
            return
        }
        
        let isPad = AgoraKitDeviceAssistant.OS.isPad
        
        room.containerView.agora_x = 0
        room.containerView.agora_right = 0
        room.containerView.agora_height = isPad ? 44 : 34
        room.containerView.agora_safe_y = 0
        
        let ViewGap: CGFloat = 2
        
        let top = (isPad ? 44 : 34) + ViewGap
        
        let size = renderSmall.teacherViewSize
        let renderListHeight = renderSmall.renderListViewHeight
        
        renderSmall.containerView.agora_safe_x = 0
        renderSmall.containerView.agora_safe_y = top
        renderSmall.containerView.agora_safe_right = 0
        renderSmall.containerView.agora_height = max(size.height,
                                                     renderListHeight)

        chat.containerView.agora_width = 56
        chat.containerView.agora_height = 56
        chat.containerView.agora_safe_bottom = 2
        chat.containerView.agora_safe_right = 10
        if let message = ["isMin": 1].jsonString() {
            chat.widgetDidReceiveMessage(message)
        }
        
        shareScreen.containerView.agora_x = 0
        shareScreen.containerView.agora_y = 0
        shareScreen.containerView.agora_bottom = 0
        shareScreen.containerView.agora_right = 0

        whiteBoard.containerView.agora_safe_x = 0
        whiteBoard.containerView.agora_safe_y = renderSmall.containerView.agora_safe_y + renderSmall.containerView.agora_height
        whiteBoard.containerView.agora_safe_bottom = 0
        whiteBoard.containerView.agora_safe_right = 0
        
        handsUp.containerView.agora_safe_right = chat.containerView.agora_safe_right + chat.containerView.agora_width + 10 - 8
        handsUp.containerView.agora_safe_bottom = 2

        userList.containerView.agora_width = 548
        userList.containerView.agora_height = 312
        if isPad {
            userList.containerView.agora_center_x = -(size.width * 0.5)
            userList.containerView.agora_center_y = 0
        } else {
            userList.containerView.agora_safe_x = whiteBoard.containerView.agora_safe_x + 60
            userList.containerView.agora_safe_y = top
        }
    }
    
    func layoutSmallView(_ isFullScreen: Bool) {
        guard let `renderSmall` = self.renderSmall,
              let `whiteBoard` = self.whiteBoard,
              let `chat` = self.chat else {
            return
        }
        
        renderSmall.updateRenderView(isFullScreen)
        
        // update
        let ViewGap: CGFloat = 2
        
        let size = renderSmall.teacherViewSize
        let renderListHeight = renderSmall.renderListViewHeight
        let whiteBoardY = isFullScreen ? renderSmall.containerView.agora_safe_y : renderSmall.containerView.agora_safe_y + renderListHeight
        let whiteBoardRight: CGFloat = 0
        
        whiteBoard.containerView.agora_safe_y = whiteBoardY
        whiteBoard.containerView.agora_safe_right = whiteBoardRight
        
        UIView.animate(withDuration: TimeInterval.agora_animation) {
            self.appView.layoutSubviews()
        }
    }
    
    func resetSmallHandsUpLayout() {
        guard let `chat` = self.hxChat,
              let `handsUp` = self.handsUp else {
            return
        }
        
        let right = chat.containerView.agora_safe_right + chat.containerView.agora_width + 10 - 8
        handsUp.containerView.agora_safe_right = right
    }
}
