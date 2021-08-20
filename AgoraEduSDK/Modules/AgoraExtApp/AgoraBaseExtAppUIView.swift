//
//  AgoraBaseExtAppUIView.swift
//  AgoraExtApp
//
//  Created by SRS on 2021/8/20.
//

import AgoraUIBaseViews

@objc public protocol AgoraBaseExtAppUIViewDelegate: NSObjectProtocol {
    // 主动移动
    func extAppUIViewPanTransformed(_ view: AgoraBaseExtAppUIView)
    // 远端移动
    func onExtAppUIViewPositionSync(_ view: AgoraBaseExtAppUIView,
                                    point: CGPoint)
}

@objcMembers open class AgoraBaseExtAppUIView: AgoraBaseUIView {
    
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
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
            self.x = self.frame.origin.x
            self.y = self.frame.origin.y
        }
    }
}
    
