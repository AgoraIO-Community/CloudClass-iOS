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

@objc public class AgoraEduUIManager: UIViewController, AgoraClassRoomManagement, AgoraUIContentContainer {
    /** 容器视图，用来框出一块16：9的适配区域*/
    public var contentView: UIView = UIView()
    
    weak var delegate: AgoraEduUIManagerCallback?
    
    var contextPool: AgoraEduContextPool
    
    var uiMode: FcrUIMode
    
    var language: FcrLanguage
    /// 弹窗控制器
    /** 控制器遮罩层，用来盛装控制器和处理手势触发消失事件*/
    private lazy var ctrlMaskView = UIView(frame: .zero)
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
    
    @objc public init(contextPool: AgoraEduContextPool,
                      delegate: AgoraEduUIManagerCallback?,
                      uiMode: FcrUIMode,
                      language: FcrLanguage) {
        self.uiMode = uiMode
        self.language = language
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
    
    // MARK: AgoraUIContentContainer
    @objc func initViews() {
        // mode set
        FcrUIGlobal.uiMode = uiMode
        FcrUIGlobal.launguage = language
        if #available(iOS 13.0, *) {
            overrideUserInterfaceStyle = (uiMode == .agoraDark) ? .dark : .light
        }
        
        view.addSubview(contentView)
        
        ctrlMaskView.isHidden = true
        
        let tap = UITapGestureRecognizer(target: self,
                                         action: #selector(onClickCtrlMaskView(_:)))
        
        ctrlMaskView.addGestureRecognizer(tap)
        
        view.addSubview(ctrlMaskView)
    }
    
    @objc func initViewFrame() {
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
        
        ctrlMaskView.mas_makeConstraints { make in
            make?.left.right().top().bottom().equalTo()(self.view)
        }
    }
    
    @objc func updateViewProperties() {
        view.backgroundColor = FcrUIColorGroup.systemBackgroundColor
        
        contentView.borderWidth = FcrUIFrameGroup.borderWidth
        contentView.layer.borderColor = FcrUIColorGroup.borderColor.cgColor
        contentView.backgroundColor = FcrUIColorGroup.systemForegroundColor
        
        let config = UIConfig.loading
        if let url = config.gifUrl,
           let data = try? Data(contentsOf: url) {
            AgoraLoading.setImageData(data)
        }
        AgoraLoading.setMessage(color: config.message.color,
                                font: config.message.font)
        AgoraLoading.setBackgroundColor(config.backgroundColor)
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
            guard !isBeingDismissed else {
                return
            }
            
            contextPool.room.leaveRoom()
            
            dismiss(animated: true) { [weak self] in
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
