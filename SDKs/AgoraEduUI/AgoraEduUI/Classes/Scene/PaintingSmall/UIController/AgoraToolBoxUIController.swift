//
//  AgoraToolBoxUIController.swift
//  AgoraEduUI
//
//  Created by DoubleCircle on 2021/11/6.
//

import SwifterSwift
import AgoraEduContext
import AgoraUIEduBaseViews

protocol AgoraToolBoxUIControllerDelegate: NSObjectProtocol {
    func toolBoxDidSelectTool(_ tool: AgoraToolBoxToolType)
}

fileprivate let kGapSize: CGFloat = 1.0
fileprivate let kItemHeight: CGFloat = 80.0
fileprivate let kItemWidth: CGFloat = 100.0

class AgoraToolBoxUIController: UIViewController {
    
    weak var delegate: AgoraToolBoxUIControllerDelegate?
    
    var data: [AgoraToolBoxToolType] = [.cloudStorage, .answerSheet ] {
        didSet {
            if data.count != oldValue.count {
                updateLayout()
            }
        }
    }
    
    private var toolBoxView: UICollectionView!
    /** SDK环境*/
    var contextPool: AgoraEduContextPool!
    
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
        
        createViews()
        createConstrains()
        updateLayout()
    }
}

// MARK: - UI
extension AgoraToolBoxUIController {
    func createViews() {
        view.layer.shadowColor = UIColor(rgb: 0x2F4192,
                                         alpha: 0.15).cgColor
        view.layer.shadowOffset = CGSize(width: 0, height: 2)
        view.layer.shadowOpacity = 1
        view.layer.shadowRadius = 6
        
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .vertical
        toolBoxView = UICollectionView(frame: .zero,
                                       collectionViewLayout: layout)
        toolBoxView.delegate = self
        toolBoxView.dataSource = self
        toolBoxView.backgroundColor = UIColor(rgb: 0xEEEEF7)
        toolBoxView.layer.cornerRadius = 10.0
        toolBoxView.clipsToBounds = true
        toolBoxView.showsHorizontalScrollIndicator = false
        toolBoxView.bounces = false
        toolBoxView.register(cellWithClass: AgoraToolBoxItemCell.self)
        view.addSubview(toolBoxView)
    }
    
    func createConstrains() {
        toolBoxView.mas_makeConstraints {[weak self] make in
            make?.left.right().top().bottom().equalTo()(self?.view)
        }
    }
    
    func updateLayout() {
        let itemCount = CGFloat(data.count ?? 0)
        let rank: CGFloat = itemCount > 3 ? 3 : itemCount
        let width: CGFloat = (rank * (kItemWidth + 1)) - 1
        let rowCount = round(CGFloat(itemCount) / 3.0)
        let height = (rowCount * (kItemHeight + 1)) - 1
        toolBoxView.mas_remakeConstraints {[weak self] make in
            make?.width.equalTo()(width)
            make?.height.equalTo()(height)
            make?.left.right().top().bottom().equalTo()(self?.view)
        }
    }
}

// MARK: - UI ViewDelegate
extension AgoraToolBoxUIController: UICollectionViewDelegate,
                                    UICollectionViewDataSource,
                                    UICollectionViewDelegateFlowLayout {
    // MARK: UICollectionViewDataSource
    func collectionView(_ collectionView: UICollectionView,
                        numberOfItemsInSection section: Int) -> Int {
        return data.count
    }
    
    func collectionView(_ collectionView: UICollectionView,
                        cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withClass: AgoraToolBoxItemCell.self,
                                                      for: indexPath)
        let tool = data[indexPath.row]
        cell.setImage(tool.cellImage(self))
        cell.titleLabel.text = tool.cellText()
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView,
                        didSelectItemAt indexPath: IndexPath) {
        collectionView.deselectItem(at: indexPath,
                                    animated: false)
        let tool = data[indexPath.row]
        delegate?.toolBoxDidSelectTool(tool)
    }
    
    // MARK: UICollectionViewDelegateFlowLayout
    func collectionView(_ collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                        sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: kItemWidth,
                      height: kItemHeight)
    }
    
    func collectionView(_ collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                        minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return kGapSize
    }
    
    func collectionView(_ collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                        minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return kGapSize
    }
    
    // MARK: UICollectionViewDelegate
    func collectionView(_ collectionView: UICollectionView,
                        didHighlightItemAt indexPath: IndexPath) {
        let cell = collectionView.cellForItem(at: indexPath) as? AgoraToolBoxItemCell
        cell?.backgroundColor = UIColor(rgb: 0xF9F9FC)
        cell?.titleLabel.textColor = UIColor(rgb: 0x191919)
        cell?.imageView.tintColor = UIColor(rgb: 0x191919)
    }
    
    func collectionView(_ collectionView: UICollectionView,
                        didUnhighlightItemAt indexPath: IndexPath) {
        let cell = collectionView.cellForItem(at: indexPath) as? AgoraToolBoxItemCell
        cell?.backgroundColor = .white
        cell?.titleLabel.textColor = UIColor(rgb: 0x7B88A0)
        cell?.imageView.tintColor = UIColor(rgb: 0x7B88A0)
    }
    
    func collectionView(_ collectionView: UICollectionView,
                        shouldHighlightItemAt indexPath: IndexPath) -> Bool {
        return true
    }
}
