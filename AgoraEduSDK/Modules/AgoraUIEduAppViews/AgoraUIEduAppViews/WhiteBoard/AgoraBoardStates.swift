//
//  AgoraBoardStates.swift
//  AgoraEduSDK
//
//  Created by Cavan on 2021/2/3.
//

import UIKit
import AgoraUIEduBaseViews

// MARK: - AgoraWhiteBoardState
@objc public protocol AgoraWhiteBoardStateDelegate: NSObjectProtocol {
    func boardStateDidUpdate(_ state: AgoraWhiteBoardState)
}

@objcMembers public class AgoraWhiteBoardState: NSObject {
    public var isFullScreen: Bool = false {
        didSet {
            callDelegateFunc()
        }
    }
    
    public var downloadingCourseURL: String?
    
    public weak var delegate: AgoraWhiteBoardStateDelegate?
    
    private func callDelegateFunc() {
        delegate?.boardStateDidUpdate(self)
    }
}

// MARK: - AgoraPageControlState
@objc public protocol AgoraBoardPageControlStateDelegate: NSObjectProtocol {
    func pageControlStateDidUpdate(_ state: AgoraBoardPageControlState)
}

@objcMembers public class AgoraBoardPageControlState: NSObject {
    public var isUserInteractionEnabled: Bool = true {
        didSet {
            callDelegateFunc()
        }
    }
    
    public var fullScreenEnable: Bool = true {
        didSet {
            callDelegateFunc()
        }
    }
    
    public var zoomEnable: Bool = true {
        didSet {
            callDelegateFunc()
        }
    }
    
    public var pagingEnable: Bool = true {
        didSet {
            callDelegateFunc()
        }
    }
    
    public weak var delegate: AgoraBoardPageControlStateDelegate?
    
    private func callDelegateFunc() {
        delegate?.pageControlStateDidUpdate(self)
    }
}

@objc public class AgoraBoardToolsLineWidthRange: NSObject {
    public var min: Int = 1
    public var max: Int = 32
}

// MARK: - AgoraBoardToolsState
@objc public protocol AgoraBoardToolsStateDelegate: NSObjectProtocol {
    func toolsState(_ state: AgoraBoardToolsState,
                    didUpdatePremission hasPermission: Bool,
                    userInteractionEnabled: Bool)
    
    func toolsState(_ state: AgoraBoardToolsState,
                    didUpdateSelectedItem item: AgoraBoardToolsItemType)
    
    func toolsState(_ state: AgoraBoardToolsState,
                    didUpdateSelectedPencilType type: AgoraBoardToolsPencilType)
    
    func toolsState(_ state: AgoraBoardToolsState,
                    didUpdateSelectedFont font: AgoraBoardToolsFont)
    
    func toolsState(_ state: AgoraBoardToolsState,
                    didUpdateSelectedColor color: AgoraBoardToolsColor)
    
    func toolsState(_ state: AgoraBoardToolsState,
                    didUpdateSelectedLineWidth width: Int)
}

@objcMembers public class AgoraBoardToolsState: NSObject {
    public var hasPermission: Bool = false {
        didSet {
            delegate?.toolsState(self,
                                 didUpdatePremission: hasPermission,
                                 userInteractionEnabled: isUserInteractionEnabled)
        }
    }
    
    public var isUserInteractionEnabled: Bool = true {
        didSet {
            delegate?.toolsState(self,
                                 didUpdatePremission: hasPermission,
                                 userInteractionEnabled: isUserInteractionEnabled)
        }
    }
    
    public var selectedItem: AgoraBoardToolsItemType = .clicker  {
        didSet {
            delegate?.toolsState(self,
                                 didUpdateSelectedItem: selectedItem)
        }
    }
    
    public var selectedPencilType: AgoraBoardToolsPencilType = .pencil  {
        didSet {
            delegate?.toolsState(self,
                                 didUpdateSelectedPencilType: selectedPencilType)
        }
    }
    
    public var selectedFont: AgoraBoardToolsFont = .font22  {
        didSet {
            delegate?.toolsState(self,
                                 didUpdateSelectedFont: selectedFont)
        }
    }
    
    public var selectedColor: AgoraBoardToolsColor = .blue  {
        didSet {
            delegate?.toolsState(self,
                                 didUpdateSelectedColor: selectedColor)
        }
    }
    
    public var selectedLineWidth: Int = 16  {
        didSet {
            delegate?.toolsState(self,
                                 didUpdateSelectedLineWidth: selectedLineWidth)
        }
    }
    
    public weak var delegate: AgoraBoardToolsStateDelegate?
    
    public let lineWidthRange = AgoraBoardToolsLineWidthRange()
}
