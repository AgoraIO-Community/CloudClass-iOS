//
//  AgoraUIManager+Lecture.swift
//  AgoraEduSDK
//
//  Created by Cavan on 2021/4/22.
//

import Foundation
import AgoraUIBaseViews
import AgoraUIEduBaseViews

extension AgoraUIManager {
    func addLectureContainerViews() {
        guard let `room` = self.room,
              let `whiteBoard` = self.whiteBoard,
              let `chat` = self.chat,
              let `shareScreen` = self.shareScreen,
              let `renderLecture` = self.renderLecture,
              let `handsUp` = self.handsUp,
              let `userList` = self.userList else  {
            return
        }
        
        appView.addSubview(room.containerView)
        appView.addSubview(renderLecture.containerView)
        appView.addSubview(whiteBoard.containerView)
        whiteBoard.containerView.addSubview(shareScreen.containerView)
        whiteBoard.containerView.sendSubviewToBack(shareScreen.containerView)
        appView.addSubview(chat.containerView)
        appView.addSubview(handsUp.containerView)
        appView.addSubview(userList.containerView)
    }

    func layoutLectureContainerViews() {
        guard let `room` = self.room,
              let `whiteBoard` = self.whiteBoard,
              let `chat` = self.chat,
              let `shareScreen` = self.shareScreen,
              let `renderLecture` = self.renderLecture,
              let `handsUp` = self.handsUp,
              let `userList` = self.userList else  {
            return
        }
        
        let ViewGap: CGFloat = 2
        let isPad = AgoraKitDeviceAssistant.OS.isPad
        let top = (isPad ? 44 : 34) + ViewGap

        room.containerView.agora_x = 0
        room.containerView.agora_right = 0
        room.containerView.agora_height = isPad ? 44 : 34
        room.containerView.agora_safe_y = 0

        let size = renderLecture.teacherViewSize
        let renderListHeight = renderLecture.renderListViewHeight
        
        renderLecture.containerView.agora_safe_x = 0
        renderLecture.containerView.agora_safe_y = top
        renderLecture.containerView.agora_safe_right = 0
        renderLecture.containerView.agora_height = max(size.height,
                                                     renderListHeight)

        resetLectureChatLayout(false)
        
        shareScreen.containerView.agora_x = 0
        shareScreen.containerView.agora_y = 0
        shareScreen.containerView.agora_bottom = 0
        shareScreen.containerView.agora_right = 0

        whiteBoard.containerView.agora_safe_x = 0
        whiteBoard.containerView.agora_safe_y = renderLecture.containerView.agora_safe_y
        whiteBoard.containerView.agora_safe_bottom = 0
        whiteBoard.containerView.agora_safe_right = size.width + ViewGap
        
        handsUp.containerView.agora_safe_right = chat.containerView.agora_safe_right + chat.containerView.agora_width + 10 - 8
        handsUp.containerView.agora_safe_bottom = 2
    
        userList.containerView.agora_safe_x = whiteBoard.containerView.agora_safe_x + (isPad ? 65 : 57)
        userList.containerView.agora_width = 300
        userList.containerView.agora_safe_y = isPad ? (whiteBoard.containerView.agora_safe_y + 101) : (top - ViewGap)
        userList.containerView.agora_height = 312
    }
    
    func layoutLectureView(_ isFullScreen: Bool,
                         coHostsCount: Int) {
        guard let `renderLecture` = self.renderLecture,
              let `whiteBoard` = self.whiteBoard,
              let `chat` = self.chat,
              let `userlist` = self.userList else {
            return
        }
        
        renderLecture.updateRenderView(isFullScreen,
                                     coHostsCount: self.coHostCount)
        
        // update
        let ViewGap: CGFloat = 2
        let isPad = AgoraKitDeviceAssistant.OS.isPad
        let top = (isPad ? 44 : 34) + ViewGap
        
        let size = renderLecture.teacherViewSize
        let renderListHeight = renderLecture.renderListViewHeight
        let whiteBoardY = (isFullScreen || coHostsCount == 0) ? renderLecture.containerView.agora_safe_y : renderLecture.containerView.agora_safe_y + renderListHeight
        let whiteBoardRight = isFullScreen ? 0 : renderLecture.containerView.agora_safe_right + size.width + ViewGap
        
        whiteBoard.containerView.agora_safe_y = whiteBoardY
        whiteBoard.containerView.agora_safe_right = whiteBoardRight
        
        userlist.containerView.agora_safe_y = isPad ? (whiteBoard.containerView.agora_safe_y + 50.5) : (top - ViewGap)
        
        if let message = ["isFullScreen": (isFullScreen ? 1 : 0)].jsonString() {
            chat.widgetDidReceiveMessage(message)
        }
        
        self.resetLectureChatLayout(isFullScreen)
        self.resetLectureHandsUpLayout(isFullScreen)
        
        UIView.animate(withDuration: TimeInterval.agora_animation) {
            self.appView.layoutSubviews()
        }
    }
        
    private func resetLectureChatLayout(_ isFullScreen: Bool) {
        guard let `chat` = self.chat,
              let `renderLecture` = self.renderLecture,
              let `whiteBoard` = self.whiteBoard,
              let `handsUp` = self.handsUp else {
            return
        }
        
        if isFullScreen {
            chat.containerView.agora_safe_bottom = handsUp.containerView.agora_safe_bottom
            chat.containerView.agora_safe_right = whiteBoard.containerView.agora_safe_right + 10
        } else {
            let ViewGap: CGFloat = 2
            
            let size = renderLecture.teacherViewSize
            let kScreenHeight = min(UIScreen.agora_width,
                                    UIScreen.agora_height)
            let safeSpace = UIScreen.agora_safe_area_top + UIScreen.agora_safe_area_bottom
            let renderSmallMaxY = renderLecture.containerView.agora_safe_y + size.height
            let chatHeight = kScreenHeight - safeSpace - renderSmallMaxY - ViewGap
            
            chat.containerView.agora_safe_right = renderLecture.containerView.agora_safe_right
            chat.containerView.agora_width = size.width
            chat.containerView.agora_height = chatHeight
            chat.containerView.agora_safe_bottom = 0
        }
    }
    
    func resetLectureHandsUpLayout(_ isFullScreen: Bool) {
        guard let `chat` = self.hxChat,
              let `handsUp` = self.handsUp else {
            return
        }
        
        let right = chat.containerView.agora_safe_right + chat.containerView.agora_width + 10 - 8
        handsUp.containerView.agora_safe_right = right
    }
}

