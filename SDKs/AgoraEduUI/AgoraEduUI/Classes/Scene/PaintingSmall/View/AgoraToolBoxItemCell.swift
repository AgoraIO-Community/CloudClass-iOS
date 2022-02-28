//
//  PaintingToolBoxView.swift
//  AgoraEduUI
//
//  Created by HeZhengQing on 2021/9/28.
//

import SwifterSwift
import Masonry
import UIKit

// MARK: - AgoraToolBoxItemCell
class AgoraToolBoxItemCell: UICollectionViewCell {
        
    var imageView: UIImageView!
    
    var titleLabel: UILabel!
        
    override init(frame: CGRect) {
        super.init(frame: frame)
        backgroundColor = .white
        
        imageView = UIImageView(frame: .zero)
        imageView.tintColor = UIColor(hex: 0x7B88A0)
        imageView.contentMode = .scaleAspectFit
        addSubview(imageView)
        
        titleLabel = UILabel(frame: .zero)
        titleLabel.font = UIFont.systemFont(ofSize: 12)
        titleLabel.textColor = UIColor(hex: 0x7B88A0)
        titleLabel.textAlignment = .center
        addSubview(titleLabel)
        
        titleLabel.mas_remakeConstraints { make in
            make?.centerX.equalTo()(titleLabel.superview)
            make?.centerY.equalTo()(self)?.offset()(12)
            make?.left.right().equalTo()(titleLabel.superview)
        }
        imageView.mas_remakeConstraints { make in
            make?.bottom.equalTo()(titleLabel.mas_top)?.offset()(-2)
            make?.centerX.equalTo()(imageView.superview)
            make?.width.height().equalTo()(28)
        }
    }
    
    func setImage(_ image: UIImage?) {
        guard let i = image else {
            return
        }
        imageView.image = i.withRenderingMode(.alwaysTemplate)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

// MARK: - AgoraTeachingAidType
enum AgoraTeachingAidType {
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
    
    func cellImage() -> UIImage? {
        switch self {
        case .cloudStorage:     return UIImage.agedu_named("ic_toolbox_cloud")
        case .saveBoard:        return UIImage.agedu_named("ic_toolbox_save")
        case .record:           return UIImage.agedu_named("ic_toolbox_record")
        case .vote:             return UIImage.agedu_named("ic_toolbox_vote")
        case .countDown:        return UIImage.agedu_named("ic_toolbox_clock")
        case .answerSheet:      return UIImage.agedu_named("ic_toolbox_answer")
        default: return nil
        }
    }
    
    func cellText() -> String? {
        switch self {
        case .cloudStorage:     return "toolbox_cloud_storage".agedu_localized()
        case .saveBoard:        return "toolbox_save_borad".agedu_localized()
        case .record:           return "toolbox_record_class".agedu_localized()
        case .vote:             return "toolbox_vote".agedu_localized()
        case .countDown:        return "toolbox_count_down".agedu_localized()
        case .answerSheet:      return "toolbox_answer_sheet".agedu_localized()
        default:                return nil
        }
    }
}
