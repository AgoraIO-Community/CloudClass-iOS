//
//  FcrProctorScene.swift
//  AgoraProctorUI
//
//  Created by LYY on 2022/9/6.
//

import AgoraUIBaseViews
import AgoraEduCore
import Masonry

@objc public protocol PtUISceneDelegate: NSObjectProtocol {
    func onExit(reason: PtUISceneExitReason)
}

@objc public class PtUIScene: UIViewController, PtAlert {
    private var deviceTest: PtDeviceTestUIComponent?
    
    private lazy var exam = PtExamUIComponent(contextPool: contextPool,
                                              delegate: self)
    
    private let contextPool: AgoraEduContextPool
    private weak var delegate: PtUISceneDelegate?
    
    @objc public init(contextPool: AgoraEduContextPool,
                      delegate: PtUISceneDelegate?) {
        self.contextPool = contextPool
        self.delegate = delegate
        
        super.init(nibName: nil,
                   bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    public override func viewDidLoad() {
        super.viewDidLoad()
        UIApplication.shared.isIdleTimerDisabled = true
        
        initViews()
        initViewFrame()
        updateViewProperties()
    }
}

// MARK: - PtDeviceTestUIComponentDelegate, PtExamUIComponentDelegate
extension PtUIScene: PtDeviceTestUIComponentDelegate,
                     PtExamUIComponentDelegate {
    public func onDeviceTestJoinExamSuccess() {
        deviceTest?.removeFromParent()
        deviceTest?.view.removeFromSuperview()
        
        deviceTest = nil
        
        addChild(exam)
        view.addSubview(exam.view)
        
        exam.view.mas_makeConstraints { make in
            make?.left.right().top().bottom().equalTo()(0)
        }
    }
    
    public func onDeviceTestExit() {
        exit()
    }
    
    public func onExamExit() {
        contextPool.room.leaveRoom()
        exit()
    }
}

// MARK: - private
extension PtUIScene: AgoraUIContentContainer {
    public func initViews() {
        if #available(iOS 13.0, *) {
            overrideUserInterfaceStyle = (agora_ui_mode == .agoraDark) ? .dark : .light
        }
        
        let deviceTestComponent = PtDeviceTestUIComponent(contextPool: contextPool,
                                                          delegate: self)
        self.deviceTest = deviceTestComponent
        
        addChild(deviceTestComponent)
        view.addSubview(deviceTestComponent.view)
    }
    
    public func initViewFrame() {
        guard let deviceTest = deviceTest else {
            return
        }
        deviceTest.view.mas_makeConstraints { make in
            make?.left.right().top().bottom().equalTo()(0)
        }
    }
    
    public func updateViewProperties() {
        let loadingComponent = UIConfig.loading
        
        if let url = loadingComponent.gifUrl,
           let data = try? Data(contentsOf: url) {
            AgoraLoading.setImageData(data)
        }
        AgoraLoading.setMessage(color: loadingComponent.message.color,
                                font: loadingComponent.message.font)
        AgoraLoading.setBackgroundColor(loadingComponent.backgroundColor)
    }
}

// MARK: - private
private extension PtUIScene {
    func exit() {
        guard !isBeingDismissed else {
            return
        }
        
        agora_dismiss(animated: true,
                      completion: { [weak self] in
            guard let `self` = self else {
                return
            }
            
            self.delegate?.onExit(reason: .normal)
        })
    }
}
