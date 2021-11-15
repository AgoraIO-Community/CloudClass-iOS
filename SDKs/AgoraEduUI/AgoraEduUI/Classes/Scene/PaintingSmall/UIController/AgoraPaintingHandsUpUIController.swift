//
//  HandsUpViewController.swift
//  AgoraEduUI
//
//  Created by 何正卿 on 2021/10/21.
//

import Masonry
import AgoraExtApp
import AgoraEduContext
import AgoraUIBaseViews
import AgoraUIEduBaseViews

protocol AgoraPaintingHandsUpUIControllerDelegate: NSObjectProtocol {
    /** 展示举手列表*/
    func onShowHandsUpList(_ view: UIView)
    /** 取消展示举手列表*/
    func onHideHandsUpList(_ view: UIView)
}

class AgoraPaintingHandsUpUIController: UIViewController {
    /** 代理*/
    weak var delegate: AgoraPaintingHandsUpUIControllerDelegate?
    /** 举手列表控制按钮*/
    private lazy var listButton: AgoraRoomToolZoomButton = {
        let v = AgoraRoomToolZoomButton(frame: .zero)
        let image = AgoraUIImage(object: self, name: "ic_func_hands_up")
        if let rendering = image?.withRenderingMode(.alwaysTemplate) {
            v.setImageForAllStates(rendering)
        }
        v.addTarget(self, action: #selector(onSelectListButton(_:)),
                    for: .touchUpInside)
        view.addSubview(v)
        v.mas_makeConstraints { make in
            make?.center.equalTo()(v.superview)
            make?.width.height().equalTo()(v.superview)
        }
        return v
    }()
    private lazy var ctrlButton: AgoraHandsUpDelayView = {
        let v = AgoraHandsUpDelayView(frame: .zero)
        v.delegate = self
        view.addSubview(v)
        v.mas_makeConstraints { make in
            make?.center.equalTo()(v.superview)
            make?.width.height().equalTo()(v.superview)
        }
        return v
    }()
    /** 举手人数的红点提醒*/
    private lazy var redDot: UIView = {
        let redDot = UIView()
        redDot.backgroundColor = UIColor(rgb: 0xF04C36)
        redDot.layer.cornerRadius = 7
        redDot.clipsToBounds = true
        redDot.isUserInteractionEnabled = false
        view.addSubview(redDot)
        redDot.addSubview(countLabel)
        countLabel.mas_makeConstraints { make in
            make?.right.equalTo()(listButton)?.offset()
            make?.top.equalTo()(listButton)?.offset()
            make?.height.equalTo()(14)
        }
        redDot.mas_makeConstraints { make in
            make?.center.height().equalTo()(countLabel)
            make?.width.greaterThanOrEqualTo()(14)
            make?.width.equalTo()(countLabel)?.offset()(5)
        }
        return redDot
    }()
    
    private lazy var countLabel: UILabel = {
        let v = UILabel()
        v.textColor = .white
        v.font = UIFont.systemFont(ofSize: 10)
        v.textAlignment = .center
        v.isUserInteractionEnabled = false
        return v
    }()
    /** 举手提示浮层*/
    private lazy var tipsView: AgoraHandsupTipsView = {
        let v = AgoraHandsupTipsView()
        view.addSubview(v)
        v.mas_makeConstraints { make in
            make?.right.equalTo()(self.view.mas_left)?.offset()(-5)
            make?.centerY.equalTo()(v.superview)
        }
        return v
    }()
    private lazy var listContentView: UIView = {
        let v = UIView()
        v.layer.shadowColor = UIColor(rgb: 0x2F4192, alpha: 0.15).cgColor
        v.layer.shadowOffset = CGSize(width: 0, height: 2)
        v.layer.shadowOpacity = 1
        v.layer.shadowRadius = 6
        v.addSubview(tableView)
        tableView.mas_makeConstraints { make in
            make?.left.right().top().bottom().equalTo()(tableView.superview)
        }
        return v
    }()
    /** 举手列表*/
    private lazy var tableView: UITableView = {
        let v = UITableView.init(frame: .zero, style: .plain)
        v.delegate = self
        v.dataSource = self
        v.tableFooterView = UIView.init(frame: CGRect(x: 0, y: 0, width: 1, height: 0.01))
        v.rowHeight = 40
        v.separatorInset = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 15)
        v.separatorColor = UIColor(hexString: "#EEEEF7")
        v.allowsSelection = false
        v.register(cellWithClass: AgoraHandsUpItemCell.self)
        v.layer.cornerRadius = 12
        v.clipsToBounds = true
        return v
    }()
    
    private var isShowedTips = false
    
    private var dataSource = [AgoraEduContextUserDetailInfo]()
    
    private var isReminding: Bool = false {
        didSet {
            if isReminding != oldValue, isReminding == true {
                blinkStart()
            }
        }
    }
    
    private var contextPool: AgoraEduContextPool!
    // MARK: - Life Cycle
    deinit {
        print("\(#function): \(self.classForCoder)")
    }
    
    init(context: AgoraEduContextPool) {
        super.init(nibName: nil, bundle: nil)
        contextPool = context
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        if contextPool.user.getLocalUserInfo().role == .teacher {
            listButton.isHidden = false
            contextPool.user.registerEventHandler(self)
        } else {
            ctrlButton.isHidden = false
            contextPool.handsUp.registerEventHandler(self)
        }
    }
    
    public func deselect() {
        guard contextPool.user.getLocalUserInfo().role == .teacher else {
            return
        }
        listButton.isSelected = false
    }
}
// MARK: - Private
private extension AgoraPaintingHandsUpUIController {
    func mayShowTips() {
        guard self.isShowedTips == false else {
            return
        }
        self.isShowedTips = true
        self.tipsView.isHidden = false
        self.tipsView.alpha = 1
        self.perform(#selector(hideTipsAnimated), with: nil, afterDelay: 2)
    }
    
    @objc func hideTipsAnimated() {
        UIView.animate(withDuration: 0.3) {
            self.tipsView.alpha = 0
        }
    }
    
    @objc func blinkStart() {
        self.perform(#selector(blinkFinish), with: nil, afterDelay: 1)
        listButton.backgroundColor = UIColor(rgb: 0x357BF6)
        listButton.imageView?.tintColor = .white
    }
    
    @objc func blinkFinish() {
        listButton.backgroundColor = .white
        listButton.imageView?.tintColor = UIColor(rgb: 0x7B88A0)
        if isReminding == true {
            self.perform(#selector(blinkStart), with: nil, afterDelay: 1)
        }
    }
    
}
// MARK: - Actions
extension AgoraPaintingHandsUpUIController {
    @objc func onSelectListButton(_ sender: UIButton) {
        sender.isSelected = !sender.isSelected
        sender.backgroundColor = sender.isSelected ? UIColor(rgb: 0x357BF6) : .white
        sender.imageView?.tintColor = sender.isSelected ? .white : UIColor(rgb: 0x7B88A0)
        if sender.isSelected {
            delegate?.onShowHandsUpList(listContentView)
        } else {
            delegate?.onHideHandsUpList(listContentView)
        }
    }
}
// MARK: - HandsUpDelayViewDelegate
extension AgoraPaintingHandsUpUIController: AgoraHandsUpDelayViewDelegate {
    func onHandsUpViewDidChangeState(_ state: AgoraHandsUpDelayView.ViewState) {
        switch state {
        case .hold:
            mayShowTips()
            contextPool.handsUp.updateWaveArmsState(.handsUp,
                                                   timeout: -1)
            break
        case .free:
            contextPool.handsUp.updateWaveArmsState(.handsUp,
                                                   timeout: 3)
            break
        case .counting: break
        default: break
        }
    }
}
// MARK: - AgoraEduHandsUpHandler
extension AgoraPaintingHandsUpUIController: AgoraEduHandsUpHandler {
    func onHandsUpEnable(_ enable: Bool) {
        
    }
    
    func onHandsUpState(_ state: AgoraEduContextHandsUpState) {
        
    }
    
    func onHandsUpError(_ error: AgoraEduContextError?) {
        
    }
    
    func onHandsUpResult(_ result: AgoraEduContextHandsUpResult) {
        var text: String
        switch result {
        case .accepted:
            text = AgoraUILocalizedString("AcceptedCoHostText",
                                          object: self)
        case .rejected:
            text = AgoraUILocalizedString("RejectedCoHostText",
                                          object: self)
        case .timeout:
            text = AgoraUILocalizedString("HandsUpTimeOutText",
                                          object: self)
        }
        AgoraUtils.showToast(message: text)
    }
}
// MARK: - AgoraEduUserHandler
extension AgoraPaintingHandsUpUIController: AgoraEduUserHandler {
    func onUpdateUserList(_ list: [AgoraEduContextUserDetailInfo]) {
        var temp = [AgoraEduContextUserDetailInfo]()
        for user in list {
            if user.wavingArms {
                temp.append(user)
            }
        }
        dataSource = temp
        redDot.isHidden = (dataSource.count == 0)
        countLabel.text = "\(dataSource.count)"
        isReminding = (dataSource.count > 0)
        tableView.reloadData()
    }
}
// MARK: - HandsUpItemCellDelegate
extension AgoraPaintingHandsUpUIController: AgoraHandsUpItemCellDelegate {
    func onClickAcceptAtIndex(_ index: IndexPath) {
        let u = dataSource[index.row]
        contextPool.user.addCoHosts(userUuids: [u.userUuid]) {
            // Do Noting
        } failure: { ero in
            // Do Noting
        }
    }
}

// MARK: - TableView Call back
extension AgoraPaintingHandsUpUIController: UITableViewDataSource, UITableViewDelegate {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return dataSource.count
    }
    
    func tableView(_ tableView: UITableView,
                   cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withClass: AgoraHandsUpItemCell.self)
        let data = dataSource[indexPath.row]
        cell.nameLabel.text = data.userName
        cell.state = data.isCoHost ? .onStage : .waiting
        cell.delegate = self
        cell.indexPath = indexPath
        return cell
    }
    
    func tableView(_ tableView: UITableView,
                   didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath,
                              animated: true)
        guard let u = dataSource[indexPath.row] as? AgoraEduContextUserDetailInfo,
              !u.isCoHost else {
                  return
              }
        contextPool.user.addCoHosts(userUuids: [u.userUuid]) {
            // TODO 将用户从tableView中移除
        } failure: { (error) in
            print("")
        }
    }
}
