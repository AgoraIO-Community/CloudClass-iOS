//
//  AgoraBaseButton.swift
//  AgoraEduSDK
//
//  Created by SRS on 2021/1/27.
//

import UIKit

@objcMembers public class AgoraBaseButton: UIButton {
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
   
    var id : Int {
        set {
            self.tag = newValue
        }
        get {
            return self.tag
        }
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.translatesAutoresizingMaskIntoConstraints = false
    }
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func clearConstraint() {
        self.removeConstraints(self.constraints)
    }

    deinit {
    }
}

// MARK: Rect
extension AgoraBaseButton {
    
    func move(_ x: CGFloat, _ y: CGFloat) -> AgoraBaseButton {
        self.x = x
        self.y = y
        return self
    }
    
    func resize(_ width: CGFloat, _ height: CGFloat) -> AgoraBaseButton {
        self.width = width
        self.height = height
        return self
    }
    
    func close() {
        self.removeFromSuperview()
    }
}

