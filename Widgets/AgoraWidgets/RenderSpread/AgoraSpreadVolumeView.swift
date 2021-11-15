//
//  MemberVolumeView.swift
//  AgoraEduUI
//
//  Created by Jonathan on 2021/10/10.
//

import UIKit

class AgoraSpreadVolumeView: UIView {
    // 0...1
    public var volume: CGFloat = 0 {
        willSet {
            if newValue != volume {
                progressLayer.strokeEnd = CGFloat(volume)
            }
        }
    }
    
    private var views = [UIView]()
    
    var progressLayer: CAShapeLayer!
    
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
        contentView.mas_makeConstraints { make in
            make?.left.right().top().bottom().equalTo()(self)
        }
        
        for _ in 0..<7 {
            let view = UIView(frame: CGRect(x: 0,
                                            y: 0,
                                            width: 6,
                                            height: 1))
            view.backgroundColor = UIColor(rgb: 0x357BF6)
            contentView.addArrangedSubview(view)
        }
                        
        progressLayer = CAShapeLayer()
        progressLayer.lineCap = .square
        progressLayer.strokeColor = UIColor.white.cgColor
        progressLayer.strokeStart = 0
        progressLayer.strokeEnd = 0
        layer.mask = progressLayer
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

}
