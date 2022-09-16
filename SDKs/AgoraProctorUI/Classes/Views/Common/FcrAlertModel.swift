//
//  FcrAlertModel.swift
//  AgoraProctorUI
//
//  Created by LYY on 2022/9/7.
//

import AgoraUIBaseViews
import SwifterSwift
import UIKit

public class FcrAlertModel: NSObject {
    
    fileprivate var image: UIImage?
    
    fileprivate var imageSize: CGSize = .zero
    
    fileprivate var title: String?
    
    fileprivate var message: String?
    
    fileprivate var actions = [FcrAlertModelAction]()
    /// 设置弹窗的头部图片及大小
    @discardableResult
    public func setImage(_ image: UIImage, size: CGSize) -> FcrAlertModel {
        self.image = image
        self.imageSize = size
        return self
    }
    /// 设置弹窗的标题
    @discardableResult
    public func setTitle(_ title: String) -> FcrAlertModel {
        self.title = title
        return self
    }
    /// 设置弹窗的详细信息
    @discardableResult
    public func setMessage(_ message: String) -> FcrAlertModel {
        self.message = message
        return self
    }
    /// 增加一个弹窗选项
    @discardableResult
    public func addAction(action: FcrAlertModelAction) -> FcrAlertModel {
        actions.append(action)
        return self
    }
    /// 展示弹窗
    public func show(in viewCotroller: UIViewController) {
        let vc = FcrAlertModelController(model: self)
        vc.modalPresentationStyle = .overFullScreen
        vc.modalTransitionStyle = .crossDissolve
        viewCotroller.present(vc,
                              animated: true,
                              completion: nil)
    }
}

public class FcrAlertModelAction: NSObject {
    
    var isSelected = false
    
    fileprivate var title: String?
    
    fileprivate var callBack: (() -> Void)?
    
    public init(title: String? = nil,
                action: (() -> Void)? = nil) {
        super.init()
        self.title = title
        self.callBack = action
    }
    
}

private class FcrAlertModelController: UIViewController {
    
    private var model: FcrAlertModel
    
    private var contentView: UIView!
        
    private var titleLabel: UILabel!
    
    private var buttonList = [UIButton]()
    
    // data
    private let alertWidth: CGFloat = 315
    private let sideGap: CGFloat = 15
    private let buttonGap: CGFloat = 11
    
    private lazy var messageLabel: UILabel = {
        let messageLabel = UILabel()
        messageLabel.text = model.message
        messageLabel.numberOfLines = 0
        
        messageLabel.textAlignment = .center
        return messageLabel
    }()
        
    private let buttonStartTag = 66788
    
    init(model: FcrAlertModel) {
        self.model = model
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        initViews()
        initViewFrame()
        updateViewProperties()
        
        createActionButtons()
    }
    
    @objc func onClickActionButton(_ sender: UIButton) {
        let index = sender.tag - buttonStartTag
        var action = model.actions[index]
        self.dismiss(animated: true,
                     completion: nil)
        action.callBack?()
    }
}

extension FcrAlertModelController: AgoraUIContentContainer {
    func initViews() {
        contentView = UIView()
        view.addSubview(contentView)
        
        titleLabel = UILabel()
        titleLabel.text = model.title
        titleLabel.numberOfLines = 1
        titleLabel.textAlignment = .center
        contentView.addSubview(titleLabel)
                        
        contentView.addSubview(messageLabel)
    }
    
    func initViewFrame() {
        contentView.mas_makeConstraints { make in
            make?.width.equalTo()(315)
            make?.height.mas_greaterThanOrEqualTo()(136)
            make?.height.mas_lessThanOrEqualTo()(300)
            make?.center.equalTo()(0)
        }
        titleLabel.mas_makeConstraints { make in
            make?.top.equalTo()(20)
            make?.left.equalTo()(30)
            make?.right.equalTo()(-30)
        }
        messageLabel.mas_makeConstraints { make in
            make?.top.equalTo()(titleLabel.mas_bottom)?.offset()(14)
            make?.left.equalTo()(30)
            make?.right.equalTo()(-30)
        }
    }
    
    func updateViewProperties() {
        let config = UIConfig.alert
        
        contentView.layer.shadowColor = config.shadow.color
        contentView.layer.shadowOffset = config.shadow.offset
        contentView.layer.shadowOpacity = config.shadow.opacity
        contentView.layer.shadowRadius = config.shadow.radius
        
        contentView.backgroundColor = config.backgroundColor
        contentView.layer.cornerRadius = config.cornerRadius
        
        titleLabel.font = config.title.font
        titleLabel.textColor = config.title.color
                
        messageLabel.font = config.message.font
        messageLabel.textColor = config.message.normalColor
    }
}
// MARK: - private
private extension FcrAlertModelController {
    private func createActionButtons() {
        guard model.actions.count > 0 else {
            return
        }
        
        let config = UIConfig.alert.button
        let singleWidth: CGFloat = (alertWidth - sideGap * 2 + buttonGap) / CGFloat(model.actions.count) - buttonGap
        
        for (index, action) in model.actions.enumerated() {
            var title: String? = nil
            if model.actions.count > index {
                title = model.actions[index].title
            }
            let button = generateButton(title: title,
                                        index: index)
            button.tag = buttonStartTag + index
            button.titleLabel?.font = config.font
            button.setTitle(title,
                            for: .normal)
            if index == model.actions.count - 1 {
                button.backgroundColor = config.highlightBackgroundColor
                button.setTitleColor(config.highlightTitleColor,
                                     for: .normal)
            } else {
                button.backgroundColor = config.normalBackgroundColor
                button.setTitleColor(config.normalTitleColor,
                                     for: .normal)
            }
            
            button.addTarget(self,
                             action: #selector(onClickActionButton(_:)),
                             for: .touchUpInside)
            buttonList.append(button)
            contentView.addSubview(button)
            
            let left = sideGap + CGFloat(index) * (singleWidth + buttonGap)
            
            let buttonHeight: CGFloat = 40
            button.layer.cornerRadius = buttonHeight / 2
            button.mas_makeConstraints { make in
                make?.top.equalTo()(messageLabel.mas_bottom)?.offset()(31)
                make?.left.equalTo()(left)
                make?.height.equalTo()(40)
                make?.width.equalTo()(singleWidth)
                make?.bottom.equalTo()(contentView.mas_bottom)?.offset()(-14)
            }
        }
    }
    
    func generateButton(title: String?,
                        index: Int) -> UIButton {
        let config = UIConfig.alert.button
        
        let button = UIButton(type: .custom)
        button.tag = buttonStartTag + index
        button.titleLabel?.font = config.font
        button.setTitle(title,
                        for: .normal)
        button.setTitleColor(config.normalTitleColor,
                             for: .normal)
        button.addTarget(self,
                         action: #selector(onClickActionButton(_:)),
                         for: .touchUpInside)
        return button
    }
}
