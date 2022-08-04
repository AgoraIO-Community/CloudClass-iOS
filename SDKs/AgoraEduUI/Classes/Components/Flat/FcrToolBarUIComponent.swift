//
//  AgoraToolBarUIController.swift
//  AgoraEduUI
//
//  Created by Jonathan on 2022/1/4.
//

import UIKit
import AgoraWidget
import AgoraEduContext
import AgoraUIBaseViews

// MARK: - Protocol
protocol FcrToolBarComponentDelegate: NSObject {
    /** 工具被选取*/
    func toolsViewDidSelectTool(tool: FcrToolBarItemType,
                                selectView: UIView)
    /** 工具被取消选取*/
    func toolsViewDidDeselectTool(tool: FcrToolBarItemType)
}

// MARK: - AgoraToolBarUIController
class FcrToolBarUIComponent: UIViewController {
    private var userController: AgoraEduUserContext {
        if let `subRoom` = subRoom {
            return subRoom.user
        } else {
            return contextPool.user
        }
    }
    
    /** SDK环境*/
    private var contextPool: AgoraEduContextPool
    private var subRoom: AgoraEduSubRoomContext?
    
    /** Size*/
    private let kButtonLength: CGFloat = UIDevice.current.agora_is_pad ? 34 : 32
    private let kGap: CGFloat = 12.0
    private let kDefaultTag: Int = 3389
    
    weak var delegate: FcrToolBarComponentDelegate?
    
    var suggestSize: CGSize {
        get {
            return CGSize(width: UIDevice.current.agora_is_pad ? 34 : 30,
                          height: CGFloat(dataSource.count) * (kButtonLength + kGap) - kGap)
        }
    }
    
    /** 展示的工具*/
    private var dataSource = [FcrToolBarItemType]()
        
    private var collectionView: UICollectionView!
    
    private var waveHandsCell: FcrToolBarWaveHandsCell?

    /** 消息提醒*/
    private var messageRemind = false
    /** 举手列表人数*/
    private var handsListCount = 0 {
        didSet {
            guard handsListCount != oldValue,
                  let indexPath = dataSource.indexOfType(.handsList) else {
                      return
            }
            collectionView.reloadItems(at: [indexPath])
        }
    }
    /** 举手提示浮层*/
    private lazy var hansupTipsView: AgoraHandsUpTipsView = {
        let v = AgoraHandsUpTipsView()
        v.isHidden = true
        view.addSubview(v)
        if let index = self.dataSource.firstIndex(of: .waveHands) {
            let cell = self.collectionView.cellForItem(at: IndexPath(row: index,
                                                                     section: 0))
            v.mas_makeConstraints { make in
                make?.right.equalTo()(self.view.mas_left)?.offset()(-8)
                make?.centerY.equalTo()(cell)
            }
        }
        return v
    }()
    /** 已被选中的工具*/
    private var selectedTool: FcrToolBarItemType? {
        didSet {
            if let oldTool = oldValue {
                self.delegate?.toolsViewDidDeselectTool(tool: oldTool)
            }
        }
    }
    
    init(context: AgoraEduContextPool,
         subRoom: AgoraEduSubRoomContext? = nil,
         delegate: FcrToolBarComponentDelegate? = nil) {
        self.contextPool = context
        self.subRoom = subRoom
        self.delegate = delegate
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
        
        contextPool.group.registerGroupEventHandler(self)
    }
    
    public func updateTools(_ list: [FcrToolBarItemType]) {
        dataSource = list.enabledList()
        updateDataSource()
    }
    
    public func deselectAll() {
        guard selectedTool != nil else {
            return
        }
        selectedTool = nil
        collectionView.reloadData()
    }
    
    public func updateChatRedDot(isShow: Bool) {
        guard messageRemind != isShow else {
            return
        }
        messageRemind = isShow
        guard let indexPath = dataSource.indexOfType(.message) else {
            return
        }
        collectionView.reloadItems(at: [indexPath])
    }
    
    public func updateHandsListCount(_ count: Int) {
        handsListCount = count
    }
}

extension FcrToolBarUIComponent: AgoraUIContentContainer {
    func initViews() {
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .vertical
        layout.itemSize = CGSize(width: kButtonLength,
                                 height: kButtonLength)
        layout.minimumLineSpacing = kGap
        layout.minimumInteritemSpacing = kGap
        collectionView = UICollectionView(frame: .zero,
                                          collectionViewLayout: layout)
        collectionView.delegate = self
        collectionView.dataSource = self
        collectionView.isScrollEnabled = false
        
        collectionView.allowsMultipleSelection = false
        collectionView.showsVerticalScrollIndicator = false
        collectionView.bounces = false
        collectionView.clipsToBounds = false
        collectionView.register(cellWithClass: AgoraToolBarItemCell.self)
        collectionView.register(cellWithClass: FcrToolBarWaveHandsCell.self)
        collectionView.register(cellWithClass: AgoraToolBarRedDotCell.self)
        collectionView.register(cellWithClass: AgoraToolBarHandsListCell.self)
        view.addSubview(collectionView)
    }
    
    func initViewFrame() {
        collectionView.mas_remakeConstraints { make in
            make?.top.bottom().equalTo()(0)
            make?.left.equalTo()(kGap / 2)
            make?.right.equalTo()(-kGap / 2)
            make?.width.equalTo()(kButtonLength)
            make?.height.equalTo()((kButtonLength + kGap) * 5 - kGap)
        }
    }
    
    func updateViewProperties() {
        collectionView.backgroundColor = .clear
        
        updateDataSource()
    }
}

// MARK: - AgoraEduGroupHandler
extension FcrToolBarUIComponent: AgoraEduGroupHandler {
    func onUserListAddedToSubRoom(userList: [String],
                                  subRoomUuid: String,
                                  operatorUser: AgoraEduContextUserInfo?) {
        if let teacherId = userController.getUserList(role: .teacher)?.first?.userUuid,
           userList.contains(teacherId),
           teacherInLocalSubRoom(),
           let indexPath = dataSource.indexOfType(.help) {
            collectionView.reloadItems(at: [indexPath])
        }
    }
    
    func onUserListRemovedFromSubRoom(userList: [AgoraEduContextSubRoomRemovedUserEvent],
                                      subRoomUuid: String) {
        if let teacherId = contextPool.user.getUserList(role: .teacher)?.first?.userUuid,
           userList.contains(where: {$0.userUuid == teacherId}),
           let indexPath = dataSource.indexOfType(.help) {
            collectionView.reloadItems(at: [indexPath])
        }
    }
}

// MARK: - Private
private extension FcrToolBarUIComponent {
    func updateDataSource() {
        guard collectionView != nil else {
            return
        }
        
        let count = CGFloat(self.dataSource.count)
        collectionView.mas_remakeConstraints { make in
            make?.left.right().top().bottom().equalTo()(0)
            make?.height.equalTo()((kButtonLength + kGap) * count - kGap)
        }

        UIView.animate(withDuration: 2) {
            self.collectionView.reloadData()
        }
    }
}

// MARK: - Student Hands Up
extension FcrToolBarUIComponent: FcrToolBarWaveHandsCellDelegate {
    func onHandsUpViewDidChangeState(_ state: FcrToolBarWaveHandsCell.ViewState) {
        switch state {
        case .hold:
            mayShowTips()
            let userName = userController.getLocalUserInfo().userName
            userController.handsWave(duration: 3,
                                     payload: ["userName": userName]) {
                
            } failure: { (_) in
                
            }
            break
        case .free:
            break
        case .counting:
            break
        default:
            break
        }
    }
    
    func mayShowTips() {
        guard self.hansupTipsView.isHidden == true else {
            return
        }
        self.hansupTipsView.isHidden = false
        self.hansupTipsView.alpha = 1
        self.perform(#selector(hideTipsAnimated), with: nil, afterDelay: 2)
    }
    
    @objc func hideTipsAnimated() {
        UIView.animate(withDuration: 0.3) {
            self.hansupTipsView.alpha = 0
        }
    }
}

// MARK: - UICollectionViewDataSource
extension FcrToolBarUIComponent: UICollectionViewDelegate,
                                    UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView,
                        numberOfItemsInSection section: Int) -> Int {
        return self.dataSource.count
    }
    
    func collectionView(_ collectionView: UICollectionView,
                        cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let tool = dataSource[indexPath.row]
        
        let aSelected = (selectedTool == tool)
        
        if tool == .message {
            let cell = collectionView.dequeueReusableCell(withClass: AgoraToolBarRedDotCell.self,
                                                          for: indexPath)
            let image = aSelected ? tool.selectedImage : tool.unselectedImage
            cell.iconView.image = image
            cell.aSelected = aSelected
            cell.redDot.isHidden = !messageRemind
            return cell
        } else if tool == .waveHands {
            let cell = waveHandsCell ?? collectionView.dequeueReusableCell(withClass: FcrToolBarWaveHandsCell.self,
                                                                         for: indexPath)
            let image = tool.unselectedImage
            cell.iconView.image = image
            if waveHandsCell == nil {
                waveHandsCell = cell
                waveHandsCell?.delegate = self
            }
            return cell
        } else if tool == .handsList {
            let cell = collectionView.dequeueReusableCell(withClass: AgoraToolBarHandsListCell.self,
                                                          for: indexPath)
            var handsListSelected = (handsListCount > 0) ? aSelected : false
            let image = handsListSelected ? tool.selectedImage : tool.unselectedImage
            cell.iconView.image = image
            
            cell.redLabel.text = "\(handsListCount)"
            cell.redLabel.isHidden = (handsListCount == 0)
            cell.aSelected = handsListSelected
            return cell
        } else if tool == .help {
            let cell = collectionView.dequeueReusableCell(withClass: AgoraToolBarItemCell.self,
                                                          for: indexPath)
            let touchable = !teacherInLocalSubRoom()
            let image = touchable ? tool.unselectedImage : tool.disabledImage
            cell.iconView.image = image
            return cell
        } else {
            let cell = collectionView.dequeueReusableCell(withClass: AgoraToolBarItemCell.self,
                                                          for: indexPath)
            let image = aSelected ? tool.selectedImage : tool.unselectedImage
            cell.iconView.image = image
            cell.aSelected = aSelected
            return cell
        }
    }
    
    func collectionView(_ collectionView: UICollectionView,
                        didSelectItemAt indexPath: IndexPath) {
        collectionView.deselectItem(at: indexPath,
                                    animated: false)
        let tool = dataSource[indexPath.row]
        if !tool.isOnceKind,
           selectedTool == tool {
            selectedTool = nil
        } else {
            selectedTool = tool
            if let cell = collectionView.cellForItem(at: indexPath) {
                self.delegate?.toolsViewDidSelectTool(tool: tool,
                                                      selectView: cell)
            }
        }
        UIView.performWithoutAnimation {
            collectionView.reloadItems(at: [indexPath])
        }
    }
    
    func collectionView(_ collectionView: UICollectionView,
                        shouldSelectItemAt indexPath: IndexPath) -> Bool {
        let tool = dataSource[indexPath.row]
        if tool == .waveHands {
            return false
        } else {
            return true
        }
    }
    
    func collectionView(_ collectionView: UICollectionView,
                        didHighlightItemAt indexPath: IndexPath) {
        let cell = collectionView.cellForItem(at: indexPath) as? AgoraToolBarItemCell
        cell?.highLight()
    }
    
    func collectionView(_ collectionView: UICollectionView,
                        didUnhighlightItemAt indexPath: IndexPath) {
        let cell = collectionView.cellForItem(at: indexPath) as? AgoraToolBarItemCell
        cell?.normalState()
    }
    
    func collectionView(_ collectionView: UICollectionView,
                        shouldHighlightItemAt indexPath: IndexPath) -> Bool {
        let tool = dataSource[indexPath.row]
        if tool == .waveHands {
            return false
        } else {
            return true
        }
    }
}

// MARK: - Creations
private extension FcrToolBarUIComponent {
    func teacherInLocalSubRoom() -> Bool {
        let group = contextPool.group
        let user = contextPool.user
        
        guard let subRoomList = group.getSubRoomList(),
              let teacher = user.getUserList(role: .teacher)?.first else {
            return false
        }
        
        let localUserId = user.getLocalUserInfo().userUuid
        let teacherId = teacher.userUuid
        
        let contains = [localUserId,
                        teacherId]
        
        for item in subRoomList {
            guard let userList = group.getUserListFromSubRoom(subRoomUuid: item.subRoomUuid),
                  userList.contains(contains) else {
                continue
            }
            
            return true
        }
        
        return false
    }
}

extension Array where Element == FcrToolBarItemType {
    func enabledList() -> [FcrToolBarItemType] {
        let config = UIConfig.toolBar
        
        var list = [FcrToolBarItemType]()
        for item in self {
            switch item {
            case .setting:
                if config.setting.enable,
                   config.setting.visible {
                    list.append(item)
                }
            case .roster:
                if UIConfig.roster.enable,
                   UIConfig.roster.visible {
                    list.append(item)
                }
            case .message:
                if config.message.enable,
                   config.message.visible {
                    list.append(item)
                }
            case .waveHands:
                if UIConfig.raiseHand.enable,
                   UIConfig.raiseHand.visible {
                    list.append(item)
                }
            case .handsList:
                if config.handsList.enable,
                   config.handsList.visible {
                    list.append(item)
                }
            case .help:
                if UIConfig.breakoutRoom.help.enable,
                   UIConfig.breakoutRoom.help.visible {
                    list.append(item)
                }
            }
        }
        return list
    }
    
    func indexOfType(_ type: FcrToolBarItemType) -> IndexPath? {
        guard let index = self.firstIndex(of: type) else {
            return nil
        }
        return IndexPath(item: index,
                         section: 0)
    }
}
