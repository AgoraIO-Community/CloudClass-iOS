//
//  AgoraBaseView.swift
//  AgoraEduSDK
//
//  Created by SRS on 2021/1/27.
//

import UIKit

@objcMembers public class AgoraBaseView: UIView {
    public var x: CGFloat = 0 {
        didSet {
            assert(self.superview != nil, "can not found superview")
            self.leftAnchor.constraint(equalTo: self.superview!.leftAnchor, constant: x).isActive = true
        }
    }
    public var y: CGFloat = 0 {
        didSet {
            assert(self.superview != nil, "can not found superview")
            self.topAnchor.constraint(equalTo: self.superview!.topAnchor, constant: y).isActive = true
        }
    }
    public var width: CGFloat = 0 {
        didSet {
            self.widthAnchor.constraint(equalToConstant: width).isActive = true
        }
    }
    public var height: CGFloat = 0 {
        didSet {
            self.heightAnchor.constraint(equalToConstant: height).isActive = true
        }
    }
    public var right: CGFloat = 0 {
        didSet {
            assert(self.superview != nil, "can not found superview")
            self.rightAnchor.constraint(equalTo: self.superview!.rightAnchor, constant: -right).isActive = true
        }
    }
    public var bottom: CGFloat = 0 {
        didSet {
            assert(self.superview != nil, "can not found superview")
            self.bottomAnchor.constraint(equalTo: self.superview!.bottomAnchor, constant: -bottom).isActive = true
        }
    }
    var z : Int = 0 {
        didSet {
            assert(self.superview != nil, "can not found superview")
            self.superview!.insertSubview(self, at: z)
        }
    }
    var isDraggable : Bool = false {
        willSet {
            if (newValue) {
                self.addGestureRecognizer(self.pan)
            } else if (isDraggable) {
                self.removeGestureRecognizer(self.pan)
            }
        }
    }
    var isResizable : Bool = false {
        willSet {
            if (newValue) {
                self.addGestureRecognizer(self.pinch)
            } else if (isResizable) {
                self.removeGestureRecognizer(self.pinch)
            }
        }
    }
    var id : Int {
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
    
    func hasTransformed() -> Bool {
        return self.hasScaled() || self.hasScaled()
    }
    
    func resetTransform() {
        self.transform = CGAffineTransform(scaleX: 1.0 / self.totalScale, y: 1.0 / self.totalScale)
        self.totalScale = 1.0
        
        self.transform = CGAffineTransform(translationX: -self.transform.tx, y: -self.transform.ty)
    }
    
    func clearConstraint() {
        self.removeConstraints(self.constraints)
    }

    deinit {
        if (self.isDraggable) {
            self.removeGestureRecognizer(self.pan)
        }
        if (self.isResizable) {
            self.removeGestureRecognizer(self.pinch)
        }
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
    
    func move(_ x: CGFloat, _ y: CGFloat) -> AgoraBaseView {
        self.x = x
        self.y = y
        return self
    }
    
    func resize(_ width: CGFloat, _ height: CGFloat) -> AgoraBaseView {
        self.width = width
        self.height = height
        return self
    }
    
    func close() {
        self.removeFromSuperview()
    }
}
