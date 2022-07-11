//
//  AgoraClassStateUIController.swift
//  AgoraEduUI
//
//  Created by LYY on 2022/3/17.
//

import AgoraUIBaseViews
import AgoraEduContext
import AgoraWidget
import Masonry
import UIKit

protocol AgoraClassStateUIControllerDelegate: NSObjectProtocol {
    func onShowStartClass()
}

class AgoraClassStateUIController: UIViewController {
    private var positionMoveFlag: Bool = false {
        didSet {
            if positionMoveFlag != oldValue {
                UIView.animate(withDuration: TimeInterval.agora_animation,
                               delay: 0,
                               options: .curveEaseInOut,
                               animations: { [weak self] in
                                guard let `self` = self else {
                                    return
                                }
                                let move: CGFloat = (UIDevice.current.agora_is_pad ? 49 : 44)
                                self.startButton.transform = CGAffineTransform(translationX: self.positionMoveFlag ? move : 0,
                                                                         y: 0)
                               }, completion: nil)
            }
        }
    }
    
    /**Views*/
    private var startButton = UIButton()
    
    /**Data*/
    private(set) var suggestSize: CGSize = UIDevice.current.agora_is_pad ? CGSize(width: 100,
                                                                           height: 34) : CGSize(width: 100,
                                                                                                height: 32)
    private weak var delegate: AgoraClassStateUIControllerDelegate?
    private var contextPool: AgoraEduContextPool
   
    init(context: AgoraEduContextPool,
         delegate: AgoraClassStateUIControllerDelegate?) {
        self.contextPool = context
        self.delegate = delegate
        super.init(nibName: nil,
                   bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        initViews()
        initViewFrame()
        updateViewProperties()
        
        contextPool.room.registerRoomEventHandler(self)
        contextPool.widget.add(self,
                               widgetId: kBoardWidgetId)
    }
    
    func dismissView() {
        view.isHidden = true
    }
}

// MARK: - AgoraUIContentContainer
extension AgoraClassStateUIController: AgoraUIContentContainer {
    func initViews() {
        startButton.addTarget(self,
                              action: #selector(onClickStart(_:)),
                              for: .touchUpInside)
        view.addSubview(startButton)
    }
    
    func initViewFrame() {
        startButton.mas_makeConstraints { make in
            make?.left.right().top().bottom().equalTo()(0)
        }
    }
    
    func updateViewProperties() {
        let ui = AgoraUIGroup()
        
        startButton.setTitle("fcr_room_start_class".agedu_localized(),
                             for: .normal)
        startButton.titleLabel?.font = ui.font.fcr_font13
        startButton.backgroundColor = FcrColorGroup.fcr_system_highlight_color
        startButton.setTitleColor(FcrColorGroup.fcr_text_contrast_color,
                                  for: .normal)
        startButton.layer.cornerRadius = ui.frame.fcr_round_container_corner_radius
        
        FcrColorGroup.borderSet(layer: startButton.layer)
    }
    
}

// MARK: - AgoraEduRoomHandler
extension AgoraClassStateUIController: AgoraEduRoomHandler {
    func onJoinRoomSuccess(roomInfo: AgoraEduContextRoomInfo) {
        if contextPool.room.getClassInfo().state == .before {
            delegate?.onShowStartClass()
        }
    }
}

// MARK: - AgoraWidgetMessageObserver
extension AgoraClassStateUIController: AgoraWidgetMessageObserver {
    func onMessageReceived(_ message: String,
                           widgetId: String) {
        guard widgetId == kBoardWidgetId,
              let signal = message.toBoardSignal() else {
            return
        }
        
        switch signal {
        case .WindowStateChanged(let state):
            positionMoveFlag = (state == .min)
        default:
            break
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
}
