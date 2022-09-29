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
import AgoraProctorSDK
import AgoraUIBaseViews

class DebugViewController: UIViewController {
    /**data**/
    private lazy var data = DebugDataHandler(delegate: self)
    /**view**/
    private lazy var debugView = DebugView(frame: .zero)
    
    /**sdk**/
    private var proctorSDK: AgoraProctorSDK?
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
    
    func onDataSourceNeedReload() {
        let cellModelList = data.cellModelList()
        debugView.dataSource = cellModelList
        debugView.reloadList()
    }
    
    func onDataSourceValid(_ valid: Bool) {
        debugView.updateEnterEnabled(valid)
    }
}

// MARK: - View Delagate
extension DebugViewController: DebugViewDelagate {
    // MARK: DebugViewDelagate
    func onClickClose() {
        FcrUserInfoPresenter.shared.qaMode = false
        dismiss(animated: true,
                completion: nil)
    }
    
    func onClickEnter() {
        guard let info = data.checkLaunchInfoValid() else {
            return
        }
        
        AgoraLoading.loading()
        
        let failureBlock: (Error) -> () = { [weak self] (error) in
            AgoraLoading.hide()
            
            self?.proctorSDK = nil
            
            let `error` = error as NSError
            
            if error.code == 30403100 {
                AgoraToast.toast(message: "login_kicked".ag_localized(),
                                 type: .error)
            } else {
                AgoraToast.toast(message: error.localizedDescription,
                                 type: .error)
            }
        }
        
        let launchSuccessBlock: () -> () = {
            AgoraLoading.hide()
        }
        
        let tokenSuccessBlock: (TokenBuilder.ServerResp) -> () = { [weak self] (response) in
            guard let `self` = self else {
                return
            }
            
            // UI mode
            agora_ui_mode = info.uiMode.edu
            agora_ui_language = info.uiLanguage.edu.string
            
            let roomType = info.roomType
            if let _ = roomType.edu,
               let launchConfig = self.data.getEduLaunchConfig(debugInfo: info,
                                                            appId: response.appId,
                                                            token: response.token,
                                                            userId: response.userId) {
#if DEBUG
            let sel1 = NSSelectorFromString("setLogConsoleState:");
            AgoraClassroomSDK.perform(sel1,
                                      with: 1)
#endif
                AgoraClassroomSDK.launch(launchConfig,
                                         success: launchSuccessBlock,
                                         failure: failureBlock)
            } else if roomType == .proctor,
                      self.proctorSDK == nil {
                let launchConfig = self.data.getProctorLaunchConfig(debugInfo: info,
                                                                     appId: response.appId,
                                                                     token: response.token,
                                                                    userId: response.userId)
                let proSDK = AgoraProctorSDK(launchConfig,
                                             delegate: self)
                self.proctorSDK = proSDK
#if DEBUG
                
                let sel2 = NSSelectorFromString("setLogConsoleState:");
                proSDK.perform(sel2,
                               with: 1)
#endif
                self.data.updateProctorSDKEnviroment(proctorSDK: proSDK)
                
                proSDK.launch(launchSuccessBlock,
                              failure: failureBlock)
            }
        }
        
        var finalUserId = info.userId
        
        if info.roomType == .proctor {
            finalUserId = "\(finalUserId)-\(info.deviceType.rawValue)"
        }
        
        data.requestToken(roomId: info.roomId,
                          userId: finalUserId,
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
    
    private func initData() {
        let language = data.getLaunchLanguage()
        let region = data.getRegion()
        let uiMode = data.getUIMode()
        let environment = data.getEnvironment()
        
        let defaultList: [DataSourceType] = [.roomName(.none),
                                             .userName(.none),
                                             .roomType(.unselected),
                                             .roleType(.unselected),
                                             .im(.easemob),
                                             .deviceType(.sub),
                                             .duration(.none),
                                             .encryptKey(.none),
                                             .encryptMode(.none),
                                             .startTime(.none),
                                             .mediaAuth(.both),
                                             .uiMode(uiMode),
                                             .uiLanguage(language),
                                             .region(region),
                                             .environment(environment)]
        
        data.updateDataSourceList(defaultList)
    }
}

// MARK: - SDK delegate
extension DebugViewController: AgoraProctorSDKDelegate,
                               AgoraEduClassroomSDKDelegate {
    func proctorSDK(_ classroom: AgoraProctorSDK,
                    didExit reason: AgoraProctorExitReason) {
        switch reason {
        case .kickOut:
            AgoraToast.toast(message: "kick out")
        default:
            break
        }
        
        self.proctorSDK = nil
    }
    
    public func classroomSDK(_ classroom: AgoraClassroomSDK,
                             didExit reason: AgoraEduExitReason) {
        switch reason {
        case .kickOut:
            AgoraToast.toast(message: "kick out")
        default:
            break
        }
    }
}
