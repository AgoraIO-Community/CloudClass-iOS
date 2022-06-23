//
//  PaintingClassRoomInfoBar.swift
//  AgoraEduUI
//
//  Created by HeZhengQing on 2021/9/22.
//

import Masonry

class AgoraRoomStateBar: UIView, AgoraUIContentContainer {
    
    private var sepLine = UIView()
    
    let netStateView = UIImageView()
    let recordingStateView = UIView()
    let recordingLabel = UILabel()
    let timeLabel = UILabel()
    let titleLabel = UILabel()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        initViews()
        initViewFrame()
        updateViewProperties()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func initViews() {
        addSubview(netStateView)
        addSubview(timeLabel)
        addSubview(sepLine)
        addSubview(titleLabel)
        addSubview(recordingStateView)
        addSubview(recordingLabel)
    }
    
    func initViewFrame() {
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
            make?.top.bottom().equalTo()(0)
            make?.width.greaterThanOrEqualTo()(60)
            
            let right: CGFloat = (UIDevice.current.agora_is_pad ? -12 : -6)
            
            if #available(iOS 11.0, *) {
                make?.right.equalTo()(self.mas_safeAreaLayoutGuideRight)?.offset()(right)
            } else {
                make?.right.equalTo()(self)?.offset()(right)
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
            make?.top.bottom().equalTo()(0)
        }
        
        let recordingViewRightOffset: CGFloat = -10
        
        recordingLabel.mas_makeConstraints { make in
            make?.right.equalTo()(titleLabel.mas_left)?.offset()(recordingViewRightOffset)
            make?.top.equalTo()(0)
            make?.bottom.equalTo()(0)
        }
        
        let redViewHeight: CGFloat = 6
        let redViewWidth: CGFloat = 6
        let redViewCornerRadius: CGFloat = (redViewWidth * 0.5)
        let redViewRightOffset: CGFloat = -10
        
        recordingStateView.mas_makeConstraints { make in
            make?.centerY.equalTo()(0)
            make?.width.equalTo()(redViewWidth)
            make?.height.equalTo()(redViewHeight)
            make?.right.equalTo()(recordingLabel.mas_left)?.offset()(redViewRightOffset)
        }
        
        recordingStateView.layer.cornerRadius = redViewCornerRadius
    }
    
    func updateViewProperties() {
        let ui = AgoraUIGroup()
        let frame = ui.frame
        let color = ui.color
        
        let font = frame.room_state_bar_font
        
        timeLabel.font = font
        timeLabel.textColor = color.room_state_label_before_color
        
        sepLine.backgroundColor = color.room_state_sep_line_color
        
        titleLabel.font = font
        titleLabel.textColor = color.room_state_title_color
        
        recordingStateView.backgroundColor = color.room_state_bar_recording_state_background_color
        
        recordingLabel.textColor = color.room_state_bar_recording_text_color
        recordingLabel.font = font
    }
}
