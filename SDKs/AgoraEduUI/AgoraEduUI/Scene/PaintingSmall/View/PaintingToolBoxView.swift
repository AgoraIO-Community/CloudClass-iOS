//
//  PaintingToolBoxView.swift
//  AgoraEduUI
//
//  Created by HeZhengQing on 2021/9/28.
//

import UIKit
import SnapKit
import SwifterSwift
import AgoraUIEduBaseViews

// MARK: - BrushToolItemCell
class ToolBoxItemCell: UICollectionViewCell {
        
    var imageView: UIImageView!
    
    var titleLabel: UILabel!
        
    override init(frame: CGRect) {
        super.init(frame: frame)
        backgroundColor = .white
        
        imageView = UIImageView(frame: .zero)
        addSubview(imageView)
        imageView.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.bottom.equalTo(self.snp.centerY).offset(-3)
            make.width.height.equalTo(28)
        }
        
        titleLabel = UILabel(frame: .zero)
        titleLabel.font = UIFont.systemFont(ofSize: 12)
        titleLabel.textColor = UIColor(rgb: 0x191919)
        titleLabel.textAlignment = .center
        addSubview(titleLabel)
        titleLabel.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.top.equalTo(self.snp.centerY).offset(3)
            make.left.right.equalToSuperview()
        }
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

// MARK: - PaintingToolBoxView
enum PaintingToolBoxTool {
    /** 云盘*/
    case cloudStorage
    /** 保存板书*/
    case saveBoard
    /** 录制*/
    case record
    /** 投票*/
    case vote
    /** 倒计时*/
    case countDown
    /** 答题器*/
    case answerSheet
}

protocol PaintingToolBoxViewDelegate: class {
    func toolBoxDidSelectTool(_ tool: PaintingToolBoxTool)
}

fileprivate let kGapSize: CGFloat = 1.0
class PaintingToolBoxView: UIView {
    
    weak var delegate: PaintingToolBoxViewDelegate?
    
    var collectionView: UICollectionView!
    
    private var itemWidth: CGFloat = 99.0
    
    private var itemHeight: CGFloat = 79.0
    
    var dataSource: [PaintingToolBoxTool] = [
        .cloudStorage,
        .saveBoard,
        .record,
        .vote,
        .countDown,
        .answerSheet
    ]
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        createViews()
        createConstrains()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        itemWidth = (bounds.width - 2 * kGapSize) / 3
        let rowCount = floor(CGFloat(dataSource.count) / 3.0)
        itemHeight = (bounds.height - (rowCount - 1) * kGapSize) / rowCount
    }
}
// MARK: - UICollectionViewDelegate
extension PaintingToolBoxView: UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return dataSource.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withClass: ToolBoxItemCell.self, for: indexPath)
        let tool = dataSource[indexPath.row]
        switch tool {
        case .cloudStorage:
            cell.imageView.image = AgoraUIImage(object: self, name: "ic_toolbox_cloud")
            cell.titleLabel.text = AgoraKitLocalizedString("toolbox_cloud_storage")
        case .saveBoard:
            cell.imageView.image = AgoraUIImage(object: self, name: "ic_toolbox_save")
            cell.titleLabel.text = AgoraKitLocalizedString("toolbox_save_borad")
        case .record:
            cell.imageView.image = AgoraUIImage(object: self, name: "ic_toolbox_record")
            cell.titleLabel.text = AgoraKitLocalizedString("toolbox_record_class")
        case .vote:
            cell.imageView.image = AgoraUIImage(object: self, name: "ic_toolbox_vote")
            cell.titleLabel.text = AgoraKitLocalizedString("toolbox_vote")
        case .countDown:
            cell.imageView.image = AgoraUIImage(object: self, name: "ic_toolbox_clock")
            cell.titleLabel.text = AgoraKitLocalizedString("toolbox_count_down")
        case .answerSheet:
            cell.imageView.image = AgoraUIImage(object: self, name: "ic_toolbox_answer")
            cell.titleLabel.text = AgoraKitLocalizedString("toolbox_answer_sheet")
        default: break
        }
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        collectionView.deselectItem(at: indexPath, animated: false)
        let tool = dataSource[indexPath.row]
        delegate?.toolBoxDidSelectTool(tool)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: itemWidth, height: itemHeight)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return kGapSize
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return kGapSize
    }
    
    func collectionView(_ collectionView: UICollectionView, didHighlightItemAt indexPath: IndexPath) {
        let cell = collectionView.cellForItem(at: indexPath)
        cell?.backgroundColor = UIColor(rgb: 0xF9F9FC)
    }
    
    func collectionView(_ collectionView: UICollectionView, didUnhighlightItemAt indexPath: IndexPath) {
        let cell = collectionView.cellForItem(at: indexPath)
        cell?.backgroundColor = .white
    }
    
    func collectionView(_ collectionView: UICollectionView, shouldHighlightItemAt indexPath: IndexPath) -> Bool {
        return true
    }
    
}
// MARK: - Creations
extension PaintingToolBoxView {
    func createViews() {
        layer.shadowColor = UIColor(rgb: 0x2F4192, alpha: 0.15).cgColor
        layer.shadowOffset = CGSize(width: 0, height: 2)
        layer.shadowOpacity = 1
        layer.shadowRadius = 6
        
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .vertical
        collectionView = UICollectionView(frame: .zero,
                                          collectionViewLayout: layout)
        collectionView.backgroundColor = UIColor(rgb: 0xEEEEF7)
        collectionView.layer.cornerRadius = 10.0
        collectionView.clipsToBounds = true
        collectionView.showsHorizontalScrollIndicator = false
        collectionView.bounces = false
        collectionView.delegate = self
        collectionView.dataSource = self
        collectionView.register(cellWithClass: ToolBoxItemCell.self)
        addSubview(collectionView)
    }
    
    func createConstrains() {
        collectionView.snp.makeConstraints { make in
            make.left.right.top.bottom.equalToSuperview()
        }
    }
}
