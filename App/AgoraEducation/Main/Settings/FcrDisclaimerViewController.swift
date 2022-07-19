//
//  FcrTermsViewController.swift
//  AgoraEducation
//
//  Created by Jonathan on 2022/7/4.
//  Copyright © 2022 Agora. All rights reserved.
//

import UIKit

class FcrDisclaimerViewController: UIViewController {
    
    private let textLabel = UILabel()
    
    private let infoLabel = UILabel()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.backgroundColor = UIColor(hex: 0xF9F9FC)
        title = NSLocalizedString("settings_disclaimer_title",
                                  comment: "")
        createViews()
        createConstrains()
    }
}
// MARK: - Creations
private extension FcrDisclaimerViewController {
    func createViews() {
        textLabel.numberOfLines = 0
        let attrString = NSMutableAttributedString(string: NSLocalizedString("settings_disclaimer_detail",
                                                                             comment: ""))
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
        
        infoLabel.text = NSLocalizedString("settings_powerd_by",
                                           comment: "")
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
