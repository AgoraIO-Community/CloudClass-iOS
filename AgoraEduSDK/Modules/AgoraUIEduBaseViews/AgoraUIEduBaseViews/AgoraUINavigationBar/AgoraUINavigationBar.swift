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
        label.font = UIFont.systemFont(ofSize: 9)
        label.textColor = UIColor(rgb: 0x191919)
        label.textAlignment = .right
        return label
    }()
    
    private lazy var gridLineView: AgoraBaseUIView = {
        let view = AgoraBaseUIView()
        view.backgroundColor = UIColor(rgb: 0x677386)
        return view
    }()
    
    public private(set) lazy var timeLabel: AgoraBaseUILabel = {
        let label = AgoraBaseUILabel()
        label.font = UIFont.systemFont(ofSize: 9)
        return label
    }()
//
//    public private(set) lazy var logButton: AgoraBaseUIButton = {
//        let button = AgoraBaseUIButton()
//        button.setImage(AgoraKitImage("log"),
//                     for: .normal)
//        return button
//    }()
    
    private lazy var lineView: AgoraBaseUIView = {
        let lineV = AgoraBaseUIView()
        lineV.backgroundColor = UIColor(rgb: 0xECECF1)
        return lineV
    }()
    
//    private let SwitchTag = 100

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
                                                      font: timeLabel.font)
        
        let space: CGFloat = 8
                
        timeLabel.agora_y = 0
        timeLabel.agora_bottom = 0
        timeLabel.agora_right = 10
        timeLabel.agora_width = roomTimeLen
        
        gridLineView.agora_right = timeLabel.agora_right + timeLabel.agora_width + space
        gridLineView.agora_width = 1
        gridLineView.agora_height = 6
        gridLineView.agora_center_y = 0

        roomNameLabel.agora_y = 0
        roomNameLabel.agora_bottom = 0
        roomNameLabel.agora_right = gridLineView.agora_right + space
        roomNameLabel.agora_width = roomNameLen
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
        backgroundColor = UIColor.white
        addSubview(signalImgView)
        addSubview(roomNameLabel)
        addSubview(gridLineView)
        addSubview(timeLabel)
//        addSubview(setButton)
        addSubview(lineView)
//        addSubview(logButton)
    }

    func initLayout() {
        signalImgView.agora_x = 10
        signalImgView.agora_width = 14
        signalImgView.agora_height = 14
        signalImgView.agora_center_y = 0
        
//        setButton.agora_safe_right = 10
//        setButton.agora_width = 24
//        setButton.agora_height = 24
//        setButton.agora_center_y = 0
//
//        logButton.agora_safe_right = 56
//        logButton.agora_width = 24
//        logButton.agora_height = 24
//        logButton.agora_center_y = 0
//
        lineView.agora_x = 0
        lineView.agora_height = 1
        lineView.agora_right = 0
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
