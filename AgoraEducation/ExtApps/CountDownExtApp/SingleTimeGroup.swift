//
//  SingleTimeGroup.swift
//  AgoraEducation
//
//  Created by LYY on 2021/5/11.
//  Copyright © 2021 Agora. All rights reserved.
//

import Foundation
import AgoraUIBaseViews

@objcMembers class SingleTimeGroup: AgoraBaseUIView {
    
    private lazy var bottomView: SingleTimeView = SingleTimeView(frame: .zero)
    private lazy var oriUp: SingleTimeView = SingleTimeView(frame: .zero)
    private lazy var oriDown: SingleTimeView = SingleTimeView(frame: .zero)
    private lazy var newDown: SingleTimeView = SingleTimeView(frame: .zero)
    private lazy var lineImgView = AgoraBaseUIImageView(image: UIImage(named: "line-\(UIDevice.current.model)"))
    
    private var timeStr: String = "" {
        didSet {
            guard oldValue != timeStr else {
                return
            }
            
            bottomView.updateLabel(str: timeStr)
            oriUp.updateLabel(str: oldValue)
            oriDown.updateLabel(str: oldValue)
            newDown.updateLabel(str: timeStr)
            
            rotation()
        }
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        initView()
        initLayout()
        initMask()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: rotation
    @objc func rebaseABC(){
        oriUp.alpha = 0
        oriDown.alpha = 0
        newDown.alpha = 0
    }
    
    func rotation(){
        oriUp.alpha = 1
        oriDown.alpha = 1
        newDown.alpha = 0
        
        rotationFirst(view: oriUp)
        rotationSecond(view: newDown)
        perform(#selector(rebaseABC), with: nil, afterDelay: 0.9)
    }
    
    func rotationFirst(view:UIView){
        //旧值标签，先出来
        let animation = CABasicAnimation(keyPath: "transform.rotation.x")
        animation.fromValue = (-10/360)*Double.pi
        animation.toValue = (-355/360)*Double.pi
        animation.duration = 1.0
        animation.repeatCount = 0
        animation.delegate = self as? CAAnimationDelegate
        view.layer.add(animation, forKey: "rotationSecond")
        view.alpha = 1
    }

    func rotationSecond(view:UIView) {
        //新值标签，后
        let animation = CABasicAnimation(keyPath: "transform.rotation.x")
        animation.fromValue  = (355/360) * Double.pi
        animation.toValue = (10/360) * Double.pi
        animation.duration = 1.0
        animation.repeatCount = 0
        animation.delegate = self as? CAAnimationDelegate
        view.layer.add(animation, forKey: "rotationFirst")
        view.alpha = 1
    }

}

// MARK: public
extension SingleTimeGroup {
    public func updateStr(str: String) {
        timeStr = str
    }
    public func turnColor(color: UIColor) {
        for timeView in [bottomView,oriUp,oriDown,newDown] {
            timeView.turnColor(color: color)
        }
    }
}

// MARK: private
fileprivate extension SingleTimeGroup {
    private func initView() {
        addSubview(bottomView)
        addSubview(oriUp)
        addSubview(oriDown)
        addSubview(newDown)
        addSubview(lineImgView)
        self.isUserInteractionEnabled = false
    }
    
    private func initLayout() {
        bottomView.agora_x = 0
        bottomView.agora_y = 0
        bottomView.agora_right = 0
        bottomView.agora_bottom = 0
        
        oriUp.agora_x = 0
        oriUp.agora_y = 0
        oriUp.agora_right = 0
        oriUp.agora_bottom = 0
        
        oriDown.agora_x = 0
        oriDown.agora_y = 0
        oriDown.agora_right = 0
        oriDown.agora_bottom = 0
        
        newDown.agora_x = 0
        newDown.agora_y = 0
        newDown.agora_right = 0
        newDown.agora_bottom = 0
        
        lineImgView.agora_center_x = 0
        lineImgView.agora_center_y = 0
    }
    
    private func initMask() {
        guard let image = UIImage(named: "bg_\(UIDevice.current.model)") else {
            return
        }
        let maskWidth = image.size.width
        let maskHeight = image.size.height / 2
        oriUp.maskLayerWithRect(rect: CGRect(x: 0,
                                        y: 0,
                                        width: maskWidth,
                                        height: maskHeight))

        oriDown.maskLayerWithRect(rect: CGRect(x: 0,
                                        y: maskHeight,
                                        width: maskWidth,
                                        height: maskHeight))

        newDown.maskLayerWithRect(rect: CGRect(x: 0,
                                               y: maskHeight,
                                               width: maskWidth,
                                               height: maskHeight))
    }
}


fileprivate extension AgoraBaseUIView {
    func maskLayerWithRect(rect: CGRect){
        // 底层
        let basicPath = UIBezierPath(rect: self.frame)
        //自定义的遮罩图形
        let maskPath = UIBezierPath(rect: rect)
        
        let maskLayer = CAShapeLayer()
        maskLayer.fillRule = .evenOdd //  奇偶层显示规则
        
        //重叠
        basicPath.append(maskPath)
        maskLayer.path = basicPath.cgPath
        self.layer.mask = maskLayer
    }
}
