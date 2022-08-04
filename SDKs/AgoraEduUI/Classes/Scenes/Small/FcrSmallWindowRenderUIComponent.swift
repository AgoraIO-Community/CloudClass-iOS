//
//  FcrSmallWindowRenderUIController.swift
//  AgoraEduUI
//
//  Created by Cavan on 2022/6/9.
//

import AgoraUIBaseViews
import AgoraEduContext
import Foundation

class FcrSmallWindowRenderUIComponent: UIViewController {
    let coHost: FcrCoHostWindowRenderUIComponent
    let teacher: FcrTeacherWindowRenderUIComponent
    
    weak var delegate: FcrWindowRenderUIComponentDelegate?
    
    init(context: AgoraEduContextPool,
         subRoom: AgoraEduSubRoomContext? = nil,
         delegate: FcrWindowRenderUIComponentDelegate? = nil,
         componentDataSource: FcrUIComponentDataSource? = nil) {
        self.coHost = FcrCoHostWindowRenderUIComponent(context: context,
                                                       subRoom: subRoom,
                                                       componentDataSource: componentDataSource)
        
        self.teacher = FcrTeacherWindowRenderUIComponent(context: context,
                                                         subRoom: subRoom)
        
        super.init(nibName: nil,
                   bundle: nil)
        
        self.coHost.delegate = self
        self.teacher.delegate = self
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
        coHost.updateLayout(coHostLayout)
        
        let teacherLayout = layout.copyLayout()
        teacher.updateLayout(teacherLayout)
        
        updateViewFrame()
    }
    
    func getRenderView(userId: String) -> FcrWindowRenderView? {
        if let renderView = teacher.getRenderView(userId: userId) {
            return renderView
        } else if let renderView = coHost.getRenderView(userId: userId) {
            return renderView
        }
        
        return nil
    }
    
    func getItem(streamId: String) -> FcrWindowRenderViewState? {
        if let item = teacher.getItem(streamId: streamId) {
            return item
        } else if let item = coHost.getItem(streamId: streamId) {
            return item
        }
        
        return nil
    }
    
    func updateItem(_ item: FcrWindowRenderViewState,
                    animation: Bool = true) {
        teacher.updateItem(item,
                           animation: animation)
        coHost.updateItem(item,
                          animation: animation)
    }
}

extension FcrSmallWindowRenderUIComponent: AgoraUIContentContainer, AgoraUIActivity {
    func initViews() {
        addChild(coHost)
        addChild(teacher)
        
        view.addSubview(coHost.view)
        view.addSubview(teacher.view)
        
        teacher.view.agora_enable = UIConfig.teacherVideo.enable
        teacher.view.agora_visible = UIConfig.teacherVideo.visible
        
        coHost.view.agora_enable = UIConfig.studentVideo.enable
        coHost.view.agora_visible = UIConfig.studentVideo.visible
    }
    
    func initViewFrame() {
        coHost.view.mas_makeConstraints { make in
            make?.left.top().right().bottom().equalTo()(0)
        }
        
        teacher.view.mas_makeConstraints { make in
            make?.left.top().bottom().equalTo()(0)
            make?.right.equalTo()(coHost.view.mas_left)?.equalTo()(0)
        }
    }
    
    func updateViewProperties() {
        
    }
    
    func viewWillActive() {
        coHost.viewWillActive()
        teacher.viewWillActive()
    }
    
    func viewWillInactive() {
        coHost.viewWillInactive()
        teacher.viewWillInactive()
    }
}

private extension FcrSmallWindowRenderUIComponent {
    func updateViewFrame() {
        let coHostCount = CGFloat(coHost.dataSource.count)
        let teacherCount = CGFloat(teacher.dataSource.count)
        let count = (teacherCount + coHostCount)
        
        let itemWidth = coHost.layout.itemSize.width
        let itemLineSpacing = coHost.layout.minimumLineSpacing
        
        let itemsWidth = (itemWidth + itemLineSpacing) * count - itemLineSpacing
        var firstItemX = (view.bounds.width - itemsWidth) * 0.5
        
        if firstItemX <= 0 {
            firstItemX = 0
        }
        
        let coHostLeft = (itemWidth + itemLineSpacing) * teacherCount + firstItemX
        
        coHost.view.mas_remakeConstraints { make in
            make?.top.right().bottom().equalTo()(0)
            make?.left.equalTo()(coHostLeft)
        }
        
        teacher.view.mas_remakeConstraints { make in
            make?.left.top().bottom().equalTo()(0)
            make?.right.equalTo()(coHost.view.mas_left)?.equalTo()(-itemLineSpacing)
        }
        
        UIView.animate(withDuration: TimeInterval.agora_animation) {
            self.view.layoutIfNeeded()
        }
    }
}

extension FcrSmallWindowRenderUIComponent: FcrWindowRenderUIComponentDelegate {
    func renderUIComponent(_ component: FcrWindowRenderUIComponent,
                           didDataSouceCountUpdated count: Int) {
        updateViewFrame()
    }
    
    func renderUIComponent(_ component: FcrWindowRenderUIComponent,
                           didPressItem item: FcrWindowRenderViewState,
                           view: UIView) {
        delegate?.renderUIComponent(component,
                                    didPressItem: item,
                                    view: view)
    }
}
