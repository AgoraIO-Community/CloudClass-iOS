//
//  FcrTermsViewController.swift
//  AgoraEducation
//
//  Created by Jonathan on 2022/7/4.
//  Copyright © 2022 Agora. All rights reserved.
//

import UIKit

class FcrDisclaimerViewController: FcrOutsideClassBaseController {
    
    private let textLabel = UILabel()
    
    private let infoLabel = UILabel()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.backgroundColor = UIColor(hex: 0xF9F9FC)
        title = "settings_disclaimer_title".ag_localized()
        createViews()
        createConstrains()
    }
}
// MARK: - Creations
private extension FcrDisclaimerViewController {
    func createViews() {
        textLabel.numberOfLines = 0
        let attrString = NSMutableAttributedString(string: "settings_disclaimer_detail".ag_localized())
        let paraStyle = NSMutableParagraphStyle()
        paraStyle.paragraphSpacing = 21
        let attr: [NSAttributedString.Key : Any] = [.font: UIFont.systemFont(ofSize: 14),
                                                    .foregroundColor: UIColor(hex: 0x586376) as Any,
                                                    .paragraphStyle: paraStyle]
        attrString.addAttributes(attr,
                                 range: NSRange(location: 0,
                                                length: attrString.length))
        textLabel.attributedText = attrString
        view.addSubview(textLabel)
        
        infoLabel.text = "settings_powerd_by".ag_localized()
        infoLabel.font = UIFont.systemFont(ofSize: 12)
        infoLabel.textColor = UIColor(hex: 0x7D8798)
        infoLabel.textAlignment = .center
        view.addSubview(infoLabel)
    }
    
    func createConstrains() {
        textLabel.mas_makeConstraints { make in
            make?.left.equalTo()(10)
            make?.right.equalTo()(-10)
            make?.top.equalTo()(10)
        }
        infoLabel.mas_makeConstraints { make in
            make?.left.right().equalTo()(0)
            make?.bottom.equalTo()(-20)
        }
    }
}
