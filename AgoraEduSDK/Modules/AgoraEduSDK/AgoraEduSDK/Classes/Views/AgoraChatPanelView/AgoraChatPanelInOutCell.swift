//
//  AgoraChatPanelInOutCell.swift
//  AgoraEduSDK
//
//  Created by SRS on 2021/1/31.
//

import UIKit

@objcMembers class AgoraChatPanelInOutCell: AgoraBaseUITableViewCell {

    fileprivate let LabelTag = 99
    
    fileprivate lazy var inoutView: AgoraBaseView = {
        let view = AgoraBaseView()
        view.clipsToBounds = true
        view.backgroundColor = UIColor(red: 19/255.0, green: 25/255.0, blue: 111/255.0, alpha: 0.7)
        
        let label = AgoraBaseUILabel()
        label.font = UIFont.systemFont(ofSize: AgoraDeviceAssistant.OS.isPad ? 12 : 8)
        label.textColor = UIColor(red: 155/255.0, green: 157/255.0, blue: 194/255.0, alpha: 1)
        label.textAlignment = .center
        label.tag = LabelTag
        view.addSubview(label)
        label.agora_x = AgoraDeviceAssistant.OS.isPad ? 13 : 9
        label.agora_right = AgoraDeviceAssistant.OS.isPad ? 13 : 9
        label.agora_y = 0
        label.agora_bottom = 0
        
        return view
    }()
    
    public override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        initView()
        initLayout()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    public override func awakeFromNib() {
        super.awakeFromNib()
        initView()
        initLayout()
    }
    
    public func updateCell(_ text: String) {
        let label = self.inoutView.viewWithTag(LabelTag) as! AgoraBaseUILabel
        label.text = text
        
        let rect: CGRect = (text).boundingRect(with: CGSize(width: CGFloat(MAXFLOAT), height: self.inoutView.agora_height), options: .usesLineFragmentOrigin , attributes: [NSAttributedString.Key.font:label.font!], context: nil)
        label.agora_width = rect.size.width + 1

        self.inoutView.layer.cornerRadius = (label.agora_width + label.agora_x + label.agora_right) * 0.06
    }
}

// MARK: Rect
extension AgoraChatPanelInOutCell {
    fileprivate func initView() {
        self.backgroundColor = UIColor.clear
        self.contentView.backgroundColor = UIColor.clear
        self.contentView.addSubview(self.inoutView)
    }
    
    fileprivate func initLayout() {
        self.inoutView.agora_height = AgoraDeviceAssistant.OS.isPad ? 35 : 20
        self.inoutView.agora_center_x = 0
        self.inoutView.agora_center_y = 0
    }
}

