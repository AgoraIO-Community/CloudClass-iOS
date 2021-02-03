//
//  AgoraBoardToolsVM.swift
//  AgoraEduSDK
//
//  Created by Cavan on 2021/2/3.
//

import UIKit

// MARK: - AgoraBoardToolsView
@objc public protocol AgoraBoardToolsVMDelegate: NSObjectProtocol {
    func boardToolsVMDidSelectMove(_ vm: AgoraBoardToolsVM)
    
    func boardToolsVM(_ vm: AgoraBoardToolsVM,
                      didSelectColor color: UIColor,
                      of type: AgoraBoardToolsItemType)
    
    func boardToolsVM(_ vm: AgoraBoardToolsVM,
                      didSelectLineWidth width: Int,
                      of type: AgoraBoardToolsItemType)
    
    func boardToolsVM(_ vm: AgoraBoardToolsVM,
                      didSelectPencil pencil: Int)
    
    func boardToolsVM(_ vm: AgoraBoardToolsVM,
                      didSelectFont font: Int)
}
 
@objc protocol AgoraBoardToolsBaseVM: NSObjectProtocol {
    var itemType: AgoraBoardToolsItemType { get }
}

@objcMembers public class AgoraBoardToolsPencilVM: NSObject, AgoraBoardToolsBaseVM {
    let itemType: AgoraBoardToolsItemType = .pencil
    var selectedColor: AgoraBoardToolsColor = .blue
    var selectedLineWidth: AgoraBoardToolsLineWidth = .width1
    var selectedPencilType: AgoraBoardToolsPencilType = .pencil1
}

@objcMembers public class AgoraBoardToolsTextVM: NSObject, AgoraBoardToolsBaseVM {
    let itemType: AgoraBoardToolsItemType = .text
    var selectedColor: AgoraBoardToolsColor = .blue
    var selectedFont: AgoraBoardToolsFont = .font22
}

@objcMembers public class AgoraBoardToolsRectangleVM: NSObject, AgoraBoardToolsBaseVM {
    let itemType: AgoraBoardToolsItemType = .rectangle
    var selectedColor: AgoraBoardToolsColor = .blue
    var selectedLineWidth: AgoraBoardToolsLineWidth = .width1
}

@objcMembers public class AgoraBoardToolsCircleVM: NSObject, AgoraBoardToolsBaseVM {
    let itemType: AgoraBoardToolsItemType = .circle
    var selectedColor: AgoraBoardToolsColor = .blue
    var selectedLineWidth: AgoraBoardToolsLineWidth = .width1
}

@objcMembers public class AgoraBoardToolsEraserVM: NSObject, AgoraBoardToolsBaseVM {
    let itemType: AgoraBoardToolsItemType = .eraser
    var selectedLineWidth: AgoraBoardToolsLineWidth = .width1
}

@objcMembers public class AgoraBoardToolsVM: NSObject {
    var selectedItem: AgoraBoardToolsItemType = .move
    let pencilVM = AgoraBoardToolsPencilVM()
    let textVM = AgoraBoardToolsTextVM()
    let rectangleVM = AgoraBoardToolsRectangleVM()
    let circleVM = AgoraBoardToolsCircleVM()
    let eraserVM = AgoraBoardToolsEraserVM()
    
    public weak var delegate: AgoraBoardToolsVMDelegate?
}
