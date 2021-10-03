//
//  BrushToolsViewController.swift
//  AgoraEduUI
//
//  Created by HeZhengQing on 2021/9/23.
//

import UIKit
import AgoraEduContext

enum BrushToolItem {
    case arrow, area, text, rubber, laser, pencil, line, rect, cycle
}

private enum BrushToolsViewState {
    case toolsOnly
    case sizeExtension
    case colorExtension
}

protocol BrushToolsViewControllerDelegate: class {
    func didSelectBrushTool()
}

private let kBrushSizeCount: Int = 5
private let kTextSizeCount: Int = 4
class BrushToolsViewController: UIViewController {
    
    weak var delegate: BrushToolsViewControllerDelegate?
    
    var contentView: UIView!
    
    var toolsCollectionView: UICollectionView!
    
    var topLine: UIView!
        
    var sizeCollectionView: UICollectionView!
    
    var bottomLine: UIView!
    
    var colorCollectionView: UICollectionView!
    /** SDK环境*/
    var contextPool: AgoraEduContextPool!
        
    let colors = [
        UIColor.white, UIColor(rgb: 0x9B9B9B), UIColor(rgb: 0x4A4A4A),
        UIColor.black, UIColor(rgb: 0xD0021B), UIColor(rgb: 0xF5A623),
        UIColor(rgb: 0xF8E71C), UIColor(rgb: 0x7ED321), UIColor(rgb: 0x9013FE),
        UIColor(rgb: 0x50E3C2), UIColor(rgb: 0x0073FF), UIColor(rgb: 0xFFC8E2)
    ]
    
    let tools: [BrushToolItem] = [.arrow, .area, .text, .rubber, .laser, .pencil, .line, .rect, .cycle]
    
    var selectedTool: BrushToolItem = .arrow
    
    private var viewState: BrushToolsViewState = .toolsOnly {
        didSet {
            if viewState != oldValue {
                switch viewState {
                case .toolsOnly:
                    contentView.snp.remakeConstraints { make in
                        make.width.equalTo(280)
                        make.height.equalTo(136)
                        make.top.bottom.left.right.equalToSuperview()
                    }
                case .sizeExtension:
                    contentView.snp.remakeConstraints { make in
                        make.width.equalTo(280)
                        make.height.equalTo(197)
                        make.top.bottom.left.right.equalToSuperview()
                    }
                case .colorExtension:
                    contentView.snp.remakeConstraints { make in
                        make.width.equalTo(280)
                        make.height.equalTo(310)
                        make.top.bottom.left.right.equalToSuperview()
                    }
                }
            }
        }
    }
    
    var colorIndex: IndexPath?
        
    deinit {
        print("\(#function): \(self.classForCoder)")
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
        view.backgroundColor = .clear
        
        createViews()
        createConstrains()
    }
}
// MARK: - UICollectionViewDelegate
extension BrushToolsViewController: UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if collectionView == toolsCollectionView {
            return tools.count
        } else if collectionView == sizeCollectionView {
            if selectedTool == .text {
                return kTextSizeCount
            } else if selectedTool == .pencil {
                return kBrushSizeCount
            } else {
                return 0
            }
        } else if collectionView == colorCollectionView {
            return colors.count
        } else {
            return 0
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        if collectionView == toolsCollectionView {
            let cell = collectionView.dequeueReusableCell(withClass: BrushToolItemCell.self, for: indexPath)
            let tool = tools[indexPath.row]
            var image: UIImage?
            switch tool {
            case .arrow:
                image = AgoraUIImage(object: self, name: "ic_brush_arrow")?.withRenderingMode(.alwaysTemplate)
            case .area:
                image = AgoraUIImage(object: self, name: "ic_brush_area")?.withRenderingMode(.alwaysTemplate)
            case .text:
                image = AgoraUIImage(object: self, name: "ic_brush_text")?.withRenderingMode(.alwaysTemplate)
            case .rubber:
                image = AgoraUIImage(object: self, name: "ic_brush_rubber")?.withRenderingMode(.alwaysTemplate)
            case .laser:
                image = AgoraUIImage(object: self, name: "ic_brush_laser")?.withRenderingMode(.alwaysTemplate)
            case .pencil:
                image = AgoraUIImage(object: self, name: "ic_brush_pencil")?.withRenderingMode(.alwaysTemplate)
            case .line:
                image = AgoraUIImage(object: self, name: "ic_brush_line")?.withRenderingMode(.alwaysTemplate)
            case .rect:
                image = AgoraUIImage(object: self, name: "ic_brush_rect")?.withRenderingMode(.alwaysTemplate)
            case .cycle:
                image = AgoraUIImage(object: self, name: "ic_brush_cycle")?.withRenderingMode(.alwaysTemplate)
            default:
                image = AgoraUIImage(object: self, name: "ic_brush_arrow")?.withRenderingMode(.alwaysTemplate)
            }
            cell.imageView.image = image
            cell.aSelected = (tool == selectedTool)
            return cell
        } else if collectionView == sizeCollectionView {
            if selectedTool == .text {
                let cell = collectionView.dequeueReusableCell(withClass: BrushTextSizeItemCell.self, for: indexPath)
                return cell
            } else if selectedTool == .pencil {
                let cell = collectionView.dequeueReusableCell(withClass: BrushSizeItemCell.self, for: indexPath)
                
                return cell
            } else {
                let cell = collectionView.dequeueReusableCell(withReuseIdentifier: NSStringFromClass(BrushSizeItemCell.self), for: indexPath) as! BrushSizeItemCell
                return cell
            }
        } else if collectionView == colorCollectionView {
            let cell = collectionView.dequeueReusableCell(withClass: BrushColorItemCell.self, for: indexPath)
            cell.color = colors[indexPath.row]
            cell.aSelected = (indexPath == colorIndex)
            return cell
        } else {
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: NSStringFromClass(BrushColorItemCell.self), for: indexPath)
            return cell
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        collectionView.deselectItem(at: indexPath, animated: false)
        if collectionView == toolsCollectionView {
            let tool = tools[indexPath.row]
            if selectedTool != tool {
                selectedTool = tool
                collectionView.reloadData()
                if tool == .text || tool == .pencil {
                    viewState = .colorExtension
                } else {
                    viewState = .toolsOnly
                    sizeCollectionView.reloadData()
                }
            }
        } else if collectionView == sizeCollectionView {
            // Do Noting
            sizeCollectionView.reloadData()
        } else if collectionView == colorCollectionView {
            if colorIndex != indexPath {
                colorIndex = indexPath
                collectionView.reloadData()
            }
        } else {
            // Do Noting
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        if collectionView == toolsCollectionView {
            return CGSize(width: 56, height: 56)
        } else if collectionView == sizeCollectionView {
            if selectedTool == .text {
                return CGSize(width: collectionView.bounds.width / CGFloat(kTextSizeCount),
                              height: collectionView.bounds.height)
            } else if selectedTool == .pencil {
                return CGSize(width: collectionView.bounds.width / CGFloat(kBrushSizeCount),
                              height: collectionView.bounds.height)
            } else {
                return .zero
            }
        } else if collectionView == colorCollectionView {
            return CGSize(width: 32, height: 32)
        } else {
            return CGSize(width: 0, height: 0)
        }
    }

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        if collectionView == toolsCollectionView {
            return UIEdgeInsets(top: 12, left: 8, bottom: 0, right: 8)
        } else if collectionView == sizeCollectionView {
            return .zero
        } else if collectionView == colorCollectionView {
            return UIEdgeInsets(top: 12, left: 10, bottom: 0, right: 10)
        } else {
            return .zero
        }
    }
}
// MARK: - Creations
private extension BrushToolsViewController {
    func createViews() {
        view.layer.shadowColor = UIColor(rgb: 0x2F4192, alpha: 0.15).cgColor
        view.layer.shadowOffset = CGSize(width: 0, height: 2)
        view.layer.shadowOpacity = 1
        view.layer.shadowRadius = 6
        
        contentView = UIView(frame: .zero)
        contentView.backgroundColor = .white
        contentView.layer.cornerRadius = 10.0
        contentView.clipsToBounds = true
        view.addSubview(contentView)
        
        let toolsLayout = UICollectionViewFlowLayout()
        toolsLayout.scrollDirection = .vertical
        toolsCollectionView = UICollectionView(frame: .zero,
                                               collectionViewLayout: toolsLayout)
        toolsCollectionView.showsHorizontalScrollIndicator = false
        toolsCollectionView.backgroundColor = .white
        toolsCollectionView.bounces = false
        toolsCollectionView.delegate = self
        toolsCollectionView.dataSource = self
        toolsCollectionView.register(cellWithClass: BrushToolItemCell.self)
        contentView.addSubview(toolsCollectionView)
        
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .vertical
        sizeCollectionView = UICollectionView(frame: .zero,
                                          collectionViewLayout: layout)
        sizeCollectionView.showsHorizontalScrollIndicator = false
        sizeCollectionView.backgroundColor = .white
        sizeCollectionView.bounces = false
        sizeCollectionView.delegate = self
        sizeCollectionView.dataSource = self
        sizeCollectionView.register(cellWithClass: BrushTextSizeItemCell.self)
        sizeCollectionView.register(cellWithClass: BrushSizeItemCell.self)
        contentView.addSubview(sizeCollectionView)
        
        let colorlayout = UICollectionViewFlowLayout()
        colorlayout.scrollDirection = .vertical
        colorCollectionView = UICollectionView(frame: .zero,
                                               collectionViewLayout: layout)
        colorCollectionView.showsHorizontalScrollIndicator = false
        colorCollectionView.backgroundColor = .white
        colorCollectionView.bounces = false
        colorCollectionView.delegate = self
        colorCollectionView.dataSource = self
        colorCollectionView.register(cellWithClass: BrushColorItemCell.self)
        contentView.addSubview(colorCollectionView)
        
        topLine = UIView(frame: .zero)
        topLine.backgroundColor = UIColor(rgb: 0xECECF1)
        contentView.addSubview(topLine)
        
        bottomLine = UIView(frame: .zero)
        bottomLine.backgroundColor = UIColor(rgb: 0xECECF1)
        contentView.addSubview(bottomLine)
    }
    
    func createConstrains() {
        contentView.snp.makeConstraints { make in
            make.width.equalTo(280)
            make.height.equalTo(136)
            make.top.bottom.left.right.equalToSuperview()
        }
        toolsCollectionView.snp.makeConstraints { make in
            make.left.right.top.equalToSuperview()
            make.height.equalTo(136)
        }
        topLine.snp.makeConstraints { make in
            make.left.equalTo(16)
            make.right.equalTo(-16)
            make.height.equalTo(1)
            make.top.equalTo(toolsCollectionView.snp.bottom)
        }
        sizeCollectionView.snp.makeConstraints { make in
            make.left.right.equalToSuperview()
            make.top.equalTo(topLine)
            make.height.equalTo(60)
        }
        bottomLine.snp.makeConstraints { make in
            make.left.equalTo(16)
            make.right.equalTo(-16)
            make.height.equalTo(1)
            make.top.equalTo(sizeCollectionView.snp.bottom)
        }
        colorCollectionView.snp.makeConstraints { make in
            make.left.right.equalToSuperview()
            make.top.equalTo(bottomLine)
            make.height.equalTo(112)
        }
    }
}
