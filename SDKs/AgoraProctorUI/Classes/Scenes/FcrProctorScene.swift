//
//  FcrProctorScene.swift
//  AgoraProctorUI
//
//  Created by LYY on 2022/9/6.
//

import AgoraUIBaseViews
import AgoraEduContext
import Masonry

@objc public enum FcrUISceneExitReason: Int {
    case normal, kickOut
}

@objc public protocol FcrProctorSceneDelegate: NSObjectProtocol {
    func onExit(reason: FcrUISceneExitReason)
}

@objc public class FcrProctorScene: UIViewController {
    private lazy var deviceTest = FcrProctorDeviceTestComponent(contextPool: contextPool,
                                                                delegate: self)
    
    private lazy var exam = FcrProctorExamComponent(contextPool: contextPool,
                                                    delegate: self)
    
    private let contextPool: AgoraEduContextPool
    private weak var delegate: FcrProctorSceneDelegate?
    
    @objc public init(contextPool: AgoraEduContextPool,
                      delegate: FcrProctorSceneDelegate?) {
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
        
        initViews()
        initViewFrame()
        updateViewProperties()
    }
}

// MARK: - FcrProctorDeviceTestComponentDelegate, FcrProctorExamComponentDelegate
extension FcrProctorScene: FcrProctorDeviceTestComponentDelegate,
                                FcrProctorExamComponentDelegate {
    public func onDeviceTestJoinExamSuccess() {
        deviceTest.removeFromParent()
        deviceTest.view.removeFromSuperview()
        
        addChildViewController(exam,
                               toContainerView: view)

        exam.view.mas_makeConstraints { make in
            make?.left.right().top().bottom().equalTo()(0)
        }
    }
    
    public func onDeviceTestExit() {
        exit()
    }
    
    public func onExamExit() {
        exit()
    }
}

// MARK: - private
extension FcrProctorScene: AgoraUIContentContainer {
    public func initViews() {
        if #available(iOS 13.0, *) {
            overrideUserInterfaceStyle = (agora_ui_mode == .agoraDark) ? .dark : .light
        }
        
        view.backgroundColor = .black
        addChildViewController(deviceTest,
                               toContainerView: view)
    }
    
    public func initViewFrame() {
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
private extension FcrProctorScene {
    func exit() {
        guard !isBeingDismissed else {
            return
        }
        
        contextPool.room.leaveRoom()
        agora_dismiss(animated: true,
                      completion: { [weak self] in
            guard let `self` = self else {
                return
            }
            
            self.delegate?.onExit(reason: .normal)
        })
    }
}
