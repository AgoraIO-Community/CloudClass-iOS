//
//  AgoraWhiteBoardUIController+UIEvent.swift
//  AgoraUIEduAppViews
//
//  Created by Cavan on 2021/4/19.
//

import UIKit
import AgoraUIEduBaseViews
import AgoraEduContext

// MARK: - Tool view select
extension AgoraWhiteBoardUIController: AgoraPencilTypeSelected {
    public func didSelectPencilType(pencil: AgoraBoardToolsPencilType) {
        boardToolsView.popover.dismiss()
        boardToolsState.selectedPencilType = pencil
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

extension AgoraWhiteBoardUIController: AgoraBoardViewDelegate {
    func didCancelDownloadPressed() {
        guard let url = boardState.downloadingCourseURL else {
            return
        }
        
        boardContext?.cancelDownload(url)
    }
    
    func didCloseDownloadPressed() {
        guard let url = boardState.downloadingCourseURL else {
            return
        }
        
        boardContext?.cancelDownload(url)
    }
    
    func didRetryDownloadPressed() {
        guard let url = boardState.downloadingCourseURL else {
            return
        }
        
        boardContext?.retryDownload(url)
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

// MARK: - Tool view permission state
extension AgoraWhiteBoardUIController {
    func noBoardPermissionTools(_ viewType: AgoraEduContextAppType) {
        switch viewType {
        case .lecture:
            let image = getImage("icon-花名册-default")
            let selectedImage = getImage("icon-花名册-actived")
            
            let studentListItem = AgoraBoardToolsBaseItem(image: image,
                                                          selectedImage: selectedImage) { [unowned self] (button) in
                self.delegate?.whiteBoard(self,
                                          didPresseStudentListButton: button)
            }
            
            var list = [studentListItem]
            
//            if let extApps = extAppItems() {
//                list.append(contentsOf: extApps)
//            }
            
            boardToolsView.registerToolItems(list,
                                              selectedIndex: 0)
            boardToolsView.isHidden = isScreenVisible
            boardToolsViewHeight(animation: true)
        case .small: fallthrough
        case .oneToOne:
            boardToolsView.isHidden = true
        }
    }
    
    func boardPermissionTools(_ viewType: AgoraEduContextAppType) {
        let moveItem = AgoraBoardToolsItem(itemType: .select) { [unowned self] (button) in
            self.boardToolsState.selectedItem = .select
        }
        
        let pencilType: AgoraBoardToolsItemType = .pencil
        
        let pencilItem = AgoraBoardToolsItem(itemType: pencilType) { [unowned self] (button) in
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
                                selectedImage: image) { [unowned self] (button) in
            self.colorButton = button
            self.boardToolsState.selectedItem = .color
            
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
            let studentListSelectedImage = getImage("icon-花名册-actived")
            
            let studentListItem = AgoraBoardToolsBaseItem(image: studentListImage,
                                                          selectedImage: studentListSelectedImage) { [unowned self] (button) in
                self.delegate?.whiteBoard(self,
                                          didPresseStudentListButton: button)
            }
            // 花名册现在放到外面了
//            list.append(studentListItem)
        }
        
//        if let extApps = extAppItems() {
//            list.append(contentsOf: extApps)
//        }
        
        boardToolsView.isHidden = isScreenVisible
        
        boardToolsView.registerToolItems(list,
                                         selectedIndex: self.boardToolsState.selectedItem.rawValue)
        boardToolsViewHeight(animation: true)
    }
    
    func extAppItems() -> [AgoraBoardToolsBaseItem]? {
        guard let appInfos = extAppContext?.getExtAppInfos(),
              appInfos.count > 0 else {
            return nil
        }
        
        var array = [AgoraBoardToolsBaseItem]()
        
        for info in appInfos {
            let item = AgoraBoardToolsBaseItem(image: info.image,
                                               selectedImage: info.selectedImage) { [unowned self] (_) in
                self.extAppContext?.willLaunchExtApp(info.appIdentifier)
            }
            
            array.append(item)
        }
        
        return array
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
        let image = AgoraKitImage(object: self,
                                  resource: "AgoraUIEduAppViews",
                                  name: imageName)
        return image
    }
}
