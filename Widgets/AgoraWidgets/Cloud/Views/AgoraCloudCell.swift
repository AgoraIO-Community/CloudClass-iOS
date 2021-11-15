//
//  AgoraCloudCell.swift
//  AgoraWidgets
//
//  Created by ZYP on 2021/10/21.
//

import AgoraUIBaseViews
import AgoraUIEduBaseViews
import Masonry

class AgoraCloudCell: AgoraBaseUITableViewCell {
    
    private let iconImageView = AgoraBaseUIImageView(frame: .zero)
    private let nameLabel = AgoraBaseUILabel()
    private let sizeLabel = AgoraBaseUILabel()
    private let timeLabel = AgoraBaseUILabel()
    private var info: Info = .empty
    
    override init(style: UITableViewCell.CellStyle,
                  reuseIdentifier: String?) {
        super.init(style: style,
                   reuseIdentifier: reuseIdentifier)
        
        backgroundColor = .white
        setup()
        initLayout()
        commonInit()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setup() {
        nameLabel.text = "文件名"
        sizeLabel.text = "大小"
        timeLabel.text = "修改时间"
        
        nameLabel.textColor = UIColor(rgb: 0x191919)
        sizeLabel.textColor = UIColor(rgb: 0x586376)
        timeLabel.textColor = UIColor(rgb: 0x586376)
        
        
        nameLabel.font = .systemFont(ofSize: 13)
        sizeLabel.font = .systemFont(ofSize: 13)
        timeLabel.font = .systemFont(ofSize: 13)
        
        contentView.addSubview(nameLabel)
        contentView.addSubview(sizeLabel)
        contentView.addSubview(timeLabel)
        contentView.addSubview(iconImageView)
    }
    
    private func initLayout() {
        iconImageView.mas_makeConstraints { make in
            make?.height.equalTo()(22)
            make?.width.equalTo()(22)
            make?.left.equalTo()(16)
            make?.centerY.equalTo()(self.contentView)
        }
        
        nameLabel.mas_makeConstraints { make in
            make?.left.equalTo()(self.iconImageView.mas_right)?.offset()(9)
            make?.centerY.equalTo()(self.contentView)
        }
        
        timeLabel.mas_makeConstraints { make in
            make?.centerY.equalTo()(self.contentView)
            make?.left.equalTo()(self.mas_right)?.offset()(-150)
        }
        
        sizeLabel.mas_makeConstraints { make in
            make?.centerY.equalTo()(self.contentView)
            make?.left.equalTo()(self.timeLabel.mas_left)?.offset()(-80)
        }
    }
    
    private func commonInit() {}
    
    func set(info: Info) {
        self.info = info
        iconImageView.image = GetWidgetImage(object: self,
                                             info.imageName)
        nameLabel.text = info.name
        sizeLabel.text = info.sizeString
        timeLabel.text = info.timeString
    }
}

extension AgoraCloudCell {
    struct Info {
        let imageName: String
        let name: String
        let sizeString: String
        let timeString: String
        
        static var empty: Info {
            Info(imageName: "",
                 name: "",
                 sizeString: "",
                 timeString: "")
        }
    }
}
