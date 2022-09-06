//
//  FcrInviligatorScene.swift
//  AgoraInvigilatorUI
//
//  Created by LYY on 2022/9/6.
//

import AgoraUIBaseViews
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
                                                                    delegate: self)
    
    private lazy var exam = FcrInviligatorExamComponent(contextPool: contextPool)
    
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
        
        view.backgroundColor = .black
        addChildViewController(deviceTest,
                               toContainerView: view)
        view.addSubview(deviceTest.view)
        
        deviceTest.view.mas_makeConstraints { make in
            make?.left.right().top().bottom().equalTo()(0)
        }
    }
}

// MARK: - FcrInviligatorDeviceTestComponentDelegate
extension FcrInviligatorScene: FcrInviligatorDeviceTestComponentDelegate {
    public func onDeviceTestJoinExamSuccess() {
        present(exam,
                animated: true)
    }
    
    public func onDeviceTestExit() {
        delegate?.
    }
}
