//
//  AgoraUIViews.swift
//  AgoraUIBaseViews
//
//  Created by Cavan on 2021/3/2.
//

import UIKit

@objcMembers open class AgoraBaseUIView: UIView, AgoraUIElement {
    public var id: String
    
    public init(id: String) {
        self.id = id
        super.init(frame: .zero)
        agora_init_base_view()
    }
    
    public override init(frame: CGRect) {
        self.id = ""
        super.init(frame: frame)
        agora_init_base_view()
    }
    
    public required init?(coder: NSCoder) {
        self.id = ""
        super.init(coder: coder)
        agora_init_base_view()
    }
}

@objc public protocol AgoraUIContainerDelegate: NSObjectProtocol {
    func containerLayoutSubviews()
}

@objcMembers open class AgoraBaseUIContainer: AgoraBaseUIView {
    public weak var delegate: AgoraUIContainerDelegate?
    
    open override func layoutSubviews() {
        super.layoutSubviews()
        delegate?.containerLayoutSubviews()
    }
}

@objcMembers open class AgoraBaseUIScrollView: UIScrollView, AgoraUIElement {
    public var id: String
    
    public init(id: String) {
        self.id = id
        super.init(frame: .zero)
        agora_init_base_view()
    }
    
    public override init(frame: CGRect) {
        self.id = ""
        super.init(frame: frame)
        agora_init_base_view()
    }
    
    public required init?(coder: NSCoder) {
        self.id = ""
        super.init(coder: coder)
        agora_init_base_view()
    }
}

@objcMembers open class AgoraBaseUILabel: UILabel, AgoraUIElement {
    public var id: String
    
    public init(id: String) {
        self.id = id
        super.init(frame: .zero)
        agora_init_base_view()
    }
    
    public override init(frame: CGRect) {
        self.id = ""
        super.init(frame: frame)
        agora_init_base_view()
    }
    
    public required init?(coder: NSCoder) {
        self.id = ""
        super.init(coder: coder)
        agora_init_base_view()
    }
}

@objcMembers open class AgoraBaseUISlider: UISlider, AgoraUIElement {
    public var id: String
    
    public init(id: String) {
        self.id = id
        super.init(frame: .zero)
        agora_init_base_view()
    }
    
    public override init(frame: CGRect) {
        self.id = ""
        super.init(frame: frame)
        agora_init_base_view()
    }
    
    public required init?(coder: NSCoder) {
        self.id = ""
        super.init(coder: coder)
        agora_init_base_view()
    }
}

@objcMembers open class AgoraBaseUIImageView: UIImageView, AgoraUIElement {
    public var id: String
    
    public init(id: String) {
        self.id = id
        super.init(frame: .zero)
        agora_init_base_view()
    }
    
    public override init(frame: CGRect) {
        self.id = ""
        super.init(frame: frame)
        agora_init_base_view()
    }
    
    public required init?(coder: NSCoder) {
        self.id = ""
        super.init(coder: coder)
        agora_init_base_view()
    }
    
    public override init(image: UIImage?) {
        self.id = ""
        super.init(image: image)
        agora_init_base_view()
    }
}

@objcMembers open class AgoraBaseUITextField: UITextField, AgoraUIElement {
    public var id: String
    
    public init(id: String) {
        self.id = id
        super.init(frame: .zero)
        agora_init_base_view()
    }
    
    public override init(frame: CGRect) {
        self.id = ""
        super.init(frame: frame)
        agora_init_base_view()
    }
    
    public required init?(coder: NSCoder) {
        self.id = ""
        super.init(coder: coder)
        agora_init_base_view()
    }
}

@objcMembers open class AgoraBaseUIButton: UIButton, AgoraUIElement {
    static var Agora_Base_Button_Edge_Insets = "agora_base_button_edge_insets"
    
    private var tapBlock: ((AgoraBaseUIButton) -> Void)?
    
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
    
    public var touchRange: CGFloat = 50
    
    public var id: String
    
    public init(id: String) {
        self.id = id
        super.init(frame: .zero)
        agora_init_base_view()
    }
    
    public override init(frame: CGRect) {
        self.id = ""
        super.init(frame: frame)
        agora_init_base_view()
        translate_tap_event()
    }
    
    public required init?(coder: NSCoder) {
        self.id = ""
        super.init(coder: coder)
        agora_init_base_view()
        translate_tap_event()
    }
    
    public override func point(inside point: CGPoint,
                             with event: UIEvent?) -> Bool {
        if !self.isEnabled || self.isHidden {
            return super.point(inside: point,
                               with: event)
            
        } else if self.hitTestEdgeInsets == UIEdgeInsets.zero {
            var bounds = self.bounds
            
            let widthDelta = max(touchRange - bounds.width, 0)
            let heightDelta = max(touchRange - bounds.height, 0)
            bounds = bounds.insetBy(dx: -0.5 * widthDelta,
                                    dy: -0.5 * heightDelta)
            return bounds.contains(point)
            
        } else {
            let relativeFrame = self.bounds
            let hitFrame = relativeFrame.inset(by: self.hitTestEdgeInsets)
            return hitFrame.contains(point)
        }
    }
    
    public func tap(_ block: @escaping (AgoraBaseUIButton) -> Void) {
        tapBlock = block
    }
    
    private func translate_tap_event() {
        addTarget(self,
                  action: #selector(do_tap_event),
                  for: .touchUpInside)
    }
    
    @objc private func do_tap_event(_ button: AgoraBaseUIButton) {
        if let `tapBlock` = tapBlock {
            tapBlock(self)
            isUserInteractionEnabled = false
            
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) { [unowned self] in
                self.isUserInteractionEnabled = true
            }
        }
    }
}

@objcMembers open class AgoraBaseUICollectionView: UICollectionView, AgoraUIElement {
    public var id: String
    
    public override init(frame: CGRect,
                  collectionViewLayout layout: UICollectionViewLayout) {
        self.id = ""
        super.init(frame: frame,
                   collectionViewLayout: layout)
        agora_init_base_view()
    }
    
    public required init?(coder: NSCoder) {
        self.id = ""
        super.init(coder: coder)
        agora_init_base_view()
    }
}

@objcMembers open class AgoraBaseUICollectionCell: UICollectionViewCell, AgoraUIElement {
    public var id: String
    
    public init(id: String) {
        self.id = id
        super.init(frame: .zero)
        agora_init_base_view()
    }
    
    public override init(frame: CGRect) {
        self.id = ""
        super.init(frame: frame)
        agora_init_base_view()
    }
    
    public required init?(coder: NSCoder) {
        self.id = ""
        super.init(coder: coder)
        agora_init_base_view()
    }
}

@objcMembers open class AgoraBaseUITableView: UITableView, AgoraUIElement {
    public var id: String
    
    public override init(frame: CGRect,
                         style: UITableView.Style) {
        self.id = ""
        super.init(frame: frame,
                   style: style)
        agora_init_base_view()
    }
    
    public required init?(coder: NSCoder) {
        self.id = ""
        super.init(coder: coder)
        agora_init_base_view()
    }
}

@objcMembers open class AgoraBaseUITableViewCell: UITableViewCell, AgoraUIElement {
    public var id: String
    
    public override init(style: UITableViewCell.CellStyle,
                         reuseIdentifier: String?) {
        self.id = ""
        super.init(style: style,
                   reuseIdentifier: reuseIdentifier)
    }
    
    public required init?(coder: NSCoder) {
        self.id = ""
        super.init(coder: coder)
        agora_init_base_view()
    }
}

@objcMembers open class AgoraBaseUISwitch: UISwitch, AgoraUIElement {
    public var id: String
    
    public init(id: String) {
        self.id = id
        super.init(frame: .zero)
        agora_init_base_view()
    }
    
    public override init(frame: CGRect) {
        self.id = ""
        super.init(frame: frame)
        agora_init_base_view()
    }
    
    public required init?(coder: NSCoder) {
        self.id = ""
        super.init(coder: coder)
        agora_init_base_view()
    }
}
