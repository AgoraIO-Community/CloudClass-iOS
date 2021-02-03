//
//  AgoraBoardToolsPopoverContent.swift
//  ApaasTest
//
//  Created by Cavan on 2021/1/31.
//

import UIKit

// MARK: - AgoraPencilPopoverContent
class AgoraPencilPopoverContent: AgoraBaseView {
    private(set) var colorCollection = AgoraColorCollection(frame: .zero,
                                                            demandSide: .pencil)
    
    private(set) var lineWidthCollection = AgoraLineWidthCollection(frame: .zero,
                                                                    demandSide: .pencil)
    
    private(set) var pencilTypeCollection = AgoraPencilTypeCollection(frame: .zero)
    
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
        let topSpace: CGFloat = 13
        let bottomSpace: CGFloat = 13
        
        // colorCollection
        let colorCollectionSpace: CGFloat = 13.0
        let colorCollectionWidth: CGFloat = bounds.width - (colorCollectionSpace * 2)
        let colorCollectionItemSpaceSum: CGFloat = colorCollectionSpace * CGFloat(colorCollection.colorDataSource.count - 1)
        let colorCollectionItemWidth: CGFloat = (colorCollectionWidth - colorCollectionItemSpaceSum) / CGFloat(colorCollection.colorDataSource.count)
        let colorCollectionItemHeight: CGFloat = colorCollectionItemWidth
        
        colorCollection.agora_x = colorCollectionSpace
        colorCollection.agora_y = topSpace
        colorCollection.agora_width = colorCollectionWidth
        colorCollection.agora_height = colorCollectionItemHeight
        
        let colorCollectionLayout = UICollectionViewFlowLayout()
        colorCollectionLayout.itemSize = CGSize(width: colorCollectionItemWidth,
                                                height: colorCollectionItemHeight)
        colorCollectionLayout.scrollDirection = .horizontal
        colorCollectionLayout.minimumLineSpacing = colorCollectionSpace
        
        colorCollection.setCollectionViewLayout(colorCollectionLayout,
                                                animated: false)
        
        // lineWidthCollection
        let lineWidthCollectionSpace: CGFloat = 13.0
        let lineWidthCollectionWidth: CGFloat = bounds.width - (lineWidthCollectionSpace * 2)
        let lineWidthCollectionItemWidth: CGFloat = 61
        let lineWidthCollectionItemHeight: CGFloat = lineWidthCollectionItemWidth
        let lineWidthCollectionItemSpaceSum: CGFloat = lineWidthCollectionWidth - (lineWidthCollectionItemWidth * CGFloat(lineWidthCollection.lineDataSource.count))
        let lineWidthCollectionItemSpace: CGFloat = lineWidthCollectionItemSpaceSum / CGFloat(lineWidthCollection.lineDataSource.count - 1)
        
        lineWidthCollection.agora_x = lineWidthCollectionSpace
        lineWidthCollection.agora_width = lineWidthCollectionWidth
        lineWidthCollection.agora_height = lineWidthCollectionItemHeight
        
        let lineWidthCollectionLayout = UICollectionViewFlowLayout()
        lineWidthCollectionLayout.itemSize = CGSize(width: lineWidthCollectionItemWidth,
                                                    height: lineWidthCollectionItemHeight)
        lineWidthCollectionLayout.scrollDirection = .horizontal
        lineWidthCollectionLayout.minimumLineSpacing = lineWidthCollectionItemSpace
        
        lineWidthCollection.setCollectionViewLayout(lineWidthCollectionLayout,
                                                    animated: false)
        
        // pencilTypeCollection
        let pencilTypeCollectionSpace: CGFloat = 13.0
        let pencilTypeCollectionWidth: CGFloat = bounds.width - (pencilTypeCollectionSpace * 2)
        let pencilTypeCollectionItemWidth: CGFloat = 64
        let pencilTypeCollectionItemHeight: CGFloat = pencilTypeCollectionItemWidth
        let pencilTypeCollectionItemSpaceSum: CGFloat = pencilTypeCollectionWidth - (pencilTypeCollectionItemWidth * CGFloat(pencilTypeCollection.pencilTypeDataSource.count))
        let pencilTypeCollectionItemSpace: CGFloat = pencilTypeCollectionItemSpaceSum / CGFloat(pencilTypeCollection.pencilTypeDataSource.count - 1)
        
        pencilTypeCollection.agora_x = pencilTypeCollectionSpace
        pencilTypeCollection.agora_width = pencilTypeCollectionWidth
        pencilTypeCollection.agora_height = pencilTypeCollectionItemHeight
        
        let pencilTypeCollectionLayout = UICollectionViewFlowLayout()
        pencilTypeCollectionLayout.itemSize = CGSize(width: pencilTypeCollectionItemWidth,
                                                    height: pencilTypeCollectionItemHeight)
        pencilTypeCollectionLayout.scrollDirection = .horizontal
        pencilTypeCollectionLayout.minimumLineSpacing = pencilTypeCollectionItemSpace
        
        pencilTypeCollection.setCollectionViewLayout(pencilTypeCollectionLayout,
                                                    animated: false)
        
        // set collection y
        let collectionTotalHeight = colorCollectionItemHeight + lineWidthCollectionItemHeight + pencilTypeCollectionItemHeight
        let rowSpace: CGFloat = (bounds.height - topSpace - bottomSpace - collectionTotalHeight) / CGFloat(2)
        
        lineWidthCollection.agora_y = colorCollection.agora_y + colorCollectionItemHeight + rowSpace
        pencilTypeCollection.agora_y = lineWidthCollection.agora_y + lineWidthCollectionItemHeight + rowSpace
    }
    
    func initViews() {
        addSubview(colorCollection)
        addSubview(lineWidthCollection)
        addSubview(pencilTypeCollection)
    }
}

// MARK: - AgoraShapePopoverContent
class AgoraShapePopoverrContent: AgoraBaseView {
    enum Shape {
        case rectangle, circle
    }
    
    var shape: Shape
    
    private(set) lazy var colorCollection = AgoraColorCollection(frame: .zero,
                                                                 demandSide: (shape == .rectangle ? .rectangle : .circle))
    
    private(set) lazy var lineWidthCollection = AgoraLineWidthCollection(frame: .zero,
                                                                    demandSide: (shape == .rectangle ? .rectangle : .circle))
    
    init(frame: CGRect, shape: Shape) {
        self.shape = shape
        super.init(frame: frame)
        initViews()
    }
    
    required init?(coder: NSCoder) {
        self.shape = .rectangle
        super.init(coder: coder)
        initViews()
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        let topSpace: CGFloat = 13
        let bottomSpace: CGFloat = 13
        
        // colorCollection
        let colorCollectionSpace: CGFloat = 13.0
        let colorCollectionWidth: CGFloat = bounds.width - (colorCollectionSpace * 2)
        let colorCollectionItemSpaceSum: CGFloat = colorCollectionSpace * CGFloat(colorCollection.colorDataSource.count - 1)
        let colorCollectionItemWidth: CGFloat = (colorCollectionWidth - colorCollectionItemSpaceSum) / CGFloat(colorCollection.colorDataSource.count)
        let colorCollectionItemHeight: CGFloat = colorCollectionItemWidth
        
        colorCollection.agora_x = colorCollectionSpace
        colorCollection.agora_y = topSpace
        colorCollection.agora_width = colorCollectionWidth
        colorCollection.agora_height = colorCollectionItemHeight
        
        let colorCollectionLayout = UICollectionViewFlowLayout()
        colorCollectionLayout.itemSize = CGSize(width: colorCollectionItemWidth,
                                                height: colorCollectionItemHeight)
        colorCollectionLayout.scrollDirection = .horizontal
        colorCollectionLayout.minimumLineSpacing = colorCollectionSpace
        
        colorCollection.setCollectionViewLayout(colorCollectionLayout,
                                                animated: false)
        
        // lineWidthCollection
        let lineWidthCollectionSpace: CGFloat = 13.0
        let lineWidthCollectionWidth: CGFloat = bounds.width - (lineWidthCollectionSpace * 2)
        let lineWidthCollectionItemWidth: CGFloat = 61
        let lineWidthCollectionItemHeight: CGFloat = lineWidthCollectionItemWidth
        let lineWidthCollectionItemSpaceSum: CGFloat = lineWidthCollectionWidth - (lineWidthCollectionItemWidth * CGFloat(lineWidthCollection.lineDataSource.count))
        let lineWidthCollectionItemSpace: CGFloat = lineWidthCollectionItemSpaceSum / CGFloat(lineWidthCollection.lineDataSource.count - 1)
        
        lineWidthCollection.agora_x = lineWidthCollectionSpace
        lineWidthCollection.agora_width = lineWidthCollectionWidth
        lineWidthCollection.agora_height = lineWidthCollectionItemHeight
        
        let lineWidthCollectionLayout = UICollectionViewFlowLayout()
        lineWidthCollectionLayout.itemSize = CGSize(width: lineWidthCollectionItemWidth,
                                                    height: lineWidthCollectionItemHeight)
        lineWidthCollectionLayout.scrollDirection = .horizontal
        lineWidthCollectionLayout.minimumLineSpacing = lineWidthCollectionItemSpace
        
        lineWidthCollection.setCollectionViewLayout(lineWidthCollectionLayout,
                                                    animated: false)
        
        // set collection y
        let collectionTotalHeight = colorCollectionItemHeight + lineWidthCollectionItemHeight
        let rowSpace: CGFloat = bounds.height - topSpace - bottomSpace - collectionTotalHeight
        
        lineWidthCollection.agora_y = colorCollection.agora_y + colorCollectionItemHeight + rowSpace
    }
    
    func initViews() {
        addSubview(colorCollection)
        addSubview(lineWidthCollection)
    }
}

// MARK: - AgoraShapePopoverContent
class AgoraEraserPopoverrContent: AgoraBaseView {
    private(set) lazy var lineWidthCollection = AgoraLineWidthCollection(frame: .zero,
                                                                         demandSide: .eraser)
    
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
        let topSpace: CGFloat = 23
        
        // lineWidthCollection
        let lineWidthCollectionSpace: CGFloat = 13.0
        let lineWidthCollectionWidth: CGFloat = bounds.width - (lineWidthCollectionSpace * 2)
        let lineWidthCollectionItemWidth: CGFloat = 61
        let lineWidthCollectionItemHeight: CGFloat = lineWidthCollectionItemWidth
        let lineWidthCollectionItemSpaceSum: CGFloat = lineWidthCollectionWidth - (lineWidthCollectionItemWidth * CGFloat(lineWidthCollection.lineDataSource.count))
        let lineWidthCollectionItemSpace: CGFloat = lineWidthCollectionItemSpaceSum / CGFloat(lineWidthCollection.lineDataSource.count - 1)
        
        lineWidthCollection.agora_x = lineWidthCollectionSpace
        lineWidthCollection.agora_y = topSpace
        lineWidthCollection.agora_width = lineWidthCollectionWidth
        lineWidthCollection.agora_height = lineWidthCollectionItemHeight
        
        let lineWidthCollectionLayout = UICollectionViewFlowLayout()
        lineWidthCollectionLayout.itemSize = CGSize(width: lineWidthCollectionItemWidth,
                                                    height: lineWidthCollectionItemHeight)
        lineWidthCollectionLayout.scrollDirection = .horizontal
        lineWidthCollectionLayout.minimumLineSpacing = lineWidthCollectionItemSpace
        
        lineWidthCollection.setCollectionViewLayout(lineWidthCollectionLayout,
                                                    animated: false)
    }
    
    func initViews() {
        addSubview(lineWidthCollection)
    }
}

// MARK: - AgoraTextPopoverContent
class AgoraTextPopoverrContent: AgoraBaseView {
    let colorCollection = AgoraColorCollection(frame: .zero,
                                               demandSide: .text)
    
    let fontTitleLabel = AgoraBaseUILabel(frame: .zero)
    
    let fontCollection = AgoraFontCollection(frame: .zero)
    
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
        let topSpace: CGFloat = 13
        let bottomSpace: CGFloat = 13
        
        // colorCollection
        let colorCollectionSpace: CGFloat = 13.0
        let colorCollectionWidth: CGFloat = bounds.width - (colorCollectionSpace * 2)
        let colorCollectionItemSpaceSum: CGFloat = colorCollectionSpace * CGFloat(colorCollection.colorDataSource.count - 1)
        let colorCollectionItemWidth: CGFloat = (colorCollectionWidth - colorCollectionItemSpaceSum) / CGFloat(colorCollection.colorDataSource.count)
        let colorCollectionItemHeight: CGFloat = colorCollectionItemWidth
        
        colorCollection.agora_x = colorCollectionSpace
        colorCollection.agora_y = topSpace
        colorCollection.agora_width = colorCollectionWidth
        colorCollection.agora_height = colorCollectionItemHeight
        
        let colorCollectionLayout = UICollectionViewFlowLayout()
        colorCollectionLayout.itemSize = CGSize(width: colorCollectionItemWidth,
                                                height: colorCollectionItemHeight)
        colorCollectionLayout.scrollDirection = .horizontal
        colorCollectionLayout.minimumLineSpacing = colorCollectionSpace
        
        colorCollection.setCollectionViewLayout(colorCollectionLayout,
                                                animated: false)
        
        // fontTitleLabel
        let fontTitleLabelTop: CGFloat = 30
        fontTitleLabel.agora_center_x = bounds.width * 0.5
        fontTitleLabel.agora_y = colorCollection.agora_y + colorCollection.agora_height + fontTitleLabelTop
        fontTitleLabel.agora_width = bounds.width
        fontTitleLabel.agora_height = 23
        
        // fontCollection
        let fontCellPerRow: CGFloat = 3
        let fontCollectionTop: CGFloat = 19
        let fontCollectionSpace: CGFloat = 15
        let fontCollectionWidth: CGFloat = bounds.width - (fontCollectionSpace * 2)
        let fontCollectionItemSpace: CGFloat = 10
        let fontCollectionItemSpaceSum: CGFloat = fontCollectionItemSpace * CGFloat(fontCellPerRow + 1)
        let fontCollectionItemWidth: CGFloat = (fontCollectionWidth - fontCollectionItemSpaceSum) / fontCellPerRow
        let fontCollectionItemHeight: CGFloat = 43
        
        fontCollection.agora_x = fontCollectionSpace
        fontCollection.agora_y = fontTitleLabel.agora_y + fontTitleLabel.agora_height + fontCollectionTop
        fontCollection.agora_width = fontCollectionWidth
        fontCollection.agora_height = bounds.height - fontCollection.agora_y - bottomSpace
        fontCollection.contentInset = UIEdgeInsets(top: fontCollectionItemSpace,
                                                   left: fontCollectionItemSpace,
                                                   bottom: fontCollectionItemSpace,
                                                   right: fontCollectionItemSpace)
        
        let fontCollectionLayout = UICollectionViewFlowLayout()
        fontCollectionLayout.itemSize = CGSize(width: fontCollectionItemWidth,
                                                height: fontCollectionItemHeight)
        fontCollectionLayout.scrollDirection = .horizontal
        fontCollectionLayout.minimumLineSpacing = fontCollectionItemSpace
    
        
        fontCollection.setCollectionViewLayout(fontCollectionLayout,
                                                animated: false)
    }
    
    func initViews() {
        addSubview(colorCollection)
        
        fontTitleLabel.text = "字体大小"
        fontTitleLabel.font = UIFont.systemFont(ofSize: 24)
        fontTitleLabel.textColor = .white
        fontTitleLabel.textAlignment = .center
        addSubview(fontTitleLabel)
        
        fontCollection.layer.cornerRadius = 6
        fontCollection.backgroundColor = .white
        addSubview(fontCollection)
    }
}
