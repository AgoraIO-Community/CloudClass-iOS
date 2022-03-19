//
//  AgoraBoardPageUIController.swift
//  AgoraEduUI
//
//  Created by DoubleCircle on 2022/2/3.
//

import AgoraEduContext
import SwifterSwift
import AgoraWidget
import UIKit

protocol AgoraBoardPageUIControllerDelegate: NSObjectProtocol {
    func boardPageUINeedMove(coursewareMin: Bool)
}

class AgoraBoardPageUIController: UIViewController {
    /** Views*/
    private var addBtn: UIButton!
    private var sepLine: UIView!
    private var pageLabel: UILabel!
    private var preBtn: UIButton!
    private var nextBtn: UIButton!
    
    private let kButtonWidth = 30
    private let kButtonHeight = 30
    
    /** SDK*/
    private var contextPool: AgoraEduContextPool!
    /** Data */
    private weak var delegate: AgoraBoardPageUIControllerDelegate?
    private var pageIndex = 1 {
        didSet {
            let text = "\(pageIndex) / \(pageCount)"
            pageLabel.text = text
        }
    }
    
    private var pageCount = 0 {
        didSet {
            let text = "\(pageIndex) / \(pageCount)"
            pageLabel.text = text
        }
    }
    
    private var positionMoveFlag: Bool = false {
        didSet {
            if positionMoveFlag != oldValue {
                delegate?.boardPageUINeedMove(coursewareMin: positionMoveFlag)
            }
        }
    }
    
    init(context: AgoraEduContextPool,
         delegate: AgoraBoardPageUIControllerDelegate) {
        super.init(nibName: nil, bundle: nil)
        self.contextPool = context
        self.delegate = delegate
        
        contextPool.widget.add(self,
                               widgetId: kBoardWidgetId)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .clear
        
        createViews()
        createConstraint()
    }
}

// MARK: - AgoraWidgetMessageObserver
extension AgoraBoardPageUIController: AgoraWidgetMessageObserver {
    func onMessageReceived(_ message: String,
                           widgetId: String) {
        guard widgetId == kBoardWidgetId,
              let signal = message.toBoardSignal() else {
                  return
              }
        switch signal {
        case .BoardPageChanged(let type):
            switch type {
            case .index(let index):
                // index从0开始，UI显示时需要+1
                pageIndex = index + 1
            case .count(let count):
                pageCount = count
            }
        case .BoardGrantDataChanged(let list):
            let localUser = contextPool.user.getLocalUserInfo()
            guard localUser.userRole != .teacher else {
                break
            }
            if let grantList = list,
               grantList.contains(localUser.userUuid) {
                view.isHidden = false
            } else {
                view.isHidden = true
            }
        case .WindowStateChanged(let state):
            positionMoveFlag = (state == .min)
        default:
            break
        }
    }
}

// MARK: - private
extension AgoraBoardPageUIController {
    func createViews() {
        view.backgroundColor = .white
        
        view.layer.cornerRadius = 17
        view.layer.shadowColor = UIColor(hex: 0x2F4192,
                                         transparency: 0.15)?.cgColor
        view.layer.shadowOffset = CGSize(width: 0,
                                         height: 2)
        view.layer.shadowOpacity = 1
        view.layer.shadowRadius = 6
        
        addBtn = UIButton(type: .custom)
        if let image = UIImage.agedu_named("ic_board_page_add") {
            addBtn.setImageForAllStates(image)
        }
        addBtn.addTarget(self,
                          action: #selector(onClickAddPage(_:)),
                          for: .touchUpInside)
        view.addSubview(addBtn)
        
        sepLine = UIView(frame: .zero)
        sepLine.backgroundColor = UIColor(hex: 0xE5E5F0)
        view.addSubview(sepLine)
        
        preBtn = UIButton(type: .custom)
        if let image = UIImage.agedu_named("ic_board_page_pre") {
            preBtn.setImageForAllStates(image)
        }
        preBtn.addTarget(self,
                          action: #selector(onClickPrePage(_:)),
                          for: .touchUpInside)
        view.addSubview(preBtn)
        
        pageLabel = UILabel(frame: .zero)
        pageLabel.text = "1 / 1"
        pageLabel.textAlignment = .center
        pageLabel.font = UIFont.systemFont(ofSize: 14)
        pageLabel.textColor = UIColor(hex:0x586376)
        view.addSubview(pageLabel)
        
        nextBtn = UIButton(type: .custom)
        if let image = UIImage.agedu_named("ic_board_page_next") {
            nextBtn.setImageForAllStates(image)
        }
        nextBtn.addTarget(self,
                           action: #selector(onClickNextPage(_:)),
                           for: .touchUpInside)
        view.addSubview(nextBtn)
    }
    
    func createConstraint() {
        addBtn.mas_remakeConstraints { make in
            make?.centerY.equalTo()(self.view)
            make?.left.equalTo()(10)
            make?.width.height().equalTo()(kButtonWidth)
        }
        
        sepLine.mas_makeConstraints { make in
            make?.centerY.equalTo()(self.view)
            make?.left.equalTo()(self.addBtn.mas_right)?.offset()(4)
            make?.top.equalTo()(8)
            make?.bottom.equalTo()(-8)
            make?.width.equalTo()(1)
        }

        preBtn.mas_remakeConstraints { make in
            make?.centerY.equalTo()(self.view)
            make?.left.equalTo()(self.sepLine.mas_right)?.offset()(3)
            make?.width.height().equalTo()(kButtonWidth)
        }
        
        nextBtn.mas_makeConstraints { make in
            make?.centerY.equalTo()(self.view)
            make?.right.equalTo()(-10)
            make?.width.height().equalTo()(kButtonWidth)
        }
        
        pageLabel.mas_makeConstraints { make in
            make?.centerY.equalTo()(self.view)
            make?.left.equalTo()(self.preBtn.mas_right)?.offset()(4)
            make?.right.equalTo()(self.nextBtn.mas_left)?.offset()(-4)
        }
    }
    
    @objc func onClickAddPage(_ sender: UIButton) {
        let changeType = AgoraBoardWidgetPageChangeType.count(pageCount + 1)
        if let message = AgoraBoardWidgetSignal.BoardPageChanged(changeType).toMessageString() {
            contextPool.widget.sendMessage(toWidget: kBoardWidgetId,
                                           message: message)
        }
    }
    
    @objc func onClickPrePage(_ sender: UIButton) {
        let changeType = AgoraBoardWidgetPageChangeType.index(pageIndex - 1 - 1)
        if let message = AgoraBoardWidgetSignal.BoardPageChanged(changeType).toMessageString() {
            contextPool.widget.sendMessage(toWidget: kBoardWidgetId,
                                           message: message)
        }
    }
    
    @objc func onClickNextPage(_ sender: UIButton) {
        let changeType = AgoraBoardWidgetPageChangeType.index(pageIndex - 1 + 1)
        if let message = AgoraBoardWidgetSignal.BoardPageChanged(changeType).toMessageString() {
            contextPool.widget.sendMessage(toWidget: kBoardWidgetId,
                                           message: message)
        }
    }
}
