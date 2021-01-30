//
//  AgoraBoardToolsView.swift
//  AgoraEduSDK
//
//  Created by Cavan on 2021/1/29.
//

import UIKit

// MARK: - AgoraButtonListView
private class AgoraButtonListView: AgoraBaseView {
    private(set) var buttons = [AgoraBaseButton]()
    private var items = [AgoraBoardToolsItem]()
    
    func initList(_ buttonItems: [AgoraBoardToolsItem]) {
        // remove old buttons
        for item in buttons {
            item.removeFromSuperview()
        }
        
        buttons = [AgoraBaseButton]()
        items = buttonItems
        
        // add new buttons
        for item in buttonItems {
            let button = AgoraBaseButton(item: item)
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
            button.x = 0
            button.y = lastButtonMaxY ?? 0
            button.width = (bounds.height == 0) ? 0 : bounds.width
            button.height = button.width
            lastButtonMaxY = button.height + button.y
        }
    }
    
    @objc func doButtonPressed(button: AgoraBaseButton) {
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
class AgoraBoardToolsItem: NSObject {
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

class AgoraBoardToolsView: AgoraBaseView {
    fileprivate let cornerRadius: CGFloat = 10
    fileprivate let buttonListView = AgoraButtonListView()
    fileprivate let titleLabel = AgoraBaseLabel()
    fileprivate let separator = AgoraBaseView()
    fileprivate let unfoldButton = AgoraBaseButton()
    
    fileprivate let popover = AgoraPopover(options: [.type(.up),
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
        self.initLayout()
    }
    
    func initLayout() {
        // titleLabel
        titleLabel.x = 0
        titleLabel.y = 0
        titleLabel.width = bounds.width
        titleLabel.height = bounds.width
        
        self.layoutIfNeeded();
        
        // separator
        let separatorSpace: CGFloat = 12
        let separatorW: CGFloat = bounds.width - (separatorSpace * 2)
        separator.x = separatorSpace
        separator.bottom = 61
        separator.height = 1
        separator.width = separatorW
        
        // unfoldButton
        let unfoldButtonH: CGFloat = 60
        let unfoldButtonY = bounds.height - unfoldButtonH - CGFloat(separator.height)
        unfoldButton.x = 0
        unfoldButton.y = unfoldButtonY
        unfoldButton.width = bounds.width
        unfoldButton.height = unfoldButtonH
        
        // unfold status frame
        if unfoldButton.isSelected {
            // buttonListView
            buttonListView.x = 0
            buttonListView.y = titleLabel.height
            buttonListView.width = bounds.width
            buttonListView.height = CGFloat(buttonListView.buttons.count) * bounds.width
            height = titleLabel.height + separator.height + unfoldButton.height + buttonListView.height
            
        // fold status frame
        } else {
            // buttonListView
            buttonListView.height = 0
            
            height = titleLabel.height + separator.height + unfoldButton.height
        }
        
        UIView.animate(withDuration: TimeInterval.animation) {
            self.superview?.layoutIfNeeded()
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
        self.popover.backgroundColor = .blue
        self.popover.strokeColor = .red
        self.popover.borderColor = .green
        
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
    }
}

fileprivate extension AgoraBaseButton {
    convenience init(item: AgoraBoardToolsItem) {
        self.init(frame: CGRect.zero)
        
        setImage(item.normalImage,
                 for: .normal)
        
        setImage(item.selectedImage,
                 for: .selected)
    }
}
