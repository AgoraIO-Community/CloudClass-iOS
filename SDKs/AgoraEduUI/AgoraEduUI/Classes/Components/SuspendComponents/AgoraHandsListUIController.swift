//
//  HandsUpViewController.swift
//  AgoraEduUI
//
//  Created by 何正卿 on 2021/10/21.
//

import Masonry
import AgoraEduContext
import AgoraUIBaseViews

struct HandsUpUser {
    var userUuid: String
    var userName: String
    var isCoHost: Bool
}

protocol AgoraHandsListUIControllerDelegate: NSObjectProtocol {
    func updateHandsListRedLabel(_ count: Int)
}

class AgoraHandsListUIController: UIViewController {
    public var suggestSize = CGSize(width: 220, height: 245)
    /** 代理*/
    weak var delegate: AgoraHandsListUIControllerDelegate?

    private var listContentView: UIView?
    /** 举手列表*/
    private var tableView: UITableView?

    private(set) var dataSource = [HandsUpUser]() {
        didSet {
            delegate?.updateHandsListRedLabel(dataSource.count)
            tableView?.reloadData()
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
        
        contextPool.user.registerUserEventHandler(self)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        
        createViews()
        createConstraint()
    }
}

// MARK: - AgoraEduUserHandler
extension AgoraHandsListUIController: AgoraEduUserHandler {
    func onUserHandsWave(userUuid: String,
                         duration: Int,
                         payload: [String : Any]?) {
        if dataSource.contains(where: {$0.userUuid == userUuid}) == false,
           let `payload` = payload,
           let userName = payload["userName"] as? String {
            var isCoHost = false
            if let list = contextPool.user.getCoHostList(),
               list.contains(where: {$0.userUuid == userUuid}){
                isCoHost = true
            }
            let user = HandsUpUser(userUuid: userUuid,
                                   userName: userName,
                                   isCoHost: isCoHost)
            dataSource.append(user)
        }
    }
    
    func onUserHandsDown(userUuid: String,
                         payload: [String : Any]?) {
        dataSource.removeAll(where: {$0.userUuid == userUuid})
    }
    
    func onCoHostUserListAdded(userList: [AgoraEduContextUserInfo],
                               operatorUser: AgoraEduContextUserInfo?) {
        for userInfo in userList {
            guard dataSource.contains(where: {$0.userUuid == userInfo.userUuid}) else{
                continue
            }
            // TODO: 验证是否触发didSet
            var handsUpUser = dataSource.first(where: {$0.userUuid == userInfo.userUuid})!
            handsUpUser.isCoHost = true
        }
    }
    
    func onCoHostUserListRemoved(userList: [AgoraEduContextUserInfo],
                                 operatorUser: AgoraEduContextUserInfo?) {
        for userInfo in userList {
            guard dataSource.contains(where: {$0.userUuid == userInfo.userUuid}) else{
                continue
            }
            // TODO: 验证是否触发didSet
            var handsUpUser = dataSource.first(where: {$0.userUuid == userInfo.userUuid})!
            handsUpUser.isCoHost = false
        }
    }
}
// MARK: - HandsUpItemCellDelegate
extension AgoraHandsListUIController: AgoraHandsUpItemCellDelegate {
    func onClickAcceptAtIndex(_ index: IndexPath) {
        let u = dataSource[index.row]
        contextPool.user.addCoHost(userUuid: u.userUuid,
                                   success: nil,
                                   failure: nil)
    }
}

// MARK: - TableView Call back
extension AgoraHandsListUIController: UITableViewDataSource, UITableViewDelegate {
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
        guard let u = dataSource[indexPath.row] as? HandsUpUser,
              u.isCoHost == false else {
                  return
        }
        
        contextPool.user.addCoHost(userUuid: u.userUuid,
                                   success: nil,
                                   failure: nil)
    }
}

// MARK: - private
extension AgoraHandsListUIController {
    func createViews() {
        view.layer.shadowColor = UIColor(hex: 0x2F4192,
                                         transparency: 0.15)?.cgColor
        view.layer.shadowOffset = CGSize(width: 0,
                                         height: 2)
        view.layer.shadowOpacity = 1
        view.layer.shadowRadius = 6
        
        let contentView = UIView()
        contentView.backgroundColor = UIColor(hex: 0xF9F9FC)
        contentView.layer.cornerRadius = 10.0
        contentView.clipsToBounds = true
        contentView.borderWidth = 1
        contentView.borderColor = UIColor(hex: 0xE3E3EC)
        contentView.isUserInteractionEnabled = true
        
//        listContentView = UIView()
//        listContentView.backgroundColor = UIColor(hex: 0xF9F9FC)
//        listContentView.layer.shadowColor = UIColor(hex: 0x2F4192,
//                                      transparency: 0.15)?.cgColor
//        listContentView.layer.shadowOffset = CGSize(width: 0, height: 2)
//        listContentView.layer.shadowOpacity = 1
//        listContentView.layer.shadowRadius = 6
        
        view.addSubview(contentView)

        
        let tab = UITableView.init(frame: .zero, style: .plain)
        tab.backgroundColor = UIColor(hex: 0xF9F9FC)
        tab.delegate = self
        tab.dataSource = self
        tab.tableFooterView = UIView.init(frame: CGRect(x: 0, y: 0, width: 1, height: 0.01))
        tab.rowHeight = 40
        tab.separatorInset = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 15)
        tab.separatorColor = UIColor(hexString: "#EEEEF7")
        tab.allowsSelection = false
        tab.register(cellWithClass: AgoraHandsUpItemCell.self)
        tab.layer.cornerRadius = 12
        tab.clipsToBounds = true
        tab.isUserInteractionEnabled = true
        
        contentView.addSubview(tab)
        
        listContentView = contentView
        tableView = tab
    }
    
    func createConstraint() {
        guard let content = listContentView,
              let tab = tableView else {
                  return
              }
        content.mas_makeConstraints { make in
            make?.left.right().top().bottom().equalTo()(content.superview)
        }
        tab.mas_makeConstraints { make in
            make?.left.right().top().bottom().equalTo()(tab.superview)
        }
    }
}
