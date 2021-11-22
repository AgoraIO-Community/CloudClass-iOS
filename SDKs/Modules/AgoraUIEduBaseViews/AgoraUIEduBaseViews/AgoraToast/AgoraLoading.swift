//
//  AgoraLoading.swift
//  AgoraUIEduBaseViews
//
//  Created by Jonathan on 2021/11/17.
//

import UIKit

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
    
    private var contentView: UIView!
    
    public var label: UILabel!
    
    private var loadingView: AgoraFLAnimatedImageView!
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        self.createViews()
        self.createConstrains()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        let size = min(self.bounds.width, self.bounds.height) * 0.25
        self.contentView.frame = CGRect(x: 0, y: 0, width: size, height: size)
        self.contentView.layer.cornerRadius = size * 0.12
        self.contentView.center = self.center
    }
    
    public func startAnimating() {
        loadingView.startAnimating()
    }
    
    public func stopAnimating() {
        loadingView.stopAnimating()
    }
    
    private func createViews() {
        contentView = UIView()
        contentView.backgroundColor = .white
        contentView.layer.cornerRadius = 15
        contentView.layer.shadowColor = UIColor(rgb: 0x2F4192,
                                                alpha: 0.15).cgColor
        contentView.layer.shadowOffset = CGSize(width: 0,
                                                height: 2)
        contentView.layer.shadowOpacity = 1
        contentView.layer.shadowRadius = 6
        addSubview(contentView)
        
        var image: AgoraFLAnimatedImage?
        if let bundle = Bundle.agoraUIEduBaseBundle() {
            if let url = bundle.url(forResource: "loading", withExtension: "gif") {
                let imgData = try? Data(contentsOf: url)
                image = AgoraFLAnimatedImage.init(animatedGIFData: imgData)
            }
        }
        loadingView = AgoraFLAnimatedImageView()
        loadingView.animatedImage = image
        contentView.addSubview(loadingView)
        
        label = UILabel()
        label.textAlignment = .center
        label.font = UIFont.systemFont(ofSize: 14)
        contentView.addSubview(label)
    }
    
    private func createConstrains() {
        loadingView.mas_makeConstraints { make in
            make?.centerX.equalTo()(0)
            make?.centerY.equalTo()(0)
            make?.width.height().equalTo()(contentView)?.multipliedBy()(0.62)
        }
        label.mas_makeConstraints { make in
            make?.left.right().equalTo()(0)
            make?.bottom.equalTo()(-5)
        }
    }
}
