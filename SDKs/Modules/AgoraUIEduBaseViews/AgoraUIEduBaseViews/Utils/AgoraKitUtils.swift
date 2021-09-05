//
//  Utils.swift
//  AgoraEduSDK
//
//  Created by SRS on 2021/1/27.
//

import UIKit
import AgoraUIBaseViews

@discardableResult func AgoraShowToast(_ message: String,
                                       shared: Bool = true) -> AgoraBaseUIView? {
    if (message.count == 0) {
        return nil
    }
    
    var v: AgoraCourseTipsView?
    
    if shared {
        v = AgoraLocationAssistant.shared().toastView
        AgoraLocationAssistant.shared().delayHiddenToastView()
    } else {
        guard let superView = UIApplication.shared.keyWindow else {
            return nil
        }

        let view = AgoraCourseTipsView(frame: .zero)
        superView.addSubview(v!)
    
        view.agora_center_x = 0
        view.agora_bottom = 30 + (UIScreen.agora_is_notch ? 34 : 0)
        view.agora_height = AgoraCourseTipsView.allHeight()
        
        let time = 3 + (Double(message.count) / 20.0)
        DispatchQueue.main.asyncAfter(deadline: .now() + time) {
            view.removeFromSuperview()
        }
        
        v = view
    }
        
    guard let view = v else {
        return nil
    }
    
    view.isHidden = false
    view.setText(text: message)
    
    let boundingRect = message.agoraKitSize(font: v!.textLabelFont,
                                   width: CGFloat(MAXFLOAT),
                                   height: v!.agora_height)
    
    view.agora_width = boundingRect.width +  v!.textLabelLeadingConstraintConstant() * 2

    return view
}

public class AgoraLocationAssistant: NSObject {
    static let object = AgoraLocationAssistant()
    
    private var dispatchWork: DispatchWorkItem?

    fileprivate weak var loadingView: AgoraAlertView?
    fileprivate lazy var toastView: AgoraCourseTipsView? = {
        
        guard let superView = UIApplication.shared.keyWindow else {
            return nil
        }

        let v = AgoraCourseTipsView(frame: .zero)
        superView.addSubview(v)

        v.agora_center_x = 0
        v.agora_bottom = 30 + (UIScreen.agora_is_notch ? 34 : 0)
        v.agora_height = AgoraCourseTipsView.allHeight()
        return v
    }()
    
    func delayHiddenToastView() {
        dispatchWork?.cancel()
        guard let superView = UIApplication.shared.keyWindow, let toastV = self.toastView else {
            return
        }
        superView.addSubview(toastV)
        
        self.dispatchWork = DispatchWorkItem() {
            self.toastView?.isHidden = true
        }
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 3, execute: self.dispatchWork!)
    }
    
    static func shared() -> AgoraLocationAssistant {
        return object
    }
}

// MARK: AgoraUtils
@objcMembers public class AgoraUtils: NSObject {
    @discardableResult public static func showToast(message: String) -> AgoraBaseUIView? {
        return AgoraShowToast(message)
    }
    @discardableResult public static func showLoading(message: String, inView: UIView? = nil, shared: Bool = false) -> AgoraAlertView? {
        
        var view = inView
        if view == nil {
            view = UIApplication.shared.keyWindow
        }
        guard let superView = view else {
            return nil
        }
        
        var loadingView: AgoraAlertView?
        if shared {
            loadingView = AgoraLocationAssistant.shared().loadingView ?? AgoraAlertView(frame: .zero)
        } else {
            loadingView = AgoraAlertView(frame: .zero)
        }
        
        let alertView = loadingView!

        let messageLabel = AgoraAlertLabelModel()
        messageLabel.text = message
        
        let styleModel = AgoraAlertModel()
        styleModel.style = .GifLoading
        styleModel.messageLabel = messageLabel
        alertView.styleModel = styleModel
        
        if shared {
            if alertView.superview == nil {
                alertView.show(in: superView)
            }
            AgoraLocationAssistant.shared().loadingView = alertView
        } else {
            alertView.show(in: superView)
        }

        return alertView
    }
    
    @discardableResult public static func showAlert(imageModel:AgoraAlertImageModel?,
                                                    title: String,
                                                    message: String,
                                                    btnModels: [AgoraAlertButtonModel]) -> AgoraAlertView? {
        
        guard let superView = UIApplication.shared.keyWindow else {
            return nil
        }
        
        let alertView = AgoraAlertView(frame: superView.bounds)
        alertView.backgroundColor = UIColor(rgb: 0xffffff, alpha: 0.6)

        let titleLabel = AgoraAlertLabelModel()
        titleLabel.text = title
        titleLabel.textColor = UIColor(rgb: 0x030303)
        titleLabel.textFont = UIFont.boldSystemFont(ofSize:  AgoraKitDeviceAssistant.OS.isPad ? 18 : 17)
        
        let messageLabel = AgoraAlertLabelModel()
        messageLabel.textColor = UIColor(rgb: 0x586376)
        messageLabel.textFont = UIFont.boldSystemFont(ofSize:  AgoraKitDeviceAssistant.OS.isPad ? 18 : 13)
        messageLabel.text = message

        btnModels.forEach { (model) in
            let btnLabel = AgoraAlertLabelModel()
            btnLabel.text = model.titleLabel?.text ?? ""
            btnLabel.textFont = UIFont.systemFont(ofSize:  AgoraKitDeviceAssistant.OS.isPad ? 18 : 17)
            btnLabel.textColor = UIColor(rgb: 0x357BF6)
            model.titleLabel = btnLabel
        }
        
        let styleModel = AgoraAlertModel()
        styleModel.style = .Alert
        if let model = imageModel {
            styleModel.titleImage = model
        }
        styleModel.titleLabel = titleLabel
        styleModel.messageLabel = messageLabel
        styleModel.buttons = btnModels
        alertView.styleModel = styleModel
        alertView.show(in: superView)
        return alertView
    }
    
    @discardableResult public static func showForbiddenAlert() -> AgoraAlertView? {
        
        let btnLabel = AgoraAlertLabelModel()
        btnLabel.text = AgoraKitLocalizedString("SureText")
        let btnModel = AgoraAlertButtonModel()
        btnModel.titleLabel = btnLabel
        btnModel.tapActionBlock = {(index) -> Void in
        }
        let alertView = showAlert(imageModel: nil,
                             title: AgoraKitLocalizedString("ForbidNoticeText"),
                             message: AgoraKitLocalizedString("ForbidText"),
                             btnModels: [btnModel])
    
        return alertView
    }
}
