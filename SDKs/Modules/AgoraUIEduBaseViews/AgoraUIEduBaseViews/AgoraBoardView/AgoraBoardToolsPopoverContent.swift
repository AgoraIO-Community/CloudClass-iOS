//
//  AgoraBoardToolsPopoverContent.swift
//  ApaasTest
//
//  Created by Cavan on 2021/1/31.
//

import UIKit
import AgoraUIBaseViews

// MARK: - AgoraPencilPopoverContent
public class AgoraPencilPopoverContent: AgoraBaseUIView {
    public let pencilTypeCollection: AgoraPencilTypeCollection
    
    public init(frame: CGRect,
                pencil: AgoraBoardToolsPencilType) {
        pencilTypeCollection = AgoraPencilTypeCollection(frame: .zero,
                                                         pencil: pencil)
        
        super.init(frame: frame)
        
        initViews()
    }
    
    required init?(coder: NSCoder) {
        fatalError()
    }
    
    public override func layoutSubviews() {
        super.layoutSubviews()
        // pencilTypeCollection
        let pencilTypeCollectionSpace: CGFloat = 12.0
        let pencilTypeCollectionTop: CGFloat = 4.0
        
        let pencilTypeCollectionWidth: CGFloat = bounds.width - (pencilTypeCollectionSpace * 2)
        let pencilTypeCollectionItemWidth: CGFloat = 28
        let pencilTypeCollectionItemHeight: CGFloat = 34
        let pencilTypeCollectionItemSpaceSum: CGFloat = pencilTypeCollectionWidth - (pencilTypeCollectionItemWidth * CGFloat(pencilTypeCollection.pencilTypeDataSource.count))
        let pencilTypeCollectionItemSpace: CGFloat = pencilTypeCollectionItemSpaceSum / CGFloat(pencilTypeCollection.pencilTypeDataSource.count - 1)
        
        pencilTypeCollection.agora_x = pencilTypeCollectionSpace
        pencilTypeCollection.agora_y = pencilTypeCollectionTop
        pencilTypeCollection.agora_width = pencilTypeCollectionWidth
        pencilTypeCollection.agora_height = pencilTypeCollectionItemHeight
        
        let pencilTypeCollectionLayout = UICollectionViewFlowLayout()
        pencilTypeCollectionLayout.itemSize = CGSize(width: pencilTypeCollectionItemWidth,
                                                     height: pencilTypeCollectionItemHeight)
        pencilTypeCollectionLayout.scrollDirection = .horizontal
        pencilTypeCollectionLayout.minimumLineSpacing = pencilTypeCollectionItemSpace
        
        pencilTypeCollection.setCollectionViewLayout(pencilTypeCollectionLayout,
                                                     animated: false)
    }
    
    func initViews() {
        addSubview(pencilTypeCollection)
    }
}

// MARK: - AgoraTextPopoverContent
public class AgoraTextPopoverrContent: AgoraBaseUIView {
    public let fontCollection: AgoraFontCollection
    
    public init(frame: CGRect,
                font: AgoraBoardToolsFont) {
        fontCollection = AgoraFontCollection(frame: .zero,
                                             font: font)
        
        super.init(frame: frame)
        initViews()
    }
    
    required init?(coder: NSCoder) {
        fatalError()
    }
    
    public override func layoutSubviews() {
        super.layoutSubviews()
        // fontCollection
        let fontCellPerRow: CGFloat = 3
        let fontCollectionTop: CGFloat = 9
        let fontCollectionBottom: CGFloat = 9
        let fontCollectionSpace: CGFloat = 9
        let fontCollectionWidth: CGFloat = bounds.width - (fontCollectionSpace * 2)
        
        let fontCollectionItemWidth: CGFloat = 46
        let fontCollectionItemHeight: CGFloat = 30
        
        let fontCollectionItemWidthSum: CGFloat = fontCollectionItemWidth * CGFloat(fontCellPerRow)
        let fontCollectionItemInterSpace: CGFloat = (fontCollectionWidth - fontCollectionItemWidthSum) / CGFloat(fontCellPerRow - 1)
        
        fontCollection.agora_x = fontCollectionSpace
        fontCollection.agora_y = 0
        fontCollection.agora_width = fontCollectionWidth
        fontCollection.agora_height = bounds.height
        fontCollection.contentInset = UIEdgeInsets(top: fontCollectionTop,
                                                   left: 0,
                                                   bottom: fontCollectionBottom,
                                                   right: 0)
        
        let fontCollectionLayout = UICollectionViewFlowLayout()
        fontCollectionLayout.itemSize = CGSize(width: fontCollectionItemWidth,
                                               height: fontCollectionItemHeight)
        fontCollectionLayout.scrollDirection = .vertical
        fontCollectionLayout.minimumLineSpacing = 8
        fontCollectionLayout.minimumInteritemSpacing = fontCollectionItemInterSpace
        
        
        fontCollection.setCollectionViewLayout(fontCollectionLayout,
                                               animated: false)
    }
    
    func initViews() {
        fontCollection.backgroundColor = .white
        addSubview(fontCollection)
    }
}

// MARK: - AgoraColorPopoverrContent
public protocol AgoraToolsViewLineWidthSelected: NSObjectProtocol {
    func didSelectLineWidth(_ width: Int)
}

@objcMembers public class AgoraLineWidthSlider: AgoraBaseUISlider {
    public weak var lineWidthSelected: AgoraToolsViewLineWidthSelected?
}

@objcMembers public class AgoraColorPopoverrContent: AgoraBaseUIView, AgoraToolsViewColorSelected {
    public let colorCollection: AgoraColorCollection
    public let lineWidthSlider: AgoraLineWidthSlider
    
    public init(frame: CGRect,
                color: AgoraBoardToolsColor,
                lineWidth: Int) {
        colorCollection = AgoraColorCollection(frame: .zero,
                                               color: color)
        
        lineWidthSlider = AgoraLineWidthSlider(frame: .zero)
        lineWidthSlider.value = Float(lineWidth)
        
        super.init(frame: frame)
        
        initViews(color: color)
    }
    
    required init?(coder: NSCoder) {
        fatalError()
    }
    
    public override func layoutSubviews() {
        super.layoutSubviews()
        // lineWidthSlider
        let lineWidthSliderSpace: CGFloat = 16
        let lineWidthSliderTop: CGFloat = 15
        let lineWidthSliderWidth: CGFloat = bounds.width - (lineWidthSliderSpace * 2)
        
        lineWidthSlider.agora_x = lineWidthSliderSpace
        lineWidthSlider.agora_y = lineWidthSliderTop
        lineWidthSlider.agora_width = lineWidthSliderWidth
        lineWidthSlider.agora_height = 14
        
        // colorCollection
        let perRowCount: Int = 4
        let colorCollectionTop: CGFloat = 50
        let colorCollectionSpace: CGFloat = 16
        let colorCollectionWidth: CGFloat = bounds.width - (colorCollectionSpace * 2)
        let colorCollectionHeight: CGFloat = 80
        
        let colorCollectionItemWidth: CGFloat = 18
        let colorCollectionItemHeight: CGFloat = 18
        let colorCollectionItemWidthSum: CGFloat = colorCollectionItemWidth * CGFloat(perRowCount)
        let colorCollectionItemSpace: CGFloat = (colorCollectionWidth - colorCollectionItemWidthSum) / CGFloat(perRowCount - 1)
        
        colorCollection.agora_x = colorCollectionSpace
        colorCollection.agora_y = colorCollectionTop
        colorCollection.agora_width = colorCollectionWidth
        colorCollection.agora_height = colorCollectionHeight
        
        let colorCollectionLayout = UICollectionViewFlowLayout()
        colorCollectionLayout.itemSize = CGSize(width: colorCollectionItemWidth,
                                                height: colorCollectionItemHeight)
        colorCollectionLayout.scrollDirection = .vertical
        colorCollectionLayout.minimumLineSpacing = colorCollectionItemSpace
        colorCollectionLayout.minimumInteritemSpacing = colorCollectionItemSpace
        
        colorCollection.setCollectionViewLayout(colorCollectionLayout,
                                                animated: false)
        
        colorCollection.colorSliderDelegate = self
    }
    
    func initViews(color: AgoraBoardToolsColor) {
        addSubview(lineWidthSlider)
        addSubview(colorCollection)
        
        lineWidthSlider.addTarget(self,
                                  action: #selector(doLineWidthValueChanged),
                                  for: .valueChanged)
        
        lineWidthSlider.setThumbImage(AgoraKitImage("矩形"),
                                      for: .normal)
        lineWidthSlider.setTrackImage(color: color)
    }
    
    @objc func doLineWidthValueChanged(sender: UISlider) {
        lineWidthSlider.lineWidthSelected?.didSelectLineWidth(Int(sender.value))
    }
    
    public func didSelectColor(_ color: AgoraBoardToolsColor) {
        lineWidthSlider.setTrackImage(color: color)
    }
}

fileprivate extension AgoraLineWidthSlider {
    func setTrackImage(color: AgoraBoardToolsColor) {
        let imageName = "line-size-#\(color.intString.uppercased())"
        setMinimumTrackImage(AgoraKitImage(imageName),
                             for: .normal)
        setMaximumTrackImage(AgoraKitImage(imageName),
                             for: .normal)
    }
}
