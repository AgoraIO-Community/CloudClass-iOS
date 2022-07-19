//
//  BrushToolItemCell.swift
//  AgoraEduUI
//
//  Created by Jonathan on 2021/9/29.
//

import Masonry
import UIKit

class AgoraToolCollectionToolCell: UICollectionViewCell, AgoraUIContentContainer {
    private lazy var imageView = UIImageView(frame: .zero)
    private var selectedColor: UIColor?
    
    var aSelected: Bool = false {
        willSet {
            if newValue,
               let i = imageView.image {
                imageView.image = i.withRenderingMode(.alwaysTemplate)
                imageView.tintColor = selectedColor
            } else {
                imageView.tintColor = nil
            }
        }
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        initViews()
        initViewFrame()
        updateViewProperties()
    }
    
    public func setImage(image: UIImage?,
                         color: UIColor?) {
        if let c = color {
            selectedColor = color
        }
        imageView.image = image
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: AgoraUIContentContainer
    func initViews() {
        imageView.contentMode = .scaleAspectFit
        addSubview(imageView)
    }
    
    func initViewFrame() {
        imageView.mas_makeConstraints { make in
            make?.center.equalTo()(self)
            make?.width.height().equalTo()(UIDevice.current.agora_is_pad ? 34 : 30)
        }
    }
    
    func updateViewProperties() {
        backgroundColor = UIConfig.toolCollection.backgroundColor
    }
}

// MARK: - AgoraBoardTextSizeItemCell
class AgoraBoardTextSizeItemCell: UICollectionViewCell {
    public var level: Int = -1 {
        willSet {
            if level != newValue {
                let scale: CGFloat = (10 + 2 * CGFloat(newValue)) / 16
                sizeView.transform = CGAffineTransform(scaleX: scale,
                                                       y: scale)
            }
        }
    }
    
    public var color: UIColor?
    /** 需要先设置颜色才能正常刷出来*/
    public var aSelected: Bool = false {
        willSet {
            guard let i = sizeView.image else {
                return
            }
            if newValue == true,
               let c = color {
                sizeView.image = i.withRenderingMode(.alwaysTemplate)
                sizeView.tintColor = c
            } else {
                sizeView.image = i.withRenderingMode(.alwaysOriginal)
            }
        }
    }
    
    private lazy var sizeView = UIImageView()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        let image = UIConfig.netlessBoard.text.image
        sizeView.image = image
        sizeView.contentMode = .scaleAspectFill
        addSubview(sizeView)
        sizeView.mas_makeConstraints { make in
            make?.center.equalTo()(sizeView.superview)
            make?.width.height().equalTo()(sizeView.superview)
        }
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}

// MARK: - BrushSizeItemCell
class AgoraBoardLineWidthCell: UICollectionViewCell, AgoraUIContentContainer {
    private var scales: [CGFloat] = [1, 4/3, 2, 7/3, 3]
    
    public var level: Int = -1 {
        willSet {
            guard level != newValue else {
                return
            }
            sizeView.transform = CGAffineTransform(scaleX: scales[newValue],
                                                   y: scales[newValue])
        }
    }
    
    public var color: UIColor?
    /** 需要先设置颜色才能正常刷出来*/
    public var aSelected: Bool = false {
        didSet {
            updateColor()
        }
    }
    
    private lazy var sizeView = UIImageView()
    
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
        let config = UIConfig.netlessBoard.lineWidth
        sizeView.image = config.image
        addSubview(sizeView)
    }
    
    func initViewFrame() {
        sizeView.mas_makeConstraints { make in
            make?.center.equalTo()(sizeView.superview)
            make?.width.height().equalTo()(6)
        }
    }
    
    func updateViewProperties() {
        updateColor()
    }
    
    func updateColor() {
        guard aSelected else {
            sizeView.tintColor = nil
            return
        }
        
        sizeView.tintColor = color
    }
}

// MARK: - BrushColorItemCell
class AgoraBoardColorItemCell: UICollectionViewCell, AgoraUIContentContainer {
    lazy var frontView = UIView(frame: .zero)
    
    lazy var backView = UIView(frame: .zero)
    
    var color: UIColor? {
        didSet {
            frontView.backgroundColor = color
            frontView.layer.borderColor = color?.cgColor
            backView.layer.borderColor = color?.cgColor
        }
    }
    
    var aSelected: Bool = false {
        willSet {
            backView.isHidden = !newValue
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
    
    // MARK: AgoraUIContentContainer
    func initViews() {
        addSubview(backView)
        addSubview(frontView)
    }
    
    func initViewFrame() {
        backView.mas_makeConstraints { make in
            make?.center.equalTo()(backView.superview)
            make?.width.height().equalTo()(24)
        }
        
        frontView.mas_makeConstraints { make in
            make?.center.equalTo()(frontView.superview)
            make?.width.height().equalTo()(20)
        }
    }
    
    func updateViewProperties() {
        let config = UIConfig.netlessBoard.colors
        
        backView.layer.borderWidth = config.borderWidth
        backView.layer.cornerRadius = config.cornerRadius
        backView.backgroundColor = config.backgroundColor
        
        frontView.layer.borderWidth = config.borderWidth
        frontView.layer.cornerRadius = config.cornerRadius
        frontView.clipsToBounds = true
    }
}
