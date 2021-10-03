//
//  RoomInfoOptionCell.swift
//  AgoraEducation
//
//  Created by HeZhengQing on 2021/9/10.
//  Copyright © 2021 Agora. All rights reserved.
//

import AgoraUIEduBaseViews
import AgoraUIBaseViews
import SnapKit

fileprivate class MemberVolumeView: UIView {
    // 0...1
    var volume: CGFloat = 0 {
        willSet {
            if newValue != volume {
                let value = newValue > 1 ? 1 : newValue
                let count = Int(value * 7)
                for index in 0..<views.count {
                    let view = views[index]
                    if index > count - 1 {
                        view.backgroundColor = UIColor(rgb: 0x357BF6)
                    } else {
                        view.backgroundColor = .clear
                    }
                }
            }
        }
    }
    
    private var views = [UIView]()
    
    private var contentView: UIStackView!
    
    public override init(frame: CGRect) {
        super.init(frame: frame)
        
        contentView = UIStackView(frame: .zero)
        contentView.backgroundColor = .clear
        contentView.axis = .vertical
        contentView.spacing = 3
        contentView.distribution = .fillEqually
        contentView.alignment = .fill
        addSubview(contentView)
        contentView.snp.makeConstraints { make in
            make.left.right.top.bottom.equalToSuperview()
        }
        
        var views = [UIView]()
        for _ in 0..<7 {
            let view = UIView(frame: CGRect(x: 0,
                                            y: 0,
                                            width: 6,
                                            height: 1))
            view.backgroundColor = UIColor(rgb: 0x357BF6)
            contentView.addArrangedSubview(view)
            views.append(view)
        }
        
        self.views = views.reversed()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
// MARK: - AgoraMemberItemCell
public class AgoraMemberItemCell: AgoraBaseUICollectionCell {
    /** 相机状态*/
    var cameraStateView: AgoraBaseUIImageView!
    /** 麦克风状态*/
    var micView: AgoraBaseUIImageView!
    /** 声音大小*/
    var volumeView: UIView!
    /** 名字*/
    var nameLabel: AgoraBaseUILabel!
    /** 举手*/
    var handsupView: AgoraBaseUIImageView!
    
    var indexPath: IndexPath = IndexPath(row: 0, section: 0)
    
    public override init(frame: CGRect) {
        super.init(frame: frame)
        createViews()
        createConstrains()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
// MARK: - Creations
private extension AgoraMemberItemCell {
    func createViews() {
        backgroundColor = UIColor.clear
        clipsToBounds = true
        layer.borderWidth = AgoraKitDeviceAssistant.OS.isPad ? 2 : 1
        layer.borderColor = UIColor(rgb: 0xECECF1).cgColor
        layer.cornerRadius = AgoraKitDeviceAssistant.OS.isPad ? 10 : 4
        
        cameraStateView = AgoraBaseUIImageView(image: AgoraKitImage("default_offline"))
        addSubview(cameraStateView)
        
        micView = AgoraBaseUIImageView.init(image: AgoraUIImage(object: self, name: "ic_mic_status_on"))
        addSubview(micView)
        
        volumeView = MemberVolumeView(frame: .zero)
        addSubview(volumeView)
        
        nameLabel = AgoraBaseUILabel()
        nameLabel.text = "student AAAAAAAA"
        nameLabel.textColor = UIColor.white
        nameLabel.font = UIFont.systemFont(ofSize: 12)
        nameLabel.layer.shadowColor = UIColor(rgb: 0x0D1D3D, alpha: 0.8).cgColor
        nameLabel.layer.shadowOffset = CGSize(width: 0, height: 1)
        nameLabel.layer.shadowOpacity = 1
        nameLabel.layer.shadowRadius = 2
        addSubview(nameLabel)
        
        handsupView = AgoraBaseUIImageView(image: AgoraKitImage("ic_member_handsup"))
        addSubview(handsupView)
    }
    
    func createConstrains() {
        cameraStateView.snp.makeConstraints { make in
            if AgoraKitDeviceAssistant.OS.isPad {
                make.size.equalTo(CGSize(width: 70, height: 70))
            } else {
                make.size.equalTo(CGSize(width: 45, height: 45))
            }
            make.center.equalTo(self)
        }
        micView.snp.makeConstraints { make in
            make.left.equalTo(2)
            make.bottom.equalTo(-2)
            make.width.height.equalTo(14)
        }
        volumeView.snp.makeConstraints { make in
            make.width.equalTo(8.4)
            make.height.equalTo(32)
            make.centerX.equalTo(micView)
            make.bottom.equalTo(micView.snp.top).offset(-4)
        }
        nameLabel.snp.makeConstraints { make in
            make.centerY.equalTo(micView)
            make.left.equalTo(micView.snp.right).offset(2)
            make.right.lessThanOrEqualTo(self)
        }
        handsupView.snp.makeConstraints { make in
            make.right.equalTo(-2)
            make.bottom.equalTo(-2)
            make.width.height.equalTo(24)
        }
    }
}
