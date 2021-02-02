//
//  AgoraBaseUI.swift
//  ApaasTest
//
//  Created by Cavan on 2021/1/31.
//

import UIKit

class AgoraBaseView: UIView {
    override init(frame: CGRect) {
        super.init(frame: frame)
        agora_init_base_view()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        agora_init_base_view()
    }
}

class AgoraBaseUILabel: UILabel {
    override init(frame: CGRect) {
        super.init(frame: frame)
        agora_init_base_view()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        agora_init_base_view()
    }
}

class AgoraBaseUIImageView: UIImageView {
    override init(frame: CGRect) {
        super.init(frame: frame)
        agora_init_base_view()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        agora_init_base_view()
    }
}

class AgoraBaseUIButton: UIButton {
    static var Agora_Base_Button_Edge_Insets = "agora_base_button_edge_insets"
    
    var hitTestEdgeInsets : UIEdgeInsets {
        set {
            objc_setAssociatedObject(self,
                                     &AgoraBaseUIButton.Agora_Base_Button_Edge_Insets,
                                     newValue,
                                     .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
        }
        
        get {
            let v = objc_getAssociatedObject(self,
                                             &AgoraBaseUIButton.Agora_Base_Button_Edge_Insets)
            
            if let value =  v as? UIEdgeInsets {
                return value
            } else {
                return UIEdgeInsets.zero
            }
        }
    }
    
    var touchRange: CGFloat = 50
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        agora_init_base_view()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        agora_init_base_view()
    }
    
    open override func point(inside point: CGPoint, with event: UIEvent?) -> Bool {
        if !self.isEnabled || self.isHidden {
            return super.point(inside: point, with: event)
            
        } else if self.hitTestEdgeInsets == UIEdgeInsets.zero {
            var bounds = self.bounds
            
            let widthDelta = max(touchRange - bounds.width, 0)
            let heightDelta = max(touchRange - bounds.height, 0)
            bounds = bounds.insetBy(dx: -0.5 * widthDelta, dy: -0.5 * heightDelta)
            return bounds.contains(point)
            
        } else {
            let relativeFrame = self.bounds
            let hitFrame = relativeFrame.inset(by: self.hitTestEdgeInsets)
            return hitFrame.contains(point)
        }
    }
}

class AgoraBaseUICollectionView: UICollectionView {
    override init(frame: CGRect,
                  collectionViewLayout layout: UICollectionViewLayout) {
        super.init(frame: frame,
                   collectionViewLayout: layout)
        agora_init_base_view()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        agora_init_base_view()
    }
}

class AgoraBaseUICollectionCell: UICollectionViewCell {
    override init(frame: CGRect) {
        super.init(frame: frame)
        agora_init_base_view()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        agora_init_base_view()
    }
}

class AgoraBaseUITableView: UITableView {
    override init(frame: CGRect, style: UITableView.Style) {
        super.init(frame: frame,
                   style: style)
        agora_init_base_view()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        agora_init_base_view()
    }
}

class AgoraBaseUITableViewCell: UITableViewCell {
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style,
                   reuseIdentifier: reuseIdentifier)
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        agora_init_base_view()
    }
}
