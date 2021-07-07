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
    
    // Views
    let renderListView = AgoraUserRenderListView(frame: .zero)
    var rewardImageView: AgoraFLAnimatedImageView?
    
    // DataSource
    var teacherInfo: AgoraEduContextUserDetailInfo? {
        didSet {
            let coHost = coHosts.first
            var volume = 0
            
            // 删除
            if coHost?.userInfo.user.role == .teacher {
                coHosts.removeFirst()
                volume = coHost?.volume ?? 0
            }

            // 增加
            if let info = teacherInfo {
                let coInfo = AgoraRenderListItem(userInfo: info,
                                                 volume: volume)
                
                coHosts.insert(coInfo, at: 0)
            }
            
            reloadData()
        }
    }

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
    
    func reloadData(){
        renderListView.collectionView.reloadData()
        
        var infos = [AgoraEduContextUserDetailInfo]()
        coHosts.forEach({infos.append($0.userInfo)})
        delegate?.renderSmallController(self,
                                        didUpdateCoHosts: infos)
    }
}

// MARK: - Private
private extension AgoraSmallRenderUIController {
    func initViews() {
        containerView.backgroundColor = .clear
        containerView.addSubview(renderListView)
        
        renderListView.isHidden = true
    }

    func initLayout() {
        // 获取当前屏幕宽
        let Width = max(UIScreen.agora_width,
                        UIScreen.agora_height)
        let SafeWidth = max(UIScreen.agora_safe_area_top + UIScreen.agora_safe_area_bottom,
                        UIScreen.agora_safe_area_right + UIScreen.agora_safe_area_left)
        let MaxWidth = Width - SafeWidth
        
        // 间距
        let ViewGap: CGFloat = 2
        
        // 最多上台人数为6人
        let MaxStudnetCoHost: CGFloat = 6
        
        // 老师和学生在一个列表, 计算放7个的时候
        let itemWidth: CGFloat = (MaxWidth - MaxStudnetCoHost * ViewGap) / 6.0
        // 宽高 16 ：9
        let itemHeight = itemWidth * 9.0 / 16.0
        
        teacherViewSize = CGSize(width: itemWidth, height: itemHeight)
        AgoraUserRenderListView.preferenceWidth = teacherViewSize.width
        AgoraUserRenderListView.preferenceHeight = teacherViewSize.height
 
        renderListView.agora_x = 0
        renderListView.agora_y = 0
        renderListView.agora_height = AgoraUserRenderListView.preferenceHeight
        renderListView.agora_right = 0
        
        renderListViewHeight = renderListView.agora_height
    }
    
    func observeEvent(register: AgoraControllerEventRegister) {
        register.controllerRegisterUserEvent(self)
    }

    func observeUI() {
        renderListView.collectionView.dataSource = self
        renderListView.collectionView.delegate = self
    }
}

