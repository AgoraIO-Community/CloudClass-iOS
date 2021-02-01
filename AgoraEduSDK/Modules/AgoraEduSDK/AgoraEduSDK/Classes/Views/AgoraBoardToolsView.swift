//
//  AgoraBoardToolsView.swift
//  AgoraEduSDK
//
//  Created by Cavan on 2021/1/29.
//

import UIKit

// MARK: - AgoraButtonListView
private class AgoraButtonListView: AgoraBaseUIView {
    private(set) var buttons = [AgoraBaseUIButton]()
    private var items = [AgoraBoardToolsItem]()
    
    func initList(_ buttonItems: [AgoraBoardToolsItem]) {
        // remove old buttons
        for item in buttons {
            item.removeFromSuperview()
        }
        
        buttons = [AgoraBaseUIButton]()
        items = buttonItems
        
        // add new buttons
        for item in buttonItems {
            let button = AgoraBaseUIButton(item: item)
            button.addTarget(self,
                             action: #selector(doButtonPressed(button:)),
                             for: .touchUpInside)
            addSubview(button)
            buttons.append(button)
        }
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        var lastButtonMaxY: CGFloat? = nil
        for button in buttons {
            button.agora_x = 0
            button.agora_y = lastButtonMaxY ?? 0
            button.agora_width = (bounds.height == 0) ? 0 : bounds.width
            button.agora_height = button.agora_width
            lastButtonMaxY = button.agora_height + button.agora_y
        }
    }
    
    func buttonsUnselected() {
        for item in buttons {
            item.isSelected = false
        }
    }
    
    @objc func doButtonPressed(button: AgoraBaseUIButton) {
        var buttonIndex: Int? = nil
        
        for (index, item) in buttons.enumerated() {
            if item == button {
                buttonIndex = index
                item.isSelected = true
            } else {
                item.isSelected = false
            }
        }
        
        guard let tIndex = buttonIndex else {
            return
        }
        
        let item = items[tIndex]
        
        guard let tap = item.tap else {
            return
        }
        
        tap(button)
    }
}

// MARK: - AgoraBoardToolsItem
@objc class AgoraBoardToolsItem: NSObject {
    var normalImage: UIImage
    var selectedImage: UIImage
    var tap: ((UIButton) -> Void)?
    
    init(normalImage: UIImage,
         selectedImage: UIImage,
         tap: ((UIButton) -> Void)? = nil) {
        self.normalImage = normalImage
        self.selectedImage = selectedImage
        self.tap = tap
    }
}

@objc class AgoraBoardToolsView: AgoraBaseUIView {
    fileprivate let cornerRadius: CGFloat = 10
    fileprivate let buttonListView = AgoraButtonListView()
    fileprivate let titleLabel = AgoraBaseUILabel()
    fileprivate let separator = AgoraBaseUIView()
    fileprivate let unfoldButton = AgoraBaseUIButton()
    
    fileprivate let popover = AgoraPopover(options: [.type(.right),
                                                     .blackOverlayColor(.clear),
                                                     .cornerRadius(5),
                                                     .arrowSize(CGSize(width: 8, height: 4))])
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        initViews()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        initViews()
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        initLayout()
    }
    
    func initLayout() {
        // titleLabel
        titleLabel.agora_x = 0
        titleLabel.agora_y = 0
        titleLabel.agora_width = bounds.width
        titleLabel.agora_height = bounds.width
        
        // separator
        let separatorSpace: CGFloat = 12
        let separatorW: CGFloat = bounds.width - (separatorSpace * 2)
        separator.agora_x = separatorSpace
        separator.agora_bottom = 61
        separator.agora_height = 1
        separator.agora_width = separatorW
        
        // unfoldButton
        let unfoldButtonH: CGFloat = 60
        let unfoldButtonY = bounds.height - unfoldButtonH - CGFloat(separator.agora_height)
        unfoldButton.agora_x = 0
        unfoldButton.agora_y = unfoldButtonY
        unfoldButton.agora_width = bounds.width
        unfoldButton.agora_height = unfoldButtonH
        
        // unfold status frame
        if unfoldButton.isSelected {
            // buttonListView
            buttonListView.agora_x = 0
            buttonListView.agora_y = titleLabel.agora_height
            buttonListView.agora_width = bounds.width
            buttonListView.agora_height = CGFloat(buttonListView.buttons.count) * bounds.width
            agora_height = titleLabel.agora_height + separator.agora_height + unfoldButton.agora_height + buttonListView.agora_height
            
        // fold status frame
        } else {
            // buttonListView
            buttonListView.agora_height = 0
            
            agora_height = titleLabel.agora_height + separator.agora_height + unfoldButton.agora_height
        }
    }
}

private extension AgoraBoardToolsView {
    func initViews() {
        backgroundColor = UIColor(rgb: 0x13196F,
                                  alpha: 0.3)
        
        layer.cornerRadius = cornerRadius
        layer.borderWidth = 1
        layer.borderColor = UIColor(rgb: 0x090E51).cgColor
        
        // titleLabel
        titleLabel.text = "Tools"
        titleLabel.textColor = .white
        titleLabel.layer.cornerRadius = cornerRadius
        titleLabel.textAlignment = .center
        addSubview(titleLabel)
        
        // buttonListView
        buttonListView.backgroundColor = .clear
        registerToolsItem()
        addSubview(buttonListView)
        
        // separator
        separator.backgroundColor = UIColor(rgb: 0x090E51)
        addSubview(separator)
        
        // unfoldButton
        unfoldButton.setImage(UIImage(named: "工具栏-收起 拷贝"),
                              for: .normal)
        unfoldButton.setImage(UIImage(named: "工具栏-收起"),
                              for: .selected)
        unfoldButton.addTarget(self,
                               action: #selector(doUnfoldButtonPressed(_:)),
                               for: .touchUpInside)
        addSubview(unfoldButton)
    }
    
    func registerToolsItem() {
        self.popover.delegate = self
        self.popover.strokeColor = UIColor(rgb: 0x13196F,
                                           alpha: 0.3)
        self.popover.borderColor = UIColor(rgb: 0x090E51)
        
        let moveItem = AgoraBoardToolsItem(normalImage: UIImage(named: "箭头")!,
                                           selectedImage: UIImage(named: "箭头-1")!) { [unowned self] (button) in
            
        }
        
        let pencilItem = AgoraBoardToolsItem(normalImage: UIImage(named: "笔")!,
                                             selectedImage: UIImage(named: "笔-1")!) { [unowned self] (button) in
            let view = UIView(frame: CGRect(x: 0, y: 0, width: 100, height: 100))
            view.backgroundColor = .clear
            
            self.popover.show(view,
                              fromView: button)
        }
        
        let textItem = AgoraBoardToolsItem(normalImage: UIImage(named: "文本")!,
                                           selectedImage: UIImage(named: "文本-1")!) { [unowned self] (button) in
            
        }
        
        let rectangleItem = AgoraBoardToolsItem(normalImage: UIImage(named: "矩形工具")!,
                                                selectedImage: UIImage(named: "矩形工具-1")!) { [unowned self] (button) in
            
        }
        
        let circleItem = AgoraBoardToolsItem(normalImage: UIImage(named: "圆形工具")!,
                                             selectedImage: UIImage(named: "圆形工具")!) { [unowned self] (button) in
            
        }
        
        let eraserItem = AgoraBoardToolsItem(normalImage: UIImage(named: "橡皮")!,
                                             selectedImage: UIImage(named: "橡皮-1")!) { [unowned self] (button) in
            
        }
        
        let list = [moveItem,
                    pencilItem,
                    textItem,
                    rectangleItem,
                    circleItem,
                    eraserItem]
        
        buttonListView.initList(list)
    }
}

private extension AgoraBoardToolsView {
    @objc func doUnfoldButtonPressed(_ button: UIButton) {
        button.isSelected.toggle()
        layoutSubviews()
        UIView.animate(withDuration: TimeInterval.animation) {
            self.superview?.layoutIfNeeded()
        }
    }
}

extension AgoraBoardToolsView: AgoraPopoverDelegate {
    func popoverDidDismiss(_ popover: AgoraPopover) {
        buttonListView.buttonsUnselected()
    }
}

fileprivate extension AgoraBaseUIButton {
    convenience init(item: AgoraBoardToolsItem) {
        self.init(frame: CGRect.zero)
        
        setImage(item.normalImage,
                 for: .normal)
        
        setImage(item.selectedImage,
                 for: .selected)
    }
}
