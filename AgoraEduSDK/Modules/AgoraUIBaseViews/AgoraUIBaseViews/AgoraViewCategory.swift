//
//  AgoraViewCategory.swift
//  ApaasTest
//
//  Created by Cavan on 2021/1/31.
//

import UIKit

public var Agora_Constraint_Id_X = "Agora_Constraint_Id_X"
public var Agora_Constraint_Id_Y = "Agora_Constraint_Id_Y"
public var Agora_Constraint_Id_Center_X = "Agora_Constraint_Id_Center_X"
public var Agora_Constraint_Id_Center_Y = "Agora_Constraint_Id_Center_Y"
public var Agora_Constraint_Id_Width = "Agora_Constraint_Id_Width"
public var Agora_Constraint_Id_Height = "Agora_Constraint_Id_Height"
public var Agora_Constraint_Id_Right = "Agora_Constraint_Id_Right"
public var Agora_Constraint_Id_Bottom = "Agora_Constraint_Id_Bottom"

public var Agora_Constraint_Id_Safe_X = "Agora_Constraint_Id_Safe_X"
public var Agora_Constraint_Id_Safe_Y = "Agora_Constraint_Id_Safe_Y"
public var Agora_Constraint_Id_Safe_Right = "Agora_Constraint_Id_Safe_Right"
public var Agora_Constraint_Id_Safe_Bottom = "Agora_Constraint_Id_Safe_Bottom"

fileprivate var Agora_Constraints_Key: NSString = "agora_constraints"

fileprivate var Agora_X_Key: NSString = "agora_x"
fileprivate var Agora_Y_Key: NSString = "agora_y"
fileprivate var Agora_Z_Key: NSString = "agora_z"

fileprivate var Agora_Safe_X_Key: NSString = "agora_safe_x"
fileprivate var Agora_Safe_Y_Key: NSString = "agora_safe_y"
fileprivate var Agora_Safe_Left_Key: NSString = "agora_safe_left"
fileprivate var Agora_Safe_Right_Key: NSString = "agora_safe_right"
fileprivate var Agora_Safe_Top_Key: NSString = "agora_safe_top"
fileprivate var Agora_Safe_Bottom_Key: NSString = "agora_safe_bottom"

fileprivate var Agora_Width_Key: NSString = "agora_width"
fileprivate var Agora_Height_Key: NSString = "agora_height"

fileprivate var Agora_Center_X_Key: NSString = "agora_center_x"
fileprivate var Agora_Center_Y_Key: NSString = "agora_center_y"

fileprivate var Agora_Left_Key: NSString = "agora_left"
fileprivate var Agora_Right_Key: NSString = "agora_right"
fileprivate var Agora_Top_Key: NSString = "agora_top"
fileprivate var Agora_Bottom_Key: NSString = "agora_bottom"
fileprivate var Agora_Pan_Limit_Key: NSString = "agora_pan_limit"

fileprivate var Agora_Total_Scale_Key: NSString = "agora_total_scale"

fileprivate var Agora_Is_Draggable_Key: NSString = "agora_is_draggable"
fileprivate var Agora_Is_Resizable_Key: NSString = "agora_is_resizable"

fileprivate var Agora_Pan_Gesture_Key: NSString = "agora_pan"
fileprivate var Agora_Pinch_Gesture_Key: NSString = "agora_pinch"

fileprivate let Agora_Float_Differ: Float = 0.001

// MARK: - Properties
@objc public extension UIView {
    var agora_x: CGFloat {
        set {
            objc_setAssociatedObject(self,
                                     &Agora_X_Key,
                                     newValue,
                                     .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
            
            assert(self.superview != nil, "can not found superview")
            if let constraint = self.agora_constraint(Agora_Constraint_Id_X, agora_constraints) {
                constraint.constant = newValue
                constraint.isActive = true
            } else {
                let constraint = self.leftAnchor.constraint(equalTo: self.superview!.leftAnchor,
                                                            constant: newValue)
                constraint.identifier = Agora_Constraint_Id_X
                constraint.isActive = true
                agora_constraints.add(constraint)
            }
        }
        
        get {
            let v = objc_getAssociatedObject(self,
                                             &Agora_X_Key)
            
            if let value = v as? CGFloat {
                return value
            } else {
                return 0
            }
        }
    }
    
    var agora_y: CGFloat {
        set {
            objc_setAssociatedObject(self,
                                     &Agora_Y_Key,
                                     newValue,
                                     .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
            
            assert(self.superview != nil, "can not found superview")
            if let constraint = self.agora_constraint(Agora_Constraint_Id_Y, agora_constraints) {
                constraint.constant = newValue
                constraint.isActive = true
            } else {
                let constraint = self.topAnchor.constraint(equalTo: self.superview!.topAnchor,
                                                           constant: newValue)
                constraint.identifier = Agora_Constraint_Id_Y
                constraint.isActive = true
                agora_constraints.add(constraint)
            }
        }
        
        get {
            let v = objc_getAssociatedObject(self,
                                             &Agora_Y_Key)
            
            if let value = v as? CGFloat {
                return value
            } else {
                return 0
            }
        }
    }
    
    var agora_z: Int {
        set {
            objc_setAssociatedObject(self,
                                     &Agora_Z_Key,
                                     newValue,
                                     .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
            
            assert(self.superview != nil, "can not found superview")
            self.superview!.insertSubview(self, at: newValue)
        }
        
        get {
            let v = objc_getAssociatedObject(self,
                                             &Agora_Z_Key)
            
            if let value = v as? Int {
                return value
            } else {
                return 0
            }
        }
    }
    
    var agora_safe_x: CGFloat {
        set {
            objc_setAssociatedObject(self,
                                     &Agora_Safe_X_Key,
                                     newValue,
                                     .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
            
            assert(self.superview != nil, "can not found superview")
            if let constraint = self.agora_constraint(Agora_Constraint_Id_Safe_X, agora_constraints) {
                constraint.constant = newValue
                constraint.isActive = true
            } else {
                if #available(iOS 11.0, *) {
                    let constraint = self.leftAnchor.constraint(equalTo: self.superview!.safeAreaLayoutGuide.leftAnchor,
                                                                constant: newValue)
                    constraint.identifier = Agora_Constraint_Id_Safe_X
                    constraint.isActive = true
                    agora_constraints.add(constraint)
                } else {
                    self.agora_x = newValue
                }
            }
        }
        
        get {
            let v = objc_getAssociatedObject(self,
                                             &Agora_Safe_X_Key)
            
            if let value = v as? CGFloat {
                return value
            } else {
                return 0
            }
        }
    }
    
    var agora_safe_y: CGFloat {
        set {
            objc_setAssociatedObject(self,
                                     &Agora_Safe_Y_Key,
                                     newValue,
                                     .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
            
            assert(self.superview != nil, "can not found superview")
            if let constraint = self.agora_constraint(Agora_Constraint_Id_Safe_Y, agora_constraints) {
                constraint.constant = newValue
                constraint.isActive = true
            } else {
                if #available(iOS 11.0, *) {
                    let constraint = self.topAnchor.constraint(equalTo: self.superview!.safeAreaLayoutGuide.topAnchor,
                                                               constant: newValue)
                    constraint.identifier = Agora_Constraint_Id_Safe_Y
                    constraint.isActive = true
                    agora_constraints.add(constraint)
                } else {
                    self.agora_y = newValue
                }
            }
        }
        
        get {
            let v = objc_getAssociatedObject(self,
                                             &Agora_Safe_Y_Key)
            
            if let value = v as? CGFloat {
                return value
            } else {
                return 0
            }
        }
    }
    
    var agora_safe_right: CGFloat {
        set {
            objc_setAssociatedObject(self,
                                     &Agora_Safe_Right_Key,
                                     newValue,
                                     .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
            
            assert(self.superview != nil, "can not found superview")
            if let constraint = self.agora_constraint(Agora_Constraint_Id_Safe_Right, agora_constraints) {
                constraint.constant = -newValue
                constraint.isActive = true
            } else {
                if #available(iOS 11.0, *) {
                    let constraint = self.rightAnchor.constraint(equalTo: self.superview!.safeAreaLayoutGuide.rightAnchor,
                                                                 constant: -newValue)
                    constraint.identifier = Agora_Constraint_Id_Safe_Right
                    constraint.isActive = true
                    agora_constraints.add(constraint)
                } else {
                    self.agora_right = newValue
                }
            }
        }
        
        get {
            let v = objc_getAssociatedObject(self,
                                             &Agora_Safe_Right_Key)
            
            if let value = v as? CGFloat {
                return value
            } else {
                return 0
            }
        }
    }
    
    var agora_safe_bottom: CGFloat {
        set {
            objc_setAssociatedObject(self,
                                     &Agora_Safe_Bottom_Key,
                                     newValue,
                                     .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
            
            assert(self.superview != nil, "can not found superview")
            if let constraint = self.agora_constraint(Agora_Constraint_Id_Safe_Bottom, agora_constraints) {
                constraint.constant = -newValue
                constraint.isActive = true
            } else {
                if #available(iOS 11.0, *) {
                    let constraint = self.bottomAnchor.constraint(equalTo: self.superview!.safeAreaLayoutGuide.bottomAnchor, constant: -newValue)
                    constraint.identifier = Agora_Constraint_Id_Safe_Bottom
                    constraint.isActive = true
                    agora_constraints.add(constraint)
                } else {
                    self.agora_bottom = newValue
                }
            }
        }
        
        get {
            let v = objc_getAssociatedObject(self,
                                             &Agora_Safe_Bottom_Key)
            
            if let value = v as? CGFloat {
                return value
            } else {
                return 0
            }
        }
    }
    
    var agora_width: CGFloat {
        set {
            objc_setAssociatedObject(self,
                                     &Agora_Width_Key,
                                     newValue,
                                     .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
            
            if let constraint = self.agora_constraint(Agora_Constraint_Id_Width, agora_constraints) {
                constraint.constant = newValue
                constraint.isActive = true
            } else {
                let constraint = self.widthAnchor.constraint(equalToConstant: newValue)
                constraint.identifier = Agora_Constraint_Id_Width
                constraint.isActive = true
                agora_constraints.add(constraint)
            }
        }
        
        get {
            let v = objc_getAssociatedObject(self,
                                             &Agora_Width_Key)
            
            if let value = v as? CGFloat {
                return value
            } else {
                return 0
            }
        }
    }
    
    var agora_height: CGFloat {
        set {
            objc_setAssociatedObject(self,
                                     &Agora_Height_Key,
                                     newValue,
                                     .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
            
            if let constraint = self.agora_constraint(Agora_Constraint_Id_Height, agora_constraints) {
                constraint.constant = newValue
                constraint.isActive = true
            } else {
                let constraint = self.heightAnchor.constraint(equalToConstant: newValue)
                constraint.identifier = Agora_Constraint_Id_Height
                constraint.isActive = true
                agora_constraints.add(constraint)
            }
        }
        
        get {
            let v = objc_getAssociatedObject(self,
                                             &Agora_Height_Key)
            
            if let value = v as? CGFloat {
                return value
            } else {
                return 0
            }
        }
    }
    
    var agora_center_x: CGFloat {
        set {
            objc_setAssociatedObject(self,
                                     &Agora_Center_X_Key,
                                     newValue,
                                     .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
            
            assert(self.superview != nil, "can not found superview")
            if let constraint = self.agora_constraint(Agora_Constraint_Id_Center_X, agora_constraints) {
                constraint.constant = newValue
                constraint.isActive = true
            } else {
                let constraint = self.centerXAnchor.constraint(equalTo: self.superview!.centerXAnchor,
                                                               constant: newValue)
                constraint.identifier = Agora_Constraint_Id_Center_X
                constraint.isActive = true
                agora_constraints.add(constraint)
            }
        }
        
        get {
            let v = objc_getAssociatedObject(self,
                                             &Agora_Center_X_Key)
            
            if let value = v as? CGFloat {
                return value
            } else {
                return 0
            }
        }
    }
    
    var agora_center_y: CGFloat {
        set {
            objc_setAssociatedObject(self,
                                     &Agora_Center_Y_Key,
                                     newValue,
                                     .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
            
            assert(self.superview != nil, "can not found superview")
            if let constraint = self.agora_constraint(Agora_Constraint_Id_Center_Y, agora_constraints) {
                constraint.constant = newValue
                constraint.isActive = true
            } else {
                let constraint = self.centerYAnchor.constraint(equalTo: self.superview!.centerYAnchor,
                                                               constant: newValue)
                constraint.identifier = Agora_Constraint_Id_Center_Y
                constraint.isActive = true
                agora_constraints.add(constraint)
            }
        }
        
        get {
            let v = objc_getAssociatedObject(self,
                                             &Agora_Center_Y_Key)
            
            if let value = v as? CGFloat {
                return value
            } else {
                return 0
            }
        }
    }
    
    var agora_right: CGFloat {
        set {
            objc_setAssociatedObject(self,
                                     &Agora_Right_Key,
                                     newValue,
                                     .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
            
            assert(self.superview != nil, "can not found superview")
            if let constraint = self.agora_constraint(Agora_Constraint_Id_Right, agora_constraints) {
                constraint.constant = -newValue
                constraint.isActive = true
            } else {
                let constraint = self.rightAnchor.constraint(equalTo: self.superview!.rightAnchor,
                                                             constant: -newValue)
                constraint.identifier = Agora_Constraint_Id_Right
                constraint.isActive = true
                agora_constraints.add(constraint)
            }
        }
        
        get {
            let v = objc_getAssociatedObject(self,
                                             &Agora_Right_Key)
            
            if let value = v as? CGFloat {
                return value
            } else {
                return 0
            }
        }
    }
    
    var agora_bottom: CGFloat {
        set {
            objc_setAssociatedObject(self,
                                     &Agora_Bottom_Key,
                                     newValue,
                                     .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
            
            assert(self.superview != nil, "can not found superview")
            if let constraint = self.agora_constraint(Agora_Constraint_Id_Bottom, agora_constraints) {
                constraint.constant = -newValue
                constraint.isActive = true
            } else {
                let constraint = self.bottomAnchor.constraint(equalTo: self.superview!.bottomAnchor,
                                                              constant: -newValue)
                constraint.identifier = Agora_Constraint_Id_Bottom
                constraint.isActive = true
                agora_constraints.add(constraint)
            }
        }
        
        get {
            let v = objc_getAssociatedObject(self,
                                             &Agora_Bottom_Key)
            
            if let value = v as? CGFloat {
                return value
            } else {
                return 0
            }
        }
    }
    
    var agora_pan_limit: CGRect {
        set {
            objc_setAssociatedObject(self,
                                     &Agora_Pan_Limit_Key,
                                     newValue,
                                     .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
        }
        
        get {
            let v = objc_getAssociatedObject(self,
                                             &Agora_Pan_Limit_Key)
            
            if let value = v as? CGRect {
                return value
            } else if let value = self.superview?.bounds {
                return value
            } else {
                return UIApplication.shared.windows[0].frame
            }
        }
    }
    
    var agora_is_draggable: Bool {
        set {
            if newValue, let pan = self.agora_pan {
                self.addGestureRecognizer(pan)
            } else if agora_is_draggable, let pan = self.agora_pan {
                self.removeGestureRecognizer(pan)
            }
            
            objc_setAssociatedObject(self,
                                     &Agora_Is_Draggable_Key,
                                     newValue,
                                     .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
        }
        
        get {
            let v = objc_getAssociatedObject(self,
                                             &Agora_Is_Draggable_Key)
            
            if let value = v as? Bool {
                return value
            } else {
                return false
            }
        }
    }
    
    var agora_is_resizable: Bool {
        set {
            if newValue, let pinch = self.agora_pinch {
                self.addGestureRecognizer(pinch)
            } else if agora_is_draggable, let pinch = self.agora_pinch {
                self.removeGestureRecognizer(pinch)
            }
            
            objc_setAssociatedObject(self,
                                     &Agora_Is_Resizable_Key,
                                     newValue,
                                     .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
        }
        
        get {
            let v = objc_getAssociatedObject(self,
                                             &Agora_Is_Resizable_Key)
            
            if let value = v as? Bool {
                return value
            } else {
                return false
            }
        }
    }
    
    var agora_id: Int {
        set {
            self.tag = newValue
        }
        
        get {
            return self.tag
        }
    }
}

extension UIView {
    fileprivate var agora_constraints: NSMutableArray {
        set {
            objc_setAssociatedObject(self,
                                     &Agora_Constraints_Key,
                                     newValue,
                                     .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
        }
        
        get {
            let v = objc_getAssociatedObject(self,
                                             &Agora_Constraints_Key)
            
            if let value = v as? NSMutableArray {
                return value
            } else {
                return NSMutableArray()
            }
        }
    }
    
    fileprivate var agora_total_scale : CGFloat {
        set {
            objc_setAssociatedObject(self,
                                     &Agora_Total_Scale_Key,
                                     newValue,
                                     .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
        }
        
        get {
            let v = objc_getAssociatedObject(self,
                                             &Agora_Total_Scale_Key)
            
            if let value = v as? CGFloat {
                return value
            } else {
                return 0
            }
        }
    }
    
    fileprivate var agora_pan: UIPanGestureRecognizer? {
        set {
            objc_setAssociatedObject(self,
                                     &Agora_Pan_Gesture_Key,
                                     newValue,
                                     .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
        }
        
        get {
            let v = objc_getAssociatedObject(self,
                                             &Agora_Pan_Gesture_Key)
            
            if let value = v as? UIPanGestureRecognizer {
                return value
            } else {
                return nil
            }
        }
    }
    
    fileprivate var agora_pinch: UIPinchGestureRecognizer? {
        set {
            objc_setAssociatedObject(self,
                                     &Agora_Pinch_Gesture_Key,
                                     newValue,
                                     .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
        }
        
        get {
            let v = objc_getAssociatedObject(self,
                                             &Agora_Pinch_Gesture_Key)
            
            if let value = v as? UIPinchGestureRecognizer {
                return value
            } else {
                return nil
            }
        }
    }
}

// MARK: - Functions
@objc public extension UIView {
    func agora_init_base_view() {
        translatesAutoresizingMaskIntoConstraints = false
        
        agora_constraints = NSMutableArray()
        
        let panGesture = UIPanGestureRecognizer(target: self,
                                                action: #selector(agora_on_pan_event(_ :)))
        self.agora_pan = panGesture
        
        let pinchGesture = UIPinchGestureRecognizer(target: self,
                                                    action: #selector(agora_on_pinch_event(_ :)))
        self.agora_pinch = pinchGesture
    }
    
    func agora_has_transformed() -> Bool {
        return self.agora_has_scaled() || self.agora_has_moved()
    }
    
    open func agora_on_pan_transformed() {
        
    }
    
    func agora_reset_transform() {
        self.transform = CGAffineTransform(scaleX: 1.0 / self.agora_total_scale,
                                           y: 1.0 / self.agora_total_scale)
        self.agora_total_scale = 1.0
        
        self.transform = CGAffineTransform(translationX: -self.transform.tx,
                                           y: -self.transform.ty)
    }
    
    func agora_clear_constraint() {
        for item in self.agora_constraints {
            let obj = item as! NSLayoutConstraint
            obj.isActive = false
        }
        
        self.agora_constraints.removeAllObjects()
    }
    
    @nonobjc @discardableResult func agora_move(_ x: CGFloat,
                                                _ y: CGFloat) -> UIView {
        
        self.agora_x = x
        self.agora_y = y
        return self
    }
    
    @nonobjc @discardableResult func agora_resize(_ width: CGFloat,
                                                  _ height: CGFloat) -> UIView {
        self.agora_width = width
        self.agora_height = height
        return self
    }
    
    @discardableResult func agora_move(x: CGFloat,
                                       y: CGFloat) -> UIView {
        return self.agora_move(x, y)
    }
    
    @discardableResult func agora_resize(width: CGFloat,
                                         height: CGFloat) -> UIView {
        return self.agora_resize(width, height)
    }
    
    func agora_close() {
        self.removeFromSuperview()
    }
}

fileprivate extension UIView {
    @objc func agora_on_pan_event(_ pan: UIPanGestureRecognizer) {
        let transP = pan.translation(in: self)
        let transX = transform.tx + transP.x
        let transY = transform.ty + transP.y
        
        var leftConstraint = (frame.origin.x + transP.x) < 0
        var topConstraint = (frame.origin.y + transP.y) < 0
        var rightConstraint: Bool
        var bottomConstraint: Bool
        
        if #available(iOS 11.0, *),
           let safeAreaInsets = UIApplication.shared.keyWindow?.safeAreaInsets  {
            rightConstraint = (frame.origin.x + frame.size.width + transP.x > agora_pan_limit.width)
            bottomConstraint = (frame.origin.y + frame.size.height + transP.y > agora_pan_limit.height)
        } else {
            rightConstraint = (frame.origin.x + frame.size.width + transP.x > agora_pan_limit.width)
            bottomConstraint = (frame.origin.y + frame.size.height + transP.y > agora_pan_limit.height)
        }
        
        let new_x = (leftConstraint || rightConstraint) ? self.transform.tx : transX;
        let new_y = (topConstraint || bottomConstraint) ? self.transform.ty : transY;
        
        self.transform = CGAffineTransform(translationX: new_x,
                                           y: new_y)
        pan.setTranslation(CGPoint.zero, in: self)
        
        self.agora_on_pan_transformed()
    }
    
    @objc func agora_on_pinch_event(_ pinch: UIPinchGestureRecognizer) {
        if (pinch.state == .began || pinch.state == .changed) {
            let scale = pinch.scale
            self.transform = CGAffineTransform(scaleX: scale, y: scale)
            pinch.scale = 1
            self.agora_total_scale *= scale
        }
    }
    
    func agora_has_scaled() -> Bool {
        if (abs(Float(self.agora_total_scale - 1.0)) <= Agora_Float_Differ) {
            return false
        }
        return true
    }
    
    func agora_has_moved() -> Bool {
        if (abs(Float(self.transform.tx)) <= Agora_Float_Differ && abs(Float(self.transform.ty)) <= Agora_Float_Differ) {
            return false
        }
        return true
    }
    
    func agora_constraint(_ identifier: String,
                          _ constraints: NSMutableArray) -> NSLayoutConstraint? {
        for item in constraints {
            let obj = item as! NSLayoutConstraint
            if obj.identifier == identifier {
                return obj
            }
        }
        return nil
    }
}

public extension UIView {
    func agora_equal_to(view: UIView,
                        attribute: NSLayoutConstraint.Attribute,
                        constant: CGFloat = 0) {
        guard let superView = self.superview else {
            return
        }
      
        let constraint = NSLayoutConstraint(item: self,
                                            attribute: attribute,
                                            relatedBy: .equal,
                                            toItem: view,
                                            attribute: attribute,
                                            multiplier: 1.0,
                                            constant: constant)
        superView.addConstraint(constraint)
    }
    
    func agora_equal_to_superView(attribute: NSLayoutConstraint.Attribute,
                                  constant: CGFloat = 0) {
        guard let superView = self.superview else {
            return
        }
        
        let constraint = NSLayoutConstraint(item: self,
                                            attribute: attribute,
                                            relatedBy: .equal,
                                            toItem: superView,
                                            attribute: attribute,
                                            multiplier: 1.0,
                                            constant: constant)
        superView.addConstraint(constraint)
    }
}
