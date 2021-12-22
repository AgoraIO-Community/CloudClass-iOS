//
//  AgoraAlert.swift
//  AgoraUIEduBaseViews
//
//  Created by Jonathan on 2021/12/1.
//

import UIKit

public class AgoraAlert: NSObject {
    
    fileprivate var image: UIImage?
    
    fileprivate var imageSize: CGSize = .zero
    
    fileprivate var title: String?
    
    fileprivate var message: String?
    
    fileprivate var actions = [AgoraAlertAction]()
    /// 设置弹窗的头部图片及大小
    @discardableResult
    public func setImage(_ image: UIImage, size: CGSize) -> AgoraAlert {
        self.image = image
        self.imageSize = size
        return self
    }
    /// 设置弹窗的标题
    @discardableResult
    public func setTitle(_ title: String) -> AgoraAlert {
        self.title = title
        return self
    }
    /// 设置弹窗的详细信息
    @discardableResult
    public func setMessage(_ message: String) -> AgoraAlert {
        self.message = message
        return self
    }
    /// 增加一个弹窗选项
    @discardableResult
    public func addAction(action: AgoraAlertAction) -> AgoraAlert {
        actions.append(action)
        return self
    }
    /// 展示弹窗
    public func show(in viewCotroller: UIViewController) {
        let vc = AgoraAlertController(model: self)
        vc.modalPresentationStyle = .overFullScreen
        vc.modalTransitionStyle = .crossDissolve
        viewCotroller.present(vc,
                              animated: true,
                              completion: nil)
    }
}

public class AgoraAlertAction: NSObject {
    
    fileprivate var title: String?
    
    fileprivate var callBack: (() -> Void)?
    
    public init(title: String? = nil, action: (() -> Void)? = nil) {
        super.init()
        self.title = title
        self.callBack = action
    }
    
}

private class AgoraAlertController: UIViewController {
    
    private var model: AgoraAlert
    
    private var contentView: UIView!
    
    private var imageView: UIImageView!
    
    private var titleLabel: UILabel!
    
    private var messageLabel: UILabel!
    
    private var hLine: UIView!
    
    private let buttonStartTag = 66788
        
    init(model: AgoraAlert) {
        self.model = model
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        createViews()
        createConstrains()
        createActionButtons()
    }
    
    @objc func onClickActionButton(_ sender: UIButton) {
        let index = sender.tag - buttonStartTag
        let action = model.actions[index]
        self.dismiss(animated: true, completion: nil)
        action.callBack?()
    }
    
    private func createViews() {
        self.view.backgroundColor = UIColor.white.withAlphaComponent(0.6)
        
        contentView = UIView()
        contentView.backgroundColor = .white
        contentView.layer.cornerRadius = 12
        contentView.layer.shadowOpacity = 1
        contentView.layer.shadowRadius = 6
        contentView.layer.shadowColor = UIColor(hex: 0x2F4192,
                                                transparency: 0.15)?.cgColor
        contentView.layer.shadowOffset = CGSize(width: 0,
                                                height: 2)
        view.addSubview(contentView)
        
        imageView = UIImageView()
        contentView.addSubview(imageView)
        
        titleLabel = UILabel()
        titleLabel.text = model.title
        titleLabel.numberOfLines = 1
        titleLabel.font = UIFont.systemFont(ofSize: 17)
        titleLabel.textColor = UIColor(hex: 0x030303)
        titleLabel.textAlignment = .center
        contentView.addSubview(titleLabel)
        
        messageLabel = UILabel()
        messageLabel.text = model.message
        messageLabel.numberOfLines = 0
        messageLabel.font = UIFont.systemFont(ofSize: 13)
        messageLabel.textColor = UIColor(hex: 0x586376)
        messageLabel.textAlignment = .center
        contentView.addSubview(messageLabel)
    }
    
    private func createConstrains() {
        contentView.mas_makeConstraints { make in
            make?.width.equalTo()(240)
            make?.height.mas_greaterThanOrEqualTo()(100)
            make?.center.equalTo()(0)
        }
        imageView.mas_makeConstraints { make in
            make?.top.equalTo()(20)
            make?.size.equalTo()(model.imageSize)
            make?.centerX.equalTo()(0)
        }
        titleLabel.mas_makeConstraints { make in
            make?.top.equalTo()(imageView.mas_bottom)
            make?.left.equalTo()(20)
            make?.right.equalTo()(-20)
        }
        messageLabel.mas_makeConstraints { make in
            make?.top.equalTo()(titleLabel.mas_bottom)?.offset()(14)
            make?.left.equalTo()(20)
            make?.right.equalTo()(-20)
        }
        hLine = UIView()
        hLine.backgroundColor = UIColor(hex: 0xEEEEF7)
        contentView.addSubview(hLine)
    }
    
    private func createActionButtons() {
        guard model.actions.count > 0 else {
            hLine.mas_makeConstraints { make in
                make?.left.right().equalTo()(0)
                make?.height.equalTo()(1)
                make?.top.equalTo()(messageLabel.mas_bottom)?.offset()(20)
                make?.bottom.equalTo()(self.contentView)
            }
            return
        }
        hLine.mas_makeConstraints { make in
            make?.left.right().equalTo()(0)
            make?.height.equalTo()(1)
            make?.top.equalTo()(messageLabel.mas_bottom)?.offset()(20)
        }
        if model.actions.count == 1 {
            let action = model.actions.first
            let button = UIButton(type: .custom)
            button.tag = buttonStartTag
            button.titleLabel?.font = UIFont.systemFont(ofSize: 17)
            button.setTitle(action?.title,
                            for: .normal)
            button.setTitleColor(UIColor(hex: 0x357BF6),
                                 for: .normal)
            button.addTarget(self,
                             action: #selector(onClickActionButton(_:)),
                             for: .touchUpInside)
            contentView.addSubview(button)
            button.mas_makeConstraints { make in
                make?.top.equalTo()(hLine.mas_bottom)
                make?.left.right().equalTo()(0)
                make?.height.equalTo()(44)
                make?.bottom.equalTo()(contentView.mas_bottom)
            }
        } else if model.actions.count == 2 {
            let firstAction = model.actions[0]
            let firstButton = generateButton(title: firstAction.title, index: 0)
            contentView.addSubview(firstButton)
            firstButton.mas_makeConstraints { make in
                make?.top.equalTo()(hLine.mas_bottom)
                make?.left.equalTo()(0)
                make?.right.equalTo()(contentView.mas_centerX)
                make?.height.equalTo()(44)
            }
            let secondAction = model.actions[1]
            let secondButton = generateButton(title: secondAction.title, index: 1)
            contentView.addSubview(secondButton)
            secondButton.mas_makeConstraints { make in
                make?.top.equalTo()(hLine.mas_bottom)
                make?.right.equalTo()(0)
                make?.left.equalTo()(contentView.mas_centerX)
                make?.height.equalTo()(44)
            }
            let line = UIView()
            line.backgroundColor = UIColor(hex: 0xEEEEF7)
            contentView.addSubview(line)
            line.mas_makeConstraints { make in
                make?.top.equalTo()(hLine.mas_bottom)
                make?.centerX.equalTo()(0)
                make?.width.equalTo()(1)
                make?.height.equalTo()(44)
                make?.bottom.equalTo()(contentView.mas_bottom)
            }
        } else {
            var previous: UIView?
            for (index, action) in model.actions.enumerated() {
                let lastOne = (index == model.actions.count - 1)
                let button = generateButton(title: action.title, index: index)
                contentView.addSubview(button)
                button.mas_makeConstraints { make in
                    if let v = previous {
                        make?.top.equalTo()(v.mas_bottom)
                    } else {
                        make?.top.equalTo()(hLine.mas_bottom)
                    }
                    make?.left.right().equalTo()(0)
                    make?.height.equalTo()(44)
                    if lastOne {
                        make?.bottom.equalTo()(self.contentView)
                    }
                }
                if lastOne == false {
                    let line = UIView()
                    line.backgroundColor = UIColor(hex: 0xEEEEF7)
                    contentView.addSubview(line)
                    previous = line
                    line.mas_makeConstraints { make in
                        make?.top.equalTo()(button.mas_bottom)
                        make?.left.right().equalTo()(0)
                        make?.height.equalTo()(1)
                    }
                }
            }
        }
    }
    
    func generateButton(title: String?, index: Int) -> UIButton {
        let button = UIButton(type: .custom)
        button.tag = buttonStartTag + index
        button.titleLabel?.font = UIFont.systemFont(ofSize: 17)
        button.setTitle(title,
                        for: .normal)
        button.setTitleColor(UIColor(hex: 0x357BF6),
                             for: .normal)
        button.addTarget(self,
                         action: #selector(onClickActionButton(_:)),
                         for: .touchUpInside)
        return button
    }
}
