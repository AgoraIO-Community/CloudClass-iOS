//
//  BrushToolItemCell.swift
//  AgoraEduUI
//
//  Created by Jonathan on 2021/9/29.
//

import AgoraUIBaseViews
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
        selectedColor = color
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
    
    func updateImageViewState() {
        
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
    private var scales: [CGFloat] = [3/7, 4/7, 5/7, 6/7, 1]
    
    private lazy var lineWidthImage = UIConfig.netlessBoard.lineWidth.image
    
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
        sizeView.image = lineWidthImage
        addSubview(sizeView)
    }
    
    func initViewFrame() {
        sizeView.mas_makeConstraints { make in
            make?.center.equalTo()(sizeView.superview)
            make?.width.height().equalTo()(14)
        }
    }
    
    func updateViewProperties() {
        updateColor()
    }
    
    func updateColor() {
        if let c = color,
           aSelected {
            sizeView.image = sizeView.image?.withRenderingMode(.alwaysTemplate)
            sizeView.tintColor = c
        } else {
            sizeView.image = sizeView.image?.withRenderingMode(.alwaysOriginal)
        }
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
            make?.width.height().equalTo()(20)
        }
        
        frontView.mas_makeConstraints { make in
            make?.center.equalTo()(frontView.superview)
            make?.width.height().equalTo()(14)
        }
    }
    
    func updateViewProperties() {
        let config = UIConfig.netlessBoard.colors
        
        backView.layer.borderWidth = config.borderWidth
        backView.layer.cornerRadius = config.cornerRadius
        backView.backgroundColor = config.backgroundColor
        
        frontView.layer.borderWidth = config.borderWidth
        frontView.layer.cornerRadius = config.cornerRadius - 2
        frontView.clipsToBounds = true
    }
}
