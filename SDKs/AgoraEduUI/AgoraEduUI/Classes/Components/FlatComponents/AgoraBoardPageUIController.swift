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

class AgoraBoardPageUIController: UIViewController {
    /** SDK*/
    private var widgetController: AgoraEduWidgetContext {
        if let `subRoom` = subRoom {
            return subRoom.widget
        } else {
            return contextPool.widget
        }
    }
    
    private var contextPool: AgoraEduContextPool
    private var subRoom: AgoraEduSubRoomContext?
    
    /** Views*/
    private var addBtn: UIButton = UIButton(type: .custom)
    private var sepLine: UIView = UIView(frame: .zero)
    private var pageLabel: UILabel = UILabel(frame: .zero)
    private var preBtn: UIButton = UIButton(type: .custom)
    private var nextBtn: UIButton = UIButton(type: .custom)
    
    /** Data */
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
            guard positionMoveFlag != oldValue else {
                return
            }
            
            UIView.animate(withDuration: TimeInterval.agora_animation,
                           delay: 0,
                           options: .curveEaseInOut,
                           animations: { [weak self] in
                            guard let `self` = self else {
                                return
                            }
                            let move: CGFloat = UIDevice.current.isPad ? 49 : 44
                            self.view.transform = CGAffineTransform(translationX: self.positionMoveFlag ? move : 0,
                                                                    y: 0)
                           }, completion: nil)
        }
    }
    
    private let kButtonWidth = 30
    private let kButtonHeight = 30
    
    init(context: AgoraEduContextPool,
         subRoom: AgoraEduSubRoomContext? = nil) {
        self.contextPool = context
        self.subRoom = subRoom
        
        super.init(nibName: nil,
                   bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        initViews()
        initViewFrame()
        updateViewProperties()
        
        widgetController.add(self,
                             widgetId: kBoardWidgetId)
    }
}

extension AgoraBoardPageUIController: AgoraUIContentContainer {
    func initViews() {
        addBtn.addTarget(self,
                          action: #selector(onClickAddPage(_:)),
                          for: .touchUpInside)
        view.addSubview(addBtn)
        
        view.addSubview(sepLine)
        
        preBtn.addTarget(self,
                          action: #selector(onClickPrePage(_:)),
                          for: .touchUpInside)
        view.addSubview(preBtn)
        
        view.addSubview(pageLabel)
        
       
        nextBtn.addTarget(self,
                           action: #selector(onClickNextPage(_:)),
                           for: .touchUpInside)
        view.addSubview(nextBtn)
    }
    
    func initViewFrame() {
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
            make?.left.equalTo()(self.preBtn.mas_right)?.offset()(0)
            make?.right.equalTo()(self.nextBtn.mas_left)?.offset()(0)
        }
    }
    
    func updateViewProperties() {
        view.backgroundColor = .white
        view.layer.cornerRadius = 17
        
        AgoraUIGroup().color.borderSet(layer: view.layer)
        
        if let image = UIImage.agedu_named("ic_board_page_add") {
            addBtn.setImageForAllStates(image)
        }
        
        sepLine.backgroundColor = UIColor(hex: 0xE5E5F0)
        
        if let image = UIImage.agedu_named("ic_board_page_pre") {
            preBtn.setImageForAllStates(image)
        }
        
        pageLabel.text = "1 / 1"
        pageLabel.textAlignment = .center
        pageLabel.font = UIFont.systemFont(ofSize: 14)
        pageLabel.textColor = UIColor(hex:0x586376)
        
        
         if let image = UIImage.agedu_named("ic_board_page_next") {
             nextBtn.setImageForAllStates(image)
         }
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
        case .GetBoardGrantedUsers(let list):
            let localUser = contextPool.user.getLocalUserInfo()
            guard localUser.userRole != .teacher else {
                break
            }
            if list.contains(localUser.userUuid) {
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
    @objc func onClickAddPage(_ sender: UIButton) {
        let changeType = AgoraBoardWidgetPageChangeType.count(pageCount + 1)
        if let message = AgoraBoardWidgetSignal.BoardPageChanged(changeType).toMessageString() {
            widgetController.sendMessage(toWidget: kBoardWidgetId,
                                         message: message)
        }
    }
    
    @objc func onClickPrePage(_ sender: UIButton) {
        let changeType = AgoraBoardWidgetPageChangeType.index(pageIndex - 1 - 1)
        if let message = AgoraBoardWidgetSignal.BoardPageChanged(changeType).toMessageString() {
            widgetController.sendMessage(toWidget: kBoardWidgetId,
                                         message: message)
        }
    }
    
    @objc func onClickNextPage(_ sender: UIButton) {
        let changeType = AgoraBoardWidgetPageChangeType.index(pageIndex - 1 + 1)
        if let message = AgoraBoardWidgetSignal.BoardPageChanged(changeType).toMessageString() {
            widgetController.sendMessage(toWidget: kBoardWidgetId,
                                         message: message)
        }
    }
}