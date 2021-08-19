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
    private(set) var renderViewSize: CGSize = CGSize(width: AgoraVideoWidth, height: AgoraVideoHeight)
    // 距离上面的值， 等于navView的高度
    let renderTop: CGFloat = AgoraNavBarHeight
    // 可渲染最大宽度
    let renderMaxWidth: CGFloat = AgoraRealMaxWidth
    // 渲染间距
    let renderViewGap: CGFloat = AgoraVideoGapX
    // 学生最多上台人数为6人， 要去除老师
    let renderMaxView: CGFloat = AgoraRenderMaxCount - 1

    private weak var contextProvider: AgoraControllerContextProvider?
    private weak var eventRegister: AgoraControllerEventRegister?
    
    weak var delegate: AgoraSmallRenderUIControllerDelegate?
    
    // Views
    let teacherView = AgoraUIUserView(frame: .zero)
    lazy var renderListView: AgoraUserRenderScrollView = {
        let v = AgoraUserRenderScrollView(frame: .zero)
        v.backgroundColor = UIColor(rgb: 0xF9F9FC)
        return v
    }()
    var rewardImageView: AgoraFLAnimatedImageView?
    
    // DataSource
    var teacherInfo: AgoraEduContextUserDetailInfo? {
        didSet {
            updateUserView(teacherView,
                           oldUserInfo: oldValue,
                           newUserInfo: teacherInfo)
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
            let renderWidth: CGFloat = (coHostCount - 1) * renderViewGap + coHostCount * renderViewSize.width
            let renderSide: CGFloat = max((renderMaxWidth - renderWidth) * 0.5, 0)
            self.renderListView.agora_x = renderSide
            self.renderListView.agora_right = renderSide
            return
        }
        
        if (self.teacherInfo != nil && self.coHosts.count == 0) {
            self.teacherView.isHidden = false
            self.renderListView.isHidden = true

            let renderSide: CGFloat = (renderMaxWidth - renderViewSize.width) * 0.5
            self.teacherView.agora_x = renderSide
            return
        }
        
        if (self.teacherInfo != nil && self.coHosts.count > 0) {
            self.teacherView.isHidden = false
            self.renderListView.isHidden = false

            let coHostCount: CGFloat = CGFloat(self.coHosts.count + 1)
            let renderWidth: CGFloat = (coHostCount - 1) * renderViewGap + coHostCount * renderViewSize.width
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
        AgoraUserRenderScrollView.preferenceWidth = renderViewSize.width
        AgoraUserRenderScrollView.preferenceHeight = renderViewSize.height
        AgoraUserRenderScrollView.preferenceVideoGapX = AgoraVideoGapX
    }
    
    func initViews() {
        teacherView.index = teacherIndex
        
        containerView.backgroundColor = UIColor(rgb: 0xF9F9FC)
        containerView.addSubview(teacherView)
        containerView.addSubview(renderListView)
        
        renderListView.isHidden = true
    }

    func initLayout() {
        teacherView.agora_x = 0
        teacherView.agora_y = 0
        teacherView.agora_width = AgoraUserRenderScrollView.preferenceWidth
        teacherView.agora_height = AgoraUserRenderScrollView.preferenceHeight
        teacherView.isHidden = true
        
        renderListView.agora_x = teacherView.agora_x + teacherView.agora_width + renderViewGap
        renderListView.agora_y = 0
        renderListView.agora_height = AgoraUserRenderScrollView.preferenceHeight
        renderListView.agora_right = 0
        renderListView.isHidden = true
    }
    
    func observeEvent(register: AgoraControllerEventRegister) {
        register.controllerRegisterUserEvent(self)
    }

    func observeUI() {
        teacherView.delegate = self
        renderListView.scrollView.delegate = self
    }
}

