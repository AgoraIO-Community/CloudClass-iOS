//
//  PaintingClassRoomInfoBar.swift
//  AgoraEduUI
//
//  Created by HeZhengQing on 2021/9/22.
//

import Masonry

class AgoraRoomStateBar: UIView, AgoraUIContentContainer {
    
    private var sepLine = UIView()
    
    lazy var netStateView = UIImageView()
    lazy var recordingStateView = UIView()
    lazy var recordingLabel = UILabel()
    lazy var timeLabel = UILabel()
    lazy var titleLabel = UILabel()
    
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
        
        recordingLabel.mas_makeConstraints { make in
            make?.right.equalTo()(titleLabel.mas_left)?.offset()(-10)
            make?.top.equalTo()(0)
            make?.bottom.equalTo()(0)
        }
        
        recordingStateView.mas_makeConstraints { make in
            make?.centerY.equalTo()(0)
            make?.width.height().equalTo()(6)
            make?.right.equalTo()(recordingLabel.mas_left)?.offset()(-10)
        }
    }
    
    func updateViewProperties() {
        let font = FcrUIFontGroup.fcr_font9
        
        timeLabel.font = font
        timeLabel.textColor = FcrUIColorGroup.fcr_text_level3_color
        
        sepLine.backgroundColor = FcrUIColorGroup.fcr_system_divider_color
        
        titleLabel.font = font
        titleLabel.textColor = FcrUIColorGroup.fcr_text_level1_color
        
        recordingStateView.backgroundColor = FcrUIColorGroup.fcr_system_error_color
        recordingStateView.layer.cornerRadius = FcrUIFrameGroup.fcr_toast_corner_radius
        
        recordingLabel.textColor = FcrUIColorGroup.fcr_text_level3_color
        recordingLabel.font = font
    }
}
