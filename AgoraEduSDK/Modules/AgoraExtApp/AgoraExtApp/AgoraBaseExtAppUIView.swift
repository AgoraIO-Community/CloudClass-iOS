//
//  AgoraBaseExtAppUIView.swift
//  AgoraExtApp
//
//  Created by SRS on 2021/8/20.
//

import AgoraUIBaseViews

//class AgoraBaseExtAppUIView

@objc public protocol AgoraBaseExtAppUIViewDelegate: NSObjectProtocol {
    // 主动移动
    func extAppUIViewPanTransformed(_ view: AgoraBaseUIView)
    // 远端移动
    func onExtAppUIViewPositionSync(_ view: AgoraBaseUIView,
                                    point: CGPoint)
}

@objcMembers public class AgoraBaseExtAppUIView: AgoraBaseUIView {
    
    public weak var extDelegate: AgoraBaseExtAppUIViewDelegate?
    
    public var x: CGFloat = 0
    public var y: CGFloat = 0
    
    public override func agora_on_pan_transformed() {
        self.extDelegate?.extAppUIViewPanTransformed(self)
    }
    
    public func onExtAppUIViewPositionSync(_ point: CGPoint) {
        self.extDelegate?.onExtAppUIViewPositionSync(self,
                                                     point: point)
    }

    open override func layoutSubviews() {
        super.layoutSubviews()
        // 因为重新设置view的frame后， frame位置会重置。 所以不能通过frame的x、y来计算
        self.x = self.center.x - self.frame.width * 0.5
        self.y = self.center.y - self.frame.height * 0.5
    }
}
    
@objcMembers public class AgoraBaseExtAppUIViewWrapper: NSObject {
    public static func onExtAppUIViewPositionSync(_ view: AgoraBaseUIView,
                                                  point: CGPoint) {
        (view as? AgoraBaseExtAppUIView)?.onExtAppUIViewPositionSync(point)
    }
    public static func x(_ view: AgoraBaseUIView) -> CGFloat {
        return (view as? AgoraBaseExtAppUIView)?.x ?? 0
    }
    public static func y(_ view: AgoraBaseUIView) -> CGFloat {
        return (view as? AgoraBaseExtAppUIView)?.y ?? 0
    }
    public static func isExtAppUIView(_ view: AgoraBaseUIView) -> Bool {
        if let _ = view as? AgoraBaseExtAppUIView {
            return true
        }
        return false
    }
    public static func createExtAppUIView() -> AgoraBaseUIView {
        return AgoraBaseExtAppUIView(frame: CGRect.zero)
    }
    public static func extDelegate(_ view: AgoraBaseUIView,
                                   delegate: AgoraBaseExtAppUIViewDelegate) {
        (view as? AgoraBaseExtAppUIView)?.extDelegate = delegate
    }
}
