//
//  DebugViewController.swift
//  AgoraEducation
//
//  Created by LYY on 2022/8/5.
//  Copyright © 2022 Agora. All rights reserved.
//

#if canImport(AgoraClassroomSDK_iOS)
import AgoraClassroomSDK_iOS
#else
import AgoraClassroomSDK
#endif
import AgoraUIBaseViews

class DebugViewController: UIViewController {
    /**data**/
    private lazy var data = DebugDataHandler(delegate: self)
    /**view**/
    private lazy var debugView = DebugView(frame: .zero)
}

// MARK: - Data Delagate
extension DebugViewController: DebugDataHandlerDelegate {
    func onDataSourceChanged(index: Int,
                             typeKey: DataSourceType.Key,
                             newCellModel: DebugInfoCellModel) {
        debugView.updateCellModel(model: newCellModel,
                                  at: index)
        debugView.reloadList([index])
    }
    
    func onDataSourceValid(_ valid: Bool) {
        debugView.updateEnterEnabled(valid)
    }
}

// MARK: - View Delagate
extension DebugViewController: DebugViewDelagate {
    // MARK: DebugViewDelagate
    func didClickClose() {
        FcrUserInfoPresenter.shared.qaMode = false
        dismiss(animated: true,
                completion: nil)
    }
    
    func didClickEnter() {
        guard let info = data.getLaunchInfo() else {
            return
        }
        let failureBlock: (Error) -> () = { (error) in
            AgoraLoading.hide()
            AgoraToast.toast(message: error.localizedDescription,
                             type: .error)
        }
        
        let launchSuccessBlock: () -> () = {
            AgoraLoading.hide()
        }
        
        let tokenSuccessBlock: (TokenBuilder.ServerResp) -> () = { [weak self] (response) in
            guard let `self` = self else {
                return
            }
            
            // UI mode
            agora_ui_mode = info.uiMode
            agora_ui_language = info.uiLanguage.string
            
            let launchConfig = self.data.getLaunchConfig(debugInfo: info,
                                                         appId: response.appId,
                                                         token: response.token,
                                                         userId: response.userId)
            
            if launchConfig.roomType == .vocational { // 职教入口
                AgoraClassroomSDK.vocationalLaunch(launchConfig,
                                                   service: info.serviceType,
                                                   success: launchSuccessBlock,
                                                   failure: failureBlock)
            } else { // 灵动课堂入口
                AgoraClassroomSDK.launch(launchConfig,
                                         success: launchSuccessBlock,
                                         failure: failureBlock)
            }
        }
        data.requestToken(roomId: info.roomId,
                          userId: info.userId,
                          userRole: info.roleType.rawValue,
                          success: tokenSuccessBlock,
                          failure: failureBlock)
    }
}

// MARK: - AgoraUIContentContainer
extension DebugViewController: AgoraUIContentContainer {
    func initViews() {
        // setup agora loading
        if let bundle = Bundle.agora_bundle("AgoraEduUI"),
           let url = bundle.url(forResource: "img_loading",
                                withExtension: "gif"),
           let data = try? Data(contentsOf: url) {
            AgoraLoading.setImageData(data)
        }
        
        let noticeImage = UIImage(named: "toast_notice")!
        let warningImage = UIImage(named: "toast_warning")!
        let errorImage = UIImage(named: "toast_warning")!
        
        AgoraToast.setImages(noticeImage: noticeImage,
                             warningImage: warningImage,
                             errorImage: errorImage)
        
        debugView.delegate = self
        
        let appVersion = "_" + AgoraClassroomSDK.version()
        let loginVersion = "Login_version".ag_localized() + appVersion
        debugView.bottomLabel.text = loginVersion
        view.addSubview(debugView)
        
        debugView.dataSource = data.cellModelList()
        debugView.reloadList()
    }
    
    func initViewFrame() {
        debugView.mas_makeConstraints { make in
            make?.left.right().top().bottom().equalTo()(0)
        }
    }
    
    func updateViewProperties() {
        view.backgroundColor = .white
    }
}

// MARK: - override
extension DebugViewController {
    public override var shouldAutorotate: Bool {
        return true
    }
    
    public override var preferredInterfaceOrientationForPresentation: UIInterfaceOrientation {
        return UIDevice.current.agora_is_pad ? .landscapeRight : .portrait
    }
    
    public override var supportedInterfaceOrientations: UIInterfaceOrientationMask {
        return UIDevice.current.agora_is_pad ? .landscapeRight : .portrait
    }
    
    public override func viewDidLoad() {
        super.viewDidLoad()
        
        initData()
        initViews()
        initViewFrame()
        updateViewProperties()
    }
    
    public override func touchesBegan(_ touches: Set<UITouch>,
                                      with event: UIEvent?) {
        super.touchesBegan(touches, with: event)
        
        UIApplication.shared.keyWindow?.endEditing(true)
    }
    
    // TODO: temp
    public override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        navigationController?.setNavigationBarHidden(true,
                                                     animated: true)
    }
    
    private func initData() {
        let language = data.getLaunchLanguage()
        let region = data.getRegion()
        let uiMode = data.getUIMode()
        
        let defaultList: [DataSourceType] = [.roomName(.none),
                                             .userName(.none),
                                             .roomType(.unselected),
                                             .roleType(.unselected),
                                             .im(.easemob),
                                             .duration(.none),
                                             .encryptKey(.none),
                                             .encryptMode(.none),
                                             .startTime(.none),
                                             .delay(.none),
                                             .mediaAuth(.both),
                                             .uiMode(uiMode),
                                             .uiLanguage(language),
                                             .region(region),
                                             .environment(.pro)]
        
        data.updateDataSourceList(defaultList)
    }
}
