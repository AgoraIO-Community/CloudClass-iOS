//
//  AgoraCycleView.swift
//  AgoraEduSDK
//
//  Created by SRS on 2021/2/14.
//

import UIKit
import AgoraUIBaseViews

class AgoraCycleView: AgoraBaseUIView {
        
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.backgroundColor = UIColor.clear
    }
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    open func progressTintColor(_ from: UIColor, to: UIColor) {
        self.layoutIfNeeded()
        
        let layerWidth = self.bounds.size.width
        let layerHeight = self.bounds.size.height
        
        var redf: CGFloat = 0.0, greenf: CGFloat = 0.0, bluef: CGFloat = 0.0, alphaf: CGFloat = 0.0
        from.getRed(&redf, green: &greenf, blue: &bluef, alpha: &alphaf)
        var redt: CGFloat = 0.0, greent: CGFloat = 0.0, bluet: CGFloat = 0.0, alphat: CGFloat = 0.0
        to.getRed(&redt, green: &greent, blue: &bluet, alpha: &alphat)
        let red = redf + (redt - redf) * 0.15
        let green = greenf + (greent - greenf) * 0.15
        let blue = bluef + (bluet - bluef) * 0.15
        let alpha = alphaf + (alphat - alphaf) * 0.15
        let midden = UIColor(red: red, green: green, blue: blue, alpha: alpha)
        
        let layer1 = CAGradientLayer()
        layer1.frame = CGRect(x: 0, y: 0, width: layerWidth * 0.5, height: layerHeight)
        layer1.colors = [to.cgColor, midden.cgColor]
        layer1.startPoint = CGPoint(x: 0, y: 0)
        layer1.endPoint = CGPoint(x: 0, y: 1)
        self.layer.addSublayer(layer1)
        
        let layer2 = CAGradientLayer()
        layer2.frame = CGRect(x: layerWidth * 0.5, y: 0, width: layerWidth * 0.5, height: layerHeight)
        layer2.colors = [from.cgColor, midden.cgColor]
        layer2.startPoint = CGPoint(x: 0, y: 0)
        layer2.endPoint = CGPoint(x: 0, y: 1)
        self.layer.addSublayer(layer2)
        
        let bezierPath = UIBezierPath()
        let center = CGPoint(x: layerWidth * 0.5, y: layerHeight * 0.5)
        bezierPath.addArc(withCenter: center, radius: layerWidth*0.5 - 4, startAngle: 1.5*(.pi), endAngle: -.pi*0.5, clockwise: false)
                
        let shapeLayer = CAShapeLayer()
        shapeLayer.path = bezierPath.cgPath
        shapeLayer.frame = self.bounds
        shapeLayer.fillColor = UIColor.clear.cgColor
        shapeLayer.strokeColor = from.cgColor
        shapeLayer.lineWidth = 4.0
        self.layer.mask = shapeLayer
    }
    
    func startAnimation() {
        let rotation = CABasicAnimation()
        rotation.keyPath = "transform.rotation"
        rotation.toValue = 2.0*(.pi)
        rotation.duration = 1.0
        rotation.repeatCount = .infinity;
        self.layer.add(rotation, forKey: "rotation")
    }
    
    func stopAnimation() {
        self.layer.removeAnimation(forKey: "rotation")
    }
    
    override var isHidden: Bool {
        didSet {
            self.stopAnimation()
        }
    }
    
    deinit {
        self.stopAnimation()
    }
}
