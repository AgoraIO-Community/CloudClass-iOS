//
//  AgoraToolBarCells.swift
//  AgoraEduUI
//
//  Created by LYY on 2022/2/10.
//

import AgoraUIBaseViews
import UIKit

// MARK: - AgoraToolBarRedDotCell
class AgoraToolBarRedDotCell: AgoraToolBarItemCell {
    var redDot = UIView()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        redDot.isHidden = true
        redDot.isUserInteractionEnabled = false
        
        redDot.layer.cornerRadius = 2
        redDot.clipsToBounds = true
        self.addSubview(redDot)
        
        redDot.mas_makeConstraints { make in
            make?.width.height().equalTo()(4)
            make?.top.equalTo()(5)
            make?.right.equalTo()(-5)
        }
    }
    
    override func updateViewProperties() {
        super.updateViewProperties()
        
        redDot.backgroundColor = UIConfig.toolBar.message.dotColor
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
// MARK: - AgoraToolBarItemCell
class AgoraToolBarItemCell: UICollectionViewCell, AgoraUIContentContainer {
    private lazy var bgView = UIImageView(frame: .zero)
    lazy var iconView = UIImageView(frame: .zero)

    var aSelected = false {
        didSet {
            let config = UIConfig.toolBar.cell
            let image = aSelected ? config.normalImage?.withRenderingMode(.alwaysTemplate) : config.normalImage
            bgView.image = image
        }
    }
            
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        initViews()
        initViewFrame()
        updateViewProperties()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func initViews() {
        contentView.addSubview(bgView)
        contentView.addSubview(iconView)
    }
    
    func initViewFrame() {
        bgView.mas_makeConstraints { make in
            make?.center.width().height().equalTo()(contentView)
        }
        iconView.mas_makeConstraints { make in
            make?.center.equalTo()(0)
            make?.width.height().equalTo()(22)
        }
    }
    
    func updateViewProperties() {
        let config = UIConfig.toolBar.cell
        contentView.layer.cornerRadius = config.cornerRadius
        
        contentView.layer.shadowColor = config.shadow.color
        contentView.layer.shadowOffset = config.shadow.offset
        contentView.layer.shadowOpacity = config.shadow.opacity
        contentView.layer.shadowRadius = config.shadow.radius
        
        bgView.image = config.normalImage
        bgView.tintColor = config.selectedColor
    }
    
    func highLight() {
        self.transform = CGAffineTransform(scaleX: 1.2,
                                           y: 1.2)
        self.iconView.transform = CGAffineTransform(scaleX: 0.8,
                                                     y: 0.8)
    }
    
    func normalState() {
        UIView.animate(withDuration: 0.1,
                       delay: 0,
                       options: .curveLinear) {
            self.transform = .identity
            self.iconView.transform = .identity
        } completion: { finish in
        }
    }
}

// MARK: - FcrToolBarWaveHandsCell
protocol FcrToolBarWaveHandsCellDelegate: NSObjectProtocol {
    func onHandsUpViewDidChangeState(_ state: FcrToolBarWaveHandsCell.ViewState)
}
class FcrToolBarWaveHandsCell: AgoraToolBarItemCell {
    
    enum ViewState {
        case free, hold, counting
    }
    
    weak var delegate: FcrToolBarWaveHandsCellDelegate?
    
    private let backgroudView = UIView()
        
    private let delayLabel = UILabel()
    
    public var duration = 3 {
        didSet {
            self.count = duration
        }
    }
    
    private var state: ViewState = .free {
        didSet {
            guard state != oldValue else {
                return
            }
            delegate?.onHandsUpViewDidChangeState(state)
        }
    }
    
    private var timer: Timer?
    
    private var count = 3
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesBegan(touches, with: event)
        guard state == .free else {
            return
        }
        backgroudView.isHidden = false
        delayLabel.isHidden = false
        delayLabel.text = "\(count)"
        aSelected = true
        highLight()
        
        stopTimer()
        state = .hold
    }
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesEnded(touches, with: event)
        didTouchFinish()
    }
    
    override func touchesCancelled(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesEnded(touches, with: event)
        didTouchFinish()
    }
    
    func didTouchFinish() {
        guard state == .hold else {
            return
        }
        normalState()
        
        state = .counting
        timer = Timer.scheduledTimer(withTimeInterval: 1,
                                     repeats: true,
                                     block: { [weak self] _ in
            self?.countDown()
        })
    }
    
    private func countDown() {
        if count > 1 {
            count -= 1
            delayLabel.text = "\(count)"
        } else {
            stopTimer()
        }
    }
    
    private func stopTimer() {
        guard timer != nil else {
            return
        }
        timer?.invalidate()
        timer = nil
        count = self.duration
        delayLabel.isHidden = true
        backgroudView.isHidden = true
        aSelected = false
        state = .free
    }
    
    
    override func initViews() {
        super.initViews()
        backgroudView.isHidden = true
        contentView.addSubview(backgroudView)
        
        delayLabel.textAlignment = .center
        contentView.addSubview(delayLabel)
    }
    
    override func initViewFrame() {
        super.initViewFrame()
        backgroudView.mas_makeConstraints { make in
            make?.left.right().top().bottom().equalTo()(iconView)
        }
        delayLabel.mas_makeConstraints { make in
            make?.center.equalTo()(0)
        }
    }
    
    override func updateViewProperties() {
        super.updateViewProperties()
        backgroudView.backgroundColor = UIConfig.toolBar.cell.selectedColor
        
        delayLabel.textColor = UIConfig.raiseHand.textColor
        delayLabel.font = UIConfig.raiseHand.font
    }
}

// MARK: - AgoraToolBarHandsListCell
class AgoraToolBarHandsListCell: AgoraToolBarItemCell {
    
    lazy var redLabel = UILabel()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        initViews()
        initViewFrame()
        updateViewProperties()
    }
    
    override func initViews() {
        super.initViews()
        redLabel.textAlignment = .center
        redLabel.isHidden = true
        redLabel.isUserInteractionEnabled = false
        
        redLabel.clipsToBounds = true
        
        self.addSubview(redLabel)
    }
    
    override func initViewFrame() {
        super.initViewFrame()
        redLabel.mas_makeConstraints { make in
            make?.width.height().equalTo()(4)
            make?.top.equalTo()(5)
            make?.right.equalTo()(-5)
        }
    }
    
    override func updateViewProperties() {
        super.updateViewProperties()
        
        let config = UIConfig.toolBar.handsList.label
        
        redLabel.textColor = config.color
        redLabel.font = config.font
        redLabel.backgroundColor = config.backgroundColor
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

// MARK: - AgoraToolCollectionCell
class AgoraToolCollectionCell: UIView {
    private var isMain: Bool
    private var imageView: UIImageView!
    private lazy var colorView: UIView = UIView(frame: .zero)
    
    private lazy var fontLabel: UILabel = {
        let fontLabel = UILabel(text: "")
        fontLabel.font = .systemFont(ofSize: 12)
        fontLabel.textAlignment = .center
        fontLabel.textColor = UIColor(hex: 0x677386)
        return fontLabel
    }()
    
    var curColor: UIColor = .white
    
    init(isMain: Bool,
         color: UIColor? = nil,
         image: UIImage? = nil,
         font: Int? = nil) {
        self.isMain = isMain
        
        super.init(frame: .zero)
        
        backgroundColor = .clear
        
        imageView = UIImageView(frame: .zero)
        imageView.contentMode = .scaleAspectFill
        imageView.image = image
        imageView.tintColor = color
        addSubview(imageView)
        
        imageView.mas_remakeConstraints { make in
            make?.center.equalTo()(0)
            make?.width.height().equalTo()(22)
        }
        
        if !isMain {
            addSubview(colorView)
            addSubview(fontLabel)
            
            fontLabel.text = "\(font)"
            colorView.backgroundColor = color
            
            colorView.mas_remakeConstraints { make in
                make?.width.height().equalTo()(AgoraFit.scale(3))
                make?.bottom.equalTo()(AgoraFit.scale(-5))
                make?.right.equalTo()(AgoraFit.scale(-5))
            }
            
            fontLabel.mas_remakeConstraints { make in
                make?.left.right().top().bottom().equalTo()(0)
            }
        }
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // 对于子配置cell，若设置图片，则隐藏font视图，显示image和color视图
    func setImage(_ image: UIImage?,
                  color: UIColor?) {
        if isMain {
            guard let i = image else {
                return
            }
            imageView.image = i.withRenderingMode(.alwaysTemplate)
            imageView.tintColor = color
        } else {
            imageView.image = image
            
            fontLabel.isHidden = true
            imageView.isHidden = false
            colorView.isHidden = false
            colorView.backgroundColor = color
        }
    }
    
    // 仅子配置cell可调用，若设置font，则隐藏image和color视图
    func setFont(_ font: Int) {
        guard !isMain else {
            return
        }
        fontLabel.isHidden = false
        imageView.isHidden = true
        colorView.isHidden = true

        fontLabel.text = "\(font)"
    }
}
