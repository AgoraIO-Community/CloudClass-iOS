//
//  AgoraToolBarCells.swift
//  AgoraEduUI
//
//  Created by LYY on 2022/2/10.
//

import AgoraUIBaseViews

// MARK: - AgoraToolBarRedDotCell
class AgoraToolBarRedDotCell: AgoraToolBarItemCell {
    
    var redDot = UIView()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        redDot.isHidden = true
        redDot.isUserInteractionEnabled = false
        redDot.backgroundColor = UIColor(hex: 0xF04C36)
        redDot.layer.cornerRadius = 2
        redDot.clipsToBounds = true
        self.addSubview(redDot)
        redDot.mas_makeConstraints { make in
            make?.width.height().equalTo()(4)
            make?.top.equalTo()(5)
            make?.right.equalTo()(-5)
        }
        
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func highLight() {
        self.imageView.tintColor = .white
        self.contentView.backgroundColor = baseTintColor
        self.transform = CGAffineTransform(scaleX: 1.2, y: 1.2)
        self.imageView.transform = CGAffineTransform(scaleX: 0.8, y: 0.8)
    }
    
    override func normalState() {
        self.imageView.tintColor = self.aSelected ? .white : nil
        self.contentView.backgroundColor = self.aSelected ? baseTintColor : .white
        UIView.animate(withDuration: 0.1,
                       delay: 0,
                       options: .curveLinear) {
            self.transform = .identity
            self.imageView.transform = .identity
        } completion: { finish in
        }
    }
}
// MARK: - AgoraToolBarItemCell
class AgoraToolBarItemCell: UICollectionViewCell {
        
    var imageView: UIImageView!
    
    var baseTintColor = UIColor(hex: 0x7B88A0)
    
    var aSelected = false {
        willSet {
            if aSelected != newValue {
                contentView.backgroundColor = newValue ? baseTintColor : .white
                imageView.tintColor = newValue ? .white : UIColor(hex: 0x7B88A0)
            }
        }
    }
            
    override init(frame: CGRect) {
        super.init(frame: frame)
        contentView.backgroundColor = UIColor.white
        
        contentView.layer.cornerRadius = 8
        contentView.layer.shadowColor = UIColor(hex: 0x2F4192,
                                                transparency: 0.15)?.cgColor
        contentView.layer.shadowOffset = CGSize(width: 0, height: 2)
        contentView.layer.shadowOpacity = 1
        contentView.layer.shadowRadius = 6
        
        imageView = UIImageView(frame: .zero)
        imageView.tintColor = UIColor(hex: 0x7B88A0)
        contentView.addSubview(imageView)
        
        imageView.mas_remakeConstraints { make in
            make?.center.equalTo()(0)
            make?.width.height().equalTo()(22)
        }
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        contentView.layer.cornerRadius = bounds.height * 0.5
    }
    
    func setImage(_ image: UIImage?) {
        guard let i = image else {
            return
        }
        imageView.image = i.withRenderingMode(.alwaysTemplate)
    }
    
    func highLight() {
        self.imageView.tintColor = .white
        self.contentView.backgroundColor = baseTintColor
        self.transform = CGAffineTransform(scaleX: 1.2, y: 1.2)
        self.imageView.transform = CGAffineTransform(scaleX: 0.8, y: 0.8)
    }
    
    func normalState() {
        contentView.backgroundColor = self.aSelected ? baseTintColor : .white
        imageView.tintColor = self.aSelected ? .white : baseTintColor
        UIView.animate(withDuration: 0.1,
                       delay: 0,
                       options: .curveLinear) {
            self.transform = .identity
            self.imageView.transform = .identity
        } completion: { finish in
        }
    }
}

// MARK: - AgoraToolBarBrushCell
class AgoraToolBarBrushCell: AgoraToolBarItemCell {
    
    override func highLight() {
        self.transform = CGAffineTransform(scaleX: 1.2, y: 1.2)
        self.imageView.transform = CGAffineTransform(scaleX: 0.8, y: 0.8)
    }
    
    override func normalState() {
        UIView.animate(withDuration: 0.1,
                       delay: 0,
                       options: .curveLinear) {
            self.transform = .identity
            self.imageView.transform = .identity
        } completion: { finish in
        }
    }
}

// MARK: - AgoraToolBarHandsUpCell
class AgoraToolBarHandsUpCell: UICollectionViewCell {
    
    var handsupDelayView: AgoraHandsUpDelayView!
            
    override init(frame: CGRect) {
        super.init(frame: frame)
        contentView.backgroundColor = UIColor.clear
        
        handsupDelayView = AgoraHandsUpDelayView(frame: .zero)
        contentView.addSubview(handsupDelayView)
        handsupDelayView.mas_makeConstraints { make in
            make?.left.right().top().bottom().equalTo()(0)
        }
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

// MARK: - AgoraToolBarHandsListCell
class AgoraToolBarHandsListCell: AgoraToolBarItemCell {
    
    let redLabel = UILabel()

    override init(frame: CGRect) {
        super.init(frame: frame)
        redLabel.textColor = .white
        redLabel.font = UIFont.systemFont(ofSize: 10)
        redLabel.textAlignment = .center

        redLabel.isHidden = true
        redLabel.isUserInteractionEnabled = false
        redLabel.backgroundColor = UIColor(hex: 0xF04C36)
        redLabel.layer.cornerRadius = 2
        redLabel.clipsToBounds = true
        self.addSubview(redLabel)
        redLabel.mas_makeConstraints { make in
            make?.width.height().equalTo()(4)
            make?.top.equalTo()(5)
            make?.right.equalTo()(-5)
        }
        
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}


class AgoraToolCollectionCell: UIView {
    private var isMain: Bool
    private var imageView: UIImageView!
    private lazy var colorView: UIView = UIView(frame: .zero)
    
    private lazy var fontLabel: UILabel = {
        let fontLabel = UILabel(text: "")
        fontLabel.font = .systemFont(ofSize: 12)
        fontLabel.textAlignment = .center
        fontLabel.textColor = UIColor(hex: 0x677386)
        return fontLabel
    }()
    
    var curColor: UIColor = .white
    
    init(isMain: Bool,
         color: UIColor? = nil,
         image: UIImage? = nil,
         font: Int? = nil) {
        self.isMain = isMain
        
        super.init(frame: .zero)
        
        backgroundColor = .clear
        
        imageView = UIImageView(frame: .zero)
        imageView.contentMode = .scaleAspectFill
        imageView.image = image
        imageView.tintColor = color
        addSubview(imageView)
        
        imageView.mas_remakeConstraints { make in
            make?.left.right().top().bottom().equalTo()(0)
        }
        
        if !isMain {
            addSubview(colorView)
            addSubview(fontLabel)
            
            fontLabel.text = "\(font)"
            colorView.backgroundColor = color
            
            colorView.mas_remakeConstraints { make in
                make?.width.height().equalTo()(AgoraFit.scale(3))
                make?.bottom.equalTo()(AgoraFit.scale(-5))
                make?.right.equalTo()(AgoraFit.scale(-5))
            }
            
            fontLabel.mas_remakeConstraints { make in
                make?.left.right().top().bottom().equalTo()(0)
            }
        }
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // 对于子配置cell，若设置图片，则隐藏font视图，显示image和color视图
    func setImage(_ image: UIImage?,
                  color: UIColor?) {
        if isMain {
            guard let i = image else {
                return
            }
            imageView.image = i.withRenderingMode(.alwaysTemplate)
            imageView.tintColor = color
        } else {
            imageView.image = image
            
            fontLabel.isHidden = true
            imageView.isHidden = false
            colorView.isHidden = false
            colorView.backgroundColor = color
        }
    }
    
    // 仅子配置cell可调用，若设置font，则隐藏image和color视图
    func setFont(_ font: Int) {
        guard !isMain else {
            return
        }
        fontLabel.isHidden = false
        imageView.isHidden = true
        colorView.isHidden = true

        fontLabel.text = "\(font)"
    }
}
