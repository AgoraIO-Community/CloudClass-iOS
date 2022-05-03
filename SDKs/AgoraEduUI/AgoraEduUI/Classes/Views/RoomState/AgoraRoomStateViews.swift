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
        case unknown, good, bad, down
    }
    
    var timeLabel: AgoraBaseUILabel!
    
    var titleLabel: AgoraBaseUILabel!
    
    private var netStateView: AgoraBaseUIImageView!
    
    private var sepLine: AgoraBaseUIView!
        
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        createViews()
        createConstraint()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func setNetworkState(_ state: NetworkQuality) {
        switch state {
        case .unknown:
            netStateView.image = UIImage.agedu_named("ic_network_unknow")
        case .good:
            netStateView.image = UIImage.agedu_named("ic_network_good")
        case .bad:
            netStateView.image = UIImage.agedu_named("ic_network_bad")
        case .down:
            netStateView.image = UIImage.agedu_named("ic_network_down")
        default: break
        }
    }
}
// MARK: - Creations
private extension AgoraRoomStateBar {
    func createViews() {
        let ui = AgoraUIGroup()
        backgroundColor = .white
        
        netStateView = AgoraBaseUIImageView(image: UIImage.agedu_named("ic_network_good"))
        addSubview(netStateView)
        
        timeLabel = AgoraBaseUILabel()
        timeLabel.font = UIFont.systemFont(ofSize: 9)
        timeLabel.textColor = ui.color.room_state_label_before_color
        addSubview(timeLabel)
        
        sepLine = AgoraBaseUIView()
        sepLine.backgroundColor = ui.color.room_state_sep_line_color
        addSubview(sepLine)
        
        titleLabel = AgoraBaseUILabel()
        titleLabel.font = UIFont.systemFont(ofSize: 9)
        titleLabel.textColor = ui.color.room_state_title_color
        addSubview(titleLabel)
    }
    
    func createConstraint() {
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
            make?.width.greaterThanOrEqualTo()(60)
            make?.centerY.equalTo()(timeLabel.superview)
            if #available(iOS 11.0, *) {
                make?.right.equalTo()(self.mas_safeAreaLayoutGuideRight)?.offset()(UIDevice.current.isPad ? -12 : -6)
            } else {
                make?.right.equalTo()(self)?.offset()(UIDevice.current.isPad ? -12 : -6)
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

class FcrRecordingStateView: UIView {
    private let redView = UIView()
    let label = UILabel()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func initViews() {
        addSubview(redView)
        addSubview(label)
        
        // TODO: 合并 flex 分支后，将这些移动到 config 里
        updateViewProperties()
        updateViewFrame()
    }
    
    private func updateViewProperties() {
        let redViewWidth: CGFloat = 6
        let redViewCornerRadius: CGFloat = (redViewWidth * 0.5)
        
        redView.layer.cornerRadius = redViewCornerRadius
        redView.backgroundColor = UIColor(hexString: "#F04C36")
        
        let textColor = UIColor(hexString: "#677386" )
        let font = UIFont.systemFont(ofSize: 9)
        label.textColor = textColor
        label.font = font
    }
    
    private func updateViewFrame() {
        let redViewHeight: CGFloat = 6
        let redViewWidth: CGFloat = 6
        let redViewCornerRadius: CGFloat = (redViewWidth * 0.5)
        
        redView.mas_makeConstraints { make in
            make?.left.equalTo()(0)
            make?.centerY.equalTo()(0)
            make?.width.equalTo()(redViewWidth)
            make?.height.equalTo()(redViewHeight)
        }
        
        label.mas_makeConstraints { make in
            make?.right.equalTo()(0)
            make?.top.equalTo()(0)
            make?.bottom.equalTo()(0)
            make?.left.equalTo()(redView.mas_right)?.offset()(-10)
        }
    }
}
