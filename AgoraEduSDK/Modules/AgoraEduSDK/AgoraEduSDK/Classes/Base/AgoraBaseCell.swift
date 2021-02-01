//
//  AgoraBaseCell.swift
//  AgoraEduSDK
//
//  Created by SRS on 2021/1/31.
//

import UIKit

@objcMembers public class AgoraBaseCell: UITableViewCell {
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    public override func awakeFromNib() {
        super.awakeFromNib()
    }
}
