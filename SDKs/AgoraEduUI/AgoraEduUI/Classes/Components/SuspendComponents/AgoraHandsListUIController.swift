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

    private lazy var listContentView: UIView = {
        let v = UIView()
        v.layer.shadowColor = UIColor(hex: 0x2F4192,
                                      transparency: 0.15)?.cgColor
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

    private var dataSource = [HandsUpUser]() {
        didSet {
            delegate?.updateHandsListRedLabel(dataSource.count)
            tableView.reloadData()
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
        
        view.addSubview(listContentView)
        tableView.mas_remakeConstraints { make in
            make?.left.right().top().bottom().equalTo()(0)
        }
        
        if contextPool.user.getLocalUserInfo().userRole == .teacher {
            contextPool.user.registerUserEventHandler(self)
        }
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
        // TODO: 待验证，上台用户是否会走该回调
        dataSource.removeAll(where: {$0.userUuid == userUuid})
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
