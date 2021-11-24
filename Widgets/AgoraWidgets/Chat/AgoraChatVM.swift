//
//  AgoraChatVM.swift
//  AgoraWidgets
//
//  Created by Cavan on 2021/7/21.
//

import Foundation
import AgoraEduContext

//struct AgoraChatItem {
//    let info: AgoraEduContextChatInfo
//    let nameLabelRect: CGRect
//    let messageContentViewRect: CGRect
//    let messageLabelRect: CGRect
//    let textSize: CGSize
//    let failViewRect: CGRect
//    let cellHeight: CGFloat
//    let cellWidth: CGFloat
//    let font: UIFont
//    let failViewAndContentViewGap: CGFloat = 8
//
//    init(info: AgoraEduContextChatInfo,
//         font: UIFont,
//         cellWidth: CGFloat) {
//        self.info = info
//
//        let xGap: CGFloat = 15
//
//        // nameLabel rect
//        let nameLabelX: CGFloat = xGap
//        let nameLabelY: CGFloat = 4
//        let nameLabelWidth: CGFloat = cellWidth - (2 * xGap)
//        let nameLabelHeight: CGFloat = 15
//        self.nameLabelRect = CGRect(x: nameLabelX,
//                                    y: nameLabelY,
//                                    width: nameLabelWidth,
//                                    height: nameLabelHeight)
//
//        // fail view rect
//        let failViewX: CGFloat = xGap
//        let failViewY: CGFloat = 0
//        let failViewWidth: CGFloat = 15
//        let failViewHeight: CGFloat = 15
//
//        var failViewRect = CGRect(x: failViewX,
//                                  y: 0,
//                                  width: failViewWidth,
//                                  height: failViewHeight)
//
//        // messageLabel rect
//        let xMessageLabelGap: CGFloat = 9
//        let yMessageLabelGap: CGFloat = 10
//        let messageLabelX: CGFloat = xMessageLabelGap
//        let messageLabelY: CGFloat = yMessageLabelGap
//
//        let messageLabelMaxWidth: CGFloat = cellWidth - (xGap * 2) - (xMessageLabelGap * 2) - failViewRect.maxX - failViewAndContentViewGap
//
//        // message text size
//        let size = info.message.agora_size(font: font,
//                                           width: messageLabelMaxWidth)
//        self.textSize = size
//        self.messageLabelRect = CGRect(x: messageLabelX,
//                                       y: messageLabelY,
//                                       width: size.width,
//                                       height: size.height)
//
//        // message content view rect
//        let messageContentViewAndNameLabelGap: CGFloat = 5
//        let messageContentViewX: CGFloat = xGap
//        let messageContentViewY: CGFloat = nameLabelRect.maxY + messageContentViewAndNameLabelGap
//        let messageContentViewWidth: CGFloat = messageLabelRect.width + (2 * xMessageLabelGap)
//        let messageContentViewHeight: CGFloat = messageLabelRect.height + (2 * yMessageLabelGap)
//        self.messageContentViewRect = CGRect(x: messageContentViewX,
//                                             y: messageContentViewY,
//                                             width: messageContentViewWidth,
//                                             height: messageContentViewHeight)
//
//        let messageContentViewAndCellBottomGap: CGFloat = 3
//
//        // update failView Y
//        failViewRect.origin.y = messageContentViewRect.maxY - failViewRect.size.height
//        self.failViewRect = failViewRect
//
//        // cell height
//        self.cellHeight = messageContentViewRect.maxY + messageContentViewAndCellBottomGap
//        self.cellWidth = cellWidth
//
//        self.font = font
//    }
//}
//
//fileprivate extension Array where Element == AgoraChatItem {
//    init(list: [AgoraEduContextChatInfo],
//         font: UIFont,
//         cellWidth: CGFloat) {
//        var array = [AgoraChatItem]()
//
//        for element in list {
//            let item = AgoraChatItem(info: element,
//                                     font: font,
//                                     cellWidth: cellWidth)
//            array.append(item)
//        }
//
//        self = array
//    }
//}
//
//class AgoraChatVM: NSObject {
//    private(set) var roomMessages = [AgoraChatItem]()
//    private(set) var conversationMessages = [AgoraChatItem]()
//
//    let font = UIFont.systemFont(ofSize: 12)
//    let cellWidth: CGFloat = (UIDevice.current.isPad ? 300 : 200)
//
//    func appendRoomMessages(_ elements: [AgoraEduContextChatInfo]) {
//        let array = [AgoraChatItem](list: elements,
//                                    font: font,
//                                    cellWidth: cellWidth)
//
//        roomMessages.append(contentsOf: array)
//    }
//
//    func insertRoomMessage(_ elements: [AgoraEduContextChatInfo]) {
//        let array = [AgoraChatItem](list: elements,
//                                    font: font,
//                                    cellWidth: cellWidth)
//
//        roomMessages.insert(contentsOf: array,
//                            at: 0)
//    }
//
//    func appendConversationMessages(_ elements: [AgoraEduContextChatInfo]) {
//        let array = [AgoraChatItem](list: elements,
//                                    font: font,
//                                    cellWidth: cellWidth)
//
//        conversationMessages.append(contentsOf: array)
//    }
//
//    func insertConversationMessage(_ elements: [AgoraEduContextChatInfo]) {
//        let array = [AgoraChatItem](list: elements,
//                                    font: font,
//                                    cellWidth: cellWidth)
//
//        conversationMessages.insert(contentsOf: array,
//                                    at: 0)
//    }
//}
