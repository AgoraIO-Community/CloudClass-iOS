//
//  AgoraWhiteBoardUIController+State.swift
//  AgoraUIEduAppViews
//
//  Created by Cavan on 2021/4/19.
//

import UIKit
import AgoraUIEduBaseViews
import AgoraUIBaseViews
import AgoraEduContext

// MARK: - AgoraBoardToolsStateDelegate
extension AgoraWhiteBoardUIController: AgoraBoardToolsStateDelegate {
    func toolsState(_ state: AgoraBoardToolsState,
                    didUpdatePremission hasPermission: Bool,
                    userInteractionEnabled: Bool) {
        if hasPermission {
            boardPermissionTools(viewType)
            // 默认选择clicker
            boardToolsState.selectedItem = .clicker
            boardToolsState.selectedColor = boardToolsState.selectedColor
        } else {
            noBoardPermissionTools(viewType)
        }
        
        boardToolsView.isUserInteractionEnabled = userInteractionEnabled
    }
    
    func toolsState(_ state: AgoraBoardToolsState,
                    didUpdateSelectedItem item: AgoraBoardToolsItemType) {
        switch item {
        case .select:
            boardToolContext?.applianceSelected(.select)
        case .pencil:
            boardToolContext?.applianceSelected(state.selectedPencilType.applianceType)
        case .eraser:
            boardToolContext?.applianceSelected(.eraser)
        case .clicker:
            boardToolContext?.applianceSelected(.clicker)
        case .text:
            boardToolContext?.fontSizeSelected(boardToolsState.selectedFont.value)
        default:
            break
        }
    }
    
    func toolsState(_ state: AgoraBoardToolsState,
                    didUpdateSelectedPencilType type: AgoraBoardToolsPencilType) {
        boardToolContext?.applianceSelected(type.applianceType)
    }
    
    func toolsState(_ state: AgoraBoardToolsState,
                    didUpdateSelectedFont font: AgoraBoardToolsFont) {
        boardToolContext?.fontSizeSelected(font.value)
    }
    
    func toolsState(_ state: AgoraBoardToolsState,
                    didUpdateSelectedColor color: AgoraBoardToolsColor) {
        boardToolContext?.colorSelected(color.value)
    }
    
    func toolsState(_ state: AgoraBoardToolsState, didUpdateSelectedLineWidth width: Int) {
        boardToolContext?.thicknessSelected(width)
    }
}

// MARK: - AgoraWhiteBoardStateDelegate
extension AgoraWhiteBoardUIController: AgoraWhiteBoardStateDelegate {
    func boardStateDidUpdate(_ state: AgoraWhiteBoardState) {
        boardPageControl.setFullScreen(state.isFullScreen)
        delegate?.whiteBoard(self,
                             willUpdateDisplayMode: state.isFullScreen)
        boardContext?.boardRefreshSize()
    }
}

extension AgoraWhiteBoardUIController: AgoraBoardPageControlStateDelegate {
    func pageControlStateDidUpdate(_ state: AgoraBoardPageControlState) {
        boardPageControl.isUserInteractionEnabled = state.isUserInteractionEnabled
        
        boardPageControl.setPagingEnable(state.pagingEnable)
        boardPageControl.setResizeFullScreenEnable(state.fullScreenEnable)
        boardPageControl.setZoomEnable(state.zoomEnable,
                                       zoomInEnable: state.zoomEnable)
    }
}

fileprivate extension AgoraBoardToolsPencilType {
    var applianceType: AgoraEduContextApplianceType {
        switch self {
        case .pencil:    return .pen
        case .circle:    return .circle
        case .rectangle: return .rect
        case .line:      return .line
        }
    }
}

fileprivate extension AgoraBoardToolsItemType {
    var applianceType: AgoraEduContextApplianceType {
        switch self {
        case .pencil:  return .pen
        case .eraser:  return .eraser
        case .select:  return .select
        case .clicker: return .clicker
        case .color:  fatalError()
        case .text:   fatalError()
        }
    }
}
