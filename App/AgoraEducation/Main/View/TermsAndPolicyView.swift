//
//  TermsAndPolicyView.swift
//  AgoraEducation
//
//  Created by LYY on 2021/7/26.
//  Copyright © 2021 Agora. All rights reserved.
//

import UIKit

class TermsAndPolicyView: UIView {
    @IBOutlet weak var termTitle: UILabel!
    @IBOutlet weak var termContent: UITextView!
    @IBOutlet weak var contentStack: UIStackView!
    @IBOutlet weak var borderView: UIView!
    @IBOutlet weak var agreeContents: UIView!
    @IBOutlet weak var checkButton: UIButton!
    @IBOutlet weak var agreeButton: UIButton!
    @IBOutlet weak var disagreeButton: UIButton!
    @IBOutlet weak var closeContent: UIView!
    @IBOutlet weak var closeButton: UIButton!
    var hasAccept = false
    var haveReadTerms = false
    override class func awakeFromNib() {
        super.awakeFromNib()
    }
    
    func setupViews() {
        agreeContents.isHidden = hasAccept
        closeContent.isHidden = !hasAccept
        agreeButton.isEnabled = haveReadTerms
        checkButton.setImage(TermsAndPolicyViewController.getPolicyPopped() ? UIImage(named: "checkBox_unchecked") : UIImage(named: "checkBox_unchecked"), for: .normal)
        termContent.attributedText = getTerms()
    }
    @IBAction func haveRead(_ sender: UIButton) {
        haveReadTerms.toggle()
        sender.setImage(self.haveReadTerms ? UIImage(named: "checkBox_checked") : UIImage(named: "checkBox_unchecked"), for: .normal)
        agreeButton.isEnabled = haveReadTerms
    }
    
    func getLanguage() -> Bool {
        guard let code = Locale.current.languageCode else {
            return false
        }
        return code.uppercased().contains("ZH") || code.uppercased().contains("CN")
    }
    
    func getTerms() -> NSAttributedString {
        if getLanguage() {
            if let rtfURL = Bundle.main.url(forResource: "Agora_Privacy_Policy_cn", withExtension: "rtf")
            {
                let rtfString = try? NSAttributedString(url: rtfURL, options: [NSAttributedString.DocumentReadingOptionKey.documentType : NSAttributedString.DocumentType.rtf], documentAttributes: nil)
                if let content = rtfString {
                    let newContent = NSMutableAttributedString(attributedString: content)
                    newContent.removeAttribute(NSAttributedString.Key.backgroundColor, range: NSRange(location: 0, length: newContent.length))
                    newContent.addAttributes([NSAttributedString.Key.foregroundColor: UIColor.gray], range: NSRange(location: 0, length: newContent.length))
                    return newContent
                }
            }
            return NSAttributedString()
        } else {
            if let rtfURL = Bundle.main.url(forResource: "Agora_Privacy_Policy_en", withExtension: "rtf")
            {
                let rtfString = try? NSAttributedString(url: rtfURL, options: [NSAttributedString.DocumentReadingOptionKey.documentType : NSAttributedString.DocumentType.rtf], documentAttributes: nil)
                if let content = rtfString {
                    let newContent = NSMutableAttributedString(attributedString: content)
                    newContent.removeAttribute(NSAttributedString.Key.backgroundColor, range: NSRange(location: 0, length: newContent.length))
                    newContent.addAttributes([NSAttributedString.Key.foregroundColor: UIColor.gray], range: NSRange(location: 0, length: newContent.length))
                    return newContent
                }
            }
            return NSAttributedString()
        }
    }
    
}

