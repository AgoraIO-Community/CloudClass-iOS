//
//  AgoraEduUI+Lecture.swift
//  AgoraEduSDK
//
//  Created by Cavan on 2021/4/22.
//

import AgoraUIBaseViews
import AgoraEduCore
import AudioToolbox
import AgoraWidget
import UIKit

/// 房间控制器:
/// 用以处理全局状态和子控制器之间的交互关系
@objc public class FcrLectureUIScene: FcrUIScene, AgoraEduStreamHandler {
    /** 全局状态 控制器（自身不包含UI）*/
    private lazy var globalComponent = FcrRoomGlobalUIComponent(roomController: contextPool.room,
                                                                userController: contextPool.user,
                                                                monitorController: contextPool.monitor,
                                                                streamController: contextPool.stream,
                                                                groupController: contextPool.group,
                                                                exitDelegate: self)
    
    /** 音频流 控制器（自身不包含UI）*/
    private lazy var audioComponent = FcrAudioStreamUIComponent(roomController: contextPool.room,
                                                                streamController: contextPool.stream,
                                                                userController: contextPool.user,
                                                                mediaController: contextPool.media)
    
    /** 花名册 控制器 （教师端）*/
    private lazy var nameRollComponent = FcrLectureRosterUIComponent(userController: contextPool.user,
                                                                     streamController: contextPool.stream)
    
    /** 设置界面 控制器*/
    private lazy var settingComponent = FcrSettingUIComponent(mediaController: contextPool.media,
                                                              widgetController: contextPool.widget,
                                                              delegate: self,
                                                              exitDelegate: self)
    
    /** 举手列表 控制器（仅教师端）*/
    private lazy var handsListComponent = FcrHandsListUIComponent(userController: contextPool.user,
                                                                  delegate: self)
    
    /** 视窗菜单 控制器（仅教师端）*/
    private lazy var renderMenuComponent = FcrRenderMenuUIComponent(userController: contextPool.user,
                                                                    streamController: contextPool.stream,
                                                                    widgetController: contextPool.widget,
                                                                    delegate: self)
    
    /** 工具栏*/
    private lazy var toolBarComponent = FcrToolBarUIComponent(userController: contextPool.user,
                                                              delegate: self)
    
    /** 房间状态 控制器*/
    private lazy var stateComponent = FcrRoomStateUIComponent(roomController: contextPool.room,
                                                              userController: contextPool.user,
                                                              monitorController: contextPool.monitor,
                                                              groupController: contextPool.group)
  
    /** 课堂状态 控制器（仅教师端）*/
    private lazy var classStateComponent = FcrClassStateUIComponent(roomController: contextPool.room,
                                                                    widgetController: contextPool.widget,
                                                                    delegate: self)
    
    /** 老师渲染 控制器*/
    private lazy var teacherRenderComponent = FcrLectureTachedWindowUIComponent(roomController: contextPool.room,
                                                                                userController: contextPool.user,
                                                                                streamController: contextPool.stream,
                                                                                mediaController: contextPool.media,
                                                                                widgetController: contextPool.widget,
                                                                                dataSource: [FcrTachedWindowRenderViewState.none],
                                                                                reverseItem: false,
                                                                                delegate: self)
    
    /** 白板 控制器*/
    private lazy var boardComponent = FcrLectureBoardUIComponent(roomController: contextPool.room,
                                                                 userController: contextPool.user,
                                                                 widgetController: contextPool.widget,
                                                                 mediaController: contextPool.media,
                                                                 delegate: self)
    
    /** 工具集合 控制器（观众端没有）*/
    private lazy var toolCollectionComponent = FcrToolCollectionUIComponent(userController: contextPool.user,
                                                                            widgetController: contextPool.widget,
                                                                            delegate: self)
    /** 大窗 控制器*/
    private lazy var windowComponent = FcrLectureDetachedWindowUIComponent(roomController: contextPool.room,
                                                                         userController: contextPool.user,
                                                                         streamController: contextPool.stream,
                                                                         mediaController: contextPool.media,
                                                                         widgetController: contextPool.widget,
                                                                         delegate: self,
                                                                         componentDataSource: self,
                                                                         actionDelegate: self)
    /** 外部链接 控制器*/
    private lazy var webViewComponent = FcrWebViewUIComponent(roomController: contextPool.room,
                                                              userController: contextPool.user,
                                                              widgetController: contextPool.widget)
    /** 云盘 控制器（仅教师端）*/
    private lazy var cloudComponent = FcrCloudUIComponent(roomController: contextPool.room,
                                                          widgetController: contextPool.widget,
                                                          userController: contextPool.user,
                                                          delegate: self)
    /** 教具 控制器*/
    private lazy var classToolsComponent = FcrClassToolsUIComponent(roomController: contextPool.room,
                                                                    userController: contextPool.user,
                                                                    monitorController: contextPool.monitor,
                                                                    widgetController: contextPool.widget)
    /** 聊天窗口 控制器*/
    private lazy var chatComponent = FcrChatUIComponent(roomController: contextPool.room,
                                                        userController: contextPool.user,
                                                        widgetController: contextPool.widget)
    /** 窗口拖拽预览视图*/
    private lazy var rectEffectView: FcrDragRectEffectView = {
        let view = FcrDragRectEffectView(frame: .zero)
        contentView.addSubview(view)
        return view
    }()
    
    private var isJoinedRoom = false
    
    private lazy var watermarkWidget: AgoraBaseWidget? = {
        guard let config = contextPool.widget.getWidgetConfig(kWatermarkWidgetId) else {
            return nil
        }
        return contextPool.widget.create(config)
    }()
    
    @objc public init(contextPool: AgoraEduContextPool,
                      delegate: FcrUISceneDelegate?) {
        super.init(sceneType: .lecture,
                   contextPool: contextPool,
                   delegate: delegate)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    public override func viewDidLoad() {
        super.viewDidLoad()
        
        contextPool.room.joinRoom { [weak self] in
            AgoraLoading.hide()
            guard let `self` = self else {
                return
            }
            self.isJoinedRoom = true
            
            if self.contextPool.user.getLocalUserInfo().userRole == .teacher {
                self.contextPool.media.openLocalDevice(systemDevice: .frontCamera)
                self.contextPool.media.openLocalDevice(systemDevice: .mic)
            }
        } failure: { [weak self] error in
            AgoraLoading.hide()
            self?.exitScene(reason: .normal)
        }
        
        if let watermark = watermarkWidget?.view {
            view.addSubview(watermark)
            
            watermark.mas_makeConstraints { make in
                make?.top.equalTo()(boardComponent.view.mas_top)
                make?.bottom.equalTo()(boardComponent.view.mas_bottom)
                make?.left.equalTo()(contentView.mas_left)
                make?.right.equalTo()(contentView.mas_right)
            }
        }
    }
    
    public override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        if isJoinedRoom == false {
            AgoraLoading.loading()
        }
    }
    
    public override func didClickCtrlMaskView() {
        super.didClickCtrlMaskView()
        toolBarComponent.deselectAll()
    }
    
    // MARK: AgoraUIContentContainer
    public override func initViews() {
        super.initViews()
        
        let userRole = contextPool.user.getLocalUserInfo().userRole
        
        var componentList: [UIViewController] = [stateComponent,
                                                 settingComponent,
                                                 boardComponent,
                                                 teacherRenderComponent,
                                                 webViewComponent,
                                                 windowComponent,
                                                 nameRollComponent,
                                                 classToolsComponent,
                                                 toolBarComponent,
                                                 toolCollectionComponent,
                                                 chatComponent,
                                                 audioComponent,
                                                 globalComponent]

        switch userRole {
        case .teacher:
            let teacherList = [classStateComponent,
                               cloudComponent,
                               renderMenuComponent,
                               handsListComponent]
            componentList.append(contentsOf: teacherList)
            classStateComponent.view.agora_visible = false
            cloudComponent.view.agora_visible = false
            renderMenuComponent.view.agora_visible = false
        case .student:
            componentList.removeAll(nameRollComponent)
        case .assistant:
            break
        case .observer:
            componentList.removeAll([toolCollectionComponent,
                                     nameRollComponent,
                                     classToolsComponent])
        }
        
        for component in componentList {
            addChild(component)
            
            if [settingComponent,
                handsListComponent,
                nameRollComponent].contains(component) {
                continue
            }
            
            if [globalComponent,
                audioComponent].contains(component) {
                component.viewDidLoad()
                continue
            }
            
            contentView.addSubview(component.view)
        }
        
        switch userRole {
        case .teacher:
            toolBarComponent.updateTools([.setting,
                                          .roster,
                                          .handsList])
            
            teacherRenderComponent.dragDelegate = self
        case .student:
            toolBarComponent.updateTools([.setting,
                                          .waveHands])
        default:
            toolBarComponent.updateTools([.setting])
        }
    }
    
    public override func initViewFrame() {
        super.initViewFrame()
        let userRole = contextPool.user.getLocalUserInfo().userRole
        
        stateComponent.view.mas_makeConstraints { make in
            make?.top.left().right().equalTo()(0)
            make?.height.equalTo()(UIDevice.current.agora_is_pad ? 24 : 14)
        }
        
        webViewComponent.view.mas_makeConstraints { [weak self] make in
            guard let `self` = self else {
                return
            }
            
            make?.left.right().top().bottom().equalTo()(self.boardComponent.view)
        }
        
        windowComponent.view.mas_makeConstraints { [weak self] make in
            guard let `self` = self else {
                return
            }
            
            make?.left.right().top().bottom().equalTo()(self.boardComponent.view)
        }
        
        teacherRenderComponent.view.mas_makeConstraints { [weak self] make in
            guard let `self` = self else {
                return
            }
            
            make?.top.equalTo()(self.stateComponent.view.mas_bottom)?.offset()(2)
            make?.right.equalTo()(0)
            make?.width.equalTo()(AgoraFit.scale(170))
            make?.height.equalTo()(AgoraFit.scale(112))
        }
        
        boardComponent.view.mas_makeConstraints { [weak self] make in
            guard let `self` = self else {
                return
            }
            
            make?.left.bottom().equalTo()(0)
            make?.right.equalTo()(self.teacherRenderComponent.view.mas_left)?.offset()(-2)
            make?.top.equalTo()(self.stateComponent.view.mas_bottom)?.offset()(2)
        }
        
        toolBarComponent.view.mas_remakeConstraints { [weak self] make in
            guard let `self` = self else {
                return
            }
            
            let right = CGFloat(UIDevice.current.agora_is_pad ? -15 : -12)
            let bottom = CGFloat(UIDevice.current.agora_is_pad ? -20 : -15)
            
            make?.right.equalTo()(self.boardComponent.view.mas_right)?.offset()(right)
            make?.bottom.equalTo()(self.boardComponent.mas_bottomLayoutGuideBottom)?.offset()(bottom)
            make?.width.equalTo()(self.toolBarComponent.suggestSize.width)
            make?.height.equalTo()(self.toolBarComponent.suggestSize.height)
        }
        
        if userRole != .observer {
            toolCollectionComponent.view.mas_makeConstraints { [weak self] make in
                guard let `self` = self else {
                    return
                }
                
                let bottom = CGFloat(UIDevice.current.agora_is_pad ? -20 : -15)
                
                make?.centerX.equalTo()(self.toolBarComponent.view.mas_centerX)
                make?.bottom.equalTo()(self.contentView)?.offset()(bottom)
                make?.width.height().equalTo()(self.toolCollectionComponent.suggestLength)
            }
            
            classToolsComponent.view.mas_makeConstraints { [weak self] make in
                guard let `self` = self else {
                    return
                }
                
                make?.left.right().top().bottom().equalTo()(self.boardComponent.view)
            }
        }
        
        chatComponent.view.mas_makeConstraints { [weak self] make in
            guard let `self` = self else {
                return
            }
            
            make?.top.equalTo()(self.teacherRenderComponent.view.mas_bottom)?.offset()(2)
            make?.left.right().equalTo()(self.teacherRenderComponent.view)
            make?.bottom.equalTo()(0)
        }
        
        updateRenderLayout()
    }
    
    public override func updateViewProperties() {
        super.updateViewProperties()
        teacherRenderComponent.view.layer.cornerRadius = FcrUIFrameGroup.windowCornerRadius
        teacherRenderComponent.view.clipsToBounds = true
    }
}
// MARK: - FcrSettingUIComponentDelegate
extension FcrLectureUIScene: FcrSettingUIComponentDelegate {
    func onShowShareView(_ view: UIView) {
        ctrlView = nil
        toolBarComponent.deselectAll()
        self.view.addSubview(view)
        view.mas_makeConstraints { make in
            make?.top.left().bottom().right().equalTo()(0)
        }
    }
}

// MARK: - AgoraBoardUIComponentDelegate
extension FcrLectureUIScene: FcrBoardUIComponentDelegate {
    func onBoardActiveStateChanged(isActive: Bool) {
        toolCollectionComponent.updateBoardActiveState(isActive: isActive)
    }
    
    func onBoardGrantedUserListAdded(userList: [String]) {
        updateStreamWindowItemBoardPrivilege(true,
                                             userList: userList)
        toolCollectionComponent.onBoardPrivilegeListChaned(true,
                                                           userList: userList)
        webViewComponent.onBoardPrivilegeListChaned(true,
                                                    userList: userList)
    }
    
    func onBoardGrantedUserListRemoved(userList: [String]) {
        updateStreamWindowItemBoardPrivilege(false,
                                             userList: userList)
        toolCollectionComponent.onBoardPrivilegeListChaned(false,
                                                           userList: userList)
        webViewComponent.onBoardPrivilegeListChaned(false,
                                                    userList: userList)
    }
    
    func updateStreamWindowItemBoardPrivilege(_ privilege: Bool,
                                              userList: [String]) {
        for (index, item) in windowComponent.dataSource.enumerated() {
            var data = item.data
            
            guard userList.contains(data.userId) else {
                continue
            }
            
            guard let user = contextPool.user.getUserInfo(userUuid: data.userId),
                  user.userRole != .teacher else {
                      continue
                  }
            
            let privilege = FcrBoardPrivilegeViewState.create(privilege)
            data.boardPrivilege = privilege
            
            windowComponent.updateItemData(data,
                                           index: index)
        }
    }
}

// MARK: - FcrDetachedStreamWindowUIComponentDelegate
extension FcrLectureUIScene: FcrDetachedStreamWindowUIComponentDelegate {
    func onNeedWindowRenderViewFrameOnTopWindow(userId: String) -> CGRect? {
        guard let renderView = teacherRenderComponent.getRenderView(userId: userId) else {
            return nil
        }
        
        let frame = renderView.convert(renderView.frame,
                                       to: UIWindow.agora_top_window())
        
        return frame
    }
    
    func onWillStartRenderVideoStream(streamId: String) {
        guard let item = teacherRenderComponent.getItem(streamId: streamId),
              let data = item.data
        else {
            return
        }
        
        let new = FcrTachedWindowRenderViewState.create(isHide: true,
                                                        data: data)
        teacherRenderComponent.updateItem(new,
                                          animation: false)
    }
    
    func onDidStopRenderVideoStream(streamId: String) {
        guard let item = teacherRenderComponent.getItem(streamId: streamId),
              let data = item.data
        else {
            return
        }
        
        let new = FcrTachedWindowRenderViewState.create(isHide: false,
                                                        data: data)
        teacherRenderComponent.updateItem(new,
                                          animation: false)
    }
}

// MARK: - AgoraCloudUIComponentDelegate
extension FcrLectureUIScene: FcrCloudUIComponentDelegate {
    func onOpenAlfCourseware(urlString: String,
                             resourceId: String) {
        webViewComponent.openWebView(urlString: urlString,
                                     resourceId: resourceId)
    }
}

// MARK: - AgoraToolBarDelegate
extension FcrLectureUIScene: FcrToolBarComponentDelegate {
    func toolsViewDidSelectTool(tool: FcrToolBarItemType,
                                selectView: UIView) {
        switch tool {
        case .setting:
            settingComponent.view.frame = CGRect(origin: .zero,
                                                 size: settingComponent.suggestSize)
            ctrlView = settingComponent.view
        case .roster:
            nameRollComponent.view.frame = CGRect(origin: .zero,
                                                  size: nameRollComponent.suggestSize)
            ctrlView = nameRollComponent.view
        case .handsList:
            if handsListComponent.dataSource.count > 0 {
                handsListComponent.view.frame = CGRect(origin: .zero,
                                                       size: handsListComponent.suggestSize)
                ctrlView = handsListComponent.view
            }
        default:
            break
        }
        ctrlViewAnimationFromView(selectView)
    }
    
    func toolsViewDidDeselectTool(tool: FcrToolBarItemType) {
        ctrlView = nil
    }
}

// MARK: - FcrLectureStreamWindowUIComponentDelegate
extension FcrLectureUIScene: FcrLectureDetachedWindowUIComponentDelegate {
    func onStreamWindow(_ component: FcrLectureDetachedWindowUIComponent,
                        didPressUser uuid: String,
                        view: UIView) {
        let rect = view.convert(view.bounds,
                                to: contentView)
        let centerX = rect.center.x - contentView.width / 2
        var role = AgoraEduContextUserRole.student
        if let teacehr = contextPool.user.getUserList(role: .teacher)?.first,
           teacehr.userUuid == uuid {
            role = .teacher
        }
        if let menuId = renderMenuComponent.userId,
           menuId == uuid {
            // 若当前已存在menu，且当前menu的userId为点击的userId，menu切换状态
            renderMenuComponent.dismissView()
        } else {
            // 1. 当前menu的userId不为点击的userId，切换用户
            // 2. 当前不存在menu，显示
            renderMenuComponent.show(roomType: .lecture,
                                     userUuid: uuid,
                                     showRoleType: role)
            renderMenuComponent.view.mas_remakeConstraints { make in
                make?.bottom.equalTo()(view.mas_bottom)?.offset()(1)
                make?.centerX.equalTo()(view.mas_centerX)
                make?.height.equalTo()(30)
                make?.width.equalTo()(renderMenuComponent.menuWidth)
            }
        }
    }
}

extension FcrLectureUIScene: FcrTachedStreamWindowUIComponentDragDelegate {
    func onStreamWindow(_ component: FcrLectureDetachedWindowUIComponent,
                        starDrag item: FcrDetachedStreamWindowWidgetItem,
                        view: UIView,
                        location: CGPoint) {
        let windowArea = FcrRectEffectArea(areaRect: windowComponent.view.frame,
                                           initSize: view.size,
                                           zoomMinSize: CGSize(width: 100, height: 100))
        let teacherArea = FcrRectEffectArea(areaRect: teacherRenderComponent.view.frame,
                                            initSize: teacherRenderComponent.view.frame.size,
                                            zoomMinSize: nil)
        let point = component.view.convert(location,
                                           to: rectEffectView)
        let rect = component.view.convert(view.frame,
                                          to: rectEffectView)
        if contextPool.user.getUserInfo(userUuid: item.data.userId)?.userRole == .teacher {
            rectEffectView.startEffect(with: [windowArea, teacherArea],
                                       from: rect,
                                       at: point)
        } else {
            rectEffectView.startEffect(with: [windowArea],
                                       from: rect,
                                       at: point)
        }
    }
    
    func onStreamWindow(_ component: FcrLectureDetachedWindowUIComponent,
                        dragging item: FcrDetachedStreamWindowWidgetItem,
                        to location: CGPoint) {
        let point = component.view.convert(location,
                                           to: rectEffectView)
        rectEffectView.setDropPoint(point)
    }
    
    func onStreamWindow(_ component: FcrLectureDetachedWindowUIComponent,
                        didEndDrag item: FcrDetachedStreamWindowWidgetItem,
                        location: CGPoint) -> CGRect? {
        let point = component.view.convert(location,
                                           to: rectEffectView)
        rectEffectView.setDropPoint(point)
        if rectEffectView.stopEffect() {
            return nil
        } else {
            return rectEffectView.getDropRectInView(windowComponent.view)
        }
    }
}

// MARK: - AgoraRenderMenuUIComponentDelegate
extension FcrLectureUIScene: FcrRenderMenuUIComponentDelegate {
    func onMenuUserLeft() {
        renderMenuComponent.dismissView()
        renderMenuComponent.view.isHidden = true
    }
}

// MARK: - FcrWindowRenderUIComponentDelegate
extension FcrLectureUIScene: FcrTachedStreamWindowUIComponentDelegate {
    func tachedStreamWindowUIComponent(_ component: FcrTachedStreamWindowUIComponent,
                           didPressItem item: FcrTachedWindowRenderViewState,
                           view: UIView) {
        guard contextPool.user.getLocalUserInfo().userRole == .teacher,
              let data = item.data else {
                  return
              }
        
        let rect = view.convert(view.bounds,
                                to: contentView)
        let centerX = rect.center.x - contentView.width / 2
        
        let userId = data.userId
        
        var role = AgoraEduContextUserRole.student
        if let teacehr = contextPool.user.getUserList(role: .teacher)?.first,
           teacehr.userUuid == userId {
            role = .teacher
        }
        
        if let menuId = renderMenuComponent.userId,
           menuId == userId {
            // 若当前已存在menu，且当前menu的userId为点击的userId，menu切换状态
            renderMenuComponent.dismissView()
        } else {
            // 1. 当前menu的userId不为点击的userId，切换用户
            // 2. 当前不存在menu，显示
            renderMenuComponent.show(roomType: .lecture,
                                     userUuid: userId,
                                     showRoleType: role)
            renderMenuComponent.view.mas_remakeConstraints { [weak self, weak view] make in
                guard let `self` = self,
                      let `view` = view else {
                    return
                }
                
                make?.bottom.equalTo()(view.mas_bottom)?.offset()(1)
                make?.centerX.equalTo()(view.mas_centerX)
                make?.height.equalTo()(30)
                make?.width.equalTo()(self.renderMenuComponent.menuWidth)
            }
        }
    }
    
    func tachedStreamWindowUIComponent(_ component: FcrTachedStreamWindowUIComponent,
                                       shouldItemIsHide streamId: String) -> Bool {
        if let _ = windowComponent.dataSource.firstItem(streamId: streamId) {
            return true
        } else {
            return false
        }
    }
    
    func tachedStreamWindowUIComponent(_ component: FcrTachedStreamWindowUIComponent,
                                       starDrag item: FcrTachedWindowRenderViewState,
                                       location: CGPoint) {
        let windowArea = FcrRectEffectArea(areaRect: windowComponent.view.frame,
                                           initSize: CGSize(width: 200, height: 160),
                                           zoomMinSize: CGSize(width: 100, height: 100))
        let teacherArea = FcrRectEffectArea(areaRect: teacherRenderComponent.view.frame,
                                            initSize: teacherRenderComponent.view.frame.size,
                                            zoomMinSize: nil)
        let point = component.view.convert(location,
                                           to: rectEffectView)
        let rect = component.view.convert(teacherRenderComponent.view.frame,
                                          to: rectEffectView)
        rectEffectView.startEffect(with: [windowArea, teacherArea],
                                   from: rect,
                                   at: point)
    }
    
    func tachedStreamWindowUIComponent(_ component: FcrTachedStreamWindowUIComponent,
                                       dragging item: FcrTachedWindowRenderViewState,
                                       to location: CGPoint) {
        let point = component.view.convert(location,
                                           to: rectEffectView)
        rectEffectView.setDropPoint(point)
    }
    
    func tachedStreamWindowUIComponent(_ component: FcrTachedStreamWindowUIComponent,
                                       didEndDrag item: FcrTachedWindowRenderViewState,
                                       location: CGPoint) {
        let point = component.view.convert(location,
                                           to: rectEffectView)
        rectEffectView.setDropPoint(point)
        rectEffectView.stopEffect()
        guard let data = item.data,
              let stream = self.contextPool.stream.getStreamList(userUuid: data.userId)?.first
        else {
            return
        }
        let rect = rectEffectView.getDropRectInView(windowComponent.view)
        self.windowComponent.createWidgetWith(stream: stream,
                                              at: rect)
    }
}

// MARK: - AgoraChatUIComponentDelegate
extension FcrLectureUIScene: FcrHandsListUIComponentDelegate {
    func updateHandsListRedLabel(_ count: Int) {
        if count == 0,
           ctrlView == handsListComponent.view {
            ctrlView = nil
        }
        toolBarComponent.updateHandsListCount(count)
    }
}

// MARK: - AgoraToolCollectionUIComponentDelegate
extension FcrLectureUIScene: FcrToolCollectionUIComponentDelegate {
    func toolCollectionDidSelectCell(view: UIView) {
        renderMenuComponent.dismissView()
        toolBarComponent.deselectAll()
        ctrlView = view
        ctrlViewAnimationFromView(toolCollectionComponent.view)
    }
    
    func toolCollectionCellNeedSpread(_ spread: Bool) {
        if spread {
            toolCollectionComponent.view.mas_remakeConstraints { [weak self] make in
                guard let `self` = self else {
                    return
                }
                
                let bottom = CGFloat(UIDevice.current.agora_is_pad ? -20 : -15)
                
                make?.centerX.equalTo()(self.toolBarComponent.view.mas_centerX)
                make?.bottom.equalTo()(self.contentView)?.offset()(bottom)
                make?.width.equalTo()(self.toolCollectionComponent.suggestLength)
                make?.height.equalTo()(self.toolCollectionComponent.suggestSpreadHeight)
            }
        } else {
            toolCollectionComponent.view.mas_remakeConstraints { [weak self] make in
                guard let `self` = self else {
                    return
                }
                
                let bottom = CGFloat(UIDevice.current.agora_is_pad ? -20 : -15)
                
                make?.centerX.equalTo()(self.toolBarComponent.view.mas_centerX)
                make?.bottom.equalTo()(self.contentView)?.offset()(bottom)
                make?.width.height().equalTo()(self.toolCollectionComponent.suggestLength)
            }
        }
    }
    
    func toolCollectionDidDeselectCell() {
        ctrlView = nil
    }
    
    func toolCollectionDidSelectTeachingAid(type: AgoraTeachingAidType) {
        // 选择插件（答题器、投票器...）
        ctrlView = nil
        switch type {
        case .cloudStorage:
            if !cloudComponent.view.agora_visible {
                cloudComponent.view.mas_makeConstraints { [weak self] make in
                    guard let `self` = self else {
                        return
                    }
                    
                    make?.left.right().top().bottom().equalTo()(self.boardComponent.view)
                }
            }
            cloudComponent.view.agora_visible = !cloudComponent.view.agora_visible
        case .saveBoard:
            boardComponent.saveBoard()
        case .vote:
            break
        case .countDown:
            break
        case .answerSheet:
            break
        default:
            break
        }
    }
    
    func toolCollectionDidChangeAppearance(_ appear: Bool) {
        UIView.animate(withDuration: TimeInterval.agora_animation,
                       delay: 0,
                       options: .curveEaseInOut,
                       animations: { [weak self] in
            guard let `self` = self else {
                return
            }
            
            if appear {
                self.toolBarComponent.view.mas_remakeConstraints { [weak self] make in
                    guard let `self` = self else {
                        return
                    }
                    
                    let right = CGFloat(UIDevice.current.agora_is_pad ? -15 : -12)
                    let bottom = CGFloat(UIDevice.current.agora_is_pad ? -15 : -12)
                    
                    make?.right.equalTo()(self.boardComponent.view.mas_right)?.offset()(right)
                    make?.bottom.equalTo()(self.toolCollectionComponent.view.mas_top)?.offset()(bottom)
                    make?.width.equalTo()(self.toolBarComponent.suggestSize.width)
                    make?.height.equalTo()(self.toolBarComponent.suggestSize.height)
                }
            } else {
                self.toolBarComponent.view.mas_remakeConstraints { [weak self] make in
                    guard let `self` = self else {
                        return
                    }
                    
                    let right = CGFloat(UIDevice.current.agora_is_pad ? -15 : -12)
                    let bottom = CGFloat(UIDevice.current.agora_is_pad ? -20 : -15)
                    
                    make?.right.equalTo()(self.boardComponent.view.mas_right)?.offset()(right)
                    make?.bottom.equalTo()(self.boardComponent.mas_bottomLayoutGuideBottom)?.offset()(bottom)
                    make?.width.equalTo()(self.toolBarComponent.suggestSize.width)
                    make?.height.equalTo()(self.toolBarComponent.suggestSize.height)
                }
            }
        }, completion: nil)
    }
}

// MARK: - AgoraClassStateUIComponentDelegate
extension FcrLectureUIScene: FcrClassStateUIComponentDelegate {
    func onShowStartClass() {
        guard contextPool.user.getLocalUserInfo().userRole == .teacher else {
            return
        }
        
        classStateComponent.view.agora_visible = true
        
        let left: CGFloat = UIDevice.current.agora_is_pad ? 198 : 192
        
        classStateComponent.view.mas_makeConstraints { [weak self] make in
            guard let `self` = self else {
                return
            }
            
            let bottom = CGFloat(UIDevice.current.agora_is_pad ? -20 : -15)
            
            make?.left.equalTo()(self.contentView)?.offset()(left)
            make?.bottom.equalTo()(self.contentView)?.offset()(bottom)
            make?.size.equalTo()(self.classStateComponent.suggestSize)
        }
    }
}

// MARK: - FcrUIcomponentDataSource
extension FcrLectureUIScene: FcrUIComponentDataSource {
    func componentNeedGrantedUserList() -> [String] {
        return boardComponent.grantedUsers
    }
}

private extension FcrLectureUIScene {
    func updateRenderLayout() {
        view.layoutIfNeeded()
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .horizontal
        
        layout.itemSize = CGSize(width: teacherRenderComponent.view.width - 2,
                                 height: teacherRenderComponent.view.height - 2)
        layout.minimumLineSpacing = 2
        teacherRenderComponent.updateLayout(layout)
    }
}
