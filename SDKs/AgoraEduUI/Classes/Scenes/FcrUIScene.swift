//
//  AgoraUIManager.swift
//  AgoraEduUI
//
//  Created by Cavan on 2021/11/18.
//

import AgoraUIBaseViews
import SwifterSwift
import AgoraEduCore
import AgoraWidget
import UIKit

@objc public enum FcrUISceneExitReason: Int {
    case normal, kickOut
}

@objc public enum FcrUISceneExitType: Int {
    case main, sub
}

@objc public protocol FcrUISceneDelegate: NSObjectProtocol {
    func scene(_ scene: FcrUIScene,
               didExit reason: FcrUISceneExitReason)
}

protocol FcrUISceneExit: NSObjectProtocol {
    func exitScene(reason: FcrUISceneExitReason,
                   type: FcrUISceneExitType)
}

@objc public class FcrUIScene: UIViewController,
                               AgoraUIContentContainer,
                               FcrUISceneExit,
                               FcrAlert {
    public override var preferredInterfaceOrientationForPresentation: UIInterfaceOrientation {
        return .landscapeRight
    }
    
    public override var supportedInterfaceOrientations: UIInterfaceOrientationMask {
        return .landscapeRight
    }
    
    public override var shouldAutorotate: Bool {
        return true
    }
    
    /** 容器视图，用来框出一块16：9的适配区域*/
    public var contentView: UIView = UIView()
    
    var popover = AgoraPopover(options: [.type(.down),
                                         .blackOverlayColor(UIColor.clear),
                                         .cornerRadius(10.0),
                                         .arrowSize(CGSize.zero),
                                         .strokeColor(.black),
                                         .arrowPointerOffset(CGPoint(x: 0, y: 3))])
       
    
    weak var delegate: FcrUISceneDelegate?
    
    let contextPool: AgoraEduContextPool
    let sceneType: FcrUISceneType
    
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
    
    @objc public init(sceneType: FcrUISceneType,
                      contextPool: AgoraEduContextPool,
                      delegate: FcrUISceneDelegate?) {
        self.sceneType = sceneType
        self.contextPool = contextPool
        self.delegate = delegate
        
        super.init(nibName: nil,
                   bundle: nil)
    }
    
    deinit {
        #if DEBUG
        print("\(#function): \(self.classForCoder)")
        #endif
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
    
    // MARK: - AgoraUIContentContainer
    public func initViews() {
        if #available(iOS 13.0, *) {
            overrideUserInterfaceStyle = (agora_ui_mode == .agoraDark) ? .dark : .light
        }
        
        view.addSubview(contentView)
        
        ctrlMaskView.isHidden = true
        
        let tap = UITapGestureRecognizer(target: self,
                                         action: #selector(onClickCtrlMaskView(_:)))
        
        ctrlMaskView.addGestureRecognizer(tap)
        
        view.addSubview(ctrlMaskView)
        
        popover.layer.masksToBounds = false
    }
    
    public func initViewFrame() {
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
    
    public func updateViewProperties() {
        let shadow = FcrUIItemShadow()

        popover.layer.shadowColor = shadow.color
        popover.layer.shadowOffset = shadow.offset
        popover.layer.shadowOpacity = shadow.opacity
        popover.layer.shadowRadius = shadow.radius
        
        popover.backgroundColor = .clear
        popover.strokeColor = .clear
        popover.borderColor = .clear
        
        view.backgroundColor = FcrUIColorGroup.systemBackgroundColor
        
        contentView.layer.borderWidth = FcrUIFrameGroup.borderWidth
        contentView.layer.borderColor = FcrUIColorGroup.systemDividerColor.cgColor
        contentView.backgroundColor = FcrUIColorGroup.systemForegroundColor
        
        let loadingComponent = UIConfig.loading
        
        if let url = loadingComponent.gifUrl,
           let data = try? Data(contentsOf: url) {
            AgoraLoading.setImageData(data)
        }
        
        AgoraLoading.setMessage(color: loadingComponent.message.color,
                                font: loadingComponent.message.font)
        
        AgoraLoading.setBackgroundColor(loadingComponent.backgroundColor)

        let toastComponent = UIConfig.toast
        
        AgoraToast.setImages(noticeImage: toastComponent.noticeImage,
                             warningImage: toastComponent.warningImage,
                             errorImage: toastComponent.errorImage)
    }
    
    @objc public func exitScene(reason: FcrUISceneExitReason,
                                type: FcrUISceneExitType = .main) {
        switch type {
        case .main:
            guard !isBeingDismissed else {
                return
            }
            
            contextPool.room.leaveRoom()
            
            agora_dismiss(animated: true) { [weak self] in
                guard let `self` = self else {
                    return
                }
                
                self.delegate?.scene(self,
                                     didExit: reason)
            }
        default:
            break
        }
    }
    
    // MARK: - Popover
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
    
    func showPopover(contentView: UIView,
                     fromView: UIView) {
        popover.show(contentView,
                     fromView: fromView)
        
       
    }
}
