//
//  Utils.swift
//  AgoraEduSDK
//
//  Created by SRS on 2021/1/27.
//

import UIKit
import AgoraUIBaseViews

public class AgoraLocationAssistant: NSObject {
    static let object = AgoraLocationAssistant()
        
    fileprivate lazy var alertView: AgoraAlertView? = {
        
        guard let superView = UIApplication.shared.keyWindow else {
            return nil
        }
        let alertView = AgoraAlertView(frame: superView.bounds)
        
        alertView.backgroundColor = UIColor(rgb: 0xffffff, alpha: 0.6)
        return alertView
    }()
    
    static func shared() -> AgoraLocationAssistant {
        return object
    }
}

// MARK: AgoraUtils
@objcMembers public class AgoraUtils: NSObject {
    
    @discardableResult public static func showAlert(imageModel:AgoraAlertImageModel?,
                                                    title: String,
                                                    message: String,
                                                    btnModels: [AgoraAlertButtonModel]) -> AgoraAlertView? {
        guard let superView = UIApplication.shared.keyWindow else {
            return nil
        }
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
        AgoraLocationAssistant.shared().alertView?.styleModel = styleModel
        AgoraLocationAssistant.shared().alertView?.show(in: superView)
        return AgoraLocationAssistant.shared().alertView
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
