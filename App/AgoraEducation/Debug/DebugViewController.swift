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
    private var dataSourceList: [DataSourceType] = []
    private var dataHandler = DebugDataHandler()
    /**view**/
    private lazy var debugView = DebugView(frame: .zero)
    
    override init(nibName nibNameOrNil: String?,
                  bundle nibBundleOrNil: Bundle?) {
        super.init(nibName: nibNameOrNil,
                   bundle: nibBundleOrNil)
        
        let language = dataHandler.getLaunchLanguage()
        let region = dataHandler.getRegion()
        let uiMode = dataHandler.getUIMode()
        
        dataSourceList = [.roomName(.none),
                          .userName(.none),
                          .roomType(selected: .oneToOne,
                                    list: DataSourceRoomType.allCases),
                          .roleType(selected: .student,
                                    list: DataSourceRoleType.allCases),
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
                          .environment(.pro)
        ]
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
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
        
    }
}

private extension DebugViewController {
    
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
        debugView.tableView.dataSource = self
        debugView.tableView.delegate = self
        debugView.optionsView.delegate = self
        view.addSubview(debugView)
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
}
