//
//  AgoraChatPanelInOutCell.swift
//  AgoraEduSDK
//
//  Created by SRS on 2021/1/31.
//

import UIKit

@objcMembers public class AgoraChatPanelInOutCell: AgoraBaseCell {
    
    fileprivate let LabelTag = 99
    
    fileprivate lazy var inoutView: AgoraBaseView = {
        let view = AgoraBaseView()
        view.clipsToBounds = true
        view.backgroundColor = UIColor(red: 19/255.0, green: 25/255.0, blue: 111/255.0, alpha: 0.7)
        
        let label = AgoraBaseLabel()
        label.font = UIFont.systemFont(ofSize: AgoraDeviceAssistant.OS.isPad ? 12 : 8)
        label.textColor = UIColor(red: 155/255.0, green: 157/255.0, blue: 194/255.0, alpha: 1)
        label.textAlignment = .center
        label.tag = LabelTag
        view.addSubview(label)
        label.x = AgoraDeviceAssistant.OS.isPad ? 13 : 9
        label.right = AgoraDeviceAssistant.OS.isPad ? 13 : 9
        label.y = 0
        label.bottom = 0
        
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
        let label = self.inoutView.viewWithTag(LabelTag) as! AgoraBaseLabel
        label.text = text
        
        let rect: CGRect = (text).boundingRect(with: CGSize(width: CGFloat(MAXFLOAT), height: self.inoutView.height), options: .usesLineFragmentOrigin , attributes: [NSAttributedString.Key.font:label.font!], context: nil)
        label.width = rect.size.width + 1

        self.inoutView.layer.cornerRadius = (label.width + label.x + label.right) * 0.06
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
        self.inoutView.height = AgoraDeviceAssistant.OS.isPad ? 35 : 20
        self.inoutView.centerX = 0
        self.inoutView.centerY = 0
    }
}

