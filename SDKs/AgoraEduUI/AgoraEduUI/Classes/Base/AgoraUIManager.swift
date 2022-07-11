//
//  AgoraUIManager.swift
//  AgoraEduUI
//
//  Created by Cavan on 2021/11/18.
//

import AgoraEduContext
import AgoraWidget
import UIKit

@objc public enum AgoraClassRoomExitReason: Int {
    case normal, kickOut
}

@objc public enum AgoraClassRoomExitRoomType: Int {
    case main, sub
}

@objc public protocol AgoraEduUIManagerCallback: NSObjectProtocol {
    func manager(_ manager: AgoraEduUIManager,
                 didExit reason: AgoraClassRoomExitReason)
}

protocol AgoraClassRoomManagement: NSObjectProtocol {
    func exitClassRoom(reason: AgoraClassRoomExitReason,
                       roomType: AgoraClassRoomExitRoomType)
}

@objc public class AgoraEduUIManager: UIViewController, AgoraClassRoomManagement {
    /** 容器视图，用来框出一块16：9的适配区域*/
    public var contentView: UIView = UIView()
    
    weak var delegate: AgoraEduUIManagerCallback?
    
    var contextPool: AgoraEduContextPool!
    
    var uiMode: AgoraUIMode
    /// 弹窗控制器
    /** 控制器遮罩层，用来盛装控制器和处理手势触发消失事件*/
    private var ctrlMaskView: UIView!
    /** 弹出显示的控制widget视图*/
    public weak var ctrlView: UIView? {
        willSet {
            UIApplication.shared.windows[0].endEditing(true)
            if let view = ctrlView {
                ctrlView?.removeFromSuperview()
                ctrlMaskView.isHidden = true
            }
            if let view = newValue {
                ctrlMaskView.isHidden = false
                self.view.addSubview(view)
            }
        }
    }
    
    public override init(nibName nibNameOrNil: String?,
                         bundle nibBundleOrNil: Bundle?) {
        self.uiMode = .agoraLight
        super.init(nibName: nibNameOrNil,
                   bundle: nibBundleOrNil)
    }
    
    @objc public init(contextPool: AgoraEduContextPool,
                      delegate: AgoraEduUIManagerCallback?,
                      uiMode: AgoraUIMode) {
        self.uiMode = uiMode
        super.init(nibName: nil,
                   bundle: nil)
        self.contextPool = contextPool
        self.delegate = delegate
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    public override func viewDidLoad() {
        super.viewDidLoad()
        
        // mode set
        UIMode = uiMode
        
        
        
        view.backgroundColor = FcrUIColorGroup.fcr_system_background_color
        
        // create content view
        contentView.borderWidth = FcrUIFrameGroup.fcr_border_width
        contentView.layer.borderColor = FcrUIColorGroup.fcr_border_color
        contentView.backgroundColor = FcrUIColorGroup.fcr_system_foreground_color
        view.addSubview(contentView)
        
        let width = max(UIScreen.main.bounds.width,
                        UIScreen.main.bounds.height)
        
        let height = min(UIScreen.main.bounds.width,
                         UIScreen.main.bounds.height)
        
        if (width / height) > (667.0 / 375.0) {
            contentView.mas_makeConstraints { make in
                make?.center.equalTo()(contentView.superview)
                make?.height.equalTo()(height)
                make?.width.equalTo()(height * 16.0 / 9.0)
            }
        } else {
            contentView.mas_makeConstraints { make in
                make?.center.equalTo()(contentView.superview)
                make?.width.equalTo()(width)
                make?.height.equalTo()(width * 9.0 / 16.0)
            }
        }
        
        // create ctrl mask view
        ctrlMaskView = UIView(frame: .zero)
        ctrlMaskView.isHidden = true
        
        let tap = UITapGestureRecognizer(target: self,
                                         action: #selector(onClickCtrlMaskView(_:)))
        
        ctrlMaskView.addGestureRecognizer(tap)
        
        view.addSubview(ctrlMaskView)
        
        ctrlMaskView.mas_makeConstraints { make in
            make?.left.right().top().bottom().equalTo()(self.view)
        }
    }
    
    @objc private func onClickCtrlMaskView(_ sender: UITapGestureRecognizer) {
        ctrlView = nil
        didClickCtrlMaskView()
    }
    /** mask空白区域被点击时子类的处理*/
    public func didClickCtrlMaskView() {
        // for override
    }
    
    public func ctrlViewAnimationFromView(_ formView: UIView) {
        guard let animaView = ctrlView else {
            return
        }
        // 算出落点的frame
        let rect = formView.convert(formView.bounds,
                                    to: self.view)
        
        var point = CGPoint(x: rect.minX - 8 - animaView.frame.size.width,
                            y: rect.minY)
        
        let estimateFrame = CGRect(origin: point,
                                   size: animaView.frame.size)
        
        if estimateFrame.maxY > self.contentView.frame.maxY - 10 {
            let gap: CGFloat = UIDevice.current.agora_is_pad ? 20 : 15
            point.y = self.contentView.frame.maxY - gap - animaView.bounds.height
        }
        
        animaView.frame = CGRect(origin: point,
                                 size: animaView.frame.size)
        // 运算动画锚点
        let anchorConvert = formView.convert(formView.bounds,
                                             to: animaView)
        
        let anchor = CGPoint(x: 1,
                             y: anchorConvert.origin.y / animaView.frame.height)
        // 开始动画运算
        let oldFrame = animaView.frame
        
        let position = CGPoint(x: animaView.layer.position.x + (anchor.x - 0.5) * animaView.bounds.width,
                               y: animaView.layer.position.y + (anchor.y - 0.5) * animaView.bounds.height)
        
        animaView.layer.anchorPoint = anchor
        animaView.frame = oldFrame
        animaView.alpha = 0.2
        animaView.transform = CGAffineTransform(scaleX: 0.8,
                                                y: 0.8)
        
        self.view.layoutIfNeeded()
        
        UIView.animate(withDuration: TimeInterval.agora_animation) {
            animaView.transform = .identity
            animaView.alpha = 1
        }
    }
    
    public override var shouldAutorotate: Bool {
        return true
    }
    
    public override var preferredInterfaceOrientationForPresentation: UIInterfaceOrientation {
        return .landscapeRight
    }
    
    public override var supportedInterfaceOrientations: UIInterfaceOrientationMask {
        return .landscapeRight
    }
    
    @objc public func exitClassRoom(reason: AgoraClassRoomExitReason,
                                    roomType: AgoraClassRoomExitRoomType = .main) {
        switch roomType {
        case .main:
            self.contextPool.room.leaveRoom()
            
            self.dismiss(animated: true) { [weak self] in
                guard let `self` = self else {
                    return
                }
                
                self.delegate?.manager(self,
                                       didExit: reason)
            }
        default:
            break
        }
    }
}
