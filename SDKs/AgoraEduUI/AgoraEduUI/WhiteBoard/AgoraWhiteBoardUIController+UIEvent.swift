//
//  AgoraWhiteBoardUIController+UIEvent.swift
//  AgoraEduUI
//
//  Created by Cavan on 2021/4/19.
//

import AgoraUIEduBaseViews
import AgoraEduContext

// MARK: - Tool view select
extension AgoraWhiteBoardUIController: AgoraPencilTypeSelected {
    public func didSelectPencilType(pencil: AgoraBoardToolsPencilType) {
        boardToolsView.popover.dismiss()
        boardToolsState.selectedPencilType = pencil
        setPencilButtonImage(pencil: pencil)
    }
    
    func setPencilButtonImage(pencil: AgoraBoardToolsPencilType) {
        pencilButton?.setImage(pencil.image,
                               for: .normal)
        pencilButton?.setImage(pencil.selectedImage,
                               for: .selected)
    }
}

extension AgoraWhiteBoardUIController: AgoraFontSelected {
    public func didSelectFont(font: AgoraBoardToolsFont) {
        boardToolsView.popover.dismiss()
        boardToolsState.selectedFont = font
    }
}

extension AgoraWhiteBoardUIController: AgoraToolsViewColorSelected {
    public func didSelectColor(_ color: AgoraBoardToolsColor) {
        boardToolsView.popover.dismiss()
        setColorButtonImage(color)
        boardToolsState.selectedColor = color
    }
    
    func setColorButtonImage(_ color: AgoraBoardToolsColor) {
        let image = getColorImage(color)
        
        colorButton?.setImage(image,
                 for: .normal)
        colorButton?.setImage(image,
                 for: .selected)
    }
}

extension AgoraWhiteBoardUIController: AgoraToolsViewLineWidthSelected {
    public func didSelectLineWidth(_ width: Int) {
        boardToolsState.selectedLineWidth = width
    }
}

// MARK: - Page control click
extension AgoraWhiteBoardUIController: AgoraBoardPageControlDelegate {
    public func didFullScreenEvent(isFullScreen: Bool) {
        boardState.isFullScreen = isFullScreen
    }
    
    public func didPrePageTouchEvent(_ prePage: Int) {
        boardPageControlContext?.prevPage()
    }
    
    public func didNextPageTouchEvent(_ nextPage: Int) {
        boardPageControlContext?.nextPage()
    }
    
    public func didIncreaseTouchEvent() {
        boardPageControlContext?.zoomIn()
    }
    
    public func didDecreaseTouchEvent() {
        boardPageControlContext?.zoomOut()
    }
}

// MARK: - AgoraUserListUIControllerDelegate
extension AgoraWhiteBoardUIController: AgoraUserListUIControllerDelegate {
    func controller(_ controller: AgoraUserListUIController,
                    didShowContainer show: Bool) {
        let studentListImage = getImage("icon-花名册-default")
        let studentListSelectedImage = getImage("icon-花名册-actived")
        
        let image = show ? studentListSelectedImage : studentListImage
        userListButton?.setImage(image,
                                 for: .normal)
        
    }
}

// MARK: - Tool view permission state
extension AgoraWhiteBoardUIController {
    func noBoardPermissionTools(_ viewType: AgoraEduContextRoomType) {
        switch viewType {
        case .small: fallthrough
        case .lecture:
            let studentListImage = getImage("icon-花名册-default")
            
            let studentListItem = AgoraBoardToolsBaseItem(image: studentListImage,
                                                          canSelected: false) { [unowned self] (button) in
                self.userListButton = button
                
                self.delegate?.whiteBoard(self,
                                          didPresseStudentListButton: button)
                
            }
            
            var list = [studentListItem]
            
            boardToolsView.registerToolItems(list,
                                             selectedIndex: 0)
            boardToolsView.isHidden = false
            boardToolsViewHeight(animation: true)
        case .oneToOne:
            boardToolsView.isHidden = true
        }
    }
    
    func boardPermissionTools(_ viewType: AgoraEduContextRoomType) {
        let moveItem = AgoraBoardToolsItem(itemType: .select) { [unowned self] (button) in
            self.boardToolsState.selectedItem = .select
        }
        
        let pencilType: AgoraBoardToolsItemType = .pencil
        
        let pencilItem = AgoraBoardToolsItem(itemType: pencilType) { [unowned self] (button) in
            self.pencilButton = button
            self.boardToolsState.selectedItem = .pencil
            
            let toolsView = self.boardToolsView
            let pencil = self.boardToolsState.selectedPencilType
            
            let view = AgoraPencilPopoverContent(frame: CGRect(x: 0,
                                                               y: 0,
                                                               width: 156 + toolsView.popover.arrowSize.height,
                                                               height: 42),
                                                 pencil: pencil)
            
            view.pencilTypeCollection.pencilTypeDelegate = self
            
            toolsView.popover.show(view,
                                   fromView: button)
        }
        
        let textType: AgoraBoardToolsItemType = .text
        
        let textItem = AgoraBoardToolsItem(itemType: textType) { [unowned self] (button) in
            self.boardToolsState.selectedItem = .text
            
            let toolsView = self.boardToolsView
            let font = self.boardToolsState.selectedFont

            let view = AgoraTextPopoverrContent(frame: CGRect(x: 0,
                                                              y: 0,
                                                              width: 186,
                                                              height: 86),
                                                font: font)

            view.fontCollection.fontDelegate = self
            toolsView.popover.show(view,
                              fromView: button)
        }
                
        let eraserItem = AgoraBoardToolsItem(itemType: .eraser) { [unowned self] (button) in
            self.boardToolsState.selectedItem = .eraser
        }
        
        let color = self.boardToolsState.selectedColor
        let image = getColorImage(color)
        
        let colorItem = AgoraBoardToolsBaseItem(image: image,
                                                selectedImage: image,
                                                canSelected: false) { [unowned self] (button) in
            self.colorButton = button
            
            let toolsView = self.boardToolsView
            let color = self.boardToolsState.selectedColor

            let view = AgoraColorPopoverrContent(frame: CGRect(x: 0,
                                                               y: 0,
                                                               width: 145,
                                                               height: 143),
                                                 color: color,
                                                 lineWidth: 0)

            let min = self.boardToolsState.lineWidthRange.min
            let max = self.boardToolsState.lineWidthRange.max
            let selected = self.boardToolsState.selectedLineWidth
            
            view.lineWidthSlider.minimumValue = Float(min)
            view.lineWidthSlider.maximumValue = Float(max)
            view.lineWidthSlider.value = Float(selected)
            
            view.colorCollection.colorDelegate = self
            view.lineWidthSlider.lineWidthSelected = self
            
            toolsView.popover.show(view,
                                   fromView: button)
        }
        
        let clicker = AgoraBoardToolsItem(itemType: .clicker) { [unowned self] (button) in
            self.boardToolsState.selectedItem = .clicker
        }
        
        var list = [clicker,
                    moveItem,
                    pencilItem,
                    textItem,
                    eraserItem,
                    colorItem]
        
        if viewType != .oneToOne {
            let studentListImage = getImage("icon-花名册-default")
            
            let studentListItem = AgoraBoardToolsBaseItem(image: studentListImage,
                                                          canSelected: false) { [unowned self] (button) in
                self.userListButton = button
                
                self.delegate?.whiteBoard(self,
                                          didPresseStudentListButton: button)
            }
            list.append(studentListItem)
        }
        
        boardToolsView.isHidden = false
        
        boardToolsView.registerToolItems(list,
                                         selectedIndex: boardToolsState.selectedItem.rawValue)
        boardToolsViewHeight(animation: true)
    }
}

// MARK: - Tools view hide or show
extension AgoraWhiteBoardUIController {
    func didFoldAnimation(_ isFold: Bool) {
        if isFold {
            boardToolsView.agora_x = -150
        } else {
            unfoldButton.agora_x = -150
        }
        
        let duration = TimeInterval.agora_animation
        
        UIView.animate(withDuration: duration) { [unowned self] in
            self.containerView.layoutIfNeeded()
        } completion: { [unowned self] (isCompletion) in
            if isFold {
                self.unfoldButton.agora_x = -42
            } else {
                self.boardToolsView.agora_x = 10
            }
            
            UIView.animate(withDuration: duration) { [unowned self] in
                self.containerView.layoutIfNeeded()
            } completion: { [unowned self] (isCompletion) in
                if isCompletion, !isFold {
                    self.boardToolsView.isFold = false
                }
            }
        }
    }
    
    @objc func doUnfolodButton() {
        didFoldAnimation(false)
    }
}

private extension AgoraWhiteBoardUIController {
    func getColorImage(_ color: AgoraBoardToolsColor) -> UIImage? {
        let imageName = "icon-color-#\(color.intString.uppercased())-more"
        return getImage(imageName)
    }
    
    func getImage(_ imageName: String) -> UIImage? {
        let image = AgoraUIImage(object: self,
                                 name: imageName)
        return image
    }
}

fileprivate extension AgoraBoardToolsPencilType {
    var image: UIImage? {
        switch self {
        case .pencil:    return AgoraKitImage("画笔icon-未选")
        case .rectangle: return AgoraKitImage("矩形icon-未选")
        case .circle:    return AgoraKitImage("圆形icon-未选")
        case .line:      return AgoraKitImage("直线icon-未选")
        }
    }
    
    var selectedImage: UIImage? {
        switch self {
        case .pencil:    return AgoraKitImage("画笔icon-已选")
        case .rectangle: return AgoraKitImage("矩形icon-已选")
        case .circle:    return AgoraKitImage("圆形icon-已选")
        case .line:      return AgoraKitImage("直线icon-已选")
        }
    }
}
