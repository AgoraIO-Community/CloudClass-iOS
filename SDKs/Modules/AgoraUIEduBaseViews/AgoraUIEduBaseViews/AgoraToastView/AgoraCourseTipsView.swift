//
//  AgoraCourseTipsView.swift
//  AFNetworking
//
//  Created by ZYP on 2021/2/3.
//

import UIKit
import AgoraUIBaseViews

@objcMembers public class AgoraCourseTipsView: AgoraBaseUIView {
    private let imageView = AgoraBaseUIImageView(image: nil)
    private let textLabel = AgoraBaseUILabel()
    private let bgView = AgoraBaseUIView()
    
    fileprivate var image: UIImage?
    fileprivate var imageSize: CGSize?
    
    public override init(frame: CGRect) {
        super.init(frame: frame)
        setup()
        setupLayout()
    }
    
    public required init?(coder: NSCoder) {
        super.init(coder: coder)
        setup()
        setupLayout()
    }
    
    public var textLabelFont: UIFont {
        return textLabel.font
    }
    
    private func setup() {
        let bgViewHeight = self.bgViewHeight()
        
        backgroundColor = .clear
        bgView.backgroundColor = UIColor.black.withAlphaComponent(0.8)
        bgView.layer.cornerRadius = bgViewHeight/2
        bgView.layer.masksToBounds = true
        
        bgView.addSubview(textLabel)
        addSubview(bgView)
        addSubview(imageView)
    }
    
    private func setupLayout() {
        let bgViewHeight = self.bgViewHeight()
        
        textLabel.agora_x = textLabelLeadingConstraintConstant()
        textLabel.agora_center_y = 0
        textLabel.agora_right = 5
        
        bgView.agora_x = bgViewLeadingConstraintConstant()
        bgView.agora_right = 0
        bgView.agora_height = bgViewHeight
        bgView.agora_center_y = 0
        
        let width = imageSize?.width ?? 0
        let height = imageSize?.height ?? 0
        imageView.image = image
        imageView.agora_x = 0
        imageView.agora_width = width
        imageView.agora_height = height
        imageView.agora_center_y = 0
    }
    
    /// Height of AgoraCourseTipsView instance should be set `allHeight` value
    public static func allHeight() -> CGFloat {
        return UIDevice.current.userInterfaceIdiom == .pad ? 82.5 : 70
    }
    
    private func bgViewHeight() -> CGFloat {
        return AgoraCourseTipsView.allHeight() - 25
    }
    
    public func textLabelLeadingConstraintConstant() -> CGFloat {
        return imageSize == nil ? 10 : (imageSize!.width/2 + 5)
    }
    
    private func bgViewLeadingConstraintConstant() -> CGFloat {
        return imageSize == nil ? 5 : (imageSize!.width/2)
    }
    
    func getTextWidthForComment(text: String, font: UIFont, height: CGFloat = 15) -> CGFloat {
        let size = text.agoraKitSize(font: font,
                             height: height)
        return ceil(size.width)
    }
    
    func setWidth() {
        var len = getTextWidthForComment(text: textLabel.text ?? "", font: textLabel.font)
        len += (imageSize?.width ?? 10) + 15
        len = CGFloat.minimum(len, UIScreen.agora_width * 0.6)
        len = CGFloat.maximum(len, imageSize?.width ?? 70)
        textLabel.textAlignment = len == 70 ? .center : .left
        agora_width = len
    }
}

extension AgoraCourseTipsView {
    public func setImage(image: UIImage, imageSize: CGSize) {
        self.image = image
        self.imageSize = imageSize
        setWidth()
        setupLayout()
    }
    
    public func setText(text: String,
                        color: UIColor = .white,
                        font: UIFont = UIFont.systemFont(ofSize: 13)){
        textLabel.text = text
        textLabel.textColor = color
        textLabel.font = font
        setWidth()
        
    }
    
    public func setAttributedText(attributedText: NSMutableAttributedString) {
        textLabel.attributedText = attributedText
        setWidth()
    }
}



