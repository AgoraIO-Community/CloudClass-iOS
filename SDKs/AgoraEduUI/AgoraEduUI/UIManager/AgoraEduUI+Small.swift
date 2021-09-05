//
//  AgoraEduUI+Small.swift
//  AgoraEduUI
//
//  Created by SRS on 2021/4/16.
//

import AgoraUIEduBaseViews
import AgoraUIBaseViews

extension AgoraEduUI {
    func addSmallContainerViews() {
        guard let `room` = self.room,
              let `whiteBoard` = self.whiteBoard,
              let `shareScreen` = self.shareScreen,
              let `renderSmall` = self.renderSmall,
              let `handsUp` = self.handsUp,
              let `userList` = self.userList else  {
            return
        }
        
        appView.addSubview(room.containerView)
        appView.addSubview(renderSmall.containerView)
        appView.addSubview(shareScreen.containerView)
        appView.addSubview(whiteBoard.containerView)
        appView.addSubview(handsUp.containerView)
        appView.addSubview(userList.containerView)
        
        if let `chat` = self.chat {
            appView.addSubview(chat.containerView)
        }
    }

    func layoutSmallContainerViews() {
        guard let `room` = self.room,
              let `whiteBoard` = self.whiteBoard,
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
        
        if let `chat` = self.chat,
           !isHyChat {
            chat.containerView.agora_width = 56
            chat.containerView.agora_height = 56
            chat.containerView.agora_safe_bottom = 2
            chat.containerView.agora_safe_right = 10
            
            guard let message = ["isMin": 1].jsonString() else {
                return
            }
            
            chat.widgetDidReceiveMessage(message)
        }
        
        shareScreen.containerView.agora_equal_to(view: whiteBoard.containerView,
                                                 attribute: .top)
        shareScreen.containerView.agora_equal_to(view: whiteBoard.containerView,
                                                 attribute: .left)
        shareScreen.containerView.agora_equal_to(view: whiteBoard.containerView,
                                                 attribute: .right)
        shareScreen.containerView.agora_equal_to(view: whiteBoard.containerView,
                                                 attribute: .bottom)
        
        whiteBoard.containerView.agora_safe_x = 0
        whiteBoard.containerView.agora_safe_y = top
        whiteBoard.containerView.agora_safe_bottom = 0
        whiteBoard.containerView.agora_safe_right = 0
        
        if let `chat` = self.chat,
           !isHyChat {
            handsUp.containerView.agora_safe_right = chat.containerView.agora_safe_right + chat.containerView.agora_width + 10 - 8
        } else {
            handsUp.containerView.agora_safe_right = 2
        }
        
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
    
    func layoutSmallView() {
        guard let `renderSmall` = self.renderSmall,
              let `whiteBoard` = self.whiteBoard else {
            return
        }
        
        renderSmall.updateRenderView(isFullScreen)
        
        let userExistFlag: Bool = hasCoHosts || teacherIn
        // update
        if isFullScreen || !userExistFlag {
            // 全屏/非全屏，但无老师且无人上台
            whiteBoard.containerView.agora_safe_y = renderSmall.containerView.agora_safe_y
        } else {
            whiteBoard.containerView.agora_safe_y = renderSmall.containerView.agora_safe_y + renderSmall.containerView.agora_height + 2
        }
        
        UIView.animate(withDuration: TimeInterval.agora_animation) {
            self.appView.layoutSubviews()
        }
    }
    
    func resetSmallHandsUpLayout() {
        guard let `handsUp` = self.handsUp else {
            return
        }
        
        if let `chat` = self.chat {
            let right = chat.containerView.agora_safe_right + chat.containerView.agora_width + 10 - 8
            handsUp.containerView.agora_safe_right = right
        } else {
            handsUp.containerView.agora_safe_right = 2
        }
        
        UIView.animate(withDuration: TimeInterval.agora_animation) {
            self.appView.layoutSubviews()
        }
    }
}
