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

        resetSmallChatLayout(false)
        
        shareScreen.containerView.agora_x = 0
        shareScreen.containerView.agora_y = 0
        shareScreen.containerView.agora_bottom = 0
        shareScreen.containerView.agora_right = 0

        whiteBoard.containerView.agora_safe_x = 0
        whiteBoard.containerView.agora_safe_y = renderSmall.containerView.agora_safe_y
        whiteBoard.containerView.agora_safe_bottom = 0
        whiteBoard.containerView.agora_safe_right = size.width + ViewGap
        
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
    
    func layoutSmallView(_ isFullScreen: Bool,
                         coHostsCount: Int) {
        guard let `renderSmall` = self.renderSmall,
              let `whiteBoard` = self.whiteBoard,
              let `chat` = self.chat else {
            return
        }
        
        renderSmall.updateRenderView(isFullScreen,
                                     coHostsCount: self.coHostCount)
        
        // update
        let ViewGap: CGFloat = 2
        
        let size = renderSmall.teacherViewSize
        let renderListHeight = renderSmall.renderListViewHeight
        let whiteBoardY = (isFullScreen || coHostsCount == 0) ? renderSmall.containerView.agora_safe_y : renderSmall.containerView.agora_safe_y + renderListHeight
        let whiteBoardRight = isFullScreen ? 0 : renderSmall.containerView.agora_safe_right + size.width + ViewGap
        
        whiteBoard.containerView.agora_safe_y = whiteBoardY
        whiteBoard.containerView.agora_safe_right = whiteBoardRight

        if let message = ["isFullScreen": (isFullScreen ? 1 : 0)].jsonString() {
            chat.widgetDidReceiveMessage(message)
        }
        
        self.resetSmallChatLayout(isFullScreen)
        self.resetSmallHandsUpLayout(isFullScreen)
        
        UIView.animate(withDuration: TimeInterval.agora_animation) {
            self.appView.layoutSubviews()
        }
    }
        
    private func resetSmallChatLayout(_ isFullScreen: Bool) {
        guard let `chat` = self.chat,
              let `renderSmall` = self.renderSmall,
              let `whiteBoard` = self.whiteBoard,
              let `handsUp` = self.handsUp else {
            return
        }
        
        if isFullScreen {
            chat.containerView.agora_safe_bottom = handsUp.containerView.agora_safe_bottom
            chat.containerView.agora_safe_right = whiteBoard.containerView.agora_safe_right + 10
        } else {
            let ViewGap: CGFloat = 2
            
            let size = renderSmall.teacherViewSize
            let kScreenHeight = min(UIScreen.agora_width,
                                    UIScreen.agora_height)
            let safeSpace = UIScreen.agora_safe_area_top + UIScreen.agora_safe_area_bottom
            let renderSmallMaxY = renderSmall.containerView.agora_safe_y + size.height
            let chatHeight = kScreenHeight - safeSpace - renderSmallMaxY - ViewGap
            
            chat.containerView.agora_safe_right = renderSmall.containerView.agora_safe_right
            chat.containerView.agora_width = size.width
            chat.containerView.agora_height = chatHeight
            chat.containerView.agora_safe_bottom = 0
        }
    }
    
    func resetSmallHandsUpLayout(_ isFullScreen: Bool) {
        guard let `chat` = self.chat,
              let `handsUp` = self.handsUp else {
            return
        }
        
        let right = chat.containerView.agora_safe_right + chat.containerView.agora_width + 10 - 8
        handsUp.containerView.agora_safe_right = right
    }
}
