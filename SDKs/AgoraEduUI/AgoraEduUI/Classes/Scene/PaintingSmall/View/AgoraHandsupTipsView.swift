//
//  HandsupTipsView.swift
//  AgoraEduUI
//
//  Created by HeZhengQing on 2021/10/26.
//

import AgoraUIBaseViews
import UIKit

class AgoraHandsupTipsView: UIView {
    var imageView: UIImageView!
    
    var label: UILabel!
        
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        createViews()
        createConstraint()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

private extension AgoraHandsupTipsView {
    func createViews() {
        layer.shadowColor = UIColor(hex: 0x2F4192,
                                    transparency: 0.15)?.cgColor
        layer.shadowOffset = CGSize(width: 0, height: 2)
        layer.shadowOpacity = 1
        layer.shadowRadius = 6

        let tipImage = UIImage.agedu_named("ic_handsup_remind_tip")
        let newImage = tipImage?.resizableImage(withCapInsets: UIEdgeInsets(top: 10, left: 10, bottom: 25, right: 10), resizingMode: .stretch)
        imageView = UIImageView(image: newImage)
        addSubview(imageView)
        
        label = UILabel()
        label.font = UIFont.systemFont(ofSize: 12)
        label.textColor = UIColor(hex: 0x191919)
        label.text = "long_press_to_wave_hands".agedu_localized()
        label.textAlignment = .center
        addSubview(label)
    }
    
    func createConstraint() {
        label.mas_makeConstraints { make in
            make?.left.equalTo()(12)
            make?.right.equalTo()(-10)
            make?.height.equalTo()(24)
            make?.top.equalTo()(20)
            make?.bottom.equalTo()(-20)
        }
        imageView.mas_makeConstraints { make in
            make?.left.equalTo()(label)?.offset()(-5)
            make?.right.equalTo()(label)?.offset()(15)
            make?.top.equalTo()(label)?.offset()(-2)
            make?.bottom.equalTo()(label)?.offset()(2)
        }
    }
}
