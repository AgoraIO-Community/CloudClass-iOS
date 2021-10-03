//
//  BrushToolItemCell.swift
//  AgoraEduUI
//
//  Created by Jonathan on 2021/9/29.
//

import SnapKit
import UIKit

// MARK: - BrushToolItemCell
class BrushToolItemCell: UICollectionViewCell {
    var imageView: UIImageView!
    
    private var colorView: UIView!
    
    var aSelected: Bool = false {
        willSet {
            if newValue {
                imageView.tintColor = .white
                colorView.backgroundColor = UIColor(rgb: 0x0073FF)
            } else {
                imageView.tintColor = UIColor(rgb: 0x7B88A0)
                colorView.backgroundColor = .white
            }
        }
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        colorView = UIView(frame: .zero)
        colorView.layer.cornerRadius = 5
        colorView.clipsToBounds = true
        addSubview(colorView)
        colorView.snp.makeConstraints { make in
            make.width.height.equalTo(38)
            make.center.equalTo(self)
        }
        
        imageView = UIImageView(frame: .zero)
        addSubview(imageView)
        imageView.snp.makeConstraints { make in
            make.center.equalTo(self)
        }
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

// MARK: - BrushTextSizeItemCell
class BrushTextSizeItemCell: UICollectionViewCell {
    
    public var level: Int = 0 {
        willSet {
            if level != newValue {
                
            }
        }
    }
    
    private var sizeView: UIImageView!
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        layer.cornerRadius = 5
        clipsToBounds = true
        
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

// MARK: - BrushSizeItemCell
class BrushSizeItemCell: UICollectionViewCell {
    
    public var level: Int = 0 {
        willSet {
            if level != newValue {
                
            }
        }
    }
    
    private var sizeView: UIView!
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        sizeView = UIView(frame: .zero)
        sizeView.backgroundColor = .gray
        sizeView.frame = CGRect(x: 0, y: 0, width: 20, height: 20)
        sizeView.cornerRadius = 10
        addSubview(sizeView)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        sizeView.center = self.center
    }
}

// MARK: - BrushColorItemCell
class BrushColorItemCell: UICollectionViewCell {
    var frontView: UIView!
    
    var backView: UIView!
    
    var color: UIColor = .clear {
        didSet {
            frontView.backgroundColor = color
            backView.layer.borderColor = color.cgColor
        }
    }
    
    var aSelected: Bool = false {
        willSet {
            backView.isHidden = !newValue
        }
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        backView = UIView(frame: .zero)
        backView.layer.borderWidth = 1
        backView.layer.borderColor = UIColor.white.cgColor
        backView.layer.cornerRadius = 4
        backView.backgroundColor = .white
        addSubview(backView)
        backView.snp.makeConstraints { make in
            make.center.equalToSuperview()
            make.width.height.equalTo(28)
        }
        
        frontView = UIView(frame: .zero)
        frontView.layer.cornerRadius = 2
        frontView.clipsToBounds = true
        addSubview(frontView)
        frontView.snp.makeConstraints { make in
            make.center.equalToSuperview()
            make.width.height.equalTo(22)
        }
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
