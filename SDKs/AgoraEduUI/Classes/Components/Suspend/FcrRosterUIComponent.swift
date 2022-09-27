//
//  FcrRosterUIComponent.swift
//  AgoraEduUI
//
//  Created by Jonathan on 2022/8/8.
//

import AgoraEduCore
import SwifterSwift
import AgoraWidget
import UIKit

/** 花名册组件父类
 * 1. 花名册的UI布局
 * 2. 花名册通用操作
 * 3. 提供数据源的增删改查方法
 */
class FcrRosterUIComponent: UIViewController {
    
    public var suggestSize: CGSize {
        get {
            // 学生姓名为100，其余为80
            let contentWidth = 80 * supportFuncs.count + 100
            return CGSize(width: contentWidth,
                          height: 253)
        }
    }
    /** 容器*/
    public let contentView = UIView(frame: .zero)
    /** 页面title*/
    private let titleLabel = UILabel(frame: .zero)
    /** 教师信息*/
    private let teacherInfoView = UIView(frame: .zero)
    /** 分割线*/
    private let topSepLine = UIView(frame: .zero)
    private let bottomSepLine = UIView(frame: .zero)
    /** 教师姓名 标签*/
    private let teacherTitleLabel = UILabel(frame: .zero)
    /** 教师姓名 姓名*/
    public let teacherNameLabel = UILabel(frame: .zero)
    /** 学生姓名*/
    private let studentTitleLabel = UILabel(frame: .zero)
    /** 列表项*/
    private let itemTitlesView = UIStackView(frame: .zero)
    /** 表视图*/
    public var tableView = UITableView.init(frame: .zero,
                                            style: .plain)
    /** 数据源*/
    public var dataSource = [AgoraRosterModel]() {
        didSet {
            update(by: dataSource.map({$0.uuid}))
            tableView.reloadData()
        }
    }
    /** 支持的选项列表*/
    public var supportFuncs = [AgoraRosterFunction]() {
        didSet {
            guard supportFuncs != oldValue else {
                return
            }
            updateItemsTitle()
        }
    }
    
    deinit {
        print("\(#function): \(self.classForCoder)")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        initViews()
        initViewFrame()
        updateViewProperties()
    }
    
    // 对用户执行了某个方法
    public func onExcuteFunc(_ fn: AgoraRosterFunction,
                             to model: AgoraRosterModel) {
        // 由子类重写，对具体事件进行实现
    }
    // 更新模型
    public func update(model: AgoraRosterModel) {
        // 由子类重写，具体赋值
    }
}
// MARK: - AgoraUIActivity & AgoraUIContentContainer
@objc extension FcrRosterUIComponent: AgoraUIActivity, AgoraUIContentContainer {
    // AgoraUIActivity
    func viewWillActive() {
        
    }
    func viewWillInactive() {
        
    }
    // AgoraUIContentContainer
    func initViews() {
        view.addSubview(contentView)
        
        titleLabel.text = "fcr_user_list".agedu_localized()
        contentView.addSubview(titleLabel)
        contentView.addSubview(teacherInfoView)
        contentView.addSubview(topSepLine)
        contentView.addSubview(bottomSepLine)
        
        teacherTitleLabel.text = "fcr_user_list_teacher_name".agedu_localized()
        contentView.addSubview(teacherTitleLabel)
        
        contentView.addSubview(teacherNameLabel)
        
        studentTitleLabel.textAlignment = .left
        studentTitleLabel.text = "fcr_user_list_student_name".agedu_localized()
        contentView.addSubview(studentTitleLabel)
        
        itemTitlesView.axis = .horizontal
        itemTitlesView.distribution = .fillEqually
        itemTitlesView.alignment = .center
        contentView.addSubview(itemTitlesView)
        
        tableView.delegate = self
        tableView.dataSource = self
        tableView.tableFooterView = UIView.init(frame: CGRect(x: 0,
                                                              y: 0,
                                                              width: 1,
                                                              height: 0.01))
        tableView.rowHeight = 40
        tableView.allowsSelection = false
        tableView.separatorInset = .zero
        tableView.register(cellWithClass: AgoraUserListItemCell.self)
        contentView.addSubview(tableView)
    }
    
    func initViewFrame() {
        contentView.mas_makeConstraints { make in
            make?.left.right().top().bottom().equalTo()(contentView.superview)
        }
        titleLabel.mas_makeConstraints { make in
            make?.top.equalTo()(titleLabel.superview)
            make?.left.equalTo()(16)
            make?.height.equalTo()(30)
        }
        teacherInfoView.mas_makeConstraints { make in
            make?.top.equalTo()(titleLabel.mas_bottom)
            make?.left.right().equalTo()(teacherInfoView.superview)
            make?.height.equalTo()(30)
        }
        topSepLine.mas_makeConstraints { make in
            make?.top.left().right().equalTo()(teacherInfoView)
            make?.height.equalTo()(1)
        }
        bottomSepLine.mas_makeConstraints { make in
            make?.bottom.left().right().equalTo()(teacherInfoView)
            make?.height.equalTo()(1)
        }
        teacherTitleLabel.mas_makeConstraints { make in
            make?.left.equalTo()(16)
            make?.top.bottom().equalTo()(teacherInfoView)
        }
        teacherNameLabel.mas_makeConstraints { make in
            make?.left.equalTo()(teacherTitleLabel.mas_right)?.offset()(6)
            make?.top.bottom().equalTo()(teacherInfoView)
        }
        studentTitleLabel.mas_makeConstraints { make in
            make?.top.equalTo()(teacherInfoView.mas_bottom)
            make?.left.equalTo()(16)
            make?.height.equalTo()(30)
            make?.width.equalTo()(80)
        }
        itemTitlesView.mas_makeConstraints { make in
            make?.top.equalTo()(studentTitleLabel)
            make?.left.equalTo()(studentTitleLabel.mas_right)
            make?.right.equalTo()(0)
            make?.height.equalTo()(studentTitleLabel)
        }
        tableView.mas_makeConstraints { make in
            make?.left.right().bottom().equalTo()(tableView.superview)
            make?.top.equalTo()(studentTitleLabel.mas_bottom)
        }
    }
    
    func updateViewProperties() {
        let config = UIConfig.roster
        
        view.layer.shadowColor = config.shadow.color
        view.layer.shadowOffset = config.shadow.offset
        view.layer.shadowOpacity = config.shadow.opacity
        view.layer.shadowRadius = config.shadow.radius
        
        contentView.backgroundColor = config.backgroundColor
        contentView.layer.cornerRadius = config.cornerRadius
        contentView.clipsToBounds = true
        contentView.layer.borderWidth = config.borderWidth
        contentView.layer.borderColor = config.borderColor
        
        titleLabel.font = config.label.font
        titleLabel.textColor = config.label.mainTitleColor
        
        topSepLine.backgroundColor = config.sepLine.backgroundColor
        bottomSepLine.backgroundColor = config.sepLine.backgroundColor
        
        teacherInfoView.backgroundColor = config.titleBackgroundColor
        teacherTitleLabel.font = config.label.font
        teacherTitleLabel.textColor = config.label.subTitleColor
        
        teacherNameLabel.font = config.label.font
        teacherNameLabel.textColor = config.label.mainTitleColor
        
        studentTitleLabel.font = config.label.font
        studentTitleLabel.textColor = config.label.subTitleColor
        
        tableView.backgroundColor = config.cellBackgroundColor
        tableView.separatorColor = config.sepLine.backgroundColor
        
        for view in itemTitlesView.arrangedSubviews {
            guard let label = view as? UILabel else {
                return
            }
            label.font = config.label.font
            label.textColor = config.label.subTitleColor
        }
    }
}
// MARK: - Public
extension FcrRosterUIComponent {
    
    func update(by uuids: [String]) {
        if uuids.count == 1 {
            if let model = dataSource.first(where: {$0.uuid == uuids.first}) {
                update(model: model)
            }
        } else {
            dataSource.forEach(where: {uuids.contains($0.uuid)}) { model in
                update(model: model)
            }
        }
    }
    
    public func setupSupportFuncs(_ funcs: [AgoraRosterFunction]) {
        supportFuncs = funcs.enabledList()
        tableView.reloadData()
    }
    
    public func setupTeacherInfo(name: String?) {
        teacherNameLabel.text = name
    }
    // 从列表中移除掉某个用户
    public func remove(by uuid: String) {
        dataSource.removeAll(where: {$0.uuid == uuid})
        tableView.reloadData()
    }
    // 清空列表
    public func removeAll() {
        dataSource.removeAll()
        tableView.reloadData()
    }
    // 获取一个用户的数据并对其手动进行更新
    public func setup(by uuid: String,
                      execution: (AgoraRosterModel) -> Void) {
        if let model = dataSource.first(where: {$0.uuid == uuid}),
           let index = dataSource.firstIndex(where: {$0.uuid == uuid}) {
            execution(model)
            let indexPath = IndexPath(row: index,
                                      section: 0)
            tableView.reloadRows(at: [indexPath],
                                 with: .none)
        }
    }
    // 获取所有用户数据并进行一次更新
    public func setupEach(execution: (AgoraRosterModel) -> Void) {
        for model in dataSource {
            execution(model)
        }
        tableView.reloadData()
    }
    
}
// MARK: - Private
private extension FcrRosterUIComponent {
    func updateItemsTitle() {
        let config = UIConfig.roster
        itemTitlesView.removeArrangedSubviews()
        for fn in supportFuncs {
            let label = UILabel(frame: .zero)
            label.text = fn.title()
            label.textAlignment = .center
            label.font = config.label.font
            label.textColor = config.label.subTitleColor
            switch fn {
            case .stage:
                label.agora_enable = config.stage.enable
                label.agora_visible = config.stage.visible
            case .auth:
                label.agora_enable = config.boardAuthorization.enable
                label.agora_visible = config.boardAuthorization.visible
            case .camera:
                label.agora_enable = config.camera.enable
                label.agora_visible = config.camera.visible
            case .mic:
                label.agora_enable = config.microphone.enable
                label.agora_visible = config.microphone.visible
            case .reward:
                label.agora_enable = config.reward.enable
                label.agora_visible = config.reward.visible
            case .kick:
                label.agora_enable = config.kickOut.enable
                label.agora_visible = config.kickOut.visible
            default:
                break
            }
            itemTitlesView.addArrangedSubview(label)
        }
    }
    
    public func reloadTableView() {
        DispatchQueue.main.async {
            self.tableView.reloadData()
        }
    }
}
// MARK: - PaintingNameRollItemCellDelegate
extension FcrRosterUIComponent: AgoraRosterItemCellDelegate {
    func onDidSelectFunction(_ fn: AgoraRosterFunction,
                             at index: IndexPath) {
        let model = dataSource[index.row]
        onExcuteFunc(fn,
                     to: model)
    }
}
// MARK: - TableView Callback
extension FcrRosterUIComponent: UITableViewDelegate,
                                UITableViewDataSource {
    func tableView(_ tableView: UITableView,
                   numberOfRowsInSection section: Int) -> Int {
        return dataSource.count
    }
    
    func tableView(_ tableView: UITableView,
                   cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withClass: AgoraUserListItemCell.self)
        cell.supportFuncs = self.supportFuncs
        cell.itemModel = self.dataSource[indexPath.row]
        cell.indexPath = indexPath
        cell.delegate = self
        return cell
    }
}
fileprivate extension Array where Element == AgoraRosterFunction {
    func enabledList() -> [AgoraRosterFunction] {
        let config = UIConfig.roster
        
        var list = [AgoraRosterFunction]()
        
        for item in self {
            switch item {
            case .stage:
                if config.stage.enable,
                   config.stage.visible {
                    list.append(item)
                }
            case .auth:
                if config.boardAuthorization.enable,
                   config.boardAuthorization.visible {
                    list.append(item)
                }
            case .camera:
                if config.camera.enable,
                   config.camera.visible {
                    list.append(item)
                }
            case .mic:
                if config.microphone.enable,
                   config.microphone.visible {
                    list.append(item)
                }
            case .reward:
                if config.reward.enable,
                   config.reward.visible {
                    list.append(item)
                }
            case .kick:
                if config.kickOut.enable,
                   config.kickOut.visible {
                    list.append(item)
                }
            default:
                break
            }
        }
        
        return list
    }
}
