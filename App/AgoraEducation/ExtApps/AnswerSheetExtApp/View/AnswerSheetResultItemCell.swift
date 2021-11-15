//
//  AnswerSheetResultItemCell.swift
//  AgoraExtApp
//
//  Created by Jonathan on 2021/10/27.
//

import UIKit

class AnswerSheetResultItemCell: UITableViewCell {
    
    public var nameLabel: UILabel!
    
    public var timeLabel: UILabel!
    
    public var answerLabel: UILabel!
    
    private var containerView: UIStackView!
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        createViews()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        containerView.frame = bounds
    }
    
    private func createViews() {
        containerView = UIStackView(frame: .zero)
        containerView.backgroundColor = .clear
        containerView.axis = .horizontal
        containerView.distribution = .fillEqually
        containerView.alignment = .fill
        contentView.addSubview(containerView)
        
        nameLabel = UILabel(frame: .zero)
        nameLabel.textAlignment = .center
        nameLabel.numberOfLines = 0
        nameLabel.font = UIFont.systemFont(ofSize: 13)
        nameLabel.textColor = UIColor(hex: 0x191919)
        containerView.addArrangedSubview(nameLabel)
        
        timeLabel = UILabel(frame: .zero)
        timeLabel.textAlignment = .center
        timeLabel.numberOfLines = 0
        timeLabel.font = UIFont.systemFont(ofSize: 13)
        timeLabel.textColor = UIColor(hex: 0x191919)
        containerView.addArrangedSubview(timeLabel)
        
        answerLabel = UILabel(frame: .zero)
        answerLabel.textAlignment = .center
        answerLabel.numberOfLines = 0
        answerLabel.font = UIFont.systemFont(ofSize: 13)
        answerLabel.textColor = UIColor(hex: 0x191919)
        containerView.addArrangedSubview(answerLabel)
    }
}
