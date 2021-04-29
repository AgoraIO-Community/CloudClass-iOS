//
//  AgoraToolsPopoverContentSubs.swift
//  ApaasTest
//
//  Created by Cavan on 2021/2/1.
//

import UIKit
import AgoraUIBaseViews

// MARK: - AgoraImageViewCell
class AgoraImageViewCell: AgoraBaseUICollectionCell {
    static var className: String {
        return NSStringFromClass(self)
    }
    
    var imageView = AgoraBaseUIImageView(frame: .zero)
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        initViews()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        initViews()
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        imageView.agora_x = 0
        imageView.agora_y = 0
        imageView.agora_width = bounds.width
        imageView.agora_height = bounds.height
        imageView.contentMode = .scaleAspectFit
    }
    
    private func initViews() {
        contentView.addSubview(imageView)
    }
}

// MARK: - AgoraColorCollection
public protocol AgoraToolsViewColorSelected: NSObjectProtocol {
    func didSelectColor(_ color: AgoraBoardToolsColor)
}

public class AgoraColorCollection: AgoraBaseUICollectionView,
                                   UICollectionViewDataSource,
                                   UICollectionViewDelegate {
    class ColorCell: AgoraImageViewCell {
        
    }
    
    let colorDataSource: [AgoraBoardToolsColor] = [.white,
                                                   .lightGray,
                                                   .darkGray,
                                                   .black,
                                                   .red,
                                                   .orange,
                                                   .yellow,
                                                   .green,
                                                   .purple,
                                                   .cyan,
                                                   .blue,
                                                   .pink]
    
    public weak var colorDelegate: AgoraToolsViewColorSelected?
    
    weak var colorSliderDelegate: AgoraToolsViewColorSelected?
    
    var selectedColor: AgoraBoardToolsColor = .black {
        didSet {
            colorDelegate?.didSelectColor(selectedColor)
            colorSliderDelegate?.didSelectColor(selectedColor)
        }
    }
    
    init(frame: CGRect,
         color: AgoraBoardToolsColor) {
        self.selectedColor = color
        super.init(frame: frame,
                   collectionViewLayout: UICollectionViewLayout())
        initViews()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        initViews()
    }
    
    private func initViews() {
        dataSource = self
        delegate = self
        register(ColorCell.self,
                 forCellWithReuseIdentifier: ColorCell.className)
        
        backgroundColor = .clear
        showsVerticalScrollIndicator = false
        showsHorizontalScrollIndicator = false
    }
    
    // MARK: UICollectionViewDataSource, UICollectionViewDelegate
    public func collectionView(_ collectionView: UICollectionView,
                               numberOfItemsInSection section: Int) -> Int {
        return colorDataSource.count
    }
    
    public func collectionView(_ collectionView: UICollectionView,
                               cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: ColorCell.className,
                                                      for: indexPath) as! ColorCell
        let color = colorDataSource[indexPath.item]
        if color == selectedColor {
            cell.imageView.image = color.selectedImage
        } else {
            cell.imageView.image = color.image
        }
        
        return cell
    }
    
    public func collectionView(_ collectionView: UICollectionView,
                               didSelectItemAt indexPath: IndexPath) {
        let color = colorDataSource[indexPath.item]
        selectedColor = color
        collectionView.reloadData()
    }
}

fileprivate extension AgoraBoardToolsColor {
    var image: UIImage? {
        let imageName = "icon-color-#\(intString.uppercased())"
        return AgoraKitImage(imageName)
    }
    
    var selectedImage: UIImage? {
        let imageName = "icon-color-#\(intString.uppercased())-actived"
        return AgoraKitImage(imageName)
    }
}

// MARK: - AgoraPencilTypeCollection
public protocol AgoraPencilTypeSelected: NSObjectProtocol {
    func didSelectPencilType(pencil: AgoraBoardToolsPencilType)
}

public class AgoraPencilTypeCollection: AgoraBaseUICollectionView,
                                 UICollectionViewDataSource,
                                 UICollectionViewDelegate {
    class PencilTypeCell: AgoraImageViewCell {
        let dotView: AgoraBaseUIView = AgoraBaseUIView(frame: .zero)
        
        override init(frame: CGRect) {
            super.init(frame: frame)
            contentView.addSubview(dotView)
        }
        
        required init?(coder: NSCoder) {
            super.init(coder: coder)
            contentView.addSubview(dotView)
        }
        
        override func layoutSubviews() {
            super.layoutSubviews()
            let imageViewSpace: CGFloat = 2
            imageView.agora_x = 0
            imageView.agora_y = imageViewSpace
            imageView.agora_width = bounds.width
            imageView.agora_height = imageView.agora_width
            
            let dotViewWidth: CGFloat = 3
            let dotViewHeight: CGFloat = 3
            dotView.agora_x = (bounds.width - dotViewWidth) * 0.5
            dotView.agora_y = imageView.agora_y + imageView.agora_height
            dotView.agora_width = dotViewWidth
            dotView.agora_height = dotViewHeight
            dotView.layer.cornerRadius = dotViewHeight * 0.5
        }
        
        var isBySelected: Bool = false {
            didSet {
                dotView.isHidden = !isBySelected
                dotView.backgroundColor = UIColor(rgb: 0x868F9F)
            }
        }
    }
    
    let pencilTypeDataSource: [AgoraBoardToolsPencilType] = [.pencil,
                                                             .rectangle,
                                                             .circle,
                                                             .line]
    
    public weak var pencilTypeDelegate: AgoraPencilTypeSelected?
    
    var selectedPencilType: AgoraBoardToolsPencilType {
        didSet {
            pencilTypeDelegate?.didSelectPencilType(pencil: selectedPencilType)
        }
    }
    
    init(frame: CGRect,
         pencil: AgoraBoardToolsPencilType) {
        self.selectedPencilType = pencil
        super.init(frame: frame,
                   collectionViewLayout: UICollectionViewLayout())
        initViews()
    }
    
    required init?(coder: NSCoder) {
        self.selectedPencilType = .pencil
        super.init(coder: coder)
        initViews()
    }
    
    private func initViews() {
        dataSource = self
        delegate = self
        register(PencilTypeCell.self,
                 forCellWithReuseIdentifier: PencilTypeCell.className)
        
        backgroundColor = .clear
    }
    
    // MARK: UICollectionViewDataSource, UICollectionViewDelegate
    public func collectionView(_ collectionView: UICollectionView,
                               numberOfItemsInSection section: Int) -> Int {
        return pencilTypeDataSource.count
    }
    
    public func collectionView(_ collectionView: UICollectionView,
                               cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: PencilTypeCell.className,
                                                      for: indexPath) as! PencilTypeCell
        let pencil = pencilTypeDataSource[indexPath.item]
        cell.imageView.image = pencil.image
        cell.isBySelected = (pencil == selectedPencilType)
        return cell
    }
    
    public func collectionView(_ collectionView: UICollectionView,
                               didSelectItemAt indexPath: IndexPath) {
        let pencil = pencilTypeDataSource[indexPath.item]
        selectedPencilType = pencil
        collectionView.reloadData()
    }
}

fileprivate extension AgoraBoardToolsPencilType {
    var image: UIImage? {
        switch self {
        case .pencil:    return AgoraKitImage("icon-pen")
        case .rectangle: return AgoraKitImage("icon-square")
        case .circle:    return AgoraKitImage("icon-circle")
        case .line:      return AgoraKitImage("icon-line")
        }
    }
}

// MARK: - AgoraFontSelected
public protocol AgoraFontSelected: NSObjectProtocol {
    func didSelectFont(font: AgoraBoardToolsFont)
}

public class AgoraFontCollection: AgoraBaseUICollectionView,
                                 UICollectionViewDataSource,
                                 UICollectionViewDelegate {
    class FontCell: AgoraBaseUICollectionCell {
        static var className: String {
            return NSStringFromClass(self)
        }
        
        private(set) var fontLabel = AgoraBaseUILabel(frame: .zero)
        
        override init(frame: CGRect) {
            super.init(frame: frame)
            initViews()
        }
        
        required init?(coder: NSCoder) {
            super.init(coder: coder)
            initViews()
        }
        
        func initViews() {
            fontLabel.layer.borderWidth = 1
            fontLabel.layer.borderColor = UIColor(rgb: 0xD9D9E7).cgColor
            fontLabel.layer.masksToBounds = true
            fontLabel.textAlignment = .center
            fontLabel.font = UIFont.systemFont(ofSize: 14)
            addSubview(fontLabel)
        }
        
        override func layoutSubviews() {
            super.layoutSubviews()
            fontLabel.agora_x = 0
            fontLabel.agora_y = 0
            fontLabel.agora_width = bounds.width
            fontLabel.agora_height = bounds.height
            fontLabel.layer.cornerRadius = 4
        }
        
        var isBySelected: Bool = false {
            didSet {
                fontLabel.backgroundColor = isBySelected ? UIColor(rgb: 0x357BF6) : .white
                fontLabel.textColor = isBySelected ? .white : UIColor(rgb: 0x7B88A0)
            }
        }
    }
    
    let fontDataSource: [AgoraBoardToolsFont] = [.font22,
                                                 .font24,
                                                 .font26,
                                                 .font30,
                                                 .font36,
                                                 .font42]
    
    public weak var fontDelegate: AgoraFontSelected?
    
    var selectedFont: AgoraBoardToolsFont {
        didSet {
            fontDelegate?.didSelectFont(font: selectedFont)
        }
    }
    
    init(frame: CGRect,
         font: AgoraBoardToolsFont) {
        self.selectedFont = font
        super.init(frame: frame,
                   collectionViewLayout: UICollectionViewLayout())
        initViews()
    }
    
    required init?(coder: NSCoder) {
        self.selectedFont = .font22
        super.init(coder: coder)
        initViews()
    }
    
    private func initViews() {
        dataSource = self
        delegate = self
        register(FontCell.self,
                 forCellWithReuseIdentifier: FontCell.className)
        backgroundColor = .clear
    }
    
    // MARK: UICollectionViewDataSource, UICollectionViewDelegate
    public func collectionView(_ collectionView: UICollectionView,
                               numberOfItemsInSection section: Int) -> Int {
        return fontDataSource.count
    }
    
    public func collectionView(_ collectionView: UICollectionView,
                               cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: FontCell.className,
                                                      for: indexPath) as! FontCell
        let font = fontDataSource[indexPath.item]
        cell.isBySelected = (font == selectedFont)
        cell.fontLabel.text = "\(font.value)pt"
        return cell
    }
    
    public func collectionView(_ collectionView: UICollectionView,
                               didSelectItemAt indexPath: IndexPath) {
        let font = fontDataSource[indexPath.item]
        selectedFont = font
        collectionView.reloadData()
    }
}
