//
//  AgoraChatPanelView.swift
//  AgoraEduSDK
//
//  Created by SRS on 2021/1/31.
//

import UIKit

@objcMembers public class AgoraChatPanelView: AgoraBaseView {
    
    public var isMin: Bool = false {
        didSet {
            self.resizeView()
        }
    }
    
    fileprivate lazy var sendView: AgoraBaseView = {
        let view = AgoraBaseView()
        view.clipsToBounds = true
        view.backgroundColor = UIColor(red: 19/255.0, green: 25/255.0, blue: 111/255.0, alpha: 1)
        
        let sendContentView = AgoraBaseView()
        sendContentView.clipsToBounds = true
        sendContentView.backgroundColor = UIColor.white
        view.addSubview(sendContentView)
        sendContentView.x = AgoraDeviceAssistant.OS.isPad ? 8 : 8
        sendContentView.right = AgoraDeviceAssistant.OS.isPad ? 8 : 8
        sendContentView.height = AgoraDeviceAssistant.OS.isPad ? 28 : 28
        sendContentView.bottom = AgoraDeviceAssistant.OS.isPad ? 10 : 10
        sendContentView.layer.cornerRadius = sendContentView.height * 0.3
        
        let btn = AgoraBaseButton(type: .custom)
        btn.setImage(AgoraImageWithName("chat_send", self.classForCoder), for: .normal)
        btn.addTarget(self, action: #selector(onSendTouchEvent), for: .touchUpInside)
        sendContentView.addSubview(btn)
        btn.right = 3
        btn.resize(22, 22)
        btn.centerY = 0
        
        let textField = AgoraBaseTextField()
        textField.attributedPlaceholder = NSAttributedString(string:" 请输入你想说的话",attributes:[NSAttributedString.Key.foregroundColor: UIColor(red: 194/255.0, green: 213/255.0, blue: 229/255.0, alpha: 1)])
        textField.font = UIFont.systemFont(ofSize: 14)
        textField.returnKeyType = .send
        textField.delegate = self
        sendContentView.addSubview(textField)
        textField.x = AgoraDeviceAssistant.OS.isPad ? 10 : 10
        textField.right = btn.right + btn.width + 5
        textField.y = 0
        textField.bottom = 0
            
        return view
    }()
    
    

//    convenience public init(delegate: AgoraPageControlProtocol?) {
//        self.init(frame: CGRect.zero)
//        self.delegate = delegate
//    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.initView()
        self.initLayout()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

// MARK: Rect
extension AgoraChatPanelView {
    fileprivate func initView() {
        self.backgroundColor = UIColor(red: 143/255.0, green: 154/255.0, blue: 208/255.0, alpha: 1)
        self.clipsToBounds = true
        self.layer.cornerRadius = AgoraDeviceAssistant.OS.isPad ? 21 : 11
    }
    
    fileprivate func initLayout() {
        
        let sideGap: CGFloat = AgoraDeviceAssistant.OS.isPad ? 22 : 13

    }
    
    fileprivate func resizeView() {
        
    }
}

// MARK: UITextFieldDelegate
extension AgoraChatPanelView: UITextFieldDelegate {
    
}

// MARK: TouchEvent
extension AgoraChatPanelView {
    @objc fileprivate func onSendTouchEvent() {
        
    }
}

