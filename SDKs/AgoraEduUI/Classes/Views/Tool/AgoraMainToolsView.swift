//
//  AgoraMainToolsView.swift
//  AgoraEduUI
//
//  Created by LYY on 2022/2/11.
//

import AgoraUIBaseViews
import Masonry
import UIKit

protocol AgoraMainToolsViewDelegate: NSObjectProtocol {
    func didSelectTeachingAid(type: AgoraTeachingAidType)
    func didSelectBoardTool(type: AgoraBoardToolMainType)
}

fileprivate let kGapSize: CGFloat = AgoraFit.scale(12)
fileprivate let kHGapSize: CGFloat = AgoraFit.scale(8)
fileprivate let kItemHeight: CGFloat = AgoraFit.scale(30)
fileprivate let kItemWidth: CGFloat = AgoraFit.scale(30)

class AgoraMainToolsView: UIView {
    /** Data */
    weak var delegate: AgoraMainToolsViewDelegate?
    // Tool Box
    var teachingAidsList: [AgoraTeachingAidType] = [.cloudStorage, .saveBoard].enabledTypes() {
        didSet {
            if teachingAidsList.count != oldValue.count {
                updateTeachingAidsLayout()
            }
        }
    }
    private var containAids: Bool = false
    
    // Board Tools
    private lazy var mainBoardTools = AgoraBoardToolMainType.allCases.enabledTypes()
    /** UI */
    private var aidsHeight: CGFloat {
        get {
            guard teachingAidsList.count > 0 else {
                return 0
            }
            return (kItemHeight + kGapSize) * ceil(CGFloat(teachingAidsList.count) / 4) + kGapSize
        }
    }
    
    public var suggestSize: CGSize {
        get {
            let boardToolsHeight = (kItemHeight + kGapSize) * ceil(CGFloat(mainBoardTools.count) / 4) + kGapSize
            if containAids {
                return CGSize(width: (kItemWidth + kGapSize) * 4 - kGapSize + kHGapSize * 2,
                              height: boardToolsHeight + aidsHeight)
            } else {
                return CGSize(width: (kItemWidth + kGapSize) * 4 - kGapSize + kHGapSize * 2,
                              height: boardToolsHeight)
            }
        }
    }
    
    var curBoardTool: AgoraBoardToolMainType = .clicker {
        didSet {
            boardToolsView.reloadData()
        }
    }
    
    var curColor = UIColor(hex: 0x357BF6) {
        didSet {
            boardToolsView.reloadData()
        }
    }
        
    var redoEnable: Bool = false {
        didSet {
            if redoEnable != oldValue {
                boardToolsView.reloadData()
            }
        }
    }
    
    var undoEnable: Bool = false {
        didSet {
            if undoEnable != oldValue {
                boardToolsView.reloadData()
            }
        }
    }
    /** 容器*/
    private lazy var contentView = UIView()
    /// 仅教师端，包含投票器、答题器等
    private lazy var teachingAidsView: UICollectionView = {
        let collectionView = makeCollectionView(space: kGapSize,
                                                sectionInset: UIEdgeInsets(top: kGapSize,
                                                                           left: kHGapSize,
                                                                           bottom: kGapSize,
                                                                           right: kHGapSize))
        collectionView.register(cellWithClass: AgoraToolCollectionToolCell.self)
        return collectionView
    }()
    
    /// 仅教师端
    private lazy var sepLine = UIView()
    /// 白板工具
    private var boardToolsView: UICollectionView!
    
    init(containAids: Bool,
         delegate: AgoraMainToolsViewDelegate) {
        self.containAids = containAids
        self.delegate = delegate
        
        super.init(frame: .zero)
        
        initViews()
        initViewFrame()
        updateViewProperties()
    }
    
    func updateTeachingAidsList(_ list: [AgoraTeachingAidType]) {
        teachingAidsList = list.enabledTypes()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

extension AgoraMainToolsView: UICollectionViewDelegate,
                              UICollectionViewDataSource,
                              UICollectionViewDelegateFlowLayout {
    // MARK: UICollectionViewDataSource
    func collectionView(_ collectionView: UICollectionView,
                        numberOfItemsInSection section: Int) -> Int {
        if collectionView == boardToolsView {
            return mainBoardTools.count
        } else if collectionView == teachingAidsView {
            return teachingAidsList.count
        }
        return 0
    }
    
    func collectionView(_ collectionView: UICollectionView,
                        cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withClass: AgoraToolCollectionToolCell.self,
                                                      for: indexPath)
        
        if collectionView == boardToolsView,
           indexPath.item < mainBoardTools.count {
           let tool = mainBoardTools[indexPath.item]
            switch tool {
            case .paint,.text:
                cell.setImage(image: (tool == curBoardTool) ? tool.selectedImage : tool.unselectedImage,
                              color: curColor)
            default:
                cell.setImage(image: (tool == curBoardTool) ? tool.selectedImage : tool.unselectedImage,
                              color: nil)
            }
            cell.aSelected = (tool == curBoardTool)
            if tool == .pre {
                cell.setImage(image: undoEnable ? tool.unselectedImage : tool.disabledImage,
                              color: nil)
            }
            if tool == .next {
                cell.setImage(image: redoEnable ? tool.unselectedImage : tool.disabledImage,
                              color: nil)
            }
            
            return cell
        }
        
        if collectionView == teachingAidsView {
            let tool = teachingAidsList[indexPath.row]
            cell.setImage(image: tool.cellImage(),
                          color: nil)
        }
        
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView,
                        didSelectItemAt indexPath: IndexPath) {
        let cell = collectionView.dequeueReusableCell(withClass: AgoraToolCollectionToolCell.self,
                                                      for: indexPath)
        
        if collectionView == boardToolsView,
           indexPath.item < mainBoardTools.count {
           let tool = mainBoardTools[indexPath.item]
            if tool.needUpdateCell {
                curBoardTool = tool
            }
            delegate?.didSelectBoardTool(type: tool)
        } else if collectionView == teachingAidsView {
            collectionView.deselectItem(at: indexPath,
                                        animated: false)
            let tool = teachingAidsList[indexPath.row]
            delegate?.didSelectTeachingAid(type: tool)
        }
        
    }
    
    // MARK: UICollectionViewDelegateFlowLayout
    func collectionView(_ collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                        sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: kItemWidth,
                      height: kItemHeight)
    }
}

// MARK: - AgoraUIContentContainer
extension AgoraMainToolsView: AgoraUIContentContainer {
    func initViews() {
        addSubview(contentView)
        
        boardToolsView = makeCollectionView(space: kGapSize,
                                            sectionInset: UIEdgeInsets(top: kGapSize,
                                                                       left: kHGapSize,
                                                                       bottom: kGapSize,
                                                                       right: kHGapSize))
        boardToolsView.register(cellWithClass: AgoraToolCollectionToolCell.self)
        contentView.addSubview(boardToolsView)
        
        if containAids {
            contentView.addSubview(teachingAidsView)
            contentView.addSubview(sepLine)
        }
    }
    
    func initViewFrame() {
        contentView.mas_makeConstraints { make in
            make?.left.right().top().bottom().equalTo()(contentView.superview)
        }
        
        if containAids {
            teachingAidsView.mas_makeConstraints { make in
                make?.left.right().top().equalTo()(self)
                make?.height.equalTo()(aidsHeight)
            }
            
            sepLine.mas_makeConstraints { make in
                make?.top.equalTo()(teachingAidsView.mas_bottom)
                make?.left.equalTo()(16)
                make?.right.equalTo()(-16)
                make?.height.equalTo()(1)
            }
            
            boardToolsView.mas_makeConstraints { make in
                make?.left.right().bottom().equalTo()(self)
                make?.top.equalTo()(self.sepLine.mas_bottom)
            }
        } else {
            boardToolsView.mas_makeConstraints { make in
                make?.top.left().right().bottom().equalTo()(self)
            }
        }
    }
    
    func updateViewProperties() {
        let config = UIConfig.toolCollection
        layer.shadowColor = config.shadow.color
        layer.shadowOffset = config.shadow.offset
        layer.shadowOpacity = config.shadow.opacity
        layer.shadowRadius = config.shadow.radius
        
        contentView.backgroundColor = config.backgroundColor
        contentView.layer.cornerRadius = config.windowCornerRadius
        contentView.clipsToBounds = true
        contentView.borderWidth = config.borderWidth
        contentView.layer.borderColor = config.borderColor
        
        if containAids {
            sepLine.backgroundColor = config.sepLine.backgroundColor
            sepLine.agora_visible = (teachingAidsList.count > 0)
        }
    }
}

// MARK: - UI
private extension AgoraMainToolsView {
    func updateTeachingAidsLayout() {
        if teachingAidsView == nil {
            // 避免在视图加载完成前对data赋值，触发layout变化
            return
        }
        sepLine.agora_visible = (teachingAidsList.count > 0)
        teachingAidsView.mas_remakeConstraints { make in
            make?.left.equalTo()(self)?.offset()(AgoraFit.scale(8))
            make?.right.equalTo()(self)?.offset()(AgoraFit.scale(-8))
            make?.height.equalTo()(aidsHeight)
        }
    }
    
    func makeCollectionView(space: CGFloat,
                            sectionInset: UIEdgeInsets) -> UICollectionView {
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .vertical
        layout.sectionInset = sectionInset
        let collectionView = UICollectionView(frame: .zero,
                                              collectionViewLayout: layout)
        collectionView.showsHorizontalScrollIndicator = false
        collectionView.backgroundColor = .clear
        collectionView.bounces = false
        collectionView.delegate = self
        collectionView.dataSource = self
        return collectionView
    }
}

fileprivate extension Array where Element == AgoraBoardToolMainType {
    func enabledTypes() -> [AgoraBoardToolMainType] {
        let config = UIConfig.netlessBoard
        var list = [AgoraBoardToolMainType]()
        for item in self {
            switch item {
            case .clicker:
                if config.mouse.enable,
                   config.mouse.visible {
                    list.append(item)
                }
            case .area:
                if config.selector.enable,
                   config.selector.visible {
                    list.append(item)
                }
            case .paint:
                if config.pencil.enable,
                   config.pencil.visible {
                    list.append(item)
                }
            case .text:
                if config.text.enable,
                   config.text.visible {
                    list.append(item)
                }
            case .rubber:
                if config.eraser.enable,
                   config.eraser.visible {
                    list.append(item)
                }
            case .clear:
                if config.clear.enable,
                   config.clear.visible {
                    list.append(item)
                }
            case .pre:
                if config.prev.enable,
                   config.prev.visible {
                    list.append(item)
                }
            case .next:
                if config.next.enable,
                   config.next.visible {
                    list.append(item)
                }
            }
        }
        return list
    }
}

fileprivate extension Array where Element == AgoraTeachingAidType {
    func enabledTypes() -> [AgoraTeachingAidType] {
        var list = [AgoraTeachingAidType]()
        for item in self {
            switch item {
            case .vote:
                if UIConfig.poll.enable,
                   UIConfig.poll.visible {
                    list.append(item)
                }
            case .cloudStorage:
                if UIConfig.cloudStorage.enable,
                   UIConfig.cloudStorage.visible {
                    list.append(item)
                }
            case .saveBoard:
                if UIConfig.netlessBoard.save.enable,
                   UIConfig.netlessBoard.save.visible {
                    list.append(item)
                }
            case .record:
                list.append(item)
            case .countDown:
                if UIConfig.counter.enable,
                   UIConfig.counter.visible {
                    list.append(item)
                }
            case .answerSheet:
                if UIConfig.popupQuiz.enable,
                   UIConfig.popupQuiz.visible {
                    list.append(item)
                }
            }
        }
        return list
    }
}
