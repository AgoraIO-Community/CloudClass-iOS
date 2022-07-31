//
//  AgoraRenderMemberMicView.swift
//  AgoraEduUI
//
//  Created by DoubleCircle on 2022/4/24.
//

import UIKit

class AgoraRenderMemberMicView: UIView {
    var imageView: UIImageView!
    
    var animaView: UIImageView!
    
    private var progressLayer: CAShapeLayer!
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        createViews()
        createConstraint()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        progressLayer.frame = bounds
        let path = UIBezierPath.init()
        path.move(to: CGPoint(x: bounds.midX, y: bounds.maxY))
        path.addLine(to: CGPoint(x: bounds.midX, y: bounds.minY))
        progressLayer.lineWidth = bounds.width
        progressLayer.path = path.cgPath
    }
        
    public func setVolume(_ value: Int) {
        let floatValue = CGFloat(value)
        self.progressLayer.strokeEnd = CGFloat(floatValue - 55.0) / (255.0 - 55.0)
        animaView.isHidden = false
    }
}

private extension AgoraRenderMemberMicView {
    func createViews() {
        imageView = UIImageView()
        imageView.image = UIImage.agedu_named("ic_mic_status_off")
        addSubview(imageView)
        
        animaView = UIImageView()
        animaView.image = UIImage.agedu_named("ic_mic_status_volume")
        animaView.isHidden  = true
        addSubview(animaView)
        
        progressLayer = CAShapeLayer()
        progressLayer.lineCap = .square
        progressLayer.strokeColor = UIColor.white.cgColor
        progressLayer.strokeStart = 0
        progressLayer.strokeEnd = 0
        animaView.layer.mask = progressLayer
    }
    
    func createConstraint() {
        imageView.mas_makeConstraints { make in
            make?.left.right().top().bottom().equalTo()(0)
        }
        animaView.mas_makeConstraints { make in
            make?.left.right().top().bottom().equalTo()(0)
        }
    }
}

