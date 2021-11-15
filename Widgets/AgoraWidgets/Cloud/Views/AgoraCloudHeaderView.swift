//
//  AgoraCloudHeaderView.swift
//  AgoraWidgets
//
//  Created by ZYP on 2021/10/21.
//

import AgoraUIBaseViews
import AgoraUIEduBaseViews
import Masonry

class AgoraCloudHeaderView: AgoraBaseUIView {
    private let nameLabel = AgoraBaseUILabel()
    private let sizeLabel = AgoraBaseUILabel()
    private let timeLabel = AgoraBaseUILabel()
    private let lineView = AgoraBaseUIView()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setup()
        initLayout()
        commonInit()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setup() {
        backgroundColor = UIColor(rgb: 0xF9F9FC)
        let textColor = UIColor(rgb: 0x191919)
        let lineColor = UIColor(rgb: 0xEEEEF7)
        
        nameLabel.text = "文件名"
        sizeLabel.text = "大小"
        timeLabel.text = "修改时间"
        
        nameLabel.textColor = textColor
        sizeLabel.textColor = textColor
        timeLabel.textColor = textColor
        lineView.backgroundColor = lineColor
        
        nameLabel.font = .systemFont(ofSize: 13)
        sizeLabel.font = .systemFont(ofSize: 13)
        timeLabel.font = .systemFont(ofSize: 13)
        
        addSubview(nameLabel)
        addSubview(sizeLabel)
        addSubview(timeLabel)
        addSubview(lineView)
    }
    
    private func commonInit() {
        
    }
    
    private func initLayout() {
        nameLabel.mas_makeConstraints { make in
            make?.centerY.equalTo()(self)
            make?.left.equalTo()(self)?.offset()(24)
        }
        
        timeLabel.mas_makeConstraints { make in
            make?.centerY.equalTo()(self)
            make?.left.equalTo()(self.mas_right)?.offset()(-150)
        }
        
        sizeLabel.mas_makeConstraints { make in
            make?.centerY.equalTo()(self)
            make?.left.equalTo()(self.timeLabel.mas_left)?.offset()(-80)
        }
        
        lineView.mas_makeConstraints { make in
            make?.left.equalTo()(self)
            make?.right.equalTo()(self)
            make?.bottom.equalTo()(self)
            make?.height.equalTo()(1)
        }
    }
    
    private func set(name: String,
                     sizeString: String,
                     timeString: String) {
        nameLabel.text = name
        timeLabel.text = timeString
        sizeLabel.text = sizeString
    }
}
