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
    func renderController(_ controller: AgoraSmallRenderUIController,
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
    
    // Views
    let teacherView = AgoraUIUserView(frame: .zero)
    let renderListView = AgoraUserRenderListView(frame: .zero)
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
    var userViews = [AgoraUIUserView]()
    
    init(viewType: AgoraEduContextAppType,
         contextProvider: AgoraControllerContextProvider,
         eventRegister: AgoraControllerEventRegister,
         delegate: AgoraSmallRenderUIControllerDelegate) {
        self.delegate = delegate
        super.init(viewType: viewType,
                   contextProvider: contextProvider,
                   eventRegister: eventRegister)
        
        initViews()
        initLayout()
        observeEvent(register: eventRegister)
        observeUI()
    }
}

// MARK: - Private
private extension AgoraSmallRenderUIController {
    func initViews() {
        teacherView.index = teacherIndex
        
        containerView.backgroundColor = .clear
        containerView.addSubview(teacherView)
        containerView.addSubview(renderListView)
        
        renderListView.alpha = 0
    }

    func initLayout() {
        let isPad = AgoraKitDeviceAssistant.OS.isPad
        let ViewGap: CGFloat = 2
        
        let width: CGFloat = isPad ? 300 : 200
        let height: CGFloat = isPad ? 168 : 112
        
        teacherView.agora_y = 0
        teacherView.agora_right = 0
        teacherView.agora_width = width
        teacherView.agora_height = height
        
        renderListView.agora_x = 0
        renderListView.agora_y = 0
        renderListView.agora_height = AgoraUserRenderListView.preferenceHeight
        renderListView.agora_right = teacherView.agora_right + teacherView.agora_width + ViewGap
        
        teacherViewSize = CGSize(width: width, height: height)
        renderListViewHeight = renderListView.agora_height
    }
    
    func observeEvent(register: AgoraControllerEventRegister) {
        register.controllerRegisterUserEvent(self)
    }

    func observeUI() {
        teacherView.delegate = self
        renderListView.collectionView.dataSource = self
        renderListView.collectionView.delegate = self
    }
}

