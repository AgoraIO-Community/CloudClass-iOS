//
//  AgoraMainToolsView.swift
//  AgoraEduUI
//
//  Created by LYY on 2022/2/11.
//

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
    // TODO: 教师端暂时删除.vote, .answerSheet, .countDown
    var teachingAidsList: [AgoraTeachingAidType] = [.cloudStorage] {
        didSet {
            if teachingAidsList.count != oldValue.count {
                updateTeachingAidsLayout()
            }
        }
    }
    private var containAids: Bool = false
    /** UI */
    let color = AgoraColorGroup()
    private let boardToolsHeight = (kItemHeight + kGapSize) * ceil(CGFloat(AgoraBoardToolMainType.allCases.count) / 4) + kGapSize
    private var aidsHeight: CGFloat {
        get {
            return (kItemHeight + kGapSize) * ceil(CGFloat(teachingAidsList.count) / 4) + kGapSize
        }
    }
    
    public var suggestSize: CGSize {
        get {
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
    private var contentView: UIView!
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
    private lazy var sepLine: UIView = {
        let sepLine = UIView()
        sepLine.backgroundColor = UIColor(hex: 0xECECF1)
        return sepLine
    }()
    
    /// 白板工具
    private var boardToolsView: UICollectionView!
    
    init(containAids: Bool,
         delegate: AgoraMainToolsViewDelegate) {
        self.containAids = containAids
        self.delegate = delegate
        
        super.init(frame: .zero)
        
        createViews()
        createConstraint()
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
            return AgoraBoardToolMainType.allCases.count
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
           let tool = AgoraBoardToolMainType(rawValue: indexPath.item) {
            switch tool {
            case .paint,.text:
                cell.setImage(image: (tool == curBoardTool) ? tool.selectedImage : tool.image,
                              color: UIColor.fakeWhite(curColor))
            default:
                cell.setImage(image: (tool == curBoardTool) ? tool.selectedImage : tool.image,
                              color: color.common_base_tint_color)
            }
            cell.aSelected = (tool == curBoardTool)
//            if tool == .pre {
//                cell.setEnable(undoEnable)
//            }
//            if tool == .next {
//                cell.setEnable(redoEnable)
//            }
        } else if collectionView == teachingAidsView {
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
           let tool = AgoraBoardToolMainType(rawValue: indexPath.item) {
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

// MARK: - UI
private extension AgoraMainToolsView {
    func createViews() {
        AgoraUIGroup().color.borderSet(layer: layer)
        
        contentView = UIView()
        contentView.backgroundColor = .white
        contentView.layer.cornerRadius = 10.0
        contentView.clipsToBounds = true
        contentView.borderWidth = 1
        contentView.borderColor = .white
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
    
    func createConstraint() {
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
    
    func updateTeachingAidsLayout() {
        if teachingAidsView == nil {
            // 避免在视图加载完成前对data赋值，触发layout变化
            return
        }
        
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
        collectionView.backgroundColor = .white
        collectionView.bounces = false
        collectionView.delegate = self
        collectionView.dataSource = self
        return collectionView
    }
}
