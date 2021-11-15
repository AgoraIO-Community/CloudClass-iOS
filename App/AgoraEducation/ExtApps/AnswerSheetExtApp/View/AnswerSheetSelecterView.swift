//
//  AnswerSheetSelecterView.swift
//  AgoraExtApp
//
//  Created by Jonathan on 2021/10/27.
//

import UIKit

protocol AnswerSheetSelecterViewDelegate: NSObjectProtocol {
    func onSubmitAnswer(answers:[String])
}
fileprivate let kItemSize = 40
class AnswerSheetSelecterView: UIView {
    
    enum AnswerSheetSelecterState {
        case waiting, replied, change
    }
    
    weak var delegate: AnswerSheetSelecterViewDelegate?
    
    private var contentView: UIView!
    
    private var titleView: ExtAppTitleView!
    
    private var collectionView: UICollectionView!
    
    private var submitButton: UIButton!
    
    private var resetButton: UIButton!
        
    private var selected = [IndexPath]()
    
    private var model: AnswerSheetModel?
    
    private var startTime = Int(Date().timeIntervalSince1970)
    
    private var duration = 0
    
    private var timer: Timer?
    
    private var isLocked: Bool = false {
        didSet {
            if isLocked {
                self.submitButton.isHidden = true
                self.resetButton.isHidden = false
            } else {
                self.submitButton.isHidden = false
                self.resetButton.isHidden = true
            }
        }
    }
    
    deinit {
        self.timer?.invalidate()
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        createViews()
        createConstrains()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    public func setupWithModel(_ model: AnswerSheetModel) {
        self.model = model
        self.mayStartTimer()
        // 是否回答过以及答案
        if let reply = model.replies.first(where: {$0.uuid == model.uuid}) {
            selected.removeAll()
            for answer in reply.answer {
                guard let i = model.items.firstIndex(of: answer) else {
                    continue
                }
                selected.append(IndexPath(row: i, section: 0))
            }
            self.isLocked = true
        }
        self.reloadButtonState()
        let count = Double(model.items.count)
        let row = ceil(count / 4.0)
        collectionView.mas_remakeConstraints { make in
            make?.top.equalTo()(titleView.mas_bottom)?.offset()(20)
            make?.left.equalTo()(16)
            make?.right.equalTo()(-16)
            make?.height.equalTo()(row * (40 + 16))
        }
        self.collectionView.reloadData()
    }
}
// MARK: - Private
private extension AnswerSheetSelecterView {
    func reloadButtonState() {
        self.submitButton.isEnabled = (self.selected.count > 0)
    }
    
    @objc func onClickSubmit(_ sender: UIButton) {
        var answers = [String]()
        for indexPath in selected.sorted() {
            let s = model?.items[indexPath.row] ?? ""
            answers.append(s)
        }
        delegate?.onSubmitAnswer(answers: answers)
    }
    
    @objc func onClickReset(_ sender: UIButton) {
        self.isLocked = false
    }
    
    func mayStartTimer() {
        guard self.timer == nil else {
            return
        }
        self.timer = Timer.scheduledTimer(withTimeInterval: 1, repeats: true, block: { [weak self] _ in
            self?.repeatTimer()
        })
    }
    
    func repeatTimer() {
        self.duration += 1
        let hh = self.duration / 3600
        let mm = self.duration / 60
        let ss = self.duration % 60
        self.titleView.timeLabel.text = String(format: "%02ld:%02ld:%02ld", hh, mm, ss)
    }
}
// MARK: - UICollectionView Call Back
extension AnswerSheetSelecterView: UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return model?.items.count ?? 0
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withClass: AnswerSheetSelectCell.self, for: indexPath)
        let s = model?.items[indexPath.row] ?? ""
        cell.titleLabel.text = s
        cell.aSeleted = selected.contains(indexPath)
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        collectionView.deselectItem(at: indexPath, animated: false)
        guard self.isLocked == false else {
            return
        }
        if selected.contains(indexPath) {
            selected.removeAll(indexPath)
        } else {
            if let m = model, m.mulChoice {
                selected.append(indexPath)
            } else {
                selected.removeAll()
                selected.append(indexPath)
            }
        }
        collectionView.reloadData()
        self.reloadButtonState()
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: kItemSize, height: kItemSize)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 16
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return 10
    }
}
// MARK: - Creations
private extension AnswerSheetSelecterView {
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
        contentView.addSubview(titleView)
        
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .vertical
        collectionView = UICollectionView(frame: .zero,
                                          collectionViewLayout: layout)
        collectionView.backgroundColor = .clear
        collectionView.showsHorizontalScrollIndicator = false
        collectionView.bounces = false
        collectionView.isScrollEnabled = false
        collectionView.delegate = self
        collectionView.dataSource = self
        collectionView.register(cellWithClass: AnswerSheetSelectCell.self)
        contentView.addSubview(collectionView)
        
        submitButton = UIButton(type: .custom)
        submitButton.layer.cornerRadius = 15
        submitButton.titleLabel?.font = UIFont.systemFont(ofSize: 13)
        submitButton.clipsToBounds = true
        submitButton.setTitle(NSLocalizedString("answer_sheet_submit_answer", comment: ""),
                              for: .normal)
        let onImage = UIImage(color: UIColor(hex: 0x357BF6), size: CGSize(width: 1, height: 1))
        let offImage = UIImage(color: UIColor(hex: 0xC0D6FF), size: CGSize(width: 1, height: 1))
        submitButton.setBackgroundImage(onImage, for: .normal)
        submitButton.setBackgroundImage(offImage, for: .selected)
        submitButton.addTarget(self, action: #selector(onClickSubmit(_:)), for: .touchUpInside)
        contentView.addSubview(submitButton)
        
        resetButton = UIButton(type: .custom)
        resetButton.isHidden = true
        resetButton.layer.cornerRadius = 15
        resetButton.layer.borderWidth = 1
        resetButton.layer.borderColor = UIColor(hex: 0x357BF6)?.cgColor
        resetButton.titleLabel?.font = UIFont.systemFont(ofSize: 13)
        resetButton.clipsToBounds = true
        resetButton.setTitle(NSLocalizedString("answer_sheet_change_answer", comment: ""),
                              for: .normal)
        resetButton.setTitleColor(UIColor(hex: 0x357BF6), for: .normal)
        resetButton.addTarget(self, action: #selector(onClickReset(_:)), for: .touchUpInside)
        contentView.addSubview(resetButton)
    }
    
    func createConstrains() {
        contentView.mas_makeConstraints { make in
            make?.width.equalTo()(240)
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
        submitButton.mas_makeConstraints { make in
            make?.width.mas_greaterThanOrEqualTo()(80)
            make?.height.equalTo()(30)
            make?.centerX.equalTo()(self)
            make?.top.equalTo()(collectionView.mas_bottom)
            make?.bottom.equalTo()(-20)
        }
        resetButton.mas_makeConstraints { make in
            make?.center.height().equalTo()(submitButton)
            make?.width.mas_greaterThanOrEqualTo()(80)
        }
    }
}
