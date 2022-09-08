//
//  RoomListTitleView.swift
//  AgoraEducation
//
//  Created by Jonathan on 2022/9/2.
//  Copyright © 2022 Agora. All rights reserved.
//

import UIKit

protocol RoomListTitleViewDelegate: NSObjectProtocol {
    func onClickJoin()
    
    func onClickCreate()
}
class RoomListTitleView: UIView {
    
    weak var delegate: RoomListTitleViewDelegate?
    
    private let cardView = UIView()
    
    private let titleLabel = UILabel()
    
    private let joinActionView = RoomListActionView(frame: .zero)
    
    private let createActionView = RoomListActionView(frame: .zero)
    
    private let joinButton = UIButton(type: .custom)
    
    private let createButton = UIButton(type: .custom)
    
    private var soildPercent: CGFloat = 0.0 {
        didSet {
            guard soildPercent != oldValue else {
                return
            }
            cardView.alpha = soildPercent
            titleLabel.alpha = 1 - soildPercent
            if soildPercent < 0.6 {
                createButton.isHidden = true
                joinButton.isHidden = true
                joinActionView.isHidden = false
                createActionView.isHidden = false
            } else {
                createButton.isHidden = false
                joinButton.isHidden = false
                joinActionView.isHidden = true
                createActionView.isHidden = true
            }
        }
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        createViews()
        createConstrains()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    public func setSoildPercent(_ percent: CGFloat) {
        soildPercent = percent
    }
    
    @objc func onClickJoin(_ sender: UIButton) {
        delegate?.onClickJoin()
    }
    
    @objc func onClickCreate(_ sender: UIButton) {
        delegate?.onClickCreate()
    }
    
}
// MARK: - Creations
private extension RoomListTitleView {
    func createViews() {
        cardView.backgroundColor = .white
        addSubview(cardView)
        
        titleLabel.font = UIFont.systemFont(ofSize: 20)
        titleLabel.textColor = UIColor.black
        titleLabel.text = "Flexibleclassroom"
        addSubview(titleLabel)
        
        joinActionView.iconView.image = UIImage(named: "")
        joinActionView.button.addTarget(self,
                                        action: #selector(onClickJoin(_:)),
                                        for: .touchUpInside)
        joinActionView.backgroundColor = .black
        addSubview(joinActionView)
        
        createActionView.iconView.image = UIImage(named: "")
        createActionView.button.addTarget(self,
                                          action: #selector(onClickCreate(_:)),
                                          for: .touchUpInside)
        createActionView.backgroundColor = .black
        addSubview(createActionView)
        
        joinButton.backgroundColor = .black
        joinButton.addTarget(self,
                             action: #selector(onClickJoin(_:)),
                             for: .touchUpInside)
        addSubview(joinButton)
        
        createButton.backgroundColor = .black
        createButton.addTarget(self,
                               action: #selector(onClickCreate(_:)),
                               for: .touchUpInside)
        addSubview(createButton)
    }
    
    func createConstrains() {
        cardView.mas_makeConstraints { make in
            make?.left.right().top().bottom().equalTo()(0)
        }
        titleLabel.mas_makeConstraints { make in
            make?.top.equalTo()(68)
            make?.left.equalTo()(16)
        }
        joinActionView.mas_makeConstraints { make in
            make?.left.equalTo()(24)
            make?.width.equalTo()(self)?.multipliedBy()(0.4)
            make?.height.equalTo()(56)
            make?.bottom.equalTo()(-20)
        }
        createActionView.mas_makeConstraints { make in
            make?.left.equalTo()(joinActionView.mas_right)?.offset()(15)
            make?.width.equalTo()(self)?.multipliedBy()(0.4)
            make?.height.equalTo()(56)
            make?.bottom.equalTo()(-20)
        }
        joinButton.mas_makeConstraints { make in
            make?.left.equalTo()(16)
            make?.width.height().equalTo()(32)
            make?.centerY.equalTo()(titleLabel)
        }
        createButton.mas_makeConstraints { make in
            make?.left.equalTo()(joinButton.mas_right)?.offset()(12)
            make?.width.height().equalTo()(32)
            make?.centerY.equalTo()(titleLabel)
        }
    }
}

private class RoomListActionView: UIView {
    
    let contentView = UIImageView(image: UIImage())
    
    let iconBGView = UIImageView(image: UIImage())
    
    let iconView = UIImageView(image: UIImage())
    
    let titleLabel = UILabel()
    
    let button = UIButton(type: .custom)
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        createViews()
        createConstrains()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func createViews() {
        addSubview(contentView)
        
        addSubview(iconBGView)
        
        addSubview(iconView)
        
        addSubview(button)
        
        addSubview(titleLabel)
    }
    
    func createConstrains() {
        contentView.mas_makeConstraints { make in
            make?.left.right().top().bottom().equalTo()(0)
        }
        iconBGView.mas_makeConstraints { make in
            make?.width.height().equalTo()(44)
            make?.left.equalTo()(8)
            make?.centerY.equalTo()(0)
        }
        iconView.mas_makeConstraints { make in
            make?.center.equalTo()(iconView)
        }
        titleLabel.mas_makeConstraints { make in
            make?.left.equalTo()(iconView.mas_right)
            make?.right.top().bottom().equalTo()(0)
        }
        button.mas_makeConstraints { make in
            make?.left.right().top().bottom().equalTo()(0)
        }
    }
}
