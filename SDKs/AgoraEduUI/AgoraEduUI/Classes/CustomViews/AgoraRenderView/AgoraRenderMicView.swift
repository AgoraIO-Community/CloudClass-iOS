//
//  AgoraRenderMicView.swift
//  AgoraEduUI
//
//  Created by Jonathan on 2021/12/8.
//

import UIKit

class AgoraRenderMicView: UIView {
    
    enum AgoraRenderMicViewState {
        case on, off, forbidden
    }
    
    private var imageView: UIImageView!
    
    private var animaView: UIImageView!
    
    private var progressLayer: CAShapeLayer!
    
    private var micState: AgoraRenderMicViewState = .off
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        createViews()
        createConstrains()
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
        guard micState == .on else {
            return
        }
        let floatValue = CGFloat(value)
        self.progressLayer.strokeEnd = CGFloat(floatValue - 55.0) / (255.0 - 55.0)
    }
    
    public func setState(_ state: AgoraRenderMicViewState) {
        guard micState != state else {
            return
        }
        micState = state
        switch state {
        case .on:
            imageView.image = UIImage.agedu_named("ic_mic_status_on")
            animaView.isHidden = false
        case .off:
            imageView.image = UIImage.agedu_named("ic_mic_status_off")
            animaView.isHidden = true
        case .forbidden:
            imageView.image = UIImage.agedu_named("ic_mic_status_forbidden")
            animaView.isHidden = true
        }
    }
}

private extension AgoraRenderMicView {
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
    
    func createConstrains() {
        imageView.mas_makeConstraints { make in
            make?.left.right().top().bottom().equalTo()(0)
        }
        animaView.mas_makeConstraints { make in
            make?.left.right().top().bottom().equalTo()(0)
        }
    }
}
