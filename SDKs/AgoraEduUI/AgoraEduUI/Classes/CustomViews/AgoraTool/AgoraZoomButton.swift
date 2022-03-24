//
//  AgoraZoomButton.swift
//  AgoraEduUI
//
//  Created by Jonathan on 2021/12/31.
//

import UIKit

public class AgoraZoomButton: UIButton {
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        backgroundColor = UIColor.white
        imageView?.tintColor = UIColor(hex: 0x7B88A0)
        
        layer.cornerRadius = 8
        AgoraUIGroup().color.borderSet(layer: layer)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    public override func layoutSubviews() {
        super.layoutSubviews()
        
        layer.cornerRadius = bounds.height * 0.5
    }
    
    public override var isSelected: Bool {
        willSet {
            if isSelected != newValue {
                backgroundColor = newValue ? UIColor(hex: 0x357BF6) : .white
                imageView?.tintColor = newValue ? .white : UIColor(hex: 0x7B88A0)
            }
        }
    }
    
    func setImage(_ image: UIImage?) {
        guard let v = image else {
            return
        }
        setImageForAllStates(v.withRenderingMode(.alwaysTemplate))
    }
    
    public override func touchesBegan(_ touches: Set<UITouch>,
                               with event: UIEvent?) {
        super.touchesBegan(touches, with: event)
        self.transform = CGAffineTransform(scaleX: 1.1, y: 1.1)
        self.imageView?.transform = CGAffineTransform(scaleX: 0.8, y: 0.8)
    }
    
    public override func touchesEnded(_ touches: Set<UITouch>,
                               with event: UIEvent?) {
        super.touchesEnded(touches, with: event)
        UIView.animate(withDuration: 0.1,
                       delay: 0,
                       options: .curveLinear) {
            self.transform = CGAffineTransform(scaleX: 1, y: 1)
            self.imageView?.transform = CGAffineTransform(scaleX: 1, y: 1)
        } completion: { finish in
        }
    }
}
