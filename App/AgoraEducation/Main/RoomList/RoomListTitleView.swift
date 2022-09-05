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
    
    let cardView = UIView()
    
    let titleLabel = UILabel()
    
    let joinButton = UIButton(type: .custom)
    
    let createButton = UIButton(type: .custom)
    
    let smallJoinButton = UIButton(type: .custom)
    
    let smallCreateButton = UIButton(type: .custom)
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        createViews()
        createConstrains()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    public func setSoildPercent(_ percent: CGFloat) {
        print(percent)
        cardView.alpha = percent
        titleLabel.alpha = 1 - percent
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
    }
    
    func createConstrains() {
        cardView.mas_makeConstraints { make in
            make?.left.right().top().bottom().equalTo()(0)
        }
        titleLabel.mas_makeConstraints { make in
            make?.top.equalTo()(68)
            make?.left.equalTo()(16)
        }
    }
}

private class RoomListActionView: UIView {
    
    let contentView = UIImageView(image: UIImage())
    
    let iconBGView = UIImageView(image: UIImage())
    
    let iconView = UIImageView(image: UIImage())
    
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
        
    }
    
    func createConstrains() {
        
    }
}
