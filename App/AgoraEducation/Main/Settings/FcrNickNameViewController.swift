//
//  FcrNickNameViewController.swift
//  AgoraEducation
//
//  Created by Jonathan on 2022/6/30.
//  Copyright © 2022 Agora. All rights reserved.
//

import UIKit

class FcrNickNameViewController: FcrOutsideClassBaseController {
    
    private let textField = UITextField(frame: .zero)
    
    private let line = UIView()

    override func viewDidLoad() {
        super.viewDidLoad()
        
        title = "settings_nickname".ag_localized()
        view.backgroundColor = .white
        createViews()
        createConstrains()
        
        textField.text = FcrUserInfoPresenter.shared.nickName
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        textField.becomeFirstResponder()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        FcrUserInfoPresenter.shared.nickName = textField.text ?? ""
    }
    
    override func touchesBegan(_ touches: Set<UITouch>,
                               with event: UIEvent?) {
        super.touchesBegan(touches, with: event)
        
        textField.resignFirstResponder()
    }
}
// MARK: - Creations
private extension FcrNickNameViewController {
    func createViews() {
        textField.textColor = UIColor(hex: 0x191919)
        textField.font = UIFont.systemFont(ofSize: 14)
        textField.clearButtonMode = .whileEditing
        view.addSubview(textField)
        
        line.backgroundColor = UIColor(hex: 0xEEEEF7)
        view.addSubview(line)
    }
    func createConstrains() {
        textField.mas_makeConstraints { make in
            make?.top.equalTo()(0)
            make?.left.equalTo()(16)
            make?.right.equalTo()(-16)
            make?.height.equalTo()(52)
        }
        line.mas_makeConstraints { make in
            make?.left.right().equalTo()(0)
            make?.height.equalTo()(1)
            make?.top.equalTo()(textField.mas_bottom)
        }
    }
}
