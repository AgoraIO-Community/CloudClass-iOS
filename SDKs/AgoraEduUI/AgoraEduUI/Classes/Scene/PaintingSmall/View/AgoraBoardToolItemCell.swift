//
//  BrushToolItemCell.swift
//  AgoraEduUI
//
//  Created by Jonathan on 2021/9/29.
//

import Masonry
import UIKit

// MARK: - AgoraBoardToolItemCell
class AgoraBoardToolItemCell: UICollectionViewCell {
    private var imageView: UIImageView!
    
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
        colorView.mas_makeConstraints { make in
            make?.width.height().equalTo()(38)
            make?.center.equalTo()(self)
        }
        
        imageView = UIImageView(frame: .zero)
        addSubview(imageView)
        imageView.mas_makeConstraints { make in
            make?.center.equalTo()(self)
        }
    }
    
    public func setImage(_ image: UIImage?) {
        guard let v = image else {
            return
        }
        imageView.image = v.withRenderingMode(.alwaysTemplate)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

// MARK: - AgoraBoardTextSizeItemCell
class AgoraBoardTextSizeItemCell: UICollectionViewCell {
    public var level: Int = 0 {
        willSet {
            if level != newValue {
                let scale = CGFloat(truncating: pow(1.4, newValue) as NSNumber)
                sizeView.transform = CGAffineTransform(scaleX: scale, y: scale)
            }
        }
    }
    
    public var color: UIColor?
    /** 需要先设置颜色才能正常刷出来*/
    public var aSelected: Bool = false {
        willSet {
            if newValue == true {
                if let c = color {
                    sizeView.tintColor = c
                } else {
                    sizeView.tintColor = UIColor(rgb: 0xE1E1EA)
                }
            } else {
                sizeView.tintColor = UIColor(rgb: 0x7B88A0)
            }
        }
    }
    
    private var sizeView: UIImageView!
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        let image = AgoraUIImage(object: self,
                                 name: "ic_brush_text")?.withRenderingMode(.alwaysTemplate)
        sizeView = UIImageView(image: image)
        sizeView.contentMode = .scaleToFill
        sizeView.tintColor = UIColor(rgb: 0x7B88A0)
        addSubview(sizeView)
        sizeView.mas_makeConstraints { make in
            make?.center.equalTo()(sizeView.superview)
            make?.width.height().equalTo()(12)
        }
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}

// MARK: - BrushSizeItemCell
class AgoraBoardSizeItemCell: UICollectionViewCell {
    public var level: Int = 0 {
        willSet {
            if level != newValue {
                let scale = CGFloat(truncating: pow(1.4, newValue) as NSNumber)
                sizeView.transform = CGAffineTransform(scaleX: scale,
                                                       y: scale)
            }
        }
    }
    
    public var color: UIColor?
    /** 需要先设置颜色才能正常刷出来*/
    public var aSelected: Bool = false {
        willSet {
            if newValue == true {
                if let c = color {
                    sizeView.backgroundColor = c
                } else {
                    sizeView.backgroundColor = UIColor(rgb: 0xE1E1EA)
                }
            } else {
                sizeView.backgroundColor = UIColor(rgb: 0x7B88A0)
            }
        }
    }
    
    private var sizeView: UIView!
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        sizeView = UIView(frame: .zero)
        sizeView.backgroundColor = UIColor(rgb: 0xE1E1EA)
        sizeView.cornerRadius = 3
        addSubview(sizeView)
        sizeView.mas_makeConstraints { make in
            make?.center.equalTo()(sizeView.superview)
            make?.width.height().equalTo()(6)
        }
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

// MARK: - BrushColorItemCell
class AgoraBoardColorItemCell: UICollectionViewCell {
    var frontView: UIView!
    
    var backView: UIView!
    
    var color: UIColor? {
        didSet {
            if let c = color {
                frontView.backgroundColor = c
                frontView.layer.borderColor = UIColor.clear.cgColor
                backView.layer.borderColor = c.cgColor
            } else {
                frontView.backgroundColor = .white
                frontView.layer.borderColor = UIColor(rgb: 0xE1E1EA).cgColor
                backView.layer.borderColor = UIColor(rgb: 0xE1E1EA).cgColor
            }
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
        backView.layer.cornerRadius = 4
        backView.backgroundColor = .white
        addSubview(backView)
        backView.mas_makeConstraints { make in
            make?.center.equalTo()(backView.superview)
            make?.width.height().equalTo()(24)
        }
        
        frontView = UIView(frame: .zero)
        frontView.layer.borderWidth = 1
        frontView.layer.cornerRadius = 4
        frontView.clipsToBounds = true
        addSubview(frontView)
        frontView.mas_makeConstraints { make in
            make?.center.equalTo()(frontView.superview)
            make?.width.height().equalTo()(20)
        }
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
