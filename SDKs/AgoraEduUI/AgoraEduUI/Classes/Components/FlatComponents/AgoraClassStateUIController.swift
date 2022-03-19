//
//  AgoraClassStateUIController.swift
//  AgoraEduUI
//
//  Created by LYY on 2022/3/17.
//

import AgoraUIBaseViews
import AgoraEduContext
import Masonry
import UIKit

protocol AgoraClassStateUIControllerDelegate: NSObjectProtocol {
    func onShowStartClass()
}

class AgoraClassStateUIController: UIViewController {
    /**Data*/
    private(set) var suggestSize: CGSize = UIDevice.current.isPad ? CGSize(width: 100,
                                                                           height: 34) : CGSize(width: 100,
                                                                                                height: 32)
    private weak var delegate: AgoraClassStateUIControllerDelegate?
    private var contextPool: AgoraEduContextPool!
    /**Views*/
    private var startButton = UIButton()
    
    init(context: AgoraEduContextPool,
         delegate: AgoraClassStateUIControllerDelegate?) {
        super.init(nibName: nil,
                   bundle: nil)
        self.contextPool = context
        self.delegate = delegate
        
        contextPool.room.registerRoomEventHandler(self)
    }
    
    func dismissView() {
        view.isHidden = true
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        createViews()
        createConstraint()
    }
}

extension AgoraClassStateUIController: AgoraEduRoomHandler {
    func onJoinRoomSuccess(roomInfo: AgoraEduContextRoomInfo) {
        if contextPool.room.getClassInfo().state == .before {
            delegate?.onShowStartClass()
        }
    }
}

private extension AgoraClassStateUIController {
    @objc func onClickStart(_ sender: UIButton) {
        contextPool.room.startClass { [weak self] in
            self?.view.removeFromSuperview()
        } failure: { error in
            
        }
    }
    
    func createViews() {
        let ui = AgoraUIGroup()
        
        startButton.setTitle("fcr_room_start_class".agedu_localized(),
                             for: .normal)
        startButton.titleLabel?.font = .systemFont(ofSize: 13)
        startButton.backgroundColor = ui.color.common_base_tint_color
        startButton.setTitleColor(.white,
                                  for: .normal)
        startButton.layer.cornerRadius = ui.frame.class_state_button_corner_radius
        startButton.addTarget(self,
                              action: #selector(onClickStart(_:)),
                              for: .touchUpInside)
        view.addSubview(startButton)
    }
    
    func createConstraint() {
        startButton.mas_makeConstraints { make in
            make?.left.right().top().bottom().equalTo()(0)
        }
    }
}
