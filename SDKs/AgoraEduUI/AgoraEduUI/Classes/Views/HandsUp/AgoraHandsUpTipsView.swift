//
//  HandsupTipsView.swift
//  AgoraEduUI
//
//  Created by HeZhengQing on 2021/10/26.
//

import AgoraUIBaseViews
import UIKit

class AgoraHandsUpTipsView: UIView {
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

private extension AgoraHandsUpTipsView {
    func createViews() {
        AgoraUIGroup().color.borderSet(layer: layer)

        let tipImage = UIImage.agedu_named("ic_handsup_remind_tip")
        let newImage = tipImage?.resizableImage(withCapInsets: UIEdgeInsets(top: 10, left: 10, bottom: 25, right: 10), resizingMode: .stretch)
        imageView = UIImageView(image: newImage)
        addSubview(imageView)
        
        label = UILabel()
        label.font = UIFont.systemFont(ofSize: 12)
        label.textColor = UIColor(hex: 0x191919)
        label.text = "fcr_user_hands".agedu_localized()
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
