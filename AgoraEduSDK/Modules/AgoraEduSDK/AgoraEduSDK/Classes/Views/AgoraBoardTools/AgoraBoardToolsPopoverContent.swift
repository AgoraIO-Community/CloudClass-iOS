//
//  AgoraBoardToolsPopoverContent.swift
//  ApaasTest
//
//  Created by Cavan on 2021/1/31.
//

import UIKit

// MARK: - AgoraPencilPopoverContent
class AgoraPencilPopoverContent: AgoraBaseView {
    let colorCollection: AgoraColorCollection
    
    let lineWidthCollection: AgoraLineWidthCollection
    
    let pencilTypeCollection: AgoraPencilTypeCollection
    
    init(frame: CGRect,
         color: AgoraBoardToolsColor,
         lineWidth: AgoraBoardToolsLineWidth,
         pencil: AgoraBoardToolsPencilType) {
        
        colorCollection = AgoraColorCollection(frame: .zero,
                                               demandSide: .pencil,
                                               color: color)
        
        lineWidthCollection = AgoraLineWidthCollection(frame: .zero,
                                                       demandSide: .pencil,
                                                       lineWidth: lineWidth)
        
        pencilTypeCollection = AgoraPencilTypeCollection(frame: .zero,
                                                         pencil: pencil)
        
        super.init(frame: frame)
        
        initViews()
    }
    
    required init?(coder: NSCoder) {
        fatalError()
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        let topSpace: CGFloat = 8
        let bottomSpace: CGFloat = 8
        
        // colorCollection
        let colorCollectionSpace: CGFloat = 12.0
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
        let lineWidthCollectionSpace: CGFloat = 12.0
        let lineWidthCollectionWidth: CGFloat = bounds.width - (lineWidthCollectionSpace * 2)
        let lineWidthCollectionItemWidth: CGFloat = 25
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
        let pencilTypeCollectionSpace: CGFloat = 12.0
        let pencilTypeCollectionWidth: CGFloat = bounds.width - (pencilTypeCollectionSpace * 2)
        let pencilTypeCollectionItemWidth: CGFloat = 25
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
    
    let colorCollection: AgoraColorCollection
    
    let lineWidthCollection: AgoraLineWidthCollection
    
    init(frame: CGRect,
         shape: Shape,
         color: AgoraBoardToolsColor,
         lineWidth: AgoraBoardToolsLineWidth) {
        self.shape = shape
        
        colorCollection = AgoraColorCollection(frame: .zero,
                                               demandSide: (shape == .rectangle ? .rectangle : .circle),
                                               color: color)
        
        lineWidthCollection = AgoraLineWidthCollection(frame: .zero,
                                                       demandSide: (shape == .rectangle ? .rectangle : .circle),
                                                       lineWidth: lineWidth)
        
        super.init(frame: frame)
        initViews()
    }
    
    required init?(coder: NSCoder) {
        fatalError()
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        let topSpace: CGFloat = 8
        let bottomSpace: CGFloat = 8
        
        // colorCollection
        let colorCollectionSpace: CGFloat = 12.0
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
        let lineWidthCollectionSpace: CGFloat = 12.0
        let lineWidthCollectionWidth: CGFloat = bounds.width - (lineWidthCollectionSpace * 2)
        let lineWidthCollectionItemWidth: CGFloat = 25
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
    let lineWidthCollection: AgoraLineWidthCollection
    
    init(frame: CGRect,
         lineWidth: AgoraBoardToolsLineWidth) {
        
        lineWidthCollection = AgoraLineWidthCollection(frame: .zero,
                                                       demandSide: .eraser,
                                                       lineWidth: lineWidth)
        
        super.init(frame: frame)
        initViews()
    }
    
    required init?(coder: NSCoder) {
        fatalError()
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        let topSpace: CGFloat = 10
        let bottomSpace: CGFloat = 10
        
        // lineWidthCollection
        let lineWidthCollectionSpace: CGFloat = 12.0
        let lineWidthCollectionWidth: CGFloat = bounds.width - (lineWidthCollectionSpace * 2)
        let lineWidthCollectionItemWidth: CGFloat = 25
        let lineWidthCollectionItemHeight: CGFloat = lineWidthCollectionItemWidth
        let lineWidthCollectionItemSpaceSum: CGFloat = lineWidthCollectionWidth - (lineWidthCollectionItemWidth * CGFloat(lineWidthCollection.lineDataSource.count))
        let lineWidthCollectionItemSpace: CGFloat = lineWidthCollectionItemSpaceSum / CGFloat(lineWidthCollection.lineDataSource.count - 1)
        
        lineWidthCollection.agora_x = lineWidthCollectionSpace
        lineWidthCollection.agora_y = topSpace
        lineWidthCollection.agora_width = lineWidthCollectionWidth
        lineWidthCollection.agora_height = bounds.height - topSpace - bottomSpace
        
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
    let colorCollection: AgoraColorCollection
    let fontCollection: AgoraFontCollection
    
    init(frame: CGRect,
         color: AgoraBoardToolsColor,
         font: AgoraBoardToolsFont) {
        colorCollection = AgoraColorCollection(frame: .zero,
                                               demandSide: .text,
                                               color: color)
        
        fontCollection = AgoraFontCollection(frame: .zero,font: font)
        
        super.init(frame: frame)
        initViews()
    }
    
    required init?(coder: NSCoder) {
        fatalError()
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        let topSpace: CGFloat = 8
        let bottomSpace: CGFloat = 8
        
        // colorCollection
        let colorCollectionSpace: CGFloat = 12.0
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
        
        // fontCollection
        let fontCellPerRow: CGFloat = 3
        let fontCollectionTop: CGFloat = 11
        let fontCollectionSpace: CGFloat = 12
        let fontCollectionWidth: CGFloat = bounds.width - (fontCollectionSpace * 2)
        let fontCollectionItemSpace: CGFloat = 6
        let fontCollectionItemSpaceSum: CGFloat = fontCollectionItemSpace * CGFloat(fontCellPerRow + 1)
        let fontCollectionItemWidth: CGFloat = (fontCollectionWidth - fontCollectionItemSpaceSum) / fontCellPerRow
        let fontCollectionItemHeight: CGFloat = 25
        
        fontCollection.agora_x = fontCollectionSpace
        fontCollection.agora_y = colorCollection.agora_y + colorCollection.agora_height + fontCollectionTop
        fontCollection.agora_width = fontCollectionWidth
        fontCollection.agora_height = bounds.height - fontCollection.agora_y - bottomSpace
        fontCollection.contentInset = UIEdgeInsets(top: fontCollectionItemSpace,
                                                   left: fontCollectionItemSpace,
                                                   bottom: fontCollectionItemSpace,
                                                   right: fontCollectionItemSpace)
        
        let fontCollectionLayout = UICollectionViewFlowLayout()
        fontCollectionLayout.itemSize = CGSize(width: fontCollectionItemWidth,
                                                height: fontCollectionItemHeight)
        fontCollectionLayout.scrollDirection = .vertical
        fontCollectionLayout.minimumLineSpacing = fontCollectionItemSpace
        fontCollectionLayout.minimumInteritemSpacing = 4
    
        
        fontCollection.setCollectionViewLayout(fontCollectionLayout,
                                                animated: false)
    }
    
    func initViews() {
        addSubview(colorCollection)
        
        fontCollection.layer.cornerRadius = 6
        fontCollection.backgroundColor = .white
        addSubview(fontCollection)
    }
}
