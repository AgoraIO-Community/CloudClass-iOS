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

protocol AgoraToolCollectionUIControllerDelegate: NSObjectProtocol {
    func toolCollectionDidSelectCell(view: UIView)
    func toolCollectionCellNeedSpread(_ spread: Bool)
    func toolCollectionDidDeselectCell()
    func toolCollectionDidSelectTeachingAid(type: AgoraTeachingAidType)
}

fileprivate enum AgoraToolCollectionSelectType: Int {
    case none, main, sub
}

class AgoraToolCollectionUIController: UIViewController {
    /// Data
    private weak var delegate: AgoraToolCollectionUIControllerDelegate?
    
    var suggestLength: CGFloat = UIDevice.current.isPad ? 34 : 32
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
    private var contentView: UIView!
    private var subCell: AgoraToolCollectionCell!
    private var sepLine: UIView!
    private var mainCell: AgoraToolCollectionCell!
    
    // 主要工具栏CollectionView（包含教具、白板工具）
    private var mainToolsView: AgoraMainToolsView!
    // 白板工具配置CollectionView
    private var subToolsView: AgoraBoardToolConfigView!
    
    let color = AgoraColorGroup()
    
    /** SDK环境*/
    var contextPool: AgoraEduContextPool!
    
    deinit {
        print("\(#function): \(self.classForCoder)")
    }

    init(context: AgoraEduContextPool,
         delegate: AgoraToolCollectionUIControllerDelegate) {
        super.init(nibName: nil, bundle: nil)
        contextPool = context
        contextPool.widget.add(self,
                               widgetId: kBoardWidgetId)
        self.delegate = delegate

        
        initCtrlViews()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
        
    override func viewDidLoad() {
        super.viewDidLoad()
        
        createViews()
        createConstraint()
    }
}

// MARK: - Widget
extension AgoraToolCollectionUIController: AgoraWidgetActivityObserver,
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
        case .MemberStateChanged(let state):
            handleBoardWidgetMemberState(state)
        case .BoardGrantDataChanged(let list):
            handleBoardWidgetGrantUsers(list)
        case .BoardStepChanged(let changeType):
            handleBoardWidgetStep(changeType)
        default:
            break
        }
    }
}

// MARK: - UI Delegate
extension AgoraToolCollectionUIController: AgoraMainToolsViewDelegate,
                                           AgoraBoardToolConfigViewDelegate {
    // MARK: - AgoraMainToolsViewDelegate
    func didSelectTeachingAid(type: AgoraTeachingAidType) {
        delegate?.toolCollectionDidSelectTeachingAid(type: type)
    }
    
    func didSelectBoardTool(type: AgoraBoardToolMainType) {
        currentMainTool = type
    }
    
    // MARK: - AgoraBoardToolConfigViewDelegate
    func didSelectColorHex(_ hex: Int) {
        mainToolsView.curColor = UIColor(hex: subToolsView.currentColor)
        updateImage()
        let colorArr = UIColor(hex: hex)?.getRGBAArr()
        if let message = AgoraBoardWidgetSignal.MemberStateChanged(AgoraBoardWidgetMemberState(strokeColor: colorArr)).toMessageString() {
            contextPool.widget.sendMessage(toWidget: kBoardWidgetId,
                                           message: message)
        }
    }
    
    func didSelectTextFont(fontSize: Int) {
        updateImage()
        if let message = AgoraBoardWidgetSignal.MemberStateChanged(AgoraBoardWidgetMemberState(textSize: fontSize)).toMessageString() {
            contextPool.widget.sendMessage(toWidget: kBoardWidgetId,
                                           message: message)
        }
    }
    
    func didSelectPaintType(_ type: AgoraBoardToolPaintType) {
        currentSubTool = type
    }
    
    func didSelectLineWidth(lineWidth: Int) {
        if let message = AgoraBoardWidgetSignal.MemberStateChanged(AgoraBoardWidgetMemberState(strokeWidth: lineWidth)).toMessageString() {
            contextPool.widget.sendMessage(toWidget: kBoardWidgetId,
                                           message: message)
        }
    }
}

// MARK: - actions
private extension AgoraToolCollectionUIController {
    @objc func didSelectMain() {
        curSelectedCell = .main
    }
    
    @objc func didSelectSub() {
        curSelectedCell = .sub
    }
}

// MARK: - UI
private extension AgoraToolCollectionUIController {
    func initCtrlViews() {
        mainToolsView = AgoraMainToolsView(containAids: contextPool.user.getLocalUserInfo().userRole == .teacher,
                                           delegate: self)
        subToolsView = AgoraBoardToolConfigView(delegate: self)
        mainToolsView.curColor = UIColor(hex: subToolsView.currentColor)
    }
    
    func createViews() {
        view.backgroundColor = .clear
        
        contentView = UIView(frame: .zero)
        contentView.backgroundColor = UIColor.white
        
        contentView.layer.cornerRadius = 16
        contentView.layer.shadowColor = UIColor(hex: 0x2F4192,
                                         transparency: 0.15)?.cgColor
        contentView.layer.shadowOffset = CGSize(width: 0, height: 2)
        contentView.layer.shadowOpacity = 1
        contentView.layer.shadowRadius = 6
        
        view.addSubview(contentView)
        
        mainCell = AgoraToolCollectionCell(isMain: true,
                                           color: UIColor(hex: subToolsView.currentColor) ?? color.common_base_tint_color,
                                           image: currentMainTool.image)
        mainCell.addGestureRecognizer(UITapGestureRecognizer(target: self,
                                                                  action: #selector(didSelectMain)))
        contentView.addSubview(mainCell)
        
        sepLine = UIView()
        sepLine.backgroundColor = UIColor(hex: 0xD2D2E2)
        contentView.addSubview(sepLine)
        
        subCell = AgoraToolCollectionCell(isMain: false,
                                          color: UIColor(hex: subToolsView.currentColor) ?? UIColor(hex: 0x357BF6),
                                          image: currentSubTool.image,
                                          font: subToolsView.curTextFont.value / 2)
        
        subCell.addGestureRecognizer(UITapGestureRecognizer(target: self,
                                                                  action: #selector(didSelectSub)))
        contentView.addSubview(subCell)
        
        updateImage()
    }
    
    func createConstraint() {
        if currentMainTool == .paint ||
            currentMainTool == .text {
            contentView.mas_remakeConstraints { make in
                make?.left.right().top().bottom().equalTo()(0)
            }
            subCell.mas_remakeConstraints { make in
                make?.top.equalTo()(0)
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
                make?.bottom.equalTo()(0)
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
    
    func handleCurrentMainToolChange(oldValue: AgoraBoardToolMainType) {
        var signal: AgoraBoardWidgetSignal?
        
        switch currentMainTool {
        case .clicker, .area, .rubber:
            updateImage()
            
            if oldValue == .paint || oldValue == .text {
                createConstraint()
                delegate?.toolCollectionCellNeedSpread(false)
            }
            if let type = currentMainTool.boardWidgetToolType {
                signal = AgoraBoardWidgetSignal.MemberStateChanged(AgoraBoardWidgetMemberState(activeApplianceType: type))
            }
        case .paint:
            subToolsView.switchType(currentMainTool)
            updateImage()
            if oldValue != .paint,
               oldValue != .text {
                createConstraint()
                delegate?.toolCollectionCellNeedSpread(true)
            }
            if let shape = currentSubTool.boardWidgetShapeType {
                signal = AgoraBoardWidgetSignal.MemberStateChanged(AgoraBoardWidgetMemberState(activeApplianceType: .Shape,
                                                                                               shapeType: shape))
            }else if let tool = currentSubTool.boardWidgetToolType {
                signal = AgoraBoardWidgetSignal.MemberStateChanged(AgoraBoardWidgetMemberState(activeApplianceType: tool))
            }
        case .text:
            subToolsView.switchType(currentMainTool)
            updateImage()
            if oldValue != .paint,
               oldValue != .text {
                createConstraint()
                delegate?.toolCollectionCellNeedSpread(true)
            }
            if let type = currentMainTool.boardWidgetToolType {
                signal = AgoraBoardWidgetSignal.MemberStateChanged(AgoraBoardWidgetMemberState(activeApplianceType: type))
            }
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
            contextPool.widget.sendMessage(toWidget: kBoardWidgetId,
                                           message: message)
        }
    }
    
    func handleCurrentSubToolChange() {
        updateImage()
        if let shape = currentSubTool.boardWidgetShapeType,
           let message = AgoraBoardWidgetSignal.MemberStateChanged(AgoraBoardWidgetMemberState(activeApplianceType: .Shape,
                                                                                               shapeType: shape)).toMessageString() {
            contextPool.widget.sendMessage(toWidget: kBoardWidgetId,
                                           message: message)
        }
        
        if let tool = currentSubTool.boardWidgetToolType,
           let message = AgoraBoardWidgetSignal.MemberStateChanged(AgoraBoardWidgetMemberState(activeApplianceType: tool)).toMessageString() {
            contextPool.widget.sendMessage(toWidget: kBoardWidgetId,
                                           message: message)
        }
    }
    
    func handleBoardWidgetMemberState(_ state: AgoraBoardWidgetMemberState) {
        if let main = state.activeApplianceType?.toMainType() {
            mainToolsView.curBoardTool = main
            if main == .paint {
                if let sub = state.shapeType?.toPaintType() {
                    subToolsView.currentPaintTool = sub
                }
                if let sub = state.activeApplianceType?.toPaintType() {
                    subToolsView.currentPaintTool = sub
                }
            }
        }
        if let width = state.strokeWidth {
            subToolsView.curLineWidth = AgoraBoardToolsLineWidth.fromValue(width)
        }
        if let strokeColor = state.strokeColor {
            subToolsView.currentColor = strokeColor.toColorHex()
        }
        if let font = state.textSize {
            subToolsView.curTextFont = AgoraBoardToolsFont.fromValue(font)
        }
        
        updateImage()
        createConstraint()
    }
    
    func handleBoardWidgetGrantUsers(_ list: [String]?) {
        guard contextPool.user.getLocalUserInfo().userRole == .student else {
            return
        }
        if let users = list  {
            view.isHidden = !users.contains(contextPool.user.getLocalUserInfo().userUuid)
        } else {
            view.isHidden = true
        }
    }
    
    func handleBoardWidgetStep(_ changeType: AgoraBoardWidgetStepChangeType) {
        switch changeType {
        case .undoCount(let count):
            mainToolsView.undoEnable = (count > 0)
        case .redoCount(let count):
            mainToolsView.redoEnable = (count > 0)
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
                              color: color.common_base_tint_color)
            
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
}


