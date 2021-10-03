//
//  AgoraEduUI+Painting.swift
//  AgoraEduUI
//
//  Created by HeZhengQing on 2021/9/9.
//

import AgoraUIEduBaseViews
import AgoraUIBaseViews

extension AgoraEduUI {
    func addPaintingContainerViews() {
        self.paintingSmall = PaintingRoomViewController(context: contextPool)
        guard let paintingSmall = self.paintingSmall else {
            return
        }
        paintingSmall.contextPool = self.contextPool
        appView.addSubview(paintingSmall.view)
        
        paintingSmall.view.agora_x = 0
        paintingSmall.view.agora_y = 0
        paintingSmall.view.agora_bottom = 0
        paintingSmall.view.agora_right = 0
        
        return
        guard let `room` = self.room,
              let `whiteBoard` = self.whiteBoard,
              let `shareScreen` = self.shareScreen,
              //let `renderPainting` = self.renderPainting,
              let `handsUp` = self.handsUp,
              let `userList` = self.userList else  {
            return
        }
        appView.addSubview(room.containerView)
        appView.addSubview(whiteBoard.containerView)
        //appView.addSubview(renderPainting.containerView)
        appView.addSubview(shareScreen.containerView)
        appView.addSubview(handsUp.containerView)
        appView.addSubview(userList.containerView)

        if let `chat` = self.chat {
            appView.addSubview(chat.containerView)
        }
    }

    func layoutPaintingContainerViews() {
        return
        guard let `room` = self.room,
              let `whiteBoard` = self.whiteBoard,
              let `shareScreen` = self.shareScreen,
              //let `renderPainting` = self.renderPainting,
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
        
//        let size = renderPainting.teacherViewSize
//        let renderListHeight = renderPainting.renderListViewHeight
        
//        renderPainting.containerView.agora_safe_x = 0
//        renderPainting.containerView.agora_safe_y = top
//        renderPainting.containerView.agora_safe_right = 0
//        renderPainting.containerView.agora_height = max(size.height,
//                                                     renderListHeight)
//        renderPainting.containerView.agora_height = 95
        
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
            //userList.containerView.agora_center_x = -(size.width * 0.5)
            userList.containerView.agora_center_y = 0
        } else {
            userList.containerView.agora_safe_x = whiteBoard.containerView.agora_safe_x + 60
            userList.containerView.agora_safe_y = top
        }
    }
    
    func layoutPaintingView() {
        return
        guard //let `renderPainting` = self.renderPainting,
              let `whiteBoard` = self.whiteBoard else {
            return
        }
        
//        renderPainting.updateRenderView(isFullScreen)
        
        let userExistFlag: Bool = hasCoHosts || teacherIn
        // update
        if isFullScreen || !userExistFlag {
            // 全屏/非全屏，但无老师且无人上台
            //whiteBoard.containerView.agora_safe_y = renderPainting.containerView.agora_safe_y
        } else {
            //whiteBoard.containerView.agora_safe_y = renderPainting.containerView.agora_safe_y + renderPainting.containerView.agora_height + 2
        }
        
        UIView.animate(withDuration: TimeInterval.agora_animation) {
            self.appView.layoutSubviews()
        }
    }
    
    func resetPaintingHandsUpLayout() {
        return
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

