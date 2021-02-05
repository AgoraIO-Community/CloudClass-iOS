//
//  AgoraBoardToolsView.swift
//  AgoraEduSDK
//
//  Created by Cavan on 2021/1/29.
//

import UIKit

// MARK: - AgoraButtonListView
private class AgoraButtonListView: AgoraBaseUIScrollView {
    private(set) var buttons = [AgoraBaseUIButton]()
    private var items = [AgoraBoardToolsItem]()
    private var selectedItemIndex = 0
    let buttonLeftSpace: CGFloat = 5
    
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
    
    func initList(_ buttonItems: [AgoraBoardToolsItem],
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
            lastButtonMaxY = button.agora_height + button.agora_y
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

@objcMembers public class AgoraBoardToolsItem: NSObject {
    var itemType: AgoraBoardToolsItemType
    var tap: ((UIButton) -> Void)?
    
    init(itemType: AgoraBoardToolsItemType,
         tap: ((UIButton) -> Void)? = nil) {
        self.itemType = itemType
        self.tap = tap
    }
}

// MARK: - AgoraBoardToolsView
@objcMembers public class AgoraBoardToolsView: AgoraBaseView {
    fileprivate let cornerRadius: CGFloat = 6
    fileprivate let buttonListView = AgoraButtonListView()
    fileprivate let titleLabel = AgoraBaseUILabel()
    fileprivate let separator = AgoraBaseView()
    fileprivate let unfoldButton = AgoraBaseUIButton()
    
    fileprivate let arrowSize = CGSize(width: 16, height: 8)
    fileprivate lazy var popover = AgoraPopover(options: [.type(.right),
                                                          .blackOverlayColor(.clear),
                                                          .cornerRadius(10),
                                                          .arrowSize(arrowSize),
                                                          .arrowPointerOffset(CGPoint(x: 10, y: 0))])
    
    public var vm: AgoraBoardToolsVM
    public var maxHeight: CGFloat = 0
    
    public init(frame: CGRect,
                vm: AgoraBoardToolsVM) {
        self.vm = vm
        super.init(frame: frame)
        initViews()
    }
    
    public required init?(coder aDecoder: NSCoder) {
        self.vm = AgoraBoardToolsVM()
        super.init(coder: aDecoder)
        initViews()
    }
    
    public override func layoutSubviews() {
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
        let separatorSpace: CGFloat = 7
        let separatorW: CGFloat = bounds.width - (separatorSpace * 2)
        separator.agora_x = separatorSpace
        separator.agora_bottom = 31
        separator.agora_height = 1
        separator.agora_width = separatorW
        
        // unfoldButton
        let unfoldButtonH: CGFloat = separator.agora_bottom - 1
        unfoldButton.agora_x = 0
        unfoldButton.agora_bottom = 0
        unfoldButton.agora_width = bounds.width
        unfoldButton.agora_height = unfoldButtonH
        unfoldButton.contentEdgeInsets = UIEdgeInsets(top: 14,
                                                      left: 16,
                                                      bottom: 10,
                                                      right: 16)
        
        // unfold status frame
        if unfoldButton.isSelected {
            agora_height = maxHeight
            
            // buttonListView
            let buttonListViewContentHeight: CGFloat = CGFloat(buttonListView.buttons.count) * (bounds.width - 10)
            buttonListView.contentSize = CGSize(width: 0,
                                                height: buttonListViewContentHeight)
            
            buttonListView.agora_x = 0
            buttonListView.agora_y = titleLabel.agora_height
            buttonListView.agora_width = bounds.width
            
            let buttonListViewHeight = maxHeight - titleLabel.agora_height - separator.agora_height - unfoldButton.agora_height
            buttonListView.agora_height = buttonListViewHeight
            
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
        unfoldButton.setImage(AgoraImgae(name: "工具栏-收起 拷贝"),
                              for: .normal)
        unfoldButton.setImage(AgoraImgae(name: "工具栏-收起"),
                              for: .selected)
        unfoldButton.addTarget(self,
                               action: #selector(doUnfoldButtonPressed(_:)),
                               for: .touchUpInside)
        unfoldButton.contentMode = .scaleAspectFit
        unfoldButton.isSelected = true
        addSubview(unfoldButton)
    }
    
    func registerToolsItem() {
        self.popover.delegate = self
        self.popover.strokeColor = UIColor(rgb: 0x13196F,
                                           alpha: 0.3)
        self.popover.borderColor = UIColor(rgb: 0x090E51)
        
        let moveItem = AgoraBoardToolsItem(itemType: .move) { [unowned self] (button) in
            self.vmMoveCallBack()
        }
        
        let pencilItem = AgoraBoardToolsItem(itemType: .pencil) { [unowned self] (button) in
            let color = vm.pencilVM.selectedColor
            let lineWidth = vm.pencilVM.selectedLineWidth
            let pencil = vm.pencilVM.selectedPencilType
            
            let view = AgoraPencilPopoverContent(frame: CGRect(x: 0,
                                                               y: 0,
                                                               width: 199 + arrowSize.height,
                                                               height: 114),
                                                 color: color,
                                                 lineWidth: lineWidth,
                                                 pencil: pencil)
            view.colorCollection.colorDelegate = self
            view.lineWidthCollection.lineWidthDelegate = self
            view.pencilTypeCollection.pencilTypeDelegate = self
            self.popover.show(view,
                              fromView: button)
            
            self.vmColorCallBack(color: color,
                                 itemType: .pencil)
            self.vmLineWidthCallBack(lineWidth: lineWidth,
                                     itemType: .pencil)
            self.vmPencilCallBack(pencil: pencil)
        }
        
        let textItem = AgoraBoardToolsItem(itemType: .text) { [unowned self] (button) in
            let color = vm.textVM.selectedColor
            let font = vm.textVM.selectedFont
            
            let view = AgoraTextPopoverrContent(frame: CGRect(x: 0,
                                                              y: 0,
                                                              width: 199 + arrowSize.height,
                                                              height: 148),
                                                color: color,
                                                font: font)
            view.colorCollection.colorDelegate = self
            view.fontCollection.fontDelegate = self
            self.popover.show(view,
                              fromView: button)
            
            self.vmColorCallBack(color: color,
                                 itemType: .text)
            self.vmFontCallBack(font: font)
        }
        
        let rectangleItem = AgoraBoardToolsItem(itemType: .rectangle) { [unowned self] (button) in
            let color = vm.rectangleVM.selectedColor
            let lineWidth = vm.pencilVM.selectedLineWidth
            
            let view = AgoraShapePopoverrContent(frame: CGRect(x: 0,
                                                               y: 0,
                                                               width: 199 + arrowSize.height,
                                                               height: 78),
                                                 shape: .rectangle,
                                                 color: color,
                                                 lineWidth: lineWidth)
            view.colorCollection.colorDelegate = self
            view.lineWidthCollection.lineWidthDelegate = self
            self.popover.show(view,
                              fromView: button)
            
            self.vmColorCallBack(color: color,
                                 itemType: .rectangle)
            self.vmLineWidthCallBack(lineWidth: lineWidth,
                                     itemType: .rectangle)
        }
        
        let circleItem = AgoraBoardToolsItem(itemType: .circle) { [unowned self] (button) in
            let color = vm.circleVM.selectedColor
            let lineWidth = vm.circleVM.selectedLineWidth
            
            let view = AgoraShapePopoverrContent(frame: CGRect(x: 0,
                                                               y: 0,
                                                               width: 199 + arrowSize.height,
                                                               height: 78),
                                                 shape: .circle,
                                                 color: color,
                                                 lineWidth: lineWidth)
            view.colorCollection.colorDelegate = self
            view.lineWidthCollection.lineWidthDelegate = self
            self.popover.show(view,
                              fromView: button)
            
            self.vmColorCallBack(color: color,
                                 itemType: .circle)
            self.vmLineWidthCallBack(lineWidth: lineWidth,
                                     itemType: .circle)
        }
        
        let eraserItem = AgoraBoardToolsItem(itemType: .eraser) { [unowned self] (button) in
            let lineWidth = vm.eraserVM.selectedLineWidth
            
            let view = AgoraEraserPopoverrContent(frame: CGRect(x: 0,
                                                                y: 0,
                                                                width: 199 + arrowSize.height,
                                                                height: 49),
                                                  lineWidth: lineWidth)
            view.lineWidthCollection.lineWidthDelegate = self
            self.popover.show(view,
                              fromView: button)
            
            self.vmLineWidthCallBack(lineWidth: lineWidth,
                                     itemType: .eraser)
        }
        
        let list = [moveItem,
                    pencilItem,
                    textItem,
                    rectangleItem,
                    circleItem,
                    eraserItem]
        
        buttonListView.initList(list,
                                selectedItemIndex: vm.selectedItem.rawValue)
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
    
    func vmColorCallBack(color: AgoraBoardToolsColor,
                         itemType: AgoraBoardToolsItemType) {
        vm.selectedItem = itemType
        
        switch itemType {
        case .pencil:
            vm.pencilVM.selectedColor = color
        case .circle:
            vm.circleVM.selectedColor = color
        case .rectangle:
            vm.rectangleVM.selectedColor = color
        case .text:
            vm.textVM.selectedColor = color
        default:
            fatalError()
        }
        
        vm.delegate?.boardToolsVM(vm,
                                  didSelectColor: color.value,
                                  of: itemType)
    }
    
    func vmLineWidthCallBack(lineWidth: AgoraBoardToolsLineWidth,
                             itemType: AgoraBoardToolsItemType) {
        vm.selectedItem = itemType
        
        switch itemType {
        case .circle:
            vm.circleVM.selectedLineWidth = lineWidth
        case .pencil:
            vm.pencilVM.selectedLineWidth = lineWidth
        case .rectangle:
            vm.rectangleVM.selectedLineWidth = lineWidth
        case .eraser:
            vm.eraserVM.selectedLineWidth = lineWidth
        default:
            fatalError()
        }
        
        vm.delegate?.boardToolsVM(vm,
                                  didSelectLineWidth: lineWidth.value,
                                  of: itemType)
    }
    
    func vmMoveCallBack() {
        vm.selectedItem = .move
        vm.delegate?.boardToolsVMDidSelectMove(self.vm)
    }
    
    func vmPencilCallBack(pencil: AgoraBoardToolsPencilType) {
        vm.selectedItem = .pencil
        vm.pencilVM.selectedPencilType = pencil
        vm.delegate?.boardToolsVM(vm,
                                  didSelectPencil: pencil.rawValue)
    }
    
    func vmFontCallBack(font: AgoraBoardToolsFont) {
        vm.selectedItem = .text
        vm.textVM.selectedFont = font
        vm.delegate?.boardToolsVM(vm,
                                  didSelectFont: font.value)
    }
}

extension AgoraBoardToolsView: AgoraPopoverDelegate {
    func popoverDidDismiss(_ popover: AgoraPopover) {
        
    }
}

// MARK: - Popover content events
extension AgoraBoardToolsView: AgoraColorSelected {
    func demandSide(_ demandSide: AgoraColorCollection.DemandSide,
                    didSelectColor color: AgoraBoardToolsColor) {
        var type: AgoraBoardToolsItemType
        
        switch demandSide {
        case .pencil:    type = .pencil
        case .circle:    type = .circle
        case .rectangle: type = .rectangle
        case .text:      type = .text
        }
        
        vmColorCallBack(color: color,
                        itemType: type)
    }
}

extension AgoraBoardToolsView: AgoraLineWidthSelected {
    func demandSide(_ demandSide: AgoraLineWidthCollection.DemandSide,
                    didSelectLineWidth width: AgoraBoardToolsLineWidth) {
        var type: AgoraBoardToolsItemType
        
        switch demandSide {
        case .circle: type = .circle
        case .pencil: type = .pencil
        case .rectangle: type = .rectangle
        case .eraser: type = .eraser
        }
        
        vmLineWidthCallBack(lineWidth: width,
                            itemType: type)
    }
}

extension AgoraBoardToolsView: AgoraPencilTypeSelected {
    func didSelectPencilType(pencil: AgoraBoardToolsPencilType) {
        vmPencilCallBack(pencil: pencil)
    }
}

extension AgoraBoardToolsView: AgoraFontSelected {
    func didSelectFont(font: AgoraBoardToolsFont) {
        vmFontCallBack(font: font)
    }
}

fileprivate extension AgoraBaseUIButton {
    convenience init(item: AgoraBoardToolsItem) {
        self.init(frame: CGRect.zero)
        
        setImage(item.itemType.image,
                 for: .normal)
        
        setImage(item.itemType.selectedImage,
                 for: .selected)
    }
}
