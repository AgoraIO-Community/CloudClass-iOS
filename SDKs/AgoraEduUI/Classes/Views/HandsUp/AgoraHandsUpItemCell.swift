//
//  HandsUpItemCell.swift
//  AgoraEduUI
//
//  Created by Jonathan on 2021/10/21.
//

import AgoraUIBaseViews
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
            let config = UIConfig.handsList
            switch state {
            case .waiting:
                stateButton.setImage(config.offImage,
                                     for: .normal)
            case .onStage:
                stateButton.setImage(config.onImage,
                                     for: .normal)
            default: break
            }
        }
    }
    
    lazy var nameLabel = UILabel()
    
    private var stateButton = UIButton.init(type: .custom)
            
    override init(style: UITableViewCell.CellStyle,
                  reuseIdentifier: String?) {
        super.init(style: style,
                   reuseIdentifier: reuseIdentifier)
        initViews()
        initViewFrame()
        updateViewProperties()
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
extension AgoraHandsUpItemCell: AgoraUIContentContainer {
    func initViews() {
        contentView.addSubview(nameLabel)
        
        stateButton.setImage(UIConfig.handsList.offImage,
                             for: .normal)
        stateButton.addTarget(self,
                              action: #selector(onClickAcceptButton(_:)),
                              for: .touchUpInside)
        contentView.addSubview(stateButton)
    }
    
    func initViewFrame() {
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
    
    func updateViewProperties() {
        let config = UIConfig.handsList
        nameLabel.textColor = config.label.color
        nameLabel.font = config.label.font
    }
}
