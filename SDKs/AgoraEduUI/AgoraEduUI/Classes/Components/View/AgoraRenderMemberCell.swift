//
//  AgoraRenderMemberCell.swift
//  AgoraEduUI
//
//  Created by Jonathan on 2021/12/9.
//

import UIKit

class AgoraRenderMemberCell: UICollectionViewCell {
    
    public let renderView = AgoraRenderMemberView(frame: .zero)
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        contentView.layer.cornerRadius = AgoraFit.scale(2)
        contentView.clipsToBounds = true
        contentView.addSubview(renderView)
        renderView.mas_makeConstraints { make in
            make?.left.right().top().bottom().equalTo()(0)
        }
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}
