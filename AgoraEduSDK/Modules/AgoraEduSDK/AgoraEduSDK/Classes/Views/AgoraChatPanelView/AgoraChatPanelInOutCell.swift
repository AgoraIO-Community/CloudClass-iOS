//
//  AgoraChatPanelInOutCell.swift
//  AgoraEduSDK
//
//  Created by SRS on 2021/1/31.
//

import Foundation

@objcMembers public class AgoraChatPanelInOutCell: AgoraBaseCell {
    
    fileprivate let LabelTag = 99
    
    fileprivate lazy var inoutView: AgoraBaseView = {
        let view = AgoraBaseView()
        view.clipsToBounds = true
        view.backgroundColor = UIColor(red: 19/255.0, green: 25/255.0, blue: 111/255.0, alpha: 0.7)
        
        let label = AgoraBaseLabel()
        label.font = UIFont.systemFont(ofSize: 12)
        label.textColor = UIColor(red: 155/255.0, green: 157/255.0, blue: 194/255.0, alpha: 0.7)
        view.addSubview(label)
        label.x = AgoraDeviceAssistant.OS.isPad ? 13 : 6
        label.right = AgoraDeviceAssistant.OS.isPad ? 13 : 6
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
        label.text = "text"
        label.sizeToFit()
        let size = label.frame.size
        label.width = size.width
    }
}

// MARK: Rect
extension AgoraChatPanelInOutCell {
    fileprivate func initView() {
        self.contentView.backgroundColor = UIColor.white
        self.contentView.addSubview(self.inoutView)
    }
    
    fileprivate func initLayout() {
        self.inoutView.height = AgoraDeviceAssistant.OS.isPad ? 35 : 25
        self.inoutView.centerX = 0
        self.inoutView.centerY = 0
    }
}

