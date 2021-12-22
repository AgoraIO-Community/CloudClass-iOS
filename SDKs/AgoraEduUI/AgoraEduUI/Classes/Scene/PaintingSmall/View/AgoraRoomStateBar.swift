//
//  PaintingClassRoomInfoBar.swift
//  AgoraEduUI
//
//  Created by HeZhengQing on 2021/9/22.
//

import AgoraUIBaseViews
import Masonry

class AgoraRoomStateBar: AgoraBaseUIView {
    
    public enum NetworkQuality: Int {
        // 网络状态：未知、好、一般、差
        case unknown, good, medium, bad
    }
    
    public var themeColor: UIColor? {
        didSet {
            if themeColor != nil, themeColor != .white {
                backgroundColor = themeColor
                titleLabel.textColor = UIColor.white.withAlphaComponent(0.7)
                timeLabel.textColor = UIColor.white.withAlphaComponent(0.7)
                sepLine.backgroundColor = UIColor.white.withAlphaComponent(0.7)
            } else {
                backgroundColor = .white
                titleLabel.textColor = UIColor(hex: 0x191919)
                timeLabel.textColor = UIColor(hex: 0x677386)
                sepLine.backgroundColor = UIColor(hex: 0xD2D2E2)
            }
        }
    }
    
    var timeLabel: AgoraBaseUILabel!
    
    var titleLabel: AgoraBaseUILabel!
    
    private var netStateView: AgoraBaseUIImageView!
    
    private var sepLine: AgoraBaseUIView!
        
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        createViews()
        createConstrains()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func setNetworkState(_ state: NetworkQuality) {
        switch state {
        case .unknown:
            netStateView.image = AgoraUIImage(object: self,
                                              name: "ic_network_unknow")
        case .good:
            netStateView.image = AgoraUIImage(object: self,
                                              name: "ic_network_good")
        case .medium:
            netStateView.image = AgoraUIImage(object: self,
                                              name: "ic_network_medium")
        case .bad:
            netStateView.image = AgoraUIImage(object: self,
                                              name: "ic_network_bad")
        default: break
        }
    }
}
// MARK: - Creations
private extension AgoraRoomStateBar {
    func createViews() {
        netStateView = AgoraBaseUIImageView(image: AgoraUIImage(object: self,
                                                                name: "ic_network_unknow"))
        addSubview(netStateView)
        
        timeLabel = AgoraBaseUILabel()
        timeLabel.font = UIFont.systemFont(ofSize: 9)
        timeLabel.textColor = UIColor(hex: 0x677386)
        addSubview(timeLabel)
        
        sepLine = AgoraBaseUIView()
        sepLine.backgroundColor = UIColor(hex: 0xD2D2E2)
        addSubview(sepLine)
        
        titleLabel = AgoraBaseUILabel()
        titleLabel.font = UIFont.systemFont(ofSize: 9)
        titleLabel.textColor = UIColor(hex: 0x191919)
        addSubview(titleLabel)
    }
    
    func createConstrains() {
        netStateView.mas_makeConstraints { make in
            if #available(iOS 11.0, *) {
                make?.left.equalTo()(self.mas_safeAreaLayoutGuideLeft)?.offset()(10)
            } else {
                make?.left.equalTo()(self)?.offset()(10)
            }
            make?.width.height().equalTo()(20)
            make?.centerY.equalTo()(netStateView.superview)
        }
        timeLabel.mas_makeConstraints { make in
            make?.width.greaterThanOrEqualTo()(84)
            make?.centerY.equalTo()(timeLabel.superview)
            if #available(iOS 11.0, *) {
                make?.right.equalTo()(self.mas_safeAreaLayoutGuideRight)?.offset()(-5)
            } else {
                make?.right.equalTo()(self)?.offset()(-5)
            }
        }
        sepLine.mas_makeConstraints { make in
            make?.right.equalTo()(timeLabel.mas_left)?.offset()(-8)
            make?.width.equalTo()(1)
            make?.height.equalTo()(6)
            make?.centerY.equalTo()(sepLine.superview)
        }
        titleLabel.mas_makeConstraints { make in
            make?.right.equalTo()(sepLine.mas_left)?.offset()(-8)
            make?.centerY.equalTo()(titleLabel.superview)
        }
    }
}
