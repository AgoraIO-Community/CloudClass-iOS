//
//  FcrInviligatorScene.swift
//  AgoraInvigilatorUI
//
//  Created by LYY on 2022/9/6.
//

import AgoraUIBaseViews
import Masonry
import AgoraEduContext

@objc public enum FcrUISceneExitReason: Int {
    case normal, kickOut
}

@objc public protocol FcrInviligatorSceneDelegate: NSObjectProtocol {
    func onExit(reason: FcrUISceneExitReason)
}

@objc public class FcrInviligatorScene: UIViewController {
    private lazy var deviceTest = FcrInviligatorDeviceTestComponent(roomController: contextPool.room,
                                                                    userController: contextPool.user,
                                                                    mediaController: contextPool.media,
                                                                    streamController: contextPool.stream,
                                                                    delegate: self)
    
    private lazy var exam = FcrInviligatorExamComponent(roomController: contextPool.room,
                                                        userController: contextPool.user,
                                                        mediaController: contextPool.media,
                                                        streamController: contextPool.stream,
                                                        delegate: self)
    
    private let contextPool: AgoraEduContextPool
    private weak var delegate: FcrInviligatorSceneDelegate?
    
    @objc public init(contextPool: AgoraEduContextPool,
                      delegate: FcrInviligatorSceneDelegate?) {
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
        
        if #available(iOS 13.0, *) {
            overrideUserInterfaceStyle = (agora_ui_mode == .agoraDark) ? .dark : .light
        }
        
        view.backgroundColor = .black
        addChildViewController(deviceTest,
                               toContainerView: view)
        view.addSubview(deviceTest.view)

        deviceTest.view.mas_makeConstraints { make in
            make?.left.right().top().bottom().equalTo()(0)
        }
    }
}

// MARK: - FcrInviligatorDeviceTestComponentDelegate, FcrInviligatorExamComponentDelegate
extension FcrInviligatorScene: FcrInviligatorDeviceTestComponentDelegate,
                                FcrInviligatorExamComponentDelegate {
    public func onDeviceTestJoinExamSuccess() {
        // TODO: 动画
        deviceTest.dismiss(animated: true) { [weak self] in
            guard let `self` = self else {
                return
            }
            self.present(self.exam,
                         animated: true)
        }
    }
    
    public func onDeviceTestExit() {
        delegate?.onExit(reason: .normal)
    }
    
    public func onExamExit() {
        delegate?.onExit(reason: .normal)
    }
}
