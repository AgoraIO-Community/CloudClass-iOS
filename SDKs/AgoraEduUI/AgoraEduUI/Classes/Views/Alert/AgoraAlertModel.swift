//
//  AgoraAlert.swift
//  AgoraUIEduBaseViews
//
//  Created by Jonathan on 2021/12/1.
//

import UIKit
import SwifterSwift

class AgoraAlertTableCell: UITableViewCell {
    static let cellId = NSStringFromClass(AgoraAlertTableCell.self)
    
    private let optionImageView = UIImageView()
    
    let optionLabel = UILabel()
    
    var optionIsSelected: Bool = false {
        didSet {
            setOptionImage()
        }
    }
    
    override init(style: UITableViewCell.CellStyle,
                  reuseIdentifier: String?) {
        super.init(style: style,
                   reuseIdentifier: reuseIdentifier)
        initViews()
        initViewFrame()
        updateViewProperties()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setOptionImage() {
        optionImageView.image = UIImage.agedu_named(optionIsSelected ? "ic_alert_checked" : "ic_alert_unchecked")
    }
}

// MARK: - AgoraUIContentContainer
extension AgoraAlertTableCell: AgoraUIContentContainer {
    func initViews() {
        selectionStyle = .none
        
        optionLabel.numberOfLines = 0
        
        addSubviews([optionImageView,
                     optionLabel])
    }
    
    func initViewFrame() {
        let horizontalSpace: CGFloat = 15
        
        optionImageView.mas_makeConstraints { make in
            make?.left.equalTo()(horizontalSpace)
            make?.centerY.equalTo()(0)
            make?.width.height().equalTo()(12)
        }
        
        let spacing = AgoraFrameGroup().fcr_alert_side_spacing
        optionLabel.mas_makeConstraints { make in
            make?.centerY.equalTo()(0)
            make?.left.equalTo()(spacing)
            make?.right.equalTo()(-spacing)
            make?.bottom.equalTo()(-0)
        }
    }
    
    func updateViewProperties() {
        optionLabel.font = AgoraUIGroup().font.fcr_font13
    }
}

public class AgoraAlertModel: NSObject {
    
    public enum Style {
        case Normal, Choice
    }
    
    fileprivate var alertStyle: Style = .Normal
    
    fileprivate var image: UIImage?
    
    fileprivate var imageSize: CGSize = .zero
    
    fileprivate var title: String?
    
    fileprivate var message: String?
    
    fileprivate var actions = [AgoraAlertAction]()
    /// 设置弹窗的头部图片及大小
    @discardableResult
    public func setImage(_ image: UIImage, size: CGSize) -> AgoraAlertModel {
        self.image = image
        self.imageSize = size
        return self
    }
    /// 设置弹窗的标题
    @discardableResult
    public func setStyle(_ style: AgoraAlertModel.Style) -> AgoraAlertModel {
        self.alertStyle = style
        return self
    }
    /// 设置弹窗的标题
    @discardableResult
    public func setTitle(_ title: String) -> AgoraAlertModel {
        self.title = title
        return self
    }
    /// 设置弹窗的详细信息
    @discardableResult
    public func setMessage(_ message: String) -> AgoraAlertModel {
        self.message = message
        return self
    }
    /// 增加一个弹窗选项
    @discardableResult
    public func addAction(action: AgoraAlertAction) -> AgoraAlertModel {
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

private class AgoraAlertController: UIViewController {
    
    private var model: AgoraAlertModel
    
    private var contentView: UIView!
    
    private var imageView: UIImageView!
    
    private var titleLabel: UILabel!
    
    // choice only
    private lazy var tableView: UITableView = {
        let tab = UITableView(frame: .zero,
                              style: .plain)
        tab.separatorStyle = .none
        tab.isScrollEnabled = false
        tab.rowHeight = 22
        tab.register(AgoraAlertTableCell.self,
                     forCellReuseIdentifier: AgoraAlertTableCell.cellId)
        tab.delegate = self
        tab.dataSource = self
        return tab
    }()
    
    // normal only
    private lazy var messageLabel: UILabel = {
        let messageLabel = UILabel()
        messageLabel.text = model.message
        messageLabel.numberOfLines = 0
        let ui = AgoraUIGroup()
        messageLabel.font = ui.font.fcr_font13
        messageLabel.textColor = FcrColorGroup.fcr_text_level2_color
        messageLabel.textAlignment = .center
        return messageLabel
    }()
    
    private var hLine: UIView!
    
    private let buttonStartTag = 66788
    
    init(model: AgoraAlertModel) {
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
        
        switch model.alertStyle {
        case .Choice:
            createChoiceButtons()
        default:
            createActionButtons()
        }
    }
    
    @objc func onClickActionButton(_ sender: UIButton) {
        let index = sender.tag - buttonStartTag
        var action: AgoraAlertAction?
        switch model.alertStyle {
        case .Choice:
            if index == 1 {
                action = model.actions.first(where: {$0.isSelected == true})
            }
        default:
            action = model.actions[index]
        }
        self.dismiss(animated: true, completion: nil)
        action?.callBack?()
    }
}

// MARK: - UITableView delegate & dataSource
extension AgoraAlertController: UITableViewDelegate, UITableViewDataSource {
    // UITableViewDelegate
    public func tableView(_ tableView: UITableView,
                          numberOfRowsInSection section: Int) -> Int {
        return model.actions.count
    }
    
    public func tableView(_ tableView: UITableView,
                          cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        var cell: UITableViewCell
        
        let cellId = AgoraAlertTableCell.cellId
        let optionCell = tableView.dequeueReusableCell(withIdentifier: cellId,
                                                       for: indexPath) as! AgoraAlertTableCell
        
        let action = model.actions[indexPath.row]
        optionCell.optionLabel.text = action.title
        optionCell.optionIsSelected = action.isSelected
        
        cell = optionCell
        
        return cell
    }
    
    // UITableViewDelegate
    public func tableView(_ tableView: UITableView,
                          didSelectRowAt indexPath: IndexPath) {
        for index in 0 ..< model.actions.count {
            model.actions[index].isSelected = (index == indexPath.row)
        }
        tableView.reloadData()
    }
    
    public func tableView(_ tableView: UITableView,
                          heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 34
    }
}

extension AgoraAlertController: AgoraUIContentContainer {
    func initViews() {
        contentView = UIView()
        view.addSubview(contentView)
        
        imageView = UIImageView()
        contentView.addSubview(imageView)
        
        titleLabel = UILabel()
        titleLabel.text = model.title
        titleLabel.numberOfLines = 1
        titleLabel.textAlignment = .center
        contentView.addSubview(titleLabel)
        
        hLine = UIView()
        
        contentView.addSubview(hLine)
        
        switch model.alertStyle {
        case .Choice:
            contentView.addSubview(tableView)
        default:
            contentView.addSubview(messageLabel)
        }
    }
    
    func initViewFrame() {
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
            make?.left.equalTo()(30)
            make?.right.equalTo()(-30)
        }
        
        switch model.alertStyle {
        case .Choice:
            tableView.mas_makeConstraints { make in
                make?.top.equalTo()(titleLabel.mas_bottom)?.offset()(14)
                make?.height.equalTo()(model.actions.count * 34)
                make?.left.equalTo()(20)
                make?.right.equalTo()(-20)
            }
        default:
            messageLabel.mas_makeConstraints { make in
                make?.top.equalTo()(titleLabel.mas_bottom)?.offset()(14)
                make?.left.equalTo()(30)
                make?.right.equalTo()(-30)
            }
        }
    }
    
    func updateViewProperties() {
        let ui = AgoraUIGroup()
        
        FcrColorGroup.borderSet(layer: contentView.layer)
        
        contentView.backgroundColor = FcrColorGroup.fcr_system_component_color
        contentView.layer.cornerRadius = ui.frame.fcr_alert_corner_radius
        
        titleLabel.font = ui.font.fcr_font17
        titleLabel.textColor = FcrColorGroup.fcr_text_level1_color
        
        view.backgroundColor = UIColor.black.withAlphaComponent(0.2)
        hLine.backgroundColor = FcrColorGroup.fcr_system_divider_color
    }
}
// MARK: - private
private extension AgoraAlertController {
    
    private func createChoiceButtons() {
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
            make?.top.equalTo()(tableView.mas_bottom)?.offset()(20)
        }

        self.model.actions[0].isSelected = true
        makeTwoButtons(firstLabel: "fcr_alert_cancel".agedu_localized(),
                       secondLabel: "fcr_alert_sure".agedu_localized())
    }
    
    private func createActionButtons() {
        let ui = AgoraUIGroup()
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
            button.titleLabel?.font = ui.font.fcr_font17
            button.setTitle(action?.title,
                            for: .normal)
            button.setTitleColor(FcrColorGroup.fcr_text_enabled_color,
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
                    line.backgroundColor = FcrColorGroup.fcr_system_divider_color
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
        line.backgroundColor = FcrColorGroup.fcr_system_divider_color
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
        let ui = AgoraUIGroup()
        let button = UIButton(type: .custom)
        button.tag = buttonStartTag + index
        button.titleLabel?.font = ui.font.fcr_font17
        button.setTitle(title,
                        for: .normal)
        button.setTitleColor(FcrColorGroup.fcr_text_enabled_color,
                             for: .normal)
        button.addTarget(self,
                         action: #selector(onClickActionButton(_:)),
                         for: .touchUpInside)
        return button
    }
}
