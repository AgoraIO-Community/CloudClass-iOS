//
//  AgoraEduUI+1V1.swift
//  AgoraEduUI
//
//  Created by SRS on 2021/4/16.
//

import AgoraUIEduBaseViews
import AgoraUIBaseViews

//extension AgoraEduUI {
//    func add1V1ContainerViews() {
//        guard let `room` = self.room,
//              let `whiteBoard` = self.whiteBoard,
//              let `shareScreen` = self.shareScreen,
//              let `render1V1` = self.render1V1 else {
//            return
//        }
//
//        appView.addSubview(room.containerView)
//        appView.addSubview(render1V1.containerView)
//        appView.addSubview(shareScreen.containerView)
//        appView.addSubview(whiteBoard.containerView)
//
//        if let `chat` = self.chat {
//            appView.addSubview(chat.containerView)
//        }
//    }
//
//    func layout1V1ContainerViews() {
//        guard let `room` = self.room,
//              let `whiteBoard` = self.whiteBoard,
//              let `shareScreen` = self.shareScreen,
//              let `render1V1` = self.render1V1 else {
//            return
//        }
//
//        let isPad = AgoraKitDeviceAssistant.OS.isPad
//
//        room.containerView.agora_x = 0
//        room.containerView.agora_right = 0
//        room.containerView.agora_height = isPad ? 44 : 34
//        room.containerView.agora_safe_y = 0
//
//        let ViewGap: CGFloat = 2
//        let top = (isPad ? 44 : 34) + ViewGap
//        let size = get1V1RenderViewSize()
//
//        render1V1.containerView.agora_width = size.width
//        render1V1.containerView.agora_safe_y = top
//        render1V1.containerView.agora_safe_right = 0
//        render1V1.containerView.agora_height = size.height * 2 + ViewGap
//
//        if let `chat` = self.chat,
//           !isHyChat {
//            chat.containerView.agora_safe_right = size.width + 10
//            chat.containerView.agora_width = 56
//            chat.containerView.agora_height = 56
//            chat.containerView.agora_safe_bottom = 0
//        }
//
//        shareScreen.containerView.agora_equal_to(view: whiteBoard.containerView,
//                                                 attribute: .top)
//        shareScreen.containerView.agora_equal_to(view: whiteBoard.containerView,
//                                                 attribute: .left)
//        shareScreen.containerView.agora_equal_to(view: whiteBoard.containerView,
//                                                 attribute: .right)
//        shareScreen.containerView.agora_equal_to(view: whiteBoard.containerView,
//                                                 attribute: .bottom)
//
//        whiteBoard.containerView.agora_safe_x = 0
//        whiteBoard.containerView.agora_safe_y = top
//        whiteBoard.containerView.agora_safe_bottom = 0
//        whiteBoard.containerView.agora_safe_right = size.width + ViewGap
//    }
//
//    func layout1V1FullScreen(_ isFullScreen: Bool) {
//        guard let render1V1 = render1V1 else {
//            return
//        }
//
//        render1V1.updateRenderView(fullScreen: isFullScreen)
//
//        guard let chatView = chat?.containerView else {
//            return
//        }
//
//        let render1V1RightSpcae = render1V1.containerView.agora_safe_right + render1V1.containerView.agora_width
//        let ViewGap: CGFloat = 2
//
//        let chatViewSafeRight = render1V1RightSpcae + ViewGap
//        chatView.agora_safe_right = isFullScreen ? 10 : chatViewSafeRight
//
//        guard let whiteBoardView = whiteBoard?.containerView else {
//            return
//        }
//
//        whiteBoardView.agora_safe_right = isFullScreen ? 0 : render1V1RightSpcae + ViewGap
//
//        UIView.animate(withDuration: TimeInterval.agora_animation) {
//            self.appView.layoutIfNeeded()
//        }
//    }
//
//    func resetOneToOneAgoraChatLayout(isMin: Bool) {
//        guard let `chat` = self.chat,
//              !isHyChat else {
//            return
//        }
//
//        let size = get1V1RenderViewSize()
//
//        if isMin {
//            chat.containerView.agora_safe_right = isFullScreen ? 10 : size.width + 10
//            chat.containerView.agora_width = 56
//            chat.containerView.agora_height = 56
//            chat.containerView.agora_safe_bottom = 0
//        } else {
//            let isPad = UIDevice.current.isPad
//            let kAgoraScreenHeight: CGFloat = min(UIScreen.agora_width,
//                                                  UIScreen.agora_height)
//
//            let chatWidth: CGFloat = (isPad ? 300 : 200)
//            let chatHeight: CGFloat = (isPad ? 400 : kAgoraScreenHeight - 34 - renderTop - 10)
//
//            chat.containerView.agora_safe_right = isFullScreen ? 10 : size.width + 10
//            chat.containerView.agora_width = chatWidth
//            chat.containerView.agora_height = chatHeight
//            chat.containerView.agora_safe_bottom = 0
//        }
//
//        UIView.animate(withDuration: TimeInterval.agora_animation) {
//            self.appView.layoutIfNeeded()
//        }
//    }
//
//    private func get1V1RenderViewSize() -> CGSize {
//        let isPad = AgoraKitDeviceAssistant.OS.isPad
//
//        let kAgoraScreenWidth: CGFloat = max(UIScreen.agora_width,
//                                             UIScreen.agora_height)
//        let kAgoraScreenHeight: CGFloat = min(UIScreen.agora_width,
//                                              UIScreen.agora_height)
//
//        let top: CGFloat = renderTop + 4
//
//        var width: CGFloat = 0
//        var height: CGFloat = 0
//
//        if isPad {
//            height = 168
//            width = 300
//        } else {
//            let screen_safe_bottom: CGFloat = min(UIScreen.agora_safe_area_bottom,
//                                                  21)
//            let videoHeight: CGFloat = (kAgoraScreenHeight - screen_safe_bottom - top) * 0.5
//            height = videoHeight
//            width = height
//        }
//
//        return CGSize(width: width,
//                      height: height)
//    }
//}
