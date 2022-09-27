//
//  FcrInputAlertController.swift
//  AgoraEducation
//
//  Created by Jonathan on 2022/9/20.
//  Copyright © 2022 Agora. All rights reserved.
//

import UIKit

class FcrInputAlertController: UIViewController {
    
    static func show(in viewController: UIViewController,
                     text: String,
                     max: UInt? = nil,
                     min: UInt? = nil,
                     complete: ((String) -> Void)?) {
        let vc = FcrInputAlertController()
        vc.maxLenth = max
        vc.minLenth = min
        vc.textField.text = text
        vc.complete = complete
        vc.modalPresentationStyle = .overCurrentContext
        vc.modalTransitionStyle = .crossDissolve
        viewController.present(vc,
                               animated: true)
    }
    
    private var complete: ((String) -> Void)?
    
    private let contentView = UIView()
    
    private let textField = UITextField()
    
    private let submitButton = UIButton(type: .custom)
    
    private let countLabel = UILabel()
    
    private let infoLabel = UILabel()
    
    private var minLenth: UInt?
    
    private var maxLenth: UInt?
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = UIColor.black.withAlphaComponent(0.4)
        // Do any additional setup after loading the view.
        createViews()
        createConstrains()
        
        registerNoti()
        textField.becomeFirstResponder()
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesBegan(touches, with: event)
        let touch = touches.first
        let location = touch?.location(in: contentView)
        guard let l = location,
            l.y < 0
        else {
            return
        }
        textField.resignFirstResponder()
        complete = nil
        dismiss(animated: true)
    }
    
    func registerNoti() {
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(onKeyBoardShow(_:)),
                                               name: UIResponder.keyboardWillShowNotification,
                                               object: nil)
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(onKeyBoardHide(_:)),
                                               name: UIResponder.keyboardWillHideNotification,
                                               object: nil)
    }
}
// MARK: - Actions
private extension FcrInputAlertController {
    @objc func onKeyBoardShow(_ sender: NSNotification) {
        guard let userInfo = sender.userInfo,
              let value = userInfo["UIKeyboardBoundsUserInfoKey"] as? NSValue
        else {
            return
        }
        let height = value.cgRectValue.size.height
        let contentHeight = 40 + height + 100
        contentView.mas_updateConstraints { make in
            make?.height.equalTo()(contentHeight)
        }
    }
    
    @objc func onKeyBoardHide(_ sender: NSNotification) {
        contentView.mas_updateConstraints { make in
            make?.height.equalTo()(140)
        }
    }
    
    @objc func onClickSubmit(_ sender: UIButton) {
        let text = textField.text ?? ""
        if let max = maxLenth, text.count > max {
            return
        }
        if let min = minLenth, text.count < min {
            return
        }
        textField.resignFirstResponder()
        complete?(textField.text ?? "")
        complete = nil
        dismiss(animated: true)
    }
}
// MARK: - Creations
private extension FcrInputAlertController {
    func createViews() {
        contentView.backgroundColor = UIColor.white
        contentView.layer.cornerRadius = 30
        view.addSubview(contentView)
        
        textField.font = UIFont.systemFont(ofSize: 16)
        textField.cornerRadius = 12
        textField.clipsToBounds = true
        textField.layer.borderWidth = 1
        textField.layer.borderColor = UIColor.clear.cgColor
        textField.leftView = UIView(frame: CGRect(x: 0,
                                                  y: 0,
                                                  width: 14,
                                                  height: 40))
        textField.leftViewMode = .always
        textField.placeholder = "fcr_alert_input_ph".ag_localized()
        textField.backgroundColor = UIColor(hex: 0xF2F4F8)
        textField.clearButtonMode = .always
        contentView.addSubview(textField)
        
        submitButton.layer.cornerRadius = 12
        submitButton.backgroundColor = UIColor(hex: 0x357BF6)
        submitButton.setImage(UIImage(named: "fcr_input_submit"),
                              for: .normal)
        submitButton.addTarget(self,
                               action: #selector(onClickSubmit(_:)),
                               for: .touchUpInside)
        contentView.addSubview(submitButton)
        
        infoLabel.textColor = UIColor(hex: 0xF5655C)
        infoLabel.font = UIFont.systemFont(ofSize: 12)
        contentView.addSubview(infoLabel)
    }
    
    func createConstrains() {
        contentView.mas_makeConstraints { make in
            make?.height.equalTo()(140)
            make?.left.right().equalTo()(0)
            make?.bottom.equalTo()(40)
        }
        submitButton.mas_makeConstraints { make in
            make?.right.equalTo()(-16)
            make?.top.equalTo()(16)
            make?.width.height().equalTo()(48)
        }
        textField.mas_makeConstraints { make in
            make?.left.top().equalTo()(16)
            make?.height.equalTo()(submitButton)
            make?.right.equalTo()(submitButton.mas_left)?.offset()(-8)
        }
        infoLabel.mas_makeConstraints { make in
            make?.left.equalTo()(textField.mas_left)?.offset()(28)
            make?.top.equalTo()(textField.mas_bottom)?.offset()(6)
        }
    }
}
