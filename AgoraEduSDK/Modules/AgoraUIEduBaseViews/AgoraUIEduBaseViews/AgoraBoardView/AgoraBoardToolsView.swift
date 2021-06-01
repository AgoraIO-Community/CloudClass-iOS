//
//  AgoraBoardToolsView.swift
//  AgoraEduSDK
//
//  Created by Cavan on 2021/1/29.
//

import UIKit
import AgoraUIBaseViews

// MARK: - AgoraButtonListView
private class AgoraButtonListView: AgoraBaseUIScrollView {
    private(set) var buttons = [AgoraBaseUIButton]()
    private var items = [AgoraBoardToolsBaseItem]()
    private var selectedItemIndex = 1
    var buttonLeftSpace: CGFloat = 0
    var buttonBottomSpace: CGFloat = 0
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        initViews()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        initViews()
    }
    
    private func initViews() {
        showsVerticalScrollIndicator = false
    }
    
    func initList(_ buttonItems: [AgoraBoardToolsBaseItem],
                  selectedItemIndex: Int) {
        self.selectedItemIndex = selectedItemIndex
        
        // remove old buttons
        for item in buttons {
            item.removeFromSuperview()
        }
        
        buttons = [AgoraBaseUIButton]()
        items = buttonItems
        
        // add new buttons
        for (index, item) in buttonItems.enumerated() {
            let button = AgoraBaseUIButton(item: item)
            button.imageView?.contentMode = .scaleAspectFit
            button.addTarget(self,
                             action: #selector(doButtonPressed(button:)),
                             for: .touchUpInside)
            button.isSelected = (index == selectedItemIndex)
            addSubview(button)
            buttons.append(button)
        }
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        var lastButtonMaxY: CGFloat? = nil
        for button in buttons {
            button.agora_x = buttonLeftSpace
            button.agora_y = lastButtonMaxY ?? 0
            button.agora_width = (bounds.height == 0) ? 0 : (bounds.width - (buttonLeftSpace * 2))
            button.agora_height = button.agora_width
            lastButtonMaxY = button.agora_height + button.agora_y + buttonBottomSpace
        }
    }
    
    func setSelectedButton(index: Int) {
        allButtonsUnselected()
        
        let button = buttons[index]
        button.isSelected = true
    }
    
    func allButtonsUnselected() {
        for item in buttons {
            item.isSelected = false
        }
    }
    
    @objc func doButtonPressed(button: AgoraBaseUIButton) {
        guard let index = buttons.firstIndex(of: button) else {
            return
        }
        
        setSelectedButton(index: index)
        
        let item = items[index]
        
        guard let tap = item.tap else {
            return
        }
        
        tap(button)
    }
}

// MARK: - AgoraBoardToolsUnfoldButton
@objcMembers public class AgoraBoardToolsUnfoldButton: AgoraBaseUIButton {
    public override init(frame: CGRect) {
        super.init(frame: frame)
        backgroundColor = .white
        setImage(AgoraKitImage("icon-close-right"),
                 for: .normal)
    }
    
    public override func layoutSubviews() {
        super.layoutSubviews()
        let space: CGFloat = 5
        let insetsLeft: CGFloat = bounds.width * 0.5 + space
        imageEdgeInsets = UIEdgeInsets(top: space,
                                       left: insetsLeft,
                                       bottom: space,
                                       right: space)
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }
}

// MARK: - AgoraBoardToolsItem
@objcMembers public class AgoraBoardToolsBaseItem: NSObject {
    var image: UIImage?
    var selectedImage: UIImage?
    var tap: ((UIButton) -> Void)?
    
    public init(image: UIImage? = nil,
                selectedImage: UIImage? = nil,
                tap: ((UIButton) -> Void)? = nil) {
        self.image = image
        self.selectedImage = selectedImage
        self.tap = tap
    }
}

@objcMembers public class AgoraBoardToolsItem: AgoraBoardToolsBaseItem {
    var itemType: AgoraBoardToolsItemType
    
    public init(itemType: AgoraBoardToolsItemType,
         tap: ((UIButton) -> Void)? = nil) {
        self.itemType = itemType
        super.init(image: itemType.image,
                   selectedImage: itemType.selectedImage,
                   tap: tap)
    }
}

// MARK: - AgoraBoardToolsView
@objcMembers public class AgoraBoardToolsView: AgoraBaseUIView {
    fileprivate let buttonListView = AgoraButtonListView(frame: .zero)
    
    public lazy var popover = AgoraPopover(options: [.type(.right),
                                                     .blackOverlayColor(.clear),
                                                     .cornerRadius(10),
                                                     .arrowSize(CGSize(width: 16,
                                                                       height: 4)),
                                                     .arrowPointerOffset(CGPoint(x: 10,
                                                                                 y: 0))])
    public var itemCount: Int {
        return buttonListView.buttons.count
    }
    
    public let foldButton = AgoraBaseUIButton()
    public var didFoldCompletion: ((Bool) -> Void)? = nil
    
    public var maxHeight: CGFloat = 0 {
        didSet {
            layoutSubviews()
        }
    }
    
    public var foldButtonTopSpace: CGFloat = 5
    public var foldButtonLeftSpace: CGFloat = 5
    
    public var toolButtonListTopSpace: CGFloat = 10
    public var toolButtonListBottomSpace: CGFloat = 7
    
    public var toolButtonLeftSpace: CGFloat = 7
    public var toolButtonLineSpace: CGFloat = 10
    public var toolButtonListMaxHeight: CGFloat = 0
    
    public var isFold = false {
        didSet {
            self.foldButton.isSelected = isFold
            
            layoutSubviews()
            
            UIView.animate(withDuration: TimeInterval.agora_animation) {
                self.superview?.layoutIfNeeded()
            } completion: { (isCompletion) in
                guard isCompletion else {
                    return
                }
                
                guard let didFoldCompletion = self.didFoldCompletion else {
                    return
                }
                
                didFoldCompletion(self.isFold)
            }
        }
    }

    public override init(frame: CGRect) {
        super.init(frame: frame)
        initViews()
    }
    
    public required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        initViews()
    }
    
    public override func layoutSubviews() {
        super.layoutSubviews()
        initLayout()
    }
    
    func initLayout() {
        // foldButton
        foldButton.agora_x = foldButtonLeftSpace
        foldButton.agora_y = foldButtonTopSpace
        
        let foldButtonWidth: CGFloat = bounds.width - (foldButtonLeftSpace * 2)
        let foldButtonHeight: CGFloat = foldButtonWidth
        
        guard foldButtonWidth >= 0,
              foldButtonHeight >= 0 else {
            return
        }
        
        foldButton.agora_width = foldButtonWidth
        foldButton.agora_height = foldButtonHeight
        
        // fold status frame
        if isFold {
            // buttonListView
            buttonListView.agora_height = 0
            
            agora_height = (foldButtonTopSpace * 2) + foldButtonHeight
            
        // unfold status frame
        } else {
            // buttonListView
            buttonListView.buttonLeftSpace = toolButtonLeftSpace
            buttonListView.buttonBottomSpace = toolButtonLineSpace
            
            let buttonWidth = bounds.width - (buttonListView.buttonLeftSpace * 2)
            let buttonHeight = buttonWidth
            let buttonLineSpace: CGFloat = toolButtonLineSpace
            
            let buttonHeightSum: CGFloat = CGFloat(buttonListView.buttons.count) * buttonHeight
            let buttonLineSum: CGFloat = CGFloat(buttonListView.buttons.count - 1) * buttonLineSpace
            let buttonListViewContentHeight: CGFloat = buttonHeightSum + buttonLineSum
            
            buttonListView.contentSize = CGSize(width: 0,
                                                height: buttonListViewContentHeight)
            
            let buttonListViewY: CGFloat = foldButtonTopSpace + foldButtonHeight + toolButtonListTopSpace
            
            buttonListView.agora_x = 0
            buttonListView.agora_y = buttonListViewY
            buttonListView.agora_width = bounds.width
            
            // AgoraToolsView height
            let toolsViewHeight = buttonListViewY + buttonHeightSum + buttonLineSum + toolButtonListBottomSpace
            let toolsViewFinalHeight = (toolsViewHeight > maxHeight ? maxHeight : toolsViewHeight)
            agora_height = toolsViewFinalHeight
            
            // buttonListView Height
            let buttonListViewHeight = agora_height - buttonListViewY - toolButtonListBottomSpace
            buttonListView.agora_height = buttonListViewHeight
            buttonListView.isScrollEnabled = (buttonListViewContentHeight > buttonListViewHeight)
        }
    }
    
    // MARK: action
    @objc func doFoldButtonPressed(_ button: UIButton) {
        isFold.toggle()
    }
}

public extension AgoraBoardToolsView {
    func registerToolItems(_ items: [AgoraBoardToolsBaseItem],
                                  selectedIndex: Int) {
        buttonListView.initList(items,
                                selectedItemIndex: selectedIndex)
    }
}

private extension AgoraBoardToolsView {
    func initViews() {
        // buttonListView
        buttonListView.backgroundColor = .clear
        addSubview(buttonListView)
        
        // foldButton
        foldButton.imageView?.contentMode = .scaleAspectFit
        
        foldButton.setImage(AgoraKitImage("icon-close"),
                              for: .normal)
        foldButton.setImage(AgoraKitImage("icon-close-right"),
                              for: .selected)
        foldButton.addTarget(self,
                               action: #selector(doFoldButtonPressed(_:)),
                               for: .touchUpInside)
        foldButton.contentMode = .scaleAspectFit
        foldButton.isSelected = false
        foldButton.touchRange = 0
        addSubview(foldButton)
        
        // popover
        popover.delegate = self
        popover.strokeColor = .white
        popover.borderColor = .white
    }
}

extension AgoraBoardToolsView: AgoraPopoverDelegate {
    public func popoverDidDismiss(_ popover: AgoraPopover) {
        
    }
}

fileprivate extension AgoraBaseUIButton {
    convenience init(item: AgoraBoardToolsBaseItem) {
        self.init(frame: CGRect.zero)
        
        setImage(item.image,
                 for: .normal)
        
        setImage(item.selectedImage,
                 for: .selected)
        
        touchRange = 0
    }
}

fileprivate extension AgoraBoardToolsItemType {
    var image: UIImage? {
        switch self {
        case .select:    return AgoraKitImage("iocn-select")!
        case .pencil:    return AgoraKitImage("icon-pen-more")!
        case .text:      return AgoraKitImage("icon-text-more")!
        case .eraser:    return AgoraKitImage("icon-eraser-more")!
        case .color:     return AgoraKitImage("icon-color-more")!
        case .clicker:   return AgoraKitImage("icon-clicker")!
        }
    }

    var selectedImage: UIImage? {
        switch self {
        case .select:    return AgoraKitImage("iocn-select_actived")!
        case .pencil:    return AgoraKitImage("icon-pen-more_actived")!
        case .text:      return AgoraKitImage("icon-text-more_actived")!
        case .eraser:    return AgoraKitImage("icon-eraser-more_actived")!
        case .color:     return AgoraKitImage("icon-color-more_actived")!
        case .clicker:   return AgoraKitImage("icon-clicker-actived")!
        }
    }
}
