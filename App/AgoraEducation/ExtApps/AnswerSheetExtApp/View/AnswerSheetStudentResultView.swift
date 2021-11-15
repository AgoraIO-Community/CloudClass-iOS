//
//  AnswerSheetStudentResultView.swift
//  AgoraEducation
//
//  Created by Jonathan on 2021/11/10.
//  Copyright © 2021 Agora. All rights reserved.
//

import UIKit

class AnswerSheetStudentResultView: UIView {
    
    private var contentView: UIView!
    
    private var titleView: ExtAppTitleView!
    
    private var numTitleLabel: UILabel!
    
    private var numLabel: UILabel!
    
    private var ratioTitleLabel: UILabel!
    
    private var ratioLabel: UILabel!
    
    private var correctTitleLabel: UILabel!
    
    private var correctLabel: UILabel!
    
    private var mineTitleLabel: UILabel!
    
    private var mineLabel: UILabel!

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
        var myAnswer = [String]()
        for reply in model.replies {
            if reply.answer == model.answer {
                correctMember += 1
            }
            if reply.uuid == model.uuid {
                myAnswer = reply.answer
            }
        }
        var ratio: Float = 0
        if model.replies.count != 0 {
            ratio = Float(correctMember) / Float(model.replies.count) * 100
        }
        self.numLabel.text = "\(model.replies.count)/\(model.students.count)"
        self.ratioLabel.text = String(format: "%.lf%%", ratio)
        self.correctLabel.text = model.answer.joined()
        self.mineLabel.text = myAnswer.joined()
        if model.answer == myAnswer {
            self.mineLabel.textColor = UIColor(hex: 0x0BAD69)
        } else {
            self.mineLabel.textColor = UIColor(hex: 0xF04C36)
        }
        if let startStr = model.startTime, let endStr = model.endTime,
           let start = Int(startStr), let end = Int(endStr) {
            let duration = end - start
            let hh = duration / 3600
            let mm = duration / 60
            let ss = duration % 60
            self.titleView.timeLabel.text = String(format: "%02ld:%02ld:%02ld", hh, mm, ss)
        }
    }
}
// MARK: - Creations
private extension AnswerSheetStudentResultView {
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
        
        numTitleLabel = UILabel()
        numTitleLabel.font = UIFont.systemFont(ofSize: 13)
        numTitleLabel.textColor = UIColor(hex: 0x7B88A0)
        numTitleLabel.text = NSLocalizedString("answer_sheet_member_count", comment: "")
        contentView.addSubview(numTitleLabel)
        
        numLabel = UILabel()
        numLabel.font = UIFont.systemFont(ofSize: 13)
        numLabel.textColor = UIColor(hex: 0x191919)
        contentView.addSubview(numLabel)
        
        ratioTitleLabel = UILabel()
        ratioTitleLabel.font = UIFont.systemFont(ofSize: 13)
        ratioTitleLabel.textColor = UIColor(hex: 0x7B88A0)
        ratioTitleLabel.text = NSLocalizedString("answer_sheet_ratio", comment: "")
        contentView.addSubview(ratioTitleLabel)
        
        ratioLabel = UILabel()
        ratioLabel.font = UIFont.systemFont(ofSize: 13)
        ratioLabel.textColor = UIColor(hex: 0x191919)
        contentView.addSubview(ratioLabel)
        
        correctTitleLabel = UILabel()
        correctTitleLabel.font = UIFont.systemFont(ofSize: 13)
        correctTitleLabel.textColor = UIColor(hex: 0x7B88A0)
        correctTitleLabel.text = NSLocalizedString("answer_sheet_correct", comment: "")
        contentView.addSubview(correctTitleLabel)
        
        correctLabel = UILabel()
        correctLabel.font = UIFont.systemFont(ofSize: 13)
        correctLabel.textColor = UIColor(hex: 0x191919)
        contentView.addSubview(correctLabel)
        
        mineTitleLabel = UILabel()
        mineTitleLabel.font = UIFont.systemFont(ofSize: 13)
        mineTitleLabel.textColor = UIColor(hex: 0x7B88A0)
        mineTitleLabel.text = NSLocalizedString("answer_sheet_mine", comment: "")
        contentView.addSubview(mineTitleLabel)
        
        mineLabel = UILabel()
        mineLabel.font = UIFont.systemFont(ofSize: 13)
        mineLabel.textColor = UIColor(hex: 0x0BAD69)
        contentView.addSubview(mineLabel)
    }
    
    func createConstrains() {
        contentView.mas_makeConstraints { make in
            make?.width.equalTo()(240)
            make?.height.equalTo()(180)
            make?.left.right().top().bottom().equalTo()(0)
        }
        titleView.mas_makeConstraints { make in
            make?.height.equalTo()(30)
            make?.left.top().right().equalTo()(self)
        }
        numTitleLabel.mas_makeConstraints { make in
            make?.top.equalTo()(titleView.mas_bottom)?.offset()(21)
            make?.left.equalTo()(55)
        }
        numLabel.mas_makeConstraints { make in
            make?.left.equalTo()(numTitleLabel.mas_right)?.offset()(4)
            make?.centerY.equalTo()(numTitleLabel)
        }
        ratioTitleLabel.mas_makeConstraints { make in
            make?.top.equalTo()(numTitleLabel.mas_bottom)?.offset()(14)
            make?.left.equalTo()(numTitleLabel)
        }
        ratioLabel.mas_makeConstraints { make in
            make?.left.equalTo()(ratioTitleLabel.mas_right)?.offset()(4)
            make?.centerY.equalTo()(ratioTitleLabel)
        }
        correctTitleLabel.mas_makeConstraints { make in
            make?.top.equalTo()(ratioTitleLabel.mas_bottom)?.offset()(14)
            make?.left.equalTo()(numTitleLabel)
        }
        correctLabel.mas_makeConstraints { make in
            make?.left.equalTo()(correctTitleLabel.mas_right)?.offset()(4)
            make?.centerY.equalTo()(correctTitleLabel)
        }
        mineTitleLabel.mas_makeConstraints { make in
            make?.top.equalTo()(correctTitleLabel.mas_bottom)?.offset()(14)
            make?.left.equalTo()(numTitleLabel)
        }
        mineLabel.mas_makeConstraints { make in
            make?.left.equalTo()(mineTitleLabel.mas_right)?.offset()(4)
            make?.centerY.equalTo()(mineTitleLabel)
        }
    }
}

