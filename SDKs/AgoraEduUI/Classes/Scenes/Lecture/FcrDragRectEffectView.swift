//
//  FcrDragRectEffectView.swift
//  AgoraEduUI
//
//  Created by Jonathan on 2022/8/23.
//

import UIKit

/** 可容纳区Rect区域
 */
struct FcrRectEffectArea: Equatable {
    // 区域的位置及大小
    let areaRect: CGRect
    // 初始化显示出effectView的大小，在区域变更时初始化显示出的视图大小
    let initSize: CGSize
    // 最小缩放大小，有值则代表可以缩放，且有最小缩放大小
    let zoomMinSize: CGSize?
    
    static func == (lhs: Self, rhs: Self) -> Bool {
        return lhs.areaRect == rhs.areaRect
    }
}
/*** 区域预览视图
 * 会根据用户设置和传入的落点，展示拖拽视图的位置预览
 */
class FcrDragRectEffectView: UIView {
    
    private enum DragType {
        case center, leftTop, rightTop, leftBottom, rightBottom
    }
    
    public let effectView = UIView(frame: .zero)
    
    private var areas = [FcrRectEffectArea]()
    
    private var from: FcrRectEffectArea?
    
    private var currentArea: FcrRectEffectArea?
    
    private var dragType = DragType.center
    // 起始拖拽点
    private var originPoint = CGPoint.zero
    // 用于计算的原始拖拽区域
    private var originRect = CGRect.zero
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        effectView.backgroundColor = UIColor.black
        effectView.alpha = 0.3
        effectView.layer.borderWidth = 0.5
        effectView.layer.borderColor = UIColor.white.cgColor
        addSubview(effectView)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    // 显示预览区域并划分区域
    func startEffect(with areas: [FcrRectEffectArea],
                     from rect: CGRect,
                     at point: CGPoint) {
        self.areas = areas
        originRect = rect
        originPoint = point
        isHidden = false
        effectView.frame = rect
        
        guard let area = areas.first(where: {$0.areaRect.contains(point)})
        else {
            return
        }
        from = area
        currentArea = area
        if area.zoomMinSize != nil {
            updateDragType(with: rect,
                           point: point)
        } else {
            dragType = .center
        }
    }
    // 设置effecView落点
    func setDropPoint(_ point: CGPoint) {
        let moveSize = CGSize(width: point.x - originPoint.x,
                              height: point.y - originPoint.y)
        if dragType == .center,
           let area = areas.first(where: {$0.areaRect.contains(point)}) { // 拖动
            if currentArea != area { // 跨区域拖动
                currentArea = area
                let rect = CGRect(center: point,
                                  size: area.initSize)
                originRect = rect
                originPoint = point
                relocationAndSetup(rect)
            } else { // 非跨区域拖动
                let rect = moveRect(with: moveSize)
                relocationAndSetup(rect)
            }
        }
        if dragType != .center { // 缩放
            let rect = zoomRect(with: moveSize)
            relocationAndSetup(rect)
        }
    }
    // 获取rect在某个视图上的落点
    func getDropRectInView(_ view: UIView) -> CGRect {
        return self.convert(effectView.frame,
                            to: view)
    }
    /** 停止展示区域预览效果
     * @return Bool 前后区域是否发生改变
     */
    @discardableResult
    func stopEffect() -> Bool {
        self.isHidden = true
        self.areas.removeAll()
        guard let fromArea = from,
              let toArea = currentArea
        else {
            from = nil
            currentArea = nil
            return false
        }
        from = nil
        currentArea = nil
        return (fromArea.areaRect != toArea.areaRect)
    }
}

private extension FcrDragRectEffectView {
    
    func moveRect(with size: CGSize) -> CGRect {
        return CGRect(x: originRect.minX + size.width,
                      y: originRect.minY + size.height,
                      width: originRect.size.width,
                      height: originRect.size.height)
    }
    
    func zoomRect(with size: CGSize) -> CGRect {
        var rect = originRect
        guard let minSize = currentArea?.zoomMinSize else {
            return rect
        }
        switch dragType {
        case .leftTop:
            var x = originRect.minX + size.width
            var width = originRect.size.width - size.width
            if width < minSize.width {
                x = originRect.minX
                width = minSize.width
            }
            
            var y = originRect.minY + size.height
            var height = originRect.size.height - size.height
            if height < minSize.height {
                y = originRect.minY
                height = minSize.height
            }
            rect = CGRect(x: x,
                          y: y,
                          width: width,
                          height: height)
        case .rightTop:
            var width = originRect.size.width + size.width
            width = width < minSize.width ? minSize.width : width
            height = height < minSize.height ? minSize.height : height
            if width < minSize.width {
                width = minSize.width
            }
            
            var y = originRect.minY + size.height
            var height = originRect.size.height - size.height
            if height < minSize.height {
                y = originRect.minY
                height = minSize.height
            }
            
            rect = CGRect(x: originRect.minX,
                          y: y,
                          width: width,
                          height: height)
        case .leftBottom:
            var x = originRect.minX + size.width
            var width = originRect.size.width - size.width
            if width < minSize.width {
                x = originRect.minX
                width = minSize.width
            }
            
            var height = originRect.size.height + size.height
            if height < minSize.height {
                height = minSize.height
            }
            
            rect = CGRect(x: x,
                          y: originRect.minY,
                          width: width,
                          height: height)
        case .rightBottom:
            var width = originRect.size.width + size.width
            if width < minSize.width {
                width = minSize.width
            }
            var height = originRect.size.height + size.height
            if height < minSize.height {
                height = minSize.height
            }
            rect = CGRect(x: originRect.minX,
                          y: originRect.minY,
                          width: width,
                          height: height)
        default:
            break
        }
        return rect
    }
    
    func relocationAndSetup(_ rect: CGRect) {
        guard let area = currentArea else {
            return
        }
        var frame = rect
        if !area.areaRect.contains(frame) {
            // 区域超出，重新计算effectView落点
            if frame.width > area.areaRect.width {
                frame.size.width = area.areaRect.size.width
            }
            if frame.height > area.areaRect.height {
                frame.size.height = area.areaRect.size.height
            }
            if frame.minX < area.areaRect.minX {
                frame.origin.x = area.areaRect.minX
            }
            if frame.maxX > area.areaRect.maxX {
                let offset = frame.maxX - area.areaRect.maxX
                frame.origin.x = frame.origin.x - offset
            }
            if frame.minY < area.areaRect.minY {
                frame.origin.y = area.areaRect.minY
            }
            if frame.maxY > area.areaRect.maxY {
                let offset = frame.maxY - area.areaRect.maxY
                frame.origin.y = frame.origin.y - offset
            }
        }
        effectView.frame = frame
    }
    
    func updateDragType(with rect: CGRect,
                        point: CGPoint) {
        let corner = 40.0
        // Left, Right, Top, Bottom
        let cornerRectLT = CGRect(x: rect.minX,
                                  y: rect.minY,
                                  width: corner,
                                  height: corner)
        let cornerRectRT = CGRect(x: rect.maxX - corner,
                                  y: rect.minY,
                                  width: corner,
                                  height: corner)
        let cornerRectLB = CGRect(x: rect.minX,
                                  y: rect.maxY - corner,
                                  width: corner,
                                  height: corner)
        let cornerRectRB = CGRect(x: rect.maxX - corner,
                                  y: rect.maxY - corner,
                                  width: corner,
                                  height: corner)
        if cornerRectLT.contains(point) {
            dragType = .leftTop
        } else if cornerRectRT.contains(point) {
            dragType = .rightTop
        } else if cornerRectLB.contains(point) {
            dragType = .leftBottom
        } else if cornerRectRB.contains(point) {
            dragType = .rightBottom
        } else {
            dragType = .center
        }
    }
}
