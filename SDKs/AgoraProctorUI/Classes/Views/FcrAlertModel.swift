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
    
    // normal only
    private lazy var messageLabel: UILabel = {
        let messageLabel = UILabel()
        messageLabel.text = model.message
        messageLabel.numberOfLines = 0
        
        messageLabel.textAlignment = .center
        return messageLabel
    }()
    
    private var hLine: UIView!
    
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
        
        hLine = UIView()
        
        contentView.addSubview(hLine)
        
        contentView.addSubview(messageLabel)
    }
    
    func initViewFrame() {
        contentView.mas_makeConstraints { make in
            make?.width.equalTo()(270)
            make?.height.mas_greaterThanOrEqualTo()(100)
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
        
        hLine.backgroundColor = config.sepLine.backgroundColor
        
        messageLabel.font = config.message.font
        messageLabel.textColor = config.message.normalColor
    }
}
// MARK: - private
private extension FcrAlertModelController {
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
        
        let config = UIConfig.alert.button
        if model.actions.count == 1 {
            let action = model.actions.first
            let button = UIButton(type: .custom)
            button.tag = buttonStartTag
            button.titleLabel?.font = config.font
            button.setTitle(action?.title,
                            for: .normal)
            button.setTitleColor(config.normalTitleColor,
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
            makeTwoButtons(firstLabel: model.actions[0].title,
                           secondLabel: model.actions[1].title)
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
                    line.backgroundColor = UIConfig.alert.sepLine.backgroundColor
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
    
    func makeTwoButtons(firstLabel: String?,
                        secondLabel: String?) {
        let firstButton = generateButton(title: firstLabel, index: 0)
        contentView.addSubview(firstButton)
        firstButton.mas_makeConstraints { make in
            make?.top.equalTo()(hLine.mas_bottom)
            make?.left.equalTo()(0)
            make?.right.equalTo()(contentView.mas_centerX)
            make?.height.equalTo()(44)
        }
        let secondButton = generateButton(title: secondLabel, index: 1)
        contentView.addSubview(secondButton)
        secondButton.mas_makeConstraints { make in
            make?.top.equalTo()(hLine.mas_bottom)
            make?.right.equalTo()(0)
            make?.left.equalTo()(contentView.mas_centerX)
            make?.height.equalTo()(44)
        }
        let line = UIView()
        line.backgroundColor = UIConfig.alert.sepLine.backgroundColor
        contentView.addSubview(line)
        line.mas_makeConstraints { make in
            make?.top.equalTo()(hLine.mas_bottom)
            make?.centerX.equalTo()(0)
            make?.width.equalTo()(1)
            make?.height.equalTo()(44)
            make?.bottom.equalTo()(contentView.mas_bottom)
        }
    }
    
    func generateButton(title: String?, index: Int) -> UIButton {
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
