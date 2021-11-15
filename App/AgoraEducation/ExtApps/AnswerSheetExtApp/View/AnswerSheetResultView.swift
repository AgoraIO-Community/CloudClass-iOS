//
//  AnswerSheetResultView.swift
//  AgoraExtApp
//
//  Created by Jonathan on 2021/10/27.
//

import UIKit

protocol AnswerSheetResultViewDelegate: NSObjectProtocol {
    /** 统计面板点击了结束答题*/
    func onAnswerSheetDidFinish()
}
class AnswerSheetResultView: UIView {
    
    weak var delegate: AnswerSheetResultViewDelegate?
    
    private var contentView: UIView!
        
    private var titleView: ExtAppTitleView!
    
    private var listContentView: UIView!
        
    private var itemsView: UIStackView!
        
    private var tableView: UITableView!
    
    private var countTitleLabel: UILabel!
    
    private var countLabel: UILabel!
    
    private var ratioTitleLabel: UILabel!
    
    private var ratioLabel: UILabel!
    
    private var answerTitleLabel: UILabel!
    
    private var answerLabel: UILabel!
    
    private var restartButton: UIButton!
        
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        createViews()
        createConstrains()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    public func setupWithModel(_ model: AnswerSheetModel) {
        var correctMember = 0
        for reply in model.replies {
            if reply.answer == model.answer {
                correctMember += 1
            }
        }
        var ratio: Float = 0
        if model.replies.count != 0 {
            ratio = Float(correctMember) / Float(model.replies.count) * 100
        }
        self.countLabel.text = "\(model.replies.count)/\(model.students.count)"
        self.ratioLabel.text = String(format: "%.lf%%", ratio)
        self.answerLabel.text = model.answer.joined(separator: "、")
    }
}

private extension AnswerSheetResultView {
    
    @objc func onClickRestart(_ sender: UIButton) {
        
    }
    
}
// MARK: - UITableView CallBack
extension AnswerSheetResultView: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 6
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withClass: AnswerSheetResultItemCell.self)
        return cell
    }
}
// MARK: - Creaions
private extension AnswerSheetResultView {
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
        
        listContentView = UIView()
        listContentView.backgroundColor = .white
        listContentView.layer.cornerRadius = 4
        listContentView.layer.borderWidth = 1
        listContentView.layer.borderColor = UIColor(hex: 0xEEEEF7).cgColor
        listContentView.clipsToBounds = true
        contentView.addSubview(listContentView)
        
        itemsView = UIStackView(frame: .zero)
        itemsView.backgroundColor = UIColor(hex: 0xF9F9FC)
        itemsView.axis = .horizontal
        itemsView.distribution = .fillEqually
        itemsView.alignment = .fill
        listContentView.addSubview(itemsView)
        
        let nameLabel = UILabel(frame: .zero)
        nameLabel.textAlignment = .center
        nameLabel.font = UIFont.systemFont(ofSize: 12)
        nameLabel.textColor = UIColor(hex: 0x7B88A0)
        nameLabel.text = NSLocalizedString("answer_sheet_student_name", comment: "")
        itemsView.addArrangedSubview(nameLabel)
        
        let timeLabel = UILabel(frame: .zero)
        timeLabel.textAlignment = .center
        timeLabel.font = UIFont.systemFont(ofSize: 12)
        timeLabel.textColor = UIColor(hex: 0x7B88A0)
        timeLabel.text = NSLocalizedString("answer_sheet_student_duration", comment: "")
        itemsView.addArrangedSubview(timeLabel)
        
        let resultLabel = UILabel(frame: .zero)
        resultLabel.textAlignment = .center
        resultLabel.font = UIFont.systemFont(ofSize: 12)
        resultLabel.textColor = UIColor(hex: 0x7B88A0)
        resultLabel.text = NSLocalizedString("answer_sheet_student_answer", comment: "")
        itemsView.addArrangedSubview(resultLabel)
        
        tableView = UITableView.init(frame: .zero, style: .plain)
        tableView.delegate = self
        tableView.dataSource = self
        tableView.tableFooterView = UIView.init(frame: CGRect(x: 0, y: 0, width: 1, height: 0.01))
        tableView.rowHeight = 30
        tableView.allowsSelection = false
        tableView.separatorInset = .zero
        tableView.separatorColor = UIColor(hex: 0xEEEEF7)
        tableView.register(cellWithClass: AnswerSheetResultItemCell.self)
        listContentView.addSubview(tableView)
        
        countTitleLabel = UILabel(frame: .zero)
        countTitleLabel.textAlignment = .center
        countTitleLabel.text = NSLocalizedString("answer_sheet_member_count",
                                                 comment: "")
        countTitleLabel.font = UIFont.systemFont(ofSize: 13)
        countTitleLabel.textColor = UIColor(hex: 0x7B88A0)
        contentView.addSubview(countTitleLabel)
        
        countLabel = UILabel(frame: .zero)
        countLabel.textAlignment = .center
        countLabel.font = UIFont.systemFont(ofSize: 13)
        countLabel.textColor = UIColor(hex: 0x191919)
        contentView.addSubview(countLabel)
        
        ratioTitleLabel = UILabel(frame: .zero)
        ratioTitleLabel.textAlignment = .center
        ratioTitleLabel.text = NSLocalizedString("answer_sheet_ratio",
                                                 comment: "")
        ratioTitleLabel.font = UIFont.systemFont(ofSize: 13)
        ratioTitleLabel.textColor = UIColor(hex: 0x7B88A0)
        contentView.addSubview(ratioTitleLabel)
        
        ratioLabel = UILabel(frame: .zero)
        ratioLabel.textAlignment = .center
        ratioLabel.font = UIFont.systemFont(ofSize: 13)
        ratioLabel.textColor = UIColor(hex: 0x191919)
        contentView.addSubview(ratioLabel)
        
        answerTitleLabel = UILabel(frame: .zero)
        answerTitleLabel.textAlignment = .center
        answerTitleLabel.text = NSLocalizedString("answer_sheet_correct",
                                                  comment: "")
        answerTitleLabel.font = UIFont.systemFont(ofSize: 13)
        answerTitleLabel.textColor = UIColor(hex: 0x7B88A0)
        contentView.addSubview(answerTitleLabel)
        
        answerLabel = UILabel(frame: .zero)
        answerLabel.textAlignment = .center
        answerLabel.font = UIFont.systemFont(ofSize: 13)
        answerLabel.textColor = UIColor(hex: 0x191919)
        contentView.addSubview(answerLabel)
        
        restartButton = UIButton(type: .custom)
        restartButton.layer.cornerRadius = 15
        restartButton.titleLabel?.font = UIFont.systemFont(ofSize: 13)
        restartButton.clipsToBounds = true
        restartButton.addTarget(self,
                                action: #selector(onClickRestart(_:)),
                                for: .touchUpInside)
        let onImage = UIImage(color: UIColor(hex: 0x357BF6), size: CGSize(width: 1, height: 1))
        let offImage = UIImage(color: UIColor(hex: 0xC0D6FF), size: CGSize(width: 1, height: 1))
        restartButton.setBackgroundImage(onImage, for: .normal)
        restartButton.setBackgroundImage(offImage, for: .selected)
        restartButton.setTitle(NSLocalizedString("answer_sheet_restart", comment: ""),
                             for: .normal)
        contentView.addSubview(restartButton)
    }
    
    func createConstrains() {
        contentView.mas_makeConstraints { make in
            make?.width.equalTo()(300)
            make?.height.equalTo()(300)
            make?.left.right().top().bottom().equalTo()(0)
        }
        titleView.mas_makeConstraints { make in
            make?.height.equalTo()(30)
            make?.left.top().right().equalTo()(self)
        }
        listContentView.mas_makeConstraints { make in
            make?.top.equalTo()(titleView.mas_bottom)?.offset()(10)
            make?.left.equalTo()(16)
            make?.right.equalTo()(-16)
            make?.height.equalTo()(140)
        }
        itemsView.mas_makeConstraints { make in
            make?.left.top().right().equalTo()(0)
            make?.height.equalTo()(20)
        }
        tableView.mas_makeConstraints { make in
            make?.top.equalTo()(itemsView.mas_bottom)
            make?.left.right().bottom().equalTo()(0)
        }
        countTitleLabel.mas_makeConstraints { make in
            make?.top.equalTo()(listContentView.mas_bottom)?.offset()(10)
            make?.left.equalTo()(70)
        }
        countLabel.mas_makeConstraints { make in
            make?.left.equalTo()(countTitleLabel.mas_right)?.offset()(4)
            make?.centerY.equalTo()(countTitleLabel)
        }
        ratioTitleLabel.mas_makeConstraints { make in
            make?.left.equalTo()(countTitleLabel)
            make?.top.equalTo()(countTitleLabel.mas_bottom)?.offset()(5)
        }
        ratioLabel.mas_makeConstraints { make in
            make?.left.equalTo()(ratioTitleLabel.mas_right)?.offset()(4)
            make?.centerY.equalTo()(ratioTitleLabel)
        }
        answerTitleLabel.mas_makeConstraints { make in
            make?.left.equalTo()(countTitleLabel)
            make?.top.equalTo()(ratioTitleLabel.mas_bottom)?.offset()(5)
        }
        answerLabel.mas_makeConstraints { make in
            make?.left.equalTo()(answerTitleLabel.mas_right)?.offset()(4)
            make?.centerY.equalTo()(answerTitleLabel)
        }
        restartButton.mas_makeConstraints { make in
            make?.height.equalTo()(30)
            make?.width.equalTo()(90)
            make?.centerX.equalTo()(self)
            make?.bottom.equalTo()(-15)
        }
    }
}
