//
//  FcrSmallWindowRenderUIController.swift
//  AgoraEduUI
//
//  Created by Cavan on 2022/6/9.
//

import AgoraEduContext
import Foundation

class FcrSmallWindowRenderUIController: UIViewController {
    private let coHostUIController: FcrCoHostWindowRenderUIController
    private let teacherUIController: FcrTeacherWindowRenderUIController
    
    weak var delegate: FcrWindowRenderUIControllerDelegate?
    
    init(context: AgoraEduContextPool,
         subRoom: AgoraEduSubRoomContext? = nil,
         delegate: FcrWindowRenderUIControllerDelegate? = nil) {
        self.coHostUIController = FcrCoHostWindowRenderUIController(context: context,
                                                                    subRoom: subRoom)
        
        self.teacherUIController = FcrTeacherWindowRenderUIController(context: context,
                                                                      subRoom: subRoom)
        
        super.init(nibName: nil,
                   bundle: nil)
        
        self.coHostUIController.delegate = self
        self.teacherUIController.delegate = self
        self.delegate = delegate
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        initViews()
        initViewFrame()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func updateLayout(_ layout: UICollectionViewFlowLayout) {
        let coHostLayout = layout.copyLayout()
        coHostUIController.updateLayout(coHostLayout)
        
        let teacherLayout = layout.copyLayout()
        teacherUIController.updateLayout(teacherLayout)
        
        updateViewFrame()
    }
    
    func getRenderView(userId: String) -> FcrWindowRenderView? {
        if let renderView = teacherUIController.getRenderView(userId: userId) {
            return renderView
        } else if let renderView = coHostUIController.getRenderView(userId: userId) {
            return renderView
        }
        
        return nil
    }
    
    func getItem(streamId: String) -> FcrWindowRenderViewState? {
        if let item = teacherUIController.getItem(streamId: streamId) {
            return item
        } else if let item = coHostUIController.getItem(streamId: streamId) {
            return item
        }
        
        return nil
    }
    
    func updateItem(_ item: FcrWindowRenderViewState,
                    animation: Bool = true) {
        teacherUIController.updateItem(item,
                                       animation: animation)
        coHostUIController.updateItem(item,
                                      animation: animation)
    }
}

extension FcrSmallWindowRenderUIController: AgoraUIContentContainer, AgoraUIActivity {
    func initViews() {
        addChild(coHostUIController)
        addChild(teacherUIController)
        
        view.addSubview(coHostUIController.view)
        view.addSubview(teacherUIController.view)
    }
    
    func initViewFrame() {
        coHostUIController.view.mas_makeConstraints { make in
            make?.left.top().right().bottom().equalTo()(0)
        }
        
        teacherUIController.view.mas_makeConstraints { make in
            make?.left.top().bottom().equalTo()(0)
            make?.right.equalTo()(coHostUIController.view.mas_left)?.equalTo()(0)
        }
    }
    
    func updateViewProperties() {
        
    }
    
    func viewWillActive() {
        coHostUIController.viewWillActive()
        teacherUIController.viewWillActive()
    }
    
    func viewWillInactive() {
        coHostUIController.viewWillInactive()
        teacherUIController.viewWillInactive()
    }
}

private extension FcrSmallWindowRenderUIController {
    func updateViewFrame() {
        let coHostCount = CGFloat(coHostUIController.dataSource.count)
        let teacherCount = CGFloat(teacherUIController.dataSource.count)
        let count = (teacherCount + coHostCount)
        
        let itemWidth = coHostUIController.layout.itemSize.width
        let itemLineSpacing = coHostUIController.layout.minimumLineSpacing
        
        let itemsWidth = (itemWidth + itemLineSpacing) * count - itemLineSpacing
        var firstItemX = (view.bounds.width - itemsWidth) * 0.5
        
        if firstItemX <= 0 {
            firstItemX = 0
        }
        
        let coHostLeft = (itemWidth + itemLineSpacing) * teacherCount + firstItemX
        
        coHostUIController.view.mas_remakeConstraints { make in
            make?.top.right().bottom().equalTo()(0)
            make?.left.equalTo()(coHostLeft)
        }
        
        teacherUIController.view.mas_remakeConstraints { make in
            make?.left.top().bottom().equalTo()(0)
            make?.right.equalTo()(coHostUIController.view.mas_left)?.equalTo()(-itemLineSpacing)
        }
        
        UIView.animate(withDuration: TimeInterval.agora_animation) {
            self.view.layoutIfNeeded()
        }
    }
}

extension FcrSmallWindowRenderUIController: FcrWindowRenderUIControllerDelegate {
    func renderUIController(_ controller: FcrWindowRenderUIController,
                            didDataSouceCountUpdated count: Int) {
        updateViewFrame()
    }
    
    func renderUIController(_ controller: FcrWindowRenderUIController,
                            didPressItem item: FcrWindowRenderViewState,
                            view: UIView) {
        delegate?.renderUIController(controller,
                                     didPressItem: item,
                                     view: view)
    }
}
