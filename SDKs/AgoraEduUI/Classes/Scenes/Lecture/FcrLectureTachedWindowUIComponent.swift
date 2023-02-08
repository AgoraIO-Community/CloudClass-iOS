//
//  FcrLectureWindowRenderUIController.swift
//  AgoraEduUI
//
//  Created by Cavan on 2022/6/12.
//

import AgoraEduCore
import UIKit

protocol FcrTachedStreamWindowUIComponentDragDelegate: NSObjectProtocol {
    func tachedStreamWindowUIComponent(_ component: FcrTachedStreamWindowUIComponent,
                                       starDrag item: FcrTachedWindowRenderViewState,
                                       location: CGPoint)
    
    func tachedStreamWindowUIComponent(_ component: FcrTachedStreamWindowUIComponent,
                                       dragging item: FcrTachedWindowRenderViewState,
                                       to location: CGPoint)
    
    func tachedStreamWindowUIComponent(_ component: FcrTachedStreamWindowUIComponent,
                                       didEndDrag item: FcrTachedWindowRenderViewState,
                                       location: CGPoint)
}

extension FcrTachedStreamWindowUIComponentDragDelegate {
    func tachedStreamWindowUIComponent(_ component: FcrTachedStreamWindowUIComponent,
                                       starDrag item: FcrTachedWindowRenderViewState,
                                       location: CGPoint) {}
    func tachedStreamWindowUIComponent(_ component: FcrTachedStreamWindowUIComponent,
                                       dragging item: FcrTachedWindowRenderViewState,
                                       to location: CGPoint) {}
    func tachedStreamWindowUIComponent(_ component: FcrTachedStreamWindowUIComponent,
                                       didEndDrag item: FcrTachedWindowRenderViewState,
                                       location: CGPoint) {}
}

class FcrLectureTachedWindowUIComponent: FcrTeacherTachedWindowUIComponent {
    weak var dragDelegate: FcrTachedStreamWindowUIComponentDragDelegate? {
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
            dragDelegate?.tachedStreamWindowUIComponent(self,
                                                        starDrag: item,
                                                        location: point)
        case .changed:
            dragDelegate?.tachedStreamWindowUIComponent(self,
                                                        dragging: item,
                                                        to: point)
        case .recognized: fallthrough
        case .ended:
            dragDelegate?.tachedStreamWindowUIComponent(self,
                                                        didEndDrag: item,
                                                        location: point)
            break
        default:
            break
        }
    }
}
