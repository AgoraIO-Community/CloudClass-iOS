//
//  FcrInviligatorTest.swift
//  AgoraInvigilatorUI
//
//  Created by DoubleCircle on 2022/9/4.
//

import AgoraUIBaseViews

class FcrInviligatorAvatarView: UIView {
    private(set) lazy var nameLabel = UILabel()
    private(set) lazy var avatarImageView = UIImageView()
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        layer.cornerRadius = frame.width / 2
        layer.masksToBounds = true
        
        avatarImageView.layer.cornerRadius = avatarImageView.frame.width / 2
        avatarImageView.layer.masksToBounds = true
    }
}

// MARK: - AgoraUIContentContainer
extension FcrInviligatorAvatarView: AgoraUIContentContainer {
    func initViews() {
        addSubviews([nameLabel,
                     avatarImageView])
    }
    
    func initViewFrame() {
        nameLabel.mas_makeConstraints { make in
            make?.center.equalTo()(self)
        }
        
        avatarImageView.mas_makeConstraints { make in
            make?.left.right().top().bottom().equalTo()(self)
        }
    }
    
    func updateViewProperties() {
        let config = UIConfig.deviceTest.avatar
        
        backgroundColor = config.backgroundColor
        nameLabel.textColor = config.titleColor
        nameLabel.font = config.titleFont
    }
}

// TODO: need?
// MARK: - private
private extension FcrInviligatorAvatarView {
    func drawCircular() {
        let centerX = bounds.size.width / 2
        let boundingRect = CGRect(x:centerX - 100,
                                  y:50,
                                  width:200,
                                  height:200)
        var orbitPath: CGPath!
        //通过CGPath的ellipseIn方法，创建一个圆形的CGPath
        orbitPath = CGPath(ellipseIn: boundingRect, transform: nil)
        //绘制路线的图层
        drawPath(path: orbitPath)
     }
        
    ///绘制路线的图层
    func drawPath(path: CGPath) {
        let pathLayer = CAShapeLayer()
        pathLayer.frame = bounds
        
        pathLayer.path = path
        pathLayer.fillColor = nil
        pathLayer.lineWidth = 3
        pathLayer.strokeColor = UIColor.white.cgColor
            
        layer.addSublayer(pathLayer)
    }
}
