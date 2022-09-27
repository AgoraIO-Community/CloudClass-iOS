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
    
    func onClickSetting()
    
    func onEnterDebugMode()
}
class RoomListTitleView: UIView {
    
    weak var delegate: RoomListTitleViewDelegate?
    
    private let cardView = UIView()
    
    private let titleLabel = UILabel()
    
    private let joinActionView = RoomListActionView(frame: .zero)
    
    private let createActionView = RoomListActionView(frame: .zero)
    
    private let joinButton = UIButton(type: .custom)
    
    private let createButton = UIButton(type: .custom)
    
    private let settingButton = UIButton(type: .custom)
    
    private var debugCount: Int = 0
    
    private var soildPercent: CGFloat = 0.0 {
        didSet {
            guard soildPercent != oldValue else {
                return
            }
            cardView.alpha = soildPercent
            titleLabel.alpha = 1 - soildPercent
            if soildPercent < 0.6 {
                titleLabel.isHidden = false
                createButton.isHidden = true
                joinButton.isHidden = true
                joinActionView.isHidden = false
                createActionView.isHidden = false
            } else {
                titleLabel.isHidden = true
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
    
    @objc func onTouchDebug() {
        guard debugCount >= 10 else {
            debugCount += 1
            return
        }
        delegate?.onEnterDebugMode()
    }
    
    @objc func onClickSetting(_ sender: UIButton) {
        delegate?.onClickSetting()
    }
}
// MARK: - Creations
private extension RoomListTitleView {
    func createViews() {
        cardView.backgroundColor = .white
        addSubview(cardView)
        
        titleLabel.font = UIFont.boldSystemFont(ofSize: 20)
        titleLabel.textColor = UIColor.black
        titleLabel.text = "fcr_room_list_title".ag_localized()
        titleLabel.isUserInteractionEnabled = true
        addSubview(titleLabel)
        let tap = UITapGestureRecognizer(target: self,
                                         action: #selector(onTouchDebug))
        titleLabel.addGestureRecognizer(tap)
        
        joinActionView.iconView.image = UIImage(named: "fcr_room_list_join")
        joinActionView.titleLabel.text = "fcr_room_list_join".ag_localized()
        joinActionView.button.addTarget(self,
                                        action: #selector(onClickJoin(_:)),
                                        for: .touchUpInside)
        addSubview(joinActionView)
        
        createActionView.iconView.image = UIImage(named: "fcr_room_list_create")
        createActionView.titleLabel.text = "fcr_room_list_create".ag_localized()
        createActionView.button.addTarget(self,
                                          action: #selector(onClickCreate(_:)),
                                          for: .touchUpInside)
        addSubview(createActionView)
        
        joinButton.titleLabel?.font = UIFont.boldSystemFont(ofSize: 20)
        joinButton.setTitleColor(.black,
                                 for: .normal)
        joinButton.setBackgroundImage(UIImage(named: "fcr_room_list_action_bg"),
                                      for: .normal)
        
        joinButton.setImage(UIImage(named: "fcr_room_list_join"),
                            for: .normal)
        joinButton.addTarget(self,
                             action: #selector(onClickJoin(_:)),
                             for: .touchUpInside)
        addSubview(joinButton)
        
        createButton.setBackgroundImage(UIImage(named: "fcr_room_list_action_bg"),
                                        for: .normal)
        createButton.setImage(UIImage(named: "fcr_room_list_create"),
                              for: .normal)
        createButton.addTarget(self,
                               action: #selector(onClickCreate(_:)),
                               for: .touchUpInside)
        addSubview(createButton)
        
        settingButton.setImage(UIImage(named: "fcr_room_list_setting"),
                               for: .normal)
        settingButton.addTarget(self,
                                action: #selector(onClickSetting(_:)),
                                for: .touchUpInside)
        addSubview(settingButton)
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
        settingButton.mas_makeConstraints { make in
            make?.centerY.equalTo()(titleLabel)
            make?.right.equalTo()(-14)
        }
    }
}

private class RoomListActionView: UIView {
    
    private let contentView = UIImageView(image: UIImage(named: "fcr_room_list_start_button_bg"))
    
    private let iconBGView = UIImageView(image: UIImage(named: "fcr_room_list_action_bg"))
    
    public let iconView = UIImageView(image: UIImage())
    
    public let titleLabel = UILabel()
    
    public let button = UIButton(type: .custom)
    
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
        
        titleLabel.font = UIFont.systemFont(ofSize: 16)
        titleLabel.textColor = .black
        titleLabel.textAlignment = .center
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
            make?.center.equalTo()(iconBGView)
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
