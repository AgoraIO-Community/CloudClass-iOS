//
//  HandsUpItemCell.swift
//  AgoraEduUI
//
//  Created by Jonathan on 2021/10/21.
//

import UIKit

protocol AgoraHandsUpItemCellDelegate: NSObjectProtocol {
    func onClickAcceptAtIndex(_ index: IndexPath)
}

class AgoraHandsUpItemCell: UITableViewCell {
    weak var delegate: AgoraHandsUpItemCellDelegate?
    
    var indexPath: IndexPath?
    
    enum HandsUpCellState {
        case waiting, onStage
    }
    
    var state: HandsUpCellState = .waiting {
        didSet {
            switch state {
            case .waiting:
                stateButton.setImage(UIImage.agedu_named("ic_handsup_off_stage"),
                                     for: .normal)
            case .onStage:
                stateButton.setImage(UIImage.agedu_named("ic_handsup_on_stage"),
                                     for: .normal)
            default: break
            }
        }
    }
    
    var nameLabel: UILabel!
    
    private var stateButton: UIButton!
            
    override init(style: UITableViewCell.CellStyle,
                  reuseIdentifier: String?) {
        super.init(style: style,
                   reuseIdentifier: reuseIdentifier)
        createViews()
        createConstrains()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    @objc func onClickAcceptButton(_ sender: UIButton) {
        guard let i = indexPath else {
            return
        }
        delegate?.onClickAcceptAtIndex(i)
    }
}
// MARK: - Creations
extension AgoraHandsUpItemCell {
    func createViews() {
        nameLabel = UILabel()
        nameLabel.textColor = UIColor(hex: 0x191919)
        nameLabel.font = UIFont.systemFont(ofSize: 12)
        contentView.addSubview(nameLabel)
        
        stateButton = UIButton.init(type: .custom)
        stateButton.setImage(UIImage.agedu_named("ic_handsup_off_stage"),
                             for: .normal)
        stateButton.addTarget(self,
                              action: #selector(onClickAcceptButton(_:)),
                              for: .touchUpInside)
        contentView.addSubview(stateButton)
    }
    
    func createConstrains() {
        nameLabel.mas_makeConstraints { make in
            make?.left.equalTo()(15)
            make?.centerY.equalTo()(nameLabel.superview)
        }
        stateButton.mas_makeConstraints { make in
            make?.right.equalTo()(-15)
            make?.centerY.equalTo()(self)
            make?.width.height().equalTo()(self.mas_height)
        }
    }
}
