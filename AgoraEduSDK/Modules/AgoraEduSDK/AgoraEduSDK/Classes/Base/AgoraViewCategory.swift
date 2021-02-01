//
//  AgoraViewCategory.swift
//  ApaasTest
//
//  Created by Cavan on 2021/1/31.
//

import UIKit

fileprivate var Agora_Constraints_Key: NSString = "agora_constraints"

fileprivate var Agora_X_Key: NSString = "agora_x"
fileprivate var Agora_Y_Key: NSString = "agora_y"
fileprivate var Agora_Z_Key: NSString = "agora_z"

fileprivate var Agora_Width_Key: NSString = "agora_width"
fileprivate var Agora_Height_Key: NSString = "agora_height"

fileprivate var Agora_Center_X_Key: NSString = "agora_center_x"
fileprivate var Agora_Center_Y_Key: NSString = "agora_center_y"

fileprivate var Agora_Left_Key: NSString = "agora_left"
fileprivate var Agora_Right_Key: NSString = "agora_right"
fileprivate var Agora_Top_Key: NSString = "agora_top"
fileprivate var Agora_Bottom_Key: NSString = "agora_bottom"

fileprivate var Agora_Total_Scale_Key: NSString = "agora_total_scale"

fileprivate var Agora_Is_Draggable_Key: NSString = "agora_is_draggable"
fileprivate var Agora_Is_Resizable_Key: NSString = "agora_is_resizable"

fileprivate var Agora_Pan_Gesture_Key: NSString = "agora_pan"
fileprivate var Agora_Pinch_Gesture_Key: NSString = "agora_pinch"

fileprivate let Agora_Float_Differ: Float = 0.001

// MARK: - Properties
extension UIView {
    var agora_x: CGFloat {
        set {
            objc_setAssociatedObject(self,
                                     &Agora_X_Key,
                                     newValue,
                                     .OBJC_ASSOCIATION_RETAIN)
            
            assert(self.superview != nil, "can not found superview")
            if let constraint = self.constraint(Constraint_Id_X, agora_constraints) {
                constraint.constant = newValue
                constraint.isActive = true
            } else {
                let constraint = self.leftAnchor.constraint(equalTo: self.superview!.leftAnchor,
                                                            constant: newValue)
                constraint.identifier = Constraint_Id_X
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
                                     .OBJC_ASSOCIATION_RETAIN)
            
            assert(self.superview != nil, "can not found superview")
            if let constraint = self.constraint(Constraint_Id_Y, agora_constraints) {
                constraint.constant = newValue
                constraint.isActive = true
            } else {
                let constraint = self.topAnchor.constraint(equalTo: self.superview!.topAnchor,
                                                           constant: newValue)
                constraint.identifier = Constraint_Id_Y
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
                                     .OBJC_ASSOCIATION_RETAIN)
            
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
    
    var agora_center_x: CGFloat {
        set {
            objc_setAssociatedObject(self,
                                     &Agora_Center_X_Key,
                                     newValue,
                                     .OBJC_ASSOCIATION_RETAIN)
            
            assert(self.superview != nil, "can not found superview")
            if let constraint = self.constraint(Constraint_Id_CenterX, agora_constraints) {
                constraint.constant = newValue
                constraint.isActive = true
            } else {
                let constraint = self.centerXAnchor.constraint(equalTo: self.superview!.centerXAnchor,
                                                               constant: newValue)
                constraint.identifier = Constraint_Id_CenterX
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
    
    var agora_width: CGFloat {
        set {
            objc_setAssociatedObject(self,
                                     &Agora_Width_Key,
                                     newValue,
                                     .OBJC_ASSOCIATION_RETAIN)
            
            if let constraint = self.constraint(Constraint_Id_Width, agora_constraints) {
                constraint.constant = newValue
                constraint.isActive = true
            } else {
                let constraint = self.widthAnchor.constraint(equalToConstant: newValue)
                constraint.identifier = Constraint_Id_Width
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
                                     .OBJC_ASSOCIATION_RETAIN)
            
            if let constraint = self.constraint(Constraint_Id_Height, agora_constraints) {
                constraint.constant = newValue
                constraint.isActive = true
            } else {
                let constraint = self.heightAnchor.constraint(equalToConstant: newValue)
                constraint.identifier = Constraint_Id_Height
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
    
    var agora_center_y: CGFloat {
        set {
            objc_setAssociatedObject(self,
                                     &Agora_Center_Y_Key,
                                     newValue,
                                     .OBJC_ASSOCIATION_RETAIN)
            
            assert(self.superview != nil, "can not found superview")
            if let constraint = self.constraint(Constraint_Id_CenterY, agora_constraints) {
                constraint.constant = newValue
                constraint.isActive = true
            } else {
                let constraint = self.centerYAnchor.constraint(equalTo: self.superview!.centerYAnchor,
                                                               constant: newValue)
                constraint.identifier = Constraint_Id_CenterY
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
                                     .OBJC_ASSOCIATION_RETAIN)
            
            assert(self.superview != nil, "can not found superview")
            if let constraint = self.constraint(Constraint_Id_Right, agora_constraints) {
                constraint.constant = -newValue
                constraint.isActive = true
            } else {
                let constraint = self.rightAnchor.constraint(equalTo: self.superview!.rightAnchor,
                                                             constant: -newValue)
                constraint.identifier = Constraint_Id_Right
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
                                     .OBJC_ASSOCIATION_RETAIN)
            
            assert(self.superview != nil, "can not found superview")
            if let constraint = self.constraint(Constraint_Id_Bottom, agora_constraints) {
                constraint.constant = -newValue
                constraint.isActive = true
            } else {
                let constraint = self.bottomAnchor.constraint(equalTo: self.superview!.bottomAnchor, constant: -newValue)
                constraint.identifier = Constraint_Id_Bottom
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
                                     .OBJC_ASSOCIATION_RETAIN)
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
                                     .OBJC_ASSOCIATION_RETAIN)
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
                                     .OBJC_ASSOCIATION_RETAIN)
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
                                     .OBJC_ASSOCIATION_RETAIN)
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
                                     .OBJC_ASSOCIATION_RETAIN)
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
extension UIView {
    func agora_init_base_view() {
        translatesAutoresizingMaskIntoConstraints = false
        
        agora_constraints = NSMutableArray()
        
        let panGesture = UIPanGestureRecognizer(target: self,
                                                action: #selector(onPanEvent(_ :)))
        self.agora_pan = panGesture
        
        let pinchGesture = UIPinchGestureRecognizer(target: self,
                                                    action: #selector(onPinchEvent(_ :)))
        self.agora_pinch = pinchGesture
        
        //        agora_width = 0
        //        agora_height = 0
        //        agora_center_x = 0
        //        agora_center_y = 0
        //        agora_right = 0
        //        agora_bottom = 0
        //
        //        agora_is_draggable = false
        //        agora_is_resizable = false
    }
    
    func agora_has_transformed() -> Bool {
        return self.hasScaled() || self.hasScaled()
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
    }
}

fileprivate extension UIView {
    @objc func onPanEvent(_ pan: UIPanGestureRecognizer) {
        let transP = pan.translation(in: self)
        self.transform = CGAffineTransform(translationX: transP.x, y: transP.y)
        pan.setTranslation(CGPoint.zero, in: self)
    }
    
    @objc func onPinchEvent(_ pinch: UIPinchGestureRecognizer) {
        if (pinch.state == .began || pinch.state == .changed) {
            let scale = pinch.scale
            self.transform = CGAffineTransform(scaleX: scale, y: scale)
            pinch.scale = 1
            self.agora_total_scale *= scale
        }
    }
    
    func hasScaled() -> Bool {
        if (abs(Float(self.agora_total_scale - 1.0)) <= Agora_Float_Differ) {
            return false
        }
        return true
    }
    
    func hasMoved() -> Bool {
        if (abs(Float(self.transform.tx)) <= Agora_Float_Differ && abs(Float(self.transform.ty)) <= Agora_Float_Differ) {
            return false
        }
        return true
    }
    
    func constraint(_ identifier: String,
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
