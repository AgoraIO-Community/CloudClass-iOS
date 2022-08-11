//
//  VocationalToolBarUIController.swift
//  AgoraEduUI
//
//  Created by Jonathan on 2022/1/4.
//

import UIKit
import AgoraWidget
import AgoraEduContext
import AgoraUIBaseViews

// MARK: - VocationalToolBarUIController
class VocationalToolBarUIComponent: UIViewController {
    
    public var handsupDuration = 3
    
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
                          height: CGFloat(tools.count) * (kButtonLength + kGap) - kGap)
        }
    }
    
    /** 展示的工具*/
    public var tools = [FcrToolBarItemType]() {
        didSet {
            updateDataSource()
        }
    }
    
    private var hiddenTools = [FcrToolBarItemType]()
    
    private var dataSource = [FcrToolBarItemType]()
        
    private var collectionView: UICollectionView!
    
    private var waveHandsCell: FcrToolBarWaveHandsCell?
    
    /** 画笔图片*/
    private var brushImage = UIConfig.netlessBoard.mouse.unselectedImage
    /** 画笔颜色*/
    private var brushColor = UIColor(hex: 0xE1E1EA)
    /** 消息提醒*/
    private var messageRemind = false
    /** 举手列表人数*/
    private var handsListCount = 0 {
        didSet {
            if handsListCount != oldValue {
                collectionView.reloadData()
            }
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
                make?.right.equalTo()(self.view.mas_left)?.offset()(-5)
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
        self.collectionView.reloadData()
    }
    
    public func updateHandsListCount(_ count: Int) {
        handsListCount = count
    }
    
    // left for painting UI manager
    public func updateBrushButton(image: UIImage?,
                                  colorHex: Int) {
        self.brushImage = image
        if colorHex == 0xFFFFFF {
            self.brushColor = UIColor(hex: 0xE1E1EA)
        } else {
            self.brushColor = UIColor(hex: colorHex)
        }
        self.collectionView.reloadData()
    }
}

extension VocationalToolBarUIComponent: AgoraUIContentContainer {
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
extension VocationalToolBarUIComponent: AgoraEduGroupHandler {
    func onUserListAddedToSubRoom(userList: [String],
                                  subRoomUuid: String,
                                  operatorUser: AgoraEduContextUserInfo?) {
        if let teacherId = userController.getUserList(role: .teacher)?.first?.userUuid,
            userList.contains(teacherId),
            teacherInLocalSubRoom() {
            collectionView.reloadData()
        }
    }
    
    func onUserListRemovedFromSubRoom(userList: [AgoraEduContextSubRoomRemovedUserEvent],
                                      subRoomUuid: String) {
        if let teacherId = contextPool.user.getUserList(role: .teacher)?.first?.userUuid,
           userList.contains(where: {$0.userUuid == teacherId}) {
            collectionView.reloadData()
        }
    }
}

// MARK: - Private
private extension VocationalToolBarUIComponent {
    func updateDataSource() {
        guard collectionView != nil else {
            return
        }
        var temp = self.tools
        self.dataSource = temp.removeAll(self.hiddenTools)
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
extension VocationalToolBarUIComponent: FcrToolBarWaveHandsCellDelegate {
    func onHandsUpViewDidChangeState(_ state: FcrToolBarWaveHandsCell.ViewState) {
        switch state {
        case .hold:
            mayShowTips()
            let userName = userController.getLocalUserInfo().userName
            userController.handsWave(duration: self.handsupDuration,
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
extension VocationalToolBarUIComponent: UICollectionViewDelegate,
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
                waveHandsCell?.duration = handsupDuration
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
private extension VocationalToolBarUIComponent {
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
