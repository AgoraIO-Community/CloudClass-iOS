//
//  AgoraUINavigationBar.swift
//  AgoraUIEduAppViews
//
//  Created by Cavan on 2021/3/3.
//

import UIKit
import AgoraUIBaseViews

@objcMembers public class AgoraUINavigationBar: AgoraBaseUIView {
    public enum NetworkQuality: Int {
        // 网络状态：未知、好、一般、差
        case unknown, good, medium, bad
    }
    
    private lazy var signalImgView: AgoraBaseUIImageView = {
        let view = AgoraBaseUIImageView(image: AgoraKitImage("unknownsignal"))
        return view
    }()
    
    private lazy var roomNameLabel: AgoraBaseUILabel = {
        let label = AgoraBaseUILabel()
        label.font = UIFont.systemFont(ofSize: 13)
        label.textColor = UIColor(rgb: 0x191919)
        label.textAlignment = .right
        return label
    }()
    
    private lazy var gridLineView: AgoraBaseUIView = {
        let view = AgoraBaseUIView()
        view.backgroundColor = UIColor(rgb: 0xECECF1)
        return view
    }()
    
    public private(set) lazy var timeLabel: AgoraBaseUILabel = {
        let label = AgoraBaseUILabel()
        label.font = UIFont.systemFont(ofSize: 13)
        return label
    }()
    
    public private(set) lazy var leaveButton: AgoraBaseUIButton = {
        let btn = AgoraBaseUIButton()
        btn.setImage(AgoraKitImage("leave"),
                     for: .normal)
        return btn
    }()
    
    private lazy var lineView: AgoraBaseUIView = {
        let lineV = AgoraBaseUIView()
        lineV.backgroundColor = UIColor.clear
        lineV.layer.borderWidth = 1
        lineV.layer.borderColor = UIColor(rgb: 0xECECF1).cgColor

        return lineV
    }()
    
    private let SwitchTag = 100

    public override func didMoveToWindow() {
        super.didMoveToWindow()
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
            self.updateCenterLayout()
        }
    }
    
    public override init(frame: CGRect) {
        super.init(frame: frame)
        self.initView()
        self.initLayout()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func updateCenterLayout() {
        let roomName = roomNameLabel.text ?? ""
        let roomTime = timeLabel.text ?? ""
        
        let roomNameLen = self.getTextWidthForComment(text: roomName,
                                                      font: roomNameLabel.font)
        let roomTimeLen = self.getTextWidthForComment(text: roomTime,
                                                      font: roomNameLabel.font)
        
        let gridLineViewWidth: CGFloat = 1
        let space: CGFloat = 20
        
        let len = roomNameLen + space + gridLineViewWidth + space + roomTimeLen
        let roomNameX = self.bounds.size.width * 0.5 - len * 0.5
        let gridLineX = roomNameX + space + roomNameLen
        let roomTimeX = gridLineX + space + 1
        
        roomNameLabel.agora_y = 0
        roomNameLabel.agora_bottom = 0
        roomNameLabel.agora_x = roomNameX
        roomNameLabel.agora_width = roomNameLen
        
        gridLineView.agora_x = gridLineX
        gridLineView.agora_width = 1
        gridLineView.agora_y = 8
        gridLineView.agora_bottom = 8

        timeLabel.agora_y = 0
        timeLabel.agora_bottom = 0
        timeLabel.agora_x = roomTimeX
        timeLabel.agora_width = roomTimeLen
    }
}

public extension AgoraUINavigationBar {
    func setClassroomName(_ name: String) {
        roomNameLabel.text = name
        updateCenterLayout()
    }
    
    func setClassTime(_ time: String) {
        timeLabel.text = time
        updateCenterLayout()
    }
    
    func setNetworkQuality(_ quality: NetworkQuality) {
        switch quality {
        case .good:
            signalImgView.image = AgoraKitImage("goodsignal")
        case .medium:
            signalImgView.image = AgoraKitImage("commonsignal")
        case .bad:
            signalImgView.image = AgoraKitImage("badsignal")
        default:
            signalImgView.image = AgoraKitImage("unknownsignal")
        }
    }
}

private extension AgoraUINavigationBar {
    func initView() {
        self.backgroundColor = UIColor.white
        self.addSubview(signalImgView)
        self.addSubview(roomNameLabel)
        self.addSubview(gridLineView)
        self.addSubview(timeLabel)
        self.addSubview(leaveButton)
        self.addSubview(lineView)
    }

    func initLayout() {
        signalImgView.agora_safe_x = 10
        signalImgView.agora_width = 20
        signalImgView.agora_height = 20
        signalImgView.agora_center_y = 0
        
        leaveButton.agora_safe_right = 10
        leaveButton.agora_width = 24
        leaveButton.agora_height = 24
        leaveButton.agora_center_y = 0
            
        lineView.agora_x = -50
        lineView.agora_height = 1
        lineView.agora_right = -50
        lineView.agora_bottom = 0
    }
    
    func getTextWidthForComment(text: String,
                                font: UIFont,
                                height: CGFloat = 15) -> CGFloat {
       let rect = text.agoraKitSize(font: font,
                                    width: CGFloat(MAXFLOAT),
                                    height: height)
       return rect.width
   }
}
