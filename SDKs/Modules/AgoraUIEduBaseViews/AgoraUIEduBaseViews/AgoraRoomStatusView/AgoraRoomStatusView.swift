//
//  RoomInfoOptionCell.swift
//  AgoraEducation
//
//  Created by HeZhengQing on 2021/9/10.
//  Copyright © 2021 Agora. All rights reserved.
//

import AgoraUIBaseViews

class AgoraRoomStatusView: AgoraBaseUIView {
    
    var netWorkView: UIImageView!
    
    var timeLabel: UILabel!
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        createViews()
        createConstrains()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}

// MARK: - Creations
private extension AgoraRoomStatusView {
    func createViews() {
        timeLabel = AgoraBaseUILabel()
        addSubview(timeLabel)
    }
    
    func createConstrains() {
        
    }
}
