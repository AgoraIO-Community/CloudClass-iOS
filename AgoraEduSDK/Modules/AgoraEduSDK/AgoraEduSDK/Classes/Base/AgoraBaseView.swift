//
//  AgoraBaseView.swift
//  AgoraEduSDK
//
//  Created by SRS on 2021/1/27.
//

import UIKit

@objcMembers public class AgoraBaseView: UIView {
    fileprivate var agoraConstraints: [NSLayoutConstraint] = []
    
    public var x: CGFloat = 0 {
        didSet {
            assert(self.superview != nil, "can not found superview")
            if let constraint = self.constraint(Constraint_Id_X, agoraConstraints) {
                constraint.constant = x
                constraint.isActive = true
            } else {
                let constraint = self.leftAnchor.constraint(equalTo: self.superview!.leftAnchor, constant: x)
                constraint.identifier = Constraint_Id_X
                constraint.isActive = true
                agoraConstraints.append(constraint)
            }
        }
    }
    public var centerX: CGFloat = 0 {
        didSet {
            assert(self.superview != nil, "can not found superview")
            if let constraint = self.constraint(Constraint_Id_CenterX, agoraConstraints) {
                constraint.constant = centerX
                constraint.isActive = true
            } else {
                let constraint = self.centerXAnchor.constraint(equalTo: self.superview!.centerXAnchor, constant: centerX)
                constraint.identifier = Constraint_Id_CenterX
                constraint.isActive = true
                agoraConstraints.append(constraint)
            }
        }
    }
    public var y: CGFloat = 0 {
        didSet {
            assert(self.superview != nil, "can not found superview")
            if let constraint = self.constraint(Constraint_Id_Y, agoraConstraints) {
                constraint.constant = y
                constraint.isActive = true
            } else {
                let constraint = self.topAnchor.constraint(equalTo: self.superview!.topAnchor, constant: y)
                constraint.identifier = Constraint_Id_Y
                constraint.isActive = true
                agoraConstraints.append(constraint)
            }
        }
    }
    public var centerY: CGFloat = 0 {
        didSet {
            assert(self.superview != nil, "can not found superview")
            if let constraint = self.constraint(Constraint_Id_CenterY, agoraConstraints) {
                constraint.constant = centerY
                constraint.isActive = true
            } else {
                let constraint = self.centerYAnchor.constraint(equalTo: self.superview!.centerYAnchor, constant: centerY)
                constraint.identifier = Constraint_Id_CenterY
                constraint.isActive = true
                agoraConstraints.append(constraint)
            }
        }
    }
    public var width: CGFloat = 0 {
        didSet {
            if let constraint = self.constraint(Constraint_Id_Width, agoraConstraints) {
                constraint.constant = width
                constraint.isActive = true
            } else {
                let constraint = self.widthAnchor.constraint(equalToConstant: width)
                constraint.identifier = Constraint_Id_Width
                constraint.isActive = true
                agoraConstraints.append(constraint)
            }
        }
    }
    public var height: CGFloat = 0 {
        didSet {
            if let constraint = self.constraint(Constraint_Id_Height, agoraConstraints) {
                constraint.constant = height
                constraint.isActive = true
            } else {
                let constraint = self.heightAnchor.constraint(equalToConstant: height)
                constraint.identifier = Constraint_Id_Height
                constraint.isActive = true
                agoraConstraints.append(constraint)
            }
        }
    }
    public var right: CGFloat = 0 {
        didSet {
            assert(self.superview != nil, "can not found superview")
            if let constraint = self.constraint(Constraint_Id_Right, agoraConstraints) {
                constraint.constant = -right
                constraint.isActive = true
            } else {
                let constraint = self.rightAnchor.constraint(equalTo: self.superview!.rightAnchor, constant: -right)
                constraint.identifier = Constraint_Id_Right
                constraint.isActive = true
                agoraConstraints.append(constraint)
            }
        }
    }
    public var bottom: CGFloat = 0 {
        didSet {
            assert(self.superview != nil, "can not found superview")
            if let constraint = self.constraint(Constraint_Id_Bottom, agoraConstraints) {
                constraint.constant = -bottom
                constraint.isActive = true
            } else {
                let constraint = self.bottomAnchor.constraint(equalTo: self.superview!.bottomAnchor, constant: -bottom)
                constraint.identifier = Constraint_Id_Bottom
                constraint.isActive = true
                agoraConstraints.append(constraint)
            }
        }
    }
    public var safeX: CGFloat = 0 {
        didSet {
            assert(self.superview != nil, "can not found superview")
            if let constraint = self.constraint(Constraint_Id_SafeX, agoraConstraints) {
                constraint.constant = safeX
                constraint.isActive = true
            } else {
                if #available(iOS 11.0, *) {
                    let constraint = self.leftAnchor.constraint(equalTo: self.superview!.safeAreaLayoutGuide.leftAnchor, constant: safeX)
                    constraint.identifier = Constraint_Id_SafeX
                    constraint.isActive = true
                    agoraConstraints.append(constraint)
                } else {
                    // Fallback on earlier versions
                }
            }
        }
    }
    public var safeY: CGFloat = 0 {
        didSet {
            assert(self.superview != nil, "can not found superview")
            if let constraint = self.constraint(Constraint_Id_SafeY, agoraConstraints) {
                constraint.constant = safeY
                constraint.isActive = true
            } else {
                if #available(iOS 11.0, *) {
                    let constraint = self.topAnchor.constraint(equalTo: self.superview!.safeAreaLayoutGuide.topAnchor, constant: safeY)
                    constraint.identifier = Constraint_Id_SafeY
                    constraint.isActive = true
                    agoraConstraints.append(constraint)
                } else {
                    // Fallback on earlier versions
                }
            }
        }
    }
    public var safeRight: CGFloat = 0 {
        didSet {
            assert(self.superview != nil, "can not found superview")
            if let constraint = self.constraint(Constraint_Id_SafeRight, agoraConstraints) {
                constraint.constant = -safeRight
                constraint.isActive = true
            } else {
                if #available(iOS 11.0, *) {
                    let constraint = self.rightAnchor.constraint(equalTo: self.superview!.safeAreaLayoutGuide.rightAnchor, constant: -safeRight)
                    constraint.identifier = Constraint_Id_SafeRight
                    constraint.isActive = true
                    agoraConstraints.append(constraint)
                } else {
                    // Fallback on earlier versions
                }
            }
        }
    }
    public var safeBottom: CGFloat = 0 {
        didSet {
            assert(self.superview != nil, "can not found superview")
            if let constraint = self.constraint(Constraint_Id_SafeBottom, agoraConstraints) {
                constraint.constant = -safeBottom
                constraint.isActive = true
            } else {
                if #available(iOS 11.0, *) {
                    let constraint = self.bottomAnchor.constraint(equalTo: self.superview!.safeAreaLayoutGuide.bottomAnchor, constant: -safeBottom)
                    constraint.identifier = Constraint_Id_SafeBottom
                    constraint.isActive = true
                    agoraConstraints.append(constraint)
                } else {
                    // Fallback on earlier versions
                }
            }
        }
    }
    public var z : Int = 0 {
        didSet {
            assert(self.superview != nil, "can not found superview")
            self.superview!.insertSubview(self, at: z)
        }
    }
    public var isDraggable : Bool = false {
        willSet {
            if (newValue) {
                self.addGestureRecognizer(self.pan)
            } else if (isDraggable) {
                self.removeGestureRecognizer(self.pan)
            }
        }
    }
    public var isResizable : Bool = false {
        willSet {
            if (newValue) {
                self.addGestureRecognizer(self.pinch)
            } else if (isResizable) {
                self.removeGestureRecognizer(self.pinch)
            }
        }
    }
    public var id : Int {
        set {
            self.tag = newValue
        }
        get {
            return self.tag
        }
    }
    
    fileprivate let FloatDiffer: Float = 0.001
    fileprivate var totalScale : CGFloat = 1.0
    fileprivate lazy var pan: UIPanGestureRecognizer = {
        let panGesture = UIPanGestureRecognizer(target: self, action: #selector(onPanEvent(_ :)))
        return panGesture
    }()
    fileprivate lazy var pinch: UIPinchGestureRecognizer = {
        let pinchGesture = UIPinchGestureRecognizer(target: self, action: #selector(onPinchEvent(_ :)))
        return pinchGesture
    }()

    override init(frame: CGRect) {
        super.init(frame: frame)
        self.translatesAutoresizingMaskIntoConstraints = false
    }
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    public func hasTransformed() -> Bool {
        return self.hasScaled() || self.hasScaled()
    }
    
    public func resetTransform() {
        self.transform = CGAffineTransform(scaleX: 1.0 / self.totalScale, y: 1.0 / self.totalScale)
        self.totalScale = 1.0
        
        self.transform = CGAffineTransform(translationX: -self.transform.tx, y: -self.transform.ty)
    }
    
    public func clearConstraint() {
        for constraint in self.agoraConstraints {
            constraint.isActive = false
        }
    }

    deinit {
        if (self.isDraggable) {
            self.removeGestureRecognizer(self.pan)
        }
        if (self.isResizable) {
            self.removeGestureRecognizer(self.pinch)
        }
        
        self.agoraConstraints.removeAll()
    }
}

// MARK: GestureRecognizer
extension AgoraBaseView {
    @objc fileprivate func onPanEvent(_ pan: UIPanGestureRecognizer) {

        let transP = pan.translation(in: self)
        self.transform = CGAffineTransform(translationX: transP.x, y: transP.y)
        pan.setTranslation(CGPoint.zero, in: self)
    }

    @objc fileprivate func onPinchEvent(_ pinch: UIPinchGestureRecognizer) {
        
        if (pinch.state == .began || pinch.state == .changed) {
            let scale = pinch.scale
            self.transform = CGAffineTransform(scaleX: scale, y: scale)
            pinch.scale = 1
            self.totalScale *= scale
        }
    }
    
    fileprivate func hasScaled() -> Bool {
        if (abs(Float(self.totalScale - 1.0)) <= FloatDiffer) {
            return false
        }
        return true
    }
    
    fileprivate func hasMoved() -> Bool {
        if (abs(Float(self.transform.tx)) <= FloatDiffer && abs(Float(self.transform.ty)) <= FloatDiffer) {
            return false
        }
        return true
    }
}

// MARK: Rect
extension AgoraBaseView {
    
    public func move(_ x: CGFloat, _ y: CGFloat) -> AgoraBaseView {
        self.x = x
        self.y = y
        return self
    }
    
    public func resize(_ width: CGFloat, _ height: CGFloat) -> AgoraBaseView {
        self.width = width
        self.height = height
        return self
    }
    
    public func close() {
        self.removeFromSuperview()
    }
}

