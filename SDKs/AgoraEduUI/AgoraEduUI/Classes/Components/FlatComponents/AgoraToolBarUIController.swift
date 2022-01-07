//
//  AgoraToolBarUIController.swift
//  AgoraEduUI
//
//  Created by Jonathan on 2022/1/4.
//

import UIKit
import AgoraExtApp
import AgoraWidget
import AgoraEduContext
import AgoraUIBaseViews
import AgoraUIEduBaseViews
// MARK: - AgoraToolBarRedDotCell
fileprivate class AgoraToolBarRedDotCell: AgoraToolBarItemCell {
    
    var redDot = UIView()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        redDot.isHidden = true
        redDot.isUserInteractionEnabled = false
        redDot.backgroundColor = UIColor(hex: 0xF04C36)
        redDot.layer.cornerRadius = 2
        redDot.clipsToBounds = true
        self.addSubview(redDot)
        redDot.mas_makeConstraints { make in
            make?.width.height().equalTo()(4)
            make?.top.equalTo()(5)
            make?.right.equalTo()(-5)
        }
        
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
// MARK: - AgoraToolBarItemCell
fileprivate class AgoraToolBarItemCell: UICollectionViewCell {
        
    var imageView: UIImageView!
    
    var aSelected = false {
        willSet {
            if aSelected != newValue {
                contentView.backgroundColor = newValue ? UIColor(hex: 0x357BF6) : .white
                imageView.tintColor = newValue ? .white : UIColor(hex: 0x7B88A0)
            }
        }
    }
            
    override init(frame: CGRect) {
        super.init(frame: frame)
        contentView.backgroundColor = UIColor.white
        
        contentView.layer.cornerRadius = 8
        contentView.layer.shadowColor = UIColor(hex: 0x2F4192,
                                                transparency: 0.15)?.cgColor
        contentView.layer.shadowOffset = CGSize(width: 0, height: 2)
        contentView.layer.shadowOpacity = 1
        contentView.layer.shadowRadius = 6
        
        imageView = UIImageView(frame: .zero)
        imageView.tintColor = UIColor(hex: 0x7B88A0)
        contentView.addSubview(imageView)
        
        imageView.mas_remakeConstraints { make in
            make?.center.equalTo()(0)
            make?.width.height().equalTo()(22)
        }
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        contentView.layer.cornerRadius = bounds.height * 0.5
    }
    
    func setImage(_ image: UIImage?) {
        guard let i = image else {
            return
        }
        imageView.image = i.withRenderingMode(.alwaysTemplate)
        imageView.tintColor = UIColor(hex: 0x7B88A0)
    }
    
    func highLight() {
        self.imageView.tintColor = .white
        self.contentView.backgroundColor = UIColor(hex: 0x357BF6)
        self.transform = CGAffineTransform(scaleX: 1.2, y: 1.2)
        self.imageView.transform = CGAffineTransform(scaleX: 0.8, y: 0.8)
    }
    
    func normalState() {
        contentView.backgroundColor = self.aSelected ? UIColor(hex: 0x357BF6) : .white
        imageView.tintColor = self.aSelected ? .white : UIColor(hex: 0x7B88A0)
        UIView.animate(withDuration: 0.1,
                       delay: 0,
                       options: .curveLinear) {
            self.transform = .identity
            self.imageView.transform = .identity
        } completion: { finish in
        }
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
// MARK: - AgoraToolBarBrushCell
fileprivate class AgoraToolBarBrushCell: AgoraToolBarItemCell {
    
    override func highLight() {
        self.transform = CGAffineTransform(scaleX: 1.2, y: 1.2)
        self.imageView.transform = CGAffineTransform(scaleX: 0.8, y: 0.8)
    }
    
    override func normalState() {
        UIView.animate(withDuration: 0.1,
                       delay: 0,
                       options: .curveLinear) {
            self.transform = .identity
            self.imageView.transform = .identity
        } completion: { finish in
        }
    }
}
// MARK: - AgoraToolBarHandsUpCell
fileprivate class AgoraToolBarHandsUpCell: UICollectionViewCell {
    
    var handsupDelayView: AgoraHandsUpDelayView!
            
    override init(frame: CGRect) {
        super.init(frame: frame)
        contentView.backgroundColor = UIColor.clear
        
        handsupDelayView = AgoraHandsUpDelayView(frame: .zero)
        contentView.addSubview(handsupDelayView)
        handsupDelayView.mas_makeConstraints { make in
            make?.left.right().top().bottom().equalTo()(0)
        }
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

// MARK: - Protocol
protocol AgoraToolBarDelegate: NSObject {
    /** 工具被选取*/
    func toolsViewDidSelectTool(tool: AgoraToolBarUIController.ItemType,
                                selectView: UIView)
    /** 工具被取消选取*/
    func toolsViewDidDeselectTool(tool: AgoraToolBarUIController.ItemType)
}
// MARK: - AgoraToolBarUIController
private let kButtonSize: CGFloat = 36.0
private let kGap: CGFloat = 12.0
private let kDefaultTag: Int = 3389
class AgoraToolBarUIController: UIViewController {
    
    weak var delegate: AgoraToolBarDelegate?
    
    public enum ItemType {
        case setting, toolBox, nameRoll, message, handsup, brushTool
        
        func cellImage() -> UIImage? {
            switch self {
            case .setting: return UIImage.agedu_named("ic_func_setting")
            case .toolBox: return UIImage.agedu_named("ic_func_toolbox")
            case .nameRoll: return UIImage.agedu_named("ic_func_name_roll")
            case .message: return UIImage.agedu_named("ic_func_message")
            case .handsup: return UIImage.agedu_named("ic_func_hands_up")
            case .brushTool: return UIImage.agedu_named("ic_brush_pencil")
            default: return nil
            }
        }
    }
    /** 展示的工具*/
    public var tools = [ItemType]()
    
    private var hiddenTools: [ItemType] = [.brushTool]
    
    private var dataSource = [ItemType]()
        
    private var collectionView: UICollectionView!
    
    private var handsupCell: AgoraToolBarHandsUpCell?
    /** SDK环境*/
    private var contextPool: AgoraEduContextPool!
    /** 画笔图片*/
    private var brushImage: UIImage?
    /** 画笔颜色*/
    private var brushColor = UIColor(hex: 0xE1E1EA)
    /** 消息提醒*/
    private var messageRemind = false
    /** 举手提示浮层*/
    private lazy var hansupTipsView: AgoraHandsupTipsView = {
        let v = AgoraHandsupTipsView()
        v.isHidden = true
        view.addSubview(v)
        if let index = self.dataSource.firstIndex(of: .handsup) {
            let cell = self.collectionView.cellForItem(at: IndexPath(row: index,
                                                                     section: 0))
            v.mas_makeConstraints { make in
                make?.right.equalTo()(self.view.mas_left)?.offset()(-5)
                make?.centerY.equalTo()(cell)
            }
        }
        return v
    }()
    /** 已被选中的工具*/
    private var selectedTool: ItemType? {
        didSet {
            if let oldTool = oldValue {
                self.delegate?.toolsViewDidDeselectTool(tool: oldTool)
            }
        }
    }
    
    init(context: AgoraEduContextPool) {
        super.init(nibName: nil, bundle: nil)
        contextPool = context
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.createViews()
        self.createConstrains()
        self.updateDataSource()
        
        contextPool.widget.add(self,
                               widgetId: "netlessBoard")
    }
    
    public func deselectAll() {
        guard selectedTool != nil else {
            return
        }
        selectedTool = nil
        collectionView.reloadData()
    }
    
    public func updateChatRedDot(isShow: Bool) {
        guard messageRemind != isShow else {
            return
        }
        messageRemind = isShow
        self.collectionView.reloadData()
    }
    
    public func updateBrushButton(image: UIImage?,
                                  colorHex: Int) {
        self.brushImage = image
        if colorHex == 0xFFFFFF {
            self.brushColor = UIColor(hex: 0xE1E1EA)
        } else {
            self.brushColor = UIColor(hex: colorHex)
        }
        self.collectionView.reloadData()
    }
}
// MARK: - Private
private extension AgoraToolBarUIController {
    func updateDataSource() {
        var temp = self.tools
        self.dataSource = temp.removeAll(self.hiddenTools)
        let count = CGFloat(self.dataSource.count)
        collectionView.mas_remakeConstraints { make in
            make?.left.right().top().bottom().equalTo()(0)
            make?.width.equalTo()(kButtonSize)
            make?.height.equalTo()((kButtonSize + kGap) * count - kGap)
        }
        self.collectionView.reloadData()
    }
}
// MARK: - Student Hands Up
extension AgoraToolBarUIController: AgoraHandsUpDelayViewDelegate {
    func onHandsUpViewDidChangeState(_ state: AgoraHandsUpDelayView.ViewState) {
        switch state {
        case .hold:
            mayShowTips()
            contextPool.user.handsWave(duration: 3) {
                
            } failure: { error in
                
            }
            break
        case .free: break
        case .counting: break
        default: break
        }
    }
    
    func mayShowTips() {
        guard self.hansupTipsView.isHidden == true else {
            return
        }
        self.hansupTipsView.isHidden = false
        self.hansupTipsView.alpha = 1
        self.perform(#selector(hideTipsAnimated), with: nil, afterDelay: 2)
    }
    
    @objc func hideTipsAnimated() {
        UIView.animate(withDuration: 0.3) {
            self.hansupTipsView.alpha = 0
        }
    }
}
extension AgoraToolBarUIController: AgoraWidgetMessageObserver {
    func onMessageReceived(_ message: String,
                           widgetId: String) {
        guard widgetId == "netlessBoard",
              let signal = message.toSignal() else {
            return
        }
        switch signal {
        case .BoardGrantDataChanged(let list):
            if let users = list,
               users.contains(contextPool.user.getLocalUserInfo().userUuid) {
                self.hiddenTools.removeAll(.brushTool)
            } else {
                if self.hiddenTools.contains(where: {$0 == .brushTool}) == false {
                    self.hiddenTools.append(.brushTool)
                }
            }
            self.updateDataSource()
        default:
            break
        }
    }
}
// MARK: - UICollectionViewDataSource
extension AgoraToolBarUIController: UICollectionViewDelegate,
                                    UICollectionViewDataSource,
                                    UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView,
                        numberOfItemsInSection section: Int) -> Int {
        return self.dataSource.count
    }
    
    func collectionView(_ collectionView: UICollectionView,
                        cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let tool = dataSource[indexPath.row]
        if tool == .message {
            let cell = collectionView.dequeueReusableCell(withClass: AgoraToolBarRedDotCell.self,
                                                          for: indexPath)
            cell.setImage(tool.cellImage())
            cell.aSelected = (selectedTool == tool)
            cell.redDot.isHidden = !messageRemind
            return cell
        } else if tool == .handsup {
            let cell = handsupCell ?? collectionView.dequeueReusableCell(withClass: AgoraToolBarHandsUpCell.self,
                                                                         for: indexPath)
            if handsupCell == nil {
                handsupCell = cell
                handsupCell?.handsupDelayView.delegate = self
            }
            return cell
        } else if tool == .brushTool {
            let cell = collectionView.dequeueReusableCell(withClass: AgoraToolBarBrushCell.self,
                                                          for: indexPath)
            cell.aSelected = false
            cell.setImage(brushImage)
            cell.imageView.tintColor = self.brushColor
            return cell
        } else {
            let cell = collectionView.dequeueReusableCell(withClass: AgoraToolBarItemCell.self,
                                                          for: indexPath)
            cell.setImage(tool.cellImage())
            cell.aSelected = (selectedTool == tool)
            return cell
        }
    }
    
    func collectionView(_ collectionView: UICollectionView,
                        didSelectItemAt indexPath: IndexPath) {
        collectionView.deselectItem(at: indexPath,
                                    animated: false)
        let tool = dataSource[indexPath.row]
        if selectedTool == tool {
            selectedTool = nil
        } else {
            selectedTool = tool
            if let cell = collectionView.cellForItem(at: indexPath) {
                self.delegate?.toolsViewDidSelectTool(tool: tool,
                                                      selectView: cell)
            }
        }
        collectionView.reloadData()
    }
    
    func collectionView(_ collectionView: UICollectionView,
                        shouldSelectItemAt indexPath: IndexPath) -> Bool {
        let tool = dataSource[indexPath.row]
        if tool == .handsup {
            return false
        } else {
            return true
        }
    }
    
    func collectionView(_ collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                        sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: kButtonSize,
                      height: kButtonSize)
    }
    
    func collectionView(_ collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                        minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return kGap
    }
    
    func collectionView(_ collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                        minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return kGap
    }
    
    func collectionView(_ collectionView: UICollectionView,
                        didHighlightItemAt indexPath: IndexPath) {
        let cell = collectionView.cellForItem(at: indexPath) as? AgoraToolBarItemCell
        cell?.highLight()
    }
    
    func collectionView(_ collectionView: UICollectionView,
                        didUnhighlightItemAt indexPath: IndexPath) {
        let cell = collectionView.cellForItem(at: indexPath) as? AgoraToolBarItemCell
        cell?.normalState()
    }
    
    func collectionView(_ collectionView: UICollectionView,
                        shouldHighlightItemAt indexPath: IndexPath) -> Bool {
        let tool = dataSource[indexPath.row]
        if tool == .handsup {
            return false
        } else {
            return true
        }
    }
}

// MARK: - Creations
private extension AgoraToolBarUIController {
    func createViews() {
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .vertical
        collectionView = UICollectionView(frame: .zero,
                                          collectionViewLayout: layout)
        collectionView.delegate = self
        collectionView.dataSource = self
        collectionView.isScrollEnabled = false
        collectionView.backgroundColor = .clear
        collectionView.allowsMultipleSelection = false
        collectionView.showsVerticalScrollIndicator = false
        collectionView.bounces = false
        collectionView.clipsToBounds = false
        collectionView.register(cellWithClass: AgoraToolBarItemCell.self)
        collectionView.register(cellWithClass: AgoraToolBarHandsUpCell.self)
        collectionView.register(cellWithClass: AgoraToolBarRedDotCell.self)
        collectionView.register(cellWithClass: AgoraToolBarBrushCell.self)
        view.addSubview(collectionView)
    }
    
    func createConstrains() {
        collectionView.mas_remakeConstraints { make in
            make?.left.right().top().bottom().equalTo()(0)
            make?.width.equalTo()(kButtonSize)
            make?.height.equalTo()((kButtonSize + kGap) * 5 - kGap)
        }
    }
}
