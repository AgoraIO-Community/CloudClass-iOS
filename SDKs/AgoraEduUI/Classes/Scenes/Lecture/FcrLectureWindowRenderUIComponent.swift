//
//  FcrLectureWindowRenderUIController.swift
//  AgoraEduUI
//
//  Created by Cavan on 2022/6/12.
//

import AgoraEduCore
import UIKit

protocol FcrWindowRenderUIComponentDragDelegate: NSObjectProtocol {
    func renderUIComponent(_ component: FcrWindowRenderUIComponent,
                           starDrag item: FcrWindowRenderViewState,
                           location: CGPoint)
    
    func renderUIComponent(_ component: FcrWindowRenderUIComponent,
                           dragging item: FcrWindowRenderViewState,
                           to location: CGPoint)
    
    func renderUIComponent(_ component: FcrWindowRenderUIComponent,
                           didEndDrag item: FcrWindowRenderViewState,
                           location: CGPoint)
}

extension FcrWindowRenderUIComponentDragDelegate {
    func renderUIComponent(_ component: FcrWindowRenderUIComponent,
                           starDrag item: FcrWindowRenderViewState,
                           location: CGPoint) {}
    func renderUIComponent(_ component: FcrWindowRenderUIComponent,
                           dragging item: FcrWindowRenderViewState,
                           to location: CGPoint) {}
    func renderUIComponent(_ component: FcrWindowRenderUIComponent,
                           didEndDrag item: FcrWindowRenderViewState,
                           location: CGPoint) {}
}

class FcrLectureWindowRenderUIComponent: FcrTeacherWindowRenderUIComponent {
    weak var dragDelegate: FcrWindowRenderUIComponentDragDelegate? {
        didSet {
            view.removeGestureRecognizers()
            
            if dragDelegate != nil {
                let panGesture = UIPanGestureRecognizer(target: self,
                                                        action: #selector(onDrag(_:)))
                view.addGestureRecognizer(panGesture)
            }
        }
    }
    
    override func initViews() {
        super.initViews()
        
        let teacherIndexPath = IndexPath(item: 0,
                                         section: 0)
        
        let teacherView = collectionView.cellForItem(at: teacherIndexPath)
        
        teacherView?.agora_enable = UIConfig.teacherVideo.enable
        teacherView?.agora_visible = UIConfig.teacherVideo.visible
    }
    
    override func addItemOfTeacher(_ user: AgoraEduContextUserInfo) {
        guard let stream = streamController.firstCameraStream(of: user) else {
            return
        }
        
        let item = createItem(with: stream)
        updateItem(item,
                   index: 0)
    }
    
    override func deleteItemOfTeacher(_ user: AgoraEduContextUserInfo) {
        updateItem(.none,
                   index: 0)
    }
    
    @objc func onDrag(_ sender: UIPanGestureRecognizer) {
        let point = sender.location(in: collectionView)
        
        //        guard let indexPath = collectionView.indexPathForItem(at: point),
        //              let cell = collectionView.cellForItem(at: indexPath)
        //        else {
        //            return
        //        }
        
        let item = dataSource[0]
        switch sender.state {
        case .began:
            dragDelegate?.renderUIComponent(self,
                                            starDrag: item,
                                            location: point)
        case .changed:
            dragDelegate?.renderUIComponent(self,
                                            dragging: item,
                                            to: point)
        case .recognized: fallthrough
        case .ended:
            dragDelegate?.renderUIComponent(self,
                                            didEndDrag: item,
                                            location: point)
            break
        default:
            break
        }
    }
}
