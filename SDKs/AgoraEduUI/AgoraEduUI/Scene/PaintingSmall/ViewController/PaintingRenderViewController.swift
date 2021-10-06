//
//  PaintingRenderViewController.swift
//  AgoraEduUI
//
//  Created by HeZhengQing on 2021/9/9.
//

import Foundation
import SnapKit
import AgoraEduContext
import AgoraUIBaseViews
import AgoraUIEduBaseViews

protocol PaintingRenderViewControllerDelegate: class {
    
    func onClickMemberAt(view: UIView)
    
    func onDoubleTapMember(at index: Int)
}

private let kItemGap: CGFloat = 5.0
class PaintingRenderViewController: UIViewController {
    
    weak var delegate: PaintingRenderViewControllerDelegate?
    
    var teacherView: AgoraMemberItemCell!
        
    var collectionView: AgoraBaseUICollectionView!
    
    var lineView: AgoraBaseUIView!
    
    var selectedIndex: Int = -1
        
    var contextPool: AgoraEduContextPool!
    
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
        contextPool.user.registerEventHandler(self)
        
        let tap = UITapGestureRecognizer.init(target: self, action: #selector(onDoubleClick(_:)))
        tap.numberOfTapsRequired = 2
        tap.numberOfTouchesRequired = 1
        tap.delaysTouchesBegan = true
        collectionView.addGestureRecognizer(tap)
    }
}
// MARK: - Actions
extension PaintingRenderViewController {
    @objc func onDoubleClick(_ sender: UITapGestureRecognizer) {
        let point = sender.location(in: collectionView)
        if sender.state == .ended,
           let indexPath = collectionView.indexPathForItem(at: point) {
            delegate?.onDoubleTapMember(at: indexPath.row)
        }
    }
}
// MARK: - PaintingRenderUIController
extension PaintingRenderViewController: AgoraEduUserHandler {
    
}
// MARK: - UICollectionViewDelegate, UICollectionViewDataSource
extension PaintingRenderViewController: UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    
    public func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return 6
    }
    
    public func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: NSStringFromClass(AgoraMemberItemCell.self), for: indexPath)
        
        return cell
    }
    
    public func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        collectionView.deselectItem(at: indexPath, animated: false)
        if let cell = collectionView.cellForItem(at: indexPath) {
            delegate?.onClickMemberAt(view: cell)
        }
    }
    
    public func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let itemWidth = (view.bounds.width + kItemGap) / 7.0 - kItemGap
        return CGSize(width: itemWidth, height: collectionView.bounds.height)
    }
    
    public func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return kItemGap
    }
    
    public func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        return UIEdgeInsets(top: 0, left: kItemGap, bottom: 0, right: 0)
    }
}

// MARK: - Creations
private extension PaintingRenderViewController {
    func createViews() {
        teacherView = AgoraMemberItemCell(frame: .zero)
        view.addSubview(teacherView)
        
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .horizontal
        collectionView = AgoraBaseUICollectionView(frame: .zero,
                                                   collectionViewLayout: layout)
        collectionView.showsHorizontalScrollIndicator = false
        collectionView.delegate = self
        collectionView.dataSource = self
        collectionView.backgroundColor = UIColor(rgb: 0xF9F9FC)
        collectionView.isScrollEnabled = false
        collectionView.register(AgoraMemberItemCell.self, forCellWithReuseIdentifier: NSStringFromClass(AgoraMemberItemCell.self))
        view.addSubview(collectionView)
        
        lineView = AgoraBaseUIView()
        lineView.backgroundColor = UIColor(rgb: 0xECECF1, alpha: 1)
        view.addSubview(lineView)
    }
    
    func createConstrains() {
        lineView.snp.makeConstraints { make in
            make.left.right.equalToSuperview()
            make.height.equalTo(1)
            make.bottom.equalToSuperview()
        }
        teacherView.snp.makeConstraints { make in
            make.top.left.equalToSuperview()
            make.bottom.equalTo(lineView.snp.top)
            make.width.equalToSuperview().offset(kItemGap).multipliedBy(1/7.0).offset(-kItemGap)
        }
        collectionView.snp.makeConstraints { make in
            make.left.equalTo(teacherView.snp.right)
            make.bottom.equalTo(teacherView)
            make.right.top.equalToSuperview()
        }
    }
}
