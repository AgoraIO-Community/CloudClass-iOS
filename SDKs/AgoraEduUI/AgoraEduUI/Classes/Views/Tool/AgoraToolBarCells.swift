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
        
        redDot.layer.cornerRadius = 2
        redDot.clipsToBounds = true
        self.addSubview(redDot)
        
        redDot.mas_makeConstraints { make in
            make?.width.height().equalTo()(4)
            make?.top.equalTo()(5)
            make?.right.equalTo()(-5)
        }
    }
    
    override func updateViewProperties() {
        super.updateViewProperties()
        
        redDot.backgroundColor = FcrUIColorGroup.fcr_system_error_color
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
// MARK: - AgoraToolBarItemCell
class AgoraToolBarItemCell: UICollectionViewCell, AgoraUIContentContainer {
    private lazy var bgView = UIImageView(frame: .zero)
    lazy var iconView = UIImageView(frame: .zero)

    var aSelected = false {
        didSet {
            let selectedName = aSelected ? "selected" : "unselected"
            let imageName = "toolbar_\(selectedName)_bg"
            bgView.image = UIImage.agedu_named(imageName)
        }
    }
            
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        initViews()
        initViewFrame()
        updateViewProperties()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func initViews() {
        if #available(iOS 13.0, *) {
            overrideUserInterfaceStyle = UIDevice.current.agora_is_dark ? .dark : .light
        }
        let selectedName = aSelected ? "selected" : "unselected"
        let imageName = "toolbar_\(selectedName)_bg"
        bgView.image = UIImage.agedu_named(imageName)
        contentView.addSubview(bgView)
        
        contentView.addSubview(iconView)
    }
    
    func initViewFrame() {
        bgView.mas_makeConstraints { make in
            make?.center.width().height().equalTo()(contentView)
        }
        iconView.mas_makeConstraints { make in
            make?.center.equalTo()(0)
            make?.width.height().equalTo()(22)
        }
    }
    
    func updateViewProperties() {
        

        contentView.layer.cornerRadius = FcrUIFrameGroup.fcr_round_container_corner_radius
        FcrUIColorGroup.borderSet(layer: contentView.layer)
    }
    
    func highLight() {
        self.transform = CGAffineTransform(scaleX: 1.2,
                                           y: 1.2)
        self.iconView.transform = CGAffineTransform(scaleX: 0.8,
                                                     y: 0.8)
    }
    
    func normalState() {
        UIView.animate(withDuration: 0.1,
                       delay: 0,
                       options: .curveLinear) {
            self.transform = .identity
            self.iconView.transform = .identity
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

// MARK: - FcrToolBarWaveHandsCell
class FcrToolBarWaveHandsCell: AgoraToolBarItemCell {
    
    lazy var waveHandsDelayView = FcrWaveHandsDelayView(frame: .zero)
    
    public var duration = 3 {
        didSet {
            self.waveHandsDelayView.duration = duration
        }
    }

    override init(frame: CGRect) {
        super.init(frame: frame)
        
        contentView.addSubview(waveHandsDelayView)
        waveHandsDelayView.mas_makeConstraints { make in
            make?.left.right().top().bottom().equalTo()(0)
        }
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

// MARK: - AgoraToolBarHandsListCell
class AgoraToolBarHandsListCell: AgoraToolBarItemCell {
    
    lazy var redLabel = UILabel()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        initViews()
        initViewFrame()
        updateViewProperties()
    }
    
    override func initViews() {
        super.initViews()
        redLabel.textAlignment = .center
        redLabel.isHidden = true
        redLabel.isUserInteractionEnabled = false
        
        redLabel.clipsToBounds = true
        
        self.addSubview(redLabel)
    }
    
    override func initViewFrame() {
        super.initViewFrame()
        redLabel.mas_makeConstraints { make in
            make?.width.height().equalTo()(4)
            make?.top.equalTo()(5)
            make?.right.equalTo()(-5)
        }
    }
    
    override func updateViewProperties() {
        super.updateViewProperties()
        
        
        redLabel.textColor = FcrUIColorGroup.fcr_text_contrast_color
        redLabel.font = FcrUIFontGroup.fcr_font10
        redLabel.backgroundColor = FcrUIColorGroup.fcr_system_error_color
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

// MARK: - AgoraToolCollectionCell
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
            make?.width.height().equalTo()(UIDevice.current.agora_is_pad ? 32 : 30)
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
