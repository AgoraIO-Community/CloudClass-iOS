//
//  PaintingBoardUIController.swift
//  AgoraEduUI
//
//  Created by Cavan on 2021/10/10.
//

import AgoraEduContext
import AgoraWidget
import Masonry
import UIKit

protocol AgoraPaintingBoardUIControllerDelegate: NSObjectProtocol {
    func controller(_ controller: AgoraPaintingBoardUIController,
                    didUpdateBoard permission: Bool)
}

class AgoraPaintingBoardUIController: UIViewController {
    private weak var contentView: UIView? // 为白板widget的视图
    private weak var boardWidget: AgoraBaseWidget?
    weak var delegate: AgoraPaintingBoardUIControllerDelegate?
    var contextPool: AgoraEduContextPool
    
    init(context: AgoraEduContextPool) {
        contextPool = context
        super.init(nibName: nil,
                   bundle: nil)
        context.widget.add(self,
                           widgetId: "netlessBoard")
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

extension AgoraPaintingBoardUIController: AgoraWidgetMessageObserver {
    func onMessageReceived(_ message: String,
                           widgetId: String) {
        guard widgetId == "netlessBoard",
        let messageDic = message.json() else {
            return
        }
        
        
    }
}

//extension AgoraPaintingBoardUIController: AgoraEduWhiteBoardHandler {
//    func onDrawingEnabled(_ enabled: Bool) {
//        delegate?.controller(self,
//                             didUpdateBoard: enabled)
//    }
//
//    func onBoardContentView(_ view: UIView) {
//        guard contentView == nil else {
//            return
//        }
//
//        contentView = view
//
//        self.view.addSubview(view)
//
//        view.mas_makeConstraints { make in
//            make?.left.right().bottom().top().equalTo()(view.superview)
//        }
//    }
//}
