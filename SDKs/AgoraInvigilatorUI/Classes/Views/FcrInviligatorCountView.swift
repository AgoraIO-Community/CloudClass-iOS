//
//  FcrInviligatorCountView.swift
//  AgoraInvigilatorUI
//
//  Created by DoubleCircle on 2022/9/4.
//

import AgoraUIBaseViews
import Masonry

class FcrInviligatorCountView: UIView {
    private(set) lazy var countDot = UIImageView()
    private(set) lazy var countLabel = UILabel()
}

// MARK: - AgoraUIContentContainer
extension FcrInviligatorCountView: AgoraUIContentContainer {
    func initViews() {
        countDot.image = UIImage.fcr_named("countDot")
        addSubview(countDot)
        addSubview(countLabel)
    }
    
    func initViewFrame() {
        countDot.mas_makeConstraints { make in
            make?.left.top().bottom().equalTo()(0)
            make?.width.equalTo()(12)
        }
        
        countLabel.mas_makeConstraints { make in
            make?.top.bottom().equalTo()(0)
            // TODO: offset
            make?.left.equalTo()(countDot)?.offset()(10)
        }
    }
    
    func updateViewProperties() {
        
    }
}
