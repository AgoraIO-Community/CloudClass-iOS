//
//  AgoraToolBarCells.swift
//  AgoraEduUI
//
//  Created by LYY on 2022/2/10.
//

import AgoraUIBaseViews
import UIKit

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
        self.imageView.tintColor = itemHighlightColor
        self.contentView.backgroundColor = itemBackgroundHighlightColor
        self.transform = CGAffineTransform(scaleX: 1.2,
                                           y: 1.2)
        self.imageView.transform = CGAffineTransform(scaleX: 0.8,
                                                     y: 0.8)
    }
    
    override func normalState() {
        self.imageView.tintColor = self.aSelected ? itemSelectedColor : itemUnselectedColor
        self.contentView.backgroundColor = self.aSelected ? itemBackgroundSelectedColor : itemBackgroundUnselectedColor
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
    
    var itemSelectedColor: UIColor
    var itemUnselectedColor: UIColor
    var itemBackgroundSelectedColor: UIColor
    var itemBackgroundUnselectedColor: UIColor
    var itemHighlightColor: UIColor
    var itemBackgroundHighlightColor: UIColor
    
    var aSelected = false {
        willSet {
            if aSelected != newValue {
                contentView.backgroundColor = newValue ? itemBackgroundSelectedColor : itemBackgroundUnselectedColor
                imageView.tintColor = newValue ? itemSelectedColor : itemUnselectedColor
            }
        }
    }
            
    override init(frame: CGRect) {
        let group = AgoraColorGroup()
        itemSelectedColor = group.tool_bar_item_selected_color
        itemUnselectedColor = group.tool_bar_item_unselected_color
        itemBackgroundSelectedColor = group.tool_bar_item_background_selected_color
        itemBackgroundUnselectedColor = group.tool_bar_item_background_unselected_color
        itemHighlightColor = group.tool_bar_item_highlight_color
        itemBackgroundHighlightColor = group.tool_bar_item_background_highlight_color
        
        super.init(frame: frame)
        
        contentView.backgroundColor = itemBackgroundUnselectedColor
        contentView.layer.cornerRadius = 8
        AgoraUIGroup().color.borderSet(layer: contentView.layer)
        
        imageView = UIImageView(frame: .zero)
        imageView.tintColor = itemUnselectedColor
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
        self.imageView.tintColor = itemHighlightColor
        self.contentView.backgroundColor = itemBackgroundHighlightColor
        self.transform = CGAffineTransform(scaleX: 1.2,
                                           y: 1.2)
        self.imageView.transform = CGAffineTransform(scaleX: 0.8,
                                                     y: 0.8)
    }
    
    func normalState() {
        contentView.backgroundColor = self.aSelected ? itemBackgroundSelectedColor : itemBackgroundUnselectedColor
        imageView.tintColor = self.aSelected ? itemSelectedColor: itemUnselectedColor
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
        self.transform = CGAffineTransform(scaleX: 1.2,
                                           y: 1.2)
        self.imageView.transform = CGAffineTransform(scaleX: 0.8,
                                                     y: 0.8)
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
    
    public var duration = 3 {
        didSet {
            self.handsupDelayView.duration = duration
        }
    }
            
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

// MARK: - AgoraToolBarHelpCell
class AgoraToolBarHelpCell: AgoraToolBarItemCell {
    var touchable: Bool = true {
        didSet {
            if touchable {
                normalState()
            } else {
                unTouchableState()
            }
        }
    }
    
    private func unTouchableState() {
        contentView.backgroundColor = .white
        imageView.tintColor = UIColor(hex: 0xECECF1)
        UIView.animate(withDuration: 0.1,
                       delay: 0,
                       options: .curveLinear) {
            self.transform = .identity
            self.imageView.transform = .identity
        } completion: { finish in
        }
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
            make?.center.equalTo()(0)
            make?.width.height().equalTo()(UIDevice.current.isPad ? 32 : 30)
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
        let finalColor = UIColor.fakeWhite(color)
        if isMain {
            guard let i = image else {
                return
            }
            imageView.image = i.withRenderingMode(.alwaysTemplate)
            imageView.tintColor = finalColor
        } else {
            imageView.image = image
            
            fontLabel.isHidden = true
            imageView.isHidden = false
            colorView.isHidden = false
            colorView.backgroundColor = finalColor
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
