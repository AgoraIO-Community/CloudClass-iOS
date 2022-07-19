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
    
    private lazy var contentView = UIView()
            
    private lazy var imageView = UIImageView()
    
    private lazy var titleLabel = UILabel()
    
    private var type: AgoraToastType
    
    init(msg: String,
         type: AgoraToastType = .notice) {
        self.type = type
        
        super.init(frame: .zero)
        
        self.isUserInteractionEnabled = false
        
        self.initViews()
        self.titleLabel.text = msg
        self.initViewFrame()
        self.updateViewProperties()
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
extension AgoraToastTipsView: AgoraUIContentContainer {
    func initViews() {
        addSubview(contentView)
        addSubview(imageView)
        
        titleLabel.textAlignment = .center
        self.addSubview(titleLabel)
    }
    
    func initViewFrame() {
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
    
    func updateViewProperties() {
        let config = UIConfig.toast
        
        layer.cornerRadius = config.cornerRadius
        
        layer.shadowColor = config.shadow.color
        layer.shadowOffset = config.shadow.offset
        layer.shadowOpacity = config.shadow.opacity
        layer.shadowRadius = config.shadow.radius
        
        titleLabel.textColor = config.label.color
        titleLabel.font = config.label.font
        
        switch type {
        case .notice:
            backgroundColor = config.safeBackgroundColor
            imageView.image = config.noticeImage
        case .warning:
            backgroundColor = config.warningBackgroundColor
            imageView.image = config.warningImage
        case .error:
            backgroundColor = config.errorBackgroundColor
            imageView.image = config.warningImage
        }
    }
}
