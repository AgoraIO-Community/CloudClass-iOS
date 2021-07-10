//
//  AgoraSmallRenderUIController.swift
//  AgoraUIEduAppViews
//
//  Created by SRS on 2021/4/18.
//

import AgoraUIEduBaseViews
import AgoraUIBaseViews
import AgoraEduContext

protocol AgoraSmallRenderUIControllerDelegate: NSObjectProtocol {
    func renderSmallController(_ controller: AgoraSmallRenderUIController,
                               didUpdateCoHosts coHosts: [AgoraEduContextUserDetailInfo])
}

class AgoraSmallRenderUIController: AgoraRenderUIController {
    private(set) var teacherViewSize: CGSize = CGSize.zero
    private(set) var renderListViewHeight: CGFloat = 0
    
    private weak var contextProvider: AgoraControllerContextProvider?
    private weak var eventRegister: AgoraControllerEventRegister?
    
    weak var delegate: AgoraSmallRenderUIControllerDelegate?
    
    // 距离上面的值， 等于navView的高度
    let renderTop: CGFloat = AgoraKitDeviceAssistant.OS.isPad ? 44 : 34
    // 可渲染最大宽度
    private var renderMaxWidth: CGFloat = 0
    // 渲染间距
    private let renderViewGap: CGFloat = 2
    // 最多上台人数为6人
    private let renderMaxView: CGFloat = 6
    
    // Views
    let teacherView = AgoraUIUserView(frame: .zero)
    lazy var renderListView: AgoraUserRenderScrollView = {
        let v = AgoraUserRenderScrollView(frame: .zero)
        return v
    }()
    var rewardImageView: AgoraFLAnimatedImageView?
    
    // DataSource
    var teacherInfo: AgoraEduContextUserDetailInfo? {
        didSet {
            updateUserView(teacherView,
                           oldUserInfo: oldValue,
                           newUserInfo: teacherInfo)
            
            updateLayout()
        }
    }
    
    let teacherIndex = -1

    var coHosts = [AgoraRenderListItem]()
    var userViews = [String : AgoraUIUserView]()

    init(viewType: AgoraEduContextAppType,
         contextProvider: AgoraControllerContextProvider,
         eventRegister: AgoraControllerEventRegister,
         delegate: AgoraSmallRenderUIControllerDelegate) {
        self.delegate = delegate
        super.init(viewType: viewType,
                   contextProvider: contextProvider,
                   eventRegister: eventRegister)
        
        initSize()
        initViews()
        initLayout()
        observeEvent(register: eventRegister)
        observeUI()
    }
    
    func updateLayout() {
        if (self.teacherInfo == nil && self.coHosts.count == 0) {
            self.teacherView.isHidden = true
            self.renderListView.isHidden = true
            return
        }
        
        if (self.teacherInfo == nil && self.coHosts.count != 0) {
            self.teacherView.isHidden = true
            self.renderListView.isHidden = false
            
            let coHostCount: CGFloat = CGFloat(self.coHosts.count)
            let renderWidth: CGFloat = (coHostCount - 1) * renderViewGap + coHostCount * teacherViewSize.width
            let renderSide: CGFloat = max((renderMaxWidth - renderWidth) * 0.5, 0)
            self.renderListView.agora_x = renderSide
            self.renderListView.agora_right = renderSide
            return
        }
        
        if (self.teacherInfo != nil && self.coHosts.count == 0) {
            self.teacherView.isHidden = false
            self.renderListView.isHidden = true

            let renderSide: CGFloat = (renderMaxWidth - teacherViewSize.width) * 0.5
            self.teacherView.agora_x = renderSide
            return
        }
        
        if (self.teacherInfo != nil && self.coHosts.count > 0) {
            self.teacherView.isHidden = false
            self.renderListView.isHidden = false

            let coHostCount: CGFloat = CGFloat(self.coHosts.count + 1)
            let renderWidth: CGFloat = (coHostCount - 1) * renderViewGap + coHostCount * teacherViewSize.width
            let renderSide: CGFloat = max((renderMaxWidth - renderWidth) * 0.5, 0)
            
            self.teacherView.agora_x = renderSide
            self.renderListView.agora_x = teacherView.agora_x + teacherView.agora_width + renderViewGap
            self.renderListView.agora_right = renderSide
            
            return
        }
    }
}

// MARK: - Private
private extension AgoraSmallRenderUIController {
    func initSize() {
        // 获取当前屏幕宽
        let Width = max(UIScreen.agora_width,
                        UIScreen.agora_height)
        let SafeWidth = max(UIScreen.agora_safe_area_top + UIScreen.agora_safe_area_bottom,
                        UIScreen.agora_safe_area_right + UIScreen.agora_safe_area_left)
        renderMaxWidth = Width - SafeWidth
    
        // 老师和学生在一个列表, 计算放7个的时候
        let itemWidth: CGFloat = (renderMaxWidth - renderMaxView * renderViewGap) / renderMaxView
        // 宽高 16 ：9
        let itemHeight = itemWidth * 9.0 / 16.0
        
        teacherViewSize = CGSize(width: itemWidth, height: itemHeight)
        AgoraUserRenderListView.preferenceWidth = teacherViewSize.width
        AgoraUserRenderListView.preferenceHeight = teacherViewSize.height
    }
    
    func initViews() {
        teacherView.index = teacherIndex
        
        containerView.backgroundColor = .clear
        containerView.addSubview(teacherView)
        containerView.addSubview(renderListView)
        
        renderListView.isHidden = true
    }

    func initLayout() {
        teacherView.agora_x = 0
        teacherView.agora_y = 0
        teacherView.agora_width = AgoraUserRenderListView.preferenceWidth
        teacherView.agora_height = AgoraUserRenderListView.preferenceHeight
        teacherView.isHidden = true
    
        renderListView.agora_x = teacherView.agora_x + teacherView.agora_width + renderViewGap
        renderListView.agora_y = 0
        renderListView.agora_height = AgoraUserRenderListView.preferenceHeight
        renderListView.agora_right = 0
        renderListView.isHidden = true
    
        renderListViewHeight = renderListView.agora_height
    }
    
    func observeEvent(register: AgoraControllerEventRegister) {
        register.controllerRegisterUserEvent(self)
    }

    func observeUI() {
        teacherView.delegate = self
        renderListView.scrollView.delegate = self
    }
}

