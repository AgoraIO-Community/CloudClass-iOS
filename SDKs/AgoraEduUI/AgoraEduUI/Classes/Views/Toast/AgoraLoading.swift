//
//  AgoraLoading.swift
//  AgoraUIEduBaseViews
//
//  Created by Jonathan on 2021/11/17.
//

import UIKit
import FLAnimatedImage

public class AgoraLoading: NSObject {
    
    /// loading 视图显示在window上，对应隐藏方法为hide()
    /// - parameter msg: loading附加文本内容
    @objc public static func loading(msg: String? = nil) {
        AgoraLoading.shared.loading(msg: msg)
    }
    /// loading 停止并隐藏
    @objc public static func hide() {
        AgoraLoading.shared.hide()
    }
    /// 往一个视图上添加loading，对应 removeLoading(in view: UIView)
    /// - parameter view: 需要添加loading的View
    @objc public static func addLoading(in view: UIView, msg: String? = nil) {
        guard view != UIApplication.shared.keyWindow else {
            fatalError("use loading(msg: String)")
            return
        }
        for subView in view.subviews {
            if let v = subView as? AgoraLoadingView {
                v.label.text = msg
                return
            }
        }
        let v = AgoraLoadingView(frame: .zero)
        v.label.text = msg
        view.addSubview(v)
        v.mas_makeConstraints { make in
            make?.left.right().top().bottom().equalTo()(0)
        }
        v.startAnimating()
    }
    /// 移除一个视图上的loading
    /// - parameter view: 需要移除loading的View
    @objc public static func removeLoading(in view: UIView) {
        for subView in view.subviews {
            if let v = subView as? AgoraLoadingView {
                v.stopAnimating()
                v.removeFromSuperview()
            }
        }
    }
    
    private static let shared = AgoraLoading()
    
    private lazy var loadingView: AgoraLoadingView = {
        let v = AgoraLoadingView(frame: .zero)
        if let w = UIApplication.shared.keyWindow {
            w.addSubview(v)
        }
        v.mas_makeConstraints { make in
            make?.left.right().top().bottom().equalTo()(0)
        }
        return v
    }()
    
    private var count = 0
    
    private func loading(msg: String?) {
        self.count += 1
        self.loadingView.superview?.bringSubviewToFront(self.loadingView)
        self.loadingView.label.text = msg
        self.loadingView.isHidden = false
        
        self.loadingView.updateLayoutIfNeeded()
        
        self.loadingView.startAnimating()
    }
    
    private func hide() {
        guard self.count != 0 else {
            return
        }
        self.count -= 1
        if count == 0 {
            self.loadingView.isHidden = true
            self.loadingView.stopAnimating()
        }
    }
}

fileprivate class AgoraLoadingView: UIView {
    
    private lazy var contentView = UIView()
    
    public lazy var label = UILabel()
    
    private lazy var animatedView = FLAnimatedImageView()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        self.createViews()
        self.createConstraint()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func updateLayoutIfNeeded() {
        guard let text = label.text else {
            return
        }
        let labelSize = text.agora_size(font: label.font)
        
        var height = min(self.bounds.width, self.bounds.height) * 0.25
        height = height > 90 ? 90 : height
        
        contentView.mas_updateConstraints { make in
            make?.height.equalTo()(height)
        }
        
        var width = contentView.width
        let labelLength = label.text?.agora_size(font: label.font).width ?? 0 + 30 * 2
        
        if labelLength > width {
            width = labelLength
            contentView.mas_updateConstraints { make in
                make?.width.equalTo()(labelLength)
            }
        }
    }
    
    public func startAnimating() {
        animatedView.startAnimating()
    }
    
    public func stopAnimating() {
        animatedView.stopAnimating()
    }
    
    private func createViews() {
        contentView.backgroundColor = .white
        contentView.layer.cornerRadius = 15
        AgoraUIGroup().color.borderSet(layer: contentView.layer)
        addSubview(contentView)
        
        var image: FLAnimatedImage?
        if let url = Bundle.agoraEduUI().url(forResource: "img_loading", withExtension: "gif") {
            let imgData = try? Data(contentsOf: url)
            image = FLAnimatedImage.init(animatedGIFData: imgData)
        }
        animatedView.animatedImage = image
        contentView.addSubview(animatedView)
        
        label.textAlignment = .center
        label.font = UIFont.systemFont(ofSize: 14)
        contentView.addSubview(label)
    }
    
    private func createConstraint() {
        contentView.mas_makeConstraints { make in
            make?.centerX.centerY().equalTo()(self)
            make?.width.height().equalTo()(90)
        }
        animatedView.mas_makeConstraints { make in
            make?.centerX.equalTo()(0)
            make?.top.equalTo()(15)
            make?.width.height().equalTo()(60)
        }
        label.mas_makeConstraints { make in
            make?.centerX.equalTo()(0)
            make?.left.greaterThanOrEqualTo()(30)
            make?.right.greaterThanOrEqualTo()(-30)
            make?.bottom.equalTo()(-15)
        }
    }
}
