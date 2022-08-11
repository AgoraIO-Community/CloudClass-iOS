//
//  HandsUpViewController.swift
//  AgoraEduUI
//
//  Created by 何正卿 on 2021/10/21.
//


import AgoraEduContext
import AgoraUIBaseViews
import Masonry

protocol FcrHandsListUIComponentDelegate: NSObjectProtocol {
    func updateHandsListRedLabel(_ count: Int)
}

class FcrHandsListUIComponent: UIViewController {
    private var userController: AgoraEduUserContext {
        if let `subRoom` = subRoom {
            return subRoom.user
        } else {
            return contextPool.user
        }
    }
    
    private var contextPool: AgoraEduContextPool
    private var subRoom: AgoraEduSubRoomContext?
    
    public var suggestSize = CGSize(width: 220,
                                    height: 245)
    /** 代理*/
    weak var delegate: FcrHandsListUIComponentDelegate?

//    private lazy var listContentView: UIView?
    /** 举手列表*/
    private lazy var tableView = UITableView.init(frame: .zero,
                                                  style: .plain)

    private(set) var dataSource = [AgoraHandsUpListUserInfo]() {
        didSet {
            delegate?.updateHandsListRedLabel(dataSource.count)
            tableView.reloadData()
        }
    }
    
    // MARK: - Life Cycle
    deinit {
        print("\(#function): \(self.classForCoder)")
    }
    
    init(context: AgoraEduContextPool,
         subRoom: AgoraEduSubRoomContext? = nil,
         delegate: FcrHandsListUIComponentDelegate? = nil) {
        self.contextPool = context
        self.subRoom = subRoom
        self.delegate = delegate
        
        super.init(nibName: nil,
                   bundle: nil)
        self.userController.registerUserEventHandler(self)
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
}

// MARK: - AgoraEduUserHandler
extension FcrHandsListUIComponent: AgoraEduUserHandler {
    func onUserHandsWave(userUuid: String,
                         duration: Int,
                         payload: [String : Any]?) {
        if dataSource.contains(where: {$0.userUuid == userUuid}) == false,
           let `payload` = payload,
           let userName = payload["userName"] as? String {
            var isCoHost = false
            if let list = userController.getCoHostList(),
               list.contains(where: {$0.userUuid == userUuid}){
                isCoHost = true
            }
            let user = AgoraHandsUpListUserInfo(userUuid: userUuid,
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
            
            var AgoraHandsUpListUserInfo = dataSource.first(where: {$0.userUuid == userInfo.userUuid})!
            AgoraHandsUpListUserInfo.isCoHost = true
        }
    }
    
    func onCoHostUserListRemoved(userList: [AgoraEduContextUserInfo],
                                 operatorUser: AgoraEduContextUserInfo?) {
        for userInfo in userList {
            guard dataSource.contains(where: {$0.userUuid == userInfo.userUuid}) else{
                continue
            }
            
            var AgoraHandsUpListUserInfo = dataSource.first(where: {$0.userUuid == userInfo.userUuid})!
            AgoraHandsUpListUserInfo.isCoHost = false
        }
    }
}
// MARK: - HandsUpItemCellDelegate
extension FcrHandsListUIComponent: AgoraHandsUpItemCellDelegate {
    func onClickAcceptAtIndex(_ index: IndexPath) {
        let u = dataSource[index.row]
        guard !u.isCoHost else {
            return
        }
        
        userController.addCoHost(userUuid: u.userUuid) { [weak self] in
            guard let `self` = self,
                  self.dataSource.count > index.row else {
                return
            }
            self.dataSource[index.row].isCoHost = true
        } failure: { contextError in

        }
    }
}

// MARK: - TableView Call back
extension FcrHandsListUIComponent: UITableViewDataSource, UITableViewDelegate {
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
}

// MARK: - AgoraUIContentContainer
extension FcrHandsListUIComponent: AgoraUIContentContainer {
    func initViews() {
        tableView.delegate = self
        tableView.dataSource = self
        tableView.tableFooterView = UIView.init(frame: CGRect(x: 0,
                                                        y: 0,
                                                        width: 1,
                                                        height: 0.01))
        tableView.rowHeight = 40
        tableView.separatorInset = UIEdgeInsets(top: 0,
                                          left: 0,
                                          bottom: 0,
                                          right: 15)
        
        tableView.allowsSelection = false
        tableView.register(cellWithClass: AgoraHandsUpItemCell.self)
        tableView.isUserInteractionEnabled = true
        view.addSubview(tableView)
    }
    
    func initViewFrame() {
        tableView.mas_makeConstraints { make in
            make?.left.right().top().bottom().equalTo()(view)
        }
    }
    
    func updateViewProperties() {
        let config = UIConfig.handsList
        
        view.layer.shadowColor = config.shadow.color
        view.layer.shadowOffset = config.shadow.offset
        view.layer.shadowOpacity = config.shadow.opacity
        view.layer.shadowRadius = config.shadow.radius
        
        tableView.backgroundColor = config.backgroundColor
        tableView.separatorColor = config.sepLine.backgroundColor
        tableView.layer.cornerRadius = config.cornerRadius
        tableView.clipsToBounds = true
    }
}
