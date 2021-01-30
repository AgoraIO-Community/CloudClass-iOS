//
//  AgoraPopover.swift
//  AgoraPopover
//
//  Created by CavanSu on 8/16/15.
//  Copyright (c) 2017 CavanSu. All rights reserved.
//

import Foundation
import UIKit

protocol AgoraPopoverDelegate: NSObjectProtocol {
    func AgoraPopoverDidDismiss(_ AgoraPopover: AgoraPopover)
}

public enum AgoraPopoverOption {
    case arrowSize(CGSize)
    case animationIn(TimeInterval)
    case animationOut(TimeInterval)
    case cornerRadius(CGFloat)
    case sideEdge(CGFloat)
    case blackOverlayColor(UIColor)
    case overlayBlur(UIBlurEffect.Style)
    case type(AgoraPopoverType)
    case color(UIColor)
    case dismissOnBlackOverlayTap(Bool)
    case showBlackOverlay(Bool)
    case springDamping(CGFloat)
    case initialSpringVelocity(CGFloat)
}

@objc public enum AgoraPopoverType: Int {
    case left
    case right
    case up
    case down
}

open class AgoraPopover: UIView {
    weak var delegate: AgoraPopoverDelegate?
    
    // custom property
    open var arrowSize: CGSize = CGSize(width: 16.0, height: 10.0)
    open var animationIn: TimeInterval = 0.6
    open var animationOut: TimeInterval = 0.3
    open var popCornerRadius: CGFloat = 6.0
    
    open var sideEdge: CGFloat = 20.0
    open var popoverType: AgoraPopoverType = .down
    open var blackOverlayColor: UIColor = UIColor(white: 0.0, alpha: 0.2)
    open var overlayBlur: UIBlurEffect?
    open var strokeColor: UIColor = UIColor.white
    open var arrowColor: UIColor = UIColor.white
    open var dismissOnBlackOverlayTap: Bool = true
    open var showBlackOverlay: Bool = true
    open var highlightFromView: Bool = false
    open var highlightCornerRadius: CGFloat = 0
    open var springDamping: CGFloat = 0.7
    open var initialSpringVelocity: CGFloat = 3
    
    // custom closure
    open var willShowHandler: (() -> ())?
    open var willDismissHandler: (() -> ())?
    open var didShowHandler: (() -> ())?
    open var didDismissHandler: (() -> ())?
    
    public fileprivate(set) var blackOverlay: UIControl = UIControl()
    
    fileprivate var containerView: UIView!
    fileprivate var contentView: UIView!
    fileprivate var contentViewFrame: CGRect!
    fileprivate var arrowShowPoint: CGPoint!
    
    public init() {
        super.init(frame: .zero)
        self.backgroundColor = .clear
        self.accessibilityViewIsModal = true
        self.layer.masksToBounds = true
    }
    
    public init(showHandler: (() -> ())?,
                dismissHandler: (() -> ())?) {
        super.init(frame: .zero)
        self.backgroundColor = .clear
        self.didShowHandler = showHandler
        self.didDismissHandler = dismissHandler
        self.accessibilityViewIsModal = true
        self.layer.masksToBounds = true
    }
    
    public init(options: [AgoraPopoverOption]?,
                showHandler: (() -> ())? = nil,
                dismissHandler: (() -> ())? = nil) {
        super.init(frame: .zero)
        self.backgroundColor = .clear
        self.setOptions(options)
        self.didShowHandler = showHandler
        self.didDismissHandler = dismissHandler
        self.accessibilityViewIsModal = true
        self.layer.masksToBounds = true
    }
    
    required public init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override open func layoutSubviews() {
        super.layoutSubviews()
        self.contentView.frame = self.bounds
        let distance = 1
        
        var y: CGFloat
        var x: CGFloat
        var width: CGFloat
        var height: CGFloat
        
        switch self.popoverType {
        case .up:
            x = CGFloat(distance)
            y = CGFloat(distance)
            width = self.bounds.width - CGFloat(distance) * 2
            height = self.bounds.height - arrowSize.height - CGFloat(distance * 2)
        case .down:
            x = CGFloat(distance)
            y = arrowSize.height + CGFloat(distance)
            width = self.bounds.width - CGFloat(distance) * 2
            height = self.bounds.height - arrowSize.height - CGFloat(distance * 2)
        case .left:
            x = CGFloat(distance)
            y = CGFloat(distance)
            width = self.bounds.width - arrowSize.width - CGFloat(distance * 2)
            height = self.bounds.height - CGFloat(distance * 2)
        case .right:
            x = CGFloat(distance)
            y = arrowSize.width + CGFloat(distance)
            width = self.bounds.width - arrowSize.width - CGFloat(distance * 2)
            height = self.bounds.height - CGFloat(distance * 2)
        }
        
        self.contentView.frame = CGRect(x: x, y: y, width: width, height: height)
        self.contentView.layer.cornerRadius = self.popCornerRadius
    }
    
    open func showAsDialog(_ contentView: UIView) {
        guard let rootView = UIApplication.shared.keyWindow else {
            return
        }
        self.showAsDialog(contentView, inView: rootView)
    }
    
    open func showAsDialog(_ contentView: UIView, inView: UIView) {
        self.arrowSize = .zero
        let point = CGPoint(x: inView.center.x,
                            y: inView.center.y - contentView.frame.height / 2)
        self.show(contentView, point: point, inView: inView)
    }
    
    open func show(_ contentView: UIView,
                   fromView: UIView) {
        guard let rootView = UIApplication.shared.keyWindow else {
            return
        }
        self.show(contentView,
                  fromView: fromView,
                  inView: rootView)
    }
    
    open func show(_ contentView: UIView,
                   fromView: UIView,
                   inView: UIView) {
        let point: CGPoint
        
//        if self.popoverType == .auto {
//            if let point = fromView.superview?.convert(fromView.frame.origin, to: nil),
//               point.y + fromView.frame.height + self.arrowSize.height + contentView.frame.height > inView.frame.height {
//                self.popoverType = .up
//            } else {
//                self.popoverType = .down
//            }
//        }
        
        switch self.popoverType {
        case .up:
            point = inView.convert(
                CGPoint(
                    x: fromView.frame.origin.x + (fromView.frame.size.width / 2),
                    y: fromView.frame.origin.y
            ), from: fromView.superview)
        case .down:
            point = inView.convert(
                CGPoint(
                    x: fromView.frame.origin.x + (fromView.frame.size.width / 2),
                    y: fromView.frame.origin.y + fromView.frame.size.height
            ), from: fromView.superview)
        case .right:
            point = inView.convert(
                CGPoint(
                    x: fromView.frame.origin.x + fromView.frame.size.width,
                    y: fromView.frame.origin.y + (fromView.frame.size.height / 2)
            ), from: fromView.superview)
        case .left:
            point = inView.convert(
                CGPoint(
                    x: fromView.frame.origin.x,
                    y: fromView.frame.origin.y + (fromView.frame.size.height / 2)
            ), from: fromView.superview)
        }
        
        if self.highlightFromView {
            self.createHighlightLayer(fromView: fromView, inView: inView)
        }
        
        self.show(contentView,
                  point: point,
                  inView: inView)
    }
    
    open func show(_ contentView: UIView, point: CGPoint) {
        guard let rootView = UIApplication.shared.keyWindow else {
            return
        }
        self.show(contentView,
                  point: point,
                  inView: rootView)
    }
    
    open func show(_ contentView: UIView,
                   point: CGPoint,
                   inView: UIView) {
        if self.dismissOnBlackOverlayTap || self.showBlackOverlay {
            self.blackOverlay.autoresizingMask = [.flexibleWidth, .flexibleHeight]
            self.blackOverlay.frame = inView.bounds
            inView.addSubview(self.blackOverlay)
            
            if showBlackOverlay {
                if let overlayBlur = self.overlayBlur {
                    let effectView = UIVisualEffectView(effect: overlayBlur)
                    effectView.frame = self.blackOverlay.bounds
                    effectView.isUserInteractionEnabled = false
                    self.blackOverlay.addSubview(effectView)
                } else {
                    if !self.highlightFromView {
                        self.blackOverlay.backgroundColor = self.blackOverlayColor
                    }
                    self.blackOverlay.alpha = 0
                }
            }
            
            if self.dismissOnBlackOverlayTap {
                self.blackOverlay.addTarget(self, action: #selector(AgoraPopover.dismiss), for: .touchUpInside)
            }
        }
        
        self.containerView = inView
        self.contentView = contentView
        self.contentView.layer.cornerRadius = self.popCornerRadius
        self.contentView.layer.masksToBounds = true
        self.arrowShowPoint = point
        self.show()
    }
    
    open override func accessibilityPerformEscape() -> Bool {
        self.dismiss()
        return true
    }
    
    @objc open func dismiss() {
        if self.superview != nil {
            self.willDismissHandler?()
            UIView.animate(withDuration: self.animationOut, delay: 0,
                           options: UIView.AnimationOptions(),
                           animations: {
                            self.transform = CGAffineTransform(scaleX: 0.0001, y: 0.0001)
                            self.blackOverlay.alpha = 0
            }){ _ in
                self.contentView.removeFromSuperview()
                self.blackOverlay.removeFromSuperview()
                self.removeFromSuperview()
                self.transform = CGAffineTransform.identity
                self.didDismissHandler?()
                
                self.delegate?.AgoraPopoverDidDismiss(self)
            }
        }
    }
    
    @objc open func dismissWithoutAnimation() {
        if self.superview != nil {
            self.willDismissHandler?()
            self.transform = CGAffineTransform(scaleX: 0.0001, y: 0.0001)
            self.blackOverlay.alpha = 0
            
            self.contentView.removeFromSuperview()
            self.blackOverlay.removeFromSuperview()
            self.removeFromSuperview()
            self.transform = CGAffineTransform.identity
            self.didDismissHandler?()
            
            self.delegate?.AgoraPopoverDidDismiss(self)
        }
    }
    
    override open func draw(_ rect: CGRect) {
        super.draw(rect)
        let stroke = UIBezierPath()
        let color = self.strokeColor
        let arrowPoint = self.containerView.convert(self.arrowShowPoint, to: self)
        
        let arrow = UIBezierPath()
        arrow.lineWidth = 1
        
        switch self.popoverType {
        case .up:
            arrow.move(to: CGPoint(x: arrowPoint.x,
                                   y: self.bounds.height + 1))

            arrow.addLine(to: CGPoint(x: arrowPoint.x + self.arrowSize.width * 0.5 - 1,
                                      y: self.bounds.height + self.arrowSize.height + 1))

            arrow.addLine(to: CGPoint(x: arrowPoint.x -  self.arrowSize.width * 0.5 + 1,
                                      y: self.bounds.height + self.arrowSize.height + 1))

            arrow.addLine(to: CGPoint(x: arrowPoint.x,
                                      y: self.bounds.height + 1))
            
            stroke.move(to: CGPoint(x: arrowPoint.x, y: self.bounds.height))
            stroke.addLine(
                to: CGPoint(
                    x: arrowPoint.x - self.arrowSize.width * 0.5,
                    y: self.isCornerLeftArrow ? self.arrowSize.height : self.bounds.height - self.arrowSize.height
                )
            )
            
            stroke.addLine(to: CGPoint(x: self.popCornerRadius, y: self.bounds.height - self.arrowSize.height))
            stroke.addArc(
                withCenter: CGPoint(
                    x: self.popCornerRadius,
                    y: self.bounds.height - self.arrowSize.height - self.popCornerRadius
                ),
                radius: self.popCornerRadius,
                startAngle: self.radians(90),
                endAngle: self.radians(180),
                clockwise: true)
            
            stroke.addLine(to: CGPoint(x: 0, y: self.popCornerRadius))
            stroke.addArc(
                withCenter: CGPoint(
                    x: self.popCornerRadius,
                    y: self.popCornerRadius
                ),
                radius: self.popCornerRadius,
                startAngle: self.radians(180),
                endAngle: self.radians(270),
                clockwise: true)
            
            stroke.addLine(to: CGPoint(x: self.bounds.width - self.popCornerRadius, y: 0))
            stroke.addArc(
                withCenter: CGPoint(
                    x: self.bounds.width - self.popCornerRadius,
                    y: self.popCornerRadius
                ),
                radius: self.popCornerRadius,
                startAngle: self.radians(270),
                endAngle: self.radians(0),
                clockwise: true)
            
            stroke.addLine(to: CGPoint(x: self.bounds.width, y: self.bounds.height - self.arrowSize.height - self.popCornerRadius))
            stroke.addArc(
                withCenter: CGPoint(
                    x: self.bounds.width - self.popCornerRadius,
                    y: self.bounds.height - self.arrowSize.height - self.popCornerRadius
                ),
                radius: self.popCornerRadius,
                startAngle: self.radians(0),
                endAngle: self.radians(90),
                clockwise: true)
            
            stroke.addLine(
                to: CGPoint(
                    x: arrowPoint.x + self.arrowSize.width * 0.5,
                    y: self.isCornerRightArrow ? self.arrowSize.height : self.bounds.height - self.arrowSize.height
                )
            )
        case .down:
            arrow.move(to: CGPoint(x: arrowPoint.x,
                                   y: 1))
            arrow.addLine(to: CGPoint(x: arrowPoint.x + self.arrowSize.width * 0.5 - 1,
                                      y: self.arrowSize.height + 1))
            
            arrow.addLine(to: CGPoint(x: arrowPoint.x -  self.arrowSize.width * 0.5 + 1,
                                      y: self.arrowSize.height + 1))
            
            arrow.addLine(to: CGPoint(x: arrowPoint.x,
                                      y: 1))
            
            stroke.move(to: CGPoint(x: arrowPoint.x, y: 0))
            stroke.addLine(
                to: CGPoint(
                    x: arrowPoint.x + self.arrowSize.width * 0.5,
                    y: self.isCornerRightArrow ? self.arrowSize.height + self.bounds.height : self.arrowSize.height
                )
            )
            
            stroke.addLine(to: CGPoint(x: self.bounds.width - self.popCornerRadius, y: self.arrowSize.height))
            stroke.addArc(
                withCenter: CGPoint(
                    x: self.bounds.width - self.popCornerRadius,
                    y: self.arrowSize.height + self.popCornerRadius
                ),
                radius: self.popCornerRadius,
                startAngle: self.radians(270.0),
                endAngle: self.radians(0),
                clockwise: true)
            
            stroke.addLine(to: CGPoint(x: self.bounds.width, y: self.bounds.height - self.popCornerRadius))
            stroke.addArc(
                withCenter: CGPoint(
                    x: self.bounds.width - self.popCornerRadius,
                    y: self.bounds.height - self.popCornerRadius
                ),
                radius: self.popCornerRadius,
                startAngle: self.radians(0),
                endAngle: self.radians(90),
                clockwise: true)
            
            stroke.addLine(to: CGPoint(x: 0, y: self.bounds.height))
            stroke.addArc(
                withCenter: CGPoint(
                    x: self.popCornerRadius,
                    y: self.bounds.height - self.popCornerRadius
                ),
                radius: self.popCornerRadius,
                startAngle: self.radians(90),
                endAngle: self.radians(180),
                clockwise: true)
            
            stroke.addLine(to: CGPoint(x: 0, y: self.arrowSize.height + self.popCornerRadius))
            stroke.addArc(
                withCenter: CGPoint(
                    x: self.popCornerRadius,
                    y: self.arrowSize.height + self.popCornerRadius
                ),
                radius: self.popCornerRadius,
                startAngle: self.radians(180),
                endAngle: self.radians(270),
                clockwise: true)
            
            stroke.addLine(to: CGPoint(
                x: arrowPoint.x - self.arrowSize.width * 0.5,
                y: self.isCornerLeftArrow ? self.arrowSize.height + self.bounds.height : self.arrowSize.height))
            
        case .left:
            break
        case .right:
            stroke.move(to: CGPoint(x: 0, y: arrowPoint.y))
            stroke.addLine(
                to: CGPoint(
                    x: self.arrowSize.height,
                    y: arrowPoint.y - (self.arrowSize.width / 2)
                )
            )
            
            stroke.addLine(to: CGPoint(x: self.arrowSize.height, y: self.popCornerRadius))
            stroke.addArc(
                withCenter: CGPoint(
                    x: self.arrowSize.height + self.popCornerRadius,
                    y: self.popCornerRadius
                ),
                radius: self.popCornerRadius,
                startAngle: self.radians(180),
                endAngle: self.radians(270),
                clockwise: true)
            
            stroke.addLine(to: CGPoint(x: self.bounds.width - self.popCornerRadius, y: 0))
            stroke.addArc(
                withCenter: CGPoint(
                    x: self.bounds.width - self.popCornerRadius,
                    y: self.popCornerRadius
                ),
                radius: self.popCornerRadius,
                startAngle: self.radians(270),
                endAngle: self.radians(0),
                clockwise: true)
            
            stroke.addLine(to: CGPoint(x: self.bounds.width, y: self.bounds.height - self.popCornerRadius))
            stroke.addArc(
                withCenter: CGPoint(
                    x: self.bounds.width - self.popCornerRadius,
                    y: self.bounds.height - self.popCornerRadius
                ),
                radius: self.popCornerRadius,
                startAngle: self.radians(0),
                endAngle: self.radians(90),
                clockwise: true)
            
            stroke.addLine(to: CGPoint(x: self.arrowSize.height + self.popCornerRadius, y: self.bounds.height))
            stroke.addArc(
                withCenter: CGPoint(
                    x: self.arrowSize.height + self.popCornerRadius,
                    y: self.bounds.height - self.popCornerRadius
                ),
                radius: self.popCornerRadius,
                startAngle: self.radians(90),
                endAngle: self.radians(180),
                clockwise: true)
            
            stroke.addLine(
                to: CGPoint(
                    x: self.arrowSize.height,
                    y: arrowPoint.y + (self.arrowSize.width / 2)
                )
            )
        }
        
        color.setFill()
        stroke.fill()
        
        arrowColor.setFill()
        arrow.fill()
    }
}

private extension AgoraPopover {
    func setOptions(_ options: [AgoraPopoverOption]?){
        if let options = options {
            for option in options {
                switch option {
                case let .arrowSize(value):
                    self.arrowSize = value
                case let .animationIn(value):
                    self.animationIn = value
                case let .animationOut(value):
                    self.animationOut = value
                case let .cornerRadius(value):
                    self.popCornerRadius = value
                case let .sideEdge(value):
                    self.sideEdge = value
                case let .blackOverlayColor(value):
                    self.blackOverlayColor = value
                case let .overlayBlur(style):
                    self.overlayBlur = UIBlurEffect(style: style)
                case let .type(value):
                    self.popoverType = value
                case let .color(value):
                    self.strokeColor = value
                case let .dismissOnBlackOverlayTap(value):
                    self.dismissOnBlackOverlayTap = value
                case let .showBlackOverlay(value):
                    self.showBlackOverlay = value
                case let .springDamping(value):
                    self.springDamping = value
                case let .initialSpringVelocity(value):
                    self.initialSpringVelocity = value
                }
            }
        }
    }
    
    func create() {
        var frame = self.contentView.frame
        frame.origin.x = self.arrowShowPoint.x - frame.size.width * 0.5
        
        var sideEdge: CGFloat = 0.0
        if frame.size.width < self.containerView.frame.size.width {
            sideEdge = self.sideEdge
        }
        
        let outerSideEdge = frame.maxX - self.containerView.bounds.size.width
        if outerSideEdge > 0 {
            frame.origin.x -= (outerSideEdge + sideEdge)
        } else {
            if frame.minX < 0 {
                frame.origin.x += abs(frame.minX) + sideEdge
            }
        }
        self.frame = frame
        
        let arrowPoint = self.containerView.convert(self.arrowShowPoint, to: self)
        var anchorPoint: CGPoint
        switch self.popoverType {
        case .up:
            frame.origin.x = self.arrowShowPoint.x - frame.size.width * 0.5
            frame.origin.y = self.arrowShowPoint.y - frame.height - self.arrowSize.height
            anchorPoint = CGPoint(x: arrowPoint.x / frame.size.width, y: 1)
        case .down:
            frame.origin.x = self.arrowShowPoint.x - frame.size.width * 0.5
            frame.origin.y = self.arrowShowPoint.y
            anchorPoint = CGPoint(x: arrowPoint.x / frame.size.width, y: 0)
        case .left:
            frame.origin.x = self.arrowShowPoint.x + frame.width + self.arrowSize.height
            anchorPoint = CGPoint(x: arrowPoint.x / frame.size.width, y: 0)
        case .right:
            frame.origin.y = self.arrowShowPoint.y - frame.size.height * 0.5
            frame.origin.x = self.arrowShowPoint.x
            anchorPoint = CGPoint(x: 1, y: arrowPoint.y / frame.size.height)
        }
        
        if self.arrowSize == .zero {
            anchorPoint = CGPoint(x: 0.5, y: 0.5)
        }
        
        let lastAnchor = self.layer.anchorPoint
        self.layer.anchorPoint = anchorPoint
        let x = self.layer.position.x + (anchorPoint.x - lastAnchor.x) * self.layer.bounds.size.width
        let y = self.layer.position.y + (anchorPoint.y - lastAnchor.y) * self.layer.bounds.size.height
        self.layer.position = CGPoint(x: x, y: y)

        frame.size.height += self.arrowSize.height
        self.frame = frame
    }
    
    func createHighlightLayer(fromView: UIView, inView: UIView) {
        let path = UIBezierPath(rect: inView.bounds)
        let highlightRect = inView.convert(fromView.frame, from: fromView.superview)
        let highlightPath = UIBezierPath(roundedRect: highlightRect, cornerRadius: self.highlightCornerRadius)
        path.append(highlightPath)
        path.usesEvenOddFillRule = true
        
        let fillLayer = CAShapeLayer()
        fillLayer.path = path.cgPath
        fillLayer.fillRule = CAShapeLayerFillRule.evenOdd
        fillLayer.fillColor = self.blackOverlayColor.cgColor
        self.blackOverlay.layer.addSublayer(fillLayer)
    }
    
    func show() {
        self.setNeedsDisplay()
        switch self.popoverType {
        case .up:
            self.contentView.frame.origin.y = 0.0
        case .down:
            self.contentView.frame.origin.y = self.arrowSize.height
        case .right:
            self.contentView.frame.origin.x = self.arrowSize.height
        case .left:
            self.contentView.frame.origin.x = 0
        }
        
        self.addSubview(self.contentView)
        self.containerView.addSubview(self)
        
        self.create()
        self.transform = CGAffineTransform(scaleX: 0.0, y: 0.0)
        self.willShowHandler?()
        UIView.animate(
            withDuration: self.animationIn,
            delay: 0,
            usingSpringWithDamping: self.springDamping,
            initialSpringVelocity: self.initialSpringVelocity,
            options: UIView.AnimationOptions(),
            animations: {
                self.transform = CGAffineTransform.identity
        }){ _ in
            self.didShowHandler?()
        }
        UIView.animate(
            withDuration: self.animationIn / 3,
            delay: 0,
            options: .curveLinear,
            animations: {
                self.blackOverlay.alpha = 1
        }, completion: nil)
    }
    
    var isCornerLeftArrow: Bool {
        return self.arrowShowPoint.x == self.frame.origin.x
    }
    
    var isCornerRightArrow: Bool {
        return self.arrowShowPoint.x == self.frame.origin.x + self.bounds.width
    }
    
    func radians(_ degrees: CGFloat) -> CGFloat {
        return CGFloat.pi * degrees / 180
    }
}
