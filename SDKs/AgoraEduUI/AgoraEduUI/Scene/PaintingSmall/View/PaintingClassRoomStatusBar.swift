//
//  PaintingClassRoomInfoBar.swift
//  AgoraEduUI
//
//  Created by HeZhengQing on 2021/9/22.
//

import AgoraUIBaseViews
import SnapKit

class PaintingClassRoomStatusBar: AgoraBaseUIView {
    
    public enum NetworkQuality: Int {
        // 网络状态：未知、好、一般、差
        case unknown, good, medium, bad
    }
    
    var netStateView: AgoraBaseUIImageView!
    
    var timeLabel: AgoraBaseUILabel!
    
    var sepLine: AgoraBaseUIView!
    
    var titleLabel: AgoraBaseUILabel!
        
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
private extension PaintingClassRoomStatusBar {
    func createViews() {
        layer.borderWidth = 1.0
        layer.borderColor = UIColor(rgb: 0xECECF1).cgColor
        layer.cornerRadius = 2.0
        
        netStateView = AgoraBaseUIImageView(image: AgoraUIImage(object: self, name: "ic_network_unknow"))
        addSubview(netStateView)
        
        timeLabel = AgoraBaseUILabel()
        timeLabel.font = UIFont.systemFont(ofSize: 9)
        timeLabel.textColor = UIColor(rgb: 0x677386)
        addSubview(timeLabel)
        
        sepLine = AgoraBaseUIView()
        sepLine.backgroundColor = UIColor(rgb: 0xD2D2E2)
        addSubview(sepLine)
        
        titleLabel = AgoraBaseUILabel()
        titleLabel.font = UIFont.systemFont(ofSize: 9)
        titleLabel.textColor = UIColor(rgb: 0x191919)
        addSubview(titleLabel)
    }
    
    func createConstrains() {
        netStateView.snp.makeConstraints { make in
            if #available(iOS 11.0, *) {
                make.left.equalTo(self.safeAreaLayoutGuide).offset(10)
            } else {
                make.left.equalTo(self).offset(10)
            }
            make.width.height.equalTo(20)
            make.centerY.equalToSuperview()
        }
        timeLabel.snp.makeConstraints { make in
            make.width.greaterThanOrEqualTo(62)
            make.centerY.equalToSuperview()
        }
        sepLine.snp.makeConstraints { make in
            make.right.equalTo(timeLabel.snp.left)
            make.width.equalTo(1)
            make.height.equalTo(6)
            make.centerY.equalToSuperview()
        }
        titleLabel.snp.makeConstraints { make in
            make.right.equalTo(sepLine.snp.left).offset(-8)
            make.centerY.equalToSuperview()
        }
    }
}
