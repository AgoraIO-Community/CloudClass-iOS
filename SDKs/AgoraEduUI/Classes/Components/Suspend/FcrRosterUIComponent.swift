//
//  FcrRosterUIComponent.swift
//  AgoraEduUI
//
//  Created by Jonathan on 2022/8/8.
//

import AgoraEduContext
import SwifterSwift
import AgoraWidget
import UIKit

/** 花名册组件父类
 * 1. 花名册的UI布局
 * 2. 花名册通用操作
 * 3. 提供数据源的增删改查方法
 */
class FcrRosterUIComponent: UIViewController {
    public let userController: AgoraEduUserContext
    public let streamController: AgoraEduStreamContext
    public let widgetController: AgoraEduWidgetContext
    
    public var suggestSize: CGSize {
        get {
            // 学生姓名为100，其余为80
            let contentWidth = 80 * supportFuncs.count + 100
            return CGSize(width: contentWidth,
                          height: 253)
        }
    }
    /** 容器*/
    private lazy var contentView = UIView(frame: .zero)
    /** 页面title*/
    private lazy var titleLabel = UILabel(frame: .zero)
    /** 教师信息*/
    private lazy var teacherInfoView = UIView(frame: .zero)
    /** 分割线*/
    private lazy var topSepLine = UIView(frame: .zero)
    private lazy var bottomSepLine = UIView(frame: .zero)
    /** 教师姓名 标签*/
    public var teacherTitleLabel = UILabel(frame: .zero)
    /** 教师姓名 姓名*/
    public var teacherNameLabel = UILabel(frame: .zero)
    /** 学生姓名*/
    private lazy var studentTitleLabel = UILabel(frame: .zero)
    /** 列表项*/
    private lazy var itemTitlesView = UIStackView(frame: .zero)
    /** 轮播 仅教师端*/
    private lazy var carouselTitleLabel: UILabel = {
        let label = UILabel(frame: .zero)
        label.text = "fcr_user_list_carousel_setting".agedu_localized()
        return label
    }()
    private lazy var carouselSwitch: UISwitch = {
        let carouselSwitch = UISwitch()
        carouselSwitch.transform = CGAffineTransform(scaleX: 0.59,
                                                     y: 0.59)
        carouselSwitch.isOn = userController.getCoHostCarouselInfo().state
        carouselSwitch.addTarget(self,
                                 action: #selector(onClickCarouselSwitch(_:)),
                                 for: .touchUpInside)
        return carouselSwitch
    }()
    
    /** 表视图*/
    private var tableView = UITableView.init(frame: .zero,
                                             style: .plain)
    /** 数据源*/
    private var dataSource = [AgoraRosterModel]()
    /** 支持的选项列表*/
    public var supportFuncs = [AgoraRosterFunction]() {
        didSet {
            guard supportFuncs != oldValue else {
                return
            }
            updateItemsTitle()
        }
    }
    
    open var carouselEnable: Bool {
        return false
    }
    
    deinit {
        print("\(#function): \(self.classForCoder)")
    }
    init(userController: AgoraEduUserContext,
         streamController: AgoraEduStreamContext,
         widgetController: AgoraEduWidgetContext) {
        self.userController = userController
        self.streamController = streamController
        self.widgetController = widgetController
        
        super.init(nibName: nil,
                   bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
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
        
        if carouselEnable {
            contentView.addSubview(carouselTitleLabel)
            contentView.addSubview(carouselSwitch)
        }
        let config = UIConfig.roster
        carouselSwitch.agora_enable = config.carousel.enable
        carouselSwitch.agora_visible = config.carousel.visible
        
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
        if carouselEnable {
            carouselSwitch.mas_makeConstraints { make in
                make?.centerY.equalTo()(teacherNameLabel.mas_centerY)
                make?.right.equalTo()(-10)
                make?.height.equalTo()(30)
            }
            carouselTitleLabel.mas_makeConstraints { make in
                make?.centerY.equalTo()(teacherNameLabel.mas_centerY)
                make?.right.equalTo()(carouselSwitch.mas_left)
                make?.height.equalTo()(30)
            }
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
        
        if carouselEnable {
            carouselTitleLabel.font = config.label.font
            carouselTitleLabel.textColor = config.label.subTitleColor
            
            carouselSwitch.onTintColor = config.carousel.tintColor
        }
    }
}
// MARK: - Public
extension FcrRosterUIComponent {
    public func setupSupportFuncs(_ funcs: [AgoraRosterFunction]) {
        supportFuncs = funcs.enabledList()
        tableView.reloadData()
    }
    
    public func setUpTeacherData() {
        if let teacher = userController.getUserList(role: .teacher)?.first {
            teacherNameLabel.text = teacher.userName
        } else {
            teacherNameLabel.text = nil
        }
    }
    // 向列表中添加用户(uuid去重)
    // @param resort 是否进行重新排序
    public func add(_ models: [AgoraRosterModel],
                    resort: Bool) {
        for model in models {
            if dataSource.contains(where: {$0.uuid == model.uuid}) == false {
                dataSource.append(model)
                update(by: model.uuid)
            }
        }
        if resort {
            sort()
        }
        tableView.reloadData()
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
    // 对用户数据进行全量更新
    // @param resort 是否因上台状态变化进行重新排序
    public func update(by uuids: [String],
                       resort: Bool) {
        var staged = false
        for uuid in uuids {
            if update(by: uuid) == true {
                staged = true
            }
        }
        if staged, resort {
            sort()
        }
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
    
    // @return 上台状态是否改变
    @discardableResult
    func update(by uuid: String) -> Bool {
        var stageChanged = false
        guard let model = dataSource.first(where: {$0.uuid == uuid}) else {
            return stageChanged
        }
        let isTeacher = (userController.getLocalUserInfo().userRole == .teacher)
        let localUserID = userController.getLocalUserInfo().userUuid
        
        model.rewards = userController.getUserRewardCount(userUuid: uuid)
        // enable
        model.stageState.isEnable = isTeacher
        model.authState.isEnable = isTeacher
        model.rewardEnable = isTeacher
        model.kickEnable = isTeacher
        // 上下台操作
        let coHosts = userController.getCoHostList()
        var isCoHost = false
        if let _ = coHosts?.first(where: {$0.userUuid == model.uuid}) {
            isCoHost = true
        }
        if model.stageState.isOn != isCoHost {
            model.stageState.isOn = isCoHost
            stageChanged = true
        }
        guard let stream = streamController.getStreamList(userUuid: model.uuid)?.first else {
            model.micState = (false, false, false)
            model.cameraState = (false, false, false)
            return stageChanged
        }
        // stream
        model.streamId = stream.streamUuid
        // audio
        model.micState.streamOn = stream.streamType.hasAudio
        model.micState.deviceOn = (stream.audioSourceState == .open)
        // video
        model.cameraState.streamOn = stream.streamType.hasVideo
        model.cameraState.deviceOn = (stream.videoSourceState == .open)
        
        model.micState.isEnable = isTeacher && (stream.audioSourceState == .open)
        model.cameraState.isEnable = isTeacher && (stream.videoSourceState == .open)
        return stageChanged
    }
    
    func sort() {
        dataSource.sort {$0.sortRank < $1.sortRank}
        var coHosts = [AgoraRosterModel]()
        var rest = [AgoraRosterModel]()
        for user in dataSource {
            if user.stageState.isOn {
                coHosts.append(user)
            } else {
                rest.append(user)
            }
        }
        coHosts.append(contentsOf: rest)
        dataSource = coHosts
        tableView.reloadData()
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
                             at index: NSIndexPath) {
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
        cell.indexPath = NSIndexPath(row: indexPath.row,
                                     section: indexPath.section)
        cell.delegate = self
        return cell
    }
}
// MARK: - Actions
extension FcrRosterUIComponent {
    @objc func onClickCarouselSwitch(_ sender: UISwitch) {
        if sender.isOn {
            userController.startCoHostCarousel(interval: 20,
                                                 count: 6,
                                                 type: .sequence,
                                                 condition: .none) {
                
            } failure: { error in
                sender.isOn = !sender.isOn
            }
        } else {
            userController.stopCoHostCarousel {
                
            } failure: { error in
                sender.isOn = !sender.isOn
            }
        }
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
