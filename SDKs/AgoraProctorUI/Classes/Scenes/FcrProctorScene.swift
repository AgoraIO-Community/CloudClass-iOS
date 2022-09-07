//
//  FcrProctorScene.swift
//  AgoraProctorUI
//
//  Created by LYY on 2022/9/6.
//

import AgoraUIBaseViews
import Masonry
import AgoraEduContext

@objc public enum FcrUISceneExitReason: Int {
    case normal, kickOut
}

@objc public protocol FcrProctorSceneDelegate: NSObjectProtocol {
    func onExit(reason: FcrUISceneExitReason)
}

@objc public class FcrProctorScene: UIViewController {
    private lazy var deviceTest = FcrProctorDeviceTestComponent(roomController: contextPool.room,
                                                                    userController: contextPool.user,
                                                                    mediaController: contextPool.media,
                                                                    streamController: contextPool.stream,
                                                                    delegate: self)
    
    private lazy var exam = FcrProctorExamComponent(roomController: contextPool.room,
                                                        userController: contextPool.user,
                                                        mediaController: contextPool.media,
                                                        streamController: contextPool.stream,
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
        
        if #available(iOS 13.0, *) {
            overrideUserInterfaceStyle = (agora_ui_mode == .agoraDark) ? .dark : .light
        }
        
        view.backgroundColor = .black

        addChildViewController(deviceTest,
                               toContainerView: view)

        deviceTest.view.mas_makeConstraints { make in
            make?.left.right().top().bottom().equalTo()(0)
        }
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
//        exam.modalPresentationStyle = .fullScreen
//        deviceTest.dismiss(animated: true) { [weak self] in
//            guard let `self` = self else {
//                return
//            }
//            self.present(self.exam,
//                         animated: true)
//        }
    }
    
    public func onDeviceTestExit() {
        deviceTest.dismiss(animated: true) { [weak self] in
            guard let `self` = self else {
                return
            }
            self.delegate?.onExit(reason: .normal)
        }
    }
    
    public func onExamExit() {
        delegate?.onExit(reason: .normal)
    }
}
