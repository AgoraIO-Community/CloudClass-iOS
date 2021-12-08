//
//  AgoraBoardView.swift
//  AgoraEduSDK
//
//  Created by SRS on 2021/2/13.
//

import AgoraUIBaseViews
import UIKit

@objc public protocol AgoraBoardViewDelegate: NSObjectProtocol {
    func didCancelDownloadPressed()
    func didCloseDownloadPressed()
    func didRetryDownloadPressed()
}

@objcMembers public class AgoraBoardView: AgoraBaseUIView  {
    private var contentView: UIView?
    private var alertLineLoadingView: AgoraAlertView?
    
    public weak var delegate: AgoraBoardViewDelegate?
    
    public override init(frame: CGRect) {
        super.init(frame: frame)
        self.initView()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        self.initView()
    }
    
    deinit {
        alertLineLoadingView = nil
    }
    
    func insertContentView(_ view: UIView) {
        self.contentView = view
        insertSubview(view,
                      at: 0)
        view.translatesAutoresizingMaskIntoConstraints = false
        view.agora_x = 0
        view.agora_y = 0
        view.agora_right = 0
        view.agora_bottom = 0
    }
    
    public func removeLoadingView() {
        AgoraLoading.removeLoading(in: self)
        
        self.alertLineLoadingView?.removeFromSuperview()
        self.alertLineLoadingView = nil
    }
}

extension AgoraBoardView {
    public func getBoardContainer() -> UIView {
        return self
    }
    
    public func setLoadingVisible(visible: Bool) {
        if visible {
            startCycleLoadingAlert()
        } else {
            stopCycleLoadingAlert()
        }
    }
    
    public func setDownloadProgress(progress: Float) {
        updateDownProcess(process: progress)
    }
    
    public func downloadTimeOut() {
        let messageLabel = AgoraAlertLabelModel()
        messageLabel.text = getLocalizedString("BoardWareProcessText")
        messageLabel.textColor = UIColor(rgb: 0x191919)
        
        let alert = AgoraAlertModel()
        alert.style = .LineLoading
        alert.messageLabel = messageLabel
        cancelDownload(alert)
    }
    
    public func downloadComplete() {
        alertLineLoadingView?.removeFromSuperview()
        alertLineLoadingView = nil
    }
    
    public func downloadError() {
        downloadFailedAlert()
    }
}

// MARK: - Private
private extension AgoraBoardView {
     func initView() {
        backgroundColor = .white
    }
}

// MARK: - AlertView
private extension AgoraBoardView {
    func startCycleLoadingAlert() {
        let message = getLocalizedString("LoaingText")
        AgoraLoading.addLoading(in: self, msg: message)
    }
    
    func stopCycleLoadingAlert() {
        AgoraLoading.removeLoading(in: self)
    }
    
    func downloadProcessAlert() {
        self.alertLineLoadingView?.removeFromSuperview()
        
        let alertView = AgoraAlertView(frame: .zero)
        addSubview(alertView)
        self.alertLineLoadingView = alertView
        
        let messageLabel = AgoraAlertLabelModel()
        messageLabel.text = getLocalizedString("BoardWareProcessText")
        messageLabel.textColor = UIColor(rgb: 0x191919)

        let styleModel = AgoraAlertModel()
        styleModel.style = .LineLoading
        styleModel.messageLabel = messageLabel
        
        self.alertLineLoadingView?.styleModel = styleModel
        self.alertLineLoadingView?.show(in: self)
    }
    
    func downloadFailedAlert() {
        self.alertLineLoadingView?.removeFromSuperview()
        
        // 显示失败
        let alertView = AgoraAlertView(frame: self.bounds)
        alertView.backgroundColor = UIColor(rgb: 0xffffff, alpha: 0.6)
        addSubview(alertView)
        self.alertLineLoadingView = alertView
        
        let imageModel = AgoraAlertImageModel()
        imageModel.name = "caution"
        imageModel.width =  UIDevice.current.isPad ? 22 * 1.2 : 22
        imageModel.height =  UIDevice.current.isPad ? 20 * 1.2 : 20
        
        let titleLabel = AgoraAlertLabelModel()
        titleLabel.text = getLocalizedString("BoardWareFailTitleText")
        titleLabel.textFont = UIFont.boldSystemFont(ofSize: UIDevice.current.isPad ? 18 : 16)
        titleLabel.textColor = UIColor(rgb: 0x191919)
        
        let messageLabel = AgoraAlertLabelModel()
        messageLabel.text = getLocalizedString("BoardWareFailMsgText")
        messageLabel.textColor = UIColor(rgb: 0x191919)
        
        let leftBtnLabel = AgoraAlertLabelModel()
        leftBtnLabel.text = getLocalizedString("BoardWareCloseText")
        leftBtnLabel.textFont = UIFont.systemFont(ofSize: UIDevice.current.isPad ? 18 : 16)
        leftBtnLabel.textColor = UIColor(rgb: 0x007AFF)
        let leftBtn = AgoraAlertButtonModel()
        leftBtn.titleLabel = leftBtnLabel
        leftBtn.tapActionBlock = { [unowned self] (index) -> Void in
            self.alertLineLoadingView = nil
            self.delegate?.didCloseDownloadPressed()
        }

        let rightBtnLabel = AgoraAlertLabelModel()
        rightBtnLabel.text = getLocalizedString("BoardWareRetryText")
        rightBtnLabel.textFont = UIFont.systemFont(ofSize:  UIDevice.current.isPad ? 18 : 16)
        rightBtnLabel.textColor = UIColor(rgb: 0x007AFF)
        let rightBtn = AgoraAlertButtonModel()
        rightBtn.titleLabel = rightBtnLabel
        rightBtn.tapActionBlock = { [unowned self] (index) -> Void in
            self.alertLineLoadingView = nil
            self.delegate?.didRetryDownloadPressed()
        }
    
        let styleModel = AgoraAlertModel()
        styleModel.style = .Alert
        styleModel.titleImage = imageModel
        styleModel.titleLabel = titleLabel
        styleModel.messageLabel = messageLabel
        styleModel.buttons = [leftBtn, rightBtn]
        self.alertLineLoadingView?.styleModel = styleModel
        self.alertLineLoadingView?.show(in: self)
    }
    
    func cancelDownload(_ styleModel: AgoraAlertModel) {
        let btnLabel = AgoraAlertLabelModel()
        btnLabel.text = getLocalizedString("BoardWareJumpText")
        btnLabel.textFont = UIFont.systemFont(ofSize: UIDevice.current.isPad ? 18 :  16)
        btnLabel.textColor = UIColor(rgb: 0x191919)
        
        let btn = AgoraAlertButtonModel()
        btn.titleLabel = btnLabel
        btn.tapActionBlock = { [unowned self] (index) -> Void in
            self.alertLineLoadingView?.removeFromSuperview()
            self.alertLineLoadingView = nil
            // 停止下载
            self.delegate?.didCancelDownloadPressed()
        }
        
        styleModel.buttons = [btn]
        self.alertLineLoadingView?.styleModel = styleModel
    }
    
    func updateDownProcess(process: Float) {
        if alertLineLoadingView?.superview == nil {
            downloadProcessAlert()
        }
        alertLineLoadingView?.process = process
    }
    
    func downloadCompletion() {
        alertLineLoadingView?.removeFromSuperview()
        alertLineLoadingView = nil
    }
    
    func getLocalizedString(_ key: String) -> String {
        return AgoraKitLocalizedString(key,
                                       object: self,
                                       resource: "AgoraUIEduBaseViews")
    }
}
