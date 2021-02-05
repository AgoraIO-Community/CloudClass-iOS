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
 
@objc public protocol AgoraBoardToolsBaseVM: NSObjectProtocol {
    var itemType: AgoraBoardToolsItemType { get }
}

@objcMembers public class AgoraBoardToolsPencilVM: NSObject, AgoraBoardToolsBaseVM {
    public let itemType: AgoraBoardToolsItemType = .pencil
    public var selectedColor: AgoraBoardToolsColor = .blue
    public var selectedLineWidth: AgoraBoardToolsLineWidth = .width1
    public var selectedPencilType: AgoraBoardToolsPencilType = .pencil1
}

@objcMembers public class AgoraBoardToolsTextVM: NSObject, AgoraBoardToolsBaseVM {
    public let itemType: AgoraBoardToolsItemType = .text
    public var selectedColor: AgoraBoardToolsColor = .blue
    public var selectedFont: AgoraBoardToolsFont = .font22
}

@objcMembers public class AgoraBoardToolsRectangleVM: NSObject, AgoraBoardToolsBaseVM {
    public let itemType: AgoraBoardToolsItemType = .rectangle
    public var selectedColor: AgoraBoardToolsColor = .blue
    public var selectedLineWidth: AgoraBoardToolsLineWidth = .width1
}

@objcMembers public class AgoraBoardToolsCircleVM: NSObject, AgoraBoardToolsBaseVM {
    public let itemType: AgoraBoardToolsItemType = .circle
    public var selectedColor: AgoraBoardToolsColor = .blue
    public var selectedLineWidth: AgoraBoardToolsLineWidth = .width1
}

@objcMembers public class AgoraBoardToolsEraserVM: NSObject, AgoraBoardToolsBaseVM {
    public let itemType: AgoraBoardToolsItemType = .eraser
    public var selectedLineWidth: AgoraBoardToolsLineWidth = .width1
}

@objcMembers public class AgoraBoardToolsVM: NSObject {
    public var selectedItem: AgoraBoardToolsItemType = .move
    public let pencilVM = AgoraBoardToolsPencilVM()
    public let textVM = AgoraBoardToolsTextVM()
    public let rectangleVM = AgoraBoardToolsRectangleVM()
    public let circleVM = AgoraBoardToolsCircleVM()
    public let eraserVM = AgoraBoardToolsEraserVM()
    
    public weak var delegate: AgoraBoardToolsVMDelegate?
}
