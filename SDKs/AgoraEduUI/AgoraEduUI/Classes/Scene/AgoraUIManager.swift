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

@objc public protocol AgoraEduUIManagerCallBack: NSObjectProtocol {
    func manager(_ manager: AgoraEduUIManager,
                 didExit reason: AgoraClassRoomExitReason)
}

protocol AgoraClassRoomManagement: NSObjectProtocol {
    func exitClassRoom(reason: AgoraClassRoomExitReason)
}

@objc public class AgoraEduUIManager: UIViewController, AgoraClassRoomManagement {
    /** 容器视图，用来框出一块16：9的适配区域*/
    public var contentView: UIView!
    
    weak var delegate: AgoraEduUIManagerCallBack?
    
    var contextPool: AgoraEduContextPool!
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
        super.init(nibName: nibNameOrNil,
                   bundle: nibBundleOrNil)
    }
    
    @objc public init(contextPool: AgoraEduContextPool,
                      delegate: AgoraEduUIManagerCallBack) {
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
        
        let ui = AgoraUIGroup()
        self.view.backgroundColor = ui.color.screen_bg_color
        // create content view
        
        self.contentView = UIView()
        contentView.borderWidth = ui.frame.room_border_width
        contentView.borderColor = ui.color.room_border_color
        contentView.backgroundColor = ui.color.room_bg_color
        self.view.addSubview(self.contentView)
        let width = max(UIScreen.main.bounds.width, UIScreen.main.bounds.height)
        let height = min(UIScreen.main.bounds.width, UIScreen.main.bounds.height)
        if width/height > 667.0/375.0 {
            contentView.mas_makeConstraints { make in
                make?.center.equalTo()(contentView.superview)
                make?.height.equalTo()(height)
                make?.width.equalTo()(height * 16.0/9.0)
            }
        } else {
            contentView.mas_makeConstraints { make in
                make?.center.equalTo()(contentView.superview)
                make?.width.equalTo()(width)
                make?.height.equalTo()(width * 9.0/16.0)
            }
        }
        // create ctrl mask view
        ctrlMaskView = UIView(frame: .zero)
        ctrlMaskView.isHidden = true
        let tap = UITapGestureRecognizer(
            target: self, action: #selector(onClickCtrlMaskView(_:)))
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
        var point = CGPoint(x: rect.minX - 8 - animaView.frame.size.width, y: rect.minY)
        let estimateFrame = CGRect(origin: point,
                                 size: animaView.frame.size)
        if estimateFrame.maxY > self.contentView.frame.maxY - 10 {
            let gap: CGFloat = UIDevice.current.isPad ? 20 : 15
            point.y = self.contentView.frame.maxY - gap - animaView.bounds.height
        }
        animaView.frame = CGRect(origin: point, size: animaView.frame.size)
        // 运算动画锚点
        let anchorConvert = formView.convert(formView.bounds, to: animaView)
        let anchor = CGPoint(x: 1, y: anchorConvert.origin.y/animaView.frame.height)
        // 开始动画运算
        let oldFrame = animaView.frame
        let position = CGPoint(x: animaView.layer.position.x + (anchor.x - 0.5) * animaView.bounds.width,
                               y: animaView.layer.position.y + (anchor.y - 0.5) * animaView.bounds.height)
        animaView.layer.anchorPoint = anchor
        animaView.frame = oldFrame
        animaView.alpha = 0.2
        animaView.transform = CGAffineTransform(scaleX: 0.8, y: 0.8)
        self.view.layoutIfNeeded()
        UIView.animate(withDuration: 0.1) {
            animaView.transform = .identity
            animaView.alpha = 1
        } completion: { finish in
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
    
    @objc public func exitClassRoom(reason: AgoraClassRoomExitReason) {
        self.contextPool.room.leaveRoom()
        
        self.dismiss(animated: true) {
            self.delegate?.manager(self,
                                   didExit: reason)
        }
    }
}

extension Dictionary {
    func jsonString() -> String? {
        guard let data = try? JSONSerialization.data(withJSONObject: self,
                                                     options: .prettyPrinted) else {
            return nil
        }

        guard let jsonString = String(data: data,
                                      encoding: .utf8) else {
            return nil
        }
        return jsonString
    }
}

extension String {
    func json() -> [String: Any]? {
        guard let data = self.data(using: .utf8) else {
            return nil
        }

        return data.dic()
    }
    
    func toArr() -> [Any]? {
        guard let data = self.data(using: .utf8) else {
            return nil
        }
        
        return data.toArr()
    }
}

extension Data {
    func dic() -> [String: Any]? {
        guard let object = try? JSONSerialization.jsonObject(with: self,
                                                             options: [.mutableContainers]) else {
            return nil
        }

        guard let dic = object as? [String: Any] else {
            return nil
        }

        return dic
    }
    
    func toArr() -> [Any]? {
        guard let object = try? JSONSerialization.jsonObject(with: self,
                                                             options: [.mutableContainers]) else {
            return nil
        }

        guard let arr = object as? [Any] else {
            return nil
        }
        
        return arr
    }
}
