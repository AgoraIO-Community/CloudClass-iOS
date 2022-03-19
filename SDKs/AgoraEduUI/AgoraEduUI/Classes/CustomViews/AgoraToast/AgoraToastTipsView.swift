//
//  AgoraToastTipsView.swift
//  AgoraUIEduBaseViews
//
//  Created by Jonathan on 2021/11/16.
//

import SwifterSwift
import Masonry
import UIKit

protocol AgoraToastTipsViewDelegate: NSObjectProtocol {
    func onDidFinishTips(_ tips: AgoraToastTipsView)
}

class AgoraToastTipsView: UIView {
    
    public weak var delegate: AgoraToastTipsViewDelegate?
    
    private var contentView: UIView!
            
    private var imageView: UIImageView!
    
    private var titleLabel: UILabel!
    
    init(msg: String,
         type: AgoraToastType = .notice) {
        super.init(frame: .zero)
        
        self.isUserInteractionEnabled = false
        self.createViews()
        self.titleLabel.text = msg
        self.createConstraint()
        switch type {
        case .notice:
            self.backgroundColor = UIColor(hex: 0xFAFFFF)
            self.layer.borderColor = UIColor(hex: 0x357BF6)?.cgColor
            self.imageView.image = UIImage.agedu_named("ic_toast_message_notice")
        case .warning:
            self.backgroundColor = UIColor(hex: 0xFFFBF4)
            self.layer.borderColor = UIColor(hex: 0xF0C996)?.cgColor
            self.imageView.image = UIImage.agedu_named("ic_toast_message_warning")
        case .error:
            self.backgroundColor = UIColor(hex: 0xFFF2F2)
            self.layer.borderColor = UIColor(hex: 0xF07766)?.cgColor
            self.imageView.image = UIImage.agedu_named("ic_toast_message_error")
        case .success:
            self.backgroundColor = UIColor(hex: 0xFAFFFF)
            self.layer.borderColor = UIColor(hex: 0x357BF6)?.cgColor
            self.imageView.image = UIImage.agedu_named("ic_toast_message_notice")
        }
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    public func start() {
        self.perform(#selector(stop), with: nil, afterDelay: 3)
        UIView.animate(withDuration: 0.1) {
            self.transform = CGAffineTransform(scaleX: 1.1, y: 1.1)
        } completion: { isFinish in
            UIView.animate(withDuration: 0.1) {
                self.transform = CGAffineTransform(scaleX: 1, y: 1)
            }
        }
    }
    
    @objc public func stop() {
        NSObject.cancelPreviousPerformRequests(withTarget: self,
                                               selector: #selector(stop),
                                               object: nil)
        self.delegate?.onDidFinishTips(self)
        UIView.animate(withDuration: TimeInterval.agora_animation) {
            self.frame.origin.y = 0
            self.transform = CGAffineTransform(scaleX: 0.9, y: 0.6)
            self.alpha = 0
        }
    }
}
// MARK: - Creations
extension AgoraToastTipsView {
    func createViews() {
        layer.borderColor = UIColor.white.cgColor
        layer.borderWidth = 1
        layer.cornerRadius = 4
        layer.shadowColor = UIColor(hex: 0x2F4192,
                                    transparency: 0.15)?.cgColor
        layer.shadowOffset = CGSize(width: 0,
                                    height: 2)
        layer.shadowOpacity = 1
        layer.shadowRadius = 6
        
        contentView = UIView()
        self.addSubview(contentView)
        
        imageView = UIImageView()
        self.addSubview(imageView)
        
        titleLabel = UILabel()
        titleLabel.textAlignment = .center
        titleLabel.textColor = UIColor(hex: 0x191919)
        titleLabel.font = UIFont.systemFont(ofSize: 14)
        self.addSubview(titleLabel)
    }
    
    func createConstraint() {
        let minWidth: CGFloat = 180
        if let width = titleLabel.text?.agora_size(font: titleLabel.font).width,
           width > minWidth {
            contentView.mas_makeConstraints { make in
                make?.left.right().top().bottom().equalTo()(0)
                make?.width.equalTo()(width+56)
                make?.height.equalTo()(44)
            }
        } else {
            contentView.mas_makeConstraints { make in
                make?.left.right().top().bottom().equalTo()(0)
                make?.width.equalTo()(minWidth + 56)
                make?.height.equalTo()(44)
            }
        }
        titleLabel.mas_makeConstraints { make in
            make?.centerX.equalTo()(0)?.offset()(10)
            make?.centerY.equalTo()(0)
        }
        imageView.mas_makeConstraints { make in
            make?.centerY.equalTo()(titleLabel)
            make?.right.equalTo()(titleLabel.mas_left)?.offset()(-6)
            make?.width.height().equalTo()(20)
        }
    }
}
