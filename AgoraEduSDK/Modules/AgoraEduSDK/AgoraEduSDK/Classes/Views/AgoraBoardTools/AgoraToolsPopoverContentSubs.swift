//
//  AgoraToolsPopoverContentSubs.swift
//  ApaasTest
//
//  Created by Cavan on 2021/2/1.
//

import UIKit

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
        addSubview(imageView)
    }
}

// MARK: - AgoraColorCollection
protocol AgoraColorSelected: NSObjectProtocol {
    func demandSide(_ demandSide: AgoraColorCollection.DemandSide,
              didSelectColor color: UIColor)
}

class AgoraColorCollection: AgoraBaseUICollectionView,
                            UICollectionViewDataSource,
                            UICollectionViewDelegate {
    @objc enum Color: Int {
        case blue, yellow, red, green, black, white
    }
    
    enum DemandSide {
        case pencil, text, rectangle, circle
    }
    
    class ColorCell: AgoraImageViewCell {
        
    }
    
    let colorDataSource: [Color] = [.blue,
                                    .yellow,
                                    .red,
                                    .green,
                                    .black,
                                    .white]
    
    weak var colorDelegate: AgoraColorSelected?
    
    var selectedColor: Color = .black {
        didSet {
            colorDelegate?.demandSide(demandSide,
                                      didSelectColor: selectedColor.value)
        }
    }
    
    var demandSide: DemandSide
    
    init(frame: CGRect,
         demandSide: DemandSide) {
        self.demandSide = demandSide
        super.init(frame: frame,
                   collectionViewLayout: UICollectionViewLayout())
        initViews()
    }
    
    required init?(coder: NSCoder) {
        self.demandSide = .pencil
        super.init(coder: coder)
        initViews()
    }
    
    private func initViews() {
        dataSource = self
        delegate = self
        register(ColorCell.self,
                 forCellWithReuseIdentifier: ColorCell.className)
        
        backgroundColor = .clear
    }
    
    // MARK: UICollectionViewDataSource, UICollectionViewDelegate
    func collectionView(_ collectionView: UICollectionView,
                        numberOfItemsInSection section: Int) -> Int {
        return colorDataSource.count
    }
    
    func collectionView(_ collectionView: UICollectionView,
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
    
    func collectionView(_ collectionView: UICollectionView,
                        didSelectItemAt indexPath: IndexPath) {
        let color = colorDataSource[indexPath.item]
        selectedColor = color
        collectionView.reloadData()
    }
}

extension AgoraColorCollection.Color {
    var value: UIColor {
        switch self {
        case .blue:   return .blue
        case .yellow: return .yellow
        case .red:    return .red
        case .green:  return .green
        case .black:  return .black
        case .white:  return .white
        }
    }
    
    var image: UIImage {
        switch self {
        case .blue:   return AgoraImgae(name: "蓝色-未选")
        case .yellow: return AgoraImgae(name: "黄色-未选")
        case .red:    return AgoraImgae(name: "红色-未选")
        case .green:  return AgoraImgae(name: "绿色-未选")
        case .black:  return AgoraImgae(name: "黑色-未选")
        case .white:  return AgoraImgae(name: "白色-未选")
        }
    }
    
    var selectedImage: UIImage {
        switch self {
        case .blue:   return AgoraImgae(name: "蓝色-已选")
        case .yellow: return AgoraImgae(name: "黄色-已选")
        case .red:    return AgoraImgae(name: "红色-已选")
        case .green:  return AgoraImgae(name: "绿色-已选")
        case .black:  return AgoraImgae(name: "黑色-已选")
        case .white:  return AgoraImgae(name: "白色-已选")
        }
    }
}

// MARK: - AgoraLineWidthCollection
protocol AgoraLineWidthSelected: NSObjectProtocol {
    func demandSide(_ demandSide: AgoraLineWidthCollection.DemandSide,
                    didSelectLineWidth width: AgoraLineWidthCollection.LineWidth)
}

class AgoraLineWidthCollection: AgoraBaseUICollectionView,
                                UICollectionViewDataSource,
                                UICollectionViewDelegate {
    enum LineWidth {
        case width1, width2, width3, width4
    }
    
    enum DemandSide {
        case pencil, rectangle, circle, eraser
    }
    
    class LineWidthCell: AgoraImageViewCell {
        override func layoutSubviews() {
            super.layoutSubviews()
            let imageViewSpace: CGFloat = 2
            imageView.agora_x = imageViewSpace
            imageView.agora_y = imageViewSpace
            imageView.agora_width = bounds.width - (imageViewSpace * 2)
            imageView.agora_height = bounds.height - (imageViewSpace * 2)
        }
        
        var isBySelected: Bool = false {
            didSet {
                backgroundColor = isBySelected ? UIColor(white: 1.0, alpha: 0.5) : .clear
                layer.cornerRadius = 10
            }
        }
    }
    
    let lineDataSource: [LineWidth] = [.width1,
                                       .width2,
                                       .width3,
                                       .width4]
    
    weak var lineWidthDelegate: AgoraLineWidthSelected?
    
    var demandSide: DemandSide
    
    var selectedLineWidth: LineWidth = .width1 {
        didSet {
            lineWidthDelegate?.demandSide(demandSide,
                                          didSelectLineWidth: selectedLineWidth)
        }
    }
    
    init(frame: CGRect,
         demandSide: DemandSide) {
        self.demandSide = demandSide
        super.init(frame: frame,
                   collectionViewLayout: UICollectionViewLayout())
        initViews()
    }
    
    required init?(coder: NSCoder) {
        self.demandSide = .pencil
        super.init(coder: coder)
        initViews()
    }
    
    private func initViews() {
        dataSource = self
        delegate = self
        register(LineWidthCell.self,
                 forCellWithReuseIdentifier: LineWidthCell.className)
        
        backgroundColor = .clear
    }
    
    // MARK: UICollectionViewDataSource, UICollectionViewDelegate
    func collectionView(_ collectionView: UICollectionView,
                        numberOfItemsInSection section: Int) -> Int {
        return lineDataSource.count
    }
    
    func collectionView(_ collectionView: UICollectionView,
                        cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: LineWidthCell.className,
                                                      for: indexPath) as! LineWidthCell
        let line = lineDataSource[indexPath.item]
        cell.imageView.image = line.image
        cell.isBySelected = (line == selectedLineWidth)
        
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView,
                        didSelectItemAt indexPath: IndexPath) {
        let line = lineDataSource[indexPath.item]
        selectedLineWidth = line
        collectionView.reloadData()
    }
}

extension AgoraLineWidthCollection.LineWidth {
    var image: UIImage {
        switch self {
        case .width1: return AgoraImgae(name: "形状 1148")
        case .width2: return AgoraImgae(name: "形状 1148 拷贝 2")
        case .width3: return AgoraImgae(name: "形状 1148 拷贝 3")
        case .width4: return AgoraImgae(name: "形状 1148 拷贝 4")
        }
    }
}

// MARK: - AgoraColorCollection
protocol AgoraPencilTypeSelected: NSObjectProtocol {
    func didSelectPencilType(pencil: AgoraPencilTypeCollection.PencilType)
}

class AgoraPencilTypeCollection: AgoraBaseUICollectionView,
                                 UICollectionViewDataSource,
                                 UICollectionViewDelegate {
    enum PencilType {
        case pencil1, pencil2, pencil3, pencil4
    }
    
    class PencilTypeCell: AgoraImageViewCell {
        override func layoutSubviews() {
            super.layoutSubviews()
            let imageViewSpace: CGFloat = 2
            imageView.agora_x = imageViewSpace
            imageView.agora_y = imageViewSpace
            imageView.agora_width = bounds.width - (imageViewSpace * 2)
            imageView.agora_height = bounds.height - (imageViewSpace * 2)
        }
        
        var isBySelected: Bool = false {
            didSet {
                backgroundColor = isBySelected ? UIColor(white: 1.0, alpha: 0.5) : .clear
                layer.cornerRadius = 10
            }
        }
    }
    
    let pencilTypeDataSource: [PencilType] = [.pencil1,
                                              .pencil2,
                                              .pencil3,
                                              .pencil4]
    
    weak var pencilTypeDelegate: AgoraColorSelected?
    
    var selectedPencilType: PencilType = .pencil1 {
        didSet {
           
        }
    }
    
    init(frame: CGRect) {
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
        register(PencilTypeCell.self,
                 forCellWithReuseIdentifier: PencilTypeCell.className)
        
        backgroundColor = .clear
    }
    
    // MARK: UICollectionViewDataSource, UICollectionViewDelegate
    func collectionView(_ collectionView: UICollectionView,
                        numberOfItemsInSection section: Int) -> Int {
        return pencilTypeDataSource.count
    }
    
    func collectionView(_ collectionView: UICollectionView,
                        cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: PencilTypeCell.className,
                                                      for: indexPath) as! PencilTypeCell
        let pencil = pencilTypeDataSource[indexPath.item]
        cell.imageView.image = pencil.image
        cell.isBySelected = (pencil == selectedPencilType)
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView,
                        didSelectItemAt indexPath: IndexPath) {
        let pencil = pencilTypeDataSource[indexPath.item]
        selectedPencilType = pencil
        collectionView.reloadData()
    }
}

extension AgoraPencilTypeCollection.PencilType {
    var image: UIImage {
        switch self {
        case .pencil1: return AgoraImgae(name: "箭头")
        case .pencil2: return AgoraImgae(name: "线条")
        case .pencil3: return AgoraImgae(name: "记号笔")
        case .pencil4: return AgoraImgae(name: "画笔 拷贝 2")
        }
    }
}

// MARK: - AgoraColorCollection
protocol AgoraFontSelected: NSObjectProtocol {
    func didSelectFont(font: Int)
}

class AgoraFontCollection: AgoraBaseUICollectionView,
                                 UICollectionViewDataSource,
                                 UICollectionViewDelegate {
    enum Font {
        case font22, font24, font26, font30, font36, font42, font60, font72
    }
    
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
            fontLabel.layer.borderColor = UIColor(rgb: 0x002591).cgColor
            fontLabel.layer.masksToBounds = true
            fontLabel.textAlignment = .center
            fontLabel.font = UIFont.systemFont(ofSize: 22)
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
                fontLabel.backgroundColor = isBySelected ? UIColor(rgb: 0x002591) : .white
                fontLabel.textColor = isBySelected ? .white : UIColor(rgb: 0x002591)
            }
        }
    }
    
    let fontDataSource: [Font] = [.font22,
                                  .font24,
                                  .font26,
                                  .font30,
                                  .font36,
                                  .font42,
                                  .font60,
                                  .font72]
    
    weak var fontDelegate: AgoraFontSelected?
    
    var selectedFont: Font = .font22 {
        didSet {
            fontDelegate?.didSelectFont(font: selectedFont.value)
        }
    }
    
    init(frame: CGRect) {
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
        register(FontCell.self,
                 forCellWithReuseIdentifier: FontCell.className)
        backgroundColor = .clear
    }
    
    // MARK: UICollectionViewDataSource, UICollectionViewDelegate
    func collectionView(_ collectionView: UICollectionView,
                        numberOfItemsInSection section: Int) -> Int {
        return fontDataSource.count
    }
    
    func collectionView(_ collectionView: UICollectionView,
                        cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: FontCell.className,
                                                      for: indexPath) as! FontCell
        let font = fontDataSource[indexPath.item]
        cell.isBySelected = (font == selectedFont)
        cell.fontLabel.text = "\(font.value)号"
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView,
                        didSelectItemAt indexPath: IndexPath) {
        let font = fontDataSource[indexPath.item]
        selectedFont = font
        collectionView.reloadData()
    }
}

extension AgoraFontCollection.Font {
    var value: Int {
        switch self {
        case .font22: return 22
        case .font24: return 24
        case .font26: return 26
        case .font30: return 30
        case .font36: return 36
        case .font42: return 42
        case .font60: return 60
        case .font72: return 72
        }
    }
}
