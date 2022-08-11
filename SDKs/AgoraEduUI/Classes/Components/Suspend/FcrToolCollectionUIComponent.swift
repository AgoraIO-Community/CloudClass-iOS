//
//  AgoraTeachingAidsUIController.swift
//  AgoraEduUI
//
//  Created by DoubleCircle on 2022/2/10.
//

import AgoraEduContext
import SwifterSwift
import AgoraWidget
import UIKit

protocol FcrToolCollectionUIComponentDelegate: NSObjectProtocol {
    func toolCollectionDidSelectCell(view: UIView)
    func toolCollectionCellNeedSpread(_ spread: Bool)
    func toolCollectionDidDeselectCell()
    func toolCollectionDidSelectTeachingAid(type: AgoraTeachingAidType)
    func toolCollectionDidChangeAppearance(_ appear: Bool)
}

class FcrToolCollectionUIComponent: UIViewController {
    /** SDK环境*/
    private var contextPool: AgoraEduContextPool!
    private var subRoom: AgoraEduSubRoomContext?
    
    private var userController: AgoraEduUserContext {
        if let `subRoom` = subRoom {
            return subRoom.user
        } else {
            return contextPool.user
        }
    }
    
    private var widgetController: AgoraEduWidgetContext {
        if let `subRoom` = subRoom {
            return subRoom.widget
        } else {
            return contextPool.widget
        }
    }
    
    /// Data
    private weak var delegate: FcrToolCollectionUIComponentDelegate?
    
    private var localAuth: Bool = false {
        didSet {
            guard localAuth != oldValue else {
                return
            }
            view.isHidden = !localAuth
            delegate?.toolCollectionDidChangeAppearance(localAuth)
            
            guard localAuth else {
                return
            }
            setBoardAssistantType()
        }
    }
    
    var suggestLength: CGFloat = UIDevice.current.agora_is_pad ? 34 : 32
    var suggestSpreadHeight: CGFloat = 80
        
    private var curSelectedCell: AgoraToolCollectionSelectType = .none {
        didSet {
            guard curSelectedCell != oldValue else {
                curSelectedCell = .none
                delegate?.toolCollectionDidDeselectCell()
                return
            }
            switch curSelectedCell {
            case .main:
                curSelectedCell = .main
                mainToolsView.frame = CGRect(origin: .zero,
                                             size: mainToolsView.suggestSize)
                delegate?.toolCollectionDidSelectCell(view: mainToolsView)
            case .sub:
                curSelectedCell = .sub
                subToolsView.frame = CGRect(origin: .zero,
                                             size: subToolsView.suggestSize)
                delegate?.toolCollectionDidSelectCell(view: subToolsView)
            default:
                delegate?.toolCollectionDidDeselectCell()
            }
        }
    }
    
    private var currentMainTool: AgoraBoardToolMainType = .clicker {
        didSet {
            handleCurrentMainToolChange(oldValue: oldValue)
        }
    }
    
    private var currentSubTool: AgoraBoardToolPaintType = .pencil {
        didSet {
            if currentSubTool != oldValue {
                handleCurrentSubToolChange()
            }
        }
    }
    
    /// UI
    // AgoraToolCollectionUIController自身视图为教室中的cell，同时控制工具栏和配置栏
    private lazy var contentView = UIView()
    private lazy var subCell = AgoraToolCollectionCell(isMain: false,
                                                       color: nil,
                                                       image: currentSubTool.image,
                                                       font: subToolsView.curTextFont.value / 2)
    private lazy var sepLine = UIView()
    private lazy var mainCell = AgoraToolCollectionCell(isMain: true,
                                                        color: nil,
                                                        image: currentMainTool.unselectedImage)
    
    // 主要工具栏CollectionView（包含教具、白板工具）
    private var mainToolsView: AgoraMainToolsView!
    // 白板工具配置CollectionView
    private var subToolsView: AgoraBoardToolConfigView!
        
    deinit {
        print("\(#function): \(self.classForCoder)")
    }

    init(context: AgoraEduContextPool,
         subRoom: AgoraEduSubRoomContext? = nil,
         delegate: FcrToolCollectionUIComponentDelegate? = nil) {        
        super.init(nibName: nil,
                   bundle: nil)
        
        self.contextPool = context
        self.subRoom = subRoom

        widgetController.add(self,
                             widgetId: kBoardWidgetId)
        
        self.delegate = delegate
        
        initCtrlViews()
    }
    
    func updateBoardActiveState(isActive: Bool) {
        guard localAuth,
              isActive else {
            view.isHidden = true
            delegate?.toolCollectionDidChangeAppearance(false)
            return
        }
        view.isHidden = false
        delegate?.toolCollectionDidChangeAppearance(true)
    }
    
    func onBoardPrivilegeListChaned(_ privilege: Bool,
                                    userList: [String]) {
        let localUser = userController.getLocalUserInfo()

        guard userList.contains(localUser.userUuid) else {
            return
        }
        
        localAuth = privilege
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
        
    override func viewDidLoad() {
        super.viewDidLoad()
        
        initViews()
        initViewFrame()
        updateViewProperties()
    }
}
// MARK: - AgoraUIActivity & AgoraUIContentContainer
@objc extension FcrToolCollectionUIComponent: AgoraUIActivity, AgoraUIContentContainer {
    // AgoraUIActivity
    func viewWillActive() {
        
    }
    
    func viewWillInactive() {
        
    }
    
    // AgoraUIContentContainer
    func initViews() {
        view.addSubview(contentView)
        
        mainCell.addGestureRecognizer(UITapGestureRecognizer(target: self,
                                                             action: #selector(didSelectMain)))
        contentView.addSubview(mainCell)
        contentView.addSubview(sepLine)
        
        subCell.addGestureRecognizer(UITapGestureRecognizer(target: self,
                                                            action: #selector(didSelectSub)))
        contentView.addSubview(subCell)
        
        updateImage()
    }
    
    func initViewFrame() {
        if currentMainTool == .paint ||
            currentMainTool == .text {
            contentView.mas_remakeConstraints { make in
                make?.left.right().top().bottom().equalTo()(0)
            }
            subCell.mas_remakeConstraints { make in
                make?.top.equalTo()(4)
                make?.centerX.equalTo()(0)
                make?.width.height().equalTo()(suggestLength)
            }
            sepLine.mas_remakeConstraints { make in
                make?.centerY.equalTo()(self.view.mas_centerY)
                make?.centerX.equalTo()(self.view.mas_centerX)
                make?.width.equalTo()(20)
                make?.height.equalTo()(1)
            }
            mainCell.mas_remakeConstraints { make in
                make?.bottom.equalTo()(-4)
                make?.centerX.equalTo()(0)
                make?.width.height().equalTo()(suggestLength)
            }
        } else {
            contentView.mas_remakeConstraints { make in
                make?.left.right().top().bottom().equalTo()(0)
            }
            mainCell.mas_remakeConstraints { make in
                make?.centerX.centerY().equalTo()(0)
                make?.width.height().equalTo()(suggestLength)
            }
        }
    }
    
    func updateViewProperties() {
        let config = UIConfig.toolCollection
        
        contentView.layer.shadowColor = config.shadow.color
        contentView.layer.shadowOffset = config.shadow.offset
        contentView.layer.shadowOpacity = config.shadow.opacity
        contentView.layer.shadowRadius = config.shadow.radius
        
        contentView.backgroundColor = config.backgroundColor
        contentView.layer.cornerRadius = config.cellCornerRadius
        sepLine.backgroundColor = config.sepLine.backgroundColor
    }
}
// MARK: - Widget
extension FcrToolCollectionUIComponent: AgoraWidgetActivityObserver,
                                           AgoraWidgetMessageObserver {
    func onWidgetActive(_ widgetId: String) {
        
    }
    
    func onWidgetInactive(_ widgetId: String) {
    
    }
    
    func onMessageReceived(_ message: String,
                           widgetId: String) {
        guard widgetId == kBoardWidgetId,
              let signal = message.toBoardSignal() else {
            return
        }
        switch signal {
        case .BoardStepChanged(let changeType):
            handleBoardWidgetStep(changeType)
        case .CloseBoard:
            view.isHidden = true
            delegate?.toolCollectionDidChangeAppearance(false)
        default:
            break
        }
    }
}

// MARK: - UI Delegate
extension FcrToolCollectionUIComponent: AgoraMainToolsViewDelegate,
                                           AgoraBoardToolConfigViewDelegate {
    // MARK: - AgoraMainToolsViewDelegate
    func didSelectTeachingAid(type: AgoraTeachingAidType) {
        delegate?.toolCollectionDidSelectTeachingAid(type: type)
    }
    
    func didSelectBoardTool(type: AgoraBoardToolMainType) {
        if type.needUpdateCell {
            currentMainTool = type
        } else {
            var signal: AgoraBoardWidgetSignal?
            switch type {
            case .clear:
                signal = AgoraBoardWidgetSignal.ClearBoard
            case .pre:
                signal = AgoraBoardWidgetSignal.BoardStepChanged(.pre(1))
            case .next:
                signal = AgoraBoardWidgetSignal.BoardStepChanged(.next(1))
            default:
                break
            }
            if let boardSignal = signal,
               let message = boardSignal.toMessageString() {
                widgetController.sendMessage(toWidget: kBoardWidgetId,
                                             message: message)
            }
        }
    }
    
    // MARK: - AgoraBoardToolConfigViewDelegate
    func didSelectColorHex(_ hex: Int) {
        mainToolsView.curColor = UIColor(hex: subToolsView.currentColor)
        updateImage()
        
        switch currentMainTool {
        case .text:
            updateWidgetText()
        case .paint:
            updateWidgetShape()
        default:
            break
        }
    }
    
    func didSelectTextFont(fontSize: Int) {
        updateImage()
        updateWidgetText()
    }
    
    func didSelectPaintType(_ type: AgoraBoardToolPaintType) {
        currentSubTool = type
    }
    
    func didSelectLineWidth(lineWidth: Int) {
        updateWidgetShape()
    }
}

// MARK: - actions
private extension FcrToolCollectionUIComponent {
    @objc func didSelectMain() {
        curSelectedCell = .main
    }
    
    @objc func didSelectSub() {
        curSelectedCell = .sub
    }
}

// MARK: - private
private extension FcrToolCollectionUIComponent {
    func initCtrlViews() {
        let containAids = (userController.getLocalUserInfo().userRole == .teacher)
        
        mainToolsView = AgoraMainToolsView(containAids: containAids,
                                           delegate: self)
        subToolsView = AgoraBoardToolConfigView(delegate: self)
        mainToolsView.curColor = UIColor(hex: subToolsView.currentColor)
    }
    
    func handleCurrentMainToolChange(oldValue: AgoraBoardToolMainType) {
        var signal: AgoraBoardWidgetSignal?
        
        switch currentMainTool {
        case .clicker, .area, .rubber:
            updateImage()
            
            if oldValue == .paint || oldValue == .text {
                initViewFrame()
                delegate?.toolCollectionCellNeedSpread(false)
            }
            updateWidgetTool()
        case .paint:
            subToolsView.switchType(currentMainTool)
            updateImage()
            if oldValue != .paint,
               oldValue != .text {
                initViewFrame()
                delegate?.toolCollectionCellNeedSpread(true)
            }
            updateWidgetShape()
        case .text:
            subToolsView.switchType(currentMainTool)
            updateImage()
            if oldValue != .paint,
               oldValue != .text {
                initViewFrame()
                delegate?.toolCollectionCellNeedSpread(true)
            }
            updateWidgetText()
        default:
            break
        }
        
        if let boardSignal = signal,
           let message = boardSignal.toMessageString() {
            widgetController.sendMessage(toWidget: kBoardWidgetId,
                                         message: message)
        }
    }
    
    func handleCurrentSubToolChange() {
        updateImage()
        updateWidgetShape()
    }
    
    func setBoardAssistantType() {
        if let boardTool = currentMainTool.widgetType {
            updateWidgetTool()
        } else if currentMainTool == .text {
            updateWidgetText()
        } else if currentMainTool == .paint {
            updateWidgetShape()
        }
    }
    
    func handleBoardWidgetStep(_ changeType: AgoraBoardWidgetStepChangeType) {
        switch changeType {
        case .undoAble(let able):
            mainToolsView.undoEnable = able
        case .redoAble(let able):
            mainToolsView.redoEnable = able
        default:
            break
        }
    }
    
    /* 1. 白板Main选中clicker、area、pencil、text、rubber
     * 2. 白板Main为pencil
     *  2.1 Sub选中颜色
     *  2.2 Sub选中工具
     * 3. 白板Main为text -> Sub选中颜色
     *  3.1 Sub选中颜色
     *  3.2 Sub选中字体大小
    */
    func updateImage() {
        guard let mainSelectedImage = currentMainTool.selectedImage else {
            return
        }

        // 若为text，paint，为选中颜色
        if currentMainTool == .paint ||
            currentMainTool == .text {
            mainCell.setImage(mainSelectedImage,
                              color: UIColor(hex: subToolsView.currentColor))
        } else {
            mainCell.setImage(mainSelectedImage,
                              color: nil)
            
            subCell.isHidden = true
            sepLine.isHidden = true
        }
        
        // 若选中的mainTool为text/paint
        if currentMainTool == .paint {
            subCell.setImage(subToolsView.currentPaintTool.image,
                             color: UIColor(hex: subToolsView.currentColor))
            
            subCell.isHidden = false
            sepLine.isHidden = false
        } else if currentMainTool == .text {
            subCell.setFont(subToolsView.curTextFont.value / 2)
            subCell.isHidden = false
            sepLine.isHidden = false
        }
    }
    
    func updateWidgetTool() {
        if let type = currentMainTool.widgetType,
           let message = AgoraBoardWidgetSignal.ChangeAssistantType(.tool(type)).toMessageString() {
            widgetController.sendMessage(toWidget: kBoardWidgetId,
                                         message: message)
        }
    }
    
    func updateWidgetText() {
        let textInfo = FcrBoardWidgetTextInfo(size: subToolsView.curTextFont.value,
                                              color: subToolsView.currentColor.toColorArr())
        
        if let message = AgoraBoardWidgetSignal.ChangeAssistantType(.text(textInfo)).toMessageString() {
            widgetController.sendMessage(toWidget: kBoardWidgetId,
                                         message: message)
        }
    }
    
    func updateWidgetShape() {
        let shapeInfo = FcrBoardWidgetShapeInfo(type: subToolsView.currentPaintTool.widgetShape,
                                                width: subToolsView.curLineWidth.value,
                                                color: subToolsView.currentColor.toColorArr())
        if let message = AgoraBoardWidgetSignal.ChangeAssistantType(.shape(shapeInfo)).toMessageString() {
            widgetController.sendMessage(toWidget: kBoardWidgetId,
                                         message: message)
        }
    }
}


