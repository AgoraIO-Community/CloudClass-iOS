//
//  AnswerSheetSetupView.swift
//  AgoraExtApp
//
//  Created by Jonathan on 2021/10/27.
//

import UIKit
import Masonry

protocol AnswerSheetSetupViewDelegate: NSObjectProtocol {
    
    func onSubmitSetup(items: [String], answers: [String])
}

fileprivate let kItemSize = 40
class AnswerSheetSetupView: UIView {
    
    weak var delegate: AnswerSheetSetupViewDelegate?
    
    private var contentView: UIView!
    
    private var titleView: ExtAppTitleView!
    
    private var collectionView: UICollectionView!
    
    private var plusButton: UIButton!
    
    private var minusButton: UIButton!
    
    private var selected: [IndexPath] = [IndexPath]()
    
    private var startButton: UIButton!
    
    private var itemsCount = 0
        
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        createViews()
        createConstrains()
        self.updateItemCount(4)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

}
// MARK: - Private
private extension AnswerSheetSetupView {
    func updateItemCount(_ count: Int) {
        if count > 8 {
            self.minusButton.isHidden = false
            self.plusButton.isHidden = true
            itemsCount = 8
        } else if count < 2 {
            self.minusButton.isHidden = true
            self.plusButton.isHidden = false
            itemsCount = 2
        } else {
            self.minusButton.isHidden = false
            self.plusButton.isHidden = false
            itemsCount = count
        }
        for indexPath in self.selected {
            if indexPath.row > itemsCount - 1 {
                selected.removeAll(indexPath)
            }
        }
        self.startButton.isEnabled = (self.selected.count != 0)
        let count = Double(itemsCount)
        let row = ceil(count / 4.0)
        let height = Int(row) * (kItemSize + 20) + 20
        collectionView.mas_remakeConstraints { make in
            make?.top.equalTo()(titleView.mas_bottom)?.offset()(20)
            make?.left.equalTo()(16)
            make?.right.equalTo()(-16)
            make?.height.equalTo()(height)
        }
        collectionView.reloadData()
    }
}
// MARK: - Actions
extension AnswerSheetSetupView {
    @objc func onClickAdd(_ sender: UIButton) {
        self.updateItemCount(itemsCount + 1)
    }
    
    @objc func onClickMinus(_ sender: UIButton) {
        self.updateItemCount(itemsCount - 1)
    }
    
    @objc func onClickStart(_ sender: UIButton) {
        var items = [String]()
        var answers = [String]()
        for i in 0..<itemsCount {
            if let c = UnicodeScalar(65 + i) {
                let item = String(Character(c))
                items.append(item)
            }
        }
        for indesPath in self.selected.sorted() {
            let a = items[indesPath.row]
            answers.append(a)
        }
        self.delegate?.onSubmitSetup(items: items, answers: answers)
    }
    
    @objc func onClickClose(_ sender: UIButton) {
        
    }
}
// MARK: - UICollectionView Call Back
extension AnswerSheetSetupView: UICollectionViewDelegateFlowLayout, UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return itemsCount
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withClass: AnswerSheetSelectCell.self, for: indexPath)
        if let c = UnicodeScalar(65 + indexPath.row) {
            cell.titleLabel.text = String(Character(c))
        }
        cell.aSeleted = self.selected.contains(indexPath)
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        collectionView.deselectItem(at: indexPath, animated: false)
        if selected.contains(indexPath) {
            selected.removeAll(indexPath)
        } else {
            selected.append(indexPath)
        }
        self.startButton.isEnabled = (self.selected.count != 0)
        collectionView.reloadData()
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: kItemSize, height: kItemSize)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 20
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return 10
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        return UIEdgeInsets(top: 20, left: 20, bottom: 0, right: 20)
    }
}
// MARK: - Creations
private extension AnswerSheetSetupView {
    func createViews() {
        backgroundColor = .clear
        layer.shadowColor = UIColor(rgb: 0x2F4192,
                                    alpha: 0.15).cgColor
        layer.shadowOffset = CGSize(width: 0,
                                    height: 2)
        layer.shadowOpacity = 1
        
        contentView = UIView()
        contentView.backgroundColor = .white
        contentView.layer.cornerRadius = 6
        contentView.clipsToBounds = true
        addSubview(contentView)
        
        titleView = ExtAppTitleView(frame: .zero)
        titleView.titleLabel.text = NSLocalizedString("answer_sheet_title", comment: "")
        titleView.closeButton.addTarget(self, action: #selector(onClickClose(_:)), for: .touchUpInside)
        contentView.addSubview(titleView)
        
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .vertical
        collectionView = UICollectionView(frame: .zero,
                                          collectionViewLayout: layout)
        collectionView.backgroundColor = .white
        collectionView.layer.cornerRadius = 4
        collectionView.layer.borderWidth = 1
        collectionView.layer.borderColor = UIColor(hex: 0xEEEEF7).cgColor
        collectionView.clipsToBounds = true
        collectionView.showsHorizontalScrollIndicator = false
        collectionView.bounces = false
        collectionView.delegate = self
        collectionView.dataSource = self
        collectionView.register(cellWithClass: AnswerSheetSelectCell.self)
        contentView.addSubview(collectionView)
        
        startButton = UIButton(type: .custom)
        startButton.layer.cornerRadius = 15
        startButton.titleLabel?.font = UIFont.systemFont(ofSize: 13)
        startButton.clipsToBounds = true
        startButton.addTarget(self, action: #selector(onClickStart(_:)), for: .touchUpInside)
        let onImage = UIImage(color: UIColor(hex: 0x357BF6), size: CGSize(width: 1, height: 1))
        let offImage = UIImage(color: UIColor(hex: 0xC0D6FF), size: CGSize(width: 1, height: 1))
        startButton.setBackgroundImage(onImage, for: .normal)
        startButton.setBackgroundImage(offImage, for: .selected)
        startButton.setTitle(NSLocalizedString("answer_sheet_begin", comment: ""),
                             for: .normal)
        contentView.addSubview(startButton)
        
        plusButton = UIButton(type: .custom)
        plusButton.layer.cornerRadius = 15
        plusButton.layer.borderWidth = 1
        plusButton.layer.borderColor = UIColor(hex: 0xEEEEF7).cgColor
        plusButton.addTarget(self, action: #selector(onClickAdd(_:)), for: .touchUpInside)
        plusButton.setTitle("+", for: .normal)
        plusButton.setTitleColor(UIColor(hex: 0x7B88A0), for: .normal)
        contentView.addSubview(plusButton)
        
        minusButton = UIButton(type: .custom)
        minusButton.layer.cornerRadius = 15
        minusButton.layer.borderWidth = 1
        minusButton.layer.borderColor = UIColor(hex: 0xEEEEF7).cgColor
        minusButton.addTarget(self, action: #selector(onClickMinus(_:)), for: .touchUpInside)
        minusButton.setTitle("-", for: .normal)
        minusButton.setTitleColor(UIColor(hex: 0x7B88A0), for: .normal)
        contentView.addSubview(minusButton)
    }
    
    func createConstrains() {
        contentView.mas_makeConstraints { make in
            make?.width.equalTo()(300)
            make?.left.right().top().bottom().equalTo()(0)
        }
        titleView.mas_makeConstraints { make in
            make?.height.equalTo()(30)
            make?.left.top().right().equalTo()(self)
        }
        collectionView.mas_makeConstraints { make in
            make?.top.equalTo()(titleView.mas_bottom)?.offset()(20)
            make?.left.equalTo()(16)
            make?.right.equalTo()(-16)
            make?.height.equalTo()(90)
        }
        startButton.mas_makeConstraints { make in
            make?.top.equalTo()(collectionView.mas_bottom)?.offset()(20)
            make?.height.equalTo()(30)
            make?.width.equalTo()(90)
            make?.centerX.equalTo()(self)
            make?.bottom.equalTo()(-20)
        }
        plusButton.mas_makeConstraints { make in
            make?.width.height().equalTo()(30)
            make?.centerY.equalTo()(startButton)
            make?.right.equalTo()(startButton.mas_left)?.offset()(-20)
        }
        minusButton.mas_makeConstraints { make in
            make?.width.height().equalTo()(30)
            make?.centerY.equalTo()(startButton)
            make?.left.equalTo()(startButton.mas_right)?.offset()(20)
        }
    }
}
